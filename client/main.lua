QBCore = exports['qb-core']:GetCoreObject()

-------------
--Variables--
-------------

cornerSelling = false
hasTarget = false
lastPed = {}
stealingPed = nil
stealData = {}
availableDrugs = {}
currentPedTryingToBuy = nil

function RobberyPed()
    CreateThread(function()
        while stealingPed do
            if IsEntityDead(stealingPed) then
                local player = cache.ped
                local playerCoords = GetEntityCoords(player)
                local stealPedCoords = GetEntityCoords(stealingPed)
                local distanceToStealingPed = #(playerCoords - stealPedCoords)

                if distanceToStealingPed < 1.5 then
                    DrawText3Ds(stealPedCoords.x, stealPedCoords.y, stealPedCoords.z+1, "[E] - Take back x"..stealData.amount.." "..stealData.item.label)

                    if IsControlJustReleased(0, 38) then
                        ClearDrawOrigin()
                        lib.requestAnimDict('pickup_object')

                        TaskPlayAnim(player, 'pickup_object', 'pickup_low', 8.0, -8.0, -1, 1, 0, false, false, false)
                        Wait(2000)
                        ClearPedTasks(player)
                        TriggerServerEvent('cornerselling:server:ReturnStolenItems', stealData)

                        stealingPed = nil
                        stealData = {}
                    end
                end
            else
                local player = cache.ped
                local playerCoords = GetEntityCoords(player)
                local stealPedCoords = GetEntityCoords(stealingPed)
                local distanceToStealingPed = #(playerCoords - stealPedCoords)

                if distanceToStealingPed > 75 then
                    stealingPed = nil
                    stealData = {}
                    break
                end
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('cornerselling:client:RefreshAvailableDrugs', function(drugs)
    availableDrugs = drugs

    if availableDrugs == nil or #availableDrugs <= 0 then
        lib.notify({
            title = 'Empty',
            description = "You don't have anything left to sell",
            type = 'error'
        })
        cornerSelling = false
    end
end)