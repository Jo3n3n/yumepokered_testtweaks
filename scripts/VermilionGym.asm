VermilionGym_Script:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	push hl
	call nz, .LoadNames
	pop hl
	bit BIT_CUR_MAP_LOADED_2, [hl]
	res BIT_CUR_MAP_LOADED_2, [hl]
	call nz, VermilionGymSetDoorTile
	call EnableAutoTextBoxDrawing
	ld hl, VermilionGymTrainerHeaders
	ld de, VermilionGym_ScriptPointers
	ld a, [wVermilionGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wVermilionGymCurScript], a
	ret

.LoadNames:
	ld hl, .CityName
	ld de, .LeaderName
	jp LoadGymLeaderAndCityName

.CityName:
	db "VERMILION CITY@"

.LeaderName:
	db "LT.SURGE@"

VermilionGymSetDoorTile:
	CheckEvent EVENT_2ND_LOCK_OPENED
	jr nz, .doorsOpen
	ld a, $24 ; double door tile ID
	jr .replaceTile
.doorsOpen
	ld a, SFX_GO_INSIDE
	call PlaySound
	ld a, $5 ; clear floor tile ID
.replaceTile
	ld [wNewTileBlockID], a
	lb bc, 2, 2
	predef_jump ReplaceTileBlock

VermilionGymResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wVermilionGymCurScript], a
	ld [wCurMapScript], a
	ret

VermilionGym_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,                   SCRIPT_VERMILIONGYM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle,      SCRIPT_VERMILIONGYM_START_BATTLE
	dw_const EndTrainerBattle,                           SCRIPT_VERMILIONGYM_END_BATTLE
	dw_const VermilionGymLTSurgeAfterBattleScript,       SCRIPT_VERMILIONGYM_LT_SURGE_AFTER_BATTLE
	dw_const VermilionGymLTSurgeRematchPostBattleScript, SCRIPT_VERMILIONGYM_LT_SURGE_REMATCH_POST_BATTLE ; marcelnote - Lt.Surge rematch

VermilionGymLTSurgeAfterBattleScript:
	ld a, [wIsInBattle]
	cp $ff ; did we lose?
	jp z, VermilionGymResetScripts
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a

VermilionGymLTSurgeReceiveTM24Script: ; marcelnote - optimized
	ld a, TEXT_VERMILIONGYM_LT_SURGE_THUNDER_BADGE_INFO
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_LT_SURGE
	lb bc, TM_THUNDERBOLT, 1
	call GiveItem
	ld a, TEXT_VERMILIONGYM_LT_SURGE_TM24_NO_ROOM
	jr nc, .bag_full
	SetEvent EVENT_GOT_TM24
	ld a, TEXT_VERMILIONGYM_LT_SURGE_RECEIVED_TM24
.bag_full
	ldh [hTextID], a
	call DisplayTextID
	ld hl, wObtainedBadges
	set BIT_THUNDERBADGE, [hl]
	;ld hl, wBeatGymFlags     ; marcelnote - removed redundant wBeatGymFlags
	;set BIT_THUNDERBADGE, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_VERMILION_GYM_TRAINER_0, EVENT_BEAT_VERMILION_GYM_TRAINER_2

	jp VermilionGymResetScripts

VermilionGymLTSurgeRematchPostBattleScript: ; marcelnote - Lt.Surge rematch
	ld a, [wIsInBattle]
	cp $ff
	jp z, VermilionGymResetScripts
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, TEXT_VERMILIONGYM_AFTER_REMATCH
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_LT_SURGE_REMATCH
	jp VermilionGymResetScripts

VermilionGym_TextPointers:
	def_text_pointers
	dw_const VermilionGymLTSurgeText,                 TEXT_VERMILIONGYM_LT_SURGE
	dw_const VermilionGymLTSurgeRematchText,          TEXT_VERMILIONGYM_LT_SURGE_REMATCH ; marcelnote - Lt.Surge rematch
	dw_const VermilionGymGentlemanText,               TEXT_VERMILIONGYM_GENTLEMAN
	dw_const VermilionGymSuperNerdText,               TEXT_VERMILIONGYM_SUPER_NERD
	dw_const VermilionGymSailorText,                  TEXT_VERMILIONGYM_SAILOR
	dw_const VermilionGymGymGuideText,                TEXT_VERMILIONGYM_GYM_GUIDE
	dw_const VermilionGymLTSurgeThunderBadgeInfoText, TEXT_VERMILIONGYM_LT_SURGE_THUNDER_BADGE_INFO
	dw_const VermilionGymLTSurgeReceivedTM24Text,     TEXT_VERMILIONGYM_LT_SURGE_RECEIVED_TM24
	dw_const VermilionGymLTSurgeTM24NoRoomText,       TEXT_VERMILIONGYM_LT_SURGE_TM24_NO_ROOM
	dw_const VermilionGymAfterRematchText,            TEXT_VERMILIONGYM_AFTER_REMATCH ; marcelnote - Lt.Surge rematch

VermilionGymTrainerHeaders:
	def_trainers 3 ; marcelnote - added 1 to accomodate Lt.Surge rematch
VermilionGymTrainerHeader0:
	trainer EVENT_BEAT_VERMILION_GYM_TRAINER_0, 3, VermilionGymGentlemanBattleText, VermilionGymGentlemanEndBattleText, VermilionGymGentlemanAfterBattleText
VermilionGymTrainerHeader1:
	trainer EVENT_BEAT_VERMILION_GYM_TRAINER_1, 2, VermilionGymSuperNerdBattleText, VermilionGymSuperNerdEndBattleText, VermilionGymSuperNerdAfterBattleText
