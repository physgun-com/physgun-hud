
local c = {}
strider.HUD = strider.HUD or {}
strider.HUD.Config = c

-- Do you want to replace the bottom left portion with a bar on the top of the screen?
c.use_bar = true

-- How tall should the barhud be? (scales automatically)
c.bar_h = 45

-- Only fill out if you are using the topbar
c.server_info = {
    logo_url = "https://i.imgur.com/JZemrSB.png",
    name = "Physgun.com"
}

-- Should there be shadows on the main element?
-- Can drop fps significantly unless on the topbar!!!!
c.shadows = true

-- override XeninUI Notifications
c.disableXeninNotifications = true

-- Should each module be enabled?
c.modules = {
    Main = true,
    Ammo = true,
    AgendaLaws = true,
    Notifications = true,
    NotificationVotes = true,
    PropCounter = true,
    EntDisplay = true,
    PlayerDisplay = true,
}

--- ADVANCED CONFIGURATION ---
-- Colors to be used
c.colors = {
    accent = Color(37, 99, 235),

    main = {
        background = Color(22, 22, 22),
        emptybar = Color(33, 33, 33),
        shadow = Color(0, 0, 0),
        name = Color(255, 255, 255),
        money = Color(58, 255, 125),
        salary = Color(58, 255, 125, 114),
        health = Color(218, 68, 68),
        armor = Color(27, 144, 209),
    },

    topbar = {
        background = Color(22, 22, 22),
        divider = Color(29, 29, 29),
        name = Color(255, 255, 255),
        money = Color(58, 255, 125),
        salary = Color(125, 125, 125),
        hpamtxt = Color(255,255,255),
        health = Color(218, 68, 68),
        armor = Color(27, 144, 209),
        serverinfotext = Color(255, 255, 255),
        shadow = Color(0, 0, 0, 150)
    },

    door = {
        title = Color(255, 255, 255),
        title_divider = Color(255, 255, 255),
        text = Color(255, 255, 255),
        f2bg = Color(107, 111, 115),
        f2text = Color(255, 255, 255)
    },

    ammo = {
        background = Color(22, 22, 22),
        border = Color(37, 99, 235),
        clip = Color(255, 255, 255),
        reserve = Color(165, 165, 165),
    },

    notices = {
        text = Color(255, 255, 255),
        topbar_background = Color(22, 22, 22),
        bars = {
            licensed = Color(37, 99, 235),
            wanted = Color(255, 58, 58),
        }
    },

    propcounter = {
        text = Color(255, 255, 255),
        icon = Color(255, 255, 255),
    },

    lawsandagenda = {
        background = Color(22, 22, 22),
        numberbg = Color(30, 30, 30),
        topbar = Color(19, 19, 19),
        title = Color(255, 255, 255),
        hide = Color(154, 154, 154),
        numbers = Color(154, 154, 154),
        text = Color(255, 255, 255)
    },

    player_display = {
        background = Color(22, 22, 22, 229),
        edge = Color(37, 99, 235),
        wanted_edge = Color(255, 0, 0),
        edge_bg = Color(109, 159, 255),
        wanted_edge_bg = Color(255, 109, 109),
        text = Color(255, 255, 255),
        wanted_icon = Color(255, 109, 109),
    },

    notifications = {
        background = Color(22,22,22),
        darker = Color(0, 0, 0),
        icons = Color(255, 255, 255),
        text = Color(255, 255, 255),
        types = CLIENT and {
            [NOTIFY_GENERIC] = Color(202, 198, 94),
            [NOTIFY_ERROR] = Color(255, 58, 58),
            [NOTIFY_UNDO] = Color(37, 99, 235),
            [NOTIFY_HINT] = Color(37, 99, 235),
            [NOTIFY_CLEANUP] = Color(202, 198, 94)
        },

        vote = Color(37, 99, 235),
        vote_btn_hovered = Color(44, 44, 44)
    },
}

-- List of notices
c.notices = {
    {
        text = "YOU ARE WANTED",
        show = function(p)
            return p:getDarkRPVar("wanted")
        end,
        color = c.colors.notices.bars.wanted
    },
    {
        text = "YOU ARE LICENSED",
        show = function(p)
            return p:getDarkRPVar("HasGunlicense")
        end,
        color = c.colors.notices.bars.licensed
    }
}

-- List of topbar elements
c.topbar_elements = {
    -- ltr
    left = {
        "strider:HUD:Topbar:Player",
        "strider:HUD:Topbar:Money",
        "strider:HUD:Topbar:HPArmor",
    },

    -- rtl
    right = {
        "strider:HUD:Topbar:Right",
    }
}

-- DONT TOUCH THIS LINE
    if strider.HUD.Refresh then strider.HUD.Refresh() end
    if c.disableXeninNotifications then
        if (XeninUI) then XeninUI.DisableNotification = true
        else hook.Add("XeninUI.PostLoadSettings", "Strider.DisableXeninNotifications", function() XeninUI.DisableNotification = true end) end
    end
-- DONT TOUCH THIS LINE
