
local PANEL = vgui.Register("strider:HUD:Topbar:Player", {}, "Panel")

function PANEL:Init()
    strider.thirdparty.getAvatarMaterial(LocalPlayer():SteamID64(), function(mat)
        if IsValid(self) then
            self.avatar_image = mat
        end
    end )

    self.SizeWeWant = strider.Scale(45)
end

function PANEL:PerformLayout(w, h)
    self.avatar = strider.thirdparty.rounded_boxes.RoundedBox(strider.Scale(4), 0, 0, h, h)
end

function PANEL:Paint(w, h)
    if not self.avatar_image or not self.avatar then return end

    local lp = LocalPlayer()
    surface.SetMaterial(self.avatar_image)
    surface.SetDrawColor(255,255,255)
    surface.DrawPoly(self.avatar)

    local pad = strider.Scale(5)
    local nw = draw.Text({
        text = lp:Nick(),
        pos = {h + pad, h / 2},
        xalign = 0,
        yalign = 4,
        font = strider.Font(math.floor(strider.HUD.Config.bar_h * .4), nil, 700)
    })

    local jt = lp:getJobTable()

    if not jt then return end
    local jw = draw.Text({
        text = jt.name,
        pos = {h + pad, h / 2},
        xalign = 0,
        yalign = 3,
        font = strider.Font(math.floor(strider.HUD.Config.bar_h * .35)),
        color = jt.color
    })


    local size = math.max(nw, jw, strider.Scale(70)) + h + pad
    if self.SizeWeWant != size then
        self.SizeWeWant = size
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:RequestWide()
    return self.SizeWeWant
end

strider.HUD.Refresh()
