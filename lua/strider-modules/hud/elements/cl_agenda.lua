
local math = math
local strider = strider

local colors
local PANEL = vgui.Register("strider:HUD:AgendaLaws", {}, "Panel")
AccessorFunc(PANEL, "Mode", "Mode") -- index of PANEL.modes
AccessorFunc(PANEL, "Show", "ShouldShow")

PANEL.hides = {"DarkRP_Agenda"}

function PANEL:Init()
    self.lerps = {}

    self.modes = {
        {
            name = "Agenda",
            func = self.PaintAgenda,
        },
        {
            name = "Laws",
            func = self.PaintLaws,
            hidebg = true
        }
    }

    self.Alpha = 0
    self.WantedHeight = 200
    self.lawsh = 0
    self:SetMode(1)

    colors = strider.HUD.Config.colors
end

function PANEL:SetMode(mode)
    self.Mode = mode
    self.ActiveMode = self.modes[mode]
end

function PANEL:PerformLayout(w, h)
    self.pad = strider.Scale(6)
    self.topbarh = strider.Scale(30)
end

function PANEL:RequestSize(w, h)
    return strider.Scale(400), self.WantedHeight
end

function PANEL:RequestPos(w, h, ow, oh)
    local pad = strider.Scale(20)
    return w - ow - pad, pad + (strider.HUD.Config.use_bar and strider.Scale(strider.HUD.Config.bar_h - 16) or 0)
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

function PANEL:PaintAgenda(w, h, tbh)
    local pad = self.pad
    local agenda = LocalPlayer():getDarkRPVar("agenda")

    if not agenda or agenda == "" then
        self:SetMode(2)
    end

    if agenda != self.Agenda then
        self.Agenda = agenda
        self.AgendaParsed = string.Split(DarkRP.textWrap(agenda or "", strider.Font(20), w - (pad * 4)), "\n")
    end

    local y = pad + tbh
    local t = {
        text = "",
        pos = {pad * 2, y},
        font = strider.Font(20),
        color = colors.lawsandagenda.text
    }

    if not self.AgendaParsed then return end

    for k,v in pairs(self.AgendaParsed) do
        t.text = v
        t.pos[2] = y

        local _, th = draw.Text(t)

        y = y + th + pad
    end
end

function PANEL:PaintLaws(w, h, tbh)
    local pad = self.pad
    local agenda = LocalPlayer():getDarkRPVar("agenda")

    if agenda and agenda != "" then
        self:SetMode(1)
    end

    draw.RoundedBoxEx(pad, strider.Scale(40), tbh, w - strider.Scale(40), h, colors.lawsandagenda.background, false, false, false, true)
    draw.RoundedBoxEx(pad, 0, tbh, strider.Scale(40), h, colors.lawsandagenda.numberbg, false, false, true)

    local font = strider.Font(17)
    local laws = DarkRP.getLaws()

    if self.Laws != #laws then
        self.Laws = #laws
        self.LawLines = {}

        for k,v in pairs(laws) do
            self.LawLines[k] = string.Split(DarkRP.textWrap(string.gsub(v, "\n", ""), font, w - strider.Scale(40) - (pad * 2)), "\n")
        end
    end

    local t = {
        text = "",
        pos = {strider.Scale(40) + pad, 0},
        font = font,
        color = colors.lawsandagenda.numbers
    }
    local n = table.Copy(t)
    n.pos[1] = strider.Scale(20)
    n.xalign = 1

    local y = tbh + pad
    for linen,lines in pairs(self.LawLines) do
        n.text = linen
        n.pos[2] = y
        draw.Text(n)

        for k,line in pairs(lines) do
            t.text = line
            t.pos[2] = y
            local _, th = draw.Text(t)

            y = y + th
        end

        y = y + strider.Scale(4)
    end

    self.lawsh = y + self.pad
end

function PANEL:Think()
    if self:GetTall() != self.WantedHeight then
        self:SetTall(self.WantedHeight)
    end

    if input.IsKeyDown(KEY_F2) and input.IsKeyDown(KEY_LSHIFT) then
        if (self.LastPress or 0) > CurTime() then return end

        self.LastPress = CurTime() + 1
        self:SetShouldShow(not self:GetShouldShow())
    end
end

function PANEL:Paint(w, h)
    if hook.Run("HUDShouldDraw", "Strider:Agenda") == false then return end
    local pad = self.pad

    self.endh = (self.Mode == 2 and math.max(strider.Scale(200), self.lawsh)) or strider.Scale(200)
    self.Alpha = self:AdjustedLerp("Alpha", 0, (self:GetShouldShow() and 255) or 0)
    self.WantedHeight = self:AdjustedLerp("WantedHeight", 0, self.endh)

    local a = self.Alpha / 255
    local oa = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier(a)
    draw.RoundedBoxEx(pad, 0, 0, w, self.topbarh, colors.lawsandagenda.topbar, true, true)

    surface.SetAlphaMultiplier(1 - a)
        local sw = draw.Text({
            text = "show",
            pos = {w - pad, self.topbarh / 2},
            xalign = 2,
            yalign = 1,
            font = strider.Font(15),
            color = colors.lawsandagenda.hide,
        })

    surface.SetAlphaMultiplier(a)
        surface.SetDrawColor(colors.lawsandagenda.topbar)

        draw.Text({
            text = self.ActiveMode.name,
            pos = {pad, self.topbarh / 2},
            xalign = 0,
            yalign = 1,
            font = strider.Font(20),
            color = colors.lawsandagenda.text,
        })


        local hw = draw.Text({
            text = "hide",
            pos = {w - pad, self.topbarh / 2},
            xalign = 2,
            yalign = 1,
            font = strider.Font(15),
            color = colors.lawsandagenda.hide,
        })

        if not self.ActiveMode.hidebg then
            draw.RoundedBoxEx(pad, 0, self.topbarh, w, h - self.topbarh, colors.lawsandagenda.background, false, false, true, true)
        end

        self.ActiveMode.func(self, w, h - self.topbarh, self.topbarh)
    surface.SetAlphaMultiplier(oa)

    draw.Text({
        text = "Shift+F2 to ",
        pos = {w - pad - Lerp(a, math.max(sw, hw), math.min(sw, hw)), self.topbarh / 2},
        xalign = 2,
        yalign = 1,
        font = strider.Font(15),
        color = colors.lawsandagenda.hide,
    })
end

strider.HUD.Refresh()
