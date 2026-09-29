// hud_pod.scad
// Right side monocular HUD pod for clip-on AR safety glasses.
// Three print pieces: BASE, LID, CARRIAGE. Each is laid flat for printing.
// Units: mm. PETG. No supports needed (only short bridges, under 5 mm).
//
// MODEL FRAME (also the print frame for the base):
//   X = sideways. +X points to the wearer's right (toward the temple).
//   Y = forward / back. -Y points toward the eye. Plate center at Y = 0.
//   Z = up. Z = 0 is the print bed (bottom of the base floor).
// WORLD FRAME (eye at origin, looking +z):
//   world x = X, world y = Z - axis_z, world z = Y + plate_eye_dist
//
// Light path: OLED (faces -X, toward the nose) -> lens -> 45 degree plate -> eye (-Y).
//
// Tags: [know] = from the given specs, [inferred] = my estimate, [don't know] = measure it.

/* [Which part to show] */
part = "plate"; // "plate" (all 3 laid out), "base", "lid", "carriage", "assembly"

/* [Optics] */
plate_eye_dist = 38;   // plate center to eye, mm (world frame only). 38 puts the pod eye face 17 mm out, in front of the safety lens. Must stay 20 or more. [inferred]
plate_size     = 25.4; // beam splitter plate, 1 in square (B0HHNPJ16X). [know]
plate_t        = 2.0;  // plate thickness (range 1.1 to 2). [know]
lens_d         = 34;   // biconvex, 45 mm focal length (B074WPTTX8). [know]
lens_edge_t    = 2.0;  // lens thickness at the rim. [don't know] measure it
lens_slot_w    = 4.4;  // seat slot width. Wider than the rim because a biconvex lens gets thicker inward. [inferred]
lens_x         = 18;   // lens center, X distance from plate center. [inferred]
screen_min     = 36;   // closest screen-to-lens distance. [know]
screen_max     = 48;   // farthest screen-to-lens distance. [know]
screen_nominal = 40;   // start here. [know]

/* [OLED module] */
pcb_w     = 27.3;  // across (Y). [know]
pcb_h     = 27.8;  // tall (Z), header pins on top edge. [know]
pcb_t     = 1.2;   // [know]
glass_w   = 26;    // [know]
glass_bot = 5;     // glass bottom edge above PCB bottom edge. [don't know] measure it
fit       = 0.4;   // pocket oversize. [know]

/* [Temple arm clip] */
arm_w     = 10;    // arm height (world y). Safety Works 10021259: [don't know] measure it
arm_t     = 3.5;   // arm thickness (world x). [don't know] measure it
temple_x  = 42;    // arm center, sideways from the eye. [don't know] measure it
arm_y     = 6;     // arm center height above eye level. [don't know] measure it
clip_len  = 18;    // clip length along the arm
clip_gap  = 6;     // gap between the pod and the clip
clip_fit  = 0.4;   // clearance around the arm
lip       = 0.8;   // snap lip size

/* [Box] */
wall   = 2;
floor_t = 3;
inner  = 38;       // inner channel width and height (fits the 34 mm lens)
lid_t  = 3.5;
end_t  = 5;        // end wall thickness (holds lid screws)
m2_pilot = 1.7;    // M2 self tap hole in PETG
m2_clear = 2.4;

$fn = 64;

// ---------- derived ----------
axis_z  = floor_t + inner/2;          // optical axis height (19)
top_z   = floor_t + inner;            // top of walls (35)
half_o  = inner/2 + wall;             // outer half width (18)
car_len = 7;                          // carriage length in X
car_w   = inner - 0.6;                // carriage width, 0.3 mm slide gap per side
x_nose  = -16 - end_t;                // nose end wall outer face (-21)
x_far   = lens_x + screen_max + car_len + 1; // far end wall inner face (74)
x_end   = x_far + end_t;              // far outer face (79)
bulk_t  = 6;                          // lens bulkhead thickness
gd      = 1.5;                        // groove depth for plate
slot_x0 = lens_x + screen_min + car_len/2;  // lock screw slot start
slot_x1 = lens_x + screen_max + car_len/2;  // lock screw slot end
echo(str("screw slot X ", slot_x0, " to ", slot_x1, ", pod box X ", x_nose, " to ", x_end));

