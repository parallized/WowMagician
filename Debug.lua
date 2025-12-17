local addonName = "WowMagician"

-- Debug模块 - 调试工具和事件监听
WowMagicianDebug = WowMagicianDebug or {}

-- 私有变量
local debugFrame = nil
local isDebugEnabled = false
local eventLog = {}
local maxLogEntries = 100
local monitoredEvents = {
    -- 大秘境相关事件
    "CHALLENGE_MODE_START",
    "CHALLENGE_MODE_COMPLETED",
    "PLAYER_LEAVING_WORLD"
}

--- 初始化Debug模块
function WowMagicianDebug.Initialize()
    WowMagicianDebug.debugFrame = WowMagicianDebug.CreateDebugFrame()
    WowMagicianDebug.RegisterEventListeners()
    print("|cff00ff00[WowMagician Debug]|r Debug模块已初始化")
end

--- 启用调试模式
function WowMagicianDebug.Enable()
    if isDebugEnabled then
        print("|cffffaa00[WowMagician Debug]|r 调试模式已启用")
        return
    end

    isDebugEnabled = true
    WowMagicianDebug.RegisterEventListeners()
    WowMagicianDebug.LogEvent("DEBUG_ENABLED", "调试模式已启用")
    print("|cff00ff00[WowMagician Debug]|r 调试模式已启用")
end

--- 禁用调试模式
function WowMagicianDebug.Disable()
    if not isDebugEnabled then
        print("|cffffaa00[WowMagician Debug]|r 调试模式已禁用")
        return
    end

    isDebugEnabled = false
    WowMagicianDebug.UnregisterEventListeners()
    WowMagicianDebug.LogEvent("DEBUG_DISABLED", "调试模式已禁用")
    print("|cff00ff00[WowMagician Debug]|r 调试模式已禁用")
end

--- 检查调试模式是否启用
-- @return boolean: 调试模式状态
function WowMagicianDebug.IsEnabled()
    return isDebugEnabled
end

--- 显示调试窗口
function WowMagicianDebug.Show()
    if not WowMagicianDebug.debugFrame then
        WowMagicianDebug.debugFrame = WowMagicianDebug.CreateDebugFrame()
    end

    WowMagicianDebug.UpdateDebugDisplay()
    WowMagicianDebug.debugFrame:Show()
end

--- 隐藏调试窗口
function WowMagicianDebug.Hide()
    if WowMagicianDebug.debugFrame then
        WowMagicianDebug.debugFrame:Hide()
    end
end

--- 切换调试模式
function WowMagicianDebug.Toggle()
    if isDebugEnabled then
        WowMagicianDebug.Disable()
    else
        WowMagicianDebug.Enable()
    end
end

--- 创建调试框架
-- @return Frame: 调试窗口框架
function WowMagicianDebug.CreateDebugFrame()
    local frame = CreateFrame("Frame", "WowMagicianDebugFrame", UIParent)
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    -- 背景
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.9)

    -- 边框
    frame.border = frame:CreateTexture(nil, "BORDER")
    frame.border:SetPoint("TOPLEFT", -2, 2)
    frame.border:SetPoint("BOTTOMRIGHT", 2, -2)
    frame.border:SetColorTexture(0.5, 0.5, 0.5, 1)

    -- 标题
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("WowMagician Debug Console")

    -- 状态文本
    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.statusText:SetPoint("TOPLEFT", 10, -30)
    frame.statusText:SetText("|cff808080状态: 禁用|r")

    -- 滚动框架
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", 10, -50)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    -- 滚动内容的容器框架
    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetSize(560, 1000) -- 设置足够大的高度来容纳文本
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    -- 日志文本框（放在滚动容器中）
    frame.logText = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.logText:SetPoint("TOPLEFT", 0, 0)
    frame.logText:SetPoint("TOPRIGHT", 0, 0)
    frame.logText:SetJustifyH("LEFT")
    frame.logText:SetJustifyV("TOP")
    frame.logText:SetWidth(560) -- 设置宽度以支持换行

    -- 控制按钮容器
    local buttonContainer = CreateFrame("Frame", nil, frame)
    buttonContainer:SetPoint("BOTTOMLEFT", 10, 10)
    buttonContainer:SetPoint("BOTTOMRIGHT", -10, 10)
    buttonContainer:SetHeight(30)

    -- 启用/禁用按钮
    frame.toggleButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    frame.toggleButton:SetSize(80, 25)
    frame.toggleButton:SetPoint("LEFT", 0, 0)
    frame.toggleButton:SetText("启用")
    frame.toggleButton:SetScript("OnClick", function()
        WowMagicianDebug.Toggle()
        WowMagicianDebug.UpdateDebugDisplay()
    end)

    -- 清空日志按钮
    frame.clearButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    frame.clearButton:SetSize(80, 25)
    frame.clearButton:SetPoint("LEFT", 90, 0)
    frame.clearButton:SetText("清空")
    frame.clearButton:SetScript("OnClick", function()
        WowMagicianDebug.ClearLog()
        WowMagicianDebug.UpdateDebugDisplay()
    end)

    -- 刷新按钮
    frame.refreshButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    frame.refreshButton:SetSize(80, 25)
    frame.refreshButton:SetPoint("LEFT", 180, 0)
    frame.refreshButton:SetText("刷新")
    frame.refreshButton:SetScript("OnClick", function()
        WowMagicianDebug.UpdateDebugDisplay()
    end)

    -- 关闭按钮
    frame.closeButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    frame.closeButton:SetSize(80, 25)
    frame.closeButton:SetPoint("RIGHT", 0, 0)
    frame.closeButton:SetText("关闭")
    frame.closeButton:SetScript("OnClick", function()
        WowMagicianDebug.Hide()
    end)

    return frame
