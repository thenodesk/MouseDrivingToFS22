---Mouse Driving

---@author Executor of Modding, n0tr3adY
---@version 1.0.0.0
---@date 05/02/2021

---@class AxisHud : RoyalHudImage
---@field superClass function
AxisHud = {}
AxisHud.DUBUG_COLOR = {1, 0, 1, 1}
AxisHud.dir = MouseDrivingMain.directory
AxisHud_mt = Class(AxisHud, RoyalHudImage)

function AxisHud:new()
    ---@type AxisHud
    local hud = RoyalHudImage:new("AxisHud_bg", self.dir .. "axis_bg.dds", 1 - (g_safeFrameOffsetX / 2), g_safeFrameOffsetY, 118, 118, nil, AxisHud_mt)
    hud:setAlignment(RoyalHud.ALIGNS_VERTICAL_BOTTOM, RoyalHud.ALIGNS_HORIZONTAL_RIGHT)
    hud.indicator = RoyalHudImage:new("AxisHud_indicator", self.dir .. "axis_indicator.dds", 0.5, 0.5, 23, 23, hud)

    hud.axisX = 0
    hud.axisY = 0
    hud.realX = 0
    hud.realY = 0
    return hud
end

function AxisHud:setAxisData(x, y)
    self.axisX = x
    self.axisY = y
end

function AxisHud:update(dt)
    AxisHud:superClass().update(self, dt, true)
    local limiter = 0.5
    if self.axisX == 0 or self.axisY == 0 then
        limiter = 0.8
    end
    local targetX = self.axisX * limiter
    local targetY = self.axisY * limiter
    local step = dt / 1000
    if self.realX < targetX then
        self.realX = math.min(targetX, self.realX + step)
    end
    if self.realX > targetX then
        self.realX = math.max(targetX, self.realX - step)
    end
    if self.realY < targetY then
        self.realY = math.min(targetY, self.realY + step)
    end
    if self.realY > targetY then
        self.realY = math.max(targetY, self.realY - step)
    end
    local x = Utility.clamp(0, (self.realX + 1) / 2, 1)
    local y = Utility.clamp(0, (self.realY + 1) / 2, 1)
    self.indicator:setPosition(x, y)
end

function AxisHud:getRenderPosition()
    local x, y = AxisHud:superClass().getRenderPosition(self)

    if MouseDrivingMain.fillLevelsDisplay ~= nil then
        local fldX, _ = MouseDrivingMain.fillLevelsDisplay:getPosition()
        x = x - (1 - fldX)
        if MouseDrivingMain.fillLevelsDisplay:getVisible() then
            x = x - (g_safeFrameOffsetX / 2)
        else
            x = x + MouseDrivingMain.fillLevelsDisplay:getWidth()
        end
    end

    return x, y
end
