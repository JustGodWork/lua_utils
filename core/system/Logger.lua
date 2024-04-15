---@author JustGodWork
---@version 1.0.0
---@description A simple event emitter class for lua_version >= 5.4
---@source https://github.com/JustGodWork/lua_utils/blob/main/core/system/Logger.lua

local _print = print;
local sort = table.sort;
local concat = table.concat;

---@class Logger: BaseClass
---@field public prefix? string
---@field public log_level eLogLevel
---@field public log_levels table<number, string>
local logger = class("Logger");

logger.log_levels = {
	[0] = "INFO",
	[1] = "WARN",
	[2] = "TRACE",
	[3] = "ERROR",
	[4] = "DEBUG",
	[5] = "FATAL"
};

logger.log_level_colors = {
	[0] = eLogColor.FgGreen,
	[1] = eLogColor.FgYellow,
	[2] = eLogColor.FgCyan,
	[3] = eLogColor.FgRed,
	[4] = eLogColor.FgMagenta,
	[5] = eLogColor.FgRed
};

---@param prefix string
---@param log_level number
function logger:Constructor(prefix, log_level)
	self.prefix = prefix;
	self.log_level = 5;
end

---@param log_level eLogLevel
function logger:SetLogLevel(log_level)
	self.log_level = log_level;
	return self;
end

---@param color eLogColor
---@param text string
function logger:FormatColor(color, text)
	---Prevent color formatting on client
	if (Client) then
		return text;
	end
	return ("%s%s%s"):format(color, text, eLogColor.Reset);
end

---@private
---@param obj any
function logger:GetTypeName(obj)
	local _type = type(obj);
	if (is_class(obj)) then
		local metatable = getmetatable(obj);
		return ("class '%s'"):format(self:FormatColor(eLogColor.FgMagenta, metatable.__name));
	end
	if (is_instance(obj)) then
		local metatable = getmetatable(obj);
		return ("instance of '%s'"):format(self:FormatColor(eLogColor.FgMagenta, metatable.__name));
	end
	if (is_singleton(obj)) then
		local metatable = getmetatable(obj);
		return ("singleton '%s'"):format(self:FormatColor(eLogColor.FgMagenta, metatable.__name));
	end
	return _type;
end

---@private
---@param obj table
function logger:HandleObj(obj)
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
			step = step + 1;

			buffer[#buffer + 1] = (
				step == 1 and "\n%s -> {" or " %s -> {"
			):format(
				self:GetTypeName(object)
			);

			for i = 1, #keys do
				local key = keys[i];
				local value = object[key];
				local key_str = type(key) == "string" and key or ("[%s]"):format(key);
				buffer[#buffer + 1] = ("\n%s%s = %s"):format((" "):rep(step * 4), key_str, value);
				dump(value, step, show_meta);
				buffer[#buffer + 1] = ",";
			end
			step = step - 1;
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
function logger:Send(log_level, ...)
	local message = "";
	local args = {...};
	local log_level_str = logger.log_levels[log_level] or "UNKNOWN";
	local log_level_color = logger.log_level_colors[log_level] or eLogColor.FgWhite;
	for i = 1, #args do
		if (is_lua_table(args[i])) then
			message = ("%s %s"):format(message, self:HandleObj(args[i]));
		else
			message = ("%s %s"):format(message, tostring(args[i]));
		end
	end
	if (self.prefix) then
		message = (" (%s)%s"):format(self:FormatColor(eLogColor.Dim, self.prefix), message);
	end
	Console.Log("%s%s", self:FormatColor(log_level_color, log_level_str), message);
end

---@vararg ConsoleData | any
function logger:log(...)
	if (self.log_level >= eLogLevel.info) then
		self:Send(eLogLevel.info, ...);
	end
	return self;
end

---@vararg any
function logger:warn(...)
	if (self.log_level >= eLogLevel.warning) then
		self:Send(eLogLevel.warning, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function logger:trace(...)
	if (self.log_level >= eLogLevel.trace) then
		self:Send(eLogLevel.trace, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function logger:err(...)
	if (self.log_level >= eLogLevel.error) then
		self:Send(eLogLevel.error, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function logger:debug(...)
	--IMPLEMENT YOUR DEBUGGING LOGIC HERE
	if (self.log_level >= eLogLevel.debug) then
		self:Send(eLogLevel.debug, ...);
	end
	return self;
end

---@vararg ConsoleData | any
function logger:fatal(...)
	if (self.log_level >= eLogLevel.fatal) then
		self:Send(eLogLevel.fatal, ...);
	end
	return self;
end

---@type Logger
console = class.instance("Logger");