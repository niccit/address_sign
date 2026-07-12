// SPDX-License-Identifier: MIT

// Be sure the number size aligns with the number size specified in panel.scad
number_size = 120;
number_height_top = 10;
number_height_bottom = 7;

// The numbers are split into top and bottom so that they can be different colors
// If you're using LEDs you'll want to have the bottom numbers translucent or transparent
module number_one_top() {
    difference() {
        linear_extrude(number_height_top)
            text("1", size=number_size);
        translate([50, 105, 0])
            cylinder(h=5, d=10);
        translate([50, 6, 0])
            cylinder(h=5, d=10);
    }
}
module number_one_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("1", size=number_size);
        translate([50, 105, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([50, 6, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_two_top() {
    difference() {
        linear_extrude(number_height_top)
            text("2", size=number_size);
        translate([50, 110, 0])
            cylinder(h=5, d=10);
        translate([50, 6, 0])
            cylinder(h=5, d=10);
    }
}
module number_two_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("2", size=number_size);
        translate([50, 110, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([50, 6, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_three_top() {
    difference() {
        linear_extrude(number_height_top)
            text("3", size=number_size);
        translate([50, 110, 0])
            cylinder(h=5, d=10);
        translate([50, 4.5, 0])
            cylinder(h=5, d=10);
    }
}
module number_three_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("3", size=number_size);
        translate([50, 110, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([50, 4.5, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_four_top() {
    difference() {
        linear_extrude(number_height_top)
            text("4", size=number_size);
        translate([64, 105, 0])
            cylinder(h=5, d=10);
        translate([64, 8, 0])
            cylinder(h=5, d=10);
    }
}
module number_four_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("4", size=number_size);
        translate([64, 105, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([64, 8, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_five_top() {
    difference() {
        linear_extrude(number_height_top)
            text("5", size=number_size);
        translate([50, 108.5, 0])
            cylinder(h=5, d=10);
        translate([50, 5, 0])
            cylinder(h=5, d=10);
    }
}
module number_five_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("5", size=number_size);
        translate([50, 108.5, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([50, 5, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_six_top() {
    difference() {
        linear_extrude(number_height_top)
            text("6", size=number_size);
        translate([50, 110, 0])
            cylinder(h=5, d=10);
        translate([50, 4.5, 0])
            cylinder(h=5, d=10);
    }
}
module number_six_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("6", size=number_size);
        translate([50, 110, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([50, 4.5, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_seven_top() {
    difference() {
        linear_extrude(number_height_top)
            text("7", size=number_size);
        translate([38, 108, 0])
            cylinder(h=5, d=10);
        translate([38, 8, 0])
            cylinder(h=5, d=10);
    }
}
module number_seven_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("7", size=number_size);
        translate([38, 108, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([38, 8, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_eight_top() {
    difference() {
        linear_extrude(number_height_top)
            text("8", size=number_size);
        translate([48, 4, 0])
            cylinder(h=5, d=10);
        translate([48, 110.75, 0])
            cylinder(h=5, d=10);
    }
}
module number_eight_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("8", size=number_size);
        translate([48, 4, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([48, 110.75, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

module number_nine_top() {
    difference() {
        linear_extrude(number_height_top)
            text("9", size=number_size);
        translate([49, 4, 0])
            cylinder(h=5, d=10);
        translate([49, 110.75, 0])
            cylinder(h=5, d=10);
    }
}
module number_nine_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("9", size=number_size);
        translate([49, 4, 5 - 0.01])
            cylinder(h=19, d=10);
        translate([49, 110.75, 5 - 0.01])
            cylinder(h=19, d=10);
    }
}

module number_zero_top() {
    difference() {
        linear_extrude(number_height_top)
            text("0", size=number_size);
        translate([48, 5, 0])
            cylinder(h=5, d=10);
        translate([48, 110, 0])
            cylinder(h=5, d=10);
    }
}
module number_zero_bottom() {
    union() {
        linear_extrude(number_height_bottom)
            text("0", size=number_size);
        translate([48, 5, 5 - 0.01])
            cylinder(h=18, d=10);
        translate([48, 110, 5 - 0.01])
            cylinder(h=18, d=10);
    }
}

number_zero_top();
translate([100, 0, 0])number_zero_bottom();
translate([200, 0, 0])number_one_top();
translate([300, 0, 0])number_one_bottom();
translate([400, 0, 0])number_two_top();
translate([500, 0, 0])number_two_bottom();
translate([600, 0, 0])number_three_top();
translate([700, 0, 0])number_three_bottom();
translate([800, 0, 0])number_four_top();
translate([900, 0, 0])number_four_bottom();
translate([0, -150, 0])number_five_top();
translate([100, -150, 0])number_five_bottom();
translate([200, -150, 0])number_six_top();
translate([300, -150, 0])number_six_bottom();
translate([400, -150, 0])number_seven_top();
translate([500, -150, 0])number_seven_bottom();
translate([600, -150, 0])number_eight_top();
translate([700, -150, 0])number_eight_bottom();
translate([800, -150, 0])number_nine_top();
translate([900, -150, 0])number_nine_bottom();

