local awful = require('awful')
local gears = require('gears')
local wibox = require ('wibox')
local beautiful = require('beautiful')
local titlebar_core = require('module.titlebar-core')
local layout = require('layout')
local slidebar = require('layout.slidebar')
local naughty = require('naughty')

local myslidebar = slidebar {
	bg = '#00000099',
	position = "left",
	size = beautiful.titlebar_size
	-- size_activator = 1
	-- show_delay = 0.25,
	-- hide_delay = 0.5,
	-- easing = 2,
	-- delta = 1,
	-- screen = nil
}

local update_client = function(c)
	-- Set client's shape based on its tag's layout and status (floating, maximized, etc.)
	local current_layout = awful.tag.getproperty(c.first_tag, 'layout')
	if current_layout == awful.layout.suit.max and (not c.floating) then
		c.shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(6))
			-- gears.shape.rectangle(cr, w, h)
			end
	elseif c.maximized then
		c.shape = function(cr, w, h)
			-- gears.shape.rounded_rect(cr, w, h, dpi(6))
			gears.shape.rectangle(cr, w, h)
			end
	elseif c.fullscreen then
		c.shape = beautiful.client_shape_rectangle
	elseif (not c.round_corners) then
		c.shape = function(cr, w, h)
			-- gears.shape.rounded_rect(cr, w, h, dpi(6))
			gears.shape.rectangle(cr, w, h)
			end
	else
		c.shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(6))
			-- gears.shape.rectangle(cr, w, h)
			end
	end
end

-- Signal function to execute when a new client appears.
client.connect_signal(
	'manage',
	function(c)
		-- Focus, raise and activate
		c:emit_signal(
			'request::activate',
			'mouse_enter',
			{
				raise = true
			}
		)

		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		if not awesome.startup then
			awful.client.setslave(c)
		end

		if awesome.startup and not c.size_hints.user_position and
			not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end

		-- Update client shape
		update_client(c)
	end
)

-- Enable sloppy focus, so that focus follows mouse then raises it.
client.connect_signal(
	'mouse::enter',
	function(c)
		c:emit_signal(
			'request::activate',
			'mouse_enter',
			{
				raise = true
			}
		)
	end
)

client.connect_signal(
	'focus',
	function(c)
		c.border_color = beautiful.border_focus
	end
)

client.connect_signal(
	'unfocus',
	function(c)
		c.border_color = beautiful.border_normal
	end
)

-- Manipulate client shape on fullscreen/non-fullscreen
client.connect_signal(
	'property::fullscreen',
	function(c)
		if c.fullscreen then
			c.shape = beautiful.client_shape_rectangle
			
		else
			update_client(c)
		end
	end
)

-- on close
client.connect_signal(
	'property::floating',
	function(c)
		local current_layout = awful.tag.getproperty(c.first_tag, 'layout')
		if c.floating and not c.maximized then
			c.shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, dpi(6))
				--gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
				-- gears.shape.rectangle(cr, w, h)
				end
		else
			if current_layout == awful.layout.suit.max then
				c.shape = beautiful.client_shape_rectangle
			end
		end
	end
)

-- Manipulate client shape on maximized
client.connect_signal(
	'property::maximized',
	function(c)
		local current_layout = awful.tag.getproperty(c.first_tag, 'layout')
		if c.maximized then
			c.shape = function(cr, w, h)
				-- gears.shape.rounded_rect(cr, w, h, dpi(6))
				--gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
				gears.shape.rectangle(cr, w, h)
			end
		else
			update_client(c)
		end
	end
)

-- Manipulate client shape on floating
client.connect_signal(
	'property::floating',
	function(c)
		local current_layout = awful.tag.getproperty(c.first_tag, 'layout')
		if c.floating and not c.maximized then
			c.shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, dpi(6))
				--gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
				-- gears.shape.rectangle(cr, w, h)
			end
		else
			if current_layout == awful.layout.suit.max then
				c.shape = function(cr, w, h)
					-- gears.shape.rounded_rect(cr, w, h, dpi(6))
					--gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
					gears.shape.rectangle(cr, w, h)
				end
			end
		end
	end
)
