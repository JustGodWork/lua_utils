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

<a href="https://discord.gg/nstjC2NBPf" class="button">```Discord```</a>
