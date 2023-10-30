
local PANEL = vgui.Register("strider:Frame", {}, "DPanel")

function PANEL:Init()
    self.topbar = vgui.Create("strider:Draggable", self)
    self.topbar:SetAreaOf(self)

    function self.topbar:Paint(w, h)
        surface.SetDrawColor(strider.themes.Get("accent"))
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(strider.themes.Get("background"))
    surface.DrawRect(0, 0, w, h)
end

-- function PANEL:PaintOver(w, h)
    -- local oc = DisableClipping(true)
    -- surface.SetDrawColor(strider.themes.Get("accent"))
    -- surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 1)

    -- surface.SetDrawColor(strider.themes.Get("background"))
    -- surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 1)

    -- DisableClipping(oc)
-- end

function PANEL:PerformLayoutInternal(w, h)
    self.topbar:SetSize(w, strider.Scale(30))
    self.topbar:SetPos(0, 0)
end

PANEL.PerformLayout = PANEL.PerformLayoutInternal

if not melon then return end
melon.DebugPanel("strider:Frame", function(p)
    p:SetSize(1200, 800)
    p:Center()
end )