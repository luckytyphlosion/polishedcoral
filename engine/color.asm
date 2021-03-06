;INCLUDE "engine/vary_colors.asm"

INCLUDE "engine/cgb.asm"

CheckShininess:
; Check if a mon is shiny by personality at bc.
; Return carry if shiny.
	ld a, [bc]
	and SHINY_MASK
	jr z, .NotShiny
	scf
	ret

.NotShiny:
	and a
	ret

InitPartyMenuPalettes:
	ld de, wUnknBGPals
	ld hl, PartyMenuBGPals
rept 4
	call LoadHLPaletteIntoDE
endr
	call InitPartyMenuOBPals
	jp WipeAttrMap

ApplyHPBarPals:
	ld a, [wWhichHPBar]
	and a
	jr z, .Enemy
	cp $1
	jr z, .Player
	cp $2
	jr z, .PartyMenu
	ret

.Enemy:
	ld de, wBGPals palette PAL_BATTLE_BG_PLAYER_HP + 2
	jr .okay

.Player:
	ld de, wBGPals palette PAL_BATTLE_BG_ENEMY_HP + 2

.okay
	ld l, c
	ld h, $0
	add hl, hl
	add hl, hl
	ld bc, HPBarInteriorPals
	add hl, bc
	ld bc, 4
	ld a, $5
	call FarCopyWRAM
	ld a, $1
	ld [hCGBPalUpdate], a
	ret

.PartyMenu:
	ld e, c
	inc e
	hlcoord 11, 1, wAttrMap
	ld bc, 2 * SCREEN_WIDTH
	ld a, [wCurPartyMon]
.loop
	and a
	jr z, .done
	add hl, bc
	dec a
	jr .loop

.done
	lb bc, 2, 8
	ld a, e
	jp FillBoxCGB

LoadPlayerStatusIconPalette:
	ld a, [wPlayerSubStatus2]
	ld de, wBattleMonStatus
	farcall GetStatusConditionIndex
	ld hl, StatusIconPals
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld de, wUnknBGPals palette PAL_BATTLE_BG_STATUS + 2
	ld bc, 2
	ld a, $5
	jp FarCopyWRAM

LoadEnemyStatusIconPalette:
	ld a, [wEnemySubStatus2]
	ld de, wEnemyMonStatus
	farcall GetStatusConditionIndex
	ld hl, StatusIconPals
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld de, wUnknBGPals palette PAL_BATTLE_BG_STATUS + 4
	ld bc, 2
	ld a, $5
	jp FarCopyWRAM

LoadBattleCategoryAndTypePals:
	ld a, [wPlayerMoveStruct + MOVE_CATEGORY]
	ld b, a
	ld a, [wPlayerMoveStruct + MOVE_TYPE]
	ld c, a
	ld de, wUnknBGPals palette PAL_BATTLE_BG_TYPE_CAT + 2
LoadCategoryAndTypePals:
	ld hl, CategoryIconPals
	ld a, b
	add a
	add a
	push bc
	ld c, a
	ld b, 0
	add hl, bc
	ld bc, 4
	ld a, $5
	push de
	call FarCopyWRAM
	pop de

	ld hl, TypeIconPals
	pop bc
	ld a, c

	farcall MultiSlotMoveTypes

	add a
	ld c, a
	ld b, 0
	add hl, bc
	inc de
	inc de
	inc de
	inc de
	ld bc, 2
	ld a, $5
	jp FarCopyWRAM
	
	
LoadItemIconPalette:
	ld a, [wCurSpecies]
	ld bc, ItemIconPalettes
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, bc
	ld de, wUnknBGPals palette 7 + 2
	ld bc, 4
	ld a, $5
	call FarCopyWRAM
	ld hl, BlackPalette
	ld bc, 2
	ld a, $5
	jp FarCopyWRAM

