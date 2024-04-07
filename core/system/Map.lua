---@author JustGodWork
---@version 1.0.0
---@description A simple Map class for lua_version >= 5.4
---@source https://github.com/JustGodWork/lua_utils/blob/main/core/system/Map.lua

---@class Map: BaseClass
---@field public size number
---@field private data table
local map = class("Map");

function map:constructor()
	self.size = 0;
	self._data = {};
end

---@param key string | number
---@return boolean
function map:has(key)
	return self._data[key] ~= nil;
end

---@param key string | number
---@return any
function map:get(key)
	return self._data[key];
end

---@param key string | number
---@param value any
function map:set(key, value)
	if (value ~= nil) then
		if (not self._data[key]) then
			self.size += 1;
		else
			self.size -= 1;
		end
	end
	self._data[key] = value;
	return self;
end

---@param key string | number
function map:remove(key)
	if (self._data[key]) then
		self._data[key] = nil;
		self.size -= 1;
	end
end

---@param callbackFn fun(key: string | number, value: any)
function map:for_each(callbackFn)
	assert(callbackFn, "Map:for_each(): callbackFn must be a function.");
	for k, v in pairs(self._data) do
		callbackFn(k, v);
	end
end

---@param callbackFn fun(key: string | number, value: any): boolean
function map:filter(callbackFn)
	assert(callbackFn, "Map:filter(): callbackFn must be a function.");
	---@type Map
	local new_map = class.instance("Map");
	for k, v in pairs(self._data) do
		if (callbackFn(k, v)) then
			new_map:set(k, v);
		end
	end
	return new_map;
end

---@param callbackFn fun(key: string | number)
---@return string[] | number[] keys
function map:keys(callbackFn)
	assert(callbackFn, "Map:keys(): callbackFn must be a function.");
	local result = {};
	for k, v in pairs(self._data) do
		callbackFn(k);
		result[#result + 1] = k;
	end
	return result;
end

---@param callbackFn fun(value: any)
---@return any[] values
function map:values(callbackFn)
	assert(callbackFn, "Map:values(): callbackFn must be a function.");
	local result = {};
	for k, v in pairs(self._data) do
		callbackFn(v);
		result[#result + 1] = v;
	end
	return result;
end

---@param callbackFn fun(key: string | number, value: any): boolean
---@return Map
function map:map(callbackFn)
	assert(callbackFn, "Map:map(): callbackFn must be a function.");
	---@type Map
	local new_map = class.instance("Map");
	for k, v in pairs(self._data) do
		if (callbackFn(k, v)) then
			new_map:set(k, v);
		end
	end
	return new_map;
end