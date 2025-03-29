-- Made by Qycko, brought to you by QR
Config = {}

-- Framework Selection (qbcore, for qbx users use qbcore, esx, esxold)
Config.Framework = 'qbcore'

-- Interaction Locations
Config.Locations = {
    {
        coords = vector3(447.73, -975.64, 25.7),  -- LSPD Garage
        markerType = 27,
        markerColor = {r = 45, g = 76, b = 139, a = 125},
        markerScale = vector3(1.5, 1.5, 1.0)
    },
    {
        coords = vector3(-448.67, 6008.09, 31.72),  -- Paleto Bay Sheriff
        markerType = 27,
        markerColor = {r = 0, g = 255, b = 0, a = 125},
        markerScale = vector3(1.5, 1.5, 1.0)
    }
}

-- Marker Settings
Config.DrawDistance = 10.0
Config.InteractDistance = 1.5

-- Allowed Jobs (ensure exact match)
Config.AllowedJobs = {
    'police',    -- Ensure this matches exactly with job name
    'sheriff'
}

-- Notification Settings
Config.Notifications = {
    ['no_permission'] = 'You do not have permission to use this menu',
    ['vehicle_washed'] = 'Vehicle washed successfully',
    ['vehicle_wash_cancelled'] = 'Vehicle wash cancelled',
    ['vehicle_repaired'] = 'Vehicle repaired successfully',
    ['vehicle_repair_cancelled'] = 'Vehicle repair cancelled'
}

function GetConfig()
    return Config
end

_G.Config = Config
