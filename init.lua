--local win_move = require('modules.winmove')
local app_man = require('modules.appman')

local vim_mode = hs.hotkey.modal.new()
local app_mode = hs.hotkey.modal.new()
local dummy_mode = hs.hotkey.modal.new()

local vimlike = require('modules.vim'):init(vim_mode)

local FRemap = require('modules/foundation_remapping')
local remapper = FRemap.new()
local key_rcmd = 'f13'
local key_ralt = 'f14'
local key_rctrl = 'f15'
remapper:remap('rcmd', key_rcmd)
remapper:remap('ralt', key_ralt)
remapper:remap('rctrl', key_rctrl)
remapper:remap('capslock', 'lcmd')
remapper:register()

hs.hotkey.bind({}, key_rcmd, function() app_mode:enter() end, function() app_mode:exit() end) 
-- 일단 ralt(key_ralt)와 rctrl(key_rctrl)의 단순 매핑 적용을 위해 dummy_mode 이용
-- (아래 코드를 적용하지 않으면 modifier가 아닌 실제 키에 매핑되어 있는 명령을 수행하게 된다)
hs.hotkey.bind({}, key_ralt, function() dummy_mode:enter() end, function() dummy_mode:exit() end)
hs.hotkey.bind({}, key_rctrl, function() dummy_mode:enter() end, function() dummy_mode:exit() end)


--[[
local inputEnglish = "com.apple.keylayout.ABC"
local esc_bind

function back_to_eng()
    local inputSource = hs.keycodes.currentSourceID()
    if not (inputSource == inputEnglish) then
        hs.eventtap.keyStroke({}, 'right')
        hs.keycodes.currentSourceID(inputEnglish)
    end
    esc_bind:disable()
    hs.eventtap.keyStroke({}, 'escape')
    esc_bind:enable()
end

esc_bind = hs.hotkey.new({}, 'escape', back_to_eng):enable()
]]


--[[
local maccy = function()
    -- maccy 는 단축키 조합에 f1 ~ f20 이 들어가면 인식을 못한다.
    hs.eventtap.keyStroke({'command', 'shift', 'option', 'control'}, 'c')
end

hs.hotkey.bind({'shift'}, 'f14', maccy) -- for maccy
]]

function setVimlikeKey(keyCode)
    local vimlikeKey = keyCode
    hs.hotkey.bind({}, vimlikeKey, vimlike.on, vimlike.off)
    --hs.hotkey.bind({'cmd'}, vimlikeKey, vimlike.on, vimlike.off)
    --hs.hotkey.bind({'shift'}, vimlikeKey, vimlike.on, vimlike.off)

    --vim_mode:bind({}, 'q', hs.caffeinate.systemSleep, vimlike.close)
    vim_mode:bind({'shift'}, 'r', hs.reload, vimlike.close)
    vim_mode:bind({}, 'a', function()
        local activeAppName = hs.application.frontmostApplication():name()
        hs.alert.show(activeAppName)
    end, vimlike.close)

    --vim_mode:bind({}, 'c', maccy, vimlike.close)
end

do  -- vimlike
    setVimlikeKey(key_ralt)
--    setVimlikeKey({'shift', 'cmd'})
end

