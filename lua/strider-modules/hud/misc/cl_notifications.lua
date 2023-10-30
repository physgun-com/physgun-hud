if not strider.HUD.Config.modules.Notifications then return end
local colors = strider.HUD.Config.colors
strider.HUD.Notifications = strider.HUD.Notifications or {}
strider.HUD.SpecialNotifications = strider.HUD.SpecialNotifications or {}

-- PANEL
do
    local PANEL = vgui.Register("strider:HUD:Notification", {}, "Panel")

    function PANEL:Init()
        self:SetSize(300, strider.Scale(45))
        self.font = strider.Font(20)
        self.start = 0 -- just incase <3
    end

    function PANEL:CalcW()
        surface.SetFont(self.font)
        local h = self:GetTall()

        return h + surface.GetTextSize(self.text) + strider.Scale(20)
    end

    function PANEL:CalcY()
        if not self.id then
            return ScrH()
        end

        return ScrH() - strider.Scale(190) - ((self.id - 1) * (self:GetTall() + strider.Scale(5)))
    end

    function PANEL:ThinkIn()
        local amt = Lerp((CurTime() - self.start) / 1, 0, 1)
        self.XWeWant = Lerp(amt, self.XWeWant or ScrW(), ScrW() - self:GetWide() - strider.Scale(20))
        self.YWeWant = Lerp(FrameTime() * 10, self.YWeWant or self:CalcY(), self:CalcY())
        self:SetPos(self.XWeWant, self.YWeWant)
        self:SetAlpha(Lerp(amt, self:GetAlpha(), 255))
    end

    function PANEL:ThinkOut()
        local amt = Lerp((CurTime() - self.outstart) / 1, 0, 1)
        self.XWeWant = Lerp(amt, self.XWeWant, ScrW())
        self.YWeWant = Lerp(FrameTime() * 10, self.YWeWant or self:CalcY(), self:CalcY())
        self:SetPos(self.XWeWant, self.YWeWant)
        self:SetAlpha(Lerp(amt, self:GetAlpha(), 0))

        if self:GetAlpha() <= 1 then
            strider.HUD.KillNotification(self.id)
            strider.HUD.UpdateNotifs()
        end
    end

    function PANEL:Think()
        if CurTime() - self.start >= self.length then
            self.outstart = CurTime()
            self.Think = self.ThinkOut
        end

        self:ThinkIn()
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(colors.notifications.background)
        draw.RoundedBox(strider.Scale(4), 0, 0, w, h, colors.notifications.background)
        draw.RoundedBox(strider.Scale(4), 0, 0, h, h, colors.notifications.darker)
        local pad = strider.Scale(10)
        surface.SetDrawColor(colors.notifications.icons)
        strider.DrawImage("https://i.imgur.com/2yD38xv.png", pad, pad, h - pad - pad, h - pad - pad)

        draw.Text({
            text = self.text,
            pos = {h + pad, h / 2},
            yalign = 1,
            font = self.font,
        })
    end

    function PANEL:PaintOver(w, h)
        local x, y = self:LocalToScreen(0, 0)
        render.SetScissorRect(x, y + (h - strider.Scale(2)), x + (self.isprog and w or (w - w * ((CurTime() - self.start) / self.length))), y + h, true)
        draw.RoundedBox(strider.Scale(4), 0, 0, w, h, colors.notifications.types[self.type] or colors.notifications.vote)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

-- vote PANEL
do
    local PANEL = vgui.Register("strider:HUD:VoteNotification", {}, "strider:HUD:Notification")

    function PANEL:Init()
        self:SetSize(300, strider.Scale(45))
        self.font = strider.Font(20)
        self.button_yes = vgui.Create("DButton", self)
        self.button_no = vgui.Create("DButton", self)
        self.canv = vgui.Create("DPanel", self)
        self.button_yes:SetText("")
        self.button_no:SetText("")

        function self.button_yes:Paint(w, h)
            self.bg = strider.colors.Lerp(FrameTime() * 10, self.bg or colors.notifications.darker, self:IsHovered() and colors.notifications.vote_btn_hovered or colors.notifications.darker)
            draw.RoundedBoxEx(strider.Scale(4), 0, 0, w, h, self.bg, true, false, true)
            surface.SetDrawColor(colors.notifications.icons)
            strider.DrawImage("https://i.imgur.com/RIBQmWH.png", w / 2 - h / 4, h / 2 - h / 4, h / 2, h / 2)
        end

        function self.button_no:Paint(w, h)
            self.bg = strider.colors.Lerp(FrameTime() * 10, self.bg or colors.notifications.darker, self:IsHovered() and colors.notifications.vote_btn_hovered or colors.notifications.darker)
            surface.SetDrawColor(self.bg)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(colors.notifications.icons)
            strider.DrawImage("https://i.imgur.com/pwYic06.png", w / 2 - h / 4, h / 2 - h / 4, h / 2, h / 2)
        end

        function self.button_yes.DoClick()
            LocalPlayer():ConCommand(self.yes)
            self:PostCommand()
        end

        function self.button_no.DoClick()
            LocalPlayer():ConCommand(self.no)
            self:PostCommand()
        end

        function self.canv.Paint(s, w, h)
            draw.RoundedBoxEx(strider.Scale(4), 0, 0, w, h, colors.notifications.background, false, true, false, true)

            draw.Text({
                text = self.text,
                pos = {w / 2, h / 2},
                xalign = 1,
                yalign = 1,
                font = self.font
            })
        end
    end

    function PANEL:PostCommand()
        self.button_yes.DoClick = function() end
        self.button_no.DoClick = function() end
        self.outstart = CurTime()
        self.Think = self.ThinkOut
    end

    function PANEL:CalcW()
        surface.SetFont(self.font)

        return (self.button_yes:GetWide() * 2) + surface.GetTextSize(self.text) + strider.Scale(20)
    end

    function PANEL:PerformLayout(w, h)
        self.button_yes:Dock(LEFT)
        self.button_yes:SetWide(strider.Scale(45))
        self.button_no:Dock(LEFT)
        self.button_no:SetWide(strider.Scale(45))
        self.canv:Dock(FILL)
        self:SetWide(self:CalcW())
    end

    function PANEL:Paint(w, h)
    end
