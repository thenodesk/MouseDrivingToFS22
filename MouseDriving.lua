--- Mouse Driving

---@author Executor of Modding, n0tr3adY
---@version 1.0.0.0
---@date 04/02/2021

---@class MouseDriving
---@field getIsEntered fun():boolean
---@field clearActionEventsTable fun(actionEvents:table)
---@field getIsActiveForInput fun():boolean
---@field addActionEvent function
MouseDriving = {}
MouseDriving.MOD_NAME = g_currentModName
MouseDriving.THROTTLE_BASE_DEADZONE = 0.05
MouseDriving.THROTTLE_BASE_SENSITIVITY = 0.02
MouseDriving.THROTTLE_DEADZONE = 0
MouseDriving.THROTTLE_SENSITIVITY = 0
MouseDriving.THROTTLE_ENABLED = true
MouseDriving.THROTTLE_INVERTED = -1
MouseDriving.STEER_BASE_DEADZONE = 0.035
MouseDriving.STEER_BASE_SENSITIVITY = 0.013
MouseDriving.STEER_DEADZONE = 0
MouseDriving.STEER_SENSITIVITY = 0
MouseDriving.STEER_ENABLED = true
MouseDriving.SHOW_HUD = true

function MouseDriving.initSpecialization()
    MouseDriving.hud = AxisHud:new()
end

function MouseDriving.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Drivable, specializations)
end

function MouseDriving.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "toggleMouseDriving", MouseDriving.toggleMouseDriving)
    SpecializationUtil.registerFunction(vehicleType, "resetMouseDriving", MouseDriving.resetMouseDriving)
end

function MouseDriving.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", MouseDriving)
end

function MouseDriving:onPreLoad(_)
    ---@type table
    self.spec_mouseDriving = self[string.format("spec_%s.mouseDriving", MouseDriving.MOD_NAME)]
    local spec = self.spec_mouseDriving
    spec.enabled = false
    spec.paused = false

    spec.realSteerAxis = 0
    spec.computedSteerAxis = 0

    spec.realThrottleAxis = 0
    spec.computedThrottleAxis = 0

    MouseDrivingMain:addSettingsChangedEventListener(self, MouseDriving.onSettingsChangedEvent)
end

function MouseDriving:onDelete()
    MouseDrivingMain:removeSettingsChangedEventListener(self)
end

function MouseDriving:onUpdate(dt, _, _, _)
    if self:getIsEntered() then
        local spec = self.spec_mouseDriving

        if spec.enabled and not g_inputBinding:getShowMouseCursor() then
            -- compute "real" axes
            spec.realSteerAxis = Utility.clamp(-1 - MouseDriving.STEER_DEADZONE, spec.realSteerAxis + (MouseDrivingMain.mouseXAxis * MouseDriving.STEER_SENSITIVITY), 1 + MouseDriving.STEER_DEADZONE)
            spec.realThrottleAxis = Utility.clamp(-1 - MouseDriving.THROTTLE_DEADZONE, spec.realThrottleAxis + (MouseDrivingMain.mouseYAxis * MouseDriving.THROTTLE_SENSITIVITY * MouseDriving.THROTTLE_INVERTED), 1 + MouseDriving.THROTTLE_DEADZONE)

            -- compute "computed" axes (apply deadzone)
            if spec.realSteerAxis <= -MouseDriving.STEER_DEADZONE then
                spec.computedSteerAxis = spec.realSteerAxis + MouseDriving.STEER_DEADZONE
            elseif spec.realSteerAxis >= MouseDriving.STEER_DEADZONE then
                spec.computedSteerAxis = spec.realSteerAxis - MouseDriving.STEER_DEADZONE
            else
                spec.computedSteerAxis = 0
            end

            if spec.realThrottleAxis <= -MouseDriving.THROTTLE_DEADZONE then
                spec.computedThrottleAxis = spec.realThrottleAxis + MouseDriving.THROTTLE_DEADZONE
            elseif spec.realThrottleAxis >= MouseDriving.THROTTLE_DEADZONE then
                spec.computedThrottleAxis = spec.realThrottleAxis - MouseDriving.THROTTLE_DEADZONE
            else
                spec.computedThrottleAxis = 0
            end

            -- call input events
            if spec.computedThrottleAxis > 0 then
                Drivable.actionEventBrake(self, nil, 0, nil, nil)
                Drivable.actionEventAccelerate(self, nil, spec.computedThrottleAxis, nil, nil)
            end

            if spec.computedThrottleAxis <= 0 then
                Drivable.actionEventBrake(self, nil, math.abs(spec.computedThrottleAxis), nil, nil)
                Drivable.actionEventAccelerate(self, nil, 0, nil, nil)
            end

            Drivable.actionEventSteer(self, nil, spec.computedSteerAxis, nil, true, nil, InputDevice.CATEGORY.GAMEPAD)

            -- update hud
            if MouseDriving.SHOW_HUD then
                MouseDriving.hud:setAxisData(spec.computedSteerAxis, spec.computedThrottleAxis)
                MouseDriving.hud:update(dt)
            end
        end
    end