do  -- tab move
    local tabTable = {}

    -- application 별 default로 설정되어 있는 tab 이동 단축키를 tabTable에 저장
    tabTable['Slack'] = {
        left = { mod = {'option'}, key = 'up' },
        right = { mod = {'option'}, key = 'down' }
    }
    tabTable['Safari'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['Google Chrome'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['터미널'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['Terminal'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }
    tabTable['iTerm2'] = {
        left = { mod = {'shift', 'command'}, key = '[' },
        right = { mod = {'shift', 'command'}, key = ']' }
    }
    tabTable['IntelliJ IDEA'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['Code'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['DataGrip'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['PyCharm'] = {
        left = { mod = {'command', 'shift'}, key = '[' },
        right = { mod = {'command', 'shift'}, key = ']' }
    }
    tabTable['_else_'] = {
        left = { mod = {'control'}, key = 'pageup' },
        right = { mod = {'control'}, key = 'pagedown' }
    }
    tabTable['Notion'] = {
        left = { mod = {'control', 'shift'}, key = 'tab' },
        right = { mod = {'control'}, key = 'tab' }
    }

    local function tabMove(dir)
        return function()
            local activeAppName = hs.application.frontmostApplication():name()
            local tab = tabTable[activeAppName] or tabTable['_else_']

            hs.eventtap.event.newKeyEvent(tab[dir]['mod'], tab[dir]['key'], true):post()
            hs.eventtap.event.newKeyEvent(tab[dir]['mod'], tab[dir]['key'], false):post()
        end
    end


    -- setVimlikeKey()로 설정된 key + ',' -> tab left 이동
    -- setVimlikeKey()로 설정된 key + '.' -> tab right 이동
    vim_mode:bind({}, ',', tabMove('left'), vimlike.close, tabMove('left'))
    vim_mode:bind({}, '.', tabMove('right'), vimlike.close, tabMove('right'))
end


do  -- app manager
    local mode = app_mode

    --mode:bind({}, 'a', app_man:toggle('safari'))
    --mode:bind({'shift'}, 'd', app_man:toggle('dictionary'))
    --mode:bind({}, 'l', app_man:toggle('Line'))
    --mode:bind({}, 'm', app_man:toggle('NoSQLBooster for MongoDB'))
    --mode:bind({}, 'o', app_man:toggle('Microsoft OneNote'))
    --mode:bind({}, 'p', app_man:toggle('Preview'))
    --mode:bind({}, 'q', app_man:toggle('Sequel Pro'))
    -- mode:bind({}, 'r', app_man:toggle('Trello'))
    -- mode:bind({}, 'w', app_man:toggle('Microsoft Word'))
    --mode:bind({}, 'x', app_man:toggle('Microsoft Excel'))
    --mode:bind({}, 'z', app_man:toggle('zoom.us'))
    --mode:bind({}, 't', app_man:toggle('Telegram'))
    --mode:bind({}, 'v', app_man:toggle('VimR'))

    mode:bind({}, ',', app_man:toggle('System Preferences'))
    mode:bind({}, '/', app_man:toggle('Activity Monitor'))
    mode:bind({}, 'c', app_man:toggle('Google Chrome'))
    mode:bind({}, 'e', app_man:toggle('Finder'))
    mode:bind({}, 'd', app_man:toggle('DataGrip'))
    mode:bind({}, 'i', app_man:toggle('IntelliJ IDEA'))
    mode:bind({}, 'k', app_man:toggle('KakaoTalk'))
    mode:bind({}, 'n', app_man:toggle('Notion'))
    mode:bind({'shift'}, 'n', app_man:toggle('Notes'))
    mode:bind({}, 'm', app_man:toggle('Postman'))
    --mode:bind({}, 'r', app_man:toggle('draw.io'))
    mode:bind({}, 's', app_man:toggle('Slack'))
    --mode:bind({}, 'space', app_man:toggle('Terminal'))
    mode:bind({}, 'space', app_man:toggle('iTerm'))
    mode:bind({'shift'}, 'v', app_man:toggle('Visual Studio Code'))

    mode:bind({}, '1', app_man:toggle('IntelliJ IDEA'))
    mode:bind({}, '2', app_man:toggle('iTerm'))
    mode:bind({}, '3', app_man:toggle('DataGrip'))
    mode:bind({}, '4', app_man:toggle('Notion'))

    mode:bind({}, 'tab', hs.hints.windowHints)
    hs.hints.hintChars = {
        'q', 'w', 'e', 'r',
        'a', 's', 'd', 'f',
        'z', 'x', 'c', 'v',
        '1', '2', '3', '4',
        'j', 'k',
        'i', 'o',
        'm', ','
    }

    mvim = true
    mode:bind({'control'}, 'v', function()

    end)
end

-- spoon plugins
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = false

function plugInstall()
    local Install=spoon.SpoonInstall
    Install:updateRepo('default')

    Install:installSpoonFromRepo('Caffeine')

    hs.alert.show('plugin installed')
end


require('modules.inputsource_aurora')


require('modules.focus-screen')


local vim_nav_mode = hs.hotkey.modal.new()
require('modules.vim-nav'):init(vim_nav_mode)


hs.alert.show('loaded')
