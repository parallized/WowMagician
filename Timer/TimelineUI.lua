local addonName = "WowMagician"

WowMagicianTimelineUI = WowMagicianTimelineUI or {}

local timelineUIFrame = nil
local eventFrames = {}

--- 创建时间轴UI
local function CreateTimelineUI()
    local frame = CreateFrame("Frame", "WowMagicianTimelineUI", UIParent, "BackdropTemplate")
    frame:SetSize(370, 170)
    -- 暂时设置为屏幕中心，稍后会在Show函数中调整位置
    frame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)

    -- 标题栏
    local titleBg = frame:CreateTexture(nil, "BACKGROUND")
    titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    titleBg:SetHeight(20)
    titleBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    frame.titleBg = titleBg

    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleText:SetPoint("CENTER", titleBg)
    titleText:SetText("大秘境时间轴")
    titleText:SetTextColor(1, 0.82, 0) -- 金色
    frame.titleText = titleText

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeButton:SetScript("OnClick", function()
        WowMagicianTimelineUI.Hide()
    end)
    frame.closeButton = closeButton

    -- 内容区域
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, -10)
    frame.content = content

    -- 创建6个事件显示框
    for i = 1, 6 do
        local eventFrame = CreateFrame("Frame", nil, content)
        eventFrame:SetSize(350, 20)

        if i == 1 then
            eventFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        else
            eventFrame:SetPoint("TOPLEFT", eventFrames[i - 1], "BOTTOMLEFT", 0, -2)
        end

        -- 时间文本
        local timeText = eventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        timeText:SetPoint("LEFT", eventFrame, "LEFT", 5, 0) -- 增加5像素左边距
        timeText:SetSize(60, 20)
        timeText:SetJustifyH("LEFT")
        eventFrame.timeText = timeText

        -- 状态图标
        local statusIcon = eventFrame:CreateTexture(nil, "OVERLAY")
        statusIcon:SetSize(16, 16)
        statusIcon:SetPoint("LEFT", eventFrame, "LEFT", 0, 0)
        eventFrame.statusIcon = statusIcon

        -- 事件文本（现在显示完整的事件信息）
        local eventText = eventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        eventText:SetPoint("LEFT", statusIcon, "RIGHT", 2, 0)
        eventText:SetPoint("RIGHT", eventFrame, "RIGHT", 0, 0)
        eventText:SetJustifyH("LEFT")
        eventText:SetWordWrap(false)
        eventFrame.eventText = eventText

        -- 背景高亮
        local highlight = eventFrame:CreateTexture(nil, "BACKGROUND")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        highlight:Hide()
        eventFrame.highlight = highlight

        eventFrames[i] = eventFrame
    end

    -- 当前时间指示器
    local currentTimeIndicator = content:CreateTexture(nil, "OVERLAY")
    currentTimeIndicator:SetSize(350, 2)
    currentTimeIndicator:SetColorTexture(1, 1, 0, 0.8) -- 黄色线条
    currentTimeIndicator:Hide()
    frame.currentTimeIndicator = currentTimeIndicator

    return frame
end

--- 初始化TimelineUI模块
function WowMagicianTimelineUI.Initialize()
    if not timelineUIFrame then
        timelineUIFrame = CreateTimelineUI()
    end
    print("|cff00ff00[WowMagician TimelineUI]|r TimelineUI模块已初始化")
end

