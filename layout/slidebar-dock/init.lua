local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require('beautiful')
local icons = require('theme.icons')
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require('widget.clickable-container')
local task_list = require('widget.task-list')


local Slidebar = {}
Slidebar.__index = Slidebar

local function over_bar(o)
    local c = mouse.current_wibox
    if c == o.wslidebar then
        return true
    else
        return false
    end
end

local function over_activator(o)
    local c = mouse.current_wibox
    if c == o.wactivator then
        return true
    else
        return false
    end
end

local function create_or_update_callbacks(o)
    local p = o.position
    local axis = o.axis
    local max = o.max
    local delta_inc = o.delta
    local limit = o.limit
    local size = o.size
    local easing = o.easing / 1000

    o.t_show = nil
    o.t_hide = nil
    o.t_slide_show = nil
    o.t_slide_hide = nil

    local function t_show_always()
        o.wslidebar[axis] = o.wslidebar[axis] + size
    end

    local function t_slide_show_cb()
        if p == "top" or p == "left" then
            return function()
                if not over_bar(o) and not over_activator(o) then
                    return false
                end
                if o.wslidebar[axis] < 0 then
                    o.wslidebar[axis] = o.wslidebar[axis] + delta_inc
                    return true
                end
                return false
            end
        else
            return function()
                if not over_bar(o) and not over_activator(o) then
                    return false
                end
                if o.wslidebar[axis] > limit then
                    o.wslidebar[axis] = o.wslidebar[axis] - delta_inc
                    return true
                else
                    return false
                end
            end
        end
    end

    local function t_slide_hide_cb()
        if p == "top" or p == "left" then
            return function()
                if over_bar(o) or over_activator(o) then
                    return false
                end
                if o.wslidebar[axis] > -size then
                    o.wslidebar[axis] = o.wslidebar[axis] - delta_inc
                    return true
                else
                    return false
                end
            end
        else
            return function()
                if over_bar(o) or over_activator(o) then
                    return false
                end
                if o.wslidebar[axis] < max then
                    o.wslidebar[axis] = o.wslidebar[axis] + delta_inc
                    return true
                else
                    return false
                end
            end
        end
    end

    o.slide_show_cb = t_slide_show_cb()
    o.slide_hide_cb = t_slide_hide_cb()

    local function t_show_cb()
        if p == "top" or p == "left" then
            return function()
                if o.wslidebar[axis] < 0 then
                    if o.t_slide_show ~= nil and o.t_slide_show.started == true then
                        return false
                    end
                    o.t_slide_show = gears.timer.start_new(
                                       easing, o.slide_show_cb)
                end
                -- NOT SURE WHAT THIS DOES
                -- o.t_show = nil
                -- return false
            end
        else
            return function()
                if o.wslidebar[axis] > limit then
                    if o.t_slide_show ~= nil and o.t_slide_show.started == true then
                        return false

                    end
                    o.t_slide_show = gears.timer.start_new(
                                       easing, o.slide_show_cb)
                end
                -- NOT SURE WHAT THIS DOES
                -- o.t_show = nil
                -- return false
            end
        end
    end

    local function t_hide_cb()
        if p == "top" or p == "left" then
            return function()
                if o.wslidebar[axis] > -size then
                    if o.t_slide_hide ~= nil and o.t_slide_hide.started == true then
                        return false
                    end
                    o.t_slide_hide = gears.timer.start_new(
                                       easing, o.slide_hide_cb)
                end
                o.t_hide = nil
                return false
            end
        else
            return function()
                if o.wslidebar[axis] < max then
                    if o.t_slide_hide ~= nil and o.t_slide_hide.started == true then
                        return
                    end
                    o.t_slide_hide = gears.timer.start_new(
                                       easing, o.slide_hide_cb)
                end
                o.t_hide = nil
                return false
            end
        end
    end

    o.show_cb = t_show_cb()
    o.hide_cb = t_hide_cb()

end

