
if SERVER then
    resource.AddWorkshop("2631771632")
    return
end

local fonts = {}
function strider.Font(size, font, weight)
    font = font or "Inter"
    local name = "strider:" .. font .. ":" .. size .. (weight and (":" .. weight) or "")

    if fonts[name] then
        return name
    end

    surface.CreateFont(name, {
        font = font,
        size = strider.Scale(size),
        weight = weight
    })

    fonts[name] = true
    return name
end

local unscaled = {}
function strider.UnscaledFont(size, font, weight)
    font = font or "Inter"
    local name = "strider:" .. font .. ":" .. size .. (weight and (":" .. weight) or "")

    if fonts[name] then
        return name
    end

    surface.CreateFont(name, {
        font = font,
        size = size,
        weight = weight
    })

    fonts[name] = true
    return name
end

hook.Add("OnScreenSizeChanged", "Strider:ResetFonts", function()
    fonts = {}
end )

