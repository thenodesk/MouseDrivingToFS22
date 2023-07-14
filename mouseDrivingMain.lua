--- Mouse Driving

---@author Executor of Modding, n0tr3adY
---@version 1.0.0.0
---@date 04/02/2021

InitRoyalMod(Utils.getFilename("rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("utility/", g_currentModDirectory))
InitRoyalSettings(Utils.getFilename("rset/", g_currentModDirectory))
InitRoyalHud(Utils.getFilename("hud/", g_currentModDirectory))

---@class MouseDrivingMain : RoyalMod
MouseDrivingMain = RoyalMod.new(false, false)
MouseDrivingMain.settingsChangedEventListeners = {}
MouseDrivingMain.fillLevelsDisplay = nil
MouseDrivingMain.mouseYAxis = 0
MouseDrivingMain.mouseXAxis = 0

function MouseDrivingMain:initialize()
    Utility.overwrittenStaticFunction(VehicleCamera, "actionEventLookLeftRight", MouseDrivingMain.VehicleCamera_actionEventLookLeftRight)
    Utility.overwrittenStaticFunction(VehicleCamera, "actionEventLookUpDown", MouseDrivingMain.VehicleCamera_actionEventLookUpDown)
    Utility.overwrittenStaticFunction(FillLevelsDisplay, "new", MouseDrivingMain.FillLevelsDisplay_new)
end

function MouseDrivingMain:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
    addSpecializationBySpecialization("mouseDriving", "drivable")
end

function MouseDrivingMain:onLoad()
    g_royalSettings:registerMod(self.name, self.directory .. "settings_icon.dds", "$l10n_md_mod_settings_title")

    g_royalSettings:registerSetting(
        self.name,
        "throttle_enabled",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        1,
        {true, false},
        {"$l10n_ui_on", "$l10n_ui_off"},
        "$l10n_md_setting_throttle_enabled",
        "$l10n_md_setting_throttle_enabled_tooltip"
    ):addCallback(self.onThrottleEnabledChange, self)

    g_royalSettings:registerSetting(
        self.name,
        "throttle_deadZone",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        6,
        {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3},
        {"25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%", "250%", "300%"},
        "$l10n_md_setting_throttle_deadZone",
        "$l10n_md_setting_throttle_deadZone_tooltip"
    ):addCallback(self.onThrottleDeadZoneChange, self)

    g_royalSettings:registerSetting(
        self.name,
        "throttle_sensitivity",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        6,
        {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3},
        {"25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%", "250%", "300%"},
        "$l10n_md_setting_throttle_sensitivity",
        "$l10n_md_setting_throttle_sensitivity_tooltip"
    ):addCallback(self.onThrottleSensitivityChange, self)

    g_royalSettings:registerSetting(self.name, "throttle_invert", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 2, {1, -1}, {"$l10n_ui_on", "$l10n_ui_off"}, "$l10n_md_setting_throttle_invert", "$l10n_md_setting_throttle_invert_tooltip"):addCallback(
        self.onThrottleInvertChange,
        self
    )

    g_royalSettings:registerSetting(self.name, "steer_enabled", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 1, {true, false}, {"$l10n_ui_on", "$l10n_ui_off"}, "$l10n_md_setting_steer_enabled", "$l10n_md_setting_steer_enabled_tooltip"):addCallback(
        self.onSteerEnabledChange,
        self
    )

    g_royalSettings:registerSetting(
        self.name,
        "steer_deadZone",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        6,
        {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3},
        {"25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%", "250%", "300%"},
        "$l10n_md_setting_steer_deadZone",
        "$l10n_md_setting_steer_deadZone_tooltip"
    ):addCallback(self.onSteerDeadZoneChange, self)

    g_royalSettings:registerSetting(
        self.name,
        "steer_sensitivity",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        6,
        {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3},
        {"25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%", "250%", "300%"},
        "$l10n_md_setting_steer_sensitivity",
        "$l10n_md_setting_steer_sensitivity_tooltip"
    ):addCallback(self.onSteerSensitivityChange, self)

    g_royalSettings:registerSetting(self.name, "hud", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 1, {true, false}, {"$l10n_ui_on", "$l10n_ui_off"}, "$l10n_md_setting_hud", "$l10n_md_setting_hud_tooltip"):addCallback(
        self.onHudChange,
        self
    )
end

function MouseDrivingMain:onThrottleEnabledChange(value)
    MouseDriving.THROTTLE_ENABLED = value
    self:onSettingsChangedEvent()
end

function MouseDrivingMain:onThrottleDeadZoneChange(value)
    MouseDriving.THROTTLE_DEADZONE = MouseDriving.THROTTLE_BASE_DEADZONE * value
end

function MouseDrivingMain:onThrottleSensitivityChange(value)
    MouseDriving.THROTTLE_SENSITIVITY = MouseDriving.THROTTLE_BASE_SENSITIVITY * value
end

function MouseDrivingMain:onThrottleInvertChange(value)
    MouseDriving.THROTTLE_INVERTED = value
    self:onSettingsChangedEvent()
end

function MouseDrivingMain:onSteerEnabledChange(value)
    MouseDriving.STEER_ENABLED = value
    self:onSettingsChangedEvent()
end

function MouseDrivingMain:onSteerDeadZoneChange(value)
    MouseDriving.STEER_DEADZONE = MouseDriving.STEER_BASE_DEADZONE * value
end

function MouseDrivingMain:onSteerSensitivityChange(value)
    MouseDriving.STEER_SENSITIVITY = MouseDriving.STEER_BASE_SENSITIVITY * value
end

function MouseDrivingMain:onHudChange(value)
    MouseDriving.SHOW_HUD = value
end

function MouseDrivingMain:onSettingsChangedEvent()
    for object, event in pairs(MouseDrivingMain.settingsChangedEventListeners) do
        event(object)
    end
end

function MouseDrivingMain.VehicleCamera_actionEventLookUpDown(superFunc, camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    if not isMouse or camera == nil or camera.vehicle == nil or camera.vehicle.spec_mouseDriving == nil or not camera.vehicle.spec_mouseDriving.enabled or camera.vehicle.spec_mouseDriving.paused then
        superFunc(camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    elseif isMouse and MouseDriving.THROTTLE_ENABLED then
        MouseDrivingMain.mouseYAxis = inputValue
    end
end

function MouseDrivingMain.VehicleCamera_actionEventLookLeftRight(superFunc, camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    if not isMouse or camera == nil or camera.vehicle == nil or camera.vehicle.spec_mouseDriving == nil or not camera.vehicle.spec_mouseDriving.enabled or camera.vehicle.spec_mouseDriving.paused then
        superFunc(camera, actionName, inputValue, callbackState, isAnalog, isMouse)
    elseif isMouse and MouseDriving.STEER_ENABLED then
        MouseDrivingMain.mouseXAxis = inputValue
    end
end

function MouseDrivingMain.FillLevelsDisplay_new(superFunc, hudAtlasPath)
    local instance = superFunc(hudAtlasPath)
    MouseDrivingMain.fillLevelsDisplay = instance
    return instance
end

---@param object table
---@param event function
function MouseDrivingMain:addSettingsChangedEventListener(object, event)
    MouseDrivingMain.settingsChangedEventListeners[object] = event
end

---@param object table
function MouseDrivingMain:removeSettingsChangedEventListener(object)
    MouseDrivingMain.settingsChangedEventListeners[object] = nil
end
