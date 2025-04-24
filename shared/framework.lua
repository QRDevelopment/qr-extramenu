Framework = {}

local function LoadQBCore()
    local QBCore = exports['qb-core']:GetCoreObject()

    Framework.GetPlayerData = function()
        return QBCore.Functions.GetPlayerData()
    end

    Framework.Notify = function(msg, type)
        return QBCore.Functions.Notify(msg, type)
    end

    return true
end

local function LoadESX()
    local ESX = exports['es_extended']:getSharedObject()

    Framework.GetPlayerData = function()
        return ESX.GetPlayerData()
    end

    Framework.Notify = function(msg, type)
        ESX.ShowNotification(msg)
    end

    return true
end

local function LoadESXOld()
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

    return true
end

function Framework.Load()
    local loaded = false

    if Config.Framework == 'qbcore' then
        loaded = LoadQBCore()
    elseif Config.Framework == 'esx' then
        loaded = LoadESX()
    elseif Config.Framework == 'esxold' then
        loaded = LoadESXOld()
    end

    if not loaded then
        print('Failed to load framework: ' .. Config.Framework)
        return false
    end

    return true
end

return Framework