end

--- 更新调试显示
function WowMagicianDebug.UpdateDebugDisplay()
    if not WowMagicianDebug.debugFrame then return end

    -- 更新状态文本
    local statusColor = isDebugEnabled and "|cff00ff00" or "|cffff0000"
    local statusText = isDebugEnabled and "启用" or "禁用"
    WowMagicianDebug.debugFrame.statusText:SetText("状态: " .. statusColor .. statusText .. "|r")

    -- 更新按钮文本
    WowMagicianDebug.debugFrame.toggleButton:SetText(isDebugEnabled and "禁用" or "启用")

    -- 更新日志显示
    local logText = WowMagicianDebug.FormatLogForDisplay()
    WowMagicianDebug.debugFrame.logText:SetText(logText)

    -- 调整滚动容器高度以适应内容
    local textHeight = WowMagicianDebug.debugFrame.logText:GetStringHeight()
    WowMagicianDebug.debugFrame.scrollChild:SetHeight(math.max(textHeight, 300))

    -- 滚动到底部
    WowMagicianDebug.debugFrame.scrollFrame:SetVerticalScroll(math.max(0, textHeight - 300))
end

--- 格式化日志用于显示
-- @return string: 格式化的日志文本
function WowMagicianDebug.FormatLogForDisplay()
    if #eventLog == 0 then
        return "|cff808080暂无日志记录|r"
    end

    local lines = {}
    for i = #eventLog, math.max(1, #eventLog - 50), -1 do -- 显示最近50条记录
        local entry = eventLog[i]
        local timestamp = date("%H:%M:%S", entry.timestamp)
        local color = WowMagicianDebug.GetEventColor(entry.event)
        local line = string.format("|cff808080[%s]|r %s%s|r: %s",
            timestamp, color, entry.event, entry.details or "")
        table.insert(lines, line)
    end

    return table.concat(lines, "\n")
end

--- 获取事件颜色
-- @param event string: 事件名称
-- @return string: 颜色代码
function WowMagicianDebug.GetEventColor(event)
    local colorMap = {
        -- 大秘境事件
        ["CHALLENGE_MODE_START"] = "|cffaa00ff",
        ["CHALLENGE_MODE_COMPLETED"] = "|cff00ffaa",
        ["PLAYER_LEAVING_WORLD"] = "|cffff6600",

        -- Debug事件
        ["DEBUG_ENABLED"] = "|cff00ff00",
        ["DEBUG_DISABLED"] = "|cffff0000"
    }

    return colorMap[event] or "|cffffffff"
end

--- 注册事件监听器
function WowMagicianDebug.RegisterEventListeners()
    if not WowMagicianDebug.eventFrame then
        WowMagicianDebug.eventFrame = CreateFrame("Frame")
        WowMagicianDebug.eventFrame:SetScript("OnEvent", WowMagicianDebug.OnEvent)
    end

    if isDebugEnabled then
        for _, event in ipairs(monitoredEvents) do
            WowMagicianDebug.eventFrame:RegisterEvent(event)
        end
    end
