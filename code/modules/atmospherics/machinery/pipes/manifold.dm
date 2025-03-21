//3-Way Manifold

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-3"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY

	construction_type = /obj/item/pipe/trinary
	pipe_state = "manifold"

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_MANIFOLD,\
		pipe_interference_group = "atmos-[piping_layer]"\
	)

/* We use New() instead of Initialize(mapload) because these values are used in update_appearance(UPDATE_ICON)
 * in the mapping subsystem init before Initialize(mapload) is called in the atoms subsystem init.
 * This is true for the other manifolds (the 4 ways and the heat exchanges) too.
 */
/obj/machinery/atmospherics/pipe/manifold/New(mapload)
	icon_state = ""
	return ..()

/obj/machinery/atmospherics/pipe/manifold/set_init_directions()
	initialize_directions = NORTH|SOUTH|EAST|WEST
	initialize_directions &= ~dir

/obj/machinery/atmospherics/pipe/manifold/update_overlays()
	. = ..()
	var/mutable_appearance/center = mutable_appearance(icon, "manifold_center")
	if(!center)
		center = mutable_appearance(icon, "manifold_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += get_pipe_image(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))

	update_layer()
	update_alpha()
