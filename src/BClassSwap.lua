-- #### namespace ####
local BClassSwap = {}
_G.BClassSwap = BClassSwap

function log(msg)
    if not msg then
        msg = nil
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function BClassSwap.RemoveClassCombo(frame)
    local mainClassNameToRemove = frame.mainClassName
    local subClassNameToRemove=  frame.subClassName
    local newClassCombo = {}
    for _, mainClass in pairs(BClassSwap.classCombos) do
        local mainClassId = mainClass.classId
        local mainClassName = mainClass.name
        local subClassList = mainClass.subclass
        for _, subClass in pairs(subClassList) do
            local subClassId = subClass.classId
            local subClassName = subClass.name
            if mainClassNameToRemove == mainClassName and subClassNameToRemove == subClassName then
                BClassSwap.numOfClassCombo = BClassSwap.numOfClassCombo - 1
            else
                newClassCombo[mainClassName] = newClassCombo[mainClassName] or {classId = mainClassId, name = mainClassName, subclass = {}}
                newClassCombo[mainClassName].subclass[subClassName] = {classId = subClassId, name = subClassName}
            end
        end
    end
    BClassSwap.classCombos = newClassCombo
    BClassSwap_SaveVariablesSettings.classCombos = BClassSwap.classCombos
    BClassSwap.RenderMainClassSelector()
    BClassSwap.RenderSubClassSelector()
    BClassSwap.RenderClassCombo()
end

BClassSwap.saveSelectedClassCombo = function ()
    local mainClassOption = BClassSwap.mainClassOptions[BClassSwap.selectedMainClass]
    if not BClassSwap.classCombos[mainClassOption.name] then
        BClassSwap.classCombos[mainClassOption.name] = { classId = mainClassOption.classId, name = mainClassOption.name, subclass = {}}
    end
    if not BClassSwap.selectedSubClass then
        log("[BClassSwap] Please select subclass")
        return
    end
    subClassOption = BClassSwap.subClassOptions[BClassSwap.selectedSubClass]
    if not BClassSwap.classCombos[mainClassOption.name].subclass[subClassOption.name] then
        BClassSwap.classCombos[mainClassOption.name].subclass[subClassOption.name] = { classId = subClassOption.classId, name = subClassOption.name }
    end
    -- BClassSwap.selectedMainClass = nil
    BClassSwap.selectedSubClass = nil
    BClassSwap.RenderMainClassSelector()
    BClassSwap.RenderSubClassSelector()
    BClassSwap.RenderClassCombo()
end

function BClassSwap.ShortenClassName(className)
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

function BClassSwap.SetUpHeightOfFrames()
    local mainFrameName = "BClassSwapFrame"
    local footerFrameName = "BClassSwapFooterFrame"
    local frameHeight = 240 + (22*BClassSwap.numOfClassCombo)
    _G[mainFrameName]:SetSize(400, frameHeight)
    _G[footerFrameName]:ClearAllAnchors();
    _G[footerFrameName]:SetAnchor("TOP", "TOP", mainFrameName, 0, frameHeight - 90);
end

function BClassSwap.SwapClassCombo(frame)
    ExchangeClass(frame.mainClassId, frame.subClassId)
end

function BClassSwap.CreateClassComboItem(i, mainClassId, mainClassName, subClassId, subClassName)
    local frameName = "BClassSwapComboItem" .. i .."Frame"
    local textFrameName = frameName .. "_Text"
    _G[frameName]:Show()
    _G[textFrameName]:SetText("==> [".. BClassSwap.ShortenClassName(mainClassName) .."/".. BClassSwap.ShortenClassName(subClassName) .."] " .. mainClassName .. " / " .. subClassName);
    _G[frameName]:ClearAllAnchors();
    _G[frameName]:SetAnchor("TOP", "TOP", "BClassSwapClassComboFrame", 10, 22*i);
    local btnFrameName = frameName .. "_Btn"
    _G[btnFrameName]:SetText("to " .. BClassSwap.ShortenClassName(mainClassName) .. "/" .. BClassSwap.ShortenClassName(subClassName))
    _G[btnFrameName].mainClassId = mainClassId
    _G[btnFrameName].subClassId = subClassId
    local removeBtnFrameName = frameName .. "_RemoveBtn"
    _G[removeBtnFrameName].mainClassName = mainClassName
    _G[removeBtnFrameName].subClassName = subClassName
