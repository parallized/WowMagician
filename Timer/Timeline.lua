local addonName = "WowMagician"

WowMagicianTimeline = WowMagicianTimeline or {}

-- 私有变量
local isTimelineEnabled = false
local currentNearbyEvents = { previous = {}, current = nil, upcoming = {} }

--- 初始化Timeline模块
function WowMagicianTimeline.Initialize()
    WowMagicianTimelineData.Initialize()
    print("|cff00ff00[WowMagician Timeline]|r Timeline模块已初始化")
end

--- 启用时间轴功能
function WowMagicianTimeline.Enable()
    isTimelineEnabled = true
    print("|cff00ff00[WowMagician Timeline]|r 时间轴功能已启用")
end

--- 禁用时间轴功能
function WowMagicianTimeline.Disable()
    isTimelineEnabled = false
    currentNearbyEvents = { previous = {}, current = nil, upcoming = {} }
    WowMagicianTimelineUI.Hide()
    print("|cff00ff00[WowMagician Timeline]|r 时间轴功能已禁用")
end

--- 检查时间轴是否启用
-- @return boolean: 启用状态
function WowMagicianTimeline.IsEnabled()
    return isTimelineEnabled
end

--- 更新当前时间附近的事件
-- @param currentTime number: 当前时间(秒)
function WowMagicianTimeline.UpdateNearbyEvents(currentTime)
    if not isTimelineEnabled then return end

    currentNearbyEvents = WowMagicianTimelineData.GetNearbyEvents(currentTime)

    -- 更新UI显示
    WowMagicianTimelineUI.UpdateDisplay(currentNearbyEvents)
end

--- 获取当前附近的事件数据
-- @return table: 附近事件数据
function WowMagicianTimeline.GetNearbyEvents()
    return currentNearbyEvents
end

--- 设置指定副本的时间轴数据
-- @param dungeonKey string: 副本键值
-- @param timelineText string: 时间轴文本数据
function WowMagicianTimeline.SetDungeonTimeline(dungeonKey, timelineText)
    WowMagicianTimelineData.SetTimelineData(dungeonKey, timelineText)
end

--- 根据当前地图ID自动设置时间轴数据
-- @param mapID number: 地图ID
function WowMagicianTimeline.AutoSetTimelineForMap(mapID)
    if not mapID then return end

    -- 这里可以根据地图ID自动加载对应的时间轴数据
    -- 暂时先用一个示例数据
    local mapName = select(1, C_ChallengeMode.GetMapUIInfo(mapID)) or "未知地图"

    -- 示例时间轴数据 (可以根据实际需要替换)
    local sampleTimeline = [[
0:36 彼岸椛已落 {spell:196718} - 雷霆一击, 心灵之火, 射击
0:39 强效面包精华 {spell:97462} - 射击, 瓦解怒吼, 雷霆一击
0:52 胖胖的我 {spell:98008} - 雷霆一击, 心灵之火, 射击
0:55 {所有人} 大个减 - 心灵之火, 雷霆一击, 痛苦撕裂
1:04 {所有人} 小个减 - 射击, 神圣惩击, 瓦解怒吼
2:29 {所有人} 小个减 - 献祭葬火, 心灵之火, 辉耀烈焰
3:31 {所有人} 小个减 - 神圣鸣罪, 辉耀烈焰, 献祭葬火
3:39 强效面包精华 {spell:97462} - 神圣鸣罪, 心灵之火, 辉耀烈焰
4:08 胖胖的我 {spell:98008} - 射击, 神圣鸣罪, 瓦解怒吼
4:31 {所有人} 小个减 - 谴罚者之盾, 神圣鸣罪, 射击
5:34 {所有人} 小个减 - 圣光逐斥
5:51 彼岸椛已落 {spell:196718} - 纯净
6:11 {所有人} 大个减 - 圣光逐斥
6:57 强效面包精华 {spell:97462} - 瓦解怒吼
7:37 {所有人} 小个减 - 瓦解怒吼, 圣光逐斥
7:38 胖胖的我 {spell:98008} - 瓦解怒吼
9:11 {所有人} 大个减 - 射击
9:22 {所有人} 小个减 - 射击
10:44 胖胖的我 {spell:98008} - 神圣鸣罪
10:53 {所有人} 小个减 - 圣光狂怒圣印, 神圣鸣罪
11:55 {所有人} 小个减
12:52 强效面包精华 {spell:97462} - 神圣鸣罪
13:17 {所有人} 大个减 - 神圣鸣罪
13:38 {所有人} 小个减
14:47 胖胖的我 {spell:98008}
15:09 {所有人} 小个减
15:40 彼岸椛已落 {spell:196718}
16:49 {所有人} 小个减
17:33 强效面包精华 {spell:97462}
18:08 {所有人} 大个减
18:29 {所有人} 小个减
18:37 胖胖的我 {spell:98008}
20:14 {所有人} 小个减
21:36 {所有人} 大个减
21:39 胖胖的我 {spell:98008}
22:02 彼岸椛已落 {spell:196718}
22:09 {所有人} 小个减
22:25 强效面包精华 {spell:97462}
23:27 {所有人} 小个减
24:27 {所有人} 小个减
25:13 胖胖的我 {spell:98008}
25:48 {所有人} 小个减
25:58 {所有人} 大个减
26:07 强效面包精华 {spell:97462}
27:44 {所有人} 小个减
28:16 彼岸椛已落 {spell:196718}
28:48 {所有人} 小个减
28:52 胖胖的我 {spell:98008}
29:16 强效面包精华 {spell:97462}
29:39 {所有人} 大个减
29:56 {所有人} 小个减
]]

    WowMagicianTimelineData.SetTimelineData(mapName, sampleTimeline)
