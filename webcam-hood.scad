// Little hood for the Logitec C920 webcam.
// (c) h.zeller@acm.org Creative Commons license BY-SA

$fn=128;

WALL_WIDTH = 2.3;
LEDGE_HEIGHT = 2.3;
LENS_HOOD_WIDTH = 0.6;

BRACKET_DEPTH = 5 + WALL_WIDTH/2;
BRACKET_WIDTH = 48;
BRACKET_LENGHT = 48;
BRACKET_HEIGHT = 29.5;
NEW_BRACKET_WIDTH = 29.5;
BRACKET_ANGLE = 4.7;

HOOD_HEIGHT = 25;
HOOD_ASPECT = 1920/1080;
HOOD_PROXIMAL_RADIUS = 4.5;
HOOD_DISTAL_RADIUS = BRACKET_HEIGHT * 0.65;

SNAP_FIT_GAP = 0.25;
SNAP_HEIGHT = LEDGE_HEIGHT / 2;

IMAGE_WIDTH = 109;
IMAGE_DISTANCE = 80;
IMAGE_WIDTH_INCLINATION = IMAGE_WIDTH / IMAGE_DISTANCE;

MOUNTING_MARGIN = IMAGE_WIDTH_INCLINATION * BRACKET_DEPTH;
MOUNTING_SPACE = 2 * (HOOD_PROXIMAL_RADIUS * HOOD_ASPECT + WALL_WIDTH * IMAGE_WIDTH_INCLINATION) + 2 * MOUNTING_MARGIN;
LEDGE_LENGHT = 2 * (HOOD_PROXIMAL_RADIUS * HOOD_ASPECT + WALL_WIDTH * IMAGE_WIDTH_INCLINATION) + 2 * MOUNTING_MARGIN;
HOOD_PLATE_LENGHT = BRACKET_LENGHT - 2;
HOOD_PLATE_WIDTH = NEW_BRACKET_WIDTH - 2;

HOLE_RADIUS = 2.5;

CUT_HOOD_RADIUS = 2 * HOOD_DISTAL_RADIUS;

OFFSET_Y = BRACKET_HEIGHT/2 + WALL_WIDTH + 1;

HOOD_OFFSET = [0, OFFSET_Y, 0];

TRUE = true;

LYING = [0, 90, 0];
RIGHT = [90, 0, 0];
TURN = [180, 0, 0];

ARRAY_BASE_CORRECTION = -1;

SQUARE_LENGHT = 2;
SQUARE_WIDTH = 6;

CAMERA_DIMENSIONS = [60, NEW_BRACKET_WIDTH, 25];
CAMERA_EDGE_RADIUS = 5;

module print() {
    hood();
    clip();
}

module hood() {
    translate(HOOD_OFFSET)
		mounted_hood();
}

module mounted_hood() {
	hood_base();
	lens_hood();
}

module hood_base() {
	difference() {
		base();
		hood_block();
	}
}

module base(snap_adjust = 0) {
	difference() {
		union() {
			plate(snap_adjust);
			ledge();
		}
		
		holes(snap_adjust);

		squares(snap_adjust);
	}
}

module plate(snap_adjust = 0) {
	offset_z = half(SNAP_HEIGHT);
	offset = [0, 0, offset_z];

	lenght = adjust_down(HOOD_PLATE_LENGHT, snap_adjust);
	width = adjust_down(HOOD_PLATE_WIDTH, snap_adjust);
	dimensions = [lenght, width, SNAP_HEIGHT];

	translate(offset)
		cube(dimensions, center = TRUE);
}

function adjust_down(dimension, adjustment_factor) = dimension - double(adjustment_factor);
function adjust_up(dimension, adjustment_factor) = dimension + double(adjustment_factor);

module ledge() {
	ledge_base();
	ledge_rounded();
	ledge_front();
}

module ledge_base() {
	offset_y = -NEW_BRACKET_WIDTH / 4;
	offset = [0, offset_y, SNAP_HEIGHT];

	width = half(NEW_BRACKET_WIDTH) + LEDGE_HEIGHT;
	dimensions = [LEDGE_LENGHT, width, LEDGE_HEIGHT];

	translate(offset)
		cube(dimensions, center = TRUE);
}

module ledge_rounded() {
	axis_y = 1 / HOOD_ASPECT;
	factors = [1, axis_y, 1];

	scale(factors)
		cylinder(r = radius(LEDGE_LENGHT), h = LEDGE_HEIGHT);
}

function half(dimension) = dimension / 2;
function radius(diameter) = half(diameter);

module ledge_front() {
	offset_x = half(-LEDGE_LENGHT);
	offset_y = half(-(NEW_BRACKET_WIDTH + LEDGE_HEIGHT));
	offset = [offset_x, offset_y, radius(LEDGE_HEIGHT)];

	translate(offset)
		rotate(LYING)
			cylinder(r = radius(LEDGE_HEIGHT), h = LEDGE_LENGHT);
}

module holes(snap_adjust = 0) {
	positions = [[half(HOOD_PLATE_LENGHT) - 2.5 - 2, half(HOOD_PLATE_WIDTH) - 4.5, -SNAP_HEIGHT], [-(half(HOOD_PLATE_LENGHT) - 2.5 - 2), half(HOOD_PLATE_WIDTH) - 4.5, -SNAP_HEIGHT]];
	number_of_holes = len(positions);
	
