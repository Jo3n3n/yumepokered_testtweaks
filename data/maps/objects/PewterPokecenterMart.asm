; marcelnote - merged Pewter Pokecenter and Mart
	object_const_def
	; Pokecenter
	const_export PEWTERPOKECENTER_NURSE
	const_export PEWTERPOKECENTER_GENTLEMAN
	const_export PEWTERPOKECENTER_JIGGLYPUFF
	const_export PEWTERPOKECENTER_LINK_RECEPTIONIST
	const_export PEWTERPOKECENTER_BENCH_GUY ; marcelnote - BenchGuy has a sprite
	; Mart
	const_export PEWTERMART_CLERK
	const_export PEWTERMART_YOUNGSTER
	const_export PEWTERMART_SUPER_NERD

PewterPokecenterMart_Object:
	db $0 ; border block

	def_warp_events
	; Pokecenter
	warp_event  3,  7, LAST_MAP, 7
	warp_event  4,  7, LAST_MAP, 7
	; Mart
	warp_event 19,  7, LAST_MAP, 5
	warp_event 20,  7, LAST_MAP, 5

	def_bg_events

	def_object_events
	; Pokecenter
	object_event  3,  1, SPRITE_NURSE, STAY, DOWN, TEXT_PEWTERPOKECENTER_NURSE
	object_event  8,  7, SPRITE_GENTLEMAN, STAY, LEFT, TEXT_PEWTERPOKECENTER_GENTLEMAN
	object_event  1,  3, SPRITE_FAIRY, STAY, DOWN, TEXT_PEWTERPOKECENTER_JIGGLYPUFF
	object_event  8,  2, SPRITE_LINK_RECEPTIONIST, STAY, DOWN, TEXT_PEWTERPOKECENTER_LINK_RECEPTIONIST
	object_event  0,  5, SPRITE_BENCH_GUY, STAY, RIGHT, TEXT_PEWTERPOKECENTER_BENCH_GUY ; marcelnote - BenchGuy has a sprite
	; Mart
	object_event 16,  5, SPRITE_CLERK, STAY, RIGHT, TEXT_PEWTERMART_CLERK
	object_event 19,  3, SPRITE_YOUNGSTER, WALK, UP_DOWN, TEXT_PEWTERMART_YOUNGSTER
	object_event 21,  5, SPRITE_SUPER_NERD, STAY, NONE, TEXT_PEWTERMART_SUPER_NERD

	def_warps_to PEWTER_POKECENTER_MART