--- 显示时间轴UI
function WowMagicianTimelineUI.Show()
    if not timelineUIFrame then
        WowMagicianTimelineUI.Initialize()
    end

    if not WowMagicianTimeline.IsEnabled() then
        WowMagicianTimeline.Enable()
    end

    -- 重新定位到TimerUI旁边
    local timerUIFrame = WowMagicianTimerUI.GetFrame()
    if timerUIFrame and timerUIFrame:IsVisible() then
        timelineUIFrame:ClearAllPoints()
        timelineUIFrame:SetPoint("TOPLEFT", timerUIFrame, "TOPRIGHT", 10, 0)
    end

    timelineUIFrame:Show()

    -- 淡入动画
    if timelineUIFrame.fadeInAnim then
        timelineUIFrame.fadeInAnim:Play()
    else
        local fadeInAnim = timelineUIFrame:CreateAnimationGroup()
        local alphaIn = fadeInAnim:CreateAnimation("Alpha")
        alphaIn:SetFromAlpha(0)
        alphaIn:SetToAlpha(1)
        alphaIn:SetDuration(0.3)
        timelineUIFrame.fadeInAnim = fadeInAnim
        fadeInAnim:Play()
    end
end

--- 隐藏时间轴UI
function WowMagicianTimelineUI.Hide()
    if timelineUIFrame then
        -- 淡出动画
        if timelineUIFrame.fadeOutAnim then
            timelineUIFrame.fadeOutAnim:Play()
        else
            local fadeOutAnim = timelineUIFrame:CreateAnimationGroup()
            local alphaOut = fadeOutAnim:CreateAnimation("Alpha")
            alphaOut:SetFromAlpha(1)
            alphaOut:SetToAlpha(0)
            alphaOut:SetDuration(0.2)
            fadeOutAnim:SetScript("OnFinished", function() timelineUIFrame:Hide() end)
            timelineUIFrame.fadeOutAnim = fadeOutAnim
            fadeOutAnim:Play()
        end
    end
end

--- 检查UI是否可见
-- @return boolean: 可见状态
function WowMagicianTimelineUI.IsVisible()
    return timelineUIFrame and timelineUIFrame:IsShown()
end

--- 重置UI状态
function WowMagicianTimelineUI.Reset()
    if timelineUIFrame then
        timelineUIFrame.currentTimeIndicator:Hide()
        for _, eventFrame in ipairs(eventFrames) do
            eventFrame.timeText:SetText("")
            eventFrame.eventText:SetText("")
            eventFrame.statusIcon:SetTexture(nil)
            eventFrame.highlight:Hide()
        end
    end
end