LoadTMHMIconPalette:
	ld a, [wCurTMHM]
	dec a
	ld hl, TMHMTypes
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld hl, TMHMTypeIconPals
	ld c, a
	ld b, 0
rept 4
	add hl, bc
endr
	ld de, wUnknBGPals palette 7 + 2
	ld bc, 4
	ld a, $5
	call FarCopyWRAM
	ld hl, BlackPalette
	ld bc, 2
	ld a, $5
	jp FarCopyWRAM

LoadStatsScreenPals:
	ld hl, StatsScreenPagePals
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a
	ld a, [hli]
	ld [wUnknBGPals palette 0], a
	ld [wUnknBGPals palette 2], a
	ld a, [hl]
	ld [wUnknBGPals palette 0 + 1], a
	ld [wUnknBGPals palette 2 + 1], a
	pop af
	ld [rSVBK], a
	call ApplyPals
	ld a, $1
	ret

LoadMailPalettes:
	ld l, e
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, MailPals
	add hl, de
	ld de, wUnknBGPals
	ld bc, 1 palettes
	ld a, $5
	call FarCopyWRAM
	call ApplyPals
	call WipeAttrMap
	jp ApplyAttrMap

LoadHLPaletteIntoDE:
	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a
	ld c, $8
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	pop af
	ld [rSVBK], a
	ret

LoadPalette_White_Col1_Col2_Black:
	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a

if !DEF(MONOCHROME)
	ld a, (palred 31 + palgreen 31 + palblue 31) % $100
	ld [de], a
	inc de
	ld a, (palred 31 + palgreen 31 + palblue 31) / $100
	ld [de], a
	inc de
else
	ld a, PAL_MONOCHROME_WHITE % $100
	ld [de], a
	inc de
	ld a, PAL_MONOCHROME_WHITE / $100
	ld [de], a
	inc de
endc

	ld c, 2 * 2
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop

if !DEF(MONOCHROME)
	xor a ; RGB 00, 00, 00
rept 2
	ld [de], a
	inc de
endr
else
	ld a, PAL_MONOCHROME_BLACK % $100
	ld [de], a
	inc de
	ld a, PAL_MONOCHROME_BLACK / $100
	ld [de], a
	inc de
endc

	pop af
	ld [rSVBK], a
	ret

FillBoxCGB:
.row
	push bc
	push hl
.col
	ld [hli], a
	dec c
	jr nz, .col
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .row
	ret

ResetBGPals:
	push af
	push bc
	push de
	push hl

	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a

	ld hl, wUnknBGPals
	ld c, 8
.loop
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec c
	jr nz, .loop

	pop af
	ld [rSVBK], a

	pop hl
	pop de
	pop bc
	pop af
	ret

Reset7BGPals:
	push af
	push bc
	push de
	push hl

	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a

	ld hl, wUnknBGPals
	ld c, 7
.loop
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec c
	jr nz, .loop

	pop af
	ld [rSVBK], a

	pop hl
	pop de
	pop bc
	pop af
	ret
	
WipeAttrMap:
	hlcoord 0, 0, wAttrMap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	xor a
	jp ByteFill

ApplyPals:
	ld hl, wUnknBGPals
	ld de, wBGPals
	ld bc, 16 palettes
	ld a, $5
	jp FarCopyWRAM

ApplyAttrMap:
	ld a, [rLCDC]
	bit 7, a
	jr nz, ApplyAttrMapVBank0
	hlcoord 0, 0, wAttrMap
	debgcoord 0, 0
	ld b, SCREEN_HEIGHT
	ld a, 1
	ld [rVBK], a
.row
	ld c, SCREEN_WIDTH
.col
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .col
	ld a, BG_MAP_WIDTH - SCREEN_WIDTH
	add e
	jr nc, .okay
	inc d
.okay
	ld e, a
	dec b
	jr nz, .row
	xor a
	ld [rVBK], a
	ret

