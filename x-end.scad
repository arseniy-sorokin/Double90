// End of the X axis
include <conf/config.scad>;

rounded_corner_radius = 6;

wall = thick_wall; 

Z_bearing_holder_wall = 2.5;
Z_bearing_outer_diameter = Z_bearings[1] + 0.2;
Z_bearing_holder_width = Z_bearing_outer_diameter + 2 * Z_bearing_holder_wall;
Z_bearing_depth = Z_bearing_holder_width / 2;
Z_bearing_length = Z_bearings[0];

shelf_thickness = 2;
shelf_clearance = 0.2; // distance between top of bearing and a shelf
shelf_depth = Z_bearing_depth - (Z_smooth_rod_diameter / 2 + 1);

Z_bearings_holder_height = max( min(65, 2.8 * Z_bearing_length), 2 * (Z_bearing_length + shelf_clearance) + 3 * shelf_thickness);

anti_backlash_wall_radius = Z_nut_radius + 0.2;
anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_wall_radius + 0.5);
anti_backlash_wall_height = nut_thickness(Z_nut);

base_thickness = nut_depth(Z_nut) + 2 * wall;
clamp_length = z_bar_spacing();
clamp_width = X_smooth_rod_diameter + 2 * wall;
slit = 2;


shelves_Z_coordinate = [ shelf_thickness / 2, // shelve at the bottom
            shelf_thickness + Z_bearing_length + shelf_clearance + shelf_thickness / 2, // shelve at the top of bottom bearing
            Z_bearings_holder_height - shelf_thickness / 2, // shelve at the bottom of top bearing
            Z_bearings_holder_height - (shelf_thickness + Z_bearing_length + shelf_clearance + shelf_thickness / 2) ]; // shelve at the top


