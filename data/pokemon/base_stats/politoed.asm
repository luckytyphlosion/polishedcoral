if DEF(FAITHFUL)
	db  90,  75,  75,  70,  90, 100
	;   hp  atk  def  spd  sat  sdf
else
	db  90,  75,  80,  80,  90, 100
	;   hp  atk  def  spd  sat  sdf
endc

if DEF(FAITHFUL)
	db WATER, WATER
else
	db WATER, GRASS
endc
	db 45 ; catch rate
	db 185 ; base exp
	db NO_ITEM ; item 1
	db KINGS_ROCK ; item 2
	dn FEMALE_50, 3 ; gender, step cycles to hatch
	dn 7, 7 ; frontpic dimensions
	db WATER_ABSORB ; ability 1
	db DAMP ; ability 2
	db DRIZZLE ; hidden ability
	db MEDIUM_SLOW ; growth rate
	dn AMPHIBIAN, AMPHIBIAN ; egg groups

	; ev_yield
	ev_yield   0,   0,   0,   0,   0,   3
	;         hp, atk, def, spd, sat, sdf

	; tmhm
	tmhm 
	; end
