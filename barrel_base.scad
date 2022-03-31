include <util/radial_square_notches.scad>
include <util/locking_lug.scad>

module barrel_half_blank(inner_radius, depth, base_thickness, wall_thickness) {
  full_height = depth + base_thickness;
  full_radius = inner_radius + wall_thickness;
  difference() {
    cylinder(r=full_radius, h=full_height);
    translate([0, 0, base_thickness])
      cylinder(r=inner_radius, h=depth * 2);
  }
}

module spring_barrel_lower(inner_radius, depth, base_thickness, wall_thickness, locking_lug_spec, lug_count) {
  union() {
    barrel_half_blank(inner_radius, depth, base_thickness, wall_thickness);
    for (a = [0:360/lug_count:360]) {
      rotate([0, 0, a + 45])
        translate([0, 0, depth + base_thickness + 1.99 * locking_lug_spec[0]])
          rotate([180, 0, 0])
            cylinder_locking_lug_L(
              locking_lug_spec[0],
              locking_lug_spec[1],
              inner_radius + locking_lug_spec[0] / 2,
              false
            );
    }
  }
}

module spring_barrel_upper(inner_radius, depth, top_thickness, wall_thickness, locking_lug_spec, lug_count,
    bearing_od, bearing_id, bearing_notch_size, bearing_notch_count, bearing_height,
    spring_peg_radius) {
  vent_cylinder_radius = (inner_radius - bearing_od / 2) / 4;
  //make the bearing slot 100.75% size
  bearing_adjustment_factor = 0.0075;
  bearing_adjusted_od = bearing_od * (1 + bearing_adjustment_factor);
  difference() {
    barrel_half_blank(inner_radius, depth, top_thickness, wall_thickness);
    translate([0, 0, -bearing_height / 4])
      cylinder(r=bearing_adjusted_od/2, h=bearing_height, center=true);
    cylinder(r=bearing_id/2, h=top_thickness + depth / 2);
    for (a = [0:360/lug_count:360]) {
      rotate([0, 0, a + 45]) {
        translate([0, 0, depth + top_thickness - 2 * locking_lug_spec[0]])
          rotate([0, 0, 0])
            cylinder_locking_lug_L(
              locking_lug_spec[0],
              locking_lug_spec[1],
              inner_radius + locking_lug_spec[0] / 2,
              true
            );
      }
    }
    // end of spring peg hole
    translate([inner_radius - spring_peg_radius / 1.5, 0, -depth / 4])
      cylinder(
        r=spring_peg_radius * spring_peg_margin_factor, 
        h=(top_thickness + depth) * 2
      );
    translate([0, 0, top_thickness + depth / 4 ])
      radial_square_notches(
        side_length=wall_thickness * 2,
        length=depth / 2,
        notches=4,
        radius=inner_radius
      );
  }
  bearing_collar_factor = 1.3;
  translate([0, 0, -bearing_height / 2 + bearing_height / 4])
    difference() {
      cylinder(r=bearing_adjusted_od / 2 * bearing_collar_factor, h=bearing_height / 2);
      cylinder(r=bearing_adjusted_od / 2, h= 2 * bearing_height, center=true);
    }
  // make the notches 93% size
  radial_square_notches(
    side_length=bearing_notch_size * 0.93,
    length=bearing_height / 2,
    notches=bearing_notch_count,
    radius=bearing_adjusted_od/2
  );
}

module test_spring_barrel() {
  inner_radius=96/2;
  depth=8.25;
  base_thickness = 4;
  top_thickness = 6;
  wall_thickness=4.5;
  lug_spec = [wall_thickness / 1.5, 10];
  mount_point_sizes = [3, 5, 8];
  mount_point_tolerance = 1.02;
  mount_point_angles = [0, 10, 25];
  mount_point_radial_pos = 1.275;
  difference() {
    spring_barrel_lower(
      inner_radius, 
      depth,
      base_thickness,
      wall_thickness,
      lug_spec, 4
    );
    // volume venting
    translate([0, 0, base_thickness + depth / 4 ])
      radial_square_notches(
        side_length=wall_thickness * 2,
        length=depth / 2,
        notches=4,
        radius=inner_radius
      );
  }
  echo([(inner_radius + wall_thickness) * 2 + 5, 0]);
  translate([(inner_radius + wall_thickness) * 2 + 5, 0, 0]) {
    difference() {
      spring_barrel_upper(
        inner_radius,
        depth,
        top_thickness,
        wall_thickness,
        locking_lug_spec=lug_spec, 
        lug_count=4,
        bearing_od=50,
        bearing_id=50 - 15,
        bearing_notch_size=1.5,
        bearing_notch_count=16, 
        bearing_height=12,
        spring_peg_radius=3
      );
      echo([(inner_radius + wall_thickness) / mount_point_radial_pos, 0, 0]);
      // mounting points
      for (outer_angle = [0:360/4:360]) {
        for (idx = [0:1:len(mount_point_sizes) - 1]) {
          sz = mount_point_sizes[idx] * mount_point_tolerance;
          angle = mount_point_angles[idx];
          rotate([0, 0, angle + outer_angle + 15])
            translate([(inner_radius + wall_thickness) / mount_point_radial_pos, 0, 0])
              cylinder(r=sz / 2, h = top_thickness * 3, center=true);
        }
      }
    }
  }
}

$fs = 0.05;
$fa = 0.02;

spring_peg_margin_factor = 1.05;

test_spring_barrel();

module point_cyl(pt, r=1, ht=100) {
  translate(pt)
    cylinder(r=r, h=ht);
}

translate([110, 0, 0])
  rotate([0, 0, 15 + 10])
    point_cyl([41.1765, 0]);
