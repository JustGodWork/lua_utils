---@author JustGodWork
---@version 1.0.0
---@description A simple class system for lua_version >= 5.4
---@source https://github.com/JustGodWork/lua_utils/blob/main/core/class.lua

---@type table<string, fun(...): table>
local classes = {};
local singletons = {};

local _type = type;

---@alias type
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"
---| "thread"
---| "userdata"
---| "BaseClass"

---@param var any
---@return type type
function type(var)
    local t = _type(var);
    if (t == "table") then
        local mt = getmetatable(var);
        return mt and mt.__name or t;
    end
    return t;
end

---@param var any
---@return type type
function typeof(var)
    return type(var);
end

---@param var any
---@return boolean
function is_lua_table(var)
    return _type(var) == "table";
end

---@param var any
---@return boolean
function is_class(var)
    if (_type(var) == "table") then
        local metatable = getmetatable(var);
        if (not metatable) then return false; end
        return metatable.__type == "class";
    end
    return false;
end

---@param var any
---@return boolean
function is_instance(var)
    if (_type(var) == "table") then
        local metatable = getmetatable(var);
        if (not metatable) then return false; end
        return metatable.__type == "instance";
    end
    return false;
end

---@param var any
---@return boolean
function is_singleton(var)
    if (_type(var) == "table") then
        local metatable = getmetatable(var);
        if (not metatable) then return false; end
        return metatable.__type == "singleton";
    end
    return false;
end

---@param var any
---@param class_name string
---@return boolean
function instanceof(var, class_name)
    assert(class_name, "instanceof: class_name must be a string.");
    assert(classes[class_name], ("instanceof: class %s doesn't exist."):format(class_name));
    if (_type(var) == "table") then
        local metatable = getmetatable(var);
        if (metatable) then
            local cls_metatable = getmetatable(classes[class_name]);
            if (not cls_metatable) then return false; end
            return metatable.__name == cls_metatable.__name
                and metatable.__type == "instance";
        end
    end
    return false;
end

---@param self BaseClass
---@param list table<number, BaseClass>
local function recursive_super_list(self, list)
	local metatable = getmetatable(self);
	local super = metatable.__super;

	if (not super) then return list; end
	list[#list + 1] = super;

	return recursive_super_list(super, list);
end

---@param self BaseClass
---@vararg any
local function super_constructor(self, ...)
	local metatable = getmetatable(self);
	local super_list = recursive_super_list(self, {});
	local super = super_list[metatable.__super_triggered + 1];

	assert(super, ("%s: super: (No super class found)"):format(metatable.__name));

	metatable.__super_triggered = metatable.__super_triggered + 1;

	if (rawget(super, "Constructor")) then
		super.Constructor(self, ...);
	end
end

---@param self BaseClass
---@param key string
---@return any
local function index(self, key)
    if (key == "super") then
        return super_constructor;
    end
	return rawget(self, key);
end

---@param cls BaseClass
---@param instance_type "instance" | "singleton"
---@vararg any
---@return BaseClass
local function new_instance(cls, instance_type, ...)
    local metatable = getmetatable(cls);
    local instance = setmetatable({}, {
		__super = metatable.__super,
		__super_count = metatable.__super_count,
		__super_triggered = 0,
        __index = cls,
        __name = metatable.__name,
		__newindex = metatable.__newindex,
        __type = instance_type,
    });

    if (rawget(cls, "Constructor")) then
        cls.Constructor(instance, ...);
    end

    local metatable = getmetatable(instance);
    local super = metatable.__super;
    local super_metatable = getmetatable(super);

    if (super_metatable.__name ~= "BaseClass") then
        assert(metatable.__super_triggered == metatable.__super_count, ("%s: Constructor: (Super Constructor not called)"):format(metatable.__name));
    end

    return instance;
end

---@param self BaseClass
---@param key string
---@param value any
local function new_key_listener(self, key, value)
    if (key == "Constructor") then
        rawset(self, key, function(self, ...)
            xpcall(value, function(err)
                local metatable = getmetatable(self);
                error(("%s: Constructor: %s"):format(metatable.__name, err), 2);
            end, self, ...);
        end);
		return;
    end
	rawset(self, key, value);
end

---@field public name string
---@field public type string

---@class BaseClass
---@field public Constructor fun(self: BaseClass, ...): void
---@field public super fun(self: BaseClass, ...): void
classes["BaseClass"] = setmetatable({}, {
    __name = "BaseClass";
    __call = new_instance;
	__index = index;
    __newindex = new_key_listener;
	__super_count = -1;
});

---@param name string
---@param from? string
---@return BaseClass
local function class_new(name, from)
    assert(type(name) == "string", ("create_class name: (Expected string, got %s)"):format(type(name)));
    assert(not classes[name], ("create_class name: (Class %s already exists)"):format(name));
	assert(classes[from], ("create_class from: (Class %s does not exist)"):format(from));

	local from_cls = classes[from];
	local from_metatable = getmetatable(from_cls);

    classes[name] = setmetatable({}, {
		__name = name,
        __index = from_cls,
        __super = from_cls,
		__super_count = from_metatable.__super_count + 1,
		__call = from_metatable.__call,
		__type = "class",
		__newindex = from_metatable.__newindex,
    });

    return classes[name];
end

---@param class_name string
---@vararg any
---@return BaseClass
local function instance(class_name, ...)
    assert(type(class_name) == "string", ("create_instance class_name: (Expected string, got %s)"):format(type(class_name)));

    local cls = classes[class_name];
    assert(cls, ("create_instance class_name: (Class %s does not exist)"):format(class_name));

    local metatable = getmetatable(cls);

    if (metatable.__type == "singleton") then
        error(("create_instance class_name: (Class %s is a singleton)"):format(class_name));
    end

    return cls("instance", ...);
end

---@param class_name string
---@vararg any
---@return BaseClass
local function singleton(class_name, ...)
    assert(type(class_name) == "string", ("create_singleton class_name: (Expected string, got %s)"):format(type(class_name)));

    local cls = classes[class_name];
    assert(cls, ("create_singleton class_name: (Class %s does not exist)"):format(class_name));

    if (singletons[class_name]) then
        return singletons[class_name];
    end

    local instance = cls("singleton", ...);
    classes[class_name] = true;
    singletons[class_name] = instance;

    return instance;
end

---@param name string
---@return BaseClass
local function get_class(name)
    return classes[name];
end

---@param name string
local function remove_class(name)
    classes[name] = nil;
    if (singletons[name]) then
        singletons[name] = nil;
    end
end

---@class class_constructor
---@field public get fun(name: string): BaseClass
---@field public extends fun(name: string, from: string): BaseClass
---@field public instance fun(name: string, ...): BaseClass
---@field public singleton fun(class_name: string, ...): BaseClass
---@field public remove fun(name: string): void
---@field public all table<string, fun(...): BaseClass>
---@overload fun(name: string): BaseClass
class = setmetatable({}, {
    __call = function(self, name)
        return class_new(name, "BaseClass");
    end;
    __index = function(self, key)
        if (key == "get") then
            return get_class;
        end

        if (key == "all") then
            return classes;
        end

        if (key == "extends") then
            return function(name, from)
                return class_new(name, from);
            end;
        end

        if (key == "instance") then
            return instance;
        end

        if (key == "singleton") then
            return singleton;
        end

        if (key == "remove") then
            return remove_class;
        end
    end;
});