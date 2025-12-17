local addonName = "WowMagician"

WowMagicianTimer = WowMagicianTimer or {}

-- 私有变量
local isTimerRunning = false
local timeLimit = 0
local currentMapID = 0
local currentLevel = 0
local updateInterval = 0.1
local lastUpdate = 0

--- 初始化Timer模块
function WowMagicianTimer.Initialize()
    WowMagicianTimer.RegisterEventListeners()
    print("|cff00ff00[WowMagician Timer]|r Timer模块已初始化")
end

--- 注册事件监听器
function WowMagicianTimer.RegisterEventListeners()
    if not WowMagicianTimer.eventFrame then
        WowMagicianTimer.eventFrame = CreateFrame("Frame")
        WowMagicianTimer.eventFrame:SetScript("OnEvent", WowMagicianTimer.OnEvent)
        WowMagicianTimer.eventFrame:SetScript("OnUpdate", WowMagicianTimer.OnUpdate)
    end

    WowMagicianTimer.eventFrame:RegisterEvent("PLAYER_LOGIN")
    WowMagicianTimer.eventFrame:RegisterEvent("CHALLENGE_MODE_START")
    WowMagicianTimer.eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    WowMagicianTimer.eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
end

--- 事件处理器
function WowMagicianTimer.OnEvent(frame, event, ...)
    if event == "PLAYER_LOGIN" then
        WowMagicianTimer.CheckInitialChallengeMode()
    elseif event == "CHALLENGE_MODE_START" then
        local mapID, level, timeLimitSeconds = ...
        WowMagicianTimer.StartTimer(mapID, level, timeLimitSeconds)
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        WowMagicianTimer.StopTimer()
    elseif event == "PLAYER_LEAVING_WORLD" then
        if C_ChallengeMode.IsChallengeModeActive() then
            print("|cff00ff00[WowMagician Timer]|r 离开世界但仍在挑战模式中，继续计时")
        else
            WowMagicianTimer.StopTimer()
        end
    end
end

--- 更新处理器 - 直接显示官方经过时间
function WowMagicianTimer.OnUpdate(frame, elapsed)
    lastUpdate = lastUpdate + elapsed

    if lastUpdate >= updateInterval then
        lastUpdate = 0
        if isTimerRunning then
            -- 直接获取并显示官方经过时间
            local _, officialElapsedTime = GetWorldElapsedTime(1)
            if officialElapsedTime then
                -- 将官方时间传递给UI显示
                WowMagicianTimerUI.UpdateDisplay(officialElapsedTime)

                -- 更新时间轴显示
                if WowMagicianTimeline and WowMagicianTimeline.IsEnabled() then
                    WowMagicianTimeline.UpdateNearbyEvents(officialElapsedTime)
                end
            end
        end
    end
end

--- 开始计时器
function WowMagicianTimer.StartTimer(mapID, level, timeLimitSeconds)
    timeLimit = timeLimitSeconds or 0
    currentMapID = mapID or 0
    currentLevel = level or 0
    isTimerRunning = true
    lastUpdate = 0

    local deathCount = C_ChallengeMode.GetDeathCount() or 0
    local mapName = select(1, C_ChallengeMode.GetMapUIInfo(mapID)) or "未知地图"

    print(string.format("|cff00ff00[WowMagician Timer]|r 战斗开始 - 开始计时: %s (等级%d, 时间限制%d秒, 当前死亡%d次)",
        mapName, level, timeLimitSeconds, deathCount))

    -- 自动加载该地图的时间轴数据
    if WowMagicianTimeline then
        WowMagicianTimeline.AutoSetTimelineForMap(mapID)
    end

    WowMagicianTimerUI.Show()
    WowMagicianTimerUI.UpdateIcon()
end

