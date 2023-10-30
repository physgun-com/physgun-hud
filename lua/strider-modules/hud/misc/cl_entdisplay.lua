
local lang
local cfg
local colors

function strider.HUD:DrawOwnableInfo(dist)
    local lp = LocalPlayer()
    if lp:InVehicle() and not lp:GetAllowWeaponsInVehicle() then return end

    local doorDrawing = hook.Call("HUDDrawDoorData", nil, self)
    if doorDrawing == true then return end

    if not self:isKeysOwnable() and self:isKeysAllowedToOwn(lp) then
        return
    end

    local oa = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier(dist)

    local doorTeams = self:getKeysDoorTeams()
    local doorGroup = self:getKeysDoorGroup()
    local title = self:getKeysTitle()

    local text = {}

    text.title = title
    text.text = "unknown"
    text.owners = self:isKeysOwned()

    local x, y = 0, 0
    local w = strider.Scale(400)

    if text.title or text.owners then
        local tw = draw.Text({
            text = text.title or lang.owned_by,
            pos = {x, y},
            xalign = 1,
            yalign = 4,
            font = strider.Font(40,nil,1000),
            color = colors.door.title
        })

        w = math.max(tw + strider.Scale(20), w)
        surface.SetDrawColor(colors.door.title_divider)
        surface.DrawRect(x - w / 2, y, w, 1)
    end

    y = y + strider.Scale(10)

    if text.owners then
        local size = strider.Scale(50)
        local icon = strider.Scale(20)
        local owners = {self:getDoorOwner()}
        owners = table.Add(owners, self:getKeysCoOwners() or {})
        owners = table.Add(owners, self:getKeysAllowedToOwn() or {})

        for k,v in pairs(owners) do
            if IsEntity(k) and IsValid(k) and k:IsPlayer() then
                v = k -- lol
            end

            if not IsEntity(v) then continue end

            surface.SetDrawColor(255,255,255)
            strider.DrawAvatar(v:SteamID64(), x - w / 2, y, size, size)

            if v == self:getDoorOwner() then
                strider.DrawImage("https://i.imgur.com/YaGGw4F.png", x - w / 2, y + size - icon, icon, icon)
            elseif self:isKeysAllowedToOwn(v) then
                strider.DrawImage("https://i.imgur.com/fjPZFqW.png", x - w / 2, y + size - icon, icon, icon)
            else
                strider.DrawImage("https://i.imgur.com/CFV8Y9o.png", x - w / 2, y + size - icon, icon, icon)
            end

            draw.Text({
                text = v:Nick(),
                pos = {x + size / 2, y + size / 2},
                xalign = 1,
                yalign = 1,
                font = strider.Font(20),
                color = colors.door.text
            })

            y = y + size + strider.Scale(5)
        end
    elseif doorGroup then
        draw.Text({
            text = doorGroup,
            pos = {x, y},
            xalign = 1,
            yalign = 1,
            font = strider.Font(20),
            color = colors.door.text
        })
    elseif doorTeams then
        for k,v in pairs(doorTeams) do
            if not v or not RPExtraTeams[k] then continue end

            local _, th = draw.Text({
                text = RPExtraTeams[k].name,
                pos = {x, y},
                xalign = 1,
                yalign = 1,
                font = strider.Font(20),
                color = colors.door.text
            })
            y = y + th + strider.Scale(5)
        end
    else
        draw.Text({
            text = lang.press,
            pos = {x, y},
            xalign = 1,
            yalign = 1,
            font = strider.Font(30),
            color = colors.door.text
        })
    end

    if self:IsVehicle() and self:GetDriver():IsPlayer() then
        draw.Text({
            text = "Driven by " .. self:GetDriver():Nick(),
            pos = {x - w / 2, y + strider.Scale(5)},
            yalign = 1,
            font = strider.Font(20)
        })
    end

    surface.SetAlphaMultiplier(oa)
end

hook.Add("PostGamemodeLoaded", "Strider:HUD:EntDisplay", function()
    lang = strider.HUD.Language
    cfg = strider.HUD.Config
    colors = strider.HUD.Config.colors

    if not cfg.modules.EntDisplay then return end
    FindMetaTable("Entity").drawOwnableInfo = strider.HUD.DrawOwnableInfo
end)

if GAMEMODE then
    hook.GetTable()["PostGamemodeLoaded"]["Strider:HUD:EntDisplay"]()
end
