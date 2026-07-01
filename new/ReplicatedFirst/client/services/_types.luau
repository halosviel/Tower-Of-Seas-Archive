--[=[
	[INFO]
	author: @halosviel
]=]

local stateMachine = require("@game/ReplicatedFirst/shared/utils/stateMachine")
local maid = require("@game/ReplicatedFirst/shared/libs/maid")

export type InterfaceService = {
	TWEEN_PRESET: TweenInfo,
	clientService: ClientService,
	main: typeof(game.ReplicatedFirst.client.services.interfaceService.main),
	viewingStage: number,
	firstEnter: boolean,
	maid: maid.Maid,
	constructor: ( self: InterfaceService ) -> nil,
	_getStageById: ( self: InterfaceService, id: number ) -> Model,
	_viewStage: ( self: InterfaceService, id: number ) -> Tween,
	enterMenu: ( self: InterfaceService ) -> nil,
	exitMenu: ( self: InterfaceService ) -> nil,
	ready: ( self: InterfaceService ) -> nil
}

export type ClientService = {
	interfaceService: InterfaceService,
	selectedStage: number,
	stateMachine: stateMachine.StateMachine,
	constructor: ( self: ClientService ) -> nil,
	ready: ( self: ClientService ) -> nil
}

return {}