end

-- strider methods
do
    function strider.HUD.AddNotification(text, type, length, isprog, custom_panel_type)
        strider.HUD.Notifications = strider.HUD.Notifications or {}
        strider.HUD.SpecialNotifications = strider.HUD.SpecialNotifications or {}

        local pnl = vgui.Create(custom_panel_type or "strider:HUD:Notification", nil, "StriderNotification")
        pnl.text = text
        pnl.type = type
        pnl.length = length
        pnl.start = CurTime()
        pnl.isprog = isprog
        pnl:SetAlpha(0)
        table.insert(strider.HUD.Notifications, pnl)
        pnl.id = #strider.HUD.Notifications
        pnl:SetWide(pnl:CalcW())

        return pnl
    end

    function strider.HUD.KillNotification(id)
        if strider.HUD.SpecialNotifications[id] then
            strider.HUD.SpecialNotifications[id]:Remove()
            strider.HUD.SpecialNotifications[id] = nil
            return
        end

        if not strider.HUD.Notifications[id] then return end
        strider.HUD.Notifications[id]:Remove()
        strider.HUD.Notifications = nil
    end

    function strider.HUD.UpdateNotifs()
        for k, v in pairs(strider.HUD.Notifications or {}) do
            if not IsValid(v) then continue end
            v.id = k
        end
    end
end

notification.STRIDEROLD__AddLegacy = notification.STRIDEROLD__AddLegacy or notification.AddLegacy
notification.STRIDEROLD__Kill = notification.STRIDEROLD__Kill or notification.Kill
notification.STRIDEROLD__AddProgress = notification.STRIDEROLD__AddProgress or notification.AddProgress

hook.Add("PostGamemodeLoaded", "strider:HUD:ReplaceDarkRPVotes", function()
    notification.AddLegacy = function(...)
        if not strider.HUD.Config.modules.Notifications then return notification.STRIDEROLD__AddLegacy(...) end

        return strider.HUD.AddNotification(...)
    end

    -- notification.Kill = function(...)
    --     if not strider.HUD.Config.modules.Notifications then return notification.STRIDEROLD__Kill(...) end

    --     return strider.HUD.KillNotification(...)
    -- end

    -- notification.AddProgress = function(id, text, frac)
    --     if not strider.HUD.Config.modules.Notifications then return notification.STRIDEROLD__AddProgress(id, text, frac) end
    --     local p = strider.HUD.AddNotification(text, NOTIFY_HINT, 0, true)
    --     strider.HUD.SpecialNotifications[id] = p
    -- end

    if not strider.HUD.Config.modules.NotificationVotes then return end

    notification.AddVote = function(text, id, time, yes, no)
        local p = strider.HUD.AddNotification(text, nil, time, false, "strider:HUD:VoteNotification")
        strider.HUD.SpecialNotifications[id] = p
        p.yes = yes
        p.no = no
    end

    usermessage.Hook("DoQuestion", function(msg)
        local text = msg:ReadString()
        local id = msg:ReadString()
        local time = msg:ReadFloat()
        notification.AddVote(text, "question:" .. id, time, "vote " .. id .. " yea", "vote " .. id .. " nay")
    end)

    usermessage.Hook("DoVote", function(msg)
        local text = msg:ReadString()
        local id = msg:ReadShort()
        local time = msg:ReadFloat()
        notification.AddVote(text, "vote:" .. id, time, "ans " .. id .. " 1", "ans " .. id .. " 2")
    end)

    usermessage.Hook("KillQuestionVGUI", function(msg)
        notification.Kill("question:" .. msg:ReadString())
    end)

    usermessage.Hook("KillVoteVGUI", function(msg)
        notification.Kill("vote:" .. msg:ReadShort())
    end)
end)

-- notification.AddLegacy("test", NOTIFY_CLEANUP, 2)

-- if not GAMEMODE then return end
-- hook.GetTable()["PostGamemodeLoaded"]["strider:HUD:ReplaceDarkRPVotes"]()
-- local rtime = math.random(4, 12)
-- notification.AddLegacy("This is what notifications look like!", NOTIFY_HINT, rtime)
-- notification.AddVote("The Man wants to become Police Chief, vote!", "cum", 15, "yes", "no")
-- -- lua_run DarkRP.createVote("Someeone is gay ban him", "test" .. CurTime(), Player(1), 20, function() print("Successful") end)