end

function MouseDriving:onDraw()
    local spec = self.spec_mouseDriving
    if self:getIsEntered() and spec.enabled and MouseDriving.SHOW_HUD then
        MouseDriving.hud:render()
    end
end

function MouseDriving:onRegisterActionEvents(_, _)
    local spec = self.spec_mouseDriving
    if self:getIsEntered() then
        self:clearActionEventsTable(spec.actionEvents)
        if self:getIsActiveForInput(true, true) then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.MD_TOGGLE, self, MouseDriving.onToggleMouseDriving, false, true, false, true)
            g_inputBinding:setActionEventTextVisibility(actionEventId, false)
            _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.MD_PAUSE, self, MouseDriving.onPauseMouseDriving, true, true, false, true)
            g_inputBinding:setActionEventTextVisibility(actionEventId, false)
        --_, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.MD_AXIS_UPDOWN, self, MouseDriving.onAxisUpDown, false, false, true, true, nil, true)
        --g_inputBinding:setActionEventTextVisibility(actionEventId, false)
        --_, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.MD_AXIS_LEFTRIGHT, self, MouseDriving.onAxisLeftRight, true, true, true, true, nil, true)
        --g_inputBinding:setActionEventTextVisibility(actionEventId, false)
        end
    end
end

function MouseDriving:toggleMouseDriving(enabled)
    local spec = self.spec_mouseDriving
    spec.enabled = enabled
    self:resetMouseDriving()
end

function MouseDriving:resetMouseDriving()
    local spec = self.spec_mouseDriving
    spec.realSteerAxis = 0
    spec.computedSteerAxis = 0
    spec.realThrottleAxis = 0
    spec.computedThrottleAxis = 0
end

function MouseDriving.onToggleMouseDriving(self, actionName, inputValue, callbackState, isAnalog, isMouse)
    local spec = self.spec_mouseDriving
    self:toggleMouseDriving(not spec.enabled)
end

function MouseDriving.onPauseMouseDriving(self, actionName, inputValue, callbackState, isAnalog, isMouse)
    local spec = self.spec_mouseDriving
    if spec.enabled then
        spec.paused = inputValue == 1
    end
end

--function MouseDriving.onAxisUpDown(self, actionName, inputValue, callbackState, isAnalog, isMouse)
--    print(tostring(inputValue))
--    if MouseDriving.THROTTLE_ENABLED then
--        local spec = self.spec_mouseDriving
--        spec.realThrottleAxis = Utility.clamp(-1 - MouseDriving.THROTTLE_DEADZONE, spec.realThrottleAxis + (inputValue * MouseDriving.THROTTLE_SENSITIVITY * MouseDriving.THROTTLE_INVERTED), 1 + MouseDriving.THROTTLE_DEADZONE)
--    end
--end
--
--function MouseDriving.onAxisLeftRight(self, actionName, inputValue, callbackState, isAnalog, isMouse)
--    print(tostring(inputValue))
--    if MouseDriving.STEER_ENABLED then
--        local spec = self.spec_mouseDriving
--        spec.realSteerAxis = Utility.clamp(-1 - MouseDriving.STEER_DEADZONE, spec.realSteerAxis + (inputValue * MouseDriving.STEER_SENSITIVITY), 1 + MouseDriving.STEER_DEADZONE)
--    end
--end

function MouseDriving.onSettingsChangedEvent(self)
    self:resetMouseDriving()
end
