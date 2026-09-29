// electronics_clip.scad
// Right temple arm cradle for a Seeed XIAO ESP32C3 plus a mini slide switch.
// Print flat, the open side of the arm clip on the bed. No supports.
// Frame: Y runs along the temple arm, Z up (bed at Z = 0), -X is toward the head.
// Tags: [know] from specs, [inferred] estimate, [don't know] measure it.

xiao_l   = 21;    // along the arm, USB-C on a short edge. [know]
xiao_w   = 17.8;  // [know]
xiao_h   = 3.5;   // PCB plus shield. [know] about
fit      = 0.4;
sw_l     = 8.6;   // mini slide switch body (SS12D00 style). [don't know] measure yours
sw_w     = 3.8;
sw_h     = 3.6;
arm_w    = 10;    // arm height. [don't know] measure it
arm_t    = 3.5;   // arm thickness. [don't know] measure it
clip_fit = 0.4;
lip      = 0.7;
wall     = 1.6;
floor_t  = 1.2;
usb_at_front = false; // false: USB-C faces the back of the head (easy to plug in)

$fn = 48;

pl = xiao_l + fit; pw = xiao_w + fit;
cw = arm_t + clip_fit; ch = arm_w + clip_fit;
sw_block = sw_l + fit + 2*wall;
total_l  = pl + 2*wall + sw_block;
clip_x0  = -(cw + 2*wall);           // clip sits on the -X side (head side)
wall_h   = floor_t + xiao_h + 1.2;

module arm_clip() {
  // opening faces down (on the bed). Roof is a short bridge.
  difference() {
    translate([clip_x0, 0, 0]) cube([cw + 2*wall, total_l, ch + wall]);
    translate([clip_x0 + wall, -1, -0.01]) cube([cw, total_l + 2, ch]);
  }
  // snap lips at the bottom
  for (s = [0, 1]) translate([clip_x0 + wall + s*(cw - lip), 0, 0]) cube([lip, total_l, 0.8]);
}

module cradle() {
  difference() {
    cube([pw + 2*wall, total_l, wall_h]);
    // XIAO pocket
    translate([wall, wall, floor_t]) cube([pw, pl, wall_h]);
    // USB-C end open
    translate([wall + pw/2 - 5, usb_at_front ? pl + wall - 1 : -1, floor_t + 0.4]) cube([10, wall + 2, wall_h]);
    // floor window: reach the BAT+ / BAT- pads under the board
    translate([wall + 3, wall + 4, -1]) cube([pw - 6, pl - 8, floor_t + 2]);
    // wire / antenna cable notch between board and switch
    translate([wall + 2, wall + pl - 1, floor_t + 1]) cube([6, wall + 2, wall_h]);
    // switch pocket (lever up), pins go down through the floor
    translate([wall + pw/2 - (sw_w + fit)/2, pl + 2*wall + wall, floor_t])
      cube([sw_w + fit, sw_l + fit, wall_h]);
    translate([wall + pw/2 - 1, pl + 2*wall + wall + 1, -1]) cube([2, sw_l + fit - 2, floor_t + 2]);
  }
  // small snap lips on the long walls to keep the board in
  for (x = [wall - 0.5, wall + pw]) translate([x, wall + 3, wall_h - 0.6]) cube([0.5, pl - 6, 0.6]);
}

union() { cradle(); arm_clip(); }
