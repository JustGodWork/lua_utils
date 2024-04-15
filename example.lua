---@class SimpleClass: BaseClass
local simple_class = class("SimpleClass");

function simple_class:Constructor(arg1, arg2)
	self.arg1 = arg1;
	self.arg2 = arg2;
end

function simple_class:show()
	console:log(self.arg1, self.arg2);
end

---@type SimpleClass
local instance = class.instance("SimpleClass", "arg1_value", "arg2_value");

console:warn(
	"Hello, World!",
	{
		1,
		2,
		3,
		4,
		5
	}
);

instance:show();

console:log({
	show_meta = true,
	instance_meta = instance
});

---@class ExtendClass: EventEmitter
---@field public data Map
local extend_class = class.extends("ExtendClass", "EventEmitter");

function extend_class:Constructor()
	self:super();
	self.data = class.instance("Map");
end

function extend_class:show_map()
	console:log(self.data);
end

---@type ExtendClass
local extend_instance = class.instance("ExtendClass");

extend_instance:show_map();

extend_instance.data:set("test", "test_value");

extend_instance:on("test", function(test_value)
	console:log("Test event emitted", test_value);
end);

extend_instance:emit("test", extend_instance.data:get("test"));