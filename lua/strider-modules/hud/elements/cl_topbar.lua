
local strider = strider

local colors
local cfg
local PANEL = vgui.Register("strider:HUD:Topbar", {}, "Panel")
PANEL.hides = {"CHudBattery", "CHudHealth", "DarkRP_LocalPlayerHUD"}

function PANEL:Init()
    self.notices = strider.HUD.Config.notices

    self.left = {}
    self.right = {}

    for k,v in pairs(strider.HUD.Config.topbar_elements.left) do
        self.left[k] = vgui.Create(v, self)
    end

    for k,v in pairs(strider.HUD.Config.topbar_elements.right) do
        self.right[k] = vgui.Create(v, self)
    end

    colors = strider.HUD.Config.colors
    cfg = strider.HUD.Config

    for k,v in pairs(self:GetChildren()) do
        v:SetPaintedManually(true)
    end
end

function PANEL:PerformLayout(w, h)
    local pad = strider.Scale(4)
    self.pad = pad

    local margin = strider.Scale(15)
    self.margin = margin

    local linew = strider.Scale(4)
    self.linew = linew

    local x = pad
    for k,v in pairs(self.left) do
        local req_w = v:RequestWide()
        v:SetPos(x, pad)
        v:SetSize(req_w, h - pad - pad)

        x = x + req_w + margin + linew
    end

    x = pad
    for k,v in pairs(self.right) do
        local req_w = v:RequestWide()
        v:SetPos(w - req_w - x, pad)
        v:SetSize(req_w, h - pad - pad)

        x = x + req_w + margin + linew
    end
end

function PANEL:RequestSize(w, h)
    return ScrW(), strider.Scale(strider.HUD.Config.bar_h)
end

function PANEL:RequestPos(w, h, ow, oh)
    return 0,0
end

function PANEL:PaintNotices(w, h)
    local oc = DisableClipping(true)

    local maxw = 0
    local tc = {}
    local lp = LocalPlayer()
    local y = h
    for k,v in pairs(self.notices) do
        if not v.show(lp) then continue end
        surface.SetFont(strider.Font(20, nil, 1000))
        local tw, th = surface.GetTextSize(v.text)
        maxw = math.max(tw) + strider.Scale(18)
        table.insert(tc, {
            text = v.text,
            color = v.color,
            y = y,
            h = th + strider.Scale(8)
        })

        y = y + th + strider.Scale(10)
    end

    for k,v in pairs(tc) do
        surface.SetDrawColor(colors.notices.topbar_background)
        surface.DrawRect(strider.Scale(20), v.y, maxw, v.h)

        draw.Text({
            text = v.text,
            pos = {strider.Scale(33), v.y + 5},
            color = colors.notices.text,
            font = strider.Font(20, nil, 1000)
        })

        surface.SetDrawColor(v.color)
        surface.DrawRect(strider.Scale(20), v.y, strider.Scale(3), v.h)
    end

    DisableClipping(oc)
end

function PANEL:Paint(w, h)
    if hook.Run("HUDShouldDraw", "Strider:Main") == false then return end

    self:PaintNotices(w, h)

    if cfg.shadows then
        local oc = DisableClipping(true)
        surface.SetDrawColor(colors.topbar.shadow)
        surface.SetMaterial(strider.Material("vgui/gradient-u"))
        surface.DrawTexturedRect(0, h, w, 15)
        DisableClipping(oc)
    end

    surface.SetDrawColor(colors.topbar.background)
    surface.DrawRect(0, 0, w, h)

    local oc = DisableClipping(true)
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h, w, strider.Scale(2))
    DisableClipping(oc)

    for k,v in pairs(self:GetChildren()) do
        v:PaintManual()
    end

    local margin = self.margin
    local linew = self.linew

    surface.SetDrawColor(colors.topbar.divider)
    for k,v in pairs(self.left) do
        if k == #self.left then break end

        local x,y = v:GetPos() + v:GetWide() + (margin / 2), h / 4
        surface.DrawRect(x + 1, y, linew / 2, h / 2)
        surface.DrawRect(x, y + 1, linew / 4, h / 2 - 2)
        surface.DrawRect(x + (linew - linew / 4), y + 1, linew / 4, h / 2 - 2)
    end
end

strider.HUD.Refresh()