ApplyAttrMapVBank0::
	ld a, [hBGMapMode]
	push af
	ld a, 2
	ld [hBGMapMode], a
	call Delay2
	pop af
	ld [hBGMapMode], a
	ret

ApplyPartyMenuHPPals: ; 96f3
	ld hl, wHPPals
	ld a, [wHPPalIndex]
	ld e, a
	ld d, $0
	add hl, de
	ld e, l
	ld d, h
	ld a, [de]
	inc a
	ld e, a
	hlcoord 11, 2, wAttrMap
	ld bc, 2 * SCREEN_WIDTH
	ld a, [wHPPalIndex]
.loop
	and a
	jr z, .done
	add hl, bc
	dec a
	jr .loop
.done
	lb bc, 2, 8
	ld a, e
	jp FillBoxCGB

InitPartyMenuOBPals:
	ld hl, PartyMenuOBPals
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5
	jp FarCopyWRAM

InitPokegearPalettes:
; This is needed because the regular palette is dark at night.
	ld hl, PokegearOBPals
	ld de, wUnknOBPals
	ld bc, 2 palettes
	ld a, $5
	jp FarCopyWRAM

GetBattlemonBackpicPalettePointer:
	push de
	farcall GetPartyMonPersonality
	ld c, l
	ld b, h
	ld a, [wTempBattleMonSpecies]
	call GetPlayerOrMonPalettePointer
	pop de
	ret

GetEnemyFrontpicPalettePointer:
	push de
	farcall GetEnemyMonPersonality
	ld c, l
	ld b, h
	ld a, [wTempEnemyMonSpecies]
	call GetFrontpicPalettePointer
	pop de
	ret

GetPlayerOrMonPalettePointer:
	and a
	jp nz, GetMonNormalOrShinyPalettePointer
	dec a
	
	ld a, [wPlayerGender]
	cp PIPPI
	jr z, .pippi
	ld a, [wPlayerPalette]
	cp $0
	jp nz, .cont1
	ld hl, PlayerPalette
	ret

.cont1
	ld a, [wPlayerPalette]
	sub $1
	jp nz, .cont2
	ld hl, PlayerPalette2
	ret
	
.cont2
	ld a, [wPlayerPalette]
	sub $2
	jp nz, .cont3
	ld hl, PlayerPalette3
	ret

.cont3
	ld a, [wPlayerPalette]
	sub $3
	jp nz, .cont4
	ld hl, PlayerPalette4
	ret
	
.cont4
	ld a, [wPlayerPalette]
	sub $4
	jp nz, .cont5
	ld hl, PlayerPalette5
	ret
	
.cont5
	ld a, [wPlayerPalette]
	sub $5
	jp nz, .cont6
	ld hl, PlayerPalette6
	ret
	
.cont6
	ld hl, PlayerPalette7
	ret
	
.pippi
	ld hl, ClefairyPalette
	ret

GetFrontpicPalettePointer:
	and a
	jr nz, GetMonNormalOrShinyPalettePointer
	ld a, [wTrainerClass]

GetTrainerPalettePointer:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld bc, TrainerPalettes
	add hl, bc
	ret

GetPaintingPalettePointer:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, PaintingPalettes
	add hl, bc
	ret

GetMonPalettePointer:
	ld l, a
	ld h, $0
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, PokemonPalettes
	add hl, bc
	ret

GetMonNormalOrShinyPalettePointer:
	push bc
	call GetMonPalettePointer
	pop bc
	push hl
	call CheckShininess
	pop hl
	ret nc
rept 4
	inc hl
endr
	ret

LoadPokemonPalette:
	; a = species
	ld a, [wCurPartySpecies]
	; hl = palette
	call GetMonPalettePointer
	; load palette in BG 7
	ld a, $5
	ld de, wUnknBGPals palette 7 + 2
	ld bc, 4
	jp FarCopyWRAM

