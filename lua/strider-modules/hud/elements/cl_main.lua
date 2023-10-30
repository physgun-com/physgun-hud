
local math = math
local strider = strider

local LocalPlayer = LocalPlayer
local RoundedBoxEx = draw.RoundedBoxEx
local SetScissorRect = render.SetScissorRect
local SetMaterial = surface.SetMaterial
local SetDrawColor = surface.SetDrawColor
local DrawTexturedRect = surface.DrawTexturedRect
local DrawPoly = surface.DrawPoly
local drawText = draw.Text

local colors
local cfg
local PANEL = vgui.Register("strider:HUD:Main", {}, "Panel")
PANEL.hides = {"CHudBattery", "CHudHealth", "DarkRP_LocalPlayerHUD"}

function PANEL:Init()
    strider.thirdparty.getAvatarMaterial(LocalPlayer():SteamID64(), function(mat)
        if IsValid(self) then
            self.avatar_image = mat
        end
    end )

    self.lerps = {}
    self.money = LocalPlayer():getDarkRPVar("money")
    self.money_text = DarkRP.formatMoney(self.money)

    self.salary = LocalPlayer():getDarkRPVar("salary")
    self.salary_text = "+" .. DarkRP.formatMoney(self.salary)

    self.notices = strider.HUD.Config.notices

    self.SizeWeWant = strider.Scale(550)

    colors = strider.HUD.Config.colors
    cfg = strider.HUD.Config
end

function PANEL:PerformLayout(w, h)
    local pad = strider.Scale(4)
    self.pad = pad
    self.avatar = strider.thirdparty.rounded_boxes.RoundedBox(strider.Scale(22), pad, pad, h - pad * 2, h - pad * 2)
end

function PANEL:RequestSize(w, h)
    return self.SizeWeWant, strider.Scale(120)
end

function PANEL:RequestPos(w, h, ow, oh)
    local pad = strider.Scale(20)

    return pad, h - oh - pad
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

function PANEL:PaintAvatar(w, h)
    draw.RoundedBox(strider.Scale(24), 0, 0, h, h, colors.main.background)

    if self.avatar_image then
        SetDrawColor(255, 255, 255)
        SetMaterial(self.avatar_image)
        DrawPoly(self.avatar)
    end
end

function PANEL:PaintNotices(w, h)
    local oc = DisableClipping(true)

    local lp = LocalPlayer()
    local y = -strider.Scale(30)
    for k,v in pairs(self.notices) do
        if not v.show(lp) then continue end
        local _, hh = draw.Text({
            text = v.text,
            pos = {strider.Scale(13), y},
            color = colors.notices.text,
            font = strider.Font(20, nil, 1000)
        })

        surface.SetDrawColor(v.color)
        surface.DrawRect(0, y, strider.Scale(3), hh)

        y = y - hh - strider.Scale(5)
    end

    DisableClipping(oc)
end

