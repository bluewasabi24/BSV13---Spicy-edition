/obj/machinery/atmospherics/pipe/layer_manifold
	name = "layer adaptor"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	pipe_flags = PIPING_ALL_LAYER | PIPING_DEFAULT_LAYER_ONLY | PIPING_CARDINAL_AUTONORMALIZE
	piping_layer = PIPING_LAYER_DEFAULT
	device_type = 0
	volume = 350
	construction_type = /obj/item/pipe/binary
	pipe_state = "manifoldlayer"
	paintable = FALSE
	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_STRAIGHT,\
		pipe_interference_group = list("atmos-1","atmos-2","atmos-3")\
	)

	var/list/front_nodes
	var/list/back_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize(mapload)
	front_nodes = list()
	back_nodes = list()
	icon_state = "manifoldlayer_center"
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	nullifyAllNodes()
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/nullifyAllNodes()
	var/list/obj/machinery/atmospherics/needs_nullifying = get_all_connected_nodes()
	front_nodes = null
	back_nodes = null
	nodes = list()
	for(var/obj/machinery/atmospherics/A in needs_nullifying)
		if(A != null && src != null) //if it's already null why are we doing this? The answer is byond... it'll always find a way
			A.disconnect(src)
			SSair.add_to_rebuild_queue(A)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_all_connected_nodes()
	return front_nodes + back_nodes + nodes

/obj/machinery/atmospherics/pipe/layer_manifold/update_layer()
	layer = initial(layer) + (PIPING_LAYER_MAX * PIPING_LAYER_LCHANGE) //This is above everything else.

/obj/machinery/atmospherics/pipe/layer_manifold/update_overlays(updates=ALL)
	. = ..()
	for(var/node in front_nodes)
		. += add_attached_images(node)
	for(var/node in back_nodes)
		. += add_attached_images(node)

	update_alpha()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/add_attached_images(obj/machinery/atmospherics/A)
	if(!A)
		return
	if(istype(A, /obj/machinery/atmospherics/pipe/layer_manifold))
		for(var/i in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
			return get_attached_image(get_dir(src, A), i)
	return get_attached_image(get_dir(src, A), A.piping_layer, A.pipe_color)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_attached_image(p_dir, p_layer, p_color = null)
	var/mutable_appearance/new_overlay

	// Uses pipe-3 because we don't want the vertical shifting
	if(p_color)
		new_overlay = get_pipe_image(icon, "pipe-3", p_dir, p_color, piping_layer = p_layer)
	else
		new_overlay = get_pipe_image(icon, "pipe-3", p_dir, piping_layer = p_layer)

	new_overlay.layer = layer - 0.01
	return new_overlay

/obj/machinery/atmospherics/pipe/layer_manifold/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/is_connectable(obj/machinery/atmospherics/target, given_layer)
	if(!given_layer)
		return TRUE
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections()
	front_nodes = list()
	back_nodes = list()
	var/list/new_nodes = list()
	for(var/iter in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		var/obj/machinery/atmospherics/foundfront = find_connecting(dir, iter)
		var/obj/machinery/atmospherics/foundback = find_connecting(turn(dir, 180), iter)
		front_nodes += foundfront
		back_nodes += foundback
		if(foundfront && !QDELETED(foundfront))
			new_nodes += foundfront
		if(foundback && !QDELETED(foundback))
			new_nodes += foundback
	update_icon()
	return new_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/atmos_init()
	normalize_cardinal_directions()
	findAllConnections()
	//var/turf/T = loc			// hide if turf is not intact
	//hide(T.underfloor_accessibility < UNDERFLOOR_VISIBLE)

/obj/machinery/atmospherics/pipe/layer_manifold/set_piping_layer()
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return get_all_connected_nodes()

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	while(reference in get_all_connected_nodes())
		if(reference in nodes)
			var/i = nodes.Find(reference)
			nodes[i] = null
		if(reference in front_nodes)
			var/i = front_nodes.Find(reference)
			front_nodes[i] = null
		if(reference in back_nodes)
			var/i = back_nodes.Find(reference)
			back_nodes[i] = null
	update_icon()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 1, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer]\th output.")

/obj/machinery/atmospherics/pipe/layer_manifold/visible
	layer = GAS_PIPE_VISIBLE_LAYER
