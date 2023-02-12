-- #### namespace ####
local ClassSwap = {}
_G.ClassSwap = ClassSwap
-- #### Import ####
-- local romApi = _G
-- local enabled = true

function log(msg)
    if not msg then
        msg = nil
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function ClassSwap.RemoveClassCombo(frame)
    local mainClassNameToRemove = frame.mainClassName
    local subClassNameToRemove=  frame.subClassName
    local newClassCombo = {}
    for _, mainClass in pairs(ClassSwap.classCombos) do
        local mainClassId = mainClass.classId
        local mainClassName = mainClass.name
        local subClassList = mainClass.subclass
        for _, subClass in pairs(subClassList) do
            local subClassId = subClass.classId
            local subClassName = subClass.name
            if mainClassNameToRemove == mainClassName and subClassNameToRemove == subClassName then
                ClassSwap.numOfClassCombo = ClassSwap.numOfClassCombo - 1
            else
                newClassCombo[mainClassName] = newClassCombo[mainClassName] or {classId = mainClassId, name = mainClassName, subclass = {}}
                newClassCombo[mainClassName].subclass[subClassName] = {classId = subClassId, name = subClassName}
            end
        end
    end
    ClassSwap.classCombos = newClassCombo
    ClassSwap_SaveVariablesSettings.classCombos = ClassSwap.classCombos
    ClassSwap.RenderMainClassSelector()
    ClassSwap.RenderSubClassSelector()
    ClassSwap.RenderClassCombo()
end

ClassSwap.saveSelectedClassCombo = function ()
    local mainClassOption = ClassSwap.mainClassOptions[ClassSwap.selectedMainClass]
    if not ClassSwap.classCombos[mainClassOption.name] then
        ClassSwap.classCombos[mainClassOption.name] = { classId = mainClassOption.classId, name = mainClassOption.name, subclass = {}}
    end
    if not ClassSwap.selectedSubClass then
        log("[ClassSwap] Please select subclass")
        return
    end
    subClassOption = ClassSwap.subClassOptions[ClassSwap.selectedSubClass]
    if not ClassSwap.classCombos[mainClassOption.name].subclass[subClassOption.name] then
        ClassSwap.classCombos[mainClassOption.name].subclass[subClassOption.name] = { classId = subClassOption.classId, name = subClassOption.name }
    end
    -- ClassSwap.selectedMainClass = nil
    ClassSwap.selectedSubClass = nil
    ClassSwap.RenderMainClassSelector()
    ClassSwap.RenderSubClassSelector()
    ClassSwap.RenderClassCombo()
end

function ClassSwap.ShortenClassName(className)
    -- body
    if className == "Warden" then
        return "Wd"
    elseif className == "Warlock" then
        return "Wl"
    elseif className == "Champion" then
        return "Ch"
    else
        return string.sub(className, 1, 1)
    end
end

function ClassSwap.SetUpHeightOfFrames()
    local mainFrameName = "ClassSwapFrame"
    local footerFrameName = "ClassSwapFooterFrame"
    local frameHeight = 240 + (22*ClassSwap.numOfClassCombo)
    _G[mainFrameName]:SetSize(400, frameHeight)
    _G[footerFrameName]:ClearAllAnchors();
    _G[footerFrameName]:SetAnchor("TOP", "TOP", mainFrameName, 0, frameHeight - 90);
end

function ClassSwap.SwapClassCombo(frame)
    ExchangeClass(frame.mainClassId, frame.subClassId)
end

function ClassSwap.CreateClassComboItem(i, mainClassId, mainClassName, subClassId, subClassName)
    local frameName = "ClassSwapComboItem" .. i .."Frame"
    local textFrameName = frameName .. "_Text"
    _G[frameName]:Show()
    _G[textFrameName]:SetText("==> [".. ClassSwap.ShortenClassName(mainClassName) .."/".. ClassSwap.ShortenClassName(subClassName) .."] " .. mainClassName .. " / " .. subClassName);
    _G[frameName]:ClearAllAnchors();
    _G[frameName]:SetAnchor("TOP", "TOP", "ClassSwapClassComboFrame", 10, 22*i);
    local btnFrameName = frameName .. "_Btn"
    _G[btnFrameName]:SetText("to " .. ClassSwap.ShortenClassName(mainClassName) .. "/" .. ClassSwap.ShortenClassName(subClassName))
    _G[btnFrameName].mainClassId = mainClassId
    _G[btnFrameName].subClassId = subClassId
    local removeBtnFrameName = frameName .. "_RemoveBtn"
    _G[removeBtnFrameName].mainClassName = mainClassName
    _G[removeBtnFrameName].subClassName = subClassName