// ---------- helpers ----------
module plate_bar(len, w, z0, z1) {
  // bar along the 45 degree plate line, centered at X=0,Y=0
  translate([0,0,z0]) rotate([0,0,45]) translate([-len/2,-w/2,0]) cube([len,w,z1-z0]);
}

// U shape: circle at bottom, straight up to the top (drop-in, no overhang)
module u_shape(r, cz, top, th) {
  rotate([0,90,0]) linear_extrude(th, center=true)
    translate([-cz,0]) union() {
      circle(r);
      translate([-(top-cz)-1, -r]) square([top-cz+1, 2*r]);
    }
}

// C clip around the temple arm, opening faces +X. Solid down to the bed.
module arm_clip() {
  cw = arm_t + clip_fit;      // cavity X
  ch = arm_w + clip_fit;      // cavity Z
  zc = axis_z + arm_y;
  wi = 3.6;                   // inner wall (holds zip tie slot)
  wo = 2.0;
  y0 = -half_o - clip_gap - clip_len;
  y1 = -half_o + 0.01;
  difference() {
    translate([temple_x - cw/2 - wi, y0, 0]) cube([cw + wi + wo, y1 - y0, zc + ch/2 + 2]);
    // arm cavity (only in the clip zone)
    translate([temple_x - cw/2, y0 - 1, zc - ch/2]) cube([cw, clip_len + 1, ch]);
    // snap opening on the +X side
    translate([temple_x + cw/2 - 0.1, y0 - 1, zc - ch/2 + lip]) cube([wo + 1, clip_len + 1, ch - 2*lip]);
    // zip tie slot (backup), vertical through the inner wall
    translate([temple_x - cw/2 - wi/2 - 0.8, y0 + clip_len/2 - 2.5, -1]) cube([1.8, 5, zc + ch]);
  }
}

// ---------- BASE ----------
module base() {
  difference() {
    union() {
      // floor
      translate([x_nose, -half_o, 0]) cube([x_end - x_nose, 2*half_o, floor_t]);
      // nose end wall
      translate([x_nose, -half_o, 0]) cube([end_t, 2*half_o, top_z]);
      // far end wall
      translate([x_far, -half_o, 0]) cube([end_t, 2*half_o, top_z]);
      // side walls: only from the lens bulkhead back (plate zone is open for see through)
      for (s = [-1, 1]) translate([lens_x - bulk_t/2, s > 0 ? inner/2 : -half_o, 0])
        cube([x_far - (lens_x - bulk_t/2) + 0.01, wall, top_z]);
      // lens bulkhead
      translate([lens_x - bulk_t/2, -half_o, 0]) cube([bulk_t, 2*half_o, top_z]);
      // floor rib under the plate
      plate_bar(plate_size + 4, plate_t + 4, floor_t - 0.01, axis_z - plate_size/2 + gd);
      // temple arm clip
      arm_clip();
    }
    // plate groove in floor rib
    plate_bar(plate_size + 0.6, plate_t + 0.3, axis_z - plate_size/2, axis_z);
    // lens drop-in slot (lens edge)
    translate([lens_x, 0, 0]) u_shape(lens_d/2 + 0.3, axis_z, top_z, lens_slot_w);
    // light aperture through the bulkhead
    translate([lens_x, 0, 0]) u_shape(lens_d/2 - 1.3, axis_z, top_z, bulk_t + 2);
    // lock screw slot through the floor
    hull() for (x = [slot_x0, slot_x1]) translate([x, 0, -1]) cylinder(d = m2_clear, h = floor_t + 2);
    // focus scale ticks on the floor bottom (read against the screw head), 1 mm steps
    for (d = [screen_min : 1 : screen_max]) {
      L = (d % 4 == 0) ? 5 : 2.5;
      translate([lens_x + d + car_len/2 - 0.25, 2, -0.01]) cube([0.5, L, 0.4]);
    }
    // wire exit: U notch at the top of the far wall
    translate([x_far - 1, -5, top_z - 10]) cube([end_t + 2, 10, 11]);
    // lid screw pilots
    for (x = [x_nose + end_t/2, x_far + end_t/2]) for (y = [-14, 14])
      translate([x, y, top_z - 10]) cylinder(d = m2_pilot, h = 11);
  }
}

