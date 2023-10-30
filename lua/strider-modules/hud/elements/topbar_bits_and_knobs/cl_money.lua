
local PANEL = vgui.Register("strider:HUD:Topbar:Money", {}, "Panel")
local colors
local lang

function PANEL:Init()
    colors = strider.HUD.Config.colors
    lang = strider.HUD.Language

    self.money = LocalPlayer():getDarkRPVar("money")
    self.money_text = DarkRP.formatMoney(self.money)

    self.salary = LocalPlayer():getDarkRPVar("salary")
    self.salary_text = DarkRP.formatMoney(self.salary) .. lang.hr

    self.SizeWeWant = 100
end

function PANEL:Paint(w, h)
    local lp = LocalPlayer()

    local new_money = Lerp(FrameTime() * 10, self.money, lp:getDarkRPVar("money"))
    if self.money != new_money then
        self.money = new_money
        if math.abs(self.money - new_money) > 1 then
            self.money = lp:getDarkRPVar("money")
        end

        self.money_text = DarkRP.formatMoney(math.Round(self.money))
    end

    local job = lp:getJobTable()
    if not job then return end
    local new_salary = Lerp(FrameTime() * 10, self.salary, job.salary)
    if self.salary != new_salary then
        self.salary = new_salary
        if math.abs(self.salary - new_salary) > 1 then
            self.salary = job.salary
        end

        self.salary_text = DarkRP.formatMoney(math.Round(self.salary)) .. lang.hr
    end

    local mw = draw.Text({
        text = self.money_text,
        pos = {0, h / 2},
        xalign = 0,
        yalign = 4,
        font = strider.Font(math.floor(strider.HUD.Config.bar_h * .4)),
        color = colors.topbar.money
    })

    local sw = draw.Text({
        text = self.salary_text,
        pos = {0, h / 2},
        xalign = 0,
        yalign = 3,
        font = strider.Font(math.floor(strider.HUD.Config.bar_h * .35)),
        color = colors.topbar.salary
    })

    local size = math.max(mw + 2, sw + 2, strider.Scale(100))
    if size != self.SizeWeWant then
        self.SizeWeWant = size
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:RequestWide()
    return self.SizeWeWant
end

strider.HUD.Refresh()