LoadPartyMonPalette:
	; bc = personality
	ld hl, wPartyMon1Personality
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld c, l
	ld b, h
	; a = species
	ld a, [wCurPartySpecies]
	; hl = palette
	call GetMonNormalOrShinyPalettePointer
	; load palette in BG 7
	ld a, $5
	ld de, wUnknBGPals palette PAL_BG_TEXT + 2
	ld bc, 4
	call FarCopyWRAM
	; hl = DVs
;	ld hl, wPartyMon1DVs
;	ld a, [wCurPartyMon]
;	call GetPartyLocation
	; b = species
;	ld a, [wCurPartySpecies]
;	ld b, a
	; vary colors by DVs
;	call CopyDVsToColorVaryDVs
;	ld hl, wUnknBGPals palette PAL_BG_TEXT + 2
;	jp VaryColorsByDVs

LoadTrainerPalette:
	; a = class
	ld a, [wTrainerClass]
	; hl = palette
	call GetTrainerPalettePointer
	; load palette in BG 7
	ld a, $5
	ld de, wUnknBGPals palette PAL_BG_TEXT + 2
	ld bc, 4
	jp FarCopyWRAM

LoadPaintingPalette:
	; a = class
	ld a, [wTrainerClass]
	; hl = palette
	call GetPaintingPalettePointer
	; load palette in BG 7
	ld a, $5
	ld de, wUnknBGPals palette PAL_BG_TEXT
	ld bc, 8
	jp FarCopyWRAM

InitCGBPals::
	ld a, $1
	ld [rVBK], a
	ld hl, VTiles0
	ld bc, $200 tiles
	xor a
	call ByteFill
	xor a
	ld [rVBK], a
	ld a, $80
	ld [rBGPI], a
	ld c, 4 * 8
.bgpals_loop
if !DEF(MONOCHROME)
	ld a, (palred 31 + palgreen 31 + palblue 31) % $100
	ld [rBGPD], a
	ld a, (palred 31 + palgreen 31 + palblue 31) / $100
	ld [rBGPD], a
else
	ld a, PAL_MONOCHROME_WHITE % $100
	ld [rBGPD], a
	ld a, PAL_MONOCHROME_WHITE / $100
	ld [rBGPD], a
endc
	dec c
	jr nz, .bgpals_loop
	ld a, $80
	ld [rOBPI], a
	ld c, 4 * 8
.obpals_loop
if !DEF(MONOCHROME)
	ld a, (palred 31 + palgreen 31 + palblue 31) % $100
	ld [rOBPD], a
	ld a, (palred 31 + palgreen 31 + palblue 31) / $100
	ld [rOBPD], a
else
	ld a, PAL_MONOCHROME_WHITE % $100
	ld [rOBPD], a
	ld a, PAL_MONOCHROME_WHITE / $100
	ld [rOBPD], a
endc
	dec c
	jr nz, .obpals_loop
	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a
	ld hl, wUnknBGPals
	call .LoadWhitePals
	ld hl, wBGPals
	call .LoadWhitePals
	pop af
	ld [rSVBK], a
	ret

.LoadWhitePals:
	ld c, 4 * 16
.loop
if !DEF(MONOCHROME)
	ld a, (palred 31 + palgreen 31 + palblue 31) % $100
	ld [hli], a
	ld a, (palred 31 + palgreen 31 + palblue 31) / $100
	ld [hli], a
else
	ld a, PAL_MONOCHROME_WHITE % $100
	ld [hli], a
	ld a, PAL_MONOCHROME_WHITE / $100
	ld [hli], a
endc
	dec c
	jr nz, .loop
	ret

CopyData: ; 0x9a52
; copy bc bytes of data from hl to de
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, CopyData
	ret
; 0x9a5b

ClearBytes: ; 0x9a5b
; clear bc bytes of data starting from de
	xor a
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, ClearBytes
	ret
; 0x9a64

