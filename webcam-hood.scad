// Little hood for the Logitec C920 webcam.
// (c) h.zeller@acm.org Creative Commons license BY-SA

$fn=128;

WALL_WIDTH = 2.3;
HOOD_WALL_WIDTH = 0.6;

BRACKET_DEPTH = 5 + WALL_WIDTH/2;
BRACKET_WIDTH = 48;
BRACKET_HEIGHT = 29.5;
BRACKET_ANGLE = 4.7;

HOOD_HEIGHT = 25;
HOOD_ASPECT = 1920/1080;
HOOD_PROXIMAL_RADIUS = 4.5;
HOOD_DISTAL_RADIUS = BRACKET_HEIGHT * 0.65;

SNAP_FIT_GAP = 0.25;
SNAP_WIDTH = WALL_WIDTH/2;

IMAGE_WIDTH = 109;
IMAGE_DISTANCE = 80;
IMAGE_WIDTH_INCLINATION = IMAGE_WIDTH / IMAGE_DISTANCE;
IMAGE_HEIGHT_INCLINATION = 1080/1920 * IMAGE_WIDTH_INCLINATION;

// The free space at the bottom in the bracket to slide the hood in. It needs to be wide
// enough, so that the hood, approached from bracket_depth below will fit in the hole.
// So the hole needs to be a bit wider by the following margin.
MOUNTING_MARGIN = IMAGE_WIDTH_INCLINATION * BRACKET_DEPTH;
MOUNTING_SPACE=2 * (HOOD_PROXIMAL_RADIUS * HOOD_ASPECT + WALL_WIDTH * IMAGE_WIDTH_INCLINATION) + 2 * MOUNTING_MARGIN;
mounting_plate_width = BRACKET_WIDTH - 2;
mounting_plate_height = BRACKET_HEIGHT - 2;

cut_radius=2 * HOOD_DISTAL_RADIUS;

// Model to play with.
module camera() {
    // Camera body
    hull() {
	translate([0, 0, -12.5]) cube([60, BRACKET_HEIGHT, 25], center=true);
	translate([38, BRACKET_HEIGHT/2, -16]) rotate([90, 0, 0]) cylinder(h=BRACKET_HEIGHT, r=5);
	translate([-38, BRACKET_HEIGHT/2, -16]) rotate([90, 0, 0]) cylinder(h=BRACKET_HEIGHT, r=5);
    }
    // The imaging area that needs to be free.
    d = 1.5 * HOOD_HEIGHT;
    w = IMAGE_WIDTH_INCLINATION * d / 2;
    h = IMAGE_HEIGHT_INCLINATION * d / 2;
    image_plane  = -9;
    translate([0, 0, image_plane]) polyhedron(points = [ [0, 0, 0],
	    [-w, -h, d], [w, -h, d], [w, h, d], [-w, h, d] ],
	faces = [ [ 0, 1, 2], [0, 2, 3], [0, 3, 4], [0, 4, 1],
	[1, 2, 3], [1, 3, 4] ]);
}

module base_bracket() {
    // The body.
    translate([0, 0, WALL_WIDTH/2]) cube([BRACKET_WIDTH, BRACKET_HEIGHT + WALL_WIDTH, WALL_WIDTH], center=true);
    // 'knee'
    translate([-BRACKET_WIDTH/2, BRACKET_HEIGHT/2+WALL_WIDTH/2, WALL_WIDTH/2])
      rotate([0, 90, 0])
        cylinder(h=BRACKET_WIDTH, r=WALL_WIDTH/2);
    
    translate([0, BRACKET_HEIGHT/2+WALL_WIDTH/2, WALL_WIDTH/2])
      rotate([-BRACKET_ANGLE, 0, 0])
        translate([0, 0, -BRACKET_DEPTH/2])
          cube([BRACKET_WIDTH, WALL_WIDTH, BRACKET_DEPTH], center=true);

    translate([-BRACKET_WIDTH/2, -BRACKET_HEIGHT/2-WALL_WIDTH/2, WALL_WIDTH/2])
      rotate([0, 90, 0])
        cylinder(h=BRACKET_WIDTH, r=WALL_WIDTH/2);
    translate([0, -BRACKET_HEIGHT/2-WALL_WIDTH/2, WALL_WIDTH/2])
      rotate([BRACKET_ANGLE, 0, 0])
        translate([0, 0, -BRACKET_DEPTH/2])
           cube([BRACKET_WIDTH, WALL_WIDTH, BRACKET_DEPTH], center=true);
}

// Mounting bracket, that has some space in the front to ease mounting.
module bracket() {
    difference() {
	base_bracket();
	// Punch out the access area.
	translate([0, -BRACKET_HEIGHT/2, 0]) cube([MOUNTING_SPACE + 2 * SNAP_FIT_GAP, BRACKET_HEIGHT, 2 * BRACKET_DEPTH], center=true);
	scale([1, 1/HOOD_ASPECT, 1]) cylinder(r=MOUNTING_SPACE/2 + SNAP_FIT_GAP, h=3 * WALL_WIDTH, center=true);
    }
}

// The solid shape of the hood.
module hood_volume(radius_adjust=0) {
    translate([0, 0, -WALL_WIDTH - 0.1]) scale([HOOD_ASPECT, 1, 1]) cylinder(h=HOOD_HEIGHT, r1=HOOD_PROXIMAL_RADIUS + radius_adjust, r2=HOOD_DISTAL_RADIUS+radius_adjust);
}