local function connect_signals(o)

    o.wactivator:connect_signal(
      "mouse::enter", function()
          if o.t_hide ~= nil and o.t_hide.started == true then
              o.t_hide:stop()
          end
          if o.t_show ~= nil and o.t_show.started == true then
              return
          end
          o.t_show = gears.timer.start_new(o.show_delay, o.show_cb)
      end)

    o.wactivator:connect_signal(
      "mouse::leave", function()
      end)

    o.wslidebar:connect_signal(
      "mouse::enter", function()
          if o.t_hide ~= nil and o.t_hide.started == true then
              o.t_hide:stop()
          end
          if o.t_show ~= nil and o.t_show.started == true then
              return
          end
          o.t_show = gears.timer.start_new(o.show_delay, o.show_cb)
      end)

    o.wslidebar:connect_signal(
      "mouse::leave", function()
          if o.t_show ~= nil and o.t_show.started == true then
              o.t_show:stop()
          end

          if o.t_hide ~= nil and o.t_hide.started == true then
              return
          end
          o.t_hide = gears.timer.start_new(o.hide_delay, o.hide_cb)
      end)
end

local function create_or_update_activator(o)
    if not o.wactivator then
        o.wactivator = wibox()
    end
    local a = o.wactivator
    a.height = o.height_activator
    a.opacity = 0
    a.screen = o.screen
    a.type = "dock"
    a.visible = true
    a.ontop = true
    -- a.width = o.width_activator
    a.width = 900
    a.x = o.x
    a.y = o.y_activator
end

local function calc_activator_geometry(o)
    local p = o.position
    o.width_activator = (p == "top" or p == "bottom") and o.screen_width or
                          o.size_activator
    o.height_activator = (p == "left" or p == "right") and o.screen_height or
                           o.size_activator
    o.x_activator = (p == "right") and (o.max - o.size_activator) or 0
    o.y_activator = (p == "bottom") and (o.max - o.size_activator) or 0
end



-- s.search = require('widget.search-apps')()

local function create_or_update_bar(o)
    if not o.wslidebar then
        o.wslidebar = wibox()
    end
    local b = o.wslidebar
    b.bg = o.bg
    b.screen = o.screen
    b.height = o.height
    b.ontop = true
    b.type = "dock"
    b.visible = true
    b.width = 900
    b.x = o.x
    b.y = o.y
    b.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
        -- gears.shape.rectangle(cr, w, h)
    end
end

local function calc_axis_max_limit(o)
    local p = o.position
    o.axis = (p == "top" or p == "bottom") and "y" or "x"
    o.max = (p == "top" or p == "bottom") and o.screen_height or o.screen_width
    o.limit = o.max - o.size
end

local function calc_bar_geometry(o)
    local x = {
        ["top"] = 0,
        ["bottom"] = o.screen_width/2 - 450,
        ["left"] = -o.size,
        ["right"] = o.screen_width,
    }
    local y = {
        ["top"] = -o.size,
        ["bottom"] = o.screen_height,
        ["left"] = 0,
        ["right"] = 0,
    }
    local width = {
        ["top"] = o.screen_width,
        ["bottom"] = o.screen_width,
        ["left"] = o.size,
        ["right"] = o.size,
    }
    local height = {
        ["top"] = o.size,
        ["bottom"] = o.size,
        ["left"] = o.screen_height,
        ["right"] = o.screen_height,
    }
    local p = o.position
    o.height = height[p]
    o.width = width[p]
    o.y = y[p]
    o.x = x[p]
end

local function calc_screen_dims(o)
    if o.screen then
        o.screen_width = o.screen.geometry.width
        o.screen_height = o.screen.geometry.height
    else
        o.screen_width = awful.screen.focused().geometry.width
        o.screen_height = awful.screen.focused().geometry.height
    end
end

local function redo_bar(o)
    if not o.wslidebar and o.wactivator then
        return
    end
    calc_screen_dims(o)
    calc_axis_max_limit(o)
    calc_bar_geometry(o)
    create_or_update_bar(o)
    calc_activator_geometry(o)
    create_or_update_activator(o)
    create_or_update_callbacks(o)
