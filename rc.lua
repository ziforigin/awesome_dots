-- ░█▀▀░█░█░█▀▄░█▀▄░█▀▀░█▀█░█░░
-- ░▀▀█░█░█░█▀▄░█▀▄░█▀▀░█▀█░█░░
-- ░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀▀▀
-- Banner generated using `toilet -f pagga AwesomeWM"

local gears = require('gears')
local beautiful = require('beautiful')
local awful = require('awful')
require('awful.autofocus')

-- ░█▀▀░█░█░█▀▀░█░░░█░░
-- ░▀▀█░█▀█░█▀▀░█░░░█░░
-- ░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀

awful.util.shell = 'sh'

-- ░▀█▀░█░█░█▀▀░█▄█░█▀▀
-- ░░█░░█▀█░█▀▀░█░█░█▀▀
-- ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀

beautiful.init(require('theme'))

-- ░█░░░█▀█░█░█░█▀█░█░█░▀█▀
-- ░█░░░█▀█░░█░░█░█░█░█░░█░
-- ░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀▀░░▀░

require('layout')

-- ░█▀▀░█▀█░█▀█░█▀▀░▀█▀░█▀▀░█░█░█▀▄░█▀█░▀█▀░▀█▀░█▀█░█▀█░█▀▀
-- ░█░░░█░█░█░█░█▀▀░░█░░█░█░█░█░█▀▄░█▀█░░█░░░█░░█░█░█░█░▀▀█
-- ░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀▀▀

require('configuration.client')
require('configuration.root')
require('configuration.tags')
root.keys(require('configuration.keys.global'))

-- ░█▄█░█▀█░█▀▄░█░█░█░░░█▀▀░█▀▀
-- ░█░█░█░█░█░█░█░█░█░░░█▀▀░▀▀█
-- ░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀

require('module.notifications')
require('module.auto-start')
require('module.exit-screen')
-- require('module.hot-corners')
require('module.quake-terminal')
require('module.menu')
require('module.titlebar')
require('module.brightness-osd')
require('module.volume-osd')
-- require('module.lockscreen')
-- require('module.dynamic-wallpaper')

-- ░█░█░█▀█░█░░░█░░░█▀█░█▀█░█▀█░█▀▀░█▀▄
-- ░█▄█░█▀█░█░░░█░░░█▀▀░█▀█░█▀▀░█▀▀░█▀▄
-- ░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░░░▀░▀░▀░░░▀▀▀░▀░▀

screen.connect_signal(
	'request::wallpaper',
	function(s)
		-- If wallpaper is a function, call it with the screen
		if beautiful.wallpaper then
			if type(beautiful.wallpaper) == 'string' then

				-- Check if beautiful.wallpaper is color/image
				if beautiful.wallpaper:sub(1, #'#') == '#' then
					-- If beautiful.wallpaper is color
					gears.wallpaper.set(beautiful.wallpaper)

				elseif beautiful.wallpaper:sub(1, #'/') == '/' then
					-- If beautiful.wallpaper is path/image
					gears.wallpaper.maximized(beautiful.wallpaper, s)
				end
			else
				beautiful.wallpaper(s)
			end
		end
	end
)

do
	local cmds =
	{
	  "setxkbmap -model pc105 -layout us,ru -variant qwerty -option grp:win_space_toggle -option altwin:swap_alt_win",
	  "xrandr --noprimary --output eDP --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --primary --mode 1920x1080 --pos 1920x0 --rotate normal"
	}
  
	for _,i in pairs(cmds) do
	  awful.spawn(i)
	end
end
