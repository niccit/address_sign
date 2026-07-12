# SPDX-License-Identifier: MIT

import json
import analogio
import board
import time
import os
import neopixel
import adafruit_logging
import wifi
import supervisor
import adafruit_connection_manager
import adafruit_minimqtt.adafruit_minimqtt
from adafruit_led_animation.group import AnimationGroup
from adafruit_led_animation.helper import PixelMap
from adafruit_minimqtt.adafruit_minimqtt import MMQTTException, MMQTTStateError
from adafruit_led_animation.sequence import AnimationSequence
from circuitpy_libs import animationBuilder
from circuitpy_libs import updateAnimationData
from circuitpy_libs import updateFiles
from circuitpy_libs import timeHelper
from circuitpy_libs import alarmsHelper
from circuitpy_libs import wanChecker
from circuitpy_libs import batteryMonitorHelper
from circuitpy_libs import getColors

# --- Set up logging --- #
logger = adafruit_logging.getLogger("address_sign")

# --- Get configuration data --- #
try:
    from data import data
    logger.info(f"data imported successfully")
except ImportError as ie:
    logger.error(f"failed to import data: {ie}")
    raise

# Variable assignments
testing = data["testing"]
high_limit = data["brightness_high"]
low_limit = data["brightness_low"]
pixel_count = data["num_pixels"]
wake_time = data["wake_time"]
wake_time_adjustment = data["wake_time_adjustment"]
shutdown_time = data["shutdown_time"]
shutdown_time_adjustment = data["shutdown_time_adjustment"]
before_shutdown = data["before_shutdown_window"]
after_shutdown = data["after_shutdown_window"]

if wake_time is not None:
    wake_time = timeHelper.get_time_in_seconds(wake_time)

if shutdown_time is not None:
    shutdown_time = timeHelper.get_time_in_seconds(shutdown_time)

ignore_sleep_string = data["ignore_sleep"]
if ignore_sleep_string is "False":
    ignore_sleep = False
else:
    ignore_sleep = True

ignore_shutdown_string = data["ignore_shutdown"]
if ignore_shutdown_string is "False":
    ignore_shutdown = False
else:
    ignore_shutdown = True

running = False
time_in_seconds = None
sunset_in_seconds = None
sunrise_in_seconds = None


if testing:
    logger.setLevel(adafruit_logging.DEBUG)
    logger.info("testing")
else:
    logger.setLevel(adafruit_logging.INFO)
    logger.info("live")


# ---- Battery ---- #
batMon = analogio.AnalogIn(board.VOLTAGE_MONITOR)
batteryCheckWait = 60
batteryCheck = None
batteryWarn = False

# ---- Helper classes ---- #
# Set all the pixels to black
def blank_all():
    pixels.fill((0, 0, 0))
    pixels.show()


# --- Set up NeoPixels --- #
num_pixels = pixel_count
pixels = neopixel.NeoPixel(board.D13, num_pixels, brightness=high_limit, auto_write=False, pixel_order=neopixel.RGB)
# addy_lights = PixelMap(pixels, [(2, 5), (6, 10), (12, 16), (17, 22), (22, 28) ], individual_pixels=False)
addy_lights = pixels
on_board_pixel = neopixel.NeoPixel(board.NEOPIXEL, 1)

# --- MQTT Configuration --- #
radio = wifi.radio
pool = adafruit_connection_manager.get_radio_socketpool(radio)
ssl_context = adafruit_connection_manager.get_radio_ssl_context(radio)

# MQTT feeds
subscribe_list = []
m_time = os.getenv("mqtt_time")
subscribe_list.append(m_time)
sunset = os.getenv("sunset")
subscribe_list.append(sunset)
sunrise = os.getenv("sunrise")
subscribe_list.append(sunrise)
address_lights = os.getenv("address_lights")
subscribe_list.append(address_lights)
battery_monitor = os.getenv("battery_monitor")

# MQTT specific helpers
def on_connect(mqtt_client, userdata, flags, rc):
    # This function will be called when the mqtt_client is connected
    # successfully to the broker.
    logger.info(f"Connected to MQTT Broker {mqtt_client.broker}!")
    logger.debug(f"Flags: {flags}\n RC: {rc}")
    for topic in subscribe_list:
        mqtt_client.subscribe(topic)


def on_disconnect(mqtt_client, userdata, rc):
    # This method is called when the mqtt_client disconnects
    # from the broker.
    logger.warning(f"{mqtt_client} Disconnected from MQTT Broker!")
    counter = 0
    backoff_sleep = 1
    backoff_increment = 1
    while counter <= 10:
        try:
            mqtt_client.reconnect()
            counter = 11
        except MMQTTException:
            counter += 1
            if counter - 1 == 0:
                time.sleep(backoff_sleep)
            else:
                backoff_sleep += backoff_increment
                time.sleep(backoff_sleep)
            pass

def on_subscribe(mqtt_client, userdata, topic, granted_qos):
    # This method is called when the mqtt_client subscribes to a new feed.
    logger.info(f"Subscribed to {topic} with QOS level {granted_qos}")

