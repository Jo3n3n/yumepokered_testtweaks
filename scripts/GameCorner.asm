GameCorner_Script:
	call GameCornerSelectLuckySlotMachine
	call GameCornerSetRocketHideoutDoorTile
	call EnableAutoTextBoxDrawing
	ld hl, GameCorner_ScriptPointers
	ld a, [wGameCornerCurScript]
	jp CallFunctionInTable

GameCornerSelectLuckySlotMachine:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_2, [hl]
	res BIT_CUR_MAP_LOADED_2, [hl]
	ret z
	call Random
	ldh a, [hRandomAdd]
	cp $8 ; marcelnote - fixed from 7
	jr nc, .not_max
	ld a, $8
.not_max
	srl a
	srl a
	srl a
	ld [wLuckySlotHiddenObjectIndex], a
	ret

GameCornerSetRocketHideoutDoorTile:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_FOUND_ROCKET_HIDEOUT
	ret nz
	ld a, $15 ; marcelnote - changed blockset
	ld [wNewTileBlockID], a
	lb bc, 0, 8 ; marcelnote - reduced map size
	predef_jump ReplaceTileBlock

GameCornerReenterMapAfterPlayerLoss:
	xor a ; SCRIPT_GAMECORNER_DEFAULT
	ld [wJoyIgnore], a
	ld [wGameCornerCurScript], a
	ld [wCurMapScript], a
	ret

GameCorner_ScriptPointers:
	def_script_pointers
	dw_const DoRet,                        SCRIPT_GAMECORNER_DEFAULT ; PureRGB - DoRet
	dw_const GameCornerRocketBattleScript, SCRIPT_GAMECORNER_ROCKET_BATTLE
	dw_const GameCornerRocketExitScript,   SCRIPT_GAMECORNER_ROCKET_EXIT

GameCornerRocketBattleScript: ; marcelnote - adjusted for reduced map size
	ld a, [wIsInBattle]
	cp $ff
	jp z, GameCornerReenterMapAfterPlayerLoss
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TEXT_GAMECORNER_ROCKET_AFTER_BATTLE
	ldh [hTextID], a
	call DisplayTextID
	ld a, GAMECORNER_ROCKET
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld a, [wXCoord]
	cp 10
	ld de, .AroundPlayerMovement
	jr z, .gotRocketMovement
	ld de, .DirectMovement
.gotRocketMovement
	ld a, GAMECORNER_ROCKET
	ldh [hSpriteIndex], a
	call MoveSprite
	ld a, SCRIPT_GAMECORNER_ROCKET_EXIT
	ld [wGameCornerCurScript], a
	ret

.AroundPlayerMovement:
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

.DirectMovement:
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

GameCornerRocketExitScript:
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, HS_GAME_CORNER_ROCKET
	ld [wMissableObjectIndex], a
	predef HideObject
	ld hl, wCurrentMapScriptFlags
	set BIT_CUR_MAP_LOADED_1, [hl]
	set BIT_CUR_MAP_LOADED_2, [hl]
	ld a, SCRIPT_GAMECORNER_DEFAULT
	ld [wGameCornerCurScript], a
	ret

GameCorner_TextPointers:
	def_text_pointers
	dw_const GameCornerBeauty1Text,           TEXT_GAMECORNER_BEAUTY1
	dw_const GameCornerClerk1Text,            TEXT_GAMECORNER_CLERK1
	dw_const GameCornerMiddleAgedMan1Text,    TEXT_GAMECORNER_MIDDLE_AGED_MAN1
	dw_const GameCornerBeauty2Text,           TEXT_GAMECORNER_BEAUTY2
	dw_const GameCornerFishingGuruText,       TEXT_GAMECORNER_FISHING_GURU
	dw_const GameCornerMiddleAgedWomanText,   TEXT_GAMECORNER_MIDDLE_AGED_WOMAN
	dw_const GameCornerGymGuideText,          TEXT_GAMECORNER_GYM_GUIDE
	dw_const GameCornerGamblerText,           TEXT_GAMECORNER_GAMBLER
	dw_const GameCornerClerk2Text,            TEXT_GAMECORNER_CLERK2
	dw_const GameCornerGentlemanText,         TEXT_GAMECORNER_GENTLEMAN
	dw_const GameCornerRocketText,            TEXT_GAMECORNER_ROCKET
	dw_const GameCornerPosterText,            TEXT_GAMECORNER_POSTER
	dw_const GameCornerRocketAfterBattleText, TEXT_GAMECORNER_ROCKET_AFTER_BATTLE

GameCornerBeauty1Text:
	text_far _GameCornerBeauty1Text
	text_end

GameCornerClerk1Text: ; marcelnote - optimized and made buying coins faster
	text_asm
	; Show player's coins
	call GameCornerDrawCoinBox
	ld hl, .DoYouNeedSomeGameCoins
