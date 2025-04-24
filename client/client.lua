local Framework = {}

local Config = _G.Config

local function LoadFramework()
    if Config.Framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        Framework.GetPlayerData = function()
            return QBCore.Functions.GetPlayerData()
        end
        Framework.Notify = function(msg, type)
            return QBCore.Functions.Notify(msg, type)
        end
    elseif Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        Framework.GetPlayerData = function()
            return ESX.GetPlayerData()
        end
        Framework.Notify = function(msg, type)
            ESX.ShowNotification(msg)
        end
    elseif Config.Framework == 'esxold' then
        local ESX = nil
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Framework.GetPlayerData = function()
            return ESX.GetPlayerData()
        end
        Framework.Notify = function(msg, type)
            ESX.ShowNotification(msg)
        end
    end
    return true
end

if not LoadFramework() then
    print('Failed to load framework: ' .. Config.Framework)
    return
end

local function Debug(message, ...)
    local args = {...}
    local formattedMsg = string.format(message, table.unpack(args))
    print("^2[QR-DEBUG]^7 " .. formattedMsg)
end

local function HasPermission(jobName)
    Debug("Checking job permission for: %s", tostring(jobName))
    for _, allowedJob in ipairs(Config.AllowedJobs) do
        if jobName == allowedJob then
            return true
        end
    end
    return false
end

local function IsPlayerNearLocation(playerCoords, location)
    return #(playerCoords - location.coords) <= Config.InteractDistance
end

local currentInteractionLocation = nil
local isMenuOpen = false
local frozenVehicle = nil


local function ForceVehicleUpdate(vehicle)
    if vehicle and vehicle ~= 0 then
        SetVehicleModKit(vehicle, 0)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)


        local pos = GetEntityCoords(vehicle)
        SetEntityCoords(vehicle, pos.x, pos.y, pos.z + 0.001, false, false, false, false)

        SetVehicleModKit(vehicle, 0)
        local livery = GetVehicleMod(vehicle, 48)
        SetVehicleMod(vehicle, 48, livery, false)
    end
end

RegisterNUICallback('setCallsignNumbers', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleModKit(vehicle, 0)

        -- Set the mod slots for callsign numbers
        SetVehicleMod(vehicle, 8, data.number1, false)
        SetVehicleMod(vehicle, 9, data.number2, false)
        SetVehicleMod(vehicle, 10, data.number3, false)

        -- Create string representation for display
        local callsignText = ""
        if data.number1 >= 0 then callsignText = callsignText .. data.number1 end
        if data.number2 >= 0 then callsignText = callsignText .. data.number2 end
        if data.number3 >= 0 then callsignText = callsignText .. data.number3 end

        ForceVehicleUpdate(vehicle)
        Framework.Notify("Callsign set to: " .. callsignText, 'success')

        -- Notify server of change
        TriggerServerEvent('qr-extramenu:modifyVehicle', 'callsign', {
            callsign = callsignText,
            callsignNumbers = {data.number1, data.number2, data.number3}
        })
    end
    cb('ok')
end)

