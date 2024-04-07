# Lua Utils
***An implementation of javascript functionality in lua***.

**Lua Utils** comes with a powerful class system

## Classes:
**Map**: A JavaScript like class implemented in lua.
```lua
---@type Map
local map = class.instance("Map");

map:set("my_key", "my_value");
console:log(map:get("my_key", "my_value"));
```

**EventEmitter**: A JavaScript like class implemented in lua.
```lua
---@type EventEmitter
local events = class.instance("EventEmitter");

events:on("my_event", function(message)
    console:log(message);
end);

events:emit("my_event");
```

**console**: A JavaScript like class implemented in lua.
```lua
console:log("My message", {
    entry1 = "Hello",
    entry2 = "World"
});
```

**GraphicsContext**: A simple FiveM rendering class
```lua
---@type GraphicsContext
local context = class.instance("GraphicsContext")
	:addText("Il a pas dit bonjour", {
		font = eTextFont.ChaletLondon,
		scale = 0.2,
		alignement = eTextAlignement.Centered,
		color = {r = 255, g = 255, b = 255, a = 255},
		position = {x = 1840, y = 1025}
	})
	:addRectangle( {
		width = 200,
		height = 30,
		color = {r = 0, g = 0, b = 0, a = 175},
		position = {x = 1720, y = 980}
	})
	:addRectangle({
		width = 200,
		height = 30,
		color = {r = 0, g = 0, b = 0, a = 175},
		position = {x = 1720, y = 1020}
	})
	:addSprite({
		textureDict = "commonmenu",
		textureName = "interaction_bgd",
		color = {r = 255, g = 255, b = 255, a = 255},
		position = {x = 250, y = 250},
		width = 400.0,
		height = 75
	});

context:start();

RegisterCommand("toggle_context", function()
	context.toggle();
end, false);
```

<a href="https://discord.gg/nstjC2NBPf" class="button">```Discord```</a>