--- 更新时间轴显示
-- @param nearbyEvents table: 附近事件数据 {previous={}, current=nil, upcoming={}}
function WowMagicianTimelineUI.UpdateDisplay(nearbyEvents)
    if not timelineUIFrame or not nearbyEvents then return end

    -- 重置所有显示
    WowMagicianTimelineUI.Reset()

    -- 获取当前时间用于计算颜色
    local _, currentTime = GetWorldElapsedTime(1)
    currentTime = currentTime or 0

    -- 组合所有事件：previous(2) + current(1) + upcoming(3) = 最多6个，我们显示全部6个
    local allEvents = {}

    -- 添加之前的2项
    for _, event in ipairs(nearbyEvents.previous or {}) do
        table.insert(allEvents, event)
    end

    -- 添加当前项
    if nearbyEvents.current then
        table.insert(allEvents, nearbyEvents.current)
    end

    -- 添加之后的3项
    for _, event in ipairs(nearbyEvents.upcoming or {}) do
        table.insert(allEvents, event)
    end

    -- 显示全部6项
    for i = 1, math.min(6, #allEvents) do
        local event = allEvents[i]
        local eventFrame = eventFrames[i]

        if event and eventFrame then
            -- 清除时间文本（现在时间显示在eventText中）
            eventFrame.timeText:SetText("")

            -- 按照Timeline.lua中的精确格式显示
            local displayText = ""

            -- 显示时间
            displayText = displayText .. WowMagicianTimer.FormatTime(event.time) .. " "

            -- 显示名字
            displayText = displayText .. (event.name or "")

            -- 显示技能列表（伤害来源）
            if event.skills and #event.skills > 0 then
                -- 对于"{所有人}"类型的事件，技能是使用的对策，不需要"-"
                if event.name and event.name:match("^{所有人}") then
                    displayText = displayText .. " " .. table.concat(event.skills, ", ")
                else
                    -- 其他事件的技能是伤害来源，需要"-"
                    displayText = displayText .. " - " .. table.concat(event.skills, ", ")
                end
            end

            -- 去除末尾空格
            displayText = displayText:gsub("%s+$", "")

            eventFrame.eventText:SetText(displayText)

            -- 设置状态图标和颜色
            local colors = WowMagicianTimeline.GetEventColor(event, currentTime)

            -- 优先显示法术图标
            local iconSet = false

            -- 首先尝试使用spellId获取图标
            if event.spellId and not iconSet then
                local iconID, originalIconID
                if C_Spell and C_Spell.GetSpellTexture then
                    iconID, originalIconID = C_Spell.GetSpellTexture(event.spellId)
                elseif GetSpellTexture then
                    iconID = GetSpellTexture(event.spellId)
                end

                if iconID then
                    eventFrame.statusIcon:SetTexture(iconID)
                    iconSet = true
                end
            end

            -- 如果没有spellId或获取失败，尝试使用技能名获取图标
            if not iconSet and event.skills and #event.skills > 0 then
                for _, skillName in ipairs(event.skills) do
                    if skillName and skillName ~= "" then
                        local iconID
                        if GetSpellTexture then
                            iconID = GetSpellTexture(skillName)
                        elseif C_Spell and C_Spell.GetSpellTexture then
                            iconID = C_Spell.GetSpellTexture(skillName)
                        end

                        if iconID then
                            eventFrame.statusIcon:SetTexture(iconID)
                            iconSet = true
                            break -- 找到第一个有效的图标就停止
                        end
                    end
                end
            end

            -- 如果都没有找到法术图标，使用状态图标
            if not iconSet then
                if event.time < currentTime then
                    -- 已过去的事件
                    eventFrame.statusIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
                elseif event.time <= currentTime + 10 then
                    -- 10秒内 - 高亮
                    eventFrame.statusIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
                elseif event.time <= currentTime + 30 then
                    -- 30秒内 - 警告
                    eventFrame.statusIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertOther")
                else
                    -- 更远的事件 - 普通
                    eventFrame.statusIcon:SetTexture("Interface\\COMMON\\Indicator-Gray")
                end
            end

            -- 设置文本颜色
            if event.time < currentTime then
                -- 已过去的事件
                eventFrame.timeText:SetTextColor(0.5, 0.5, 0.5)
                eventFrame.eventText:SetTextColor(0.5, 0.5, 0.5)
            elseif event.time <= currentTime + 10 then
                -- 10秒内 - 高亮
                eventFrame.timeText:SetTextColor(1, 0.2, 0.2)
                eventFrame.eventText:SetTextColor(1, 0.2, 0.2)
                eventFrame.highlight:Show()
            elseif event.time <= currentTime + 30 then
                -- 30秒内 - 警告
                eventFrame.timeText:SetTextColor(1, 0.7, 0.2)
                eventFrame.eventText:SetTextColor(1, 0.7, 0.2)
            else
                -- 更远的事件 - 普通
                eventFrame.timeText:SetTextColor(0.7, 0.7, 0.7)
                eventFrame.eventText:SetTextColor(0.7, 0.7, 0.7)
            end

            -- 如果是当前事件，显示特殊标记
            if nearbyEvents.current and event.time == nearbyEvents.current.time then
                eventFrame.highlight:SetColorTexture(0.2, 0.8, 0.2, 0.3) -- 绿色高亮
                eventFrame.highlight:Show()

                -- 移除当前时间指示器显示
                -- local indicatorY = eventFrame:GetTop() - timelineUIFrame:GetTop() - 10
                -- timelineUIFrame.currentTimeIndicator:SetPoint("TOP", timelineUIFrame, "TOP", 0, -indicatorY)
                -- timelineUIFrame.currentTimeIndicator:Show()
            end
        end
    end
end
