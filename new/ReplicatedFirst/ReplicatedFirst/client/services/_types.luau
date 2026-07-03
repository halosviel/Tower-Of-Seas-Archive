--[=[
	[INFO]
	author: @halosviel
]=]

local stateMachine = require("@game/ReplicatedFirst/shared/utils/stateMachine")
local maid = require("@game/ReplicatedFirst/shared/libs/maid")

export type InterfaceService = {
	TWEEN_PRESET: TweenInfo,
	clientService: ClientService,
	musicService: MusicService,
	main: typeof(game.ReplicatedFirst.client.services.interfaceService.main),
	viewingStage: number,
	firstEnter: boolean,
	maid: maid.Maid,
	menuButtonMaid: maid.Maid,
	constructor: ( self: InterfaceService ) -> nil,
	_getStageById: ( self: InterfaceService, id: number ) -> Model,
	_viewStage: ( self: InterfaceService, id: number ) -> Tween,
	_updateStageInfo: ( self: InterfaceService ) -> Model,
	_setMusicButtonVisible: ( self: InterfaceService, value: boolean ) -> nil,
	_setMusicButtonEnabled: ( self: InterfaceService, value: boolean ) -> nil,
	enterMenu: ( self: InterfaceService ) -> nil,
	exitMenu: ( self: InterfaceService ) -> nil,
	enableMenuButton: ( self: InterfaceService ) -> nil,
	disableMenuButton: ( self: InterfaceService ) -> nil,
	ready: ( self: InterfaceService ) -> nil
}

export type ClientService = {
	interfaceService: InterfaceService,
	selectedStage: number,
	stateMachine: stateMachine.StateMachine,
	constructor: ( self: ClientService ) -> nil,
	ready: ( self: ClientService ) -> nil
}

export type PartService = {
	names: { string },
	modules: { [string]: ( part: BasePart ) -> nil },
	constructor: ( self: PartService ) -> nil,
	ready: ( self: PartService ) -> nil
}

export type MusicService = {
	interfaceService: InterfaceService,
	isPlaying: boolean,
	currentSong: Sound,
	constructor: ( self: MusicService ) -> nil,
	play: ( self: MusicService ) -> nil,
	pause: ( self: MusicService ) -> nil,
	ready: ( self: MusicService ) -> nil
}

return {}