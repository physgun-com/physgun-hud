
local PANEL = vgui.Register("strider:HUD:Topbar:Right", {}, "Panel")
local colors
local cfg

function PANEL:Init()
    self.maxplayers = game.MaxPlayers()
    self.SizeWeWant = 100

    colors = strider.HUD.Config.colors
    cfg = strider.HUD.Config.server_info
end

function PANEL:Paint(w, h)
    local pad = strider.Scale(6)
    surface.SetDrawColor(255,255,255)
    strider.DrawImage(cfg.logo_url, w - h, 0, h, h)

    local nw = draw.Text({
        text = cfg.name,
        pos = {w - h - pad, h / 2},
        xalign = 2,
        yalign = 4,
        color = colors.topbar.serverinfotext,
        font = strider.Font(math.floor(strider.HUD.Config.bar_h * .4))
    })

    local pw = draw.Text({
        text = player.GetCount() .. "/" .. self.maxplayers,
        pos = {w - h - pad, h / 2},
        xalign = 2,
        yalign = 3,
        color = colors.topbar.serverinfotext,
        font = strider.Font(math.floor(strider.HUD.Config.bar_h * .35)),
    })

    local size = math.max(nw, pw) + pad + h

    if self.SizeWeWant != size then
        self.SizeWeWant = size
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:RequestWide()
    return self.SizeWeWant
end

strider.HUD.Refresh()
