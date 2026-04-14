--[[
                       __                   ___.            
  ____  __ __  _______/  |_  ____   _____   \_ |__    ____  
_/ ___\|  |  \/  ___/\   __\/  _ \ /     \   | __ \  / ___\ 
\  \___|  |  /\___ \  |  | (  <_> )  Y Y  \  | \_\ \/ /_/  >
 \___  >____//____  > |__|  \____/|__|_|  /  |___  /\___  / 
     \/           \/                    \/       \//_____/  
___.            ____  ______  .________.________.________   
\_ |__ ___.__. /_   |/  __  \ |   ____/|   ____/|   ____/   
 | __ <   |  |  |   |>      < |____  \ |____  \ |____  \    
 | \_\ \___  |  |   /   --   \/       \/       \/       \   
 |___  / ____|  |___\______  /______  /______  /______  /   
     \/\/                  \/       \/       \/       \/    
]]

local libs      = {} -- пользовательские библиотеки фонов
local libs_main = {'https://raw.githubusercontent.com/benchmerge/custombg/refs/heads/main/presets.json'}
local libs_alt  = {'https://raw.githubusercontent.com/benchmerge/custombg/refs/heads/main/presets_filegarden.json'}

local custom_presets = {
    ['umbrella'] = 'https://uc.zone/',
    -- ['название пресета'] = 'ссылка',
}

-- dependencies
local JSON = require('assets.JSON')

-- localization
local lang = Localizer.Get('Main') == 'Main' and 'en' or 'ru'

local locals = {
    en = {
        enable_bg = 'Enable custom background',
        url = 'URL',
        presets = 'Presets',
        hide_panels = 'Hide small panels',
        hide_chat = 'Hide chat',
        disable_clicks = 'Disable background clicks',
        blur = 'Blur',
        refresh = 'Refresh',
        load_presets = 'Load presets',
        dm = 'For any help DM me on Discord: 18555',
        alt_presets = 'Show alt presets'
    },
    ru = {
        enable_bg = 'Включить кастомный фон',
        url = 'Ссылка',
        presets = 'Пресеты',
        hide_panels = 'Скрыть мелкие панели',
        hide_chat = 'Скрыть чат',
        disable_clicks = 'Отключить клики по фону',
        blur = 'Блюр',
        refresh = 'Обновить',
        load_presets = 'Загрузить пресеты',
        dm = 'По любым вопросам - в ЛС в дискорде: \u{0007}{primary}18555',
        alt_presets = 'Отоброжать альт. пресеты'
    }
}

local l = locals[lang]

-- gradient
local function lerp(c1, c2, t)
    t = math.floor(t * 1e6 + 0.5) / 1e6
    local r1,g1,b1 = tonumber(c1:sub(1,2),16),tonumber(c1:sub(3,4),16),tonumber(c1:sub(5,6),16)
    local r2,g2,b2 = tonumber(c2:sub(1,2),16),tonumber(c2:sub(3,4),16),tonumber(c2:sub(5,6),16)
    return string.format("%02X%02X%02X",
        math.floor(r1+(r2-r1)*t),math.floor(g1+(g2-g1)*t),math.floor(b1+(b2-b1)*t))
end

