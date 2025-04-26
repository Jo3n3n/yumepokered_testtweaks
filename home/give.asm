GiveItem::
; Give player quantity c of item b,
; and copy the item's name to wStringBuffer.
; Return carry on success.
	ld a, b
	ld [wNamedObjectIndex], a
	ld [wCurItem], a
	ld a, c
	ld [wItemQuantity], a
	ld hl, wNumBagItems
	;;;;;;;;;; marcelnote - new for bag pockets
	call IsKeyItem ; b already loaded in [wCurItem]
	ld a, [wIsKeyItem]
	and a
	jr z, .notKeyItem
	ld hl, wNumBagKeyItems
.notKeyItem
	;;;;;;;;;;
	call AddItemToInventory
	ret nc
	call GetItemName ; stores name at de -> wNameBuffer
	call CopyToStringBuffer
	scf
	ret

GivePokemon::
; Give the player monster b at level c.
	ld a, b
	ld [wCurPartySpecies], a
	ld a, c
	ld [wCurEnemyLevel], a
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	farjp _GivePokemon
