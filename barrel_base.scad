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
  difference() {
    barrel_half_blank(inner_radius, depth, base_thickness, wall_thickness);
    for (a = [0:360/lug_count:360]) {
      rotate([0, 0, a + 45])
        translate([0, 0, depth + base_thickness - 2 * locking_lug_spec[0]])
          rotate([0, 0, 0])
            cylinder_locking_lug_L(
              locking_lug_spec[0],
              locking_lug_spec[1],
              inner_radius + locking_lug_spec[0] / 2,
              true
            );
    }
  }
}

module spring_barrel_upper(inner_radius, depth, top_thickness, wall_thickness, locking_lug_spec, lug_count,
    bearing_od, bearing_id, bearing_notch_size, bearing_notch_count, bearing_height) {
  difference() {
    barrel_half_blank(inner_radius, depth, top_thickness, wall_thickness);
    cylinder(r=bearing_od/2, h=bearing_height, center=true);
    cylinder(r=bearing_id/2, h=top_thickness + depth / 2);
  }
  translate([0, 0, bearing_height/4])
    radial_square_notches(
      side_length=bearing_notch_size,
      length=bearing_height/2,
      notches=bearing_notch_count,
      radius=bearing_od/2
    );
  for (a = [0:360/lug_count:360]) {
    rotate([0, 0, a])
      translate([0, 0, depth + top_thickness + 1.99 * locking_lug_spec[0]])
        rotate([180, 0, 0])
          cylinder_locking_lug_L(
            locking_lug_spec[0],
            locking_lug_spec[1],
            inner_radius + locking_lug_spec[0] / 2,
          );
  }
}

module test_spring_barrel() {
  inner_radius=96/2;
  depth=18;
  base_thickness=12;
  wall_thickness=5;
  lug_spec = [wall_thickness / 1.5, 10];
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
  translate([(inner_radius + wall_thickness) * 2 + 5, 0, 0])
    spring_barrel_upper(
      inner_radius,
      depth,
      base_thickness,
      wall_thickness,
      locking_lug_spec=lug_spec, 
      lug_count=4,
      bearing_od=48.9, 
      bearing_id=48.9 - 14, 
      bearing_notch_size=1.5,
      bearing_notch_count=16, 
      bearing_height=12
    );
}

$fs = 0.5;
$fa = 0.2;
test_spring_barrel();