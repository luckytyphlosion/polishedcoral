SpookyForest1_MapScriptHeader:
	db 0 ; scene scripts

	db 0 ; callbacks

	db 0 ; warp events

	db 0 ; coord events

	db 1 ; bg events
	signpost 10, 7, SIGNPOST_READ, SpookyForest1Sign

	db 0 ; object events

SpookyForest1Sign:
	jumptext SpookyForest1SignText
	
SpookyForest1SignText:
	text "BEWARE!"
	
	para "If you don't want"
	line "to get lost,"
	
	para "you must pay"
	line "very close atten-"
	cont "tion to your"
	cont "surroundings."
	
	para "Watch carefully"
	line "for clues."
	done