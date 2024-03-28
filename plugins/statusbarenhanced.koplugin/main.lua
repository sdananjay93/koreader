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
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local Hello = WidgetContainer:extend {
    name = "hello",
    is_doc_only = false,
}

function Hello:onDispatcherRegisterActions()
    Dispatcher:registerAction("helloworld_action",
        { category = "none", event = "HelloWorld", title = _("Hello World"), general = true, })
end

function Hello:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Hello:addToMainMenu(menu_items)
    menu_items.status_bar_v2 = {
        text = _("Status Bar V2"),
        -- in which menu this should be appended
        sorting_hint = "setting",
        sub_item_table = {
            {
                text = _("About Status Bar V2"),
                callback = function()
                    UIManager:show(InfoMessage:new {
                        text = _("This is an alternative to the bottom Footer. " ..
                            "Enabling this will disable the Built-in footer. " ..
                            "Disabling this, will restore the original footer settings")
                    })
                end
            }
        }
    }
end

function Hello:onHelloWorld()
    local popup = InfoMessage:new {
        text = _("Hello World"),
    }
    UIManager:show(popup)
end

return Hello
