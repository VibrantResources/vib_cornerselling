RegisterNetEvent('cornerselling:client:ToggleSellingState', function()
    if CheckIfPlayerIsInVehicle() then
        return
    end

    if not cornerSelling then
        availableDrugs = lib.callback.await('cornerselling:GetAvailableDrugs', false)

        if not availableDrugs then
            lib.notify({
                title = 'Unable',
                description = "You don't have anything to sell",
                type = 'error'
            })
            cornerSelling = false
            return
        end

        local startLocation = GetEntityCoords(cache.ped)
        cornerSelling = true

        lib.notify({
            title = "Selling",
            type = 'success'
        })
        
        TriggerEvent('cornerselling:client:KeepTrackOfDistance', startLocation)

        CreateThread(function()
            while cornerSelling do
                if CheckIfPlayerIsInVehicle() then
                    return
                end

                local player = cache.ped
                local playerCoords = GetEntityCoords(player)

                if not hasTarget then
                    local PlayerPeds = {}

                    if next(PlayerPeds) == nil then
                        for _, activePlayer in ipairs(GetActivePlayers()) do
                            local ped = GetPlayerPed(activePlayer)

                            PlayerPeds[#PlayerPeds + 1] = ped
                        end
                    end
                    local closestPed, closestDistance = QBCore.Functions.GetClosestPed(playerCoords, PlayerPeds)
                    local distanceBetweenPlayerAndFirstPed = Config.CoreInfo.Distance.BetweenPlayerAndPedForSaleToInitiate

                    if closestDistance < distanceBetweenPlayerAndFirstPed and closestPed ~= 0 and not IsPedInAnyVehicle(closestPed) and GetPedType(closestPed) ~= 28 then
                        if CheckIfPlayerIsInVehicle() then
                            return
                        end
                        currentPedTryingToBuy = closestPed
                        SellToPed(closestPed)

                        local randomWaitTimeBetweenSales = math.random(Config.CoreInfo.WaitTimeBetweenSalesInSeconds.min , Config.CoreInfo.WaitTimeBetweenSalesInSeconds.max)

                        Wait((randomWaitTimeBetweenSales * 1000))
                    end
                end
                
                Wait(0)
            end
        end)
    else
        stealingPed = nil
        stealData = {}
        cornerSelling = false
        availableDrugs = {}
        currentPedTryingToBuy = nil

        lib.notify({
            title = "Stopped",
            type = 'error'
        })
    end
end)