end

function BClassSwap.HideAllClassCombo()
    for i = 1, 20 do
        local frameName = "BClassSwapComboItem" .. i .."Frame"
        _G[frameName]:Hide()
    end
end

function BClassSwap.RenderClassCombo()
    BClassSwap.HideAllClassCombo()
    BClassSwap.SetUpHeightOfFrames()
    local frameIndex = 1
    BClassSwap.numOfClassCombo = 0
    for _, mainClass in pairs(BClassSwap.classCombos) do
        local mainClassId = mainClass.classId
        local mainClassName = mainClass.name
        local subClassList = mainClass.subclass
        for _, subClass in pairs(subClassList) do
            local subClassId = subClass.classId
            local subClassName = subClass.name
            BClassSwap.CreateClassComboItem(frameIndex, mainClassId, mainClassName, subClassId, subClassName)
            frameIndex = frameIndex + 1
            BClassSwap.numOfClassCombo = BClassSwap.numOfClassCombo + 1
        end
    end
end

function BClassSwap.containInClassCombo(mainClassName, subClassName)
    if (not BClassSwap.classCombos[mainClassName]) then
        return false
    end
    local subClassList = BClassSwap.classCombos[mainClassName].subclass
    for _, v in pairs(subClassList) do
        if subClassName == v.name then
            return true
        end
    end
    return false
end

function BClassSwap.GetPlayerClassInfoEnglish(classId)
    local class, token, level, currExp, maxExp, xpDebt = GetPlayerClassInfo(classId);
    if not token then
        return class, token, level, currExp, maxExp, xpDebt
    end
    if (token == "WARRIOR") then
        return "Warrior", token, level, currExp, maxExp, xpDebt
    elseif (token == "RANGER") then
        return "Scout", token, level, currExp, maxExp, xpDebt
    elseif (token == "THIEF") then
        return "Rogue", token, level, currExp, maxExp, xpDebt
    elseif (token == "MAGE") then
        return "Mage", token, level, currExp, maxExp, xpDebt
    elseif (token == "AUGUR") then
        return "Priest", token, level, currExp, maxExp, xpDebt
    elseif (token == "KNIGHT") then
        return "Knight", token, level, currExp, maxExp, xpDebt
    elseif (token == "WARDEN") then
        return "Warden", token, level, currExp, maxExp, xpDebt
    elseif (token == "DRUID") then
        return "Druid", token, level, currExp, maxExp, xpDebt
    elseif (token == "PSYRON") then
        return "Champion", token, level, currExp, maxExp, xpDebt
    elseif (token == "HARPSYN") then
        return "Warlock", token, level, currExp, maxExp, xpDebt
    end
end


function BClassSwap.RenderCurrentClass()
    local mainClassName = BClassSwap.GetPlayerClassInfoEnglish(EXCHANGECLASS_MAINCLASS);
    local subClassName = BClassSwap.GetPlayerClassInfoEnglish(EXCHANGECLASS_SUBCLASS);
    local frameName = "BClassSwapCurrentClassFrame_Text"
    local btnFrameName = "BClassSwapCurrentClassFrame_Btn"
    local displayText = "==> Quick swap to [".. BClassSwap.ShortenClassName(subClassName) .."/".. BClassSwap.ShortenClassName(mainClassName) .."] ".. subClassName .." / " .. mainClassName
    _G[frameName]:SetText(displayText)
    _G[btnFrameName]:SetText("Quick swap to " .. BClassSwap.ShortenClassName(subClassName) .."/".. BClassSwap.ShortenClassName(mainClassName))
end

