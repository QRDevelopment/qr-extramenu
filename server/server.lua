-- Initialize framework based on config
local Framework = nil

-- Load config from shared file
local Config = _G.Config

if Config.Framework == 'qbcore' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' or Config.Framework == 'esxold' then
    if Config.Framework == 'esxold' then
        TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
    else
        Framework = exports['es_extended']:getSharedObject()
    end
end

-- Server-side job verification callback
if Config.Framework == 'qbcore' then
    Framework.Functions.CreateCallback('qr-extramenu:checkJobPermission', function(source, cb)
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            local job = Player.PlayerData.job.name
            cb(Config.AllowedJobs[job] ~= nil)
        else
            cb(false)
        end
    end)
else
    -- ESX version of the callback
    Framework.RegisterServerCallback('qr-extramenu:checkJobPermission', function(source, cb)
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            local job = xPlayer.job.name
            cb(Config.AllowedJobs[job] ~= nil)
        else
            cb(false)
        end
    end)
end

-- Centralized vehicle modification event
RegisterServerEvent('qr-extramenu:modifyVehicle')
AddEventHandler('qr-extramenu:modifyVehicle', function(modificationType, modificationData)
    local src = source
    local Player = nil
    local playerName = ''
    local jobName = ''

    if Config.Framework == 'qbcore' then
        Player = Framework.Functions.GetPlayer(src)
        if Player then
            playerName = Player.PlayerData.name
            jobName = Player.PlayerData.job.name
        end
    else
        Player = Framework.GetPlayerFromId(src)
        if Player then
            playerName = Player.getName()
            jobName = Player.job.name
        end
    end

    if Player then
        print(string.format("[QR-ExtraMenu] Player %s (Job: %s) performed %s modification",
            playerName,
            jobName,
            modificationType
        ))
    end
end)

-- Reset vehicle event
RegisterServerEvent('qr-extramenu:resetVehicle')
AddEventHandler('qr-extramenu:resetVehicle', function(resetType)
    local src = source
    local Player = nil

    if Config.Framework == 'qbcore' then
        Player = Framework.Functions.GetPlayer(src)
    else
        Player = Framework.GetPlayerFromId(src)
    end

    if Player then
        local playerName = Config.Framework == 'qbcore' and Player.PlayerData.name or Player.getName()
        local jobName = Config.Framework == 'qbcore' and Player.PlayerData.job.name or Player.job.name

        print(string.format("[QR-ExtraMenu] Player %s (Job: %s) reset vehicle - Type: %s",
            playerName,
            jobName,
            resetType
        ))
    end
end)
