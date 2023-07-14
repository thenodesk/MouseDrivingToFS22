--- Royal Settings

---@author Royal Modding
---@version 1.3.0.0
---@date 18/01/2021

SettingsGuiPage = {}

local SettingsGuiPage_mt = Class(SettingsGuiPage, TabbedMenuFrameElement)

SettingsGuiPage.CONTROLS = {
  "settingsContainer", "headerIcon", "headerText",
  --"cloneElement",
  "settingElement1", "settingElement2", "settingElement3", "settingElement4",
  "settingElement5", "settingElement6", "settingElement7", "settingElement8",
  "ingameMenuHelpBox"
}

function SettingsGuiPage:new(target)
    --local o = TabbedMenuFrameElement:new(target, SettingsGuiPage_mt)
    local o = TabbedMenuFrameElement.new(target, SettingsGuiPage_mt)
    o.returnScreenName = ""
    o.settingElements = {}
    o:registerControls(SettingsGuiPage.CONTROLS)
    return o
end

---@param mod RoyalSettingsMod
function SettingsGuiPage:setup(mod)
    --if self.cloneElement ~= nil then
        ---@type RoyalSetting
--         local orderedSett = {mod.orderedSettings[1], mod.orderedSettings[2]}
        for idx, setting in ipairs(mod.orderedSettings) do
--         for idx, setting in ipairs(orderedSett) do
--             local cloned = self.cloneElement:clone(self.cloneElement.parent, false, true)
            local cloned = self["settingElement"..idx]
            cloned.id = "clonedElement_" .. setting.key
            cloned.name = setting.key
            cloned:setLabel(setting.description)
            local texts = {}
            for i, option in ipairs(setting.options) do
                texts[i] = option.text
            end
            cloned:setTexts(texts)
            cloned.toolTipText = setting.tooltip
            --cloned.toolTipElement = self.cloneElement.toolTipElement
            cloned.royalSetting = setting
            table.insert(self.settingElements, cloned)
        end
        --self.cloneElement:delete()
    --end
end

function SettingsGuiPage:onFrameOpen()
    SettingsGuiPage:superClass().onFrameOpen(self)
    FocusManager:unsetHighlight(FocusManager.currentFocusData.highlightElement)
    FocusManager:unsetFocus(FocusManager.currentFocusData.focusElement)
    self:updateElementsState()
end

function SettingsGuiPage:onFrameClose()
    SettingsGuiPage:superClass().onFrameClose(self)
end

----- Get the frame's main content element's screen size.
function SettingsGuiPage:getMainElementSize()
    return self.settingsContainer.size
end

--- Get the frame's main content element's screen position.
function SettingsGuiPage:getMainElementPosition()
    return self.settingsContainer.absPosition
end

function SettingsGuiPage:updateElementsState()
    for _, element in pairs(self.settingElements) do
        if element.royalSetting ~= nil then
            ---@type RoyalSetting
            local setting = element.royalSetting
            element:setState(setting:getSelectedIndex())
        end
    end
end

function SettingsGuiPage:onOptionChange(state, element)
    if element.royalSetting ~= nil then
        ---@type RoyalSetting
        local setting = element.royalSetting
        setting:select(state)
    end
end

function SettingsGuiPage:onIngameMenuHelpTextChanged(box)
    local hasText = box.text ~= nil and box.text ~= ""
    self.ingameMenuHelpBox:setVisible(hasText)
end
