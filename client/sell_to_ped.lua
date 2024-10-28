function SellToPed(ped)
    local player = cache.ped
    hasTarget = true

    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            return
        end
    end

    local randomPoliceCallChance = math.random(1, 100)
    local randomGetScammedChance = math.random(1, 100)
    local randomGetRobbedChance = math.random(1, 100)

    local randomDrugKey = math.random(1, #availableDrugs)
    local chosenDrugToSell = availableDrugs[randomDrugKey]
    local randomDrugAmount = math.random(1, availableDrugs[randomDrugKey].amount)

    if randomDrugAmount > 15 then 
        randomDrugAmount = math.random(9, 15)
    end

    local drugValue = Config.SellableDrugs[chosenDrugToSell.item]
    local randomDrugPrice = math.random(drugValue.min, drugValue.max) * randomDrugAmount

    if randomGetScammedChance <= Config.CoreInfo.PercentChance.ToGetScammed then 
        randomDrugPrice = math.random(1, 2) * randomDrugAmount 
    end

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local playerCoords = GetEntityCoords(player, true)
    local pedCoords = GetEntityCoords(ped)
    local distanceToPed = #(playerCoords - pedCoords)

    if randomGetRobbedChance <= Config.CoreInfo.PercentChance.ToGetRobbed then
        TaskGoStraightToCoord(ped, playerCoords, 15.0, -1, 0.0, 0.0)
    else
        TaskGoStraightToCoord(ped, playerCoords, 1.2, -1, 0.0, 0.0)
    end

    while distanceToPed > 1.5 do
        playerCoords = GetEntityCoords(player, true)
        pedCoords = GetEntityCoords(ped)

        if randomGetRobbedChance <= Config.CoreInfo.PercentChance.ToGetRobbed then
            TaskGoStraightToCoord(ped, playerCoords, 15.0, -1, 0.0, 0.0)
        else
            TaskGoStraightToCoord(ped, playerCoords, 1.2, -1, 0.0, 0.0)
        end

        TaskGoStraightToCoord(ped, playerCoords, 1.2, -1, 0.0, 0.0)
        distanceToPed = #(playerCoords - pedCoords)
        local distanceBetweenPlayerAndPedAfterSaleStarts = Config.CoreInfo.Distance.BetweenPlayerAndPedAfterSaleStartsBeforeEndingSale

        if distanceToPed > distanceBetweenPlayerAndPedAfterSaleStarts then
            MovedTooFarAway()
            return
        end

        Wait(100)
    end

    TaskLookAtEntity(ped, player, 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, player, 5500)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT', 0, false)

    if hasTarget then
        if not cornerSelling then
            return
        end

        while distanceToPed < 2.0 and not IsPedDeadOrDying(ped) do
            local playerCoords2 = GetEntityCoords(player, true)
            local pedCoords2 = GetEntityCoords(ped)
            local pedDist2 = #(playerCoords2 - pedCoords2)

            if randomGetRobbedChance <= Config.CoreInfo.PercentChance.ToGetRobbed then
                ClearDrawOrigin()
                TriggerServerEvent('cornerselling:server:GetRobbed', chosenDrugToSell, randomDrugAmount)

                lib.notify({
                    title = 'Robbed',
                    description = "You got robbed of your "..chosenDrugToSell.label,
                    type = 'error'
                })

                stealingPed = ped
                stealData = {
                    item = chosenDrugToSell,
                    amount = randomDrugAmount,
                }
                hasTarget = false
                currentPedTryingToBuy = nil

                ClearPedTasksImmediately(ped)
                TaskSmartFleePed(ped, player, 500.0, -1)
                lastPed[#lastPed + 1] = ped
                RobberyPed()

                break
            else
                if pedDist2 < 1.5 and cornerSelling then
                    pedCoords = GetEntityCoords(ped)
                    DrawText3Ds(pedCoords.x, pedCoords.y, pedCoords.z+1, "[E] - Sell "..randomDrugAmount.."x "..chosenDrugToSell.label.." for $"..randomDrugPrice.." / [G] - Refuse sale")

                    if IsControlJustPressed(0, 38) then -- Press [E] to sell
                        ClearDrawOrigin()
                        if IsPedInAnyVehicle(player, false) then
                            lib.notify({
                                title = 'Unable',
                                description = "You can't sell drugs from a vehicle",
                                type = 'error'
                            })
                            hasTarget = false
                            SetPedKeepTask(ped, false)
                            SetEntityAsNoLongerNeeded(ped)
                            ClearPedTasksImmediately(ped)
                            lastPed[#lastPed + 1] = ped
                            currentPedTryingToBuy = nil

                            break
                        else
                            if lib.progressCircle({
                                lable = "Selling",
                                duration = 1500,
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    move = true,
                                    car = true,
                                    combat = true,
                                    mouse = false
                                },
                                anim = {
                                    dict = 'gestures@f@standing@casual',
                                    clip = 'gesture_point',
                                    flag = 49,
                                },
                            }) then
                                ClearDrawOrigin()

                                TriggerServerEvent('cornerselling:server:SellDrugs', chosenDrugToSell, randomDrugAmount, randomDrugPrice)
                                hasTarget = false
                                SetPedKeepTask(ped, false)
                                SetEntityAsNoLongerNeeded(ped)
                                ClearPedTasksImmediately(ped)
                                lastPed[#lastPed + 1] = ped
                                cornerSelling = false
                                currentPedTryingToBuy = nil
                                
                                if randomPoliceCallChance <= Config.CoreInfo.PercentChance.ToCallPolice then
                                    exports['ps-dispatch']:DrugSale()
                                end

                                break
                            else
                                ClearDrawOrigin()

                                hasTarget = false
                                SetPedKeepTask(ped, false)
                                SetEntityAsNoLongerNeeded(ped)
                                ClearPedTasksImmediately(ped)
                                lastPed[#lastPed + 1] = ped
                                cornerSelling = false
                                currentPedTryingToBuy = nil

                                lib.notify({
                                    title = "Canceled",
                                    description =  "You canceled the sale and stopped selling",
                                    type = "error"
                                })
                            end
                        end
                    end
                    if IsControlJustPressed(0, 47) then -- Press [G] to refuse
                        ClearDrawOrigin()

                        lib.notify({
                            title = 'Refused',
                            description = "You refused the offer and stopped selling",
                            type = 'inform'
                        })
                        hasTarget = false
                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        lastPed[#lastPed + 1] = ped
                        cornerSelling = false
                        currentPedTryingToBuy = nil

                        break
                    end
                end
            end
            Wait(0)
        end
        local randomWaitTimeBetweenSales = math.random(Config.CoreInfo.WaitTimeBetweenSalesInSeconds.min , Config.CoreInfo.WaitTimeBetweenSalesInSeconds.max)

        Wait((randomWaitTimeBetweenSales * 1000))
    end
end