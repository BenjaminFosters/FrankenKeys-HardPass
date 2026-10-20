// FrankenKeys HardPass: RP2350-Zero case shell
// The Waveshare model is proprietary (STEP converted to STL with FreeCAD)
// and is not part of this file. Set show_model = true to overlay it for fit checks.

show_model = false;

// ---------- Parameters ----------

// Board (RP2350-Zero)
rp_board = [18, 23.5];          // [X width, Y length]

// USB-C cutout
usb_c_w     = 8.34 + 1.5;       // width incl. clearance
usb_c_h     = 2.56 + 1.5;       // height incl. clearance
usb_c_r     = 1.25;             // corner radius
usb_c_z     = 0.25;             // bottom of the cutout above z = 0
usb_c_depth = 5;                // cut depth into the back wall

// Shell
floor_t  = 2;                   // material under the cavity
cavity_h = 5;                   // board space (rails sit inside this)
lid_h    = 2;                   // headroom above the cavity for the lid tab
shell_w  = rp_board.x + 3;
shell_l  = rp_board.y + 2.25;
shell_h  = floor_t + cavity_h + lid_h;
shell_y0 = -0.5;                // front face of the shell

// Rails
rail_t      = 0.5;
rail_z_low  = 1;
rail_z_high = cavity_h - rail_t;
rail_l      = rp_board.y + 2;

// Screws
screw_d      = 3.4;             // M3 clearance diameter (Claude Suggested)
screw_margin = 1.7;             // material on each side of the hole (1.5 minimum)

// Derived positions
cx       = rp_board.x / 2;      // X centerline everything is symmetric about
shell_x0 = cx - shell_w / 2;    // left outer wall
shell_x1 = cx + shell_w / 2;    // right outer wall
shell_y1 = shell_y0 + shell_l;  // back face of the shell

// Render settings
eps = 0.1;                      // overshoot so boolean cuts never share faces
$fs = 0.1;

// ---------- Helpers ----------

// Cube centered on the X centerline; y and z start at the origin like a normal cube
module cube_cx(size) {
    translate([cx - size.x / 2, 0, 0]) cube(size);
}

// Reusable screw block with a hole through its full length (along +Y).
// Origin-relative: the block spans x = -eps..width, y = 0..length, z = 0..height,
// and the hole is centered in X and Z. The -eps overlap fuses it into the wall it
// touches. Mirror it for the other side; reuse it for the lid with other arguments.
module screw_boss(length, height = shell_h, margin = screw_margin) {
    w = screw_d + 2 * margin;
    difference() {
        translate([-eps, 0, 0])
            cube([w + eps, length, height]);
        translate([w / 2, -eps, height / 2])
            rotate([-90, 0, 0])
                cylinder(d = screw_d, h = length + 2 * eps);
    }
}

// ---------- Shell parts ----------

module shell_body() {
    color([1, 0.5, 0])
    translate([0, shell_y0, -floor_t])
        cube_cx([shell_w, shell_l, shell_h]);
}

// Open at the front and top
module cavity() {
    translate([0, shell_y0 - eps, 0])
        cube_cx([rp_board.x + 1, rp_board.y + 1.25 + eps, cavity_h + lid_h + eps]);
}

// Pocket under the board, open to the front
module underbelly() {
    translate([0, -1, -1])
        cube_cx([16, 22, 2]);
}

module type_c_cutout() {
    translate([cx - usb_c_w / 2, shell_y1 + eps, usb_c_z])
    hull()
        for (x = [usb_c_r, usb_c_w - usb_c_r],
             z = [usb_c_r, usb_c_h - usb_c_r])
            translate([x, 0, z])
                rotate([90, 0, 0])
                    cylinder(h = usb_c_depth, r = usb_c_r);
}

// Full-width rail with the center strip removed
module railing(z) {
    difference() {
        translate([0, shell_y0, z])
            cube_cx([shell_w, rail_l, rail_t]);
        translate([0, shell_y0 - eps, z - eps])
            cube_cx([rp_board.x - 2, rail_l + 2 * eps, rail_t + 2 * eps]);
    }
}

// Tab for lid insertion
module lid_tab() {
    tab_l = 3;
    translate([0, shell_y1 - tab_l, cavity_h])
    difference() {
        cube_cx([shell_w, tab_l, lid_h]);
        translate([0, -eps, -eps])
            cube_cx([rp_board.x + 1, 2 + eps, 1 + eps]);
    }
}

// One screw block on each outer wall, mirrored around the centerline
module side_screw_bosses() {
    translate([shell_x1, shell_y0, -floor_t])
        screw_boss(shell_l);
    translate([shell_x0, shell_y0, -floor_t])
        mirror([1, 0, 0])
            screw_boss(shell_l);
}

// ---------- Assembly ----------

module case_shell() {
    difference() {
        shell_body();
        cavity();
        underbelly();
        type_c_cutout();
    }
    side_screw_bosses();
    railing(rail_z_low);
    railing(rail_z_high);
    lid_tab();
}

case_shell();

if (show_model)
    %translate([0, 0.5, 1]) import("RP2350-Zero.stl");