LoadMapPals:
	farcall LoadSpecialMapPalette
	jr c, .got_pals

	; Which palette group is based on whether we're outside or inside
	ld a, [wPermission]
	and 7
	ld e, a
	ld d, 0
	ld hl, .TilesetColorsPointers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	; Futher refine by time of day
	ld a, [wTimeOfDayPal]
	and 3
	add a
	add a
	add a
	ld e, a
	ld d, 0
	add hl, de
	ld e, l
	ld d, h
	; Switch to palettes WRAM bank
	ld a, [rSVBK]
	push af
	ld a, $5
	ld [rSVBK], a
	ld hl, wUnknBGPals
	ld b, 7
.outer_loop
	ld a, [de] ; lookup index for TilesetBGPalette
	push de
	push hl
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, TilesetBGPalette
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld c, 1 palettes
.inner_loop
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .inner_loop
	pop de
	inc de
	dec b
	jr nz, .outer_loop
	pop af
	ld [rSVBK], a

.got_pals
	ld a, [wMapGroup]
	cp GROUP_LAKE_ONWA
	jp z, .rockscheck1
	cp GROUP_ROUTE_3_EAST
	jp z, .rockscheck2
	cp GROUP_SUNBEAM_ISLAND
	jp z, .umbrellacheck
	cp GROUP_SUNSET_BAY
	jp z, .sailboat
	cp GROUP_SKATEPARK
	jp z, .skateparkcheck
.got_pals_cont
	ld a, [wTileset]
	cp TILESET_CAVE
	jp z, .rocks
	cp TILESET_STARGLOW_CAVERN
	jp z, .starglow
	cp TILESET_RANCH
	jp z, .ranch
	cp TILESET_SNOW
	jp z, .snow
	cp TILESET_LUSTER
	jp z, .luster
	cp TILESET_MALL_1
	jp z, .lustermall
	cp TILESET_SEWER
	jp z, .sewer
	cp TILESET_ICE_CAVE
	jp z, .ice_cave
	cp TILESET_PLAYER_HOUSE
	jp z, .playerhouse
	jp .normal
.playerhouse
	ld a, [wMapGroup]
	cp GROUP_TWINKLE_GYM_ENTRY
	jp nz, .normal
	ld a, [wMapNumber]
	cp MAP_TWINKLE_GYM_BLUE_ROOM
	jr z, .blue_room
	cp MAP_TWINKLE_GYM_YELLOW_ROOM
	jr z, .yellow_room
	cp MAP_TWINKLE_GYM_RED_ROOM
	jr z, .red_room
	jp .normal
.blue_room
	eventflagcheck EVENT_BLUE_ROOM_STEAM_1
	jr nz, .steam1
	eventflagcheck EVENT_BLUE_ROOM_STEAM_2
	jr nz, .steam2
	eventflagcheck EVENT_BLUE_ROOM_STEAM_3
	jr nz, .steam3
	jp .normal
.yellow_room
	eventflagcheck EVENT_YELLOW_ROOM_STEAM_1
	jr nz, .steam1
	eventflagcheck EVENT_YELLOW_ROOM_STEAM_2
	jr nz, .steam2
	eventflagcheck EVENT_YELLOW_ROOM_STEAM_3
	jr nz, .steam3
	jp .normal
.red_room
	eventflagcheck EVENT_RED_ROOM_STEAM_1
	jr nz, .steam1
	eventflagcheck EVENT_RED_ROOM_STEAM_2
	jr nz, .steam2
	eventflagcheck EVENT_RED_ROOM_STEAM_3
	jr nz, .steam3
	jp .normal
.steam1
	ld hl, MapObjectPalsTwinkleGym1
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
.steam2
	ld hl, MapObjectPalsTwinkleGym2
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
.steam3
	ld hl, MapObjectPalsTwinkleGym3
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
.ice_cave
	ld a, [wPlayerPalette]
	cp 4
	jr z, .ice_cave_purple
	eventflagcheck EVENT_TORCH_LIT
	jr nz, .torch
	jr .ice_cave_cont
