EventidePokeCenter_MapScriptHeader:
	db 0 ; scene scripts

	db 0 ; callbacks

	db 2 ; warp events
	warp_event  4,  7, EVENTIDE_VILLAGE, 3
	warp_event  5,  7, EVENTIDE_VILLAGE, 3

	db 0 ; coord events

	db 0 ; bg events

	db 1 ; object events
	pc_nurse_event  4, 1
