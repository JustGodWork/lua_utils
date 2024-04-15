---@author JustGodWork
---@version 1.0.0
---@description A simple event emitter class for lua_version >= 5.4
---@source https://github.com/JustGodWork/lua_utils/blob/main/core/system/EventEmitter.lua

---@class EventEmitter: BaseClass
---@field private _events table<string, function[]>
---@field private _maxListeners number
local event_emitter = class("EventEmitter");

---@param eventName string
---@param func function
---@vararg any
local function safe_call(eventName, func, ...)
	local args = { ... };
	local success, result = xpcall(func, function(err)
		print(("An error occurred while emitting event (%s): %s"):format(eventName, err));
	end, table.unpack(args));
end

---@param options EventEmitterOptions
function event_emitter:Constructor(options)
	local opt = type(options) == "table" and options or {};
	self._events = {};
	self._maxListeners = type(opt.maxListeners) == "number"
		and options.maxListeners or 10;
end

---@param event string
---@param listener function
---@return EventEmitterData
function event_emitter:on(event, listener)
	assert(type(event) == "string", "EventEmitter: event must be a string");
	assert(type(listener) == "function", "EventEmitter: listener must be a function");

	self._events[event] = self._events[event] or {};

	assert(#self._events[event] < self._maxListeners, (
		"EventEmitter: event (%s) has reached the maximum number of listeners (%s) use setMaxListeners to increase the limit"
	):format(event, self._maxListeners));

	local index = #self._events[event] + 1;

	self._events[event][index] = function(...)
		local args = { ... };
		coroutine.wrap(safe_call, event, listener, table.unpack(args));
	end
	return {
		event = event,
		index = index
	};
end

---@param event string
---@param listener function
function event_emitter:once(event, listener)
	local data;
	data = self:on(event, function(...)
		self:removeListener(data);
		safe_call(event, listener, ...);
	end);
end

---@param eventData EventEmitterData
function event_emitter:removeListener(eventData)
	local listeners = self._events[eventData.event];

	if (listeners) then
		self._events[eventData.event][eventData.index] = nil;
	end
	return self;
end

---@param event string
---@vararg any
function event_emitter:emit(event, ...)
	local listeners = self._events[event];

	if (listeners) then
		for i = 1, #listeners do
			if (type(listeners[i]) == "function") then
				listeners[i](...);
			end
		end
	end
end

function event_emitter:clear()
	self._events = {};
	return self;
end