def on_unsubscribe(mqtt_client, userdata, topic, pid):
    # This method is called when the mqtt_client unsubscribes from a feed.
    logger.info(f"Unsubscribed from {topic} with PID {pid}")

def on_publish(mqtt_client, userdata, topic, pid):
    # This method is called when the mqtt_client publishes data to a feed.
    logger.info(f"Published to {topic} with PID {pid}")


reload = False
update = False
floats = ["speed", "length", "size", "spacing"]
notString = False
def on_message(client, topic, message):
    global time_in_seconds, sunset_in_seconds, sunrise_in_seconds, reload, update, notString
    logger.info(f"New message for {client} on topic {topic}: {message}")
    # Support changes to the light configurations in the data.py file
    if "lights" in topic:
        received_message = json.loads(message)
        logger.debug(f"received message {received_message}")
        # since the name of the name/value pair is known, use this in the MQTT message
        # it will be transformed to the actual value in the data file before calling updater.update_data_file
        search_string = received_message["search_string"]
        mod_current_string = str(data[search_string]).strip("' [ ]")
        mod_new_string = str(received_message["new_value"]).strip("' [ ]")

        for _ in floats:
            if _ in search_string:
                notString = True
                logger.debug(f"dealing with floats not strings, {notString}")

        if notString:
            if data[search_string] != received_message["new_value"]:
                update = True
                logger.debug(f"compared floats and something changed")
            notString = False
        else:
            logger.debug(f"new string is {type(mod_new_string)}:{mod_new_string} and current string is {type(mod_current_string)}:{mod_current_string}")
            if mod_new_string not in mod_current_string:
                update = True
                logger.debug(f"compared strings and something changed")


        if "animations" is search_string and update:
            reload = True
            logger.debug(f"we have an animation or a config change,  {reload}")

        if update:
            received_message['search_string'] = str(data[search_string])
            updated_message = json.dumps(received_message)
            logger.debug(f"update message is {updated_message}, and search string is {str(search_string)}")
            updateFiles.update_data_file(updated_message, search_string)

        if reload:
            logger.debug("reloading")
            supervisor.reload()

    if "time" in topic:
        received_time = message
        logger.debug(f"New message for {client} on topic {topic}: {received_time}")
        time_in_seconds = timeHelper.get_time_in_seconds(received_time)
    if "sunset" in topic:
        sunset_time = message
        logger.debug(f"New message for {client} on topic {topic}: {sunset_time}")
        sunset_in_seconds = timeHelper.get_time_in_seconds(sunset_time)
    if "sunrise" in topic:
        sunrise_time = message
        logger.debug(f"New message for {client} on topic {topic}: {sunrise_time}")
        sunrise_in_seconds = timeHelper.get_time_in_seconds(sunrise_time)

    if time_in_seconds and sunset_in_seconds and sunrise_in_seconds:

        if not ignore_sleep:
            if wake_time is not None:
                need_sleep, time_diff = alarmsHelper.check_need_sleep(time_in_seconds, wake_time,
                                                                      wake_time_adjustment)
            else:
                need_sleep, time_diff = alarmsHelper.check_need_sleep(time_in_seconds, sunset_in_seconds,
                                                                      wake_time_adjustment)
            logger.debug(f"need sleep is {need_sleep} time diff is {time_diff}")

            if need_sleep:
                logger.debug("blanking pixels")
                blank_all()
                logger.debug("sleeping before sunset")
                on_board_pixel.fill((0, 0, 0))
                on_board_pixel.show()
                alarmsHelper.sleep_before_set_time(time_diff, 0)
            else:
                logger.debug(f"set to ignore sleep before sunset: {ignore_sleep}")

        if not ignore_shutdown:
            if shutdown_time is not None:
                if wake_time is not None:
                    need_shutdown, time_diff = alarmsHelper.check_need_shutdown(time_in_seconds, shutdown_time, before_shutdown,
                                                                                after_shutdown, wake_time_adjustment, wake_time)
                else:
                    need_shutdown, time_diff = alarmsHelper.check_need_shutdown(time_in_seconds, shutdown_time, before_shutdown,
                                                                                after_shutdown, wake_time_adjustment, sunset_in_seconds)
            else:
                if wake_time is not None:
                    need_shutdown, time_diff = alarmsHelper.check_need_shutdown(time_in_seconds, sunrise_in_seconds, before_shutdown,
                                                                                after_shutdown, wake_time_adjustment, wake_time )
                else:
                    need_shutdown, time_diff = alarmsHelper.check_need_shutdown(time_in_seconds, sunrise_in_seconds, before_shutdown,
                                                                                after_shutdown, wake_time_adjustment, sunset_in_seconds)

            logger.debug(f"need shutdown is {need_shutdown} time diff is {time_diff}")

            if need_shutdown:
                logger.debug("blanking pixels")
                blank_all()
                logger.debug("it's sunrise, sleeping before sunset")
                on_board_pixel.fill((0, 0, 0))
                on_board_pixel.show()
                alarmsHelper.shutdown(time_diff, 0)
            else:
                logger.debug(f"set to ignore shutdown: {ignore_shutdown}")