function BClassSwap.RenderMainClassSelector()
    local numClasses = GetNumClasses();
    local options = {}
    local optionIndex = 1    
    for classIndex = 2, numClasses do
        local class, token, level, currExp, maxExp = BClassSwap.GetPlayerClassInfoEnglish(classIndex);
        if class then
            options[optionIndex] = {name = class, classId = classIndex}
            if not BClassSwap.selectedMainClass then
                BClassSwap.selectedMainClass = optionIndex
            end
            optionIndex = optionIndex + 1
        end
    end

    local onSelect = function(dropdown, i, v)
        BClassSwap.selectedMainClass = i
        BClassSwap.selectedSubClass = nil
        BClassSwap.RenderSubClassSelector()
    end


    BClassSwap.mainClassOptions = options
    BClassSwap.setupDropdown(BClassSwap_AddCombo_MainClassSelectorFrame, options, BClassSwap.selectedMainClass, 120, onSelect)
end



function BClassSwap.RenderSubClassSelector()
    local numClasses = GetNumClasses();
    local options = {}   
    local optionIdex = 1
    local mainClassName = BClassSwap.mainClassOptions[BClassSwap.selectedMainClass].name
    for classIndex = 1, numClasses do
        class, token, level, currExp, maxExp = BClassSwap.GetPlayerClassInfoEnglish(classIndex);
        if class and class ~= mainClassName and not BClassSwap.containInClassCombo(mainClassName, class) then
            options[optionIdex] = {name = class, classId = classIndex}
            if not BClassSwap.selectedSubClass then
                BClassSwap.selectedSubClass = optionIdex
            end
            optionIdex = optionIdex + 1
        end        
    end

    local onSelect = function(dropdown, i, v)
        BClassSwap.selectedSubClass = i
    end

    BClassSwap.subClassOptions = options
    BClassSwap.setupDropdown(BClassSwap_AddCombo_SubClassSelectorFrame, options, BClassSwap.selectedSubClass, 120, onSelect)
end



function BClassSwap.onLoad(this)
	this:RegisterEvent("EXCHANGECLASS_SHOW")
	this:RegisterEvent("EXCHANGECLASS_CLOSED")
	this:RegisterEvent("EXCHANGECLASS_SUCCESS")
    this:RegisterEvent("EXCHANGECLASS_FAILED")
	this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("SAVE_VARIABLES")
    SaveVariablesPerCharacter("BClassSwap_SaveVariablesSettings")
end

function BClassSwap.onEvent(this, event)
	-- thanks to TheGooch and Alleris for helping simplify this to 2 clicks (click npc, click "change class")
	-- romApi.ExchangeClass(romApi.EXCHANGECLASS_SUBCLASS, romApi.EXCHANGECLASS_MAINCLASS)
	if event == "EXCHANGECLASS_SHOW" then
        BClassSwap.RenderCurrentClass()
		BClassSwapFrame:Show()
	elseif event == "EXCHANGECLASS_SUCCESS" or event == "EXCHANGECLASS_CLOSED" or event == "EXCHANGECLASS_FAILED" then
		BClassSwapFrame:Hide()
    elseif event == "VARIABLES_LOADED" then
        BClassSwap.Settings = BClassSwap_SaveVariablesSettings or {numOfClassCombo = 0, classCombos = {}}
        if not BClassSwap.Settings.numOfClassCombo then
            BClassSwap.Settings.numOfClassCombo = 0
        end
        if not BClassSwap.Settings.classCombos then
            BClassSwap.Settings.classCombos = {}
        end
        BClassSwap_SaveVariablesSettings = BClassSwap.Settings
        BClassSwap.classCombos = BClassSwap_SaveVariablesSettings.classCombos
        BClassSwap.numOfClassCombo = BClassSwap_SaveVariablesSettings.numOfClassCombo
        DEFAULT_CHAT_FRAME:AddMessage("Class Swap Helper loaded.")
        BClassSwap.RenderMainClassSelector()
        BClassSwap.RenderSubClassSelector()
        BClassSwap.RenderClassCombo()
    elseif event == "SAVE_VARIABLES" then
        BClassSwap_SaveVariablesSettings.classCombos = BClassSwap.classCombos
        BClassSwap_SaveVariablesSettings.numOfClassCombo = BClassSwap.numOfClassCombo
	end
end

function BClassSwap.setupDropdown(dropdown, values, selectedIndex, width, onSelectScript)
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