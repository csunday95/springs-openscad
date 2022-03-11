
function spiral_pt(v, w, c, t) = [
  abs(v * t + c) * cos(w * t),
  (v * t + c) * sin(w * t)
];

function spiral_points(v, w, c, dt, max_t) = [
  for (t = [0:dt:max_t]) spiral_pt(v, w, c, t)
];

function spiral_points_reverse(v, w, c, dt, max_t) = [
  for (t = [max_t:-dt:0]) spiral_pt(v, w, c, t)
];

function cat(L1, L2) = [for (i=[0:len(L1)+len(L2)-1]) 
                        i < len(L1)? L1[i] : L2[i-len(L1)]] ;

module archimedian_spiral_profile(v, w, dt, max_t, width) {
  inner_spiral = spiral_points(v, w, -width / 2, dt, max_t);
  outer_spiral = spiral_points_reverse(v, w, width / 2, dt, max_t);
  spiral_points = cat(inner_spiral, outer_spiral);
  polygon(spiral_points);
}

module test_archimedian_spiral_profile() {
  archimedian_spiral_profile(1/CIRCLE_DEG, 1, 1, 4 * CIRCLE_DEG, 0.2);
}

module archimedian_spiral(total_radius, circle_count, height, thickness, step=1) {
  velocity = total_radius / circle_count;
  angular_vel = 1;
  linear_extrude(height)
    archimedian_spiral_profile(
      v=velocity / CIRCLE_DEG, 
      w=angular_vel, 
      dt=step, 
      max_t=circle_count * CIRCLE_DEG,
      width=thickness
    );
}

// archimedian_spiral(30, 3, 10, 2, 0.1);

CIRCLE_DEG = 360;