.need_more_coins ; marcelnote - new for buying coins faster
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, .PleaseComePlaySometime
	jr nz, .print_text ; declined
	; Can only get more coins if you
	; - have the Coin Case
	ld b, COIN_CASE
	call IsItemInBag
	ld hl, .DontHaveCoinCase
	jr z, .print_text ; no coin case
	; - have room in the Coin Case for at least 9 coins
	call Has9990Coins
	ld hl, .CoinCaseIsFull
	jr nc, .print_text ; coin case full
	; - have at least 1000 yen
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $10
	ldh [hMoney + 1], a
	call HasEnoughMoney
	jr nc, .buy_coins
	ld hl, .CantAffordTheCoins
.print_text
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd
.buy_coins
	; Spend 1000 yen
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $10
	ldh [hMoney + 1], a
	ld hl, hMoney + 2
	ld de, wPlayerMoney + 2
	ld c, $3
	predef SubBCDPredef
	; Receive 50 coins
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $50
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	; Update display
	call GameCornerDrawCoinBox
	ld a, SFX_PURCHASE            ; marcelnote -
	call PlaySoundWaitForCurrent  ; added purchase sound
	call WaitForSoundToFinish     ; when buying coins
	ld hl, .ThanksHereAre50Coins
	;jr .print_ret
	; marcelnote - next few lines are new for buying coins faster
	call PrintText
	ld hl, .WantMoreCoins
	jr .need_more_coins

.DoYouNeedSomeGameCoins:
	text_far _GameCornerClerk1DoYouNeedSomeGameCoinsText
	text_end

.ThanksHereAre50Coins:
	text_far _GameCornerClerk1ThanksHereAre50CoinsText
	text_end

.WantMoreCoins: ; marcelnote - new for buying coins faster
	text_far _GameCornerClerk1WantMoreCoinsText
	text_end

.PleaseComePlaySometime:
	text_far _GameCornerClerk1PleaseComePlaySometimeText
	text_end

.CantAffordTheCoins:
	text_far _GameCornerClerk1CantAffordTheCoinsText
	text_end

.CoinCaseIsFull:
	text_far _GameCornerClerk1CoinCaseIsFullText
	text_end

.DontHaveCoinCase:
	text_far _GameCornerClerk1DontHaveCoinCaseText
	text_end

GameCornerMiddleAgedMan1Text:
	text_far _GameCornerMiddleAgedMan1Text
	text_end

GameCornerBeauty2Text:
	text_far _GameCornerBeauty2Text
	text_end

GameCornerFishingGuruText:
	text_asm
	CheckEvent EVENT_GOT_10_COINS
	ld hl, .WinsComeAndGoText
	jr nz, .print_text ; already got coins
	ld hl, .WantToPlayText
	call PrintText
	ld b, COIN_CASE
	call IsItemInBag
	ld hl, GameCornerOopsForgotCoinCaseText
	jr z, .print_text ; don't have coin case
	call Has9990Coins
	ld hl, .DontNeedMyCoinsText ; coin case full
	jr nc, .print_text
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $10
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	SetEvent EVENT_GOT_10_COINS
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .Received10CoinsText
.print_text
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.WantToPlayText:
	text_far _GameCornerFishingGuruWantToPlayText
	text_end

.Received10CoinsText:
	text_far _GameCornerFishingGuruReceived10CoinsText
	sound_get_item_1
	text_end

.DontNeedMyCoinsText:
	text_far _GameCornerFishingGuruDontNeedMyCoinsText
	text_end

.WinsComeAndGoText:
	text_far _GameCornerFishingGuruWinsComeAndGoText
	text_end

GameCornerMiddleAgedWomanText:
	text_far _GameCornerMiddleAgedWomanText
	text_end

GameCornerGymGuideText: ; marcelnote - adjusted
	text_asm
	CheckEvent EVENT_BEAT_ERIKA
	ld hl, GameCornerGymGuideTheyOfferRarePokemonText
	jr nz, .beat_erika
	ld hl, GameCornerGymGuideChampInMakingText
.beat_erika
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

GameCornerGymGuideChampInMakingText:
	text_far _GameCornerGymGuideChampInMakingText
	text_end

GameCornerGymGuideTheyOfferRarePokemonText:
	text_far _GameCornerGymGuideTheyOfferRarePokemonText
	text_end

GameCornerGamblerText:
	text_far _GameCornerGamblerText
	text_end

GameCornerClerk2Text:
	text_asm
	CheckEvent EVENT_GOT_20_COINS_2
	ld hl, .INeedMoreCoinsText
	jr nz, .print_text ; already got coins
	ld hl, .WantSomeCoinsText
	call PrintText
	ld b, COIN_CASE
	call IsItemInBag
	ld hl, GameCornerOopsForgotCoinCaseText
	jr z, .print_text ; don't have coin case
	call Has9990Coins
	ld hl, .YouHaveLotsOfCoinsText
	jr nc, .print_text ; coin case full
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $20
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	SetEvent EVENT_GOT_20_COINS_2
	ld hl, .Received20CoinsText
