--- Royal Mod

---@author Royal Modding
---@version 1.4.0.0
---@date 03/12/2020

--- Initialize RoyalMod
---@param rmodDirectory string
function InitRoyalMod(rmodDirectory)
    source(Utils.getFilename("RoyalMod.lua", rmodDirectory))
    --g_logManager:devInfo("Royal Mod loaded successfully by " .. g_currentModName)
    print("DevInfo: Royal Mod loaded successfully by " .. g_currentModName)
    --print("Teste: %s " .. 23)
    return true
end
