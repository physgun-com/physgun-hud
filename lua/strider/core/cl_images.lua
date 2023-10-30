
file.CreateDir("strider")
file.CreateDir("strider/images")

local function URLExtension(url)
    local spl = string.Split(url, ".")

    return spl[#spl]
end

local function SanitizeURL(url)
    return ({url:gsub("%W", "")})[1]
end

local reqs = {}
local function Get(url, fn, err)
    if not reqs then
        return http.Fetch(url, fn, err)
    end

    table.insert(reqs, {url, fn, err})
end

hook.Add("Think", "Strider:ImageDownloadDelay", function()
    hook.Remove("Think", "Strider:ImageDownloadDelay")

    for k,v in pairs(reqs) do
        http.Fetch(v[1], v[2], v[3])
    end

    reqs = nil
end )

strider.InvalidImage = strider.InvalidImage or Material("flags16/il.png")
local images = {}
function strider.Image(url, callback)
    if images[url] then
        if callback then callback(true, images[url]) end
        return images[url]
    end

    local sans = SanitizeURL(url)
    local ext = URLExtension(url)
    if file.Exists("strider/images/" .. sans .. "." .. ext , "DATA") then
        images[url] = Material("../data/strider/images/" .. sans .. "." .. ext, "mips smooth")
        if callback then callback(true, images[url]) end
        return images[url]
    end

    print("Image Fetch made to", "https://external-content.duckduckgo.com/iu/?u=" .. url)
    Get("https://external-content.duckduckgo.com/iu/?u=" .. url, function(bod, size, headers, code)
        file.Write("strider/images/" .. sans .. "." .. ext, bod)
        images[url] = Material("../data/strider/images/" .. sans .. "." .. ext, "mips smooth")
        print("Image Download Success:", url, code)

        if callback then callback(true, images[url]) end
    end, function(err)
        print("Image Download Failure:", err)

        if callback then callback(false, err) end
    end )

    images[url] = strider.InvalidImage

    return images[url]
end

hook.Add("InitPostEntity", "strider:LoadLoadingImage", function()
    strider.Image("https://i.imgur.com/635PPvg.png", function(success, mat)
        if success then
            strider.InvalidImage = mat
        else
            strider.InvalidImage = true
        end
    end )
end )

function strider.DrawImage(url, x, y, w, h)
    local mat = strider.Image(url)

    if mat == strider.InvalidImage then
        local size = math.min(w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 2) * 30)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, size, size, CurTime() * 2)
        return false
    end

    surface.SetMaterial(mat)
    surface.DrawTexturedRect(x, y, w, h)
    return true
end

local avatars = {}
function strider.GetPlayerAvatar(steamid)
    if avatars[steamid] then
        return avatars[steamid]
    end

    avatars[steamid] = strider.InvalidImage
    strider.thirdparty.getAvatarMaterial(steamid, function(mat)
        avatars[steamid] = mat
    end )

    return avatars[steamid]
end

function strider.DrawAvatar(steamid, x, y, w, h)
    local mat = strider.GetPlayerAvatar(steamid)

    if mat == strider.InvalidImage then
        local size = math.min(w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 2) * 30)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, size, size, CurTime() * 2)
        return false
    end

    surface.SetMaterial(mat)
    surface.DrawTexturedRect(x, y, w, h)
    return true
end
