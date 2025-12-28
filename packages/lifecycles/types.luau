export type Lifecycle<Args... = ...any> = {
	_isDestroyed: boolean,
	_selfRegistered: { (callback: (Args...) -> ()) -> () },
	_selfUnregistered: { (callback: (Args...) -> ()) -> () },

	type: "Lifecycle",

	callbacks: { (Args...) -> () },
	method: string,

	register: (self: Lifecycle<Args...>, callback: (Args...) -> ()) -> (),
	fire: (self: Lifecycle<Args...>, Args...) -> (),
	unregister: (self: Lifecycle<Args...>, callback: (Args...) -> ()) -> (),
	clear: (self: Lifecycle<Args...>) -> (),
	onRegistered: (self: Lifecycle<Args...>, listener: (callback: (Args...) -> ()) -> ()) -> () -> (),
	onUnregistered: (self: Lifecycle<Args...>, listener: (callback: (Args...) -> ()) -> ()) -> () -> (),
	await: (self: Lifecycle<Args...>) -> Args...,
	destroy: (self: Lifecycle<Args...>) -> (),
}

return nil
