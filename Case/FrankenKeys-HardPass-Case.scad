// This is Proprietary, owned by Waveshare, Uncomment to show the model
// Converted from STEP to STL with FreeCAD
translate([0,0.5,1]) {
    import("RP2350-Zero.stl");
}

$fs=.1;
usb_c_w = 8.34+1;
usb_c_h = 2.56+1;
rp_board = [18, 23.5];

// Type-C Cutout
module type_c_cutout() {
    color([1,0.5,1]) {
        translate([(rp_board.x - usb_c_w)/2, rp_board.y+2, 1/2]){
        type_c_radius = 1.25;
            hull() {
                translate([type_c_radius, 0, type_c_radius])rotate([90,90,1])cylinder(5,type_c_radius,type_c_radius);
                translate([type_c_radius, 0, usb_c_h - type_c_radius])rotate([90,90,1])cylinder(5,type_c_radius,type_c_radius);
                translate([usb_c_w - type_c_radius , 0, type_c_radius])rotate([90,90,1])cylinder(5,type_c_radius,type_c_radius);
                translate([usb_c_w - type_c_radius, 0, usb_c_h - type_c_radius])rotate([90,90,1])cylinder(5,type_c_radius,type_c_radius);
            //cube([usb_c_w, 1, usb_c_h]);
            }
        }
    }
}

union() {
// Tab
translate([-1.5, rp_board.y-1.25, 5])difference() {
    // Positive
    cube([rp_board.x+3, 3, 2]);
    
    // Negative
    translate([1,0,0])cube([rp_board.x+1.5, 2, 1]);
}    


union() {
    translate([0,1,0])difference() {
    // Railing
        // Positive
        translate([-1.5,0,1]){
        cube([rp_board.x+2,rp_board.y,0.5]);
        }
        
        // Negative
        translate([1,0,1]){
        cube([rp_board.x - 3,rp_board.y,0.5]);
        }}
difference() {
    // Board Baseline
    difference(){
        // Positives
        color([1,0.5,0]) {
            translate([0-1.5,-.5,0-2]){
                cube([rp_board.x+3, rp_board.y + 1.25 + 1, 5 + 2]);
            }
        }

        // Negatives
        union() {
            // Body Negative
            color([1,0.5,0]) {
                translate([-.5,-.5,0]){
                    cube([rp_board.x+.5, rp_board.y + 1.25,5]);
                }
            }
            // Underbelly Negative
            color([1,0,0]) {
                translate([1,0, -1]) {
                    cube([16,20,2]);
                }
            }
        }
    }
    // Type-C Cutout
    type_c_cutout();
}}}