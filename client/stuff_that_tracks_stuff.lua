function CheckIfPlayerIsInVehicle()
    if IsPedInAnyVehicle(cache.ped, true) then
        lib.notify({
            title = 'Unable',
            description = "You can't sell drugs from a vehicle",
            type = 'error'
        })

        return true
    end

    return false
end

function MovedTooFarAway()
    lib.notify({
        title = 'Stopped',
        description = "You moved too far from your selling spot",
        type = 'error'
    })

    cornerSelling = false
    hasTarget = false
    availableDrugs = {}
    ClearDrawOrigin()
    lastPed[#lastPed + 1] = currentPedTryingToBuy
    
    SetEntityAsNoLongerNeeded(currentPedTryingToBuy)
    ClearPedTasksImmediately(currentPedTryingToBuy)

    currentPedTryingToBuy = nil
end

RegisterNetEvent('cornerselling:client:KeepTrackOfDistance', function(startLocation)
    CreateThread(function()
        while cornerSelling do
            local player = cache.ped
            local playerCoords = GetEntityCoords(player)
            local distanceFromStartLocation = #(startLocation - playerCoords)
            local distanceBeteenPlayerAndStart = Config.CoreInfo.Distance.BetweenPlayerAndStartLocationBeforeEndingSale

            if distanceFromStartLocation >= distanceBeteenPlayerAndStart then
                MovedTooFarAway()
                return
            end

            Wait(0)
        end
    end)
end)