local titlebar = require('awful.titlebar')


function fullscreen_button(c)
    local widget = titlebar.widget.button(c, "fullscreen", function(cl)
        return cl.fullscreen
    end, function(cl, state)
        cl.fullscreen = not state
    end)
    update_on_signal(c, "property::fullscreen", widget)
    return widget
end