end

local slidebar_instance_mt = {
    __index = function(self, k)
        return self.__data[k]

    end,

    __newindex = function(self, prop, val)
        local dat = self.__data
        if prop == "bg" then
            self.__data.bg = val
            if self.__data.wslidebar then
                self.__data.wslidebar.bg = val
            end
            return
        end

        if prop == "easing" then
            if val == self.__data.easing then
                return
            end
            self.__data.easing = val
            create_or_update_callbacks(self)
            return
        end

        if prop == "delta" then
            if val == self.__data.delta then
                return
            end
            self.__data.delta = val
            create_or_update_callbacks(self)
            return
        end

        if prop == "hide_delay" then
            self.__data.hide_delay = val
            return
        end

        if prop == "screen" then
            if val == self.__data.screen then
                return
            end
            self.__data.screen = val
            redo_bar(self)
            return
        end

        if prop == "show_delay" then
            self.__data.show_delay = val
            return
        end

        if prop == "size" then
            if val == self.__data.size then
                return
            end
            self.__data.size = val
            redo_bar(self)
            return
        end

        if prop == "size_activator" then

            if val == self.__data.size_activator then
                return
            end
            if val > self.__data.size then
                self.__data.size_activator = self.__data.size
            else
                self.__data.size_activator = val
            end
            calc_activator_geometry(self)
            create_or_update_activator(self)
            return
        end

        if prop == "position" then
            if val == self.__data.position then
                return
            end
            self.__data.position = val
            redo_bar(self)
            return
        end

        self.__data[prop] = val
    end,
}

function Slidebar.new(args)
    args = args or {}
    local self = {
        ["__data"] = {
            ["delta"] = 1,
            ["bg"] = "#282a36",
            ["easing"] = 2,
            ["hide_delay"] = 0.5,
            ["position"] = "top",
            ["screen"] = nil,
            ["show_delay"] = 0.25,
            ["size"] = 45,
            ["size_activator"] = 1
        },
    }
    setmetatable(self.__data, Slidebar)
    setmetatable(self, slidebar_instance_mt)
    for k, v in pairs(args) do
        self[k] = v
    end
    calc_screen_dims(self)
    calc_axis_max_limit(self)
    calc_bar_geometry(self)
    create_or_update_bar(self)
    calc_activator_geometry(self)
    create_or_update_activator(self)
    create_or_update_callbacks(self)
    connect_signals(self)
    return self
end


function Slidebar:setup(s)

    s.search = require('widget.search-apps')()
    local tag_list = require('widget.tag-list')

    self.wslidebar:setup{
        layout = wibox.layout.fixed.horizontal,
        s.search,
        separator,
        tag_list(s),
        require('widget.xdg-folders')()
    }
end

-- function Slidebar:setup(s)

--     s.search = require('widget.search-apps')()
--     local tag_list = require('widget.tag-list')

--     self.wslidebar:setup{
--         local panel = awful.popup {
--             widget = {
--                 {
--                     layout = wibox.layout.fixed.horizontal,
--                     s.search,
--                     separator,
--                     tag_list(s),
--                     require('widget.xdg-folders')()
--                 },
--                 bg = beautiful.background,
--                 shape = function(cr, w, h)
--                     gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
--                     -- gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
--                 end,
--                 widget = wibox.container.background
--             },
--             type = 'dock',
--             screen = s,
--             ontop = true,
--             visible = true,
--             height = bottom_panel_height,
--             maximum_height = bottom_panel_height,
--             placement = awful.placement.bottom,
--             shape = gears.shape.rectangle,
--             bg = beautiful.transparent
--         }
--     }
-- end


function Slidebar:hide_bar()
    self.wactivator.visible = false
    self.wslidebar.visible = false
end

function Slidebar:show_bar()
    self.wactivator.visible = true
    self.wslidebar.visible = true
end

return setmetatable(
         Slidebar, {
      __call = function(_, ...)
          return Slidebar.new(...)
      end,
  })
