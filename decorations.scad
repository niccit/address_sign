// SPDX-License-Identifier: MIT

$fa = 0.4;
$fs = 1;
$fn = 50;

use <pin_connectors/pins.scad>;

// plumeria flower decoration
module plumeria() {
    union() {
        rotate([-90, 0, 0])import("images/decorations/plumeria.stl");
        translate([0, 10.5, -1])rotate([180, 0, 0])pin(h=10, r=4);
    }
}

module mermaid() {
    difference() {
        import("images/decorations/mermaid.stl");
    }
    color("blue")translate([0, 0, 15])rotate([180, 0, 0])pinhole(h=10, r=4, tight=false);
}

// Seagrass decoration
module seagrass() {
    union() {
        rotate([-90, 0, 0])scale([1.25, 2, 1])color("green")import("images/decorations/seagrass.stl");
        translate([0, 3, -0.5])rotate([180, 0, 0])color("blue")pin(h=10, r=4);
    }
}

// Tacks to cover decoration pinholes when not being used
module tacks(h=10, r=4) {
    pintack(h=h, r=r, bh=2, br=6);
}

module pinpegs(h=10, r=4) {
    pinpeg(h=h, r=4);
}

// hanger for securing sign to mailbox
module hooks() {
    module hanger() {
        difference() {
            linear_extrude(h=6)
                hull() {
                    circle(d=7);
                    translate([0, 8, 0]) circle(d=7);
                }
            translate([-5, 4, 3])rotate([0, 90, 0])cylinder(r=2, h=10);
        }
    }
    // connect hanger to pin
    union() {
        rotate([-90, 0, 0])pin(h=10, r=4);
        translate([-4, 0, 0])rotate([90, 90, 0])hanger();
    }
}

mermaid();