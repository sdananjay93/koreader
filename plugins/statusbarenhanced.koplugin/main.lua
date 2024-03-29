--[[--
This is a debug plugin to test Plugin functionality.

@module koplugin.HelloWorld
--]]
--

-- This is a debug plugin, remove the following if block to enable it
-- if true then
--     return { disabled = true, }
-- end

local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local Notification = require("ui/widget/notification")
local UIManager = require("ui/uimanager")
local Event = require("ui/event")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local logger = require("logger")
local ReaderFooter = require("apps.reader.modules.readerfooter")

local BetterBar = WidgetContainer:extend {
    name = "BetterBar",
    bar_settings_file = DataStorage:getSettingsDir() .. "/better_status_bar.lua",
    defaults = {
        enabled = false
    }
}

local about_bar = "This is an alternative to the bottom Footer. " ..
    "Enabling this will disable the Built-in footer. " ..
    "Disabling this, will restore the original footer settings"

orig_settings_to_update = {
    "page_progress",
    "pages_left_book",
    "time",
}

-- function BetterBar:onDispatcherRegisterActions()
--     Dispatcher:registerAction("helloworld_action",
--         { category = "none", event = "HelloWorld", title = _("Hello World"), general = true, })
-- end

function BetterBar:init()
    logger.dbg("DJ: Better Bar Intialized")
    -- self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
    self.better_settings = LuaSettings:open(self.bar_settings_file)
    if not self.better_settings.data.footer_v2 then
        logger.dbg("DJ: Settings is empty..")
        self.better_settings:readSetting("footer_v2", self.defaults)
    end
    self.bar_settings = self.better_settings.data.footer_v2
    if self.bar_settings.enabled and self.view then
        self.view.footer_visible = false
    end
end

function BetterBar:addToMainMenu(menu_items)
    logger.dbg("DJ: Adding to Menu")
    local sub_items = {}
    menu_items.status_bar_v2 = {
        text = _("Status Bar V2"),
        -- in which menu this should be appended
        sorting_hint = "main",
        sub_item_table = sub_items
    }
    -- Add about Status Bar
    table.insert(sub_items, {
        text = _("About Status Bar V2"),
        callback = function()
            return self:notify(about_bar, 'popup')
        end
    })
    -- Enable / Disable V2
    table.insert(sub_items, {
        text = _("Enable Better Bar"),
        checked_func = function()
            return self.bar_settings.enabled == true
        end,
        callback = function()
            self.bar_settings.enabled = not self.bar_settings.enabled
            if self.bar_settings.enabled then
                self.view.footer_visible = false
            else
                self.view.footer_visible = true
                self.view.footer:refreshFooter()
            end
        end
    })
end

function BetterBar:notify(msg, notif_type)
    local popup
    notif_type = notif_type or "notify"
    if notif_type == "popup" then
        popup = InfoMessage:new {
            text = _(msg)
        }
    elseif notif_type == "notify" then
        popup = Notification:new {
            text = _(msg)
        }
    end
    return UIManager:show(popup)
end

function BetterBar:onCloseDocument()
    self.better_settings:close()
end

function BetterBar:onFlushSettings()
    self.better_settings:close()
end

return BetterBar