end

--- 切换时间轴显示
function WowMagicianTimeline.Toggle()
    if isTimelineEnabled then
        WowMagicianTimeline.Disable()
    else
        WowMagicianTimeline.Enable()
        -- 显示时间轴UI
        WowMagicianTimelineUI.Show()
        -- 如果计时器正在运行，立即更新显示
        if WowMagicianTimer and WowMagicianTimer.IsRunning() then
            local _, officialElapsedTime = GetWorldElapsedTime(1)
            if officialElapsedTime then
                WowMagicianTimeline.UpdateNearbyEvents(officialElapsedTime)
            end
        end
    end
end

--- 获取时间轴事件的状态颜色
-- @param event table: 时间轴事件
-- @param currentTime number: 当前时间
-- @return table: 颜色表 {r, g, b}
function WowMagicianTimeline.GetEventColor(event, currentTime)
    if not event or not currentTime then
        return { 0.7, 0.7, 0.7 } -- 默认灰色
    end

    local timeDiff = event.time - currentTime

    if timeDiff < 0 then
        -- 已过去的事件
        return { 0.5, 0.5, 0.5 } -- 灰色
    elseif timeDiff <= 10 then
        -- 10秒内的事件
        return { 1, 0.2, 0.2 } -- 红色
    elseif timeDiff <= 30 then
        -- 30秒内的事件
        return { 1, 0.7, 0.2 } -- 橙色
    elseif timeDiff <= 60 then
        -- 1分钟内的事件
        return { 1, 1, 0.2 } -- 黄色
    else
        -- 更远的事件
        return { 0.7, 0.7, 0.7 } -- 灰色
    end
end

--- 格式化时间轴事件为显示文本
-- @param event table: 时间轴事件
-- @param currentTime number: 当前时间
-- @return string: 格式化的显示文本
function WowMagicianTimeline.FormatEventText(event, currentTime)
    if not event then return "" end

    local timeText = WowMagicianTimer.FormatTime(event.time)
    local timeDiff = event.time - currentTime

    local statusText = ""
    if timeDiff < 0 then
        statusText = "✓" -- 已完成
    elseif timeDiff <= 10 then
        statusText = "⚠" -- 紧急
    elseif timeDiff <= 30 then
        statusText = "!" -- 注意
    else
        statusText = "○" -- 等待
    end

    local nameText = event.name or ""
    if event.spellId then
        nameText = nameText .. " (" .. event.spellId .. ")"
    end

    local skillsText = ""
    if event.skills and #event.skills > 0 then
        skillsText = " - " .. table.concat(event.skills, ", ")
    end

    return string.format("%s %s %s%s", statusText, timeText, nameText, skillsText)
end