--- 停止计时器
function WowMagicianTimer.StopTimer()
    if not isTimerRunning then return end

    isTimerRunning = false

    -- 获取官方完成信息
    local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members =
        C_ChallengeMode.GetCompletionInfo()

    if mapChallengeModeID then
        local officialTime = time / 1000 -- 毫秒转秒
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

        local mapName = select(1, C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)) or "未知地图"
        print(string.format("|cff00ff00[WowMagician Timer]|r 大秘境完成: %s (等级%d, 官方用时%.2f秒, %s, 钥石升级%d级%s)",
            mapName, level, officialTime, result, keystoneUpgradeLevels, recordInfo))
    else
        local mapName = select(1, C_ChallengeMode.GetMapUIInfo(currentMapID)) or "未知地图"
        print(string.format("|cff00ff00[WowMagician Timer]|r 停止计时: %s", mapName))
    end

    WowMagicianTimerUI.Hide()
    WowMagicianTimer.ResetTimer()
end

--- 检查进入游戏时是否已经在挑战模式中
function WowMagicianTimer.CheckInitialChallengeMode()
    if C_ChallengeMode.IsChallengeModeActive() then
        local mapID = C_ChallengeMode.GetActiveChallengeMapID()
        if mapID and mapID > 0 then
            local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo()
            local deathCount = C_ChallengeMode.GetDeathCount() or 0
            local timeLimitSeconds = select(3, C_ChallengeMode.GetMapUIInfo(mapID)) or 0

            print(string.format("|cff00ff00[WowMagician Timer]|r 检测到正在进行大秘境挑战 (等级%d, 死亡%d次)，恢复计时器",
                level or 0, deathCount))

            WowMagicianTimer.StartTimer(mapID, level or 0, timeLimitSeconds)
        end
    end
end

--- 重置计时器
function WowMagicianTimer.ResetTimer()
    isTimerRunning = false
    timeLimit = 0
    currentMapID = 0
    currentLevel = 0
    lastUpdate = 0

    WowMagicianTimerUI.Reset()
end

--- 检查计时器是否运行
function WowMagicianTimer.IsRunning()
    return isTimerRunning
end

--- 获取时间限制
function WowMagicianTimer.GetTimeLimit()
    return timeLimit or 0
end

--- 获取当前地图信息
function WowMagicianTimer.GetMapInfo()
    return currentMapID, currentLevel
end

--- 获取地图名称
function WowMagicianTimer.GetMapName()
    if currentMapID == 0 then return "未开始" end
    return select(1, C_ChallengeMode.GetMapUIInfo(currentMapID)) or "未知地图"
end

--- 格式化时间显示
function WowMagicianTimer.FormatTime(seconds)
    if not seconds or seconds <= 0 then
        return "00:00"
    end

    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)

    return string.format("%02d:%02d", minutes, secs)
end

--- 获取当前挑战模式状态信息
function WowMagicianTimer.GetChallengeModeStats()
    if not C_ChallengeMode.IsChallengeModeActive() then
        return nil
    end

    local deathCount = C_ChallengeMode.GetDeathCount() or 0
    local mapID = C_ChallengeMode.GetActiveChallengeMapID()
    local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo()

    return {
        deathCount = deathCount,
        mapID = mapID,
        level = level,
        affixes = affixes,
        wasEnergized = wasEnergized
    }
end

--- 获取官方完成时间
function WowMagicianTimer.GetOfficialCompletionTime()
    local mapChallengeModeID, level, time, onTime = C_ChallengeMode.GetCompletionInfo()
    if mapChallengeModeID and time then
        return time / 1000 -- 毫秒转秒
    end
    return nil
end

--- 获取完成状态信息
function WowMagicianTimer.GetCompletionStatus()
    local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members =
        C_ChallengeMode.GetCompletionInfo()

    if not mapChallengeModeID then
        return nil
    end

    return {
        mapID = mapChallengeModeID,
        level = level,
        time = time / 1000, -- 毫秒转秒
        onTime = onTime,
        keystoneUpgradeLevels = keystoneUpgradeLevels,
        practiceRun = practiceRun,
        oldScore = oldOverallDungeonScore,
        newScore = newOverallDungeonScore,
        isMapRecord = IsMapRecord,
        isAffixRecord = IsAffixRecord,
        primaryAffix = PrimaryAffix,
        isEligibleForScore = isEligibleForScore,
        members = members
    }
end

--- 切换计时器显示
function WowMagicianTimer.Toggle()
    if WowMagicianTimerUI.IsVisible() then
        WowMagicianTimerUI.Hide()
    else
        WowMagicianTimerUI.Show()
    end
end
