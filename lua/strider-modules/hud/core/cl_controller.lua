
strider.HUD.Hides = strider.HUD.Hides or {}

function strider.HUD.Hide(...)
    for k,v in pairs({...}) do
        strider.HUD.Hides[v] = true
    end
end

hook.Add("HUDShouldDraw", "Strider:HUD:Hides", function(n)
    if strider.HUD.Hides[n] then return false end
end )

function strider.HUD.Create()
    if IsValid(strider.HUD.Panel) then
        strider.HUD.Panel:Remove()
    end

    strider.HUD.Panel = vgui.Create("Panel")
    strider.HUD.Panel:ParentToHUD()
    strider.HUD.Panel:SetSize(ScrW(), ScrH())
    strider.HUD.Panel.OnScreenSizeChanged = function(s)
        s:SetSize(ScrW(), ScrH())
    end
    strider.HUD.Panel.PerformLayout = function(s, w, h)
        for k, v in pairs(s:GetChildren()) do
            if not v.RequestSize then continue end
            local nw, nh = v:RequestSize(w, h)
            v:SetSize(nw, nh)

            if not v.RequestPos then continue end
            v:SetPos(v:RequestPos(w, h, nw, nh))
        end
    end

    local modules = {
        Main = strider.HUD.Config.use_bar and "strider:HUD:Topbar" or "strider:HUD:Main",
        Ammo = "strider:HUD:Ammo",
        AgendaLaws = "strider:HUD:AgendaLaws",
        PropCounter = "strider:HUD:PropCounter"
    }

    for k,v in pairs(modules) do
        if not strider.HUD.Config.modules[k] then continue end

        local p = vgui.Create(v, strider.HUD.Panel)
        strider.HUD[k] = p

        if istable(p.hides) then
            for _,hide in pairs(p.hides) do
                strider.HUD.Hide(hide)
            end
        elseif p.hides then
            strider.HUD.Hide(hide)
        end
    end
end

function strider.HUD.Refresh()
    if GAMEMODE then
        hook.Call("Strider:HUD:Refresh")
        strider.HUD.Create()
    end
end

hook.Add("InitPostEntity", "Strider:HUD:Create", function()
    strider.HUD.Create()
end )
