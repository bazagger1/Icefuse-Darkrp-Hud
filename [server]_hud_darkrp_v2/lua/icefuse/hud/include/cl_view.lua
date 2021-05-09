--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hud_darkrp_v2/lua/icefuse/hud/include/cl_view.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

--[[ -----------------------------------------------------------
	This script was made by ikefi
		http://steamcommunity.com/id/ikefi/
------------------------------------------------------------- ]]

local Addon = IcefuseHUD

local __identifier = Addon.identifier

--------------------------------------------------------------------------------

local math_abs = math.abs
local math_sin = math.sin
local math_clamp = math.Clamp

local string_Comma = string.Comma

local table_concat = table.concat

local CurTime = CurTime
local LocalPlayer = LocalPlayer
local Lerp = Lerp
local GetGlobalBool = GetGlobalBool
local Color = Color
local ScrW, ScrH = ScrW, ScrH

local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_DrawText = surface.DrawText
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize

local render_SetScissorRect = render.SetScissorRect
local render_SetMaterial = render.SetMaterial
local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local render_GetScreenEffectTexture = render.GetScreenEffectTexture
local render_DrawTextureToScreen = render.DrawTextureToScreen
local render_GetRenderTarget = render.GetRenderTarget
local render_SetRenderTarget = render.SetRenderTarget

local draw_RoundedBox = draw.RoundedBox
local draw_SimpleText = draw.SimpleText
local draw_DrawText = draw.DrawText

--------------------------------------------------------------------------------

local playerMeta = FindMetaTable('Player')

do

		-- For testing purposes
	if playerMeta.getXP == nil then

		function playerMeta:getXP()
		    return 18601
		end

		function playerMeta:getMaxXP()
		    return 24213
		end

		function playerMeta:getLevel()
		    return 11
		end
	end

	timer.Simple(0, function()

		-- Fixes for client side xp/level functions...
		if LevelSystemConfiguration ~= nil then

			function playerMeta:getXP()
				return self:getDarkRPVar('xp') or 0
			end

			function playerMeta:getMaxXP()
				local level = self:getLevel()
				return (10 + (level * (level + 1) * 90)) * LevelSystemConfiguration.XPMult
			end

			function playerMeta:getLevel()
				return self:getDarkRPVar('level') or 1
			end

		end

	end)

end

--------------------------------------------------------------------------------

--
-- Command to show or hide the hud
--
concommand.Add('icefuse_showhud', function(ply, cmd, args)
    if args[1] == '0' then
        Addon.closeView()
    else
        Addon.openView()
    end
end)

--------------------------------------------------------------------------------

Addon._view = Addon._view or nil

--[[ ]]
function Addon.openView()
    Addon.closeView()
    Addon._view = Addon.createView()
end

--[[ ]]
function Addon.closeView()
    if IsValid(Addon._view) == true then
        Addon._view:Remove()
    end
    Addon._view = nil
end

--[[ ]]
function Addon.toggleView()
    if IsValid(Addon._view) == true then
        Addon.closeView()
    else
        Addon.openView()
    end
end

--------------------------------------------------------------------------------

local FONT_BAR_GENERIC = 'IcefuseHUD.bar.generic'

surface.CreateFont('IcefuseHUD.tiny', {
    font = 'Roboto',
    size = 14,
    weight = 300,
    antialias = true
})

surface.CreateFont(FONT_BAR_GENERIC, {
    font = 'Roboto',
    size = 14,
    weight = 800,
    antialias = true,
	shadow = false
})

surface.CreateFont('IcefuseHUD.ammo', {
    font = 'Roboto',
    size = 28,
    weight = 400,
    antialias = true
})

surface.CreateFont('IcefuseHUD.ammo.small', {
    font = 'Roboto',
    size = 20,
    weight = 400,
    antialias = true
})

surface.CreateFont('IcefuseHUD.head.name', {
    font = 'Roboto',
    size = 28,
    weight = 800,
    antialias = true
})
surface.CreateFont('IcefuseHUD.head.job', {
    font = 'Roboto',
    size = 24,
    weight = 800,
    antialias = true
})
surface.CreateFont('IcefuseHUD.head.wanted', {
    font = 'Roboto',
    size = 20,
    weight = 800,
    antialias = true
})
surface.CreateFont('IcefuseHUD.head.wantedReason', {
    font = 'Roboto',
    size = 18,
    weight = 800,
    antialias = true,
    shadow = false
})

surface.CreateFont('IcefuseHUD.agenda.title', {
    font = 'Roboto',
    size = 14,
    weight = 800,
    antialias = true,
    shadow = false
})
surface.CreateFont('IcefuseHUD.agenda.text', {
    font = 'Roboto',
    size = 16,
    weight = 400,
    antialias = true,
    shadow = false
})

