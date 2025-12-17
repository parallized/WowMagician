local addonName = "WowMagician"

-- 核心模块 - 插件初始化和事件处理
WowMagicianCore = WowMagicianCore or {}

--- 初始化插件
function WowMagicianCore.Initialize()
    -- 确保依赖模块已加载
    if not WowMagicianConstants then
        error("WowMagicianConstants 模块未加载")
    end
    if not WowMagicianUtils then
        error("WowMagicianUtils 模块未加载")
    end
    if not WowMagicianData then
        error("WowMagicianData 模块未加载")
    end
    if not WowMagicianUI then
        error("WowMagicianUI 模块未加载")
    end
    if not WowMagicianDebug then
        error("WowMagicianDebug 模块未加载")
    end
    if not WowMagicianTimer then
        error("WowMagicianTimer 模块未加载")
    end
    if not WowMagicianTimerUI then
        error("WowMagicianTimerUI 模块未加载")
    end
    if not WowMagicianTimeline then
        error("WowMagicianTimeline 模块未加载")
    end
    if not WowMagicianTimelineData then
        error("WowMagicianTimelineData 模块未加载")
    end
    if not WowMagicianTimelineUI then
        error("WowMagicianTimelineUI 模块未加载")
    end

    -- 初始化Debug模块
    WowMagicianDebug.Initialize()

    -- 初始化Timer模块
    WowMagicianTimer.Initialize()

    -- 初始化Timeline模块
    WowMagicianTimeline.Initialize()
    WowMagicianTimelineUI.Initialize()

    -- 注册斜杠命令
    WowMagicianCore.RegisterSlashCommands()

    print("|cff00ff00[WowMagician]|r 插件已加载! 输入 |cff00ff00/wowm|r 来显示团队信息")
end

--- 注册斜杠命令
function WowMagicianCore.RegisterSlashCommands()
    SLASH_WOWMAGICIAN1 = "/wowm"
    SLASH_WOWMAGICIAN2 = "/wowmagician"

    SlashCmdList["WOWMAGICIAN"] = function(msg)
        WowMagicianCore.HandleSlashCommand(msg)
    end
end

--- 处理斜杠命令
-- @param msg string: 命令参数
function WowMagicianCore.HandleSlashCommand(msg)
    msg = strtrim(msg or "")

    if msg == "" or msg == "show" then
        WowMagicianUI.ShowRaidInfo()
    elseif msg == "hide" then
        WowMagicianUI.HideRaidInfo()
    elseif msg == "debug" then
        WowMagicianDebug.Show()
    elseif msg == "debug on" then
        WowMagicianDebug.Enable()
    elseif msg == "debug off" then
        WowMagicianDebug.Disable()
    elseif msg == "debug toggle" then
        WowMagicianDebug.Toggle()
    elseif msg == "debug clear" then
        WowMagicianDebug.ClearLog()
    elseif msg == "timer" then
        WowMagicianTimer.Toggle()
    elseif msg == "timeline" then
        WowMagicianTimeline.Toggle()
    elseif msg == "help" then
        WowMagicianCore.ShowHelp()
    else
        print("|cff00ff00[WowMagician]|r 未知命令. 使用 |cff00ff00/wowm help|r 查看帮助")
    end
end

--- 显示帮助信息
function WowMagicianCore.ShowHelp()
    print("|cff00ff00[WowMagician] 命令帮助:|r")
    print("  |cff00ff00/wowm|r 或 |cff00ff00/wowm show|r - 显示团队信息")
    print("  |cff00ff00/wowm hide|r - 隐藏团队信息")
    print("  |cff00ff00/wowm debug|r - 打开调试控制台")
    print("  |cff00ff00/wowm debug on|r - 启用事件监听")
    print("  |cff00ff00/wowm debug off|r - 禁用事件监听")
    print("  |cff00ff00/wowm debug toggle|r - 切换调试模式")
    print("  |cff00ff00/wowm debug clear|r - 清空调试日志")
    print("  |cff00ff00/wowm timer|r - 切换计时器显示")
    print("  |cff00ff00/wowm timeline|r - 切换时间轴显示")
    print("  |cff00ff00/wowm help|r - 显示此帮助信息")
end

--- 事件处理器
-- @param event string: 事件名称
-- @param ... 事件参数
function WowMagicianCore.OnEvent(event, ...)
    if event == "ADDON_LOADED" and (...) == addonName then
        WowMagicianCore.Initialize()
    end
end

--- 获取插件版本信息
-- @return string: 版本信息
function WowMagicianCore.GetVersion()
    return "WowMagician v1.0.0"
end

--- 检查插件依赖
-- @return boolean: 是否所有依赖都已满足
function WowMagicianCore.CheckDependencies()
    local dependencies = {
        "WowMagicianConstants",
        "WowMagicianUtils",
        "WowMagicianData",
        "WowMagicianUI",
        "WowMagicianTimer",
        "WowMagicianTimerUI",
        "WowMagicianDebug"
    }

    for _, dep in ipairs(dependencies) do
        if not _G[dep] then
            print("|cffff0000[WowMagician] 错误: 依赖模块 " .. dep .. " 未找到|r")
            return false
        end
    end

    return true
end
