
local math = math
local strider = strider

local LocalPlayer = LocalPlayer
local colors
local PANEL = vgui.Register("strider:HUD:Ammo", {}, "Panel")
PANEL.hides = {"CHudAmmo", "CHudSecondaryAmmo"}

function PANEL:Init()
    self.lerps = {}
    self.Clip = 0
    self.MaxClip = 1
    self.ClipAmt = 1
    self.Reserve = 0
    self.Alpha = 0

    colors = strider.HUD.Config.colors
end

function PANEL:PerformLayout(w, h)
    self.pad = strider.Scale(3)
end

function PANEL:RequestSize(w, h)
    return strider.Scale(120), strider.Scale(120)
end

function PANEL:RequestPos(w, h, ow, oh)
    local pad = strider.Scale(20)

    -- return w / 2 - ow / 2, h / 2 - oh / 2
    return w - ow - pad, h - oh - pad
end

function PANEL:AdjustedLerp(name, start, to)
    local from = self.lerps[name] or start
    if from == to then
        return from
    end

    local lp = Lerp(FrameTime() * 10, from, to)

    if math.Round(lp) == to then
        self.lerps[name] = to

        return to
    end

    self.lerps[name] = lp

    return lp
end

function PANEL:UpdateWeaponInfo()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() == -1 or wep:GetMaxClip1() == -1 then

        -- we love hl2 weapons
        if IsValid(wep) and wep:GetPrimaryAmmoType() > -1 then
            self.Alpha = self:AdjustedLerp("Alpha", 0, 255)
            self.SingleAmmo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
            return
        end

        self.Alpha = self:AdjustedLerp("Alpha", 0, 0)
        return
    end

    if self.Weapon != wep then
        self.lerps["Reserve"] = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
    end

    self.SingleAmmo = false
    self.Weapon = wep
    self.Alpha = self:AdjustedLerp("Alpha", 0, 255)

    self.Clip = wep:Clip1()
    self.MaxClip = wep:GetMaxClip1()
    self.ClipAmt = self:AdjustedLerp("ClipAmt", 0, self.Clip)
    self.Reserve = self:AdjustedLerp("Reserve", 0, LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()))

    self.HasAltAmmo = wep:GetSecondaryAmmoType() != -1
    self.AltAmmo = LocalPlayer():GetAmmoCount(wep:GetSecondaryAmmoType())
end

function PANEL:Paint(w, h)
    if hook.Run("HUDShouldDraw", "Strider:Ammo") == false then return end
    self:UpdateWeaponInfo()

    local oa = surface.GetAlphaMultiplier()
    local pad = self.pad

    surface.SetAlphaMultiplier(self.Alpha / 500)
    local x,y = self:LocalToScreen(0, 0)
    render.SetScissorRect(x + w - (w * (self.ClipAmt / self.MaxClip)), y, x + w, y + h, true)
    draw.RoundedBox(pad * 2, 0, 0, w, h, colors.ammo.border)
    render.SetScissorRect(0, 0, 0, 0, false)

    surface.SetAlphaMultiplier(self.Alpha / (255 / 4))

    draw.RoundedBox(pad, pad, pad, w - pad * 2, h - pad * 2, colors.ammo.background)

    local oc = DisableClipping(true) -- just incase we go over with the text, we dont wanna be a burden

    if self.SingleAmmo then
        draw.Text({
            text = self.SingleAmmo,
            pos = {w / 2, h / 2},
            xalign = 1,
            yalign = 1,
            font = strider.Font(50)
        })

        DisableClipping(oc)
        return surface.SetAlphaMultiplier(oa)
    end

    local tw, th = draw.Text({
        text = self.Clip,
        pos = {w / 2, h * .45},
        xalign = 1,
        yalign = 1,
        color = colors.ammo.clip,
        font = strider.Font(50)
    })
    draw.Text({
        text = math.floor(self.Reserve),
        pos = {w / 2, h / 2 + th / 4 + strider.Scale(10)},
        xalign = 1,
        yalign = 1,
        color = colors.ammo.reserve,
        font = strider.Font(24),
    })


    if not self.HasAltAmmo then
        DisableClipping(oc)
        return surface.SetAlphaMultiplier(oa)
    end

    draw.Text({
        text = "(" .. self.AltAmmo .. ")",
        pos = {w / 2 + tw / 2 + pad, h * .45 + th / 8},
        xalign = 0,
        yalign = 1,
        color = colors.ammo.reserve,
        font = strider.Font(15)
    })

    DisableClipping(oc)
    surface.SetAlphaMultiplier(oa)
end

strider.HUD.Refresh()