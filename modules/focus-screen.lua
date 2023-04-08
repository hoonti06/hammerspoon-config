local function focus_next_screen() -- focuses the next screen 
   local screen = hs.mouse.getCurrentScreen()
   local nextScreen = screen:next()
   local rect = nextScreen:fullFrame()
   local center = hs.geometry.rectMidPoint(rect)
   hs.mouse.setAbsolutePosition(center)
end 

local function focus_previous_screen() -- focuses the other screen 
   local screen = hs.mouse.getCurrentScreen()
   local prevScreen = screen:previous()
   local rect = prevScreen:fullFrame()
   local center = hs.geometry.rectMidPoint(rect)
   hs.mouse.setAbsolutePosition(center)
end 

function get_window_under_mouse() -- from https://gist.github.com/kizzx2/e542fa74b80b7563045a 
   local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
   local my_screen = hs.mouse.getCurrentScreen()
   return hs.fnutils.find(hs.window.orderedWindows(), function(w)
       return my_screen == w:screen() and my_pos:inside(w:frame())
   end)
end

function activate_next_screen()
   focus_next_screen() 
   local win = get_window_under_mouse() 
   win:focus() 
end 

function activate_previous_screen()
   focus_previous_screen() 
   local win = get_window_under_mouse() 
   win:focus() 
end 

hs.hotkey.bind({'ctrl', 'shift'}, ';', function() -- does the keybinding
    activate_previous_screen()
end)