end

function ClassSwap.HideAllClassCombo()
    for i = 1, 20 do
        local frameName = "ClassSwapComboItem" .. i .."Frame"
        _G[frameName]:Hide()
    end
end

function ClassSwap.RenderClassCombo()
    ClassSwap.HideAllClassCombo()
    ClassSwap.SetUpHeightOfFrames()
    local frameIndex = 1
    ClassSwap.numOfClassCombo = 0
    for _, mainClass in pairs(ClassSwap.classCombos) do
        local mainClassId = mainClass.classId
        local mainClassName = mainClass.name
        local subClassList = mainClass.subclass
        for _, subClass in pairs(subClassList) do
            local subClassId = subClass.classId
            local subClassName = subClass.name
            ClassSwap.CreateClassComboItem(frameIndex, mainClassId, mainClassName, subClassId, subClassName)
            frameIndex = frameIndex + 1
            ClassSwap.numOfClassCombo = ClassSwap.numOfClassCombo + 1
        end
    end

    -- ClassSwapClassComboFrame:SetFrame(frames)
    -- log(type(ClassSwapClassComboFrame))
    -- for k, v in pairs(ClassSwapClassComboFrame) do
    --     log(k)
    -- end
end

function ClassSwap.containInClassCombo(mainClassName, subClassName)
    if (not ClassSwap.classCombos[mainClassName]) then
        return false
    end
    local subClassList = ClassSwap.classCombos[mainClassName].subclass
    for _, v in pairs(subClassList) do
        if subClassName == v.name then
            return true
        end
    end
    return false
end

function ClassSwap.RenderCurrentClass()
    local mainClassName = GetPlayerClassInfo(EXCHANGECLASS_MAINCLASS);
    local subClassName = GetPlayerClassInfo(EXCHANGECLASS_SUBCLASS);
    local frameName = "ClassSwapCurrentClassFrame_Text"
    local btnFrameName = "ClassSwapCurrentClassFrame_Btn"
    local displayText = "==> Quick swap to [".. ClassSwap.ShortenClassName(subClassName) .."/".. ClassSwap.ShortenClassName(mainClassName) .."] ".. subClassName .." / " .. mainClassName
    _G[frameName]:SetText(displayText)
    _G[btnFrameName]:SetText("Quick swap to " .. ClassSwap.ShortenClassName(subClassName) .."/".. ClassSwap.ShortenClassName(mainClassName))
end

function ClassSwap.RenderMainClassSelector()
    local numClasses = GetNumClasses();
    local options = {}
    local optionIndex = 1    
    for classIndex = 1, numClasses do
        local class, token, level, currExp, maxExp = GetPlayerClassInfo(classIndex);
        if class then
            options[optionIndex] = {name = class, classId = classIndex}
            if not ClassSwap.selectedMainClass then
                ClassSwap.selectedMainClass = optionIndex
            end
            optionIndex = optionIndex + 1
        end
    end

    local onSelect = function(dropdown, i, v)
        ClassSwap.selectedMainClass = i
        ClassSwap.selectedSubClass = nil
        ClassSwap.RenderSubClassSelector()
    end


    ClassSwap.mainClassOptions = options
    ClassSwap.setupDropdown(ClassSwap_AddCombo_MainClassSelectorFrame, options, ClassSwap.selectedMainClass, 120, onSelect)
end



