
include <util/radial_square_notches.scad>
include <../shafts/parts/keyed_shaft.scad>
include <archimedian_spiral.scad>

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
            line(points[index - 1], points[index], width, true);
            polyline_inner(points, index + 1);
        }
    }
    module polyline_inner_iter() {
      
    }

    polyline_inner(points, 1);
}

$fs = 0.01;
$fa = 0.01;

step = 0.1;
circles = 8;
arm_len = 6.25;
thickness = 1.75;

b = arm_len / 2 / PI;
// one radian is almost 57.2958 degrees
points = [for(theta = [0:step:2 * PI * circles])
    [b * theta * cos(theta * 57.2958), b * theta * sin(theta * 57.2958)]
];

notch_size = 1.5;
shaft_radius = 6;
inner_radius = shaft_radius + notch_size;
spring_height = 15;
shaft_height = 20;
total_radius = arm_len * circles;
notch_scale_factor = 0.93;
echo(total_radius * 2);

difference() {
    union() {
        linear_extrude(spring_height)
            polyline(points, thickness);
        cylinder(r=inner_radius, h=spring_height);
        translate([total_radius, 0, 0])
          cylinder(r=3, h=spring_height + shaft_height);
        translate([0, 0, (spring_height + shaft_height) / 2])
            keyed_shaft(
                shaft_radius=shaft_radius,
                shaft_length=spring_height + shaft_height,
                key_width=notch_size * notch_scale_factor,
                key_length=spring_height + shaft_height,
                key_count=4
            );
    }
    // translate([0, 0, 5])
    //   cylinder(r=inner_radius, h=20, center=true);
    // translate([0, 0, 5])
    //   radial_square_notches(side_length=notch_size, notches=4, length=12, radius=inner_radius);
}