mqtt_local_broker = os.getenv("mqtt_local_server")
mqtt_local_port = os.getenv("mqtt_local_port")
mqtt_local_username = os.getenv("mqtt_local_username")
mqtt_local_key = os.getenv("mqtt_local_key")
local_mqtt = adafruit_minimqtt.adafruit_minimqtt.MQTT(
    broker=mqtt_local_broker
    ,port = int(mqtt_local_port)
    ,username=mqtt_local_username
    ,password=mqtt_local_key
    ,socket_pool=pool
    ,ssl_context=ssl_context
    ,is_ssl=False
)

# Connect callback handlers for local mqtt_client
local_mqtt.on_connect = on_connect
local_mqtt.on_disconnect = on_disconnect
local_mqtt.on_subscribe = on_subscribe
local_mqtt.on_unsubscribe = on_unsubscribe
local_mqtt.on_publish = on_publish
local_mqtt.on_message = on_message

# Connect
network_status = wanChecker.cpy_wan_active()
logger.info(f"network status is {network_status}")
if network_status:
    try:
        local_mqtt.connect()
    except adafruit_minimqtt.adafruit_minimqtt.MMQTTStateError:
        logger.error("Failed to connect to MQTT broker!")
        supervisor.reload()
else:
    try:
        wifi.radio.connect(os.getenv("CIRCUITPY_WIFI_SSID"), os.getenv("CIRCUITPY_WIFI_PASSWORD"))
    except ConnectionError:
        logger.error("Failed to connect to WiFi")
        supervisor.reload()



# --- Build Animations --- #
# Animations defined in animation.json
# Custom colors defined in data.py
current_animations = data["animations"]
animation_group = []
color = None
override_array = ["sparkles", "speed", "rate", "count", "period", "tail_length", "step", "reverse", "spacing", "size",
                  "bounce"]
# Read in all animations from json file
# And build the animation objects and append them to the array
# Support animations for the tree and the star
with open('./lib/circuitpy_libs/animations.json', 'r') as infile:
    adata = json.load(infile)
    for item in adata['animations']:
        if item['name'] in current_animations:
            # Check for any animation overrides and update the JSON object
            item_with_overrides = updateAnimationData.override_default_settings(data, override_array, item)
            # Set the color choice
            updated_item = updateAnimationData.set_color(data, item_with_overrides)

            if item['name'] in current_animations:
                logger.debug(f"{item['name']} is our animation")
                obj = animationBuilder.build_animation(addy_lights, updated_item)

            animation_group.append(obj)

if len(animation_group) > 2:
    animations = AnimationSequence(
        AnimationGroup(
            *(x for x in animation_group))
        ,advance_interval=5
    )
else:
    animations = AnimationSequence(
        AnimationGroup(
            *(x for x in animation_group))
        ,advance_interval=0
    )

# --- Settings for Non-Blocking(ish) Hack provided by Mikey Sklar from Adafruit Forums! --- #
FRAME_DELAY = 0.01    # 100 FPS (20 ms per frame)
MQTT_POLL_EVERY = 1500 # poll MQTT about every 30 seconds (every 100 frames is about ~2 seconds at 50 FPS)
frame_counter = 0

# --- Main --- #
logger.info("Address sign starting up")
while True:

    animations.animate()

    frame_counter += 1

    if frame_counter >= MQTT_POLL_EVERY:
        # Check WAN connectivity
        wan_state = wanChecker.cpy_wan_active()
        logger.debug(f"WAN state is {wan_state} {wifi.radio.ap_info.ssid} {wifi.radio.ipv4_address}")

        # if MQTT_POLL_EVERY criterion is met, loop mqtt for 1 second
        if wan_state:
            logger.debug(f"WAN state is {wan_state}")
            try:
                local_mqtt.loop(timeout=1)
            except MMQTTStateError as e:
                print(f"MQTT error: {e}, reloading")
                supervisor.reload()
            except MMQTTException as me:
                print(f"MQTT error: {me}, reloading")
                supervisor.reload()
        else:
            logger.error(f"network not connected {wan_state}, reloading")
            supervisor.reload()

        # Check the voltage of the battery, send a message to MQTT if it's below 3.7V
        if batteryCheck is None or time.monotonic() > batteryCheck + batteryCheckWait:
            batteryVoltage, batteryPercentage = batteryMonitorHelper.monitor_battery(batMon, "v1")
            batteryVoltage = round(batteryVoltage, 1)
            batteryVoltage_pretty_print = batteryMonitorHelper.format_battery_voltage(batteryVoltage)
            batteryWarnHigh, batteryWarnLow = batteryMonitorHelper.get_discharging_level()
            batteryAlarm = batteryMonitorHelper.get_warning_level()
            bat_message = {
                "raw_voltage": batteryVoltage,
                "pretty_voltage": batteryVoltage_pretty_print,
                "warn": batteryWarnLow,
                "alarm": batteryAlarm
            }
            bat_message = json.dumps(bat_message)
            logger.debug(f"sending message {bat_message}")
            local_mqtt.publish(battery_monitor, bat_message)
            batteryCheck = time.monotonic()

        frame_counter = 0

    time.sleep(FRAME_DELAY)
