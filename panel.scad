// SPDX-License-Identifier: MIT

use <pin_connectors/pins.scad>
use <threads-scad/threads.scad>

$fa = 0.4;
$fs = 1;
$fn = 50;

// Enclosure Size
enclosure_length = 465;
enclosure_width = 250;
enclosure_height = 10;
number_size = 120;

// Number spacing for top
number_spacing = 86;
gap = number_spacing / 3;
first_number = -2;
second_number = first_number + number_spacing;
third_number = second_number + number_spacing + gap;
fourth_number = third_number + number_spacing;
fifth_number = fourth_number + number_spacing;

power_x = enclosure_length - 24;
power_y = enclosure_width - 53;
power_z = 5;

reset_x = enclosure_length - 20;
reset_y = enclosure_width - 30;
reset_z = 10;

// If you don't want to use the included texture you will need to resize and translate your texture to fit
module top_plate () {
    if (need_texture == true) {
        translate([0, 0, enclosure_height - 3])scale([2.74, 1.6, 1])linear_extrude(5)
            import("images/lava_ropes.svg");
    }
    cube([enclosure_length, enclosure_width, enclosure_height]);
}

module base_plate () {
    difference() {
        cube([enclosure_length, enclosure_width, enclosure_height + 10]);
        translate([10, 10, 2])cube([enclosure_length - 20, enclosure_width - 20, enclosure_height + 10]);
    }
}

module pcbStand() {
    RodEnd(4, 6, thread_diam=2);
}

module power_inlet() {
    cube([45, 12, 8]);
}

module reset_button() {
    rotate(([0, 90, 0]))cylinder(r=3.9, h=40);
}

// --- Numbers that need to be hollowed out for printing --- //
module number_zero() {
    union() {
        linear_extrude(enclosure_height + 5)text("0", size=number_size);
        translate([46, 40, -1])linear_extrude(h=enclosure_height + 10)hull() {
            translate([0, 35, 0]) circle(30);
            circle(30);
        }
    }
}

module number_four() {
    union() {
        linear_extrude(enclosure_height + 5)text("4", size=number_size);
        translate([12, 35, 0])
            difference() {
                cube([55, 76, enclosure_height + 10]);
                translate([-55, 35, -1])rotate([0, 0, -36])cube([65, 100, enclosure_height + 12]);
            }
    }
}

module number_six() {
    union() {
        linear_extrude(enclosure_height + 5)text("6", size=number_size);
        translate([50, 35, 0])cylinder(d=60, h=enclosure_height + 10);
    }
}

module number_eight() {
    union() {
        linear_extrude(enclosure_height + 5)text("8", size=number_size);
        translate([45, 85, 0])cylinder(d=50, h=enclosure_height + 10);
        translate([45, 30, 0])cylinder(d=55, h=enclosure_height + 10);
    }
}

module number_nine() {
    union() {
        linear_extrude(enclosure_height + 5)text("9", size=number_size);
        translate([46, 78, 0])cylinder(d=55, h=enclosure_height + 10);
    }
}

// --- end special numbers --- //

// The case is spec'd out for an Adafruit Feather ESP32-v2
module case() {
    module base_mount() {
        difference() {
            cube([54, 26.86, 10]);
            translate([0, 0, 1])cube([54, 26.86, 10]);
        }
    }
    union() {
        base_mount();
        translate([50, 22.55, 0 - 0.01])pcbStand();
        translate([50, 4.35, 0 - 0.01])pcbStand();
        translate([4.39, 22.55, 0 - 0.01])pcbStand();
        translate([4.39, 4.35, 0 - 0.01])pcbStand();
    }
}

// If you're using one of the module numbers, you don't need to linear_extrude, it's handled in the parent_module
// This is done so that the number is hollowed out
// Numbers 1, 2, 3, 5, and 7 don't need that, so you must linear_extrude when using them
module enclosure_top() {
    difference() {
        top_plate();
        translate([first_number, (enclosure_width / 2) - 5 , 0])
            number_zero();
        translate([second_number, (enclosure_width / 2) - 5, 0])linear_extrude(enclosure_height + 5)
            text("1", size=number_size);
        translate([third_number , 20, 0])linear_extrude(enclosure_height + 5)
            text("2", size=number_size);
        translate([fourth_number, 20, 0])linear_extrude(enclosure_height + 5)
            text("3", size=number_size);
        translate([fifth_number, 20, 0])
            number_four();
        if (need_decorations == true) {
            // pinholes for decorations
            translate([(enclosure_length / 2) - (gap + 15), (enclosure_width / 2), enclosure_height + 5])rotate([180, 0, 0])
                pinhole(h=14, r=4, lt=1, t=0.3, tight = true);
            translate([second_number + (gap - 35), 50, enclosure_height + 5])rotate([180, 0, 0])
                pinhole(h=14, r=4, lt=1, t=0.3, tight = true);
            translate([fourth_number + (gap + 20), enclosure_width - 48, enclosure_height + 5])rotate([180, 0, 0])
                pinhole(h=14, r=4, lt=1, t=0.3, tight = true);
        }
    }
    }

