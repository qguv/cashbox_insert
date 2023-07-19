fudge = 0.01;
$fn = 90;

module cyl(h, r, on_edge=false) {
    rotate([0, on_edge ? 90 : 0, 0])
        translate([r - (on_edge ? 2 * r : 0), r, 0])
            cylinder(h=h, r=r);
}

module rrect(border_radius, size) {
    hull() {
        for (x = [0:1]) {
            for (y = [0:1]) {
                translate([
                    x * (size.x - border_radius * 2),
                    y * (size.y - border_radius * 2),
                    0,
                ]) {
                    cyl(size.z, r=border_radius);
                }
            }
        }
    }
}

module hinge_positive(size, hinge_cut_size, hinge_cut_x) {
    translate([
        hinge_cut_x,
        size.y - hinge_cut_size.y,
        -fudge
    ]) {
        cube([
            hinge_cut_size.x,
            hinge_cut_size.y + fudge,
            size.z + fudge * 2,
        ]);
    }
    translate([size.x - hinge_cut_x - hinge_cut_size.x, size.y - hinge_cut_size.y, -fudge]) {
        cube([
            hinge_cut_size.x,
            hinge_cut_size.y + fudge,
            size.z + fudge * 2,
        ]);
    }
}

module lock_slot_positive(size, lock_cut_size, lock_cut_position) {
    translate([
        lock_cut_position.x,
        lock_cut_position.y,
        -fudge,
    ]) {
        cube([
            lock_cut_size.x,
            lock_cut_size.y,
            size.z + fudge * 2,
        ]);
    }
}

module insert_positive(size, insert_size, insert_position) {
    translate([
        insert_position.x,
        insert_position.y,
        -fudge,
    ]) {
        cube([
            insert_size.x,
            insert_size.y,
            size.z + fudge * 2,
        ]);
    }
}

module tray_positive(
    border_radius, size, hinge_cut_size, hinge_cut_x, lock_cut_size, lock_cut_position, insert_size, insert_position
) {
    rrect(border_radius, size);
    coin_trays(size);
}

module tray_negative(
    border_radius, size, hinge_cut_size, hinge_cut_x, lock_cut_size, lock_cut_position, insert_size, insert_position
) {
    hinge_positive(size, hinge_cut_size, hinge_cut_x);
    lock_slot_positive(size, lock_cut_size, lock_cut_position);
    //insert_positive(size, insert_size, insert_position);
    coins(size);
}

module tray(
    border_radius, size, hinge_cut_size, hinge_cut_x, lock_cut_size, lock_cut_position, insert_size, insert_position
) {
    difference() {
        union() tray_positive(
            border_radius, size, hinge_cut_size, hinge_cut_x, lock_cut_size, lock_cut_position, insert_size, insert_position
        );
        tray_negative(
            border_radius, size, hinge_cut_size, hinge_cut_x, lock_cut_size, lock_cut_position, insert_size, insert_position
        );
    }
}

module test(size) {
    difference() {
        children();
        translate([
            -fudge,
            -fudge,
            -fudge,
        ]) {
            cube([size.x / 2 + fudge, size.y + fudge * 2, size.z + fudge * 2]);
        }
    }
}

module coins(size, wall=0) {
    coins = [
//      [d,     h   ], // value
//      [16.25, 1.67], // 1c
//      [18.75, 1.67], // 2c
        [21.25, 1.67], // 5c
        [19.75, 1.93], // 10c
        [22.25, 2.14], // 20c
        [24.25, 2.38], // 50c
        [23.25, 2.33], // EUR1
        [25.75, 2.20], // EUR2
    ];
    coin_wiggle = 0.5;
    batch_offset = 3;
    batch_n = 5;
    batches = 5;
    series_sep = 5;
    rows = 3;
    for (coin_i = [0 : len(coins) - 1]) {
        coin = coins[coin_i];
        row_i = coin_i % rows;
        col_i = floor(coin_i / rows);
        batch_size = [
            coin[1] * batch_n + coin_wiggle,
            coin[0] + coin_wiggle,
        ];
        series_size = [
            batch_size.x * batches,
            batch_size.y + batch_offset,
        ];
        series_pos = [
            size.x / 2
                + (col_i % 2 ? 0 : -1) * series_size.x
                + (col_i % 2 ? 1 : -1) * series_sep,
            size.y / (2 * rows + 2) * (2 + row_i * 2) - (series_size.y / 2),
            size.z - coin.x / 2,
        ];
        for (batch_i = [0 : batch_n - 1]) {
            translate([
                series_pos.x + batch_size.x * batch_i - wall,
                series_pos.y + (batch_i % 2 ? batch_offset : 0) - wall,
                series_pos.z - wall,
            ]) {
                cyl(batch_size.x + wall * 2, batch_size.y / 2 + wall, true);
            }
        }
    }
}

module coin_trays(size) {
    difference() {
        coins(size, size.z);
        translate([0, 0, size.z + fudge]) {
            cube([
                size.x,
                size.y,
                1000,
            ]);
        }
    }
}


size = [192, 152, 2];
tray(
    20, size,
    [45, 10], 30,
    [32, 5], [97, 7],
    [160, 118],
    [15, 20]
);