end

--- 注销事件监听器
function WowMagicianDebug.UnregisterEventListeners()
    if WowMagicianDebug.eventFrame then
        for _, event in ipairs(monitoredEvents) do
            WowMagicianDebug.eventFrame:UnregisterEvent(event)
        end
    end
end

--- 事件处理器
-- @param frame Frame: 触发事件的框架
-- @param event string: 事件名称
-- @param ... 事件参数
function WowMagicianDebug.OnEvent(frame, event, ...)
    if not isDebugEnabled then return end

    local details = WowMagicianDebug.FormatEventDetails(event, ...)
    WowMagicianDebug.LogEvent(event, details)

    -- 同时输出到游戏控制台
    print(string.format("|cff00ff00[WowMagician Debug]|r |cff808080[%s]|r %s",
        date("%H:%M:%S"), event))
end

--- 格式化事件详情
-- @param event string: 事件名称
-- @param ... 事件参数
-- @return string: 格式化的详情字符串
function WowMagicianDebug.FormatEventDetails(event, ...)
    local args = { ... }
    local details = ""

    if event == "CHALLENGE_MODE_START" then
        local mapID = args[1]
        local level = args[2]
        local timeLimit = args[3]
        local mapName = C_ChallengeMode.GetMapUIInfo(mapID) or "未知地图"
        details = string.format("大秘境开始: %s (等级%d, 时间限制%d秒)", mapName, level, timeLimit)
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        -- 使用C_ChallengeMode.GetCompletionInfo()获取详细完成信息
        local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members = C_ChallengeMode.GetCompletionInfo()

        local mapName = select(1, C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)) or "未知地图"
        local timeStr = string.format("%.2f", time / 1000)
        local result = onTime and "按时完成" or "超时完成"
        local recordInfo = ""
        if IsMapRecord then
            recordInfo = recordInfo .. "地图记录 "
        end
        if IsAffixRecord then
            recordInfo = recordInfo .. "词缀记录 "
        end
        if recordInfo ~= "" then
            recordInfo = " (" .. recordInfo .. ")"
        end

        details = string.format("大秘境完成: %s (等级%d, 用时%s秒, %s, 钥石升级%d级%s, 分数:%d->%d)",
            mapName, level, timeStr, result, keystoneUpgradeLevels, recordInfo, oldOverallDungeonScore, newOverallDungeonScore)
    elseif event == "PLAYER_LEAVING_WORLD" then
        local zoneName = GetZoneText()
        local subZoneName = GetSubZoneText()
        local instanceName = GetInstanceInfo()
        details = string.format("离开副本: %s (%s - %s)", instanceName, zoneName, subZoneName)
    end

    return details
end

--- 记录事件到日志
-- @param event string: 事件名称
-- @param details string: 事件详情
function WowMagicianDebug.LogEvent(event, details)
    table.insert(eventLog, {
        timestamp = time(),
        event = event,
        details = details or ""
    })

    -- 限制日志条目数量
    if #eventLog > maxLogEntries then
        table.remove(eventLog, 1)
    end

    -- 如果调试窗口打开，更新显示
    if WowMagicianDebug.debugFrame and WowMagicianDebug.debugFrame:IsShown() then
        WowMagicianDebug.UpdateDebugDisplay()
    end
end

--- 清空日志
function WowMagicianDebug.ClearLog()
    eventLog = {}
    print("|cff00ff00[WowMagician Debug]|r 日志已清空")
end

--- 获取当前日志
-- @return table: 日志条目数组
function WowMagicianDebug.GetLog()
    return eventLog
end

--- 导出日志到字符串
-- @return string: 日志字符串
function WowMagicianDebug.ExportLog()
    local lines = { "WowMagician Debug Log - " .. date() }
    table.insert(lines, "========================")

    for _, entry in ipairs(eventLog) do
        local timestamp = date("%Y-%m-%d %H:%M:%S", entry.timestamp)
        table.insert(lines, string.format("[%s] %s: %s", timestamp, entry.event, entry.details or ""))
    end

    return table.concat(lines, "\n")
end
