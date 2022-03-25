-- https://github.com/johngrib/hammerspoon-config/blob/master/modules/inputsource_aurora.lua

local boxes = {}
local inputEnglish = "com.apple.keylayout.ABC"
local box_height = 23
local box_alpha = 0.35
local GREEN = hs.drawing.color.osx_green

-- 입력소스 변경 이벤트에 이벤트 리스너를 달아준다
hs.keycodes.inputSourceChanged(function()
    disable_show()
    if hs.keycodes.currentSourceID() ~= inputEnglish then
        enable_show()
    end
end)

--상단 color
upper_color = {
    hex="5A0000",
    alpha = 1
}
--upper_color=GREEN

--하단color
under_color = {
    hex="5A0000",
    alpha = 1
}

function enable_show()
    reset_boxes()
    hs.fnutils.each(hs.screen.allScreens(), function(scr)
        local frame = scr:fullFrame()

        local box = newBox()
        draw_rectangle(box, frame.x, frame.y, frame.w, box_height, upper_color)
        table.insert(boxes, box)

        -- 이 부분의 주석을 풀면 화면 아래쪽에도 보여준다
        local box2 = newBox()
        draw_rectangle(box2, frame.x, frame.y+frame.h - 10, frame.w, box_height, under_color)
        table.insert(boxes, box2)
    end)
end

function disable_show()
    hs.fnutils.each(boxes, function(box)
        if box ~= nil then
            box:delete()
        end
    end)
    reset_boxes()
end

function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
end

function reset_boxes()
    boxes = {}
end

function draw_rectangle(target_draw, x, y, width, height, fill_color)
  -- 그릴 영역 크기를 잡는다
  target_draw:setSize(hs.geometry.rect(x, y, width, height))
  -- 그릴 영역의 위치를 잡는다
  target_draw:setTopLeft(hs.geometry.point(x, y))

  target_draw:setFillColor(fill_color)
  target_draw:setFill(true)
  target_draw:setAlpha(box_alpha)
  target_draw:setLevel(hs.drawing.windowLevels.overlay)
  target_draw:setStroke(false)
  target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
  target_draw:show()
end

