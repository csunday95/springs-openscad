
include <util/radial_square_notches.scad>
include <../shafts/parts/keyed_shaft.scad>
include <archimedian_spiral.scad>

$fs = 0.025;
$fa = 0.02;

step = 0.15;
circles = 10;
arm_len = 5.15;
thickness = 1.3;

notch_size = 1.5;
shaft_radius = 6;
inner_radius = shaft_radius * 1.5 + notch_size;
spring_height = 15;
shaft_height = 50;
peg_height = 18;
peg_diameter = 6;
total_radius = arm_len * circles;
center_shaft_scale_factor = 0.975;
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
          cylinder(r=peg_diameter/2, h=spring_height + peg_height);
        translate([0, 0, (spring_height + shaft_height) / 2])
            keyed_shaft(
                shaft_radius=shaft_radius * center_shaft_scale_factor,
                shaft_length=spring_height + shaft_height,
                key_width=notch_size * center_shaft_scale_factor,
                key_length=spring_height + shaft_height,
                key_count=4
            );
    }
    // translate([0, 0, 5])
    //   cylinder(r=inner_radius, h=20, center=true);
    // translate([0, 0, 5])
    //   radial_square_notches(side_length=notch_size, notches=4, length=12, radius=inner_radius);
}
