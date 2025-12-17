local addonName = "WowMagician"

-- TimerUI模块 - 大秘境计时器UI
WowMagicianTimerUI = WowMagicianTimerUI or {}

-- 私有变量
local timerUIFrame = nil

--- 创建计时器UI
-- @return Frame: 计时器UI框架
function WowMagicianTimerUI.CreateUI()
    -- 使用BackdropTemplate创建主框架，并手动添加标题
    local frame = CreateFrame("Frame", "WowMagicianTimerUI", UIParent, "BackdropTemplate")
    frame:SetSize(280, 120)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    -- 设置背景
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)

    -- 创建标题栏背景
    local titleBg = frame:CreateTexture(nil, "BACKGROUND")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetPoint("TOP", 0, 12)
    titleBg:SetSize(160, 32)
    frame.titleBg = titleBg

    -- 创建标题文本
    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOP", 0, -2)
    titleText:SetText("大秘境计时器")
    titleText:SetTextColor(1, 0.82, 0) -- 金色
    frame.titleText = titleText

    -- 创建关闭按钮
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetSize(24, 24)
    closeButton:SetScript("OnClick", function()
        WowMagicianTimerUI.Hide()
    end)
    frame.closeButton = closeButton

    -- 创建内容容器
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 15, -25)
    content:SetPoint("BOTTOMRIGHT", -15, 15)
    frame.content = content

    -- 大秘境图标
    local icon = content:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("TOPLEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\achievement_bg_masterofallbgs")
    frame.icon = icon

    -- 时间显示区域
    local timeContainer = CreateFrame("Frame", nil, content)
    timeContainer:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    timeContainer:SetPoint("RIGHT", -10, 0)
    timeContainer:SetHeight(40)
    frame.timeContainer = timeContainer

    -- 主时间显示
    local timeText = timeContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    timeText:SetPoint("TOP", 0, 0)
    timeText:SetText("00:00")
    timeText:SetShadowColor(0, 0, 0, 0.8)
    timeText:SetShadowOffset(1, -1)
    frame.timeText = timeText

    -- 副时间显示（显示额外信息）
    local subTimeText = timeContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subTimeText:SetPoint("BOTTOM", 0, 0)
    subTimeText:SetText("")
    subTimeText:SetTextColor(0.7, 0.7, 0.7)
    frame.subTimeText = subTimeText

    -- 进度条
    local progressBar = CreateFrame("StatusBar", nil, content)
    progressBar:SetSize(180, 8)
    progressBar:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -5)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0, 1, 0) -- 默认绿色
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetValue(0)

    -- 进度条背景
    local bg = progressBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bg:SetVertexColor(0.3, 0.3, 0.3, 0.5)
    progressBar.bg = bg

    -- 进度条边框
    local border = CreateFrame("Frame", nil, progressBar, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    progressBar.border = border

    frame.progressBar = progressBar

    -- 地图信息
    local mapText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mapText:SetPoint("TOPLEFT", progressBar, "BOTTOMLEFT", 0, -2)
    mapText:SetText("未开始")
    mapText:SetTextColor(1, 0.82, 0) -- 金色
    frame.mapText = mapText

    -- 等级信息
    local levelText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("TOPRIGHT", progressBar, "BOTTOMRIGHT", 0, -2)
    levelText:SetText("")
    levelText:SetTextColor(0.7, 0.7, 0.7)
    frame.levelText = levelText

    -- 添加闪烁动画
    local flashAnim = frame:CreateAnimationGroup()
    local flash = flashAnim:CreateAnimation("Alpha")
    flash:SetDuration(0.5)
    flash:SetFromAlpha(1)
    flash:SetToAlpha(0.3)
    flash:SetOrder(1)
    flashAnim:SetLooping("BOUNCE")
    frame.flashAnim = flashAnim

    return frame
end

--- 显示计时器UI
function WowMagicianTimerUI.Show()
    if not timerUIFrame then
        timerUIFrame = WowMagicianTimerUI.CreateUI()
    end

    -- 更新图标
    WowMagicianTimerUI.UpdateIcon()

    timerUIFrame:Show()
    WowMagicianTimerUI.UpdateDisplay(0) -- 显示初始状态

    -- 添加淡入动画
    if timerUIFrame.fadeIn then
        timerUIFrame.fadeIn:Stop()
    end
    timerUIFrame.fadeIn = timerUIFrame:CreateAnimationGroup()
    local fade = timerUIFrame.fadeIn:CreateAnimation("Alpha")
    fade:SetDuration(0.3)
    fade:SetFromAlpha(0)
    fade:SetToAlpha(1)
    fade:SetOrder(1)
    timerUIFrame.fadeIn:Play()
end

--- 隐藏计时器UI
function WowMagicianTimerUI.Hide()
    if timerUIFrame then
        -- 停止闪烁动画
        if timerUIFrame.flashAnim then
            timerUIFrame.flashAnim:Stop()
        end

        -- 添加淡出动画
        if timerUIFrame.fadeOut then
            timerUIFrame.fadeOut:Stop()
        end
        timerUIFrame.fadeOut = timerUIFrame:CreateAnimationGroup()
        local fade = timerUIFrame.fadeOut:CreateAnimation("Alpha")
        fade:SetDuration(0.2)
        fade:SetFromAlpha(1)
        fade:SetToAlpha(0)
        fade:SetOrder(1)
        timerUIFrame.fadeOut:SetScript("OnFinished", function()
            timerUIFrame:Hide()
        end)
        timerUIFrame.fadeOut:Play()
    end
end

--- 检查UI是否可见
-- @return boolean: UI可见状态
function WowMagicianTimerUI.IsVisible()
    return timerUIFrame and timerUIFrame:IsShown()
end

--- 获取UI框架对象
-- @return Frame: 计时器UI框架
function WowMagicianTimerUI.GetFrame()
    return timerUIFrame
end

--- 更新显示
-- @param officialElapsedTime number: 官方经过时间(秒)，可选
function WowMagicianTimerUI.UpdateDisplay(officialElapsedTime)
    if not timerUIFrame then return end

    local currentTime = officialElapsedTime or 0
    local timeLimit = WowMagicianTimer.GetTimeLimit()
    local remainingTime = timeLimit > 0 and math.max(0, timeLimit - currentTime) or 0
    local mapName = WowMagicianTimer.GetMapName()
    local mapID, level = WowMagicianTimer.GetMapInfo()

    -- 更新图标
    WowMagicianTimerUI.UpdateIcon()

    -- 更新时间显示 - 始终显示已经打了多久
    if WowMagicianTimer.IsRunning() then
        -- 显示已经经过的时间
        timerUIFrame.timeText:SetText(WowMagicianTimer.FormatTime(currentTime))

        -- 在副标题显示剩余时间或状态信息
        if timeLimit > 0 then
            if remainingTime <= 0 then
                -- 超时：显示超时的绝对时间
                timerUIFrame.subTimeText:SetText(string.format("|cffff0000超时 +%s|r",
                    WowMagicianTimer.FormatTime(math.abs(remainingTime))))
                timerUIFrame.timeText:SetTextColor(1, 0.4, 0.4) -- 红色表示超时
            elseif remainingTime <= 300 then                    -- 5分钟警告
                timerUIFrame.subTimeText:SetText(string.format("|cffff6600剩余: %s|r",
                    WowMagicianTimer.FormatTime(remainingTime)))
                timerUIFrame.timeText:SetTextColor(1, 0.7, 0.3) -- 橙色表示警告
            elseif remainingTime <= 600 then                    -- 10分钟注意
                timerUIFrame.subTimeText:SetText(string.format("|cffffff00剩余: %s|r",
                    WowMagicianTimer.FormatTime(remainingTime)))
                timerUIFrame.timeText:SetTextColor(1, 1, 0.5) -- 黄色表示注意
            else
                timerUIFrame.subTimeText:SetText(string.format("剩余: %s", WowMagicianTimer.FormatTime(remainingTime)))
                timerUIFrame.timeText:SetTextColor(0.5, 1, 0.5) -- 绿色表示正常
            end
        else
            timerUIFrame.subTimeText:SetText("进行中")
            timerUIFrame.timeText:SetTextColor(1, 1, 1) -- 白色表示正常
        end
    else
        -- 检查是否有官方完成时间
        local officialTime = WowMagicianTimer.GetOfficialCompletionTime()
        if officialTime then
            -- 显示官方完成时间
            timerUIFrame.timeText:SetText(WowMagicianTimer.FormatTime(officialTime))
            timerUIFrame.subTimeText:SetText("已完成")
            timerUIFrame.timeText:SetTextColor(0, 1, 0) -- 绿色表示完成
        else
            timerUIFrame.timeText:SetText("00:00")
            timerUIFrame.subTimeText:SetText("未开始")
            timerUIFrame.timeText:SetTextColor(1, 1, 1) -- 白色表示未开始
        end
    end

    -- 更新地图信息
    if mapID > 0 then
        timerUIFrame.mapText:SetText(mapName)
        timerUIFrame.levelText:SetText(string.format("等级 %d", level))
    else
        timerUIFrame.mapText:SetText("未开始")
        timerUIFrame.levelText:SetText("")
    end

    -- 更新进度条
    if timeLimit > 0 and WowMagicianTimer.IsRunning() then
        local progress = math.max(0, math.min(1, currentTime / timeLimit))
        timerUIFrame.progressBar:SetValue(progress)

        if remainingTime <= 0 then
            -- 超时：深红 + 闪烁
            timerUIFrame.progressBar:SetStatusBarColor(0.8, 0, 0)
            if not timerUIFrame.flashAnim:IsPlaying() then
                timerUIFrame.flashAnim:Play()
            end
        elseif remainingTime <= 300 then -- 5分钟
            -- 危险：红色
            timerUIFrame.progressBar:SetStatusBarColor(1, 0.2, 0.2)
            timerUIFrame.flashAnim:Stop()
        elseif remainingTime <= 600 then -- 10分钟
            -- 警告：橙色
            timerUIFrame.progressBar:SetStatusBarColor(1, 0.5, 0)
            timerUIFrame.flashAnim:Stop()
        elseif remainingTime <= 900 then -- 15分钟
            -- 注意：黄色
            timerUIFrame.progressBar:SetStatusBarColor(1, 1, 0)
            timerUIFrame.flashAnim:Stop()
        else
            -- 正常：绿色
            timerUIFrame.progressBar:SetStatusBarColor(0, 1, 0)
            timerUIFrame.flashAnim:Stop()
        end
    else
        timerUIFrame.progressBar:SetValue(0)
        timerUIFrame.progressBar:SetStatusBarColor(0.5, 0.5, 0.5)
        timerUIFrame.flashAnim:Stop()
    end
end

--- 重置UI显示
function WowMagicianTimerUI.Reset()
    if not timerUIFrame then return end

    timerUIFrame.timeText:SetText("00:00")
    timerUIFrame.timeText:SetTextColor(1, 1, 1)
    timerUIFrame.subTimeText:SetText("未开始")
    timerUIFrame.mapText:SetText("未开始")
    timerUIFrame.levelText:SetText("")
    timerUIFrame.progressBar:SetValue(0)
    timerUIFrame.progressBar:SetStatusBarColor(0.5, 0.5, 0.5)
    timerUIFrame.flashAnim:Stop()
end

--- 更新图标
function WowMagicianTimerUI.UpdateIcon()
    if not timerUIFrame or not timerUIFrame.icon then return end

    local mapID, level = WowMagicianTimer.GetMapInfo()
    if mapID > 0 then
        -- 尝试获取大秘境的图标
        local texture = select(4, C_ChallengeMode.GetMapUIInfo(mapID))
        if texture then
            timerUIFrame.icon:SetTexture(texture)
        else
            -- 默认大秘境图标
            timerUIFrame.icon:SetTexture("Interface\\Icons\\achievement_bg_masterofallbgs")
        end
    else
        -- 未开始时的图标
        timerUIFrame.icon:SetTexture("Interface\\Icons\\achievement_bg_masterofallbgs")
    end
end
