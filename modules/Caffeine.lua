-- https://github.com/johngrib/hammerspoon-config/blob/master/modules/Caffeine.lua

local obj = {}

function obj:init(spoon)
    hs.loadSpoon('Caffeine')

--    spoon.Caffeine:bindHotkeys({
--        toggle = {{'control'}, 'f19'},
--    })

    spoon.Caffeine:start()
    spoon.Caffeine:setState(false)
end

return obj
