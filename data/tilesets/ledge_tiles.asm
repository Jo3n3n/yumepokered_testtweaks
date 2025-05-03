LedgeTiles:
	; player direction, tile player standing on, ledge tile, input required
	db SPRITE_FACING_DOWN,  $2C, $37, D_DOWN
	db SPRITE_FACING_DOWN,  $39, $36, D_DOWN
	db SPRITE_FACING_DOWN,  $39, $37, D_DOWN
	db SPRITE_FACING_LEFT,  $2C, $27, D_LEFT
	db SPRITE_FACING_LEFT,  $39, $27, D_LEFT
	db SPRITE_FACING_RIGHT, $2C, $0D, D_RIGHT
	db SPRITE_FACING_RIGHT, $39, $0D, D_RIGHT
	;db SPRITE_FACING_RIGHT, $2C, $1D, D_RIGHT ; marcelnote - freed tile
	db -1 ; end

LedgeTilesCavern: ; marcelnote - new for Cavern ledges
	; player direction, tile player standing on, ledge tile, input required
	db SPRITE_FACING_DOWN,  $20, $43, D_DOWN
	db SPRITE_FACING_LEFT,  $20, $42, D_LEFT
	db SPRITE_FACING_RIGHT, $20, $47, D_RIGHT
	db -1 ; end