.torch
	ld a, 1
.ice_cave_cont
	and 3
	ld bc, 8 palettes
	eventflagcheck EVENT_MAMOSWINE_CUTSCENE
	jr z, .not_mamo
	ld hl, MapObjectPalsIceCave2
	jr .ice_cave_cont2
.not_mamo
	ld hl, MapObjectPalsIceCave
.ice_cave_cont2
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.ice_cave_purple
	eventflagcheck EVENT_TORCH_LIT
	jr nz, .torch_purple
	jr .ice_cave_purple_cont
.torch_purple
	ld a, 1
.ice_cave_purple_cont
	and 3
	ld bc, 8 palettes
	eventflagcheck EVENT_MAMOSWINE_CUTSCENE
	jr z, .not_mamo_purple
	ld hl, MapObjectPalsIceCavePurple2
	jr .ice_cave_purple_cont2
.not_mamo_purple
	ld hl, MapObjectPalsIceCavePurple
.ice_cave_purple_cont2
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.sewer
	ld a, [wMapNumber]
	cp MAP_LUSTER_SEWERS_B1F
	jp z, .rocks
	cp MAP_LUSTER_SEWERS_B2F
	jp z, .rocks
	ld hl, MapObjectPalsSewer
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
.umbrellacheck
	ld a, [wMapNumber]
	cp MAP_SUNBEAM_BEACH
	jp nz, .normal
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsUmbrella
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jp .outside
.rockscheck1
	ld a, [wMapNumber]
	cp MAP_LAKE_ONWA
	jp nz, .got_pals_cont
	jr .rocks
.rockscheck2
	ld a, [wMapNumber]
	cp MAP_ROUTE_3_EAST
	jp nz, .got_pals_cont
.rocks
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsRocks
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ld a, [wPermission]
	cp FOREST
	jp z, .outside
	cp TOWN
	jp z, .outside
	cp ROUTE
	jp z, .outside
	ret
.starglow
	ld hl, MapObjectPalsStarglow
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
.ranch
	ld a, [wMapNumber]
	cp MAP_ROUTE_9
	jr z, .ranchcont
	cp MAP_DODRIO_RANCH_RACETRACK
	jr z, .ranchcont
	jp .hangar
.ranchcont
	ld a, [wTimeOfDayPalFlags]
	and $3F
	cp 1
	jr z, .ranchyellow
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsRanch
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jp .outside
.ranchyellow
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsRanchYellow
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jp .outside
	
.hangar
	ld a, [wPlayerPalette]
	cp 4
	jr z, .hangar2
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsHangar
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jp .outside
	
.hangar2
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsHangarPurple
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jp .outside
	
.luster
	ld a, [wIsNearCampfire]
	bit 0, a
	jr nz, .lustercont1
	ld a, [wTimeOfDayPal]
	jr .lustercont2
.lustercont1
	ld a, 1
.lustercont2
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsLuster
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jp .outside
	
.snow
	ld a, [wPlayerPalette]
	cp 3
	jr z, .snowbrown
	eventflagcheck EVENT_SNOWSTORM_HAPPENING
	jr nz, .snowstorm
	ld a, [wIsNearCampfire]
	bit 0, a
	jr nz, .snowcont1
	ld a, [wTimeOfDayPal]
	jr .snowcont2
.snowcont1
	ld a, 1
.snowcont2
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsSnow
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.snowbrown
	eventflagcheck EVENT_SNOWSTORM_HAPPENING
	jr nz, .snowstormbrown
	ld a, [wIsNearCampfire]
	bit 0, a
	jr nz, .snowbrowncont1
	ld a, [wTimeOfDayPal]
	jr .snowbrowncont2
.snowbrowncont1
	ld a, 1