module x_end_bracket() {
        // Shelves for bearings
        intersection() {
            for(z = shelves_Z_coordinate) {
                translate([-Z_bearing_depth + shelf_depth / 2, 0, z])
                    cube([shelf_depth, Z_bearing_outer_diameter, shelf_thickness], center = true);
            }
            cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2, $fn = smooth);
        }

        difference() {
            union() {
                // Main vertical block
                translate([-clamp_length / 2 , X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, (x_bar_spacing() + clamp_width) / 2]) {
                    difference() {
                        cube([clamp_length, clamp_width, x_bar_spacing() + wall], center = true);
                        translate([0, 0, -X_smooth_rod_diameter / 2 + wall / 2])
                            cube([clamp_length + eta, X_smooth_rod_diameter - wall, x_bar_spacing() - clamp_width], center = true); 
                        translate([0, 0, (x_bar_spacing() - 1.5 * clamp_width) / 2])
                            rotate([90, 0, 90])  
                                teardrop(h = clamp_length + eta, r = (X_smooth_rod_diameter - wall) / 2, truncate=false, $fn = smooth, center = true);  
                    }
                    // Spectra line stabilizer
                    translate([wall, 0, - X_smooth_rod_diameter / 2])
                        difference() {
                            cube([2, clamp_width, x_bar_spacing() / 2 + wall], center = true);
                            cube([2 * 2, slit, x_bar_spacing() / 2 + wall], center = true);
                            // translate([0, 0, -(x_bar_spacing() / 3 + wall) / 2])
                            //     rotate([90, 0, 90])  
                            //         teardrop(h = slit * 2 + eta, r = X_smooth_rod_diameter / 2 - wall / 2, $fn = smooth, truncate=false, center = true);
                        }
                }

                // Anti-backlash nut holder
                if (is_hex(Z_nut)) {
                    translate([-z_bar_spacing(), 0, anti_backlash_wall_height / 2])
                       rotate([0, 0, 90])                    
                            cylinder(r = anti_backlash_wall_radius + anti_backlash_wall_width, h = anti_backlash_wall_height, $fn = 6, center = true);
                } else if (is_flanged(Z_nut)) {
                } else { 
                    // translate([-z_bar_spacing(), 0, base_thickness / 2])
                    //     cylinder(r = Z_nut_radius + anti_backlash_wall_width, h = base_thickness, $fn = smooth, center = true);
                    // hull() {
                        // translate([0, 0, (base_thickness - wall) / 2])
                        //     cylinder(r = Z_bearing_holder_width / 2, h = base_thickness- wall, $fn = smooth, center = true);
                        translate([-z_bar_spacing(), 0, (base_thickness- wall ) / 2])
                            cylinder(h = base_thickness- wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                    // }
                    translate([-z_bar_spacing() + Z_nut_radius + z_bar_spacing() / 4 + wall / 2, 0, base_thickness / 2])
                        cube([z_bar_spacing() / 2 + wall, Z_bearing_holder_width, base_thickness], center = true);
                    // Z thread nut cover
                    // *difference() {
                    //     cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                    //     cylinder(h = wall + eta, r = Z_nut_radius - wall, $fn = smooth, center = true);
                    //     *translate([- Z_nut_radius / 2 - wall, 0, 0])
                    //         cube([Z_nut_radius + 2 * wall, (Z_nut_radius - wall) * 2, wall + eta], center = true);
                    // }

                    translate([-z_bar_spacing(), 0, base_thickness - wall / 2]) {
                        rotate ([0, 0, 90]) {
                            intersection() {
                                cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                                union() {
                                    // Right thin bar
                                    translate([-Z_screw_diameter / 2 - (wall - 1) / 2 - 0.5, 0, 0])
                                        cube([wall - 0.5, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    // Left thicker cover
                                    translate([Z_screw_diameter / 2 + wall + 0.5, 0, 0])
                                        cube([wall * 2, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    difference() {
                                        cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                                        cylinder(h = wall + eta, r = Z_nut_radius, $fn = smooth, center = true);
                                        translate([-Z_screw_diameter / 2 - (wall * 3) / 2 - 0.5, 0, 0])
                                            cube([wall * 3, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    }
                                }
                            }
                        }
                    }

                    // Bottom connection 
                    translate([-z_bar_spacing() + Z_nut_radius - wall, -Z_bearing_holder_width / 4, wall / 2])
                        cube([Z_screw_diameter, Z_bearing_holder_width / 2, wall], center = true);
                }
                // Large support triangle
                // *translate([-z_bar_spacing() + Z_nut_radius / 2, Z_bearing_holder_width / 2 - wall, base_thickness]) 
                //     rotate([90, 0, -90])
                //         right_triangle(width = wall - 0.2,  height = x_bar_spacing(), h = Z_nut_radius);

                // Small support triangle
                translate([-clamp_length + 0.1, Z_nut_radius, base_thickness]) 
                    rotate([90, 0, 180]) 
                        right_triangle(width = wall + 1,  height = x_bar_spacing() - X_smooth_rod_diameter / 2 - wall, h = wall, center = true);

                for (y = [Z_nut_radius - wall + 0.5 / 2, -Z_nut_radius + wall]) {
                    // Left support triangle
                    translate([(-z_bar_spacing() + Z_screw_diameter / 2 + 1.5 * wall) / 2, y, base_thickness]) 
                        rotate([90, 0, 180]) 
                            right_triangle(width = z_bar_spacing(),  height = Z_bearings_holder_height - base_thickness, h = wall - 0.5, center = true);

                    // Right support triangle
                    // translate([(-z_bar_spacing() + Z_screw_diameter / 2 + 1.5 * wall) / 2, -Z_nut_radius + wall , base_thickness]) 
                    //     rotate([90, 0, 180]) 
                    //         right_triangle(width = z_bar_spacing(),  height = Z_bearings_holder_height - base_thickness, h = wall - 0.5, center = true);
                }

                // Support triangle
                // *translate([-z_bar_spacing() / 4, -Z_screw_diameter / 2 - (wall - 1) / 2 - 0.5, base_thickness]) {
                //     rotate([90, 0, 180]) 
                //         right_triangle(width = z_bar_spacing() + wall - 1,  height = Z_bearings_holder_height - base_thickness - wall, h = wall - 0.5, center = true);
                //     translate([-Z_screw_diameter / 2, 0, - wall / 2])
                //         rotate ([0, 0, 90]) 
                //             cube([wall - 0.5, z_bar_spacing() / 2, wall], center = true);
                //     }

                // *difference() {
                //     translate([- clamp_length + clamp_length / 8 , (Z_bearing_holder_width / 2 - wall) / 2, (x_bar_spacing() + clamp_width) / 4]) 
                //         cube([clamp_length / 4, Z_bearing_holder_width / 2 - wall, (x_bar_spacing() + clamp_width) / 2 - 10], center = true);

                //     translate([-z_bar_spacing() - wall, 0, (x_bar_spacing() + clamp_width) / 4]) 
                //         cylinder(r = Z_bearing_holder_width / 2 - wall + 1, h = (x_bar_spacing() + clamp_width) / 2 - 10, $fn = smooth, center = true);
                // }

                // Rounded inner edge
                // *difference() {
                //     union() {  
                //      // hull() { -Z_bearing_depth - Z_bearing_holder_width / 4 
                //         *translate([-Z_bearing_depth + wall / 2 , (Z_bearing_holder_width / 2 - wall) / 2, (Z_bearings_holder_height + 2 * X_smooth_rod_diameter) / 2]) 
                //             cube([wall, Z_bearing_holder_width / 2 - wall, Z_bearings_holder_height + 2 * X_smooth_rod_diameter], center = true);
                        
                //         *translate([0, 0, Z_bearings_holder_height + X_smooth_rod_diameter])                      
                //             intersection() {       
                //                 translate([-Z_bearing_depth, 0, 0])                      
                //                     cube([2 * Z_bearing_depth, Z_bearing_outer_diameter, 2 * X_smooth_rod_diameter], center = true);
                //                 translate([-z_bar_spacing() / 2 + wall, 0, 0])   
                //                     cylinder(h = 2 * X_smooth_rod_diameter, r = Z_bearing_holder_width / 2, $fn = smooth, center = true);
                //             }
                //         // }
                //     }
                //     // Big empty cylinder at the top
                //     translate([-Z_bearing_depth, -Z_bearing_holder_width / 2 - wall, Z_bearings_holder_height + Z_bearing_holder_width - 1]) 
                //         rotate([90, 0, 90])
                //             cylinder(h = 2 * Z_bearing_holder_width, r = Z_bearing_holder_width, $fn = smooth, center = true);
                // }

                // Z bearings holder
                translate([0, 0, Z_bearings_holder_height / 2])
                    cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2, $fn = smooth, center = true);

                // Bottom X rod holder
                translate([-clamp_length / 2 , X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , 0]) {
                    translate([0, 0, clamp_width / 2])
                        rotate([90, 0, 90])
                           teardrop(r = clamp_width / 2, h = clamp_length, center = true);

                   translate([0, 0, clamp_width / 2])
                        cube([clamp_length, clamp_width, clamp_width], center = true);   
                }


                // Top X rod holder
                translate([-clamp_length / 2 , X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , clamp_width / 2 + x_bar_spacing() + wall / 2]) {
                    rotate([90, 0, 90])
                        cylinder(h = clamp_length, r = clamp_width / 2, $fn = smooth, center = true);
                       // *teardrop(r = clamp_width / 2, h = clamp_length, center = true);
                            
                    //Left top clamp   
                    *translate([0, clamp_width / 8 + slit / 2, clamp_width / 2 + wall])
                        rotate([90, 0, 0])
                            linear_extrude(height = clamp_width / 4, center = true)
                                hull () {
                                    translate([-clamp_length / 2 + rounded_corner_radius, 0, 0])
                                        circle(r = rounded_corner_radius);
                                    translate([clamp_length / 2 - rounded_corner_radius, 0, 0])
                                        circle(r = rounded_corner_radius); 
                                    translate([0, -rounded_corner_radius, 0])
                                        square([clamp_length, wall], center = true);      
                                }
                    //Right top clamp            
                    *translate([0, -clamp_width / 4, clamp_width / 2 + wall])
                        rotate([90, 0, 0])
                            linear_extrude(height = clamp_width / 2, center = true)
                                hull () {
                                    translate([-clamp_length / 2 + rounded_corner_radius, 0, 0])
                                        circle(r = rounded_corner_radius);
                                    translate([clamp_length / 2 - rounded_corner_radius, 0, 0])
                                        circle(r = rounded_corner_radius);  
                                    translate([0, -clamp_width / 2 - wall, 0])
                                        square([clamp_length, wall], center = true);  
                                }
                }
            }

            for (second = [0, x_bar_spacing()]) {
                translate([-clamp_length / 2, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, clamp_width / 2 + second]) {
                    // Holes for X rods
                        rotate([90, 0, 90])
                            // teardrop(r = X_smooth_rod_diameter / 2, h = clamp_length * 2, center = true, truncate = true);
                            cylinder(r = X_smooth_rod_diameter / 2, h = clamp_length * 2, center = true);
                        // Slits for X rods clamps
                        // translate([0, 0, -X_smooth_rod_diameter / 2])
                        //     cube([clamp_length + 1, slit, x_bar_spacing() / 4], center = true);
                    // X bar clamps nut traps
                    // *translate([0, (- slit / 2 - clamp_width / 4), clamp_width - washer_diameter(washer)])
                    //     rotate([90,90,0]) {
                    //         nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth, true, length = nut_trap_depth);
                    //         translate([0, 0, -clamp_width / 2])
                    //             teardrop_plus(r = 3/2, h = 20, center = true);
                    //     }
                }
            }


            translate([-clamp_length / 2, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, x_bar_spacing() / 2 ]) 
                cube([clamp_length + 1, slit, x_bar_spacing() + clamp_width / 2], center = true);

            // Slits for bottom clamp
            *translate([-clamp_length / 2, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 + 1.5 * wall, 0]) { 
                translate([clamp_length / 4, 0, clamp_width * 1.5 - wall -(1.5 * X_smooth_rod_diameter) / 2])
                    rotate([0, 0, 90])
                        cube([clamp_width / 4 + 2 * wall, 0.5, 1.5 * X_smooth_rod_diameter], center = true);
                translate([-clamp_length / 4, 0, clamp_width * 1.5 - wall - (1.5 * X_smooth_rod_diameter) / 2]) 
                    rotate([0, 0, 90])
                        cube([clamp_width / 4 + 2 * wall, 0.5, 1.5 * X_smooth_rod_diameter], center = true);
                translate([0, 0, clamp_width * 1.5 - wall]) 
                    rotate([90, 0, 0])
                        cube([clamp_length / 2 + 0.5, 0.5, clamp_width / 4 + 2 * wall + eta], center = true);
            }

            // Hole for Z leadscrew
            translate([-z_bar_spacing(), 0, Z_bearings_holder_height / 2])
                poly_cylinder(r = Z_screw_diameter / 2, h = 2 * Z_bearings_holder_height + eta, $fn = smooth, center = true);

            //Hole for Z leadscrew nut
            if (is_hex(Z_nut)) {
                // Hex nut
                translate([-z_bar_spacing(), 0, base_thickness / 2])
                    cylinder(r = anti_backlash_wall_radius, h = base_thickness + eta, $fn = 6, center = true);
            } else if (is_flanged(Z_nut)) {
                    //Flanged nut
                    translate([-z_bar_spacing(), 0, 0])
                        poly_cylinder(r = Z_nut_radius + 0.2, h = nut_depth(Z_nut) + eta, $fn = smooth);
                    translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - flanged_nut_flange_thickness(Z_nut) / 2 - 0.1])
                    rotate([0, 0, 23]) {
                        flanged_nut(Z_nut);
                        rotate([0, 0, 120]) {
                            translate ([flanged_nut_hole_distance_radius(Z_nut), 0, base_thickness / 2])
                                poly_cylinder (r = flanged_nut_mounting_hole_radius(Z_nut), h = 2 * flanged_nut_barrel_thickness(Z_nut) + 0.1, center = true);
                            translate ([-flanged_nut_hole_distance_radius(Z_nut), 0, base_thickness / 2])
                                poly_cylinder (r = flanged_nut_mounting_hole_radius(Z_nut), h = 2 * flanged_nut_barrel_thickness(Z_nut) + 0.1, center = true);
                        }           
                    }
            } else {
                // translate([0, 0, Z_bearings_holder_height - base_thickness / 2 ]) {
                    //Round nut
                    translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 + wall]) 
                        poly_cylinder(r = Z_nut_radius, h = nut_depth(Z_nut) + 0.1, $fn = smooth, center = true);
                    translate([-z_bar_spacing(), - Z_nut_radius / 2 - wall, nut_depth(Z_nut) / 2 + wall])
                        cube([Z_nut_radius * 2, Z_nut_radius + 2 * wall, nut_depth(Z_nut) + 0.1], center = true);
                // }
            }

            // Hole for spectra line bearing screw
            translate([-clamp_length * 3 / 4 + wall, Z_bearing_holder_width / 2 + clamp_width / 2 - wall, (clamp_width + x_bar_spacing()) / 2 - wall])
                rotate([90, 0, 0]) 
                   teardrop_plus(r = 4/2, h = 2 * clamp_width + eta, center = true);
                

            // Hole for spectra line fixing screw
            translate([-wall, clamp_width / 2 + Z_bearing_holder_width / 2, (clamp_width + x_bar_spacing()) / 2 - wall + 1.5 * ball_bearing_diameter(BB624)])
                rotate([90, 90, 0])
                    teardrop_plus(r = M4_clearance_radius, h = clamp_width, center = true);                    

            //Hole for Z bearings
            translate([0, 0, -1])
                poly_cylinder(h = Z_bearings_holder_height + 1 + eta, r = Z_bearing_outer_diameter / 2);

            //Front entry cut out
            translate([Z_bearing_outer_diameter/2, 0, Z_bearings_holder_height / 2])
                rotate([0, 0, 45])
                    cube([Z_bearing_outer_diameter, Z_bearing_outer_diameter, Z_bearings_holder_height + 1], center = true);
        }
}

module x_end_assembly() {
    color(x_end_bracket_color)
        render() x_end_bracket();

    // Z leadscrew
    translate([-z_bar_spacing(), 0, 40])
        rod(Z_screw_diameter, 200);
    
    // Z smooth rod
    translate([0, 0, 40])
        rod(Z_smooth_rod_diameter, 200);
    
    // Z leadscrew nut
    if (is_hex(Z_nut)) {
            // Hex nut
        } else {
            if (is_flanged(Z_nut)) {
                // Round flanged nut
                translate([-z_bar_spacing(), 0, 100])
                    rotate([0, 180, 20])
                        flanged_nut(Z_nut);
            } else {
                // Round nut
                translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - wall])
                    round_nut(Z_nut, brass = true, center = true);
            }
        }

    // Spectra line bearing
    translate([-clamp_length * 3 / 4 + wall, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, (clamp_width + x_bar_spacing()) / 2 - wall])
        rotate([0, 90, 90]) 
            ball_bearing(BB624);

    // Spectra line bearing screw
    translate([-clamp_length * 3 / 4 + wall , clamp_width + Z_bearing_holder_width / 2 - wall, (clamp_width + x_bar_spacing()) / 2 - wall])
        rotate([0, 90, 90]) 
            screw_and_washer(M4_pan_screw, screw_longer_than(clamp_width), center = true);

    // Spectra line fixing screw
    translate([-wall, clamp_width + Z_bearing_holder_width / 2 - wall, (clamp_width + x_bar_spacing()) / 2 - wall + 1.5 * ball_bearing_diameter(BB624)])
        rotate([0, 90, 90])
            screw_and_washer(M4_pan_screw, screw_shorter_than(clamp_width), center = true); 

    // Bottom clamp screw
    // translate([-clamp_length / 2 , clamp_width + Z_bearing_holder_width / 2 - wall, 1.5 * clamp_width - washer_diameter(washer)])
    //     rotate([0, 90, 90])
    //         screw(M3_pan_screw, screw_longer_than(clamp_width), center = true); 

    // Top clamp screw
    // translate([-clamp_length / 2 , clamp_width + Z_bearing_holder_width / 2 - 2 * wall - 0.5, 1.5 * clamp_width - washer_diameter(washer) + x_bar_spacing()])
    //     rotate([0, 90, 90])
    //         screw(M3_pan_screw, clamp_width, center = true); 

    // Z leadscrew nut fixing screw
    // translate([-z_bar_spacing() - Z_nut_radius - anti_backlash_wall_width - 15, 0, base_thickness / 2])  
    //     rotate([90, 0, 270]) {
    //         translate([0, 0, -10])  
    //             comp_spring(extruder_spring, 10);
    //         screw_and_washer(M3_pan_screw, anti_backlash_wall_width + 15, center = true); 
    //     }

    // Z bearings
    for(i = [0, 2]) {
        translate([0, 0, (shelves_Z_coordinate[i] + shelves_Z_coordinate[i+1])/2 ])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }

    // X smooth rods
    for (second = [0, x_bar_spacing()]) {
        translate([-clamp_length + 45, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , clamp_width / 2 + second]) {
            rotate([90, 0, 90])
                rod(X_smooth_rod_diameter, 100);
        }
    }
    
    translate([5, clamp_width + Z_bearing_holder_width / 2, clamp_width + microswitch_length() / 2])
        rotate([0, 90, 270])
            microswitch();
}

x_end_assembly();