module enclosure_base() {
    difference() {
        union() {
            base_plate();
            translate([enclosure_length - 66, enclosure_width - 60, 2 - 0.01])case();
        }
        // inlet for power to circuit board
        translate([power_x + 4, power_y, power_z - 2])power_inlet();
        // reset button
        translate([reset_x, reset_y, reset_z])reset_button();
        // reset button inset
        translate([reset_x + 8, reset_y, reset_z])rotate([0, 90, 0])cylinder(d=9.4, h=10);
    }
}


// You can print the entire enclosure and then use your slicer to cut it top/bottom and add connectors
// You only need to cut it top/bottom if you're adding a circuit board and lights
// You can print the base and top without any type of connectors and choose your own way to connect them once assembled
// You can print the base and top with pins and cooresponding pinholes
// Default view is the entire enclosure
// Set need_decorations to false if you don't want to add any flourishes to the front of the panel
// Set need_texture to false if you don't want a textured top_plate
panel_base = false;
panel_top = true;
need_pinholes = false;
need_decorations = false;
need_texture = true;

 if (panel_top == true) {
     if (need_pinholes == true) {
         difference() {
             enclosure_top();
             // top
             translate([0 + 6, enclosure_width - 5, -1])pinhole(r=3, h=10, tight=false);
             translate([enclosure_length / 2, enclosure_width - 5, -1])pinhole(r=3, h=10, tight=false);
             translate([enclosure_length - 6, enclosure_width - 5, -1])pinhole(r=3, h=10, tight=false);
             // bottom
             translate([0 + 6, 5, -1])pinhole(r=3, h=10, tight=false);
             translate([enclosure_length / 2, 5, -1])pinhole(r=3, h=10, tight=false);
             translate([enclosure_length - 6, 5, -1])pinhole(r=3, h=10, tight=false);
             // sides
             translate([5, enclosure_width / 2, -1])pinhole(r=3, h=10, tight=false);
             translate([enclosure_length - 5, enclosure_width / 2, -1])pinhole(r=3, h=10, tight=false);
         }
     }
     else {
         enclosure_top();
     }
 }
 else if (panel_base == true) {
     if (need_pinholes == true) {
         union() {
             difference() {
                 enclosure_base();
                 // hangers
                 translate([enclosure_length / 4, enclosure_width + 1, (enclosure_height / 2) + 6])rotate([90, 0, 0])
                     pinhole(h = 10, r = 4, lt = 1, t = 0.3, tight = true);
                 translate([enclosure_length - 100, enclosure_width + 2, (enclosure_height / 2) + 6])rotate([90, 0, 0])
                     pinhole(h = 10, r = 4, lt = 1, t = 0.3, tight = true);
             }
             // top
             translate([0 + 6, enclosure_width - 5, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             translate([enclosure_length / 2, enclosure_width - 5, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             translate([enclosure_length - 6, enclosure_width - 5, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             // bottom
             translate([0 + 6, 5, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             translate([enclosure_length / 2, 5, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             translate([enclosure_length - 6, 5, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             // sides
             translate([5, enclosure_width / 2, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);
             translate([enclosure_length - 5, enclosure_width / 2, 19 - 0.01])rotate([0, 0, 0])pin(r=3, h=10);

             }
     }
     else {
         difference() {
             enclosure_base();
             // hangers
             translate([enclosure_length / 4, enclosure_width + 1, (enclosure_height / 2) + 6])rotate([90, 0, 0])pinhole(h = 10, r = 4, lt = 1, t = 0.3, tight = true);
             translate([enclosure_length - 100, enclosure_width + 2, (enclosure_height / 2) + 6])rotate([90, 0, 0])pinhole(h = 10, r = 4, lt = 1, t = 0.3, tight = true);
         }
     }
 }
 else {
     difference() {
         union() {
             enclosure_base();
             translate([0, 0, 20 - 0.01])enclosure_top();
         }
         // hangers
         translate([enclosure_length / 4, enclosure_width + 1, (enclosure_height / 2) + 10])rotate([90, 0, 0])pinhole(h = 10, r = 4, lt = 1, t = 0.3, tight = true);
         translate([enclosure_length - 100, enclosure_width + 2, (enclosure_height / 2) + 10])rotate([90, 0, 0])pinhole(h = 10, r = 4, lt = 1, t = 0.3, tight = true);
     }
 }