extends Node

#
# DEBUGGING
#
var debug_starting_level := -1
var debug_disable_tweens := false

#
# MISC
#

# how much empty space to leave at edges when auto-centering camera
var camera_edge_margin := Vector2(40.0, 40.0)

# length of countdown before each level starts (and shadows come in)
var countdown_num_seconds := 3

#
# MAP
#

# this is the default size of all sprites and cells in game world
var cell_size := 512.0
var def_map_size := Vector2(7,5)
var map_size_scalar := [0.0, 1.0, 1.11, 1.2, 1.25] # first one is for "0 players", which never happens, so just do 0

var machines_included := [] # updated as we go through levels to indicate what machines should be placed
var machine_frequency_scalar := [0.0, 1.0, 1.1, 1.25, 1.5]

var def_cell_element_scale := 0.75

var map_size_growth_per_level := 1.0225
var map_size_growth_max := 1.5

# at least this many cells must not be used or occupied, otherwise it's just too busy or impossible to play
# @NOTE: this is only checked on progression; other elements (such as potion breaking) must always succeed for consistency
var map_percentage_required_empty := 0.175

#
# SHADOWS
#

# on high player counts, we lower def shadow, otherwise the map has to be huge or is always covered in shadow entirely
var def_shadow_size := [0,2,2,1,1]
var shadow_filter_based_on_effects := false
var shadow_sprite_alpha := 0.66

#
# PROGRESSION
#

# how many rounds a single game/run can have at most
# (at this point, it's at its biggest size and tutorials have run out)
var cur_level := 0
var max_levels_per_run := 20
var prog_skip_bounds := { "min": 2, "max": 4 } # how many levels a property stays the same before it jumps to the next option

var def_prog_tick := 3
var prog_tick_scalar := [0.0, 1.0, 0.9, 0.8, 0.7]

var prog_def_potion_bounds := { "min": 1, "max": 3 }
var prog_potion_bounds_scalar := [0.0, 1.0, 1.1, 1.2, 1.5]

var prog_def_customer_bounds := { "min": 1, "max": 3 }
var prog_customer_bounds_scalar := [0.0, 1.0, 1.1, 1.2, 1.5]

var prog_def_num_total_customers_bounds = { "min": 4, "max": 7 }
var prog_num_total_customers_scalar = [0.0, 1.0, 1.15, 1.25, 1.5]

var def_dynamic_spawner_tick := 6
var dynamic_spawner_tick_scalar := [0.0, 1.0, 0.9, 0.8, 0.7]
var dynamic_spawner_freq_scalar := [0.0, 1.0, 1.15, 1.25, 1.5]

var garbage_bin_content_is_permanent := false
var boosted_component_factor := 4.0 # they are "4x more likely" than others
var prog_max_planter_cells := 8

var prog_potions_num_before_start := 2 # it takes a while before potions start ticking up, otherwise we start with way too many potions outright => especially with recipe book moved back

#
# MOVEMENT
#
var disabled_cells_kill_you := false
var def_move_tween_duration := 0.33
var players_interact_by_sharing_inventory := false

#
# INVENTORY
#
var inventory_scale := 0.4
var inventory_max_size := 4

#
# RECIPES
# 
var recipes_available : Dictionary = {} # populated dynamically as they're generated in a level

var recipe_book_visit_changes_recipes := false
var potion_delivery_regenerates_recipe := false
var recipe_book_dynamic_read_dir := false

var wildcard_include := false

#
# INGREDIENTS, POTIONS & SPAWNING
#
var only_spawn_whats_wanted := true

var map_spawns_components := true
var map_spawns_potions := false
var map_spawn_component_over_potion_prob := 0.66 # 2 out of 3 times, when both are allowed, it prefers spawning a component

var mutate_elements_in_shadow := false
var mutate_min_time := 4
var mutate_check_tick := 0.33
var mutate_prob := 0.275

var remove_dynamic_elements_in_shadow := false
var remove_dynamic_min_time := 2.5

var potion_garbage_can_appear := false
var potion_garbage_prob := 0.33

var delivered_components_create_effects := false # after delivering an order, the special powers attached to the ingredients become yours

#
# ORDERS
#
var orders_are_timed := false
var def_order_duration := { "min": 14, "max": 24 }
var order_duration_scalar := [0.0, 1.0, 1.1, 1.2, 1.33]
var order_duration_prog_scalar_per_level := 1.0535
var order_duration_prog_scalar_max := 3.0

var customers_want_components := true
var customer_want_component_prob := 0.75

var customers_want_potions := false
var customer_want_potion_prob := 0.33

var customer_visit_delays_timer := true
var customer_timer_delay_scalar := 0.425 # multiplied by average order time

var order_only_visible_after_visit := false # you must first "ask what they want" by visiting

var wrong_order_is_garbage := false # walking over order invalidly clears inventory
var wrong_order_moves_machines := false # walking over order invalidly makes stuff change positions