function PANEL:Paint(w, h)
    if hook.Run("HUDShouldDraw", "Strider:Main") == false then return end

    local s26 = strider.Scale(26)
    local sp2 = self.pad * 2

    local lp = LocalPlayer()
    local pam = lp:Armor()
    local php = lp:Health()

    local hp        = self:AdjustedLerp("Health",   0, php)
    local armor     = self:AdjustedLerp("Armor",    0, pam)
    -- local armor_h   = self:AdjustedLerp("ArmorH",   0,   pam > 0 and (h / 2) or 0)
    local font_s    = 24

    local barx = h - strider.Scale(12)
    local barwide = w - barx - strider.Scale(20)
    local midh = h - s26 * 2

    self:PaintNotices(w, h)

    if cfg.shadows then
        strider.thirdparty.BSHADOWS.BeginShadow()
            local x,y = self:LocalToScreen(0, 0)

            RoundedBoxEx(h, x + barx, y + sp2, barwide, h / 2, colors.main.emptybar, false, true)
            RoundedBoxEx(h, x + barx, y + h / 2 - sp2, barwide, h / 2, colors.main.emptybar, false, false, false, true)

            RoundedBoxEx(strider.Scale(20), x + s26, y + s26, w - s26, midh, colors.main.background, false, true, false, true)
            draw.RoundedBox(strider.Scale(24), x, y, h, h, colors.main.background)
        strider.thirdparty.BSHADOWS.EndShadow(1, 1, 4, opacity, direction, distance, false)
    else
        RoundedBoxEx(h, barx, sp2, barwide, h / 2, colors.main.emptybar, false, true)
        RoundedBoxEx(h, barx, h / 2 - sp2, barwide, h / 2, colors.main.emptybar, false, false, false, true)
    end


    local hp_x,hp_y = self:LocalToScreen(barx, sp2)
    local hp_w,hp_h = self:LocalToScreen(barx + Lerp(hp / lp:GetMaxHealth(), 0, barwide), h)

    SetScissorRect(hp_x, hp_y, hp_w, hp_h, true)
        RoundedBoxEx(h, barx, sp2, barwide, h / 2, colors.main.health, false, true)
        -- RoundedBoxEx(h, barx, h / 2 - sp2, barwide, h / 2, colors.main.health, fawlse, false, false, true)
    SetScissorRect(0,0,0,0,false)

    local am_x,am_y = self:LocalToScreen(barx, h / 2 - sp2)
    local am_w,am_h = self:LocalToScreen(barx + Lerp(armor / (lp.GetMaxArmor and lp:GetMaxArmor()) or 255, 0, barwide), h)

    SetScissorRect(am_x, am_y, am_w, am_h, true)
        RoundedBoxEx(h, barx, h / 2 - sp2, barwide, h / 2, colors.main.armor, false, false, false, true)
    SetScissorRect(0,0,0,0,false)

    RoundedBoxEx(strider.Scale(20), s26, s26, w - s26, midh, colors.main.background, false, true, false, true)

    SetMaterial(strider.Material("vgui/gradient-l"))
    SetDrawColor(colors.main.shadow)
    DrawTexturedRect(h - strider.Scale(13), s26, 40, midh)

    self:PaintAvatar(w, h)

    local tw = drawText({
        text = lp:Nick(),
        pos = {h + sp2, s26 + midh / 2},
        font = strider.Font(font_s, nil, 700),
        xalign = 0,
        yalign = 4,
        color = colors.main.name
    })

    local job = lp:getJobTable()
    local jw = drawText({
        text = job.name,
        pos = {h + sp2, s26 + midh / 2},
        font = strider.Font(font_s),
        xalign = 0,
        yalign = 3,
        color = job.color
    })

    local leftw = math.max(tw, jw)

    local new_money = Lerp(FrameTime() * 10, self.money, lp:getDarkRPVar("money"))
    if self.money != new_money then
        self.money = new_money
        if math.abs(self.money - new_money) > 1 then
            self.money = lp:getDarkRPVar("money")
        end

        self.money_text = DarkRP.formatMoney(math.Round(self.money))
    end

    local mw = drawText({
        text = self.money_text,
        pos = {w - sp2, s26 + midh / 2},
        xalign = 2,
        yalign = 4,
        font = strider.Font(font_s),
        color = colors.main.money
    })

    local new_salary = Lerp(FrameTime() * 10, self.salary, job.salary)
    if self.salary != new_salary then
        self.salary = new_salary
        if math.abs(self.salary - new_salary) > 1 then
            self.salary = job.salary
        end

        self.salary_text = "+" .. DarkRP.formatMoney(math.Round(self.salary))
    end

    local sw = drawText({
        text = self.salary_text,
        pos = {w - sp2, s26 + midh / 2},
        xalign = 2,
        yalign = 3,
        color = colors.main.salary,
        font = strider.Font(math.floor(font_s * .75))
    })

    local rightw = math.max(mw, sw)


    local sizewewant = math.max(leftw + rightw, strider.Scale(400)) + h + strider.Scale(50)
    if self.SizeWeWant != sizewewant then
        self.SizeWeWant = sizewewant
        self:GetParent():InvalidateLayout(true)
    end
end

strider.HUD.Refresh()
