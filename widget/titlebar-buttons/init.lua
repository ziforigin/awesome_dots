local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local clickable_container = require('widget.clickable-container')
local icons = require('theme.icons')

--- Common method to create buttons.
-- @tab buttons
-- @param object
-- @return table
local function create_buttons(buttons, object)
	if buttons then
		local btns = {}
		for _, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them to the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = awful.button {
				modifiers = b.modifiers,
				button = b.button,
				on_press = function()
					b:emit_signal('press', object)
				end,
				on_release = function()
					b:emit_signal('release', object)
				end
			}
			btns[#btns + 1] = btn
		end
		return btns
	end
end

local function list_update(w, buttons, label, data, objects)
	-- Update the widgets, creating them if needed
	w:reset()
	for i, o in ipairs(objects) do
		local cache = data[o]
		local ib, cb, cbm, bgb, ibm, tt, l, ll, bg_clickable
		if cache then
			ib = cache.ib
			bgb = cache.bgb
			ibm = cache.ibm
		else
			ib = wibox.widget {
				{
					{
						image = icons.fullscreen_titlebar,
						-- resize = true,
						widget = wibox.widget.imagebox
					},
					margins = dpi(4),
					widget = wibox.container.margin
				},
				widget = clickable_container
			}
			cb = wibox.widget {
				{
					{
						image = icons.close_titlebar,
						-- resize = true,
						widget = wibox.widget.imagebox
					},
					margins = dpi(4),
					widget = wibox.container.margin
				},
				widget = clickable_container
			}
			cb.shape = gears.shape.circle
			cbm = wibox.widget {
				-- 4, 8 ,12 ,12 -- close buttonf
				cb,
				left = dpi(4),
				right = dpi(4),
				top = dpi(4),
				bottom = dpi(4),
				widget = wibox.container.margin
			}
		
			cbm:buttons(
				gears.table.join(
					awful.button(
						{},
						1,
						nil,
						function()
							o:kill()
						end
					)
				)
			)
			bg_clickable = clickable_container()
			bgb = wibox.container.background()
			ibm = wibox.widget {
				-- 4, 8 ,12 ,12 -- close buttonf
				ib,
				left = dpi(4),
				right = dpi(4),
				top = dpi(4),
				bottom = dpi(4),
				widget = wibox.container.margin
			}
			l = wibox.layout.fixed.horizontal()
			ll = wibox.layout.fixed.horizontal()

			-- All of this is added in a fixed widget
			l:fill_space(true)
			l:add(ibm)
			ll:add(l)
			ll:add(cbm)
			-- l:add(ibm)


			bg_clickable:set_widget(ll)
			-- And all of this gets a background
			bgb:set_widget(bg_clickable)

			l:buttons(create_buttons(buttons, o))

			-- Tooltip to display whole title, if it was truncated
			-- tt = awful.tooltip({
			-- 	objects = {tb},
			-- 	mode = 'outside',
			-- 	align = 'bottom',
			-- 	delay_show = 1,
			-- })

			data[o] = {
				ib = ib,
				bgb = bgb,
				ibm = ibm
			}
		end

		local text, bg, bg_image, icon, args = label(o, tb)
		args = args or {}

		bgb:set_bg(bg)
		if type(bg_image) == 'function' then
			-- TODO: Why does this pass nil as an argument?
			bg_image = bg_image(o, nil, objects, i)
		end
		bgb:set_bgimage(bg_image)
		if icon then
			ib.image = gears.surface(icon)
		else
			ibm:set_margins(0)
		end

		bgb.shape = args.shape
		bgb.shape_border_width = args.shape_border_width
		bgb.shape_border_color = args.shape_border_color

		w:add(bgb)
	end
end

local tasklist_buttons = awful.util.table.join(
	awful.button(
		{},
		1,
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end
	),
	awful.button(
		{},
		2,
		function(c)
			c:kill()
		end
	),
	awful.button(
		{},
		4,
		function()
			awful.client.focus.byidx(1)
		end
	),
	awful.button(
		{},
		5,
		function()
			awful.client.focus.byidx(-1)
		end
	)
)

local titlebar_buttons = function(s)
	return awful.widget.tasklist(
		s,
		awful.widget.tasklist.filter.currenttags,
		tasklist_buttons,
		{},
		list_update,
		wibox.layout.fixed.horizontal()
	)
end

return titlebar_buttons