function ClassSwap.RenderSubClassSelector()
    local numClasses = GetNumClasses();
    local options = {}   
    local optionIdex = 1
    local mainClassName = ClassSwap.mainClassOptions[ClassSwap.selectedMainClass].name
    for classIndex = 1, numClasses do
        class, token, level, currExp, maxExp = GetPlayerClassInfo(classIndex);
        if class and class ~= mainClassName and not ClassSwap.containInClassCombo(mainClassName, class) then
            options[optionIdex] = {name = class, classId = classIndex}
            if not ClassSwap.selectedSubClass then
                ClassSwap.selectedSubClass = optionIdex
            end
            optionIdex = optionIdex + 1
        end        
    end

    local onSelect = function(dropdown, i, v)
        ClassSwap.selectedSubClass = i
    end

    ClassSwap.subClassOptions = options
    ClassSwap.setupDropdown(ClassSwap_AddCombo_SubClassSelectorFrame, options, ClassSwap.selectedSubClass, 120, onSelect)
end



function ClassSwap.onLoad(this)
	this:RegisterEvent("EXCHANGECLASS_SHOW")
	this:RegisterEvent("EXCHANGECLASS_CLOSED")
	this:RegisterEvent("EXCHANGECLASS_SUCCESS")
    this:RegisterEvent("EXCHANGECLASS_FAILED")
	this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("SAVE_VARIABLES")
    SaveVariablesPerCharacter("ClassSwap_SaveVariablesSettings")
end

function ClassSwap.onEvent(this, event)
	-- thanks to TheGooch and Alleris for helping simplify this to 2 clicks (click npc, click "change class")
	-- romApi.ExchangeClass(romApi.EXCHANGECLASS_SUBCLASS, romApi.EXCHANGECLASS_MAINCLASS)
	if event == "EXCHANGECLASS_SHOW" then
        ClassSwap.RenderCurrentClass()
		ClassSwapFrame:Show()
	elseif event == "EXCHANGECLASS_SUCCESS" or event == "EXCHANGECLASS_CLOSED" or event == "EXCHANGECLASS_FAILED" then
		ClassSwapFrame:Hide()
    elseif event == "VARIABLES_LOADED" then
        ClassSwap.Settings = ClassSwap_SaveVariablesSettings or {numOfClassCombo = 0, classCombos = {}}
        if not ClassSwap.Settings.numOfClassCombo then
            ClassSwap.Settings.numOfClassCombo = 0
        end
        if not ClassSwap.Settings.classCombos then
            ClassSwap.Settings.classCombos = {}
        end
        ClassSwap_SaveVariablesSettings = ClassSwap.Settings
        ClassSwap.classCombos = ClassSwap_SaveVariablesSettings.classCombos
        ClassSwap.numOfClassCombo = ClassSwap_SaveVariablesSettings.numOfClassCombo
        DEFAULT_CHAT_FRAME:AddMessage("Class Swap Helper loaded.")
        ClassSwap.RenderMainClassSelector()
        ClassSwap.RenderSubClassSelector()
        ClassSwap.RenderClassCombo()
    elseif event == "SAVE_VARIABLES" then
        ClassSwap_SaveVariablesSettings.classCombos = ClassSwap.classCombos
        ClassSwap_SaveVariablesSettings.numOfClassCombo = ClassSwap.numOfClassCombo
	end
end

function ClassSwap.setupDropdown(dropdown, values, selectedIndex, width, onSelectScript)
    if not dropdown or not values then
        return
    end
    if not width then 
        width = 120
    end
    if not selectedIndex then
        selectedIndex = 1
    end
    
    local selectFn = function(button)
        UIDropDownMenu_SetSelectedID(dropdown, button:GetID())
        if onSelectScript and type(onSelectScript) == "function" then
            onSelectScript(dropdown, button:GetID(), values[button:GetID()])
        end
    end
    local onShowFn = function()
        for _, v in pairs(values) do
            UIDropDownMenu_AddButton({["text"] = tostring(v.name), ["func"] = selectFn})
        end
    end
    
    UIDropDownMenu_SetWidth(dropdown, width)
    UIDropDownMenu_Initialize(dropdown, onShowFn)
    UIDropDownMenu_SetSelectedID(dropdown, selectedIndex)
end