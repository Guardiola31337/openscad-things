// Little hood for the Logitec C920 webcam.
// (c) h.zeller@acm.org Creative Commons license BY-SA

$fn = 128;

LEDGE_HEIGHT = 2.3;
LENS_HOOD_WIDTH = 0.6;

BRACKET_LENGHT = 48;
BRACKET_WIDTH = 29.5;
BRACKET_HEIGHT = 5 + LEDGE_HEIGHT / 2;
BRACKET_ANGLE = 4.7;

HOOD_HEIGHT = 25;
HOOD_ASPECT = 1920 / 1080;
HOOD_PROXIMAL_RADIUS = 4.5;
HOOD_DISTAL_RADIUS = BRACKET_WIDTH * 0.65;

SNAP_FIT_GAP = 0.25;
SNAP_HEIGHT = LEDGE_HEIGHT / 2;

IMAGE_WIDTH = 109;
IMAGE_DISTANCE = 80;
IMAGE_WIDTH_INCLINATION = IMAGE_WIDTH / IMAGE_DISTANCE;

MOUNTING_MARGIN = IMAGE_WIDTH_INCLINATION * BRACKET_HEIGHT;
LEDGE_LENGHT = 2 * (HOOD_PROXIMAL_RADIUS * HOOD_ASPECT + LEDGE_HEIGHT * IMAGE_WIDTH_INCLINATION) + 2 * MOUNTING_MARGIN;
HOOD_PLATE_LENGHT = BRACKET_LENGHT - 2;
HOOD_PLATE_WIDTH = BRACKET_WIDTH - 2;

HOLE_RADIUS = 2.5;

CUT_HOOD_RADIUS = 2 * HOOD_DISTAL_RADIUS;

OFFSET_Y = BRACKET_WIDTH / 2 + LEDGE_HEIGHT + 1;

HOOD_OFFSET = [0, OFFSET_Y, 0];

TRUE = true;

LYING = [0, 90, 0];
RIGHT = [90, 0, 0];
TURN = [180, 0, 0];

ARRAY_BASE_CORRECTION = -1;

SQUARE_LENGHT = 2;
SQUARE_WIDTH = 6;

CAMERA_DIMENSIONS = [60, BRACKET_WIDTH, 25];
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
	offset_y = -BRACKET_WIDTH / 4;
	offset = [0, offset_y, SNAP_HEIGHT];

	width = half(BRACKET_WIDTH) + LEDGE_HEIGHT;
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
	offset_y = half(-(BRACKET_WIDTH + LEDGE_HEIGHT));
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
	radius_top = HOOD_DISTAL_RADIUS + radius_adjust;

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
		hollow();
	}
}

module hollow() {
	offset = [0, 0, 0.1];
	
	hood_block(-LENS_HOOD_WIDTH);
	translate(offset)
		hood_block(-LENS_HOOD_WIDTH);
}

module camera() {
	right_side = 38;
	left_side = -38;

	hull() {
		central_block();
		lateral_block(right_side);
		lateral_block(left_side);
	}
}

module central_block() {
	offset = [0, 0, -12.5];

	translate(offset)
		cube(CAMERA_DIMENSIONS, center = TRUE);
}

module lateral_block(side) {
	offset = [side, half(BRACKET_WIDTH), -16];

	translate(offset)
		rotate(RIGHT)
			cylinder(h = BRACKET_WIDTH, r = CAMERA_EDGE_RADIUS);
}

module cut_hood() {
	offset = [-BRACKET_LENGHT, half(BRACKET_WIDTH), -(CUT_HOOD_RADIUS - HOOD_HEIGHT + LEDGE_HEIGHT)];

	translate(offset)
		rotate(LYING)
			cylinder(h = double(BRACKET_LENGHT), r = CUT_HOOD_RADIUS);
}

function double(dimension) = dimension * 2;

module clip() {
	offset = [0, OFFSET_Y, -LEDGE_HEIGHT];	

	rotate(TURN)
		translate(offset)
			clip_bracket();
}

module clip_bracket() {
	difference() {
		bracket();
		punch();
	}
}

module bracket() {
	difference() {
		bracket_base();
		bracket_ledge_space();
	}
}

module bracket_base() {
    body();
    hooks();
}

module body() {
	offset = [0, 0, half(LEDGE_HEIGHT)];

	dimensions = [BRACKET_LENGHT, BRACKET_WIDTH + LEDGE_HEIGHT, LEDGE_HEIGHT];

    translate(offset)
		cube(dimensions, center = TRUE);
}

module hooks() {
	positions = [half(BRACKET_WIDTH) + half(LEDGE_HEIGHT), -half(BRACKET_WIDTH) - half(LEDGE_HEIGHT)];
	angles = [-BRACKET_ANGLE, BRACKET_ANGLE];

	for(i = [0 : 1]) {
		edge_block(positions[i]);
		hook_block(positions[i], angles[i]);
	}
}

module edge_block(position) {
	offset = [-half(BRACKET_LENGHT), position, half(LEDGE_HEIGHT)];

	translate(offset)
      rotate(LYING)
        cylinder(h = BRACKET_LENGHT, r = radius(LEDGE_HEIGHT));
}

module hook_block(position, angle) {
	horizontal_offset = [0, position, half(LEDGE_HEIGHT)];
	vertical_offset = [0, 0, -half(BRACKET_HEIGHT)];

	coordinates = [angle, 0, 0];

	dimensions = [BRACKET_LENGHT, LEDGE_HEIGHT, BRACKET_HEIGHT];

	translate(horizontal_offset)
      rotate(coordinates)
        translate(vertical_offset)
          cube(dimensions, center = TRUE);
}

module bracket_ledge_space() {
	punch_ledge_base();
	punch_ledge_rounded();
}

module punch_ledge_base() {
	offset = [0, -half(BRACKET_WIDTH), 0];

	lenght = LEDGE_LENGHT + 2 * SNAP_FIT_GAP;
	height = 2 * BRACKET_HEIGHT;
	dimensions = [lenght, BRACKET_WIDTH, height];

	translate(offset)
		cube(dimensions, center = TRUE);
}

module punch_ledge_rounded() {
	axis_y = 1 / HOOD_ASPECT;
	factors = [1, axis_y, 1];

	radius = half(LEDGE_LENGHT) + SNAP_FIT_GAP;
	height = 3 * LEDGE_HEIGHT;

	scale(factors)
		cylinder(r = radius, h = height, center = TRUE);
}

module punch() {
	offset = [0, 0, -0.1];

	base(-SNAP_FIT_GAP);
	translate(offset)
		base(-SNAP_FIT_GAP);
}

print();

