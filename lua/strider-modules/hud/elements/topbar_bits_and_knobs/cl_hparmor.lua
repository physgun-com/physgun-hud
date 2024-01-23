
local PANEL = vgui.Register("strider:HUD:Topbar:HPArmor", {}, "Panel")
local colors

function PANEL:Init()
    self.lerps = {}

    self.hp = LocalPlayer():Health()
    self.armor = LocalPlayer():Armor()

    self.SizeWeWant = 100

    colors = strider.HUD.Config.colors
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


function PANEL:Paint(w, h)
    local lp = LocalPlayer()
    local pam = lp:Armor()
    local php = lp:Health()

    local hp        = self:AdjustedLerp("Health",   0, php)
    local armor     = self:AdjustedLerp("Armor",    0, pam)

    local fontsize = math.floor(strider.HUD.Config.bar_h * .4)

    local hw = draw.Text({
        text = "HP   ",
        pos = {0, h / 2},
        xalign = 0,
        yalign = 4,
        font = strider.Font(fontsize, nil, 700),
        color = colors.topbar.hpamtxt
    })

    local aw = draw.Text({
        text = "AP   ",
        pos = {0, h / 2},
        xalign = 0,
        yalign = 3,
        font = strider.Font(fontsize, nil, 700),
        color = colors.topbar.hpamtxt
    })

    hw = hw + draw.Text({
        text = hp,
        pos = {aw, h / 2},
        xalign = 0,
        yalign = 4,
        font = strider.Font(fontsize),
        color = colors.topbar.health
    })

    aw = aw + draw.Text({
        text = armor,
        pos = {aw, h / 2},
        xalign = 0,
        yalign = 3,
        font = strider.Font(fontsize),
        color = colors.topbar.armor
    })

    local size = math.max(hw, aw, strider.Scale(100))
    if size != self.SizeWeWant then
        self.SizeWeWant = size
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:RequestWide()
    return self.SizeWeWant
end

strider.HUD.Refresh()