.snowbrowncont2
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsSnowBrown
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.snowstorm
	ld a, [wIsNearCampfire]
	bit 0, a
	jr nz, .snowstormcont1
	ld a, [wTimeOfDayPal]
	jr .snowstormcont2
.snowstormcont1
	ld a, 1
.snowstormcont2
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsSnowstorm
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.snowstormbrown
	ld a, [wIsNearCampfire]
	bit 0, a
	jr nz, .snowstormbrowncont1
	ld a, [wTimeOfDayPal]
	jr .snowstormbrowncont2
.snowstormbrowncont1
	ld a, 1
.snowstormbrowncont2
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsSnowstormBrown
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.lustermall
	ld hl, MapObjectPalsLusterMall
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ret
	
.skateparkcheck
	ld a, [wMapNumber]
	cp MAP_SKATEPARK
	jp nz, .got_pals_cont
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsSkatepark
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jr .outside
	
.sailboat
	ld a, [wMapNumber]
	cp MAP_SUNSET_BAY
	jr z, .sailboatcont
	cp MAP_SUNSET_CAPE
	jr z, .lighthouse
	jr .normal
	
.sailboatcont
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsSailboat
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jr .outside
	
.lighthouse
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPalsLighthouse
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	jr .outside

.normal
	ld a, [wTimeOfDayPal]
	and 3
	ld bc, 8 palettes
	ld hl, MapObjectPals
	call AddNTimes
	ld de, wUnknOBPals
	ld bc, 8 palettes
	ld a, $5 ; BANK(UnknOBPals)
	call FarCopyWRAM
	ld a, [wTileset]
	cp TILESET_SPOOKY
	jr z, .outside
	ld a, [wPermission]
	cp FOREST
	jr z, .outside
	cp TOWN
	jr z, .outside
	cp ROUTE
	ret nz
.outside
	ld a, [wTileset]
	cp TILESET_GROVE
	ret z
	cp TILESET_MOUNTAIN
	ret z
	cp TILESET_SNOW
	ret z
	cp TILESET_PARK
	ret z
	
	ld a, [wTimeOfDayPal]
	and 3
	cp DUSK
	jr z, .dusk
	ld a, [wMapGroup]
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, RoofPals
	add hl, de
	jr .controof	
.dusk
	ld a, [wMapGroup]
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, RoofPalsDusk
	add hl, de
	jr .morn_day
.controof
	ld a, [wTimeOfDayPal]
	and 3
	cp NITE
	jr c, .morn_day
rept 4
	inc hl
endr
.morn_day
	ld de, wUnknBGPals + 6 palettes + 2
	ld bc, 4
	ld a, $5
	call FarCopyWRAM
	ret

.TilesetColorsPointers:
	dw .OutdoorColors ; unused
	dw .OutdoorColors ; TOWN
	dw .OutdoorColors ; ROUTE
	dw .IndoorColors ; INDOOR
	dw .DungeonColors ; CAVE
	dw .Perm5Colors ; PERM_5
	dw .IndoorColors ; GATE
	dw .DungeonColors ; DUNGEON
	dw .OutdoorColors ; FOREST

; Valid indices: $00 - $29
.OutdoorColors:
	db $00, $01, $02, $03, $04, $05, $06, $07 ; morn
	db $08, $09, $0a, $0b, $0c, $0d, $0e, $0f ; day
	db $10, $11, $12, $13, $14, $15, $16, $17 ; nite
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f ; dark

.IndoorColors:
	db $20, $21, $22, $23, $24, $25, $26, $07 ; morn
	db $20, $21, $22, $23, $24, $25, $26, $07 ; day
	db $10, $11, $12, $13, $14, $15, $16, $07 ; nite
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $07 ; dark

.DungeonColors:
	db $00, $01, $02, $03, $04, $05, $06, $07 ; morn
	db $20, $21, $22, $23, $24, $25, $26, $07 ; day
	db $10, $11, $12, $13, $14, $15, $16, $17 ; nite
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f ; dark

