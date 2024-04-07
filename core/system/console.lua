---@author JustGodWork
---@version 1.0.0
---@description A simple event emitter class for lua_version >= 5.4
---@source https://github.com/JustGodWork/lua_utils/blob/fivem/core/system/console.lua

local _print = print;
local sort = table.sort;
local concat = table.concat;

---@class console
---@field log_level number
---@field log_levels table<number, string>
local _console = class("console");

---@param log_level number
function _console:constructor(log_level)
	self.log_level = 5;
	self.log_levels = {
		[0] = "^5INFO^0",
		[1] = "^3WARN^0",
		[2] = "^5TRACE^0",
		[3] = "^1ERROR^0",
		[4] = "^6DEBUG^0",
		[5] = "^1FATAL^0"
	};
end

---@param log_level number
function _console:setLogLevel(log_level)
	self.log_level = log_level;
	return self;
end

---@private
---@param obj any
function _console:get_type_name(obj)
	local _type = type(obj);
	if (is_class(obj)) then
		local metatable = getmetatable(obj);
		return ("class '%s'"):format(metatable.__name);
	end
	if (is_instance(obj)) then
		local metatable = getmetatable(obj);
		return ("instance of '%s'"):format(metatable.__name);
	end
	if (is_singleton(obj)) then
		local metatable = getmetatable(obj);
		return ("singleton '%s'"):format(metatable.__name);
	end
	return _type;
end

---@private
---@param obj table
function _console:handle_obj(obj)
	local data, buffer = {}, {};
	local function dump(object, step, show_meta)
		local is_table = is_lua_table(object);
		if (is_table and not data[object]) then
			local metatable = getmetatable(object);

			if (metatable and show_meta) then
				dump(metatable, step, show_meta);
			end

			data[object] = true;

			local keys = {};

			for key in pairs(object) do
				if (key ~= "show_meta") then
					keys[#keys + 1] = key;
				end
			end

			step += 1;

			buffer[#buffer + 1] = (
				step == 1 and "\n^6%s^0 -> {" or " ^6%s^0 -> {"
			):format(
				self:get_type_name(object)
			);

			for i = 1, #keys do
				local key = keys[i];
				local value = object[key];
				local key_str = type(key) == "string"
					and ("^6%s^0"):format(key)
					or ("[^6%s^0]"):format(key);
				local indentation = (" "):rep(step * 4);

				buffer[#buffer + 1] = ("\n%s%s = ^5%s^0"):format(indentation, key_str, value);
				dump(value, step, show_meta);
				buffer[#buffer + 1] = ",";
			end

			step -= 1;
			buffer[#buffer + 1] = ("\n%s}"):format((" "):rep(step * 4));

			return;
		end
	end

	dump(obj, 0, is_lua_table(obj) and obj.show_meta);

	return concat(buffer);
end

---@private
---@param log_level number
---@vararg ConsoleData | any
function _console:send(log_level, ...)
	if (log_level < self.log_level) then return; end
	local message = "";
	local args = {...};
	local log_level_str = self.log_levels[log_level] or "UNKNOWN";
	for i = 1, #args do
		if (is_lua_table(args[i])) then
			message = ("%s %s^0\n"):format(message, self:handle_obj(args[i]));
		else
			message = ("%s %s^0"):format(message, tostring(args[i]));
		end
	end
	_print(("^0[%s]%s"):format(log_level_str, message));
end

---@vararg ConsoleData | any
function _console:log(...)
	if (self.log_level >= 0) then
		self:send(0, ...);
	end
	return self;
end

---@vararg any
function _console:warn(...)
	if (self.log_level >= 1) then
		self:send(1, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function _console:trace(...)
	if (self.log_level >= 2) then
		self:send(2, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function _console:err(...)
	if (self.log_level >= 3) then
		self:send(3, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function _console:debug(...)
	--IMPLEMENT YOUR DEBUGGING LOGIC HERE
	if (self.log_level >= 4) then
		self:send(4, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function _console:fatal(...)
	if (self.log_level >= 5) then
		self:send(5, ...);
	end
	return self;
end

---@type console
console = class.singleton("console");

function print(...)
	console:log(...);
end