surface.CreateFont('IcefuseHUD.notify', {
    font = 'Roboto',
    size = 19,
    weight = 500,
    antialias = true,
    shadow = false
})

--------------------------------------------------------------------------------

local ICON_HEALTH = Material('icefuse/hud/icons/hh_minify_hp.png', 'noclamp smooth')
local ICON_ARMOR = Material('icefuse/hud/icons/hh_minify_armor.png', 'noclamp smooth')
local ICON_ENERGY = Material('icefuse/hud/icons/hh_minify_hunger.png', 'noclamp smooth')
local ICON_MONEY = Material('icefuse/hud/icons/hh_money.png', 'noclamp smooth')
local ICON_CLOCK = Material('icefuse/hud/icons/hh_clock_2.png', 'noclamp smooth')

-- local ICON_EXPERIENCE = Material('icefuse/hud/icons/hh_minify_xp.png', 'noclamp smooth')

local ICON_LICENSE = Material('icefuse/hud/icons/hh_license.png', 'noclamp smooth')
local ICON_WANTED = Material('icefuse/hud/icons/hh_wanted.png', 'noclamp smooth')
local ICON_LOCKDOWN = Material('icefuse/hud/icons/hh_lockdown.png', 'noclamp smooth')

--------------------------------------------------------------------------------

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_BLACK = Color(0, 0, 0)

local COLOR_BAR_ICON = Color(230, 230, 230)
local COLOR_BAR_TEXT = Color(230, 230, 230)

local COLOR_BAR_HEALTH = Color(205, 0, 5)
local COLOR_BAR_ARMOR = Color(8, 113, 188)
local COLOR_BAR_ENERGY = Color(206, 159, 23)

local COLOR_BAR_MONEY = Color(140, 140, 140)
local COLOR_BAR_TIME = Color(14, 160, 65)

local COLOR_BAR_EXPERIENCE = Color(8, 168, 0)

local COLOR_STATUS_ICON_OFF = Color(0, 0, 0, 0)

local COLOR_BAR_SHADOW = Color(255, 255, 255, 18)
local COLOR_BAR_BORDER = Color(40, 40, 40, 240)

--------------------------------------------------------------------------------

local MATERIAL_BLUR = Material("pp/blurscreen")
local MATERIAL_PANEL_BLUR = Material("pp/blurscreen")

--[[
- Draw a blured rectangle on the screen.
- @arg number x
- @arg number y
- @arg number w
- @arg number h
]]
local function drawBluredRect(x, y, w, h)
	local amount, heavyness = 6, 3

	render_SetScissorRect(x, y, x + w, y + h, true)

		surface_SetDrawColor(255, 255, 255)
		surface_SetMaterial(MATERIAL_BLUR)

		for i=1, heavyness do
			MATERIAL_BLUR:SetFloat('$blur', (i / 3) * amount)
			MATERIAL_BLUR:Recompute()

			render_UpdateScreenEffectTexture()
			surface_DrawTexturedRect(0, 0, ScrW(), ScrH())

		end

	render_SetScissorRect(0, 0, 0, 0, false)

end

--[[
- Draws a blured rectangle over the whole panel.
- @arg panel panel
]]
local function drawBluredPanel(panel)
    local x, y = panel:LocalToScreen(0, 0)
    local w, h = panel:GetSize()

	local amount, heavyness = 6, 3

	surface_SetDrawColor(255, 255, 255)
	surface_SetMaterial(MATERIAL_PANEL_BLUR)

	for i=1, heavyness do
		MATERIAL_PANEL_BLUR:SetFloat('$blur', (i / 3) * amount)
		MATERIAL_PANEL_BLUR:Recompute()

		render_UpdateScreenEffectTexture()
		surface_DrawTexturedRect(-x, -y, ScrW(), ScrH())

	end

end

--[[ ]]
local function drawProgressBar(x, y, w, h, progress, color)

    -- Background
    surface_SetDrawColor(80, 80, 80, 200)
    surface_DrawRect(x, y, w, h)

	surface_SetDrawColor(color)
	surface_DrawRect(x, y, w * progress, h)

    -- The slight tint for shadow effect
    surface_SetDrawColor(COLOR_BAR_SHADOW)
    surface_DrawRect(x, y, w, 5)

    -- The border
    surface_SetDrawColor(COLOR_BAR_BORDER)
    surface_DrawOutlinedRect(x, y, w, h)

end

--[[ ]]
local function drawIcon(x, y, w, h, material, color)
	surface_SetMaterial(material)
	surface_SetDrawColor(color)
	surface_DrawTexturedRect(x, y, w, h)
end

