/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	pipe_flags = PIPING_ONE_PER_TURF
	construction_type = /obj/item/pipe/directional
	var/uid
	var/static/gl_uid = 1
	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_NODE,\
		pipe_interference_group = "atmos-[piping_layer]"\
	)

/obj/machinery/atmospherics/components/unary/set_init_directions()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/on_construction()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/hide(intact)
	update_icon()
	..(intact)

/obj/machinery/atmospherics/components/unary/proc/assign_uid_vents()
	uid = num2text(gl_uid++)
	return uid

/obj/machinery/atmospherics/components/unary/proc/change_pipe_connection(disconnect)
	if(disconnect)
		disconnect_pipes()
		return
	connect_pipes()

/obj/machinery/atmospherics/components/unary/proc/connect_pipes()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	atmos_init()
	node1 = nodes[1]
	if(node1)
		node1.atmos_init()
		node1.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/proc/disconnect_pipes()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullify_pipenet(parents[1])
