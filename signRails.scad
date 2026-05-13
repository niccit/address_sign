// SPDX-License-Identifier: MIT
$fa = 1;
$fs = 0.4;


rail_length = 300;
rail_width = 3;
rail_height =15;


// Set split to true if your 3D Printer can't support a length of 300mm
split = false;
if (split == true) {
    cube([(rail_length / 2), rail_width, rail_height], center=true);
    translate([0, (rail_width * 3), 0])
        cube([(rail_length / 2), rail_width, rail_height], center=true);
}
else {
    cube([rail_length, rail_width, rail_height], center=true);
}