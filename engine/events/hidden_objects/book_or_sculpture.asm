BookOrSculptureText::
	text_asm
	ld hl, PokemonBooksText
	ld a, [wCurMapTileset]
	cp MANSION ; Celadon Mansion tileset
	jr nz, .ok
	lda_coord 8, 6
	cp $38
	jr nz, .ok
	ld hl, DiglettSculptureText
.ok
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

PokemonBooksText:
	text_far _PokemonBooksText
	text_end

DiglettSculptureText:
	text_far _DiglettSculptureText
	text_end