local function grad(args)
    local colors  = args.colors or args[2] or {"ffffff"}
    local text    = args.text   or args[1]
    local dynamic = args.dynamic == nil and true or args.dynamic
    local speed   = args.speed  or args[3] or 1
    local loop    = args.loop    == nil and true  or args.loop
    local sine    = args.sine    == nil and false or args.sine

    if sine then
        local t = (math.sin(os.clock() * speed) + 1) / 2
        local color = lerp(colors[1], colors[2], t)
        if not text then return color end
        return ('\a%s%s'):format(color, text), color
    end

    local chars = {}
    if text then
        for _, c in utf8.codes(text) do chars[#chars+1] = utf8.char(c) end
    end
    local char_count = #chars

    local steps = math.max(char_count * 10, 100)
    local segs  = loop and #colors or (#colors - 1)

    local pal = {}
    if loop then
        for i = 1, #colors do
            local seg_steps = math.floor(steps / segs) + (i <= steps % segs and 1 or 0)
            local c1, c2 = colors[i], colors[(i % #colors) + 1]
            for j = 0, seg_steps - 1 do pal[#pal+1] = lerp(c1, c2, j / seg_steps) end
        end
    else
        for i = 1, #colors - 1 do
            local seg_steps = math.floor(steps / segs) + (i <= steps % segs and 1 or 0)
            local c1, c2 = colors[i], colors[i + 1]
            for j = 0, seg_steps - 1 do pal[#pal+1] = lerp(c1, c2, j / seg_steps) end
        end
        pal[#pal+1] = colors[#colors]
    end
    local total = #pal

    local offset = dynamic and (os.clock() * speed * 20) % total or 0

    local fp = math.floor(offset) + 1
    local first_color = pal[((fp - 1) % total) + 1]

    if not text then return first_color end

    local res = ""
    for i = 1, char_count do
        local pos
        if loop then
            pos = ((i - 1) * total / char_count + offset) % total
        else
            pos = math.min((i - 1) * total / char_count + offset, total - 1)
        end
        pos = math.floor(pos * 1e9 + 0.5) / 1e9
        local i1 = math.floor(pos) + 1
        local i2 = math.min(i1 + 1, total)
        res = res .. "\a" .. lerp(pal[i1], pal[i2], pos - math.floor(pos)) .. chars[i]
    end

    return res, first_color
end

-- ui creation
local grad_colors = { "3B3A5C", "5A51A0", "2E2A70" }

local tab = Menu.Create("Scripts", "Utility"):Create(grad({ 'Background', grad_colors, dynamic = false, loop = false }))
local secondtab = tab:Create("Main")

tab:Icon('\u{e2ca}')

local main = secondtab:Create("Main")
local customization = secondtab:Create("Custom")
local by = secondtab:Create(" "):Label('script by 18555')

-- logger
local function log(msg)
    Log.Write('[custombg] ' .. tostring(msg))
end

-- widgets
local enabled = main:Switch(l.enable_bg, false)
local show_alt_toggle = main:Switch(l.alt_presets, false)
local url = main:Input(l.url, '')
local preset_combo = main:Combo(l.presets, {}, 0)

customization:Switch(l.hide_panels, false):SetCallback(function(this)
    local panel = Panorama.GetPanelByName("TodayPages", false)
    if panel then
        panel:SetVisible(not this:Get())
    end
end, true)

customization:Switch(l.hide_chat, false):SetCallback(function(this)
    local panel = Panorama.GetPanelByName("Chat", false)
    if panel then
        panel:SetVisible(not this:Get())
    end
end, true)

local disable_interactions = customization:Switch(l.disable_clicks, true)
local blur = customization:Slider(l.blur, 0, 30, 0, function(v)
    return tostring(v) .. 'px'
end)

customization:Label(l.dm)

-- presets storage
local presets = {}
local preset_source = {}
local preset_names = {}

local function add_preset(name, preset_url, source)
    if not name or name == "" or not preset_url or preset_url == "" then return end
    presets[name] = preset_url
    preset_source[name] = source or 'user'
end

local function rebuild_preset_combo()
    preset_names = {}
    local show_alt = show_alt_toggle:Get()

    for name, _ in pairs(presets) do
        local src = preset_source[name]
        
        if src == 'main' and not show_alt then
            table.insert(preset_names, name)
        elseif src == 'alt' and show_alt then
            table.insert(preset_names, name)
        elseif src == 'user' or src == 'custom' then
            table.insert(preset_names, name)
        end
    end

    table.sort(preset_names)
    preset_combo:Update(#preset_names > 0 and preset_names or {}, 0)
end

local save_presets = function()
    local count = 0

    for _ in pairs(presets) do
        count = count + 1
    end

    Config.WriteInt("custombg_presets", "count", count)

    local i = 1
    for name, preset_url in pairs(presets) do
        local src = preset_source[name]
        if src ~= 'custom' then
            Config.WriteString("custombg_presets", i .. "_name", name)
            Config.WriteString("custombg_presets", i .. "_url", preset_url)
            Config.WriteString("custombg_presets", i .. "_source", src or 'user')
            i = i + 1
        end
    end

    log("saved presets: " .. count)
end

local load_presets = function()
    local count = Config.ReadInt("custombg_presets", "count", 0)

    log("load_presets count: " .. tostring(count))  -- добавь это

    if count == 0 then
        log("no saved presets")
        return
    end

    for i = 1, count do
        local name       = Config.ReadString("custombg_presets", i .. "_name", "")
        local preset_url = Config.ReadString("custombg_presets", i .. "_url", "")
        local source     = Config.ReadString("custombg_presets", i .. "_source", "user")
        add_preset(name, preset_url, source)
    end

    rebuild_preset_combo()
    log("loaded presets: " .. count)
end

local fetch_presets = function(libs_to_fetch, source)
    local pending = #libs_to_fetch
    if pending == 0 then return end

    for _, lib_url in ipairs(libs_to_fetch) do
        HTTP.Request("GET", lib_url, {
            headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36",
                ["Accept"] = "application/json, text/plain, */*",
                ["Connection"] = "keep-alive",
            }
        }, function(response)
            if response.code ~= 200 then
                log("failed load " .. lib_url .. ", code: " .. tostring(response.code))
            else
                local ok, data = pcall(function() return JSON:decode(response.response) end)
                if not ok or type(data) ~= "table" then
                    log("broken json: " .. data .. " " .. lib_url)
                else
                    local added = 0
                    for name, preset_url in pairs(data) do
                        add_preset(name, preset_url, source)
                        added = added + 1
                    end
                    log("loaded from " .. lib_url .. ": " .. tostring(added))
                end
            end

            pending = pending - 1
            rebuild_preset_combo()

            if pending <= 0 then
                save_presets()
                log("fetch presets done: " .. source)
            end
        end, lib_url)
    end
end

-- functions
local function apply_bg_style(bg)
    if not bg or not bg:IsValid() then return end

    local blur_px = blur:Get()
    local blocked = disable_interactions:Get()

    local style = "width: 100%; height: 100%; z-index: -999; blur: gaussian(" .. blur_px .. "px);"
    bg:SetStyle(style)

    Engine.RunScript(([[
        var p = $.GetContextPanel().FindChildTraverse("CustomBackground");
        if (p) p.enabled = %s;
    ]]):format(blocked and "false" or "true"))
end

local update = function()
    local parent = Panorama.GetPanelByName("DashboardBackgroundManager", false)
    if not parent then
        log("no DashboardBackgroundManager")
        return
    end

    local first_child = parent:GetFirstChild()
    if first_child then
        first_child:SetVisible(not enabled:Get())
    end

    local bg = Panorama.GetPanelByName("CustomBackground", false)

    if not enabled:Get() then
        if bg then
            Engine.RunScript('$.GetContextPanel().FindChildTraverse("CustomBackground").DeleteAsync(0)')
            log("background removed")
        end
        return
    end

    bg = bg or Panorama.CreatePanel("DOTAHTMLPanel", "CustomBackground", parent)
    log("panel created: " .. tostring(bg ~= nil) .. " valid: " .. tostring(bg:IsValid()))
    log("parent valid: " .. tostring(parent:IsValid()))

    apply_bg_style(bg)
    bg:SetVisible(true)

    local current_url = url:Get()
    log("set url: " .. tostring(current_url))

    Engine.RunScript(('$.GetContextPanel().FindChildTraverse("CustomBackground").SetURL("%s")'):format(current_url))
end

-- set callbacks
enabled:SetCallback(function()
    log("enabled: " .. tostring(enabled:Get()))
    update()
end, true)

show_alt_toggle:SetCallback(function() rebuild_preset_combo() end)

main:Button(l.refresh, function()
    log("manual update")
    Engine.RunScript(('$.GetContextPanel().FindChildTraverse("CustomBackground").SetURL(""); $.GetContextPanel().FindChildTraverse("CustomBackground").SetURL("%s");'):format(url:Get()))
    update()
end)

preset_combo:SetCallback(function(this)
    local idx = this:Get() + 1
    local name = preset_names[idx]

    if name and presets[name] then
        log("preset selected: " .. name)
        url:Set(presets[name])
        update()
    end
end)

disable_interactions:SetCallback(function()
    local bg = Panorama.GetPanelByName("CustomBackground", false)
    apply_bg_style(bg)
end)

blur:SetCallback(function()
    local bg = Panorama.GetPanelByName("CustomBackground", false)
    apply_bg_style(bg)
end)

main:Button(l.load_presets, function()
    fetch_presets(libs, 'user')
    fetch_presets(libs_main, 'main')
    fetch_presets(libs_alt, 'alt')
end)

for name, preset_url in pairs(custom_presets) do
    add_preset(name, preset_url, 'custom')
end

load_presets()
rebuild_preset_combo()

return {
    OnFrame = function()
        tab:Icon(('\a%s\u{e2ca}'):format(grad({ colors = grad_colors })))
        by:ForceLocalization(('\a%sscript by 18555'):format(grad({ colors = { '36B1C7', '960B33' }, sine = true })))
    end
}