// This is more or less a funnel. The curved_hood() below makes this looks a bit nicer.
module straight_hood() {
    difference() {
	difference() {
	    // This difference make it hollow.
	    hood_volume(0);
	    hood_volume(-HOOD_WALL_WIDTH);
	    translate([0, 0, 0.1]) hood_volume(-HOOD_WALL_WIDTH); // clean top cut.
	}
	camera(); // We're a bit below. Cut that flush wherever the camera is.
    }
}

// Let's curve the top off a bit. We are mostly interested in blocking light from the top.
module curved_hood() {
    intersection() {
	straight_hood();
	// Make it more like a cape; cut the hood with a cylinder.
	translate([-BRACKET_WIDTH, BRACKET_HEIGHT/2, -(cut_radius-HOOD_HEIGHT+WALL_WIDTH)]) rotate([0, 90, 0]) cylinder(h=2 * BRACKET_WIDTH, r=cut_radius);
    }
}

// We mount the hood on a base-plate, that will snap into the bracket.
// The snap_adjust is the addional amount it the holes should be sized.
module hood_baseplate(snap_adjust=0) {
    difference() {
	union() {
	    // Plate we 'mount' the hood on. This is thinner (only snap-width) than the usual wall width, because
	    // we want to snap to halfs together.
	    translate([0, 0, SNAP_WIDTH/2]) cube([mounting_plate_width - 2 * snap_adjust, mounting_plate_height - 2 * snap_adjust, SNAP_WIDTH], center=true);
	    
	    // In the mounting space area, we have a thicker part of the plate, so that after mounting, things are flush.
	    translate([0, -BRACKET_HEIGHT/4, WALL_WIDTH/2]) cube([MOUNTING_SPACE, BRACKET_HEIGHT/2+WALL_WIDTH, WALL_WIDTH], center=true);
	    scale([1, 1/HOOD_ASPECT, 1]) cylinder(r=MOUNTING_SPACE/2, h=WALL_WIDTH);

	    // rounded front.
	    translate([-MOUNTING_SPACE/2, -(BRACKET_HEIGHT + WALL_WIDTH)/2, WALL_WIDTH/2]) rotate([0, 90, 0]) cylinder(r=WALL_WIDTH/2, h=MOUNTING_SPACE);
	}
	// mounting holes.
	translate([mounting_plate_width/2 - 2.5 - 2, mounting_plate_height/2 - 4.5, -1]) cylinder(r=2.5 + snap_adjust, h=WALL_WIDTH + 2);
	translate([-(mounting_plate_width/2 - 2.5 - 2), mounting_plate_height/2 - 4.5, -1]) cylinder(r=2.5 + snap_adjust, h=WALL_WIDTH + 2);

	// and squares.
	translate([(mounting_plate_width + MOUNTING_SPACE) / 4, -mounting_plate_height/4, 0]) cube([2 + 2*snap_adjust, 6 +2* snap_adjust, 10], center=true);
	translate([-(mounting_plate_width + MOUNTING_SPACE) / 4, -mounting_plate_height/4, 0]) cube([2 + 2*snap_adjust, 6 + 2*snap_adjust, 10], center=true);
    }
}

module mounted_hood() {
    difference() {
	hood_baseplate();
	hood_volume();  // Punch a hole.
    }
    curved_hood();
}

module clickable_bracket() {
    difference() {
	bracket();
	hood_baseplate(-SNAP_FIT_GAP);
	translate([0, 0, -0.1]) hood_baseplate(-SNAP_FIT_GAP); // properly punch
    }
}

// Now, let's print these components next to each other. We essentially take
// them from the mounted position and unfold them by turning the bracket 180 degrees
// on its back.
print_offset_y=BRACKET_HEIGHT/2 + WALL_WIDTH + 1;
module print_hood() {
    // The hood is already flush with the bottom.
    translate([0, print_offset_y, 0]) mounted_hood();
}

module print_bracket() {
    // The hood needs to be turned around to be printed flat on its back.
    rotate([180, 0, 0]) translate([0, print_offset_y, -WALL_WIDTH]) clickable_bracket();
}

module print() {
    print_hood();
    print_bracket();
}

// How it looks while attempting to mount to see that there is enough space.
module mounting_animation() {
    // Two 'scenes': approach and marry.
    if ($t < 0.5) {
	assign(scene_t = 2 * (0.5 - $t)) {  // 1..0
	    translate([0, scene_t * (BRACKET_HEIGHT + 5), scene_t * HOOD_HEIGHT/5 + (BRACKET_DEPTH + WALL_WIDTH/2)]) rotate([scene_t * 20, 0, 0]) clickable_bracket();
	}
    } else {
	assign(scene_t = 1 - 2 * ($t - 0.5)) {  // 1..0
	    translate([0, 0, scene_t * (BRACKET_DEPTH + WALL_WIDTH/2)]) clickable_bracket();
	}
    }
    color("lightgreen") mounted_hood();
}

module complete_mount() {
    color("red") clickable_bracket();
    mounted_hood();
    %camera();
}

//complete_mount();
//mounting_animation();
print();
