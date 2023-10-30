
local math = math
local strider = strider

local LocalPlayer = LocalPlayer
local SetDrawColor = surface.SetDrawColor
local drawText = draw.Text
local DrawImage = strider.DrawImage
local CurTime = CurTime

local colors
local PANEL = vgui.Register("strider:HUD:PropCounter", {}, "Panel")

function PANEL:Init()
    self.SizeWeWant = 100
    self.LastChange = CurTime()

    colors = strider.HUD.Config.colors
end

function PANEL:RequestSize(w, h)
    return self.SizeWeWant, strider.Scale(40)
end

function PANEL:RequestPos(w, h, ow, oh)
    local pad = strider.Scale(20)

    return pad, pad + (strider.HUD.Config.use_bar and h - oh - strider.Scale(30) or 0)
end

function PANEL:Paint(w, h)
    if hook.Run("HUDShouldDraw", "Strider:PropCounter") == false then return end

    self:SetAlpha(math.max(40, 255 - (math.abs(self.LastChange - CurTime()) * 60)))
    SetDrawColor(
        colors.propcounter.icon.r,
        colors.propcounter.icon.g,
        colors.propcounter.icon.b,
        self:GetAlpha() * 2
    )

    DrawImage("https://i.imgur.com/TtzdXUV.png", h / 6, h / 6, h - h / 3, h - h / 3)

    local pc = LocalPlayer():GetCount("props")
    local tw = drawText({
        text = pc .. " Props",
        pos = {h, h / 2},
        xalign = 0,
        yalign = 1,
        font = strider.Font(20),
        color = colors.propcounter.text,
    })

    self.SizeWeWant = tw + h

    if pc != self.PropCount then
        self:GetParent():InvalidateLayout(true)
        self.PropCount = pc
        self.LastChange = CurTime()
    end
end

strider.HUD.Refresh()