.print_text
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.WantSomeCoinsText:
	text_far _GameCornerClerk2WantSomeCoinsText
	text_end

.Received20CoinsText:
	text_far _GameCornerClerk2Received20CoinsText
	sound_get_item_1
	text_end

.YouHaveLotsOfCoinsText:
	text_far _GameCornerClerk2YouHaveLotsOfCoinsText
	text_end

.INeedMoreCoinsText:
	text_far _GameCornerClerk2INeedMoreCoinsText
	text_end

GameCornerGentlemanText:
	text_asm
	CheckEvent EVENT_GOT_20_COINS
	ld hl, .CloselyWatchTheReelsText
	jr nz, .print_text ; already got coins
	ld hl, .ThrowingMeOffText
	call PrintText
	ld b, COIN_CASE
	call IsItemInBag
	ld hl, GameCornerOopsForgotCoinCaseText
	jr z, .print_text ; don't have coin case
	call Has9990Coins
	ld hl, .YouGotYourOwnCoinsText
	jr z, .print_text ; coin case full
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld a, $20
	ldh [hCoins + 1], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	SetEvent EVENT_GOT_20_COINS
	ld hl, .Received20CoinsText
.print_text
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.ThrowingMeOffText:
	text_far _GameCornerGentlemanThrowingMeOffText
	text_end

.Received20CoinsText:
	text_far _GameCornerGentlemanReceived20CoinsText
	sound_get_item_1
	text_end

.YouGotYourOwnCoinsText:
	text_far _GameCornerGentlemanYouGotYourOwnCoinsText
	text_end

.CloselyWatchTheReelsText:
	text_far _GameCornerGentlemanCloselyWatchTheReelsText
	text_end

GameCornerRocketText:
	text_asm
	ld hl, .ImGuardingThisPosterText
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .BattleEndText
	ld de, .BattleEndText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ld a, SCRIPT_GAMECORNER_ROCKET_BATTLE
	ld [wGameCornerCurScript], a
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.ImGuardingThisPosterText:
	text_far _GameCornerRocketImGuardingThisPosterText
	text_end

.BattleEndText:
	text_far _GameCornerRocketBattleEndText
	text_end

GameCornerRocketAfterBattleText:
	text_far _GameCornerRocketAfterBattleText
	text_end

GameCornerPosterText:
	text_asm
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .SwitchBehindPosterText
	call PrintText
	call WaitForSoundToFinish
	ld a, SFX_GO_INSIDE
	call PlaySound
	call WaitForSoundToFinish
	SetEvent EVENT_FOUND_ROCKET_HIDEOUT
	ld a, $16 ; marcelnote - changed blockset
	ld [wNewTileBlockID], a
	lb bc, 0, 8 ; marcelnote - reduced map size
	predef ReplaceTileBlock
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.SwitchBehindPosterText:
	text_far _GameCornerPosterSwitchBehindPosterText
	text_asm
	ld a, SFX_SWITCH
	call PlaySound
	call WaitForSoundToFinish
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

GameCornerOopsForgotCoinCaseText:
	text_far _GameCornerOopsForgotCoinCaseText
	text_end

GameCornerDrawCoinBox:
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	hlcoord 11, 0
	lb bc, 5, 7 ; marcelnote - use lb
	call TextBoxBorder
	call UpdateSprites
	hlcoord 12, 1
	lb bc, 4, 7 ; marcelnote - use lb
	call ClearScreenArea
	hlcoord 12, 2
	ld de, GameCornerMoneyText
	call PlaceString
;	hlcoord 12, 3               ; marcelnote - useless?
;	ld de, GameCornerBlankText
;	call PlaceString
	hlcoord 12, 3
	ld de, wPlayerMoney
	ld c, 3 | MONEY_SIGN | LEADING_ZEROES
	call PrintBCDNumber
	hlcoord 12, 4
	ld de, GameCornerCoinText
	call PlaceString
;	hlcoord 12, 5               ; marcelnote - useless?
;	ld de, GameCornerBlankText
;	call PlaceString
	hlcoord 15, 5
	ld de, wPlayerCoins
	ld c, 2 | LEADING_ZEROES
	call PrintBCDNumber
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	ret

GameCornerMoneyText:
	db "MONEY@"

GameCornerCoinText:
	db "COINS@" ; marcelnote - added S

;GameCornerBlankText: ; marcelnote - useless?
;	db "       @"

Has9990Coins:
	ld a, $99
	ldh [hCoins], a
	ld a, $90
	ldh [hCoins + 1], a
	jp HasEnoughCoins
