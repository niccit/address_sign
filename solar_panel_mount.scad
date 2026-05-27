use <solar_panel_mount.scad>
// OpenSCAD file
// Created: 5/22/26
// SPDX-License-Identifier: MIT
$fa = 1;
$fs = 0.4;
$fn = 50; // Circle resolution

// 16.23

use <threads-scad/threads.scad>

module hook() {
    difference() {
        cube([55, 28.23, 50], center=true);
        translate([0, 3, -1])
            cube([56, 16.23, 50], center=true);
        translate([0, 13, -1])
            cube([56, 4, 50], center=true);
    }
}

module front_plate() {
    union() {
        difference() {
            cube([55, 3, 3.5], center=true);
            translate([0, -1, 0])
                cube([55, 3, 2.5], center=true);

        }
       translate([0, -0.99 - 0.01, -11.75])
           cube([55, 1, 21], center=true);
     }
}

module mount() {
    union() {
        cylinder(h=5, d1=28, d2= 22.25);
        RodStart(22, 30, thread_len=11, thread_diam=19.55, thread_pitch=1.5);
        translate([0, 0, 39.75 - 0.01])
            top();
    }
}

module screw_cap() {
    difference() {
        RodEnd(24.30, 15, thread_len=0, thread_diam=19.90, thread_pitch=1.5);
        translate([0, 0, -1])
            cylinder(h=4, d=13.72);
    }
}


module door_screw() {
    cylinder(h=5, d=11.25);
    translate([0, 0, 0.25 - 0.01])
        MetricBolt(4, 47, tolerance=0.7);
}

module top() {
    difference() {
        cylinder(h=9, d=11.07);
        translate([0, 0, 9])
            sphere(d=10.13);
    }
}

all = true;
cap = false;
hook = false;
rod = false;

if (all == true) {
    union() {
        hook();
        translate([0, 12.62 - 0.01, 22.85])
           front_plate();
        translate([0, 0, 24.25 - 0.01])
           mount();
    }

    translate([0, -30, 0])
        screw_cap();
}

if (cap == true) {
    screw_cap();
}

if (rod == true) {
    mount();
}

if (hook == true) {
    union() {
        hook();
        translate([0, 12.62 - 0.01, 22.85])
           front_plate();
    }
}