VermilionGymTrainerHeader2:
	trainer EVENT_BEAT_VERMILION_GYM_TRAINER_2, 3, VermilionGymSailorBattleText, VermilionGymSailorEndBattleText, VermilionGymSailorAfterBattleText
	db -1 ; end

VermilionGymLTSurgeText: ; marcelnote - optimized
	text_asm
	CheckEvent EVENT_BEAT_LT_SURGE
	jr z, .before_beat
	CheckEventReuseA EVENT_GOT_TM24
	jr nz, .got_tm24_already
	call z, VermilionGymLTSurgeReceiveTM24Script
	call DisableWaitingAfterTextDisplay
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd
.got_tm24_already
	ld hl, .PostBattleAdviceText
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd
.before_beat
	ld hl, .PreBattleText
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, VermilionGymLTSurgeReceivedThunderBadgeText
	ld de, VermilionGymLTSurgeReceivedThunderBadgeText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $3
	ld [wGymLeaderNo], a
	xor a
	ldh [hJoyHeld], a
	ld a, SCRIPT_VERMILIONGYM_LT_SURGE_AFTER_BATTLE
	ld [wVermilionGymCurScript], a
	ld [wCurMapScript], a
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.PreBattleText:
	text_far _VermilionGymLTSurgePreBattleText
	text_end

.PostBattleAdviceText:
	text_far _VermilionGymLTSurgePostBattleAdviceText
	text_end

VermilionGymLTSurgeThunderBadgeInfoText:
	text_far _VermilionGymLTSurgeThunderBadgeInfoText
	text_end

VermilionGymLTSurgeReceivedTM24Text:
	text_far _VermilionGymLTSurgeReceivedTM24Text
	sound_get_key_item
	text_far _TM24ExplanationText
	text_end

VermilionGymLTSurgeTM24NoRoomText:
	text_far _VermilionGymLTSurgeTM24NoRoomText
	text_end

VermilionGymLTSurgeReceivedThunderBadgeText:
	text_far _VermilionGymLTSurgeReceivedThunderBadgeText
	text_end

VermilionGymGentlemanText:
	text_asm
	ld hl, VermilionGymTrainerHeader0
	call TalkToTrainer
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

VermilionGymGentlemanBattleText:
	text_far _VermilionGymGentlemanBattleText
	text_end

VermilionGymGentlemanEndBattleText:
	text_far _VermilionGymGentlemanEndBattleText
	text_end

VermilionGymGentlemanAfterBattleText:
	text_far _VermilionGymGentlemanAfterBattleText
	text_end

VermilionGymSuperNerdText:
	text_asm
	ld hl, VermilionGymTrainerHeader1
	call TalkToTrainer
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

VermilionGymSuperNerdBattleText:
	text_far _VermilionGymSuperNerdBattleText
	text_end

VermilionGymSuperNerdEndBattleText:
	text_far _VermilionGymSuperNerdEndBattleText
	text_end

VermilionGymSuperNerdAfterBattleText:
	text_far _VermilionGymSuperNerdAfterBattleText
	text_end

VermilionGymSailorText:
	text_asm
	ld hl, VermilionGymTrainerHeader2
	call TalkToTrainer
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

VermilionGymSailorBattleText:
	text_far _VermilionGymSailorBattleText
	text_end

VermilionGymSailorEndBattleText:
	text_far _VermilionGymSailorEndBattleText
	text_end

VermilionGymSailorAfterBattleText:
	text_far _VermilionGymSailorAfterBattleText
	text_end

VermilionGymGymGuideText: ; marcelnote - optimized
	text_asm
	CheckEvent EVENT_BEAT_LT_SURGE
	ld hl, .BeatLTSurgeText
	jr nz, .beat_lt_surge
	ld hl, .ChampInMakingText
.beat_lt_surge
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.ChampInMakingText:
	text_far _VermilionGymGymGuideChampInMakingText
	text_end

.BeatLTSurgeText:
	text_far _VermilionGymGymGuideBeatLTSurgeText
	text_end

VermilionGymLTSurgeRematchText: ; marcelnote - Lt.Surge rematch
	text_asm
	CheckEvent EVENT_BEAT_LT_SURGE_REMATCH
	jr z, .beforeBeat
	ld hl, VermilionGymAfterRematchText
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd
.beforeBeat
	ld hl, .PreBattleText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	ld hl, .AcceptBattleText
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .LTSurgeDefeatedText
	ld de, .LTSurgeDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $3
	ld [wGymLeaderNo], a
	xor a
	ldh [hJoyHeld], a
	ld a, SCRIPT_VERMILIONGYM_LT_SURGE_REMATCH_POST_BATTLE
	ld [wVermilionGymCurScript], a
	ld [wCurMapScript], a
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd
.refused
	ld hl, .RefusedBattleText
	call PrintText
	rst TextScriptEnd ; PureRGB - rst TextScriptEnd

.PreBattleText:
	text_far _VermilionGymLTSurgeRematchPreBattleText
	text_end

.AcceptBattleText:
	text_far _VermilionGymLTSurgeRematchAcceptBattleText
	text_end

.RefusedBattleText:
	text_far _VermilionGymLTSurgeRematchRefusedBattleText
	text_end

.LTSurgeDefeatedText:
	text_far _VermilionGymLTSurgeRematchDefeatedText
	text_end

VermilionGymAfterRematchText: ; marcelnote - Lt.Surge rematch
	text_far _VermilionGymAfterRematchText
	text_end
