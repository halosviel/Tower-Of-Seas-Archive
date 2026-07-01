--[=[
	[INFO]
	author: @halosviel
]=]

export type StageService = {
	players: { [Player]: number },
	constructor: ( self: SampleService ) -> nil,
	ready: ( self: SampleService ) -> nil
}

export type SampleService = {
	constructor: ( self: SampleService ) -> nil,
	ready: ( self: SampleService ) -> nil
}

return {}