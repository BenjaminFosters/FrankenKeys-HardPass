// RP2350-Zero case shell
// The Waveshare model is proprietary (STEP converted to STL with FreeCAD)
// and is not part of this file. Set show_model = true to overlay it for fit checks.

show_model = true;

// Dimensions
rp_board = [18, 23.5];      // [X width, Y length]
usb_c_w  = 8.34 + 1.5;        // cutout width incl. clearance
usb_c_h  = 2.56 + 1.5;        // cutout height incl. clearance
usb_c_r  = 1.25;            // cutout corner radius

shell_w  = rp_board.x + 3;
shell_l  = rp_board.y + 2.25;
shell_y0 = -0.5;            // front face of the shell
floor_t  = 2;
cavity_h = 5;
rail_t   = 0.5;
rail_z_low  = 1;
rail_z_high = cavity_h - rail_t;

eps = 0.1;                  // overshoot so boolean cuts never share faces
$fs = 0.1;

// Cube centered on the board's X axis; y and z start at the origin like a normal cube
module cube_cx(size) {
    translate([rp_board.x / 2 - size.x / 2, 0, 0]) cube(size);
}

module shell_body() {
    color([1, 0.5, 0])
    translate([0, shell_y0, -floor_t])
        cube_cx([shell_w, shell_l, floor_t + cavity_h + 2]);
}

// Open at the front and top
module cavity() {
    color([1, 0.5, 0])
    translate([0, shell_y0 - eps, 0])
        cube_cx([rp_board.x + 1, rp_board.y + 1.25 + eps, cavity_h + 2 + eps]);
}

module underbelly() {
    color([1, 0, 0])
    translate([0, -1, -1])
        cube_cx([16, 22, 2]);
}

module type_c_cutout() {
    color([1, 0.5, 1])
    translate([rp_board.x / 2 - usb_c_w / 2, rp_board.y + 2, 0.5/2])
    hull()
        for (x = [usb_c_r, usb_c_w - usb_c_r],
             z = [usb_c_r, usb_c_h - usb_c_r])
            translate([x, 0, z])
                rotate([90, 0, 0])
                    cylinder(h = 5, r = usb_c_r);
}

// Two side rails with the center strip removed
module railing(z) {
    len = rp_board.y + 2;
    difference() {
        translate([0, shell_y0, z])
            cube_cx([shell_w, len, rail_t]);
        translate([0, shell_y0 - eps, z - eps])
            cube_cx([rp_board.x - 2, len + 2 * eps, rail_t + 2 * eps]);
    }
}

// Tab for lid insertion
module lid_tab() {
    translate([0, rp_board.y - 1.25, cavity_h])
    difference() {
        cube_cx([shell_w, 3, 2]);
        translate([0, -eps, -eps])
            cube_cx([rp_board.x + 1, 2 + eps, 1 + eps]);
    }
}

screw_r = 3.4;
screw_clearance = 7;

// Orthogonal Screw Hole
module screw_hole(){
    difference() {
        // Negative
        cube([screw_r + screw_clearance,1, floor_t + cavity_h + 2]);
        // Positive
        translate([(screw_r + screw_clearance)/2,1, (floor_t + cavity_h + 2)/2])rotate([90])cylinder(r = screw_r);
    }
}

// Screw Hole for Body
module sh_body() {
    hull() {
    translate([0,5,0])screw_hole();
    screw_hole();
    }
}

//translate([15.5,-.5,-2])screw_hole();
translate([15.5,-.5,10])screw_hole();
sh_body();

module case_shell() {
    difference() {
        shell_body();
        cavity();
        underbelly();
        type_c_cutout();
    }
    railing(rail_z_low);
    railing(rail_z_high);
    lid_tab();
}

case_shell();

if (show_model)
    %translate([0, 0.5, 1]) import("RP2350-Zero.stl");