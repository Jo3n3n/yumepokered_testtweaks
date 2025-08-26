; marcelnote - new list to determine Physical / Special types
SpecialTypesList:
	db FALSE     ; $00 ; NORMAL to TRUE
	db FALSE     ; $01 ; FIGHTING
	db TRUE      ; $02 ; FLYING to TRUE
	db FALSE     ; $03 ; POISON
	db FALSE     ; $04 ; GROUND
	db FALSE     ; $05 ; ROCK
	db FALSE     ; $06 ; BIRD
	db FALSE     ; $07 ; BUG
	db TRUE      ; $08 ; GHOST
	db FALSE     ; $09 ; unused type
	db FALSE     ; $0A ; unused type
	db FALSE     ; $0B ; unused type
	db FALSE     ; $0C ; unused type
	db FALSE     ; $0D ; unused type
	db FALSE     ; $0E ; unused type
	db FALSE     ; $0F ; unused type
	db FALSE     ; $10 ; unused type
	db FALSE     ; $11 ; unused type
	db FALSE     ; $12 ; unused type
	db TRUE      ; $13 ; Added NORMAL_SPC
	db TRUE      ; $14 ; FIRE
	db FALSE     ; $15 ; WATER to FALSE
	db FALSE     ; $16 ; GRASS to FALSE
	db TRUE      ; $17 ; ELECTRIC
	db TRUE      ; $18 ; PSYCHIC_TYPE
	db FALSE     ; $19 ; ICE to FALSE
	db FALSE     ; $1A ; DRAGON
	db -1 ; end
