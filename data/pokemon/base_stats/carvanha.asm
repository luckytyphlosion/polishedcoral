	db  45,  90,  20,  65,  65,  20
	;   hp  atk  def  spd  sat  sdf

	db WATER, DARK
	db 225 ; catch rate
	db  88 ; base exp
	db NO_ITEM ; item 1
	db NO_ITEM ; item 2
	dn FEMALE_50, 3 ; gender, step cycles to hatch
	dn 5, 5 ; frontpic dimensions
	db NO_ABILITY ;ROUGH_SKIN ; ability 1
	db NO_ABILITY ;ROUGH_SKIN ; ability 2
	db SPEED_BOOST ; hidden ability
	db SLOW ; growth rate
	dn FISH, FISH ; egg groups

	; ev_yield
	ev_yield   0,   1,   0,   0,   0,   0
	;         hp, atk, def, spd, sat, sdf

	; tmhm
	tmhm 
	; end
