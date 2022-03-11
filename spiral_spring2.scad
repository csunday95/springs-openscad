
include <util/radial_square_notches.scad>
include <../shafts/parts/keyed_shaft.scad>
include <archimedian_spiral.scad>

$fs = 0.01;
$fa = 0.01;

step = 0.1;
circles = 8;
arm_len = 6;
thickness = 1.75;

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
        archimedian_spiral(
          total_radius=total_radius, 
          circle_count=circles,
          height=spring_height,
          thickness=thickness,
          step=step
        );
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
