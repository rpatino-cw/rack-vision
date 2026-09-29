// battery_clip.scad
// Left temple arm cradle for an 802030 LiPo, 400 mAh (counterweight).
// Battery stands on its long edge next to the arm. Pocket open on top.
// Print as is: arm clip opening on the bed. No supports.
// Frame: Y along the arm, Z up, +X is toward the head on the LEFT arm.
// Tags: [know] from specs, [inferred] estimate, [don't know] measure it.

bat_t   = 8;     // 802030 cell. [know] about
bat_w   = 20;    // stands up (Z). [know] about
bat_l   = 30;    // along the arm (Y). [know] about
swell   = 1;     // extra room for LiPo swelling. [know]
fit     = 0.4;
wall    = 1.6;
floor_t = 1.2;
arm_w   = 10;    // [don't know] measure it
arm_t   = 3.5;   // [don't know] measure it
clip_fit = 0.4;
lip     = 0.7;
cable_w = 4.0;   // JST-PH 2.0 lead channel. [inferred]

$fn = 48;

px = bat_t + swell + fit;   // 9.4
py = bat_l + fit;
pz = bat_w + fit;
cw = arm_t + clip_fit; ch = arm_w + clip_fit;
L  = py + 2*wall;
H  = pz + floor_t;
cx0 = px + 2*wall;          // clip on the +X side (toward the head)

module arm_clip() {
  difference() {
    translate([cx0, 0, 0]) cube([cw + 2*wall, L, ch + wall]);
    translate([cx0 + wall, -1, -0.01]) cube([cw, L + 2, ch]);
  }
  for (s = [0, 1]) translate([cx0 + wall + s*(cw - lip), 0, 0]) cube([lip, L, 0.8]);
}

module cradle() {
  difference() {
    cube([px + 2*wall, L, H]);
    translate([wall, wall, floor_t]) cube([px, py, H]);
    // cable channel: slot down the back end wall and out the bottom
    translate([wall + px/2 - cable_w/2, L - wall - 1, floor_t + 2]) cube([cable_w, wall + 2, H]);
    // window in the outer wall: see swelling, saves weight
    translate([-1, wall + 6, floor_t + 5]) cube([wall + 2, py - 12, pz - 8]);
    // strap notches at the top for a rubber band or tape
    for (y = [8, L - 12]) translate([-1, y, H - 3]) cube([px + 2*wall + 2, 4, 1.2]);
  }
}

union() { cradle(); arm_clip(); }
