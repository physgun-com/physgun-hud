
local colors = strider.HUD.Config.colors
local cfg = strider.HUD.Config
if not cfg.modules.PlayerDisplay then return end

strider.HUD.Hide("DarkRP_EntityDisplay")

function strider.HUD.DrawPlayerInfo(ply)
    surface.SetFont(strider.UnscaledFont(100))
    local x = 0
    local wanted = ply:getDarkRPVar("wanted")
    local tw, th = surface.GetTextSize(ply:Nick())
    tw = tw + 100
    th = th + 50

    surface.SetDrawColor(colors.player_display.background)
    surface.DrawRect(0, 0, tw, th)

    if wanted then
        local icw = 100
        surface.DrawRect(tw, 0, icw, th)
        tw = tw + icw
        x = icw

        surface.SetDrawColor(colors.player_display.wanted_icon)
        strider.DrawImage("https://i.imgur.com/YWr6KC9.png", th / 2 - icw / 2, th / 2 - icw / 2, icw, icw)
    end

    surface.SetDrawColor(wanted and colors.player_display.wanted_edge_bg or colors.player_display.edge_bg)

    local sizew, sizeh = math.ceil(tw / 3), math.ceil(th / 3)
    surface.DrawRect(0, 0, 5, sizeh)
    surface.DrawRect(5, 0, sizew, 5)
    surface.DrawRect(tw - sizew - 5, th - 5, sizew, 5)
    surface.DrawRect(tw - 5, th - sizeh, 5, sizeh)

    surface.SetDrawColor(wanted and colors.player_display.wanted_edge or colors.player_display.edge)

    surface.DrawRect(0, 0, 5, 5)
    surface.DrawRect(tw - 5, th - 5, 5, 5)

    surface.SetMaterial(strider.Material("vgui/gradient-l"))
    surface.DrawTexturedRect(5, 0, sizew, 5)
    surface.SetMaterial(strider.Material("vgui/gradient-u"))
    surface.DrawTexturedRect(0, 5, 5, sizeh - 5)

    surface.SetMaterial(strider.Material("vgui/gradient-r"))
    surface.DrawTexturedRect(tw - sizew - 5, th - 5, sizew, 5)
    surface.SetMaterial(strider.Material("vgui/gradient-d"))
    surface.DrawTexturedRect(tw - 5, th - sizeh, 5, sizeh - 5)

    draw.Text({
        text = ply:Nick(),
        font = strider.UnscaledFont(100),
        pos = {50 + x, 25},
    })

    local y = th + 10

    if not ply.getDarkRPVar then return end
    if not ply:getDarkRPVar("job") then return end
    surface.SetFont(strider.UnscaledFont(80))
    tw, th = surface.GetTextSize(ply:getDarkRPVar("job"))
    tw = tw + 40
    th = th + 20

    surface.SetDrawColor(colors.player_display.background)
    surface.DrawRect(0, y, tw, th)

    surface.SetDrawColor(wanted and colors.player_display.wanted_edge or colors.player_display.edge)
    surface.DrawRect(0, y, 5, th)

    draw.Text({
        text = ply:getDarkRPVar("job"),
        pos = {25, y + 10},
        font = strider.UnscaledFont(80)
    })

    if not ply:getDarkRPVar("HasGunlicense") then return end

    surface.SetDrawColor(colors.player_display.background)
    surface.DrawRect(tw + 10, y, th, th)

    surface.SetDrawColor(255,255,255)
    strider.DrawImage("https://i.imgur.com/nzq2ciy.png", tw + 30, y + 20, th - 40, th - 40)

    surface.SetDrawColor(wanted and colors.player_display.wanted_edge or colors.player_display.edge)
    surface.DrawRect(tw + th + 10, y, 5, th)
end

hook.Add("PostDrawTranslucentRenderables", "Strider:HUD:PlayerDisplay", function()
    local lp = LocalPlayer()
    local aim = lp:GetAimVector()
    local shoot = lp:GetShootPos()
    local lppos = lp:GetPos()
    for k,v in pairs(player.GetAll()) do
        if not IsValid(v) then continue end
        if v == lp then continue end
        if not v:Alive() then continue end
        if v:GetNoDraw() then continue end
        if v:IsDormant() then continue end
        if v:GetColor().a == 0 and (v:GetRenderMode() == RENDERMODE_TRANSALPHA or v:GetRenderMode() == RENDERMODE_TRANSCOLOR) then continue end

        local dist = lppos:DistToSqr(v:GetPos())
        if dist > (400 ^ 2) then return end

        local eye = v:EyePos()
        local diff = eye - shoot
        if aim:Dot(diff) / diff:Length() <= 0.65 then continue end

        local ang = (eye - lppos):Angle()
        ang:SetUnpacked(0, ang[2] - 90, 90)
        cam.Start3D2D(eye + (ang:Forward() * 12), ang, 0.05)
            strider.HUD.DrawPlayerInfo(v)
        cam.End3D2D()
    end

    local ent = lp:GetEyeTrace().Entity

    if not IsValid(ent) then return end
    local dist = ent:GetPos():DistToSqr(lppos)
    local max = 40000

    if ent:isKeysOwnable() and not ent:getKeysNonOwnable() and dist < max then
        local pos = ent:WorldSpaceCenter()
        cam.Start3D2D(pos + ent:GetAngles():Forward() * 3, ent:GetAngles() + Angle(0, 90, 90), 0.1)
            ent:drawOwnableInfo(1 - dist / max)
        cam.End3D2D()

        cam.Start3D2D(pos - ent:GetAngles():Forward() * 3, ent:GetAngles() + Angle(0, -90, 90), 0.1)
            ent:drawOwnableInfo(1 - dist / max)
        cam.End3D2D()
    end
end )