--[[
-
]]
local function textWrap(text, maxWidth, maxHeight)
	local dotsWidth, height = surface.GetTextSize('...')

	local lines = {}	-- The lines
	local usedWidth = 0 -- Remaining text width

	-- Each line..
	for _, split in ipairs(('[\n\t]'):Explode(text, true)) do
		local width = surface.GetTextSize(split)

		-- Whether line does not have to be wrapped..
		if width < maxWidth then
			lines[#lines + 1] = split

			continue
		end

		--------------------------------------------------
		-- Wrap the words

		local words = {}

		-- Each word..
		for _, word in ipairs((' '):Explode(split, false)) do
			local width = surface.GetTextSize(word)

			-- Whether word does not have to be wrapped..
			if usedWidth + width < maxWidth then

				usedWidth = usedWidth + width
				words[#words + 1] = word

				continue
			end

			-- Whether the word itself is too long
			if width > maxWidth then
				-- Shorten the word..

				usedWidth = usedWidth + dotsWidth

				local chars = {}

				-- Each character..
				for index, char in ipairs((''):Explode(text, false)) do
					local width = surface.GetTextSize(char)

					-- Whether word should not be ended yet..
					if usedWidth + width < maxWidth then

						usedWidth = usedWidth + width
						chars[#chars + 1] = char

						continue
					end

					chars[#chars + 1] = '...'

					break
				end

				word = table.concat(chars, '')

			end

			if #words > 0 then
				usedWidth = 0
				lines[#lines + 1] = table.concat(words, ' ')
			end

			words = {word}

		end

		usedWidth = 0
		lines[#lines + 1] = table.concat(words, ' ')

	end

	--------------------------------------------------
	-- Concat the whole thing

	local linesToConcat = {}
	for i=1, math.Clamp(#lines, 0, math.floor(maxHeight / height) - 1) do
		linesToConcat[i] = lines[i]
	end

	if #linesToConcat < #lines then
		linesToConcat[#linesToConcat + 1] = '...'
	end

	return table.concat(linesToConcat, '\n')
end

--[[
-
]]
local function lerp(t, from, to, maxDiff)
	local r = Lerp(t, from, to)

	-- Max differense, so that it won't endlessly change
	if math.abs(from - to) < (maxDiff == nil and .2 or maxDiff) then
		return to
	end

	return r
end

--------------------------------------------------------------------------------
-- HUD

local BAR_HEIGHT = 30					-- Bar height

local BAR_ICON_SIZE = 12

local BAR_GENERIC_OFFSET = 8			-- Generic bar offset from the top
local BAR_GENERIC_OFFSET_HOR = 0		-- Generic bar offset horizontally
local BAR_GENERIC_HEIGHT = 20			-- Generic bar height
local BAR_GENERIC_WIDTH = 190			-- Generic bar width

local BAR_EXPERIENCE_OFFSET = 0			-- Experience bar offset from the top
local BAR_EXPERIENCE_HEIGHT = 9			-- Experience bar height

local INIT_TIME = CurTime()

--[[
- The main bar of the HUD.
]]
function Addon.drawBar(options, client, width, height)
    local x, y = 0, 0
    local w, h = width, BAR_HEIGHT

	--------------------------------------------------
	-- Calculations

    local health = client:Health() or 0
    if options.health ~= health then
        options.health = lerp(FrameTime() * 2, options.health or health, health)
        options.healthProgress = math_clamp(options.health * (1 / client:GetMaxHealth()), 0, 1)
    end

	local armor = client:Armor() or 0
	if options.armor ~= armor then
		options.armor = lerp(FrameTime() * 2, options.armor or armor, armor)
		options.armorProgress = math_clamp(options.armor * (1 / 100), 0, 1)
	end

    local energy = client:getDarkRPVar('Energy') or 65
    if options.energy ~= energy then
        options.energy = lerp(FrameTime() * 2, options.energy or energy, energy)
        options.energyProgress = math_clamp(options.energy * (1 / 100), 0, 1)
    end

    local money = client:getDarkRPVar('money') or 0
	if options.money ~= money then
		options.moneyText = "$" .. string_Comma(money)
	end

	local salary = client:getDarkRPVar('salary') or 0
	if options.salary ~= salary then
		options.salaryText = string_Comma(salary) .. "/ hr"
	end

	--------------------------------------------------

    -- -- Blured background
    -- surface_SetDrawColor(255, 255, 255)
    -- drawBluredRect(x, y, width, BAR_HEIGHT + BAR_EXPERIENCE_HEIGHT)
	--
    -- -- Black background
    -- surface_SetDrawColor(0, 0, 0, 180)
    -- surface_DrawRect(x, y, width, BAR_HEIGHT)

	-- Gradient
	do
		local w, h = w, h + 12
		local x, y = x + w * .5, 0

		y = y + h * .5
		y = y + BAR_EXPERIENCE_HEIGHT

		surface_SetMaterial(Material('gui/gradient'))
		surface_SetDrawColor(Color(0, 0, 0, 180))
		surface.DrawTexturedRectRotated(x, y, h, w, -90)

	end

	-- if true then
	-- 	return
	-- end

    -- Bars
    do
		local x, y = x, y + BAR_GENERIC_OFFSET

	    surface_SetFont(FONT_BAR_GENERIC)
		surface_SetTextColor(COLOR_BAR_TEXT)

        -- Health
        do
            local x = x
			local w, h = BAR_GENERIC_WIDTH, BAR_GENERIC_HEIGHT

            drawProgressBar(x, y, w, h, options.healthProgress, COLOR_BAR_HEALTH)
            drawIcon(x + 4, y + 4, BAR_ICON_SIZE, BAR_ICON_SIZE, ICON_HEALTH, COLOR_BAR_ICON)

            local textW, textH = surface_GetTextSize(health)
            surface_SetTextPos(x + w - textW - 5, y + 3)
            surface_DrawText(health)

        end

        -- Armor
        do
            local x = x + BAR_GENERIC_WIDTH - 1
			local w, h = BAR_GENERIC_WIDTH, BAR_GENERIC_HEIGHT

            drawProgressBar(x, y, w, h, options.armorProgress, COLOR_BAR_ARMOR)
            drawIcon(x + 4, y + 4, BAR_ICON_SIZE, BAR_ICON_SIZE, ICON_ARMOR, COLOR_BAR_ICON)

            local textW, textH = surface_GetTextSize(armor)
            surface_SetTextPos(x + w - textW - 5, y + 3)
            surface_DrawText(armor)

        end

        -- Hunger
        if options.energyProgress ~= nil then
            local x = x + BAR_GENERIC_WIDTH * 2 - 2
			local w, h = BAR_GENERIC_WIDTH, BAR_GENERIC_HEIGHT

            drawProgressBar(x, y, w, h, options.energyProgress, COLOR_BAR_ENERGY)
            drawIcon(x + 4, y + 4, BAR_ICON_SIZE, BAR_ICON_SIZE, ICON_ENERGY, COLOR_BAR_ICON)

			local text = math.Round(energy) .. '%'
            local textW, textH = surface_GetTextSize(text)
            surface_SetTextPos(x + w - textW - 5, y + 3)
            surface_DrawText(text)

        end

        -- Money
        do
			local x = (x + w) - 145 - 125 - 160 + 2
			local w, h = 160, BAR_GENERIC_HEIGHT

			local payDelay = GAMEMODE.Config.paydelay

            drawProgressBar(x, y, w, h, ((CurTime() - INIT_TIME) % payDelay) / payDelay,  COLOR_BAR_MONEY)
            drawIcon(x + 5, y + 4, BAR_ICON_SIZE, BAR_ICON_SIZE, ICON_MONEY, COLOR_BAR_TEXT)

            surface_SetTextPos(x + BAR_ICON_SIZE + 8, y + 4)
            surface_DrawText(options.salaryText)

            local textW, textH = surface_GetTextSize(options.moneyText)
            surface_SetTextPos(x + w - textW - 5, y + 4)
            surface_DrawText(options.moneyText)

        end

        -- -- Level
        do
			local x = (x + w) - 145 - 125 + 1
			local w, h = 125, BAR_GENERIC_HEIGHT

            drawProgressBar(x, y, w, h, 0,  COLOR_BAR_TIME)

			local experience, maxExperience, level = client:getXP(), client:getMaxXP(), client:getLevel()
			local levelText = "level " .. level
			local experienceText = math.ceil(100 / maxExperience * experience) .. '%'

            surface_SetTextPos(x + 5, y + 4)
            surface_DrawText(levelText)

            local textW, textH = surface_GetTextSize(experienceText)
            surface_SetTextPos(x + w - textW - 5, y + 4)
            surface_DrawText(experienceText)

        end

		-- Time
        do
			local x = (x + w) - 145
			local w, h = 145, BAR_GENERIC_HEIGHT

			local time, date = os.date('%H:%M'), os.date('%m/%d/%Y')

            drawProgressBar(x, y, w, h, 0, COLOR_BAR_TIME)
            drawIcon(x + 4, y + 4, BAR_ICON_SIZE, BAR_ICON_SIZE, ICON_CLOCK, COLOR_BAR_TEXT)

            surface_SetTextPos(x + BAR_ICON_SIZE + 8, y + 3)
            surface_DrawText(time)

            local textW, textH = surface_GetTextSize(date)
            surface_SetTextPos(x + w - textW - 5 , y + 3)
            surface_DrawText(date)

        end

    end

	-- Level & Experience
    do
        local x, y = x, BAR_EXPERIENCE_OFFSET
		local w, h = width, BAR_EXPERIENCE_HEIGHT

		local experience, maxExperience, level = client:getXP(), client:getMaxXP(), client:getLevel()
		local progress = (1 / maxExperience) * experience

		surface_SetDrawColor(100, 100, 100, 240)
		surface_DrawRect(x, y, w, h)

		surface_SetDrawColor(COLOR_BAR_EXPERIENCE)
		surface_DrawRect(x, y, w * progress, h)

	    -- The slight tint for shadow effect
	    surface_SetDrawColor(255, 255, 255, 30)
	    surface_DrawRect(x, y, w, 3)

		-- Border at the bottom
		surface_SetDrawColor(20, 20, 20, 200)
		surface_DrawOutlinedRect(x, y + h - 1, w, 1)

		-- The stripes that mark every 5%
		for i=1, 39 do
			surface_SetDrawColor(10, 10, 10, 60)
			surface_DrawRect(x + w * (1 / 40) * i, y, 1, h)
		end

		-- -- Text
		--
		-- surface_SetFont('IcefuseHUD.small')
		--
		-- surface_SetTextPos(x + w - textW - 2, y + h + 2)
		-- surface_SetTextColor(Color(0, 0, 0, 180))
		-- surface_DrawText(text)
		--
		-- surface_SetTextPos(x + w - textW - 3, y + h + 1)
		-- surface_SetTextColor(Color(240, 240, 240, 220))
		-- surface_DrawText(text)

    end

	-- Draw the icons..
	Addon.drawStatusIcons(options, client, width, height)

end

--[[ ]]
function Addon.drawStatusIcons(options, client, width, height)
    local x, y = width - 453, 13

	local pulse = math_abs(math_sin(SysTime() * 2))
	local pulseColor = Color(200 * pulse, 200 * pulse, 0, math_clamp(255 * pulse, 100, 255))

    -- Lockdown
	if GetGlobalBool('DarkRP_LockDown') then
		drawIcon(x, y, 16, 16, ICON_LOCKDOWN, pulseColor)
		x = x - 22
	end

    -- Gun license
	if client:getDarkRPVar('HasGunlicense') then
		drawIcon(x, y, 16, 16, ICON_LICENSE, Color(220, 220, 220))
		x = x - 22
	end

	-- Wanted
	if client:isWanted() then
		drawIcon(x, y, 16, 16, ICON_WANTED, pulseColor)
	end

end

--[[ ]]
function Addon.drawAgenda(options, client, width, height)

    local agenda = client:getAgendaTable()
    if not agenda then
        return
    end

	surface_SetFont('IcefuseHUD.agenda.text')

	local agendaText = client:getDarkRPVar('agenda') or ""
	if options.agendaText ~= agendaText then
		options.agendaText = agendaText
		options.agendaParsedText = textWrap(agendaText:Trim():gsub('//', '\n'):gsub('\\n', '\n'), 380, 300)
	end

 	local textW, textH = surface_GetTextSize(options.agendaParsedText)
	if options.agendaParsedText == '' then
		textH = 0
	end

    local w, h = math.Clamp(textW + 12, 190, 390), 24 + textH + 5
    local x, y = width - w - 8, 38

	-- Blured background
	surface_SetDrawColor(255, 255, 255)
	drawBluredRect(x, y, w, h)

	-- Black background
	surface_SetDrawColor(0, 0, 0, 180)
	surface_DrawRect(x, y, w, h)

	-- Black outline
	surface_SetDrawColor(0, 0, 0, 100)
	surface_DrawOutlinedRect(x, y, w, h)

	-- Text
	draw_DrawText(options.agendaParsedText, 'IcefuseHUD.agenda.text',
        x + 5, y + 24, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Title
    do

        -- Black background
        surface_SetDrawColor(0, 0, 0, 120)
    	surface_DrawRect(x, y, w, 22)

        -- Black outline
        surface_SetDrawColor(0, 0, 0, 100)
    	surface_DrawOutlinedRect(x, y, w, 22)

        surface_SetTextColor(Color(255, 255, 255, 200))
        surface_SetFont('IcefuseHUD.agenda.title')
        surface_SetTextPos(x + 5 + 16, 5 + y)
        surface_DrawText(agenda.Title)

    end

end

--[[ ]]
function Addon.drawAmmunition(options, client, width, height)

    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) == false then
        return
    end

    local x, y = width, height
    local w, h = 0, 0

    local primaryAmmo = weapon:Clip1()
    local secondaryAmmo = weapon:Clip2()

    local primaryType = weapon:GetPrimaryAmmoType()
    local secondaryType = weapon:GetSecondaryAmmoType()

    local totalPrimaryAmmo = client:GetAmmoCount(weapon:GetPrimaryAmmoType())
    local totalSecondaryAmmo = client:GetAmmoCount(weapon:GetSecondaryAmmoType())

    local x, y = x - 20, y - 15
    local w, h = 140, 40

    local text = {}

    if primaryType ~= -1 and primaryAmmo ~= -1 then
        text[#text + 1] = tostring(primaryAmmo)
    end
    if secondaryType ~= -1 and secondaryAmmo ~= -1 then
        text[#text + 1] = " + "
        text[#text + 1] = tostring(secondaryAmmo)
    end

    if totalPrimaryAmmo > 0 or totalSecondaryAmmo > 0 then
        if #text > 0 then
            text[#text + 1] = " /"
        end
        if totalPrimaryAmmo > 0 then
            text[#text + 1] = " "
            text[#text + 1] = tostring(totalPrimaryAmmo)
        end
        if totalSecondaryAmmo > 0 then
            text[#text + 1] = " + "
            text[#text + 1] = tostring(totalSecondaryAmmo)
        end
    end

    text = table.concat(text)
    if text ~= "" then

		draw.SimpleText(
            "Ammo", 'IcefuseHUD.ammo.small',
            x + 1, y - 34 + 1,
            Color(0, 0, 0),
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
        )

        draw.SimpleText(
            "Ammo", 'IcefuseHUD.ammo.small',
            x, y - 34,
            Color(255, 255, 255),
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
        )

        draw.SimpleText(
            text, 'IcefuseHUD.ammo',
            x + 1, y + 1,
            Color(0, 0, 0),
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
        )

        draw.SimpleText(
            text, 'IcefuseHUD.ammo',
            x, y,
            Color(255, 255, 255),
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
        )

    end

end

--------------------------------------------------------------------------------
-- World drawing

local nextTick = 0
local playersToDraw = {}
hook.Add('Think', 'IcefuseHUD.playersToDraw', function()

    if nextTick > SysTime() then
        return
    end
    nextTick = SysTime() + .2

    local client = LocalPlayer()
    local clientPos = client:GetShootPos()
    local clientAimVector = client:GetAimVector()

    playersToDraw = {}
    for _, ply in ipairs(player.GetAll()) do

        -- Ignore local player, dead players and players that should not be drawn
        if ply == client or ply:Alive() == false or ply:GetNoDraw() == true then
            continue
        end

        local pos = ply:GetShootPos()
        local distance = pos:DistToSqr(clientPos)

        -- Check if the player is within range for the wanted HUD
        if distance > 1000 ^ 2 then
            continue
        end

        local posDifference = pos - clientPos

        -- Ignore if the client can't see the player
        local trace = util.QuickTrace(clientPos, posDifference, client)
        if trace.Hit and trace.Entity ~= ply then
            continue
        end

        if ply:isWanted() then
            -- Draw the player's wanted HUD
            playersToDraw[ply] = 2
        end

        -- Check if the player is within range
        if distance > 350 ^ 2 then
            continue
        end

        -- Ignore if the player is not 'almost' looking at the player
        if posDifference:GetNormalized():Dot(clientAimVector) < 0.95 then
            continue
        end

        if playersToDraw[ply] == nil then
            playersToDraw[ply] = 1
        else
            playersToDraw[ply] = 3
        end

    end

end)

--[[ ]]
function Addon.drawPlayers(options, client)
    for ply, n in pairs(playersToDraw) do

        if not IsValid(ply) then
            continue
        end

        local position
        local index = ply:LookupBone('ValveBiped.Bip01_Head1')
        if index ~= nil then
            position = ply:GetBonePosition(index) + Vector(0, 0, 20)
        else
            position = ply:EyePos() + Vector(0, 0, 20)
        end

        local screen = position:ToScreen()
        local x, y = screen.x, screen.y

        if n == 1 or n == 3 then
            local teamIndex = ply:Team()

            local jobTextWidth, _ = draw.SimpleTextOutlined(
                team.GetName(teamIndex), 'IcefuseHUD.head.job',
                x, y,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,
                1, Color(0, 0, 0, 40)
            )

            local teamColor = team.GetColor(teamIndex)
            draw.SimpleTextOutlined(
                ply:Nick(), 'IcefuseHUD.head.name',
                x, y - 24,
                teamColor,
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,
                1, Color(teamColor.r - 120, teamColor.g - 120, teamColor.b - 120, 80)
            )

            if ply:getDarkRPVar('HasGunlicense') then
                drawIcon(x - jobTextWidth * .5 - 21, y + 3, 20, 20, ICON_LICENSE, Color(0, 0, 0, 80))
                drawIcon(x - jobTextWidth * .5 - 20, y + 4, 18, 18, ICON_LICENSE, Color(255, 255, 255))
            end

            y = y - 24

        end

        if n == 2 or n == 3 then

            draw.SimpleTextOutlined(
                ply:getWantedReason(), 'IcefuseHUD.head.wantedReason',
                x, y - 22,
                Color(255, 155, 155, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,
                1, Color(0, 0, 0, 80)
            )
            draw.SimpleTextOutlined(
                "Wanted", 'IcefuseHUD.head.wanted',
                x, y - 44,
                Color(255, 60, 60, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,
                1, Color(0, 0, 0, 80)
            )

        end

    end
end

--[[ ]]
function Addon.drawDoorInfo(options, client)

    local entity = client:GetEyeTrace().Entity
    if IsValid(entity) and entity:isKeysOwnable() and entity:GetPos():DistToSqr(client:GetPos()) < 40000 then
        entity:drawOwnableInfo()
    end

end

--------------------------------------------------------------------------------
-- Main HUD loop

--[[ ]]
function Addon.HUDPaint(options, width, height)
	local client = LocalPlayer()

	if hook.Call('HUDShouldDraw', nil, IcefuseHUD.identifier) == false then
		return
	end

	--------------------------------------------------
	-- World rendering

    -- Door info
    Addon.drawDoorInfo(options, client)

    -- Above head HUD
    Addon.drawPlayers(options, client)

	--------------------------------------------------
	-- HUD rendering

	-- Bar
    Addon.drawBar(options, client, width, height)

    -- Agenda
    Addon.drawAgenda(options, client, width, height)

    -- Ammunition, etc...
    Addon.drawAmmunition(options, client, width, height)

end

--[[ ]]
function Addon.createView()

    local options = {}

    local window = vgui.Create('EditablePanel')
    options.window = window

    window:SetPos(0, 0)
    window:SetSize(ScrW(), ScrH())
    window:SetMouseInputEnabled(false)
    window:SetKeyboardInputEnabled(false)

	window:MoveToBack()

    window.Paint = function(pnl, width, height)
        Addon.HUDPaint(options, width, height)
    end

    return window
end

--------------------------------------------------------------------------------

--
-- Show the HUD when the player is valid
--
hook.Add('Tick', 'IcefuseHUD.onValidClient', function()
	if IsValid(LocalPlayer()) then
		hook.Remove('Tick', 'IcefuseHUD.onValidClient')

		Addon.openView()

	end
end)

--
-- Check for screen resolution changes.
-- We want the HUD to scale with the resolution of the screen.
--
do
    local width, height = ScrW(), ScrH()

    local nextTick = 0
    hook.Add('Tick', 'IcefuseHUD.screenResolution', function()
        if nextTick <= SysTime() then
            nextTick = SysTime() + 5

            if width ~= ScrW() or height ~= ScrH() then

                -- Recreate the view
                Addon.openView()

            end

        end
    end)

end

--
-- Disable default HUDs
--
local DISABLED_HUDS = {

	-- GMod
	['CHudHealth'] = false,                                                 	-- Player health
    ['CHudBattery'] = false,                                                	-- Suit battery
    ['CHudSuitPower'] = false,                                              	-- Suit power
    ['CHudAmmo'] = false,                                                    	-- Weapon ammo
	-- ['CHudWeaponSelection'] = false,											-- Player weapon selection menu
	['CHudTrain'] = false,														-- Controls when using a func_train?

	-- DarkRP
    ['DarkRP_HUD'] = false,                                                     -- Controls all DarkRP huds including arrested, lockdown, etc
    ['DarkRP_LocalPlayerHUD'] = false,                                          -- Bottom left hud
    ['DarkRP_EntityDisplay'] = false,                                           -- Info for doors, vehicles, and above player head
    ['DarkRP_ZombieInfo'] = false,                                              -- Information from /showzombie
    ['DarkRP_Hungermod'] = false,                                               -- Hunger mod information
    ['DarkRP_Agenda'] = false,                                              	-- Agenda hud

}

--[[
- @param string name
]]
hook.Add('HUDShouldDraw', 'IcefuseHUD', function(name)
    return DISABLED_HUDS[name]
end)

--[[
-
]]
hook.Add('HUDDrawTargetID', 'IcefuseHUD', function()
	return false
end)

--[[
-
]]
hook.Add('HUDDrawPickupHistory', 'IcefuseHUD', function()
	return false
end)

--------------------------------------------------------------------------------

-- usermessage.Hook("GotArrested", function(msg)
--     local StartArrested = CurTime()
--     local ArrestedUntil = msg:ReadFloat()
--
--     Arrested = function()
--         local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_ArrestedHUD")
--         if shouldDraw == false then return end
--
--         if CurTime() - StartArrested <= ArrestedUntil and localplayer:getDarkRPVar("Arrested") then
--             draw.DrawNonParsedText(DarkRP.getPhrase("youre_arrested", math.ceil((ArrestedUntil - (CurTime() - StartArrested)) * 1 / game.GetTimeScale())), "DarkRPHUD1", Scrw / 2, Scrh - Scrh / 12, colors.white, 1)
--         elseif not localplayer:getDarkRPVar("Arrested") then
--             Arrested = function() end
--         end
--     end
-- end)

-- Notifications paint
--------------------------------------------------------------------------------

local NoticeCotnrolTable = vgui.GetControlTable('NoticePanel')

function NoticeCotnrolTable:Init()

	self:DockPadding( 3, 3, 3, 3 )

	self.Label = vgui.Create('DLabel', self)
	self.Label:Dock( FILL )
	self.Label:SetFont('IcefuseHUD.notify')
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	self.Label:SetContentAlignment( 5 )

	self:SetBackgroundColor( Color( 20, 20, 20, 255 * 0.6 ) )

end

function NoticeCotnrolTable:Paint(w, h)

	-- self.BaseClass.Paint( self, w, h )

    -- Blured background
    surface.SetDrawColor(255, 255, 255)
    drawBluredPanel(self)

    -- Black background
    surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(0, 0, w, h)

    -- Black outline
    surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(0, 0, w, h)

	if ( !self.Progress ) then return end

	surface.SetDrawColor( 0, 100, 0, 150 )
	surface.DrawRect( 4, self:GetTall() - 10, self:GetWide() - 8, 5 )

	surface.SetDrawColor( 0, 50, 0, 255 )
	surface.DrawRect( 5, self:GetTall() - 9, self:GetWide() - 10, 3 )

	local w = self:GetWide() * 0.25
	local x = math.fmod( SysTime() * 200, self:GetWide() + w ) - w

	if ( x + w > self:GetWide() - 11 ) then w = ( self:GetWide() - 11 ) - x end
	if ( x < 0 ) then w = w + x; x = 0 end

	surface.SetDrawColor( 0, 255, 0, 255 )
	surface.DrawRect( 5 + x, self:GetTall() - 9, w, 3 )

end

local function DisplayNotify(msg)
   local txt = msg:ReadString()
   GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
   surface.PlaySound("buttons/lightswitch2.wav")

   -- Log to client console
   MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end
usermessage.Hook("_Notify", DisplayNotify)

-- Average FPS
--------------------------------------------------------------------------------

surface.CreateFont('IcefuseHUD.AverageFPS.big', {
    font = 'Arial',
    size = 32,
    weight = 600,
    antialias = true,
    shadow = false
})
surface.CreateFont('IcefuseHUD.AverageFPS.small', {
    font = 'Arial',
    size = 22,
    weight = 500,
    antialias = true,
    shadow = false
})

--------------------------------------------------------------------------------

--[[ ]]
Addon._averageFPS = Addon._averageFPS or {
    ticks = 0,
    time = 0,
    startTime = 0
}
local _aFPS = Addon._averageFPS

--[[ ]]
function Addon.paintAverageFPS()
    _aFPS.ticks, _aFPS.time = _aFPS.ticks + 1, _aFPS.time + RealFrameTime()

    local textWidth, textHeight = draw.SimpleTextOutlined(
		math.Round(1 / (_aFPS.time / _aFPS.ticks), 2), 'IcefuseHUD.AverageFPS.big',
		20, 20,
		Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 80)
	)
	draw.SimpleTextOutlined(
		math.Round(SysTime() - _aFPS.startTime, 2).." s", 'IcefuseHUD.AverageFPS.small',
		20, 20 + textHeight,
		Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 80)
	)

end

--[[ ]]
function Addon.toggleAverageFPS()

    if hook.GetTable()['DrawOverlay'] and hook.GetTable()['DrawOverlay']['IcefuseHUD.averageFPS'] then
        hook.Remove('DrawOverlay', 'IcefuseHUD.averageFPS')
    else
        hook.Add('DrawOverlay', 'IcefuseHUD.averageFPS', Addon.paintAverageFPS)
    end

    Addon.resetAverageFPS()

end

--[[ ]]
function Addon.resetAverageFPS()
    _aFPS.ticks, _aFPS.time, _aFPS.startTime = 0, 0, SysTime()
end
