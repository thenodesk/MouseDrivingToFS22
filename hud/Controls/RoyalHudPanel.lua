--- Royal Hud

---@author Royal Modding
---@version 1.3.0.0
---@date 10/11/2020

--- RoyalHudPanel class
---@class RoyalHudPanel : RoyalHudControl
RoyalHudPanel = {}
RoyalHudPanel_mt = Class(RoyalHudPanel, RoyalHudControl)

--- Create new hud panel
---@param name string name of the hud
---@param x number normalized (relative to parent) size if the value is between 0 and 1 otherwise a pixel value
---@param y number normalized (relative to parent) size if the value is between 0 and 1 otherwise a pixel value
---@param width number size in pixels
---@param height number size in pixels
---@param style? table style for thus control
---@param parent? table parent of the hud
---@return RoyalHudPanel
function RoyalHudPanel:new(name, x, y, width, height, style, parent, mt)
    ---@type RoyalHudPanel
    local control = RoyalHudControl:new(name, x, y, width, height, style, parent, mt or RoyalHudPanel_mt)

    control.bg = RoyalHudOverlay:new(name .. "_bg", 0.5, 0.5, width, height, control)
    control.bg:setColor(control.style.panel.bgColor)

    control.bBorder = RoyalHudOverlay:new(name .. "_bBorder", 0.5, 0, width, control.style.panel.borders["BOTTOM"].size, control.bg)
    control.bBorder:setColor(control.style.panel.borders["BOTTOM"].color)

    control.tBorder = RoyalHudOverlay:new(name .. "_tBorder", 0.5, 1, width, control.style.panel.borders["TOP"].size, control.bg)
    control.tBorder:setAlignment(RoyalHud.ALIGNS_VERTICAL_TOP, RoyalHud.ALIGNS_HORIZONTAL_CENTER)
    control.tBorder:setColor(control.style.panel.borders["TOP"].color)

    control.lBorder = RoyalHudOverlay:new(name .. "_lBorder", 0, 0, control.style.panel.borders["LEFT"].size, height - (control.style.panel.borders["BOTTOM"].size / 2), control.tBorder)
    control.lBorder:setAlignment(RoyalHud.ALIGNS_VERTICAL_TOP, RoyalHud.ALIGNS_HORIZONTAL_LEFT)
    control.lBorder:setColor(control.style.panel.borders["LEFT"].color)

    control.rBorder = RoyalHudOverlay:new(name .. "_rBorder", 1, 0, control.style.panel.borders["RIGHT"].size, height - (control.style.panel.borders["BOTTOM"].size / 2), control.tBorder)
    control.rBorder:setAlignment(RoyalHud.ALIGNS_VERTICAL_TOP, RoyalHud.ALIGNS_HORIZONTAL_RIGHT)
    control.rBorder:setColor(control.style.panel.borders["RIGHT"].color)
    return control
end