RegisterNUICallback('clearCallsignNumbers', function(_, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleModKit(vehicle, 0)

        -- Clear the mod slots
        SetVehicleMod(vehicle, 8, -1, false)
        SetVehicleMod(vehicle, 9, -1, false)
        SetVehicleMod(vehicle, 10, -1, false)

        ForceVehicleUpdate(vehicle)
        Framework.Notify("Callsign removed", 'success')

        -- Notify server of change
        TriggerServerEvent('qr-extramenu:modifyVehicle', 'callsign', {
            callsign = "",
            callsignNumbers = {-1, -1, -1}
        })
    end
    cb('ok')
end)

local function getCurrentCallsignNumbers(vehicle)
    if vehicle == 0 then return {-1, -1, -1} end

    SetVehicleModKit(vehicle, 0)

    return {
        GetVehicleMod(vehicle, 8),
        GetVehicleMod(vehicle, 9),
        GetVehicleMod(vehicle, 10)
    }
end

-- Function to get vehicle state
local function GetVehicleState(vehicle)
    if not vehicle or vehicle == 0 then return nil end

    Debug("Getting vehicle state for vehicle: %s", vehicle)

    -- Force vehicle update before getting state
    SetVehicleModKit(vehicle, 0)

    local state = {
        extras = {},
        colors = {},
        livery = {
            current = -1,
            count = 0,
            names = {},
            roof = {
                current = GetVehicleRoofLivery(vehicle),
                count = GetVehicleRoofLiveryCount(vehicle)
            }
        },
        windowTint = GetVehicleWindowTint(vehicle),
        callsignNumbers = getCurrentCallsignNumbers(vehicle)
    }

    -- Check for mod-based liveries first (mod slot 48)
    local modCount = GetNumVehicleMods(vehicle, 48)
    if modCount > 0 then
        state.livery.count = modCount + 1 -- Add 1 for the default livery
        state.livery.current = GetVehicleMod(vehicle, 48) + 1 -- Add 1 to match UI indexing

        -- Get livery names from mod slot 48
        for i = -1, modCount - 1 do
            local name = GetModTextLabel(vehicle, 48, i)
            if name and name ~= "" then
                state.livery.names[i + 2] = GetLabelText(name) -- Adjust index to start from 1
                if state.livery.names[i + 2] == "NULL" then
                    state.livery.names[i + 2] = "Livery " .. (i + 2)
                end
            else
                state.livery.names[i + 2] = "Livery " .. (i + 2)
            end
        end
        -- Set the first livery name (index 1) to "No Livery"
        state.livery.names[1] = "No Livery"
    else
        -- Fall back to traditional liveries if no mod-based liveries exist
        state.livery.count = GetVehicleLiveryCount(vehicle)
        if state.livery.count > 0 then
            state.livery.current = GetVehicleLivery(vehicle) + 1 -- Add 1 to match UI indexing

            -- Set the first livery name (index 1) to "No Livery"
            state.livery.names[1] = "No Livery"

            for i = 0, state.livery.count - 1 do
                local name = GetLiveryName(vehicle, i)
                if name and name ~= "" then
                    state.livery.names[i + 2] = name -- Adjust index to start from 2
                else
                    state.livery.names[i + 2] = "Livery " .. (i + 1)
                end
            end
        end
    end

    Debug("Livery count: %s, Current livery: %s", state.livery.count, state.livery.current)

    -- Get extras
    for i = 1, 12 do
        if DoesExtraExist(vehicle, i) then
            state.extras[i] = IsVehicleExtraTurnedOn(vehicle, i)
        end
    end

    -- Get colors
    local primaryColor, secondaryColor = GetVehicleColours(vehicle)
    state.colors = {
        primary = primaryColor,
        secondary = secondaryColor
    }

    return state
end

-- Function to freeze/unfreeze vehicle
local function SetVehicleFrozen(vehicle, frozen)
    if vehicle and vehicle ~= 0 then
        FreezeEntityPosition(vehicle, frozen)
        SetVehicleEngineOn(vehicle, not frozen, true, true)
    end
end

-- Draw Markers and Handle Interaction
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        local isNearLocation = false
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        -- Check if player is near any allowed location
        for _, location in ipairs(Config.Locations) do
            local distance = #(playerCoords - location.coords)

            if distance <= Config.DrawDistance then
                sleep = 0
                DrawMarker(
                    location.markerType,
                    location.coords.x,
                    location.coords.y,
                    location.coords.z - 0.98,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    location.markerScale.x,
                    location.markerScale.y,
                    location.markerScale.z,
                    location.markerColor.r,
                    location.markerColor.g,
                    location.markerColor.b,
                    location.markerColor.a,
                    false, true, 2, false, nil, nil, false
                )

                -- Check if player is within interaction distance and in a vehicle
                if distance <= Config.InteractDistance and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    isNearLocation = true
                    currentInteractionLocation = location
                    break
                end
            end
        end

        -- Check for 'E' key press when near location and in vehicle
        if isNearLocation and IsControlJustPressed(0, 38) and not isMenuOpen then  -- 38 is the key code for 'E'
            local player = Framework.GetPlayerData()

            if HasPermission(player.job.name) then
                -- Freeze vehicle
                SetVehicleFrozen(vehicle, true)
                frozenVehicle = vehicle

                -- Get vehicle state
                local vehicleState = GetVehicleState(vehicle)

                -- Open NUI with vehicle state
                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = 'openMenu',
                    vehicleState = vehicleState
                })
                isMenuOpen = true
            else
                Framework.Notify(Config.Notifications['no_permission'], 'error')
            end
        end

        Wait(sleep)
    end
end)

-- Handle ESC key to close menu
CreateThread(function()
    while true do
        Wait(0)
        if isMenuOpen and (IsControlJustPressed(0, 322) or IsControlJustPressed(0, 177)) then  -- 322 is ESC, 177 is BACKSPACE
            -- Force final update before unfreezing
            if frozenVehicle then
                ForceVehicleUpdate(frozenVehicle)
                SetVehicleFrozen(frozenVehicle, false)
                frozenVehicle = nil
            end

            SetNuiFocus(false, false)
            SendNUIMessage({type = 'closeMenu'})
            isMenuOpen = false
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    -- Force final update before unfreezing
    if frozenVehicle then
        ForceVehicleUpdate(frozenVehicle)
        SetVehicleFrozen(frozenVehicle, false)
        frozenVehicle = nil
    end

    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

RegisterNUICallback('setWindowTint', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local tintLevel = tonumber(data.tint)
        Debug("Setting window tint to: %s", tintLevel)

        -- Set the window tint
        SetVehicleWindowTint(vehicle, tintLevel)

        -- Force vehicle update
        ForceVehicleUpdate(vehicle)

        -- Verify window tint was set
        local currentTint = GetVehicleWindowTint(vehicle)
        Debug("Current window tint after setting: %s", currentTint)

        -- Notify server of the change
        TriggerServerEvent('qr-extramenu:modifyVehicle', 'windowTint', {
            tint = tintLevel
        })
    end
    cb('ok')
end)

RegisterNUICallback('toggleExtra', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleExtra(vehicle, tonumber(data.extra), not data.state)
        ForceVehicleUpdate(vehicle)
        TriggerServerEvent('qr-extramenu:modifyVehicle', 'extra', {
            extra = data.extra,
            state = not data.state
        })
    end
    cb('ok')
end)

RegisterNUICallback('removeAllExtras', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        for i = 1, 12 do
            if DoesExtraExist(vehicle, i) then
                SetVehicleExtra(vehicle, i, true)
            end
        end
        ForceVehicleUpdate(vehicle)
        TriggerServerEvent('qr-extramenu:resetVehicle', 'extras')
    end
    cb('ok')
end)

RegisterNUICallback("changeColor", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle then
        local colorType = data.type -- "primary" or "secondary"
        local colorIndex = tonumber(data.colorIndex)

        if colorType == "primary" then
            local _, sec = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, colorIndex, sec)
        elseif colorType == "secondary" then
            local pri, _ = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, pri, colorIndex)
        end
        ForceVehicleUpdate(vehicle)
    end
    cb("ok")
