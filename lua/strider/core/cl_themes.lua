
local curr
local default = "dark"

strider.themes = strider.themes or {}
strider.themes.list = strider.colors.list or {}
function strider.themes.Create(id, theme)
    strider.themes.list[id] = theme

    if theme.default then
        default = id
    end

    return theme
end

function strider.themes.Get(category, color)
    if not curr then
        curr = strider.themes.list[cookie.GetString("strider_ui_theme", default)]
    end

    if color then
        return curr[category][color]
    end

    return curr[category]
end

function strider.themes.GetCurrent()
    return curr_id
end

function strider.themes.Set(id)
    curr = nil
    curr_id = id

    cookie.Set("strider_ui_theme", id)
end