local alert    = require("hs.alert")
local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")


local obj = {}

local vim_nav_icon = hs.menubar.new()
local inputEnglish = "com.apple.keylayout.ABC"

local cfg = {
    key_interval = 100,
    icon = { vim = "𝑽_ON", novim = "𝑽_OFF" },
}

local mode = {
    on        = false,
    triggered = false,
}

function obj:init(mode)
    local function displayOn()
        vim_nav_icon:setTitle(cfg.icon.vim)
    end
    local function displayOff()
        vim_nav_icon:setTitle(cfg.icon.novim)
    end


    local function vim_nav_end()
        mode.triggered = true
    end

    self.close = vim_nav_end

    local function setDisplay()
        if mode.on == false then
            self.on()
        else
            self.off()
        end
    end

    hs.fnutils.each({
        { mod={} , key='h' , func=rapidKey({} , 'left')  , repetition=true } ,
        { mod={} , key='j' , func=rapidKey({} , 'down')  , repetition=true } ,
        { mod={} , key='k' , func=rapidKey({} , 'up')    , repetition=true } ,
        { mod={} , key='l' , func=rapidKey({} , 'right') , repetition=true } ,
        { mod={'lcmd'} , key='h' , func=rapidKey({'lcmd'} , 'left')  , repetition=true } ,
        { mod={'lcmd'} , key='j' , func=rapidKey({'lcmd'} , 'down')  , repetition=true } ,
        { mod={'lcmd'} , key='k' , func=rapidKey({'lcmd'} , 'up')  , repetition=true } ,
        { mod={'lcmd'} , key='l' , func=rapidKey({'lcmd'} , 'right')  , repetition=true } ,
        { mod={'option'} , key='h' , func=rapidKey({'option'} , 'left')  , repetition=true } ,
        { mod={'option'} , key='j' , func=rapidKey({'option'} , 'down')  , repetition=true } ,
        { mod={'option'} , key='k' , func=rapidKey({'option'} , 'up')  , repetition=true } ,
        { mod={'option'} , key='l' , func=rapidKey({'option'} , 'right')  , repetition=true } ,
        { mod={'shift'} , key='h' , func=rapidKey({'shift'} , 'left')  , repetition=true } ,
        { mod={'shift'} , key='j' , func=rapidKey({'shift'} , 'down')  , repetition=true } ,
        { mod={'shift'} , key='k' , func=rapidKey({'shift'} , 'up')  , repetition=true } ,
        { mod={'shift'} , key='l' , func=rapidKey({'shift'} , 'right')  , repetition=true } ,
        { mod={'lcmd', 'shift'} , key='h' , func=rapidKey({'lcmd', 'shift'} , 'left')  , repetition=true } ,
        { mod={'lcmd', 'shift'} , key='j' , func=rapidKey({'lcmd', 'shift'} , 'down')  , repetition=true } ,
        { mod={'lcmd', 'shift'} , key='k' , func=rapidKey({'lcmd', 'shift'} , 'up')  , repetition=true } ,
        { mod={'lcmd', 'shift'} , key='l' , func=rapidKey({'lcmd', 'shift'} , 'right')  , repetition=true } ,
        { mod={'option', 'shift'} , key='h' , func=rapidKey({'option', 'shift'} , 'left')  , repetition=true } ,
        { mod={'option', 'shift'} , key='j' , func=rapidKey({'option', 'shift'} , 'down')  , repetition=true } ,
        { mod={'option', 'shift'} , key='k' , func=rapidKey({'option', 'shift'} , 'up')  , repetition=true } ,
        { mod={'option', 'shift'} , key='l' , func=rapidKey({'option', 'shift'} , 'right')  , repetition=true } ,
        { mod={} , key='d' , func=rapidKey({} , 'delete')  , repetition=true } ,
        { mod={} , key='u' , func=rapidKey({'cmd'} , 'z')  , repetition=true } ,
        { mod={} , key='r' , func=rapidKey({'cmd', 'shift'} , 'z')  , repetition=true } ,
    }, function(v)
        if v.repetition then
            mode:bind(v.mod, v.key, v.func, vim_nav_end, v.func)
        else
            mode:bind(v.mod, v.key, v.func, vim_nav_end)
        end
    end)

    -- icon 클릭했을 때
    vim_nav_icon:setClickCallback(setDisplay)


    self.on = function()
        timeFirstControl, firstDown, secondDown = 0, false, false
        mode:enter()
        displayOn()
        mode.triggered = false
        mode.on = true
    end

    self.off = function()
        timeFirstControl, firstDown, secondDown = 0, false, false
        displayOff()
        mode:exit()

        local input_source = hs.keycodes.currentSourceID()

        if not mode.triggered then
            if not (input_source == inputEnglish) then
                hs.eventtap.keyStroke({}, 'right')
                hs.keycodes.currentSourceID(inputEnglish)
            end
            hs.eventtap.keyStroke({}, 'escape')
        end

        mode.triggered = true
        mode.on = false
    end

    self.isOn = function()
        return mode.on
    end


    displayOff()
    mode.on = false

    return self
end

function rapidKey(modifiers, key)
    modifiers = modifiers or {}
    return function()
        hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
        hs.timer.usleep(cfg.key_interval)
        hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
    end
end


local events   = eventtap.event.types

local module   = {}

-- Save this in your Hammerspoon configuration directiorn (~/.hammerspoon/) 
-- You either override timeFrame and action here or after including this file from another, e.g.
--
-- ctrlDoublePress = require("ctrlDoublePress")
-- ctrlDoublePress.timeFrame = 2
-- ctrlDoublePress.action = function()
--    do something special
-- end

-- how quickly must the two single ctrl taps occur?
module.timeFrame = 0.5

-- what to do when the double tap of ctrl occurs
module.action = function()
--    alert("You double tapped ctrl!")
    obj.on()
end

local timeFirstControl, firstDown, secondDown = 0, false, false

-- verify that no keyboard flags are being pressed
local noFlags = function(ev)
    local result = true
    for k,v in pairs(ev:getFlags()) do
        if v then
            result = false
            break
        end
    end
    return result
end

-- verify that *only* the ctrl key flag is being pressed
local onlyCtrl = function(ev)
    local result = ev:getFlags().ctrl
    for k,v in pairs(ev:getFlags()) do
        if k ~= "ctrl" and v then
            result = false
            break
        end
    end
    return result
end

-- the actual workhorse

module.eventWatcher = eventtap.new({events.flagsChanged, events.keyDown}, function(ev)
    -- if it's been too long; previous state doesn't matter
    if (timer.secondsSinceEpoch() - timeFirstControl) > module.timeFrame then
        timeFirstControl, firstDown, secondDown = 0, false, false
    end

    if ev:getType() == events.flagsChanged then
        if noFlags(ev) and firstDown and secondDown then -- ctrl up and we've seen two, so do action
            if module.action then module.action() end
            timeFirstControl, firstDown, secondDown = 0, false, false
        elseif onlyCtrl(ev) and not firstDown then         -- ctrl down and it's a first
            if obj.isOn() == true then
                obj.off()
            else
                firstDown = true
                timeFirstControl = timer.secondsSinceEpoch()
            end
        elseif onlyCtrl(ev) and firstDown then             -- ctrl down and it's the second
            secondDown = true
        elseif not noFlags(ev) then                        -- otherwise reset and start over
            timeFirstControl, firstDown, secondDown = 0, false, false
        end
    else -- it was a key press, so not a lone ctrl char -- we don't care about it
        timeFirstControl, firstDown, secondDown = 0, false, false
    end
    return false
end):start()

return obj