end)

RegisterNUICallback('resetColors', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        -- Set both primary and secondary colors to metallic black (0)
        SetVehicleColours(vehicle, 0, 0)
        ForceVehicleUpdate(vehicle)
        TriggerServerEvent('qr-extramenu:modifyVehicle', 'colors', {
            primary = 0,
            secondary = 0
        })
    end
    cb('ok')
end)

RegisterNUICallback('changeLivery', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local liveryIndex = tonumber(data.liveryIndex)

        Debug("Changing livery - Index: %s", liveryIndex)

        -- Try mod-based livery first (mod slot 48)
        if GetNumVehicleMods(vehicle, 48) > 1 then
            SetVehicleMod(vehicle, 48, liveryIndex - 1, false) -- Subtract 2 to convert from UI index to game index
            Debug("Set mod-based livery: %s", liveryIndex - 1)
        else
            -- Fall back to traditional livery
            SetVehicleLivery(vehicle, liveryIndex - 1) -- Subtract 2 to convert from UI index to game index
            Debug("Set traditional livery: %s", liveryIndex - 1)
        end

        -- Force vehicle update
        ForceVehicleUpdate(vehicle)

        TriggerServerEvent('qr-extramenu:modifyVehicle', 'livery', {
            liveryIndex = liveryIndex
        })
    end
    cb('ok')
end)

RegisterNUICallback('washVehicle', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        if lib then
            local washSuccess = false

            lib.progressBar({
                duration = 5000,
                label = 'Washing Vehicle',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    dict = 'timetable@maid@cleaning@base',
                    clip = 'base'
                },
                onStart = function()
                    washSuccess = false
                end,
                onComplete = function()
                    washSuccess = true
                    SetVehicleDirtLevel(vehicle, 0.0)
                    WashDecalsFromVehicle(vehicle, 0.0)
                    ForceVehicleUpdate(vehicle)
                    TriggerServerEvent('qr-extramenu:modifyVehicle', 'wash', {})
                    Framework.Notify(Config.Notifications['vehicle_washed'], 'success')
                end,
                onCancel = function()
                    washSuccess = false
                    Framework.Notify(Config.Notifications['vehicle_wash_cancelled'], 'error')
                end
            })
        else
            SetVehicleDirtLevel(vehicle, 0.0)
            WashDecalsFromVehicle(vehicle, 0.0)
            ForceVehicleUpdate(vehicle)
            TriggerServerEvent('qr-extramenu:modifyVehicle', 'wash', {})
            Framework.Notify(Config.Notifications['vehicle_washed'], 'success')
        end
    end
    cb('ok')
end)

RegisterNUICallback('fixVehicle', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        if lib then
            local repairSuccess = false

            lib.progressBar({
                duration = 7000,
                label = 'Repairing Vehicle',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    dict = 'mini@repair',
                    clip = 'fixing_a_player'
                },
                onStart = function()
                    repairSuccess = false
                end,
                onComplete = function()
                    repairSuccess = true
                    SetVehicleFixed(vehicle)
                    ForceVehicleUpdate(vehicle)
                    TriggerServerEvent('qr-extramenu:modifyVehicle', 'repair', {})
                    Framework.Notify(Config.Notifications['vehicle_repaired'], 'success')
                end,
                onCancel = function()
                    repairSuccess = false
                    Framework.Notify(Config.Notifications['vehicle_repair_cancelled'], 'error')
                end
            })
        else
            SetVehicleFixed(vehicle)
            ForceVehicleUpdate(vehicle)
            TriggerServerEvent('qr-extramenu:modifyVehicle', 'repair', {})
            Framework.Notify(Config.Notifications['vehicle_repaired'], 'success')
        end
    end
    cb('ok')
end)