// ---------- LID (modeled in place, flipped for print) ----------
module lid_in_place() {
  difference() {
    union() {
      translate([x_nose, -half_o, top_z]) cube([x_end - x_nose, 2*half_o, lid_t]);
      // rib over the plate
      plate_bar(plate_size + 4, plate_t + 4, axis_z + plate_size/2 - gd, top_z + 0.01);
      // tab that holds the lens down
      translate([lens_x - lens_slot_w/2 - 1.5, -8, axis_z + lens_d/2 + 0.3])
        cube([lens_slot_w + 3, 16, top_z - (axis_z + lens_d/2 + 0.3) + 0.01]);
    }
    plate_bar(plate_size + 0.6, plate_t + 0.3, axis_z + plate_size/2 - gd - 0.01, axis_z + plate_size/2 + 0.3);
    // lens groove in the tab
    translate([lens_x - lens_slot_w/2, -9, axis_z]) cube([lens_slot_w, 18, lens_d/2 + 1]);
    // screw holes
    for (x = [x_nose + end_t/2, x_far + end_t/2]) for (y = [-14, 14])
      translate([x, y, top_z - 1]) cylinder(d = m2_clear, h = lid_t + 2);
    // vents over the OLED
    for (x = [lens_x + screen_min + 2 : 4 : x_far - 3])
      translate([x, -10, top_z - 1]) cube([1.6, 20, lid_t + 2]);
  }
}
module lid_print() { translate([0, 0, top_z + lid_t]) mirror([0,0,1]) lid_in_place(); }

// ---------- CARRIAGE (front face at X=0 faces -X, toward the lens) ----------
glass_h  = 15;
car_base = axis_z - floor_t - glass_bot - glass_h/2;  // puts the glass center on the optical axis
car_top  = car_base + pcb_h - 3;  // PCB top 3 mm sticks out for the header pins
module carriage() {
  pw = pcb_w + fit;
  difference() {
    translate([0, -car_w/2, 0]) cube([car_len, car_w, car_top]);
    // PCB slot (drop in from the top)
    translate([1.5, -pw/2, car_base]) cube([pcb_t + fit, pw, car_top]);
    // front window for the glass (open to the top, no bridge)
    translate([-1, -(glass_w + 0.6)/2, car_base + glass_bot - 1.5]) cube([2.6, glass_w + 0.6, car_top]);
    // back window for parts on the PCB back
    translate([1.5 + pcb_t + fit - 0.01, -12, car_base + 3]) cube([car_len, 24, car_top]);
    // M2 lock screw pilot from below
    translate([car_len/2, 0, -1]) cylinder(d = m2_pilot, h = car_base + 0.9);
  }
}

// ---------- layouts ----------
module assembly() {
  color("SteelBlue") base();
  color("LightSteelBlue", 0.5) lid_in_place();
  color("Orange") translate([lens_x + screen_nominal, 0, floor_t + 0.01]) carriage();
  color("Cyan", 0.4) plate_bar(plate_size, plate_t, axis_z - plate_size/2, axis_z + plate_size/2);
  color("White", 0.6) translate([lens_x, 0, axis_z]) rotate([0,90,0]) cylinder(d = lens_d, h = lens_edge_t, center = true);
}

if (part == "base") base();
else if (part == "lid") lid_print();
else if (part == "carriage") carriage();
else if (part == "assembly") assembly();
else {
  base();
  translate([0, 50, 0]) lid_print();
  translate([60, -50, 0]) carriage();
}
