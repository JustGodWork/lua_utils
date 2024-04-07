---@author JustGodWork
---@version 1.0.0
---@description A simple FiveM rendering class for lua_version >= 5.4
---@source https://github.com/JustGodWork/lua_utils/blob/fivem/core/utils/Graphics.lua

local DRAW_RECT = DrawRect;
local DRAW_SPRITE = DrawSprite;

---@class GraphicsData
---@field public type "rect" | "text" | "sprite
---@field public entry? string
---@field public options SettingText | SettingRect | SettingSprite

---@class GraphicsContext
---@field public data GraphicsData[]
---@field public started boolean
local graphics = class("GraphicsContext");

function graphics:constructor()
	self.data = {};
	self.started = false;
end

---@param textureDict string
function graphics:request_texture_dict(textureDict)
	if (not HasStreamedTextureDictLoaded(textureDict)) then
		RequestStreamedTextureDict(textureDict);
		while (not HasStreamedTextureDictLoaded(textureDict)) do
			console:warn("Waiting for texture dict to load: " .. textureDict);
			Wait(0);
		end
	end
	return self;
end

---@param screenX number
---@param screenY number
---@return number x, number y
function graphics:to_resolution(screenX, screenY)
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local _resolutionX = (screenX) * (resolutionX / 1920)
    local _resolutionY = (screenY) * (resolutionY / 1080)
    return (_resolutionX / resolutionX), (_resolutionY / resolutionY)
end

---@param entry string
---@param options SettingText
function graphics:draw_text(entry, options)
	assert(entry, "entry is required");
	assert(options, "options is required");
	assert(options.font, "options.font is required");
	assert(options.scale, "options.scale is required");
	assert(options.alignement, "options.alignement is required");
	assert(options.color, "options.color is required");
	assert(options.position, "options.position is required");

	local x, y = self:to_resolution(options.position.x, options.position.y);

	SetTextFont(options.font);
	SetTextScale(1.0, options.scale);
	SetTextColour(options.color.r, options.color.g, options.color.b, options.color.a);

	if (options.alignement == eTextAlignement.Centered) then
		SetTextCentre(true);
	elseif (options.alignement == eTextAlignement.Right) then
		SetTextRightJustify(true);
		SetTextWrap(0.0, x);
	else
		SetTextCentre(false);
	end

	if (options.wordWrap) then
		local _x, _ = toResolution(options.wordWrap, 0);
		SetTextWrap(_x, x + _x);
	end

	BeginTextCommandDisplayText("STRING");
	AddTextComponentSubstringPlayerName(entry);
	EndTextCommandDisplayText(x, y);
	return self;
end

---@param options SettingRect
function graphics:draw_rect(options)
	assert(options, "options is required");
	assert(options.width, "options.width is required");
	assert(options.height, "options.height is required");
	assert(options.position, "options.position is required");

    local _color = type(options.color) == 'table' and options.color or {r = 255, g = 255, b = 255, a = 255};
    local x, y = self:to_resolution(options.position.x, options.position.y);
    local width, height = self:to_resolution(options.width, options.height);
    DRAW_RECT(x + width * 0.5, y + height * 0.5, width, height, _color.r, _color.g, _color.b, _color.a);
	return self;
end

---@param options SettingSprite
function graphics:draw_sprite(options)
	assert(options, "options is required");
	assert(options.textureDict, "options.textureDict is required");
	assert(options.textureName, "options.textureName is required");
	assert(options.position, "options.position is required");
	assert(options.width, "options.width is required");
	assert(options.height, "options.height is required");

	self:request_texture_dict(options.textureDict);

	local _color = type(options.color) == 'table' and options.color or {r = 255, g = 255, b = 255, a = 255};
	local x, y = self:to_resolution(options.position.x, options.position.y);
	local width, height = self:to_resolution(options.width, options.height);

	DRAW_SPRITE(options.textureDict, options.textureName, x + width * 0.5, y + height * 0.5, width, height, 0.0, _color.r, _color.g, _color.b, _color.a);
	return self;
end

---@param options SettingText
function graphics:addRectangle(options)
	self.data[#self.data + 1] = {type = "rect", options = options};
	return self;
end

---@param entry string
---@param options SettingText
function graphics:addText(entry, options)
	self.data[#self.data + 1] = {type = "text", options = options, entry = entry};
	return self;
end

---@param options SettingSprite
function graphics:addSprite(options)
	self.data[#self.data + 1] = {type = "sprite", options = options};
	return self;
end

---@private
function graphics:render()
	if (not self.started) then return; end
	CreateThread(function()
		while self.started do
			for i = 1, #self.data do
				local item = self.data[i];
				if (not item) then goto continue end
				if (item.type == "rect") then
					self:draw_rect(item.options);
				elseif (item.type == "text") then
					self:draw_text(item.entry, item.options);
				elseif (item.type == "sprite") then
					self:draw_sprite(item.options);
				end
				::continue::
			end
			Wait(0);
		end
	end);
	return self;
end

function graphics:start()
	self.started = true;
	self:render();
	return self;
end

function graphics:stop()
	self.started = false;
	return self;
end

function graphics:toggle()
	self.started = not self.started;
	if (self.started) then
		self:render();
	end
	return self;
end

function graphics:clear()
	self.data = {};
	return self;
end

function graphics:destroy()
	self:clear();
	self:stop();
	return self;
end

print("OKKK")

---EXAMPLE:

-- ---@type GraphicsContext
-- local context = class.instance("GraphicsContext")
-- 	:addText("Il a pas dit bonjour", {
-- 		font = eTextFont.ChaletLondon,
-- 		scale = 0.2,
-- 		alignement = eTextAlignement.Centered,
-- 		color = {r = 255, g = 255, b = 255, a = 255},
-- 		position = {x = 1840, y = 1025}
-- 	})
-- 	:addRectangle( {
-- 		width = 200,
-- 		height = 30,
-- 		color = {r = 0, g = 0, b = 0, a = 175},
-- 		position = {x = 1720, y = 980}
-- 	})
-- 	:addRectangle({
-- 		width = 200,
-- 		height = 30,
-- 		color = {r = 0, g = 0, b = 0, a = 175},
-- 		position = {x = 1720, y = 1020}
-- 	})
-- 	:addSprite({
-- 		textureDict = "commonmenu",
-- 		textureName = "interaction_bgd",
-- 		color = {r = 255, g = 255, b = 255, a = 255},
-- 		position = {x = 250, y = 250},
-- 		width = 400.0,
-- 		height = 75
-- 	});

-- context:start();

-- RegisterCommand("toggle_context", function()
-- 	context.toggle();
-- end, false);