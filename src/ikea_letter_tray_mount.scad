// https://www.thingiverse.com/thing:422252/
// released under CC attribution license
use <uploads_a1_41_64_c7_58_2dfillet.scad>

$fn=100;
$fillet_fn=24;

// measurements from Ikea DOKUMENT (currently guesstimates)
bar_r = 3.5;
between_crossbars_y = 105;

tube_y = between_crossbars_y;
tube_t = 3;         // tube thickness of base
tube_tol = 0.25;    // add some air on the inside of the tube
tube_inner_r = bar_r+tube_tol;
tube_outer_r = tube_inner_r+tube_t;

// screw positions
screw_inner_offset_x = 10;

// screw dimensions
screw_grooving_diameter = 3;
screw_head_r = 5.5/2;
screw_head_depth = 2;
screw_head_clearance = 0.5;
screw_seating_t = 1;
screw_seating_r = screw_head_r + screw_head_clearance + screw_seating_t;
screw_depth = 10; // something high, doesn't matter

module halftube() {
    out_r = tube_outer_r;
    in_r = tube_inner_r;
    dif = 1;
    
    rotate([-90,0,0])
        linear_extrude(height=tube_y)
            translate([0,-in_r])
                difference() {
                    // outer
                    union() {
                        intersection() {
                            circle(r=out_r);
                            translate(out_r*[-1,-1])
                                square(out_r*[2,1]);
                        }
                        translate([-out_r,0])
                            square([2*out_r, in_r]);
                    }
                    // inner
                    circle(r=in_r);
                    translate([-in_r,0])
                        square([2*in_r, out_r+dif]);
                }
}

module screw(grooving_diameter, screw_depth, head_diameter, head_depth) {
    dif=1;
    translate([0,0,-head_depth]) {
        cylinder(r=head_diameter/2, h=head_depth);
        translate([0,0,-screw_depth])
            cylinder(r=grooving_diameter/2, h=screw_depth+dif);
    }
}

module screw_seatings() {
    module screw_seating(fillet_r, fillet_base_y, fillet_base_offset_x=0) {
        dummy = 1;       
        fillet_display(fillet_r, fn_fillet=$fillet_fn) {
            translate([-(screw_seating_r + dummy + fillet_base_offset_x), -fillet_base_y/2])
                square([dummy, fillet_base_y]);
            circle(screw_seating_r);
        }
    }
    fillet_outer_r = 6;
    fillet_inner_r = 20.5;
    
    fillet_base_y_outer = 4*screw_seating_r;
    fillet_base_y_inner = 0.5*tube_y;
    
    linear_extrude(height=tube_inner_r) {
        screw_positions_outer() {
            screw_seating(fillet_outer_r, fillet_base_y_outer);
        }
        screw_positions_inner() {
            rotate([0,0,180])
                screw_seating(fillet_inner_r, fillet_base_y_inner, fillet_base_offset_x=screw_inner_offset_x);
        }
    }
}

module screw_holes() {
    module screw_hole() {
        dif = 1;
        translate([0,0,tube_inner_r+dif])
            screw(screw_grooving_diameter, screw_depth+2*dif, 2*screw_head_r+2*screw_head_clearance, screw_head_depth+dif);
    }
    
    screw_positions_outer() {
        screw_hole();
    }
    screw_positions_inner() {
        screw_hole();
    }
}

module screw_positions_outer() {   
    // screws are positioned on the y axis by some offset from the center
    screw_y_inner_offset = 0.35*tube_y;
    screw_ys = [-screw_y_inner_offset, screw_y_inner_offset];
    screw_x = tube_outer_r + screw_seating_r;
    
    for(i = [0:1:1]) {
        translate([screw_x, screw_ys[i] + tube_y/2, 0])
            children();
    }
}

module screw_positions_inner() {
    screw_x = tube_outer_r + screw_seating_r + screw_inner_offset_x;
    translate([-screw_x, tube_y/2, 0])
        children();
}

module mount() {
    difference() {
        union() {
            halftube();
            screw_seatings();
        }
        screw_holes();
    }
}

mount();