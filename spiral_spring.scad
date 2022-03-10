
include <util/radial_square_notches.scad>
include <../shafts/parts/keyed_shaft.scad>

module line(point1, point2, width = 1, cap_round = true) {
    angle = 90 - atan((point2[1] - point1[1]) / (point2[0] - point1[0]));
    offset_x = 0.5 * width * cos(angle);
    offset_y = 0.5 * width * sin(angle);

    offset1 = [-offset_x, offset_y];
    offset2 = [offset_x, -offset_y];

    if(cap_round) {
        translate(point1) circle(d = width, $fn = 24);
        translate(point2) circle(d = width, $fn = 24);
    }

    polygon(points=[
        point1 + offset1, point2 + offset1,  
        point2 + offset2, point1 + offset2
    ]);
}

module polyline(points, width = 1) {
    module polyline_inner(points, index) {
        if(index < len(points)) {
            line(points[index - 1], points[index], width);
            polyline_inner(points, index + 1);
        }
    }

    polyline_inner(points, 1);
}

$fs = 0.05;
$fa = 0.01;

step = 0.05;
circles = 8;
arm_len = 7;

b = arm_len / 2 / PI;
// one radian is almost 57.2958 degrees
points = [for(theta = [0:step:2 * PI * circles])
    [b * theta * cos(theta * 57.2958), b * theta * sin(theta * 57.2958)]
];

inner_radius = 5;
notch_size = 2;
shaft_height = 5;
shaft_radius = 4;
spring_height = 10;

difference() {
    union() {
        linear_extrude(spring_height)
            polyline(points, 2.5);
        cylinder(r=10, h=spring_height);
        translate([56, 0, 0])
          cylinder(r=2, h=spring_height + 5);
        translate([0, 0, (spring_height + shaft_height) / 2])
            keyed_shaft(
                shaft_radius=shaft_radius,
                shaft_length=spring_height + shaft_height,
                key_height=1,
                key_width=1.5,
                key_length=spring_height + shaft_height,
                key_count=4
            );
    }
    // translate([0, 0, 5])
    //   cylinder(r=inner_radius, h=20, center=true);
    // translate([0, 0, 5])
    //   radial_square_notches(side_length=notch_size, notches=4, length=12, radius=inner_radius);
}