.Perm5Colors:
	db $00, $01, $02, $03, $04, $05, $06, $07 ; morn
	db $08, $09, $0a, $0b, $0c, $0d, $0e, $0f ; day
	db $10, $11, $12, $13, $14, $15, $16, $17 ; nite
	db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f ; dark

Palette_b309: ; b309 mobile
	RGB 31, 31, 31
	RGB 31, 19, 24
	RGB 30, 10, 06
	RGB 00, 00, 00

Palette_b311: ; b311 not mobile
	RGB 31, 31, 31
	RGB 17, 19, 31
	RGB 14, 16, 31
	RGB 00, 00, 00

TilesetBGPalette:
INCLUDE "maps/palettes/bgpals/bg.pal"

MapObjectPals::
INCLUDE "maps/palettes/obpals/ob.pal"

MapObjectPalsRocks::
INCLUDE "maps/palettes/obpals/obrocks.pal"

MapObjectPalsUmbrella::
INCLUDE "maps/palettes/obpals/obumbrella.pal"

MapObjectPalsStarglow::
INCLUDE "maps/palettes/obpals/obstarglow.pal"

MapObjectPalsIceCave::
INCLUDE "maps/palettes/obpals/obicecave.pal"

MapObjectPalsIceCave2::
INCLUDE "maps/palettes/obpals/obicecave2.pal"

MapObjectPalsIceCavePurple::
INCLUDE "maps/palettes/obpals/obicecavepurple.pal"

MapObjectPalsIceCavePurple2::
INCLUDE "maps/palettes/obpals/obicecavepurple2.pal"

MapObjectPalsTwinkleGym1:
INCLUDE "maps/palettes/obpals/obtwinklegym1.pal"

MapObjectPalsTwinkleGym2:
INCLUDE "maps/palettes/obpals/obtwinklegym2.pal"

MapObjectPalsTwinkleGym3:
INCLUDE "maps/palettes/obpals/obtwinklegym3.pal"

MapObjectPalsSewer::
INCLUDE "maps/palettes/obpals/obsewer.pal"

MapObjectPalsRanch:
INCLUDE "maps/palettes/obpals/obranch.pal"

MapObjectPalsRanchYellow::
INCLUDE "maps/palettes/obpals/obranchyellow.pal"

MapObjectPalsHangar::
INCLUDE "maps/palettes/obpals/obranchhangar.pal"

MapObjectPalsHangarPurple::
INCLUDE "maps/palettes/obpals/obranchhangarpurple.pal"

MapObjectPalsSnow::
INCLUDE "maps/palettes/obpals/obsnow.pal"

MapObjectPalsSnowBrown::
INCLUDE "maps/palettes/obpals/obsnowbrown.pal"

MapObjectPalsSnowstorm::
INCLUDE "maps/palettes/obpals/obsnowstorm.pal"

MapObjectPalsSnowstormBrown::
INCLUDE "maps/palettes/obpals/obsnowstormbrown.pal"

MapObjectPalsSailboat::
INCLUDE "maps/palettes/obpals/obsailboat.pal"

MapObjectPalsLighthouse::
INCLUDE "maps/palettes/obpals/oblighthouse.pal"

MapObjectPalsSkatepark::
INCLUDE "maps/palettes/obpals/obskatepark.pal"

MapObjectPalsLuster::
INCLUDE "maps/palettes/obpals/obluster.pal"

MapObjectPalsLusterMall::
INCLUDE "maps/palettes/obpals/oblustermall.pal"

RoofPals::
INCLUDE "maps/palettes/roofpals/roof.pal"

RoofPalsDusk::
INCLUDE "maps/palettes/roofpals/roofdusk.pal"


INCLUDE "data/pokemon/palettes.asm"

INCLUDE "data/trainers/palettes.asm"

INCLUDE "data/events/paintings/palettes.asm"

INCLUDE "engine/palettes.asm"
