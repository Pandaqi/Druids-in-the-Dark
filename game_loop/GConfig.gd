extends Node

#
# MISC
#

# how much empty space to leave at edges when auto-centering camera
var camera_edge_margin := Vector2(40.0, 40.0)


#
# MAP
#

# this is the default size of all sprites and cells in game world
var cell_size := 512.0
var def_map_size := Vector2(7,5)
var map_size_scalar := [0.0, 1.0, 1.125, 1.25, 1.4] # first one is for "0 players", which never happens, so just do 0

var machines_included := [] # updated as we go through levels to indicate what machines should be placed
var machine_frequency_scalar := [0.0, 1.0, 1.1, 1.25, 1.5]

var def_cell_element_scale := 0.75

#
# SHADOWS
#

# on high player counts, we lower def shadow, otherwise the map has to be huge or is always covered in shadow entirely
var def_shadow_size := [0,2,2,1,1]
var shadow_filter_based_on_effects := false

#
# PROGRESSION
#

# how many rounds a single game/run can have at most
# (at this point, it's at its biggest size and tutorials have run out)
var max_levels_per_run := 20
var def_prog_tick := 6
var prog_tick_scalar := [1.0, 0.9, 0.8, 0.7]

var prog_def_potion_bounds := { "min": 1, "max": 3 }
var prog_potion_bounds_scalar := [0.0, 1.0, 1.1, 1.2, 1.5]

var prog_def_customer_bounds := { "min": 1, "max": 3 }
var prog_customer_bounds_scalar := [0.0, 1.0, 1.1, 1.2, 1.5]

var prog_def_num_total_customers_bounds = { "min": 2, "max": 7 }
var prog_num_total_customers_scalar = [0.0, 1.0, 1.15, 1.25, 1.5]

var def_dynamic_spawner_tick := 10
var dynamic_spawner_tick_scalar := [1.0, 0.9, 0.8, 0.7]
var dynamic_spawner_freq_scalar := [1.0, 1.15, 1.25, 1.5]

#
# MOVEMENT
#
var disabled_cells_kill_you := true
var def_move_tween_duration := 0.33

#
# INVENTORY
#
var inventory_scale := 0.4
var inventory_max_size := 4

#
# RECIPES
# 
var recipe_book_visit_changes_recipes := false
var potion_delivery_regenerates_recipe := false

var wildcard_include := false

#
# INGREDIENTS, POTIONS & SPAWNING
#
var only_spawn_whats_wanted := true

var map_spawns_components := true
var map_spawn_component_prob := 0.75

var map_spawns_potions := false
var map_spawn_potion_prob := 0.33

var mutate_elements_in_shadow := false
var mutate_min_time := 10
var mutate_check_tick := 1
var mutate_prob := 0.2

var remove_dynamic_elements_in_shadow := false
var remove_dynamic_min_time := 7

var potion_garbage_can_appear := false
var potion_garbage_prob := 0.33

var delivered_components_create_effects := false # after delivering an order, the special powers attached to the ingredients become yours

#
# ORDERS
#
var orders_are_timed := false
var def_order_duration := { "min": 25, "max": 40 }
var order_duration_scalar := [0.0, 1.0, 1.0, 1.25, 1.33]

var customers_want_components := true
var customer_want_component_prob := 0.75

var customers_want_potions := false
var customer_want_potion_prob := 0.33

var customer_visit_delays_timer := true
var customer_timer_delay_scalar := 0.2 # multiplied by average order time

var order_only_visible_after_visit := false # you must first "ask what they want" by visiting

var wrong_order_is_garbage := false # walking over order invalidly clears inventory
var wrong_order_moves_machines := false # walking over order invalidly makes stuff change positions