	for(i = [0 : number_of_holes + ARRAY_BASE_CORRECTION]) {
		translate(positions[i])
			hole(snap_adjust);
	}
}

module hole(snap_adjust = 0) {
	radius = HOLE_RADIUS + snap_adjust;

	cylinder(r = radius, h = LEDGE_HEIGHT + 2);
}

module squares(snap_adjust = 0) {
	positions = [[(HOOD_PLATE_LENGHT + LEDGE_LENGHT) / 4, -HOOD_PLATE_WIDTH / 4, 0], [-(HOOD_PLATE_LENGHT + LEDGE_LENGHT) / 4, -HOOD_PLATE_WIDTH / 4, 0]];
	number_of_squares = len(positions);
	
	for(i = [0 : number_of_squares + ARRAY_BASE_CORRECTION]) {
		translate(positions[i])
			square(snap_adjust);
	}
}

module square(snap_adjust = 0) {
	lenght = adjust_up(SQUARE_LENGHT, snap_adjust);
	width = adjust_up(SQUARE_WIDTH, snap_adjust);
	dimensions = [lenght, width, LEDGE_HEIGHT + 2];

	cube(dimensions, center = TRUE);
}

module hood_block(radius_adjust = 0) {
	offset = [0, 0, -LEDGE_HEIGHT - 0.1];
	factors = [HOOD_ASPECT, 1, 1];
	radius_bottom = HOOD_PROXIMAL_RADIUS + radius_adjust;
	radius_top = 	HOOD_DISTAL_RADIUS + radius_adjust;

	translate(offset)
		scale(factors)
			cylinder(h = HOOD_HEIGHT, r1 = radius_bottom, r2 = radius_top);
}

module lens_hood() {
	intersection() {
		straight_hood();
		cut_hood();
	}
}

module straight_hood() {
	difference() {
		funnel_hood();
		camera();
	}
}

module funnel_hood() {
	difference() {
		hood_block(0);
		hood_block(-LENS_HOOD_WIDTH);
		hollow_top();
	}
}


module hollow_top() {
	offset = [0, 0, 0.1];
	
	translate(offset)
		hood_block(-LENS_HOOD_WIDTH);
}

module camera() {
	hull() {
		central_block();
		right_block();
		left_block();
	}
}

module central_block() {
	offset = [0, 0, -12.5];

	translate(offset)
		cube(CAMERA_DIMENSIONS, center = TRUE);
}

module right_block() {
	offset = [38, half(NEW_BRACKET_WIDTH), -16];
	
	translate(offset)
		rotate(RIGHT)
			cylinder(h = NEW_BRACKET_WIDTH, r = CAMERA_EDGE_RADIUS);
}

module left_block() {
	offset = [-38, half(NEW_BRACKET_WIDTH), -16];

	translate(offset)
		rotate(RIGHT)
			cylinder(h = NEW_BRACKET_WIDTH, r = CAMERA_EDGE_RADIUS);
}

module cut_hood() {
	offset = [-BRACKET_LENGHT, half(NEW_BRACKET_WIDTH), -(CUT_HOOD_RADIUS - HOOD_HEIGHT + LEDGE_HEIGHT)];

	translate(offset)
		rotate(LYING)
			cylinder(h = double(BRACKET_LENGHT), r = CUT_HOOD_RADIUS);
}

function double(dimension) = dimension * 2;

module clip() {
	rotate(TURN)
		translate([0, OFFSET_Y, -WALL_WIDTH])
			clickable_bracket();
}

module clickable_bracket() {
	difference() {
		bracket();
		base(-SNAP_FIT_GAP);
		translate([0, 0, -0.1])
			base(-SNAP_FIT_GAP); // properly punch
	}
}

// Mounting bracket, that has some space in the front to ease mounting.
module bracket() {
	difference() {
		base_bracket();
		// Punch out the access area.
		translate([0, -BRACKET_HEIGHT/2, 0])
			cube([MOUNTING_SPACE + 2 * SNAP_FIT_GAP, BRACKET_HEIGHT, 2 * BRACKET_DEPTH], center=true);
		scale([1, 1/HOOD_ASPECT, 1])
			cylinder(r=MOUNTING_SPACE/2 + SNAP_FIT_GAP, h=3 * WALL_WIDTH, center=true);
	}
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

//complete_mount();
//mounting_animation();
print();

module complete_mount() {
	color("red")
		clickable_bracket();
	mounted_hood();
	%camera();
}

// How it looks while attempting to mount to see that there is enough space.
module mounting_animation() {
	// Two 'scenes': approach and marry.
	if ($t < 0.5) {
		assign(scene_t = 2 * (0.5 - $t)) {  // 1..0
			translate([0, scene_t * (BRACKET_HEIGHT + 5), scene_t * HOOD_HEIGHT/5 + (BRACKET_DEPTH + WALL_WIDTH/2)])
				rotate([scene_t * 20, 0, 0]) clickable_bracket();
		}
	} else {
		assign(scene_t = 1 - 2 * ($t - 0.5)) {  // 1..0
			translate([0, 0, scene_t * (BRACKET_DEPTH + WALL_WIDTH/2)])
				clickable_bracket();
		}
	}
	color("lightgreen")
		mounted_hood();
}
