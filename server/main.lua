QBCore = exports['qb-core']:GetCoreObject()

local stolenDrugs = {}

function GetAvailableDrugs(source)
    local AvailableDrugs = {}
    local player = QBCore.Functions.GetPlayer(source)

    if not player then return nil end

    for k, v in pairs(Config.SellableDrugs) do
        local itemCount = exports.ox_inventory:Search(source, 'count', k)

        if itemCount > 0 then
            local itemInfo = exports.ox_inventory:GetItem(source, k)

            AvailableDrugs[#AvailableDrugs + 1] = {
                item = itemInfo.name,
                amount = itemCount,
                label = itemInfo.label
            }
        end
    end

    return table.type(AvailableDrugs) ~= 'empty' and AvailableDrugs or nil
end

RegisterNetEvent('cornerselling:server:ReturnStolenItems', function(stealData)
    local player = QBCore.Functions.GetPlayer(source)

    if not player or stolenDrugs == {} then 
        return 
    end

    for k, v in pairs(stolenDrugs) do
        if stealData.item.item == v.item and stealData.amount == v.amount then
            if exports.ox_inventory:CanCarryItem(source, v.item, v.amount) then
                exports.ox_inventory:AddItem(source, v.item, v.amount)
            end
            table.remove(stolenDrugs, k)
        end
    end
end)

RegisterNetEvent('cornerselling:server:SellDrugs', function(chosenDrugToSell, randomDrugAmount, randomDrugPrice)
    local player = QBCore.Functions.GetPlayer(source)
    local availableDrugs = GetAvailableDrugs(source)

    if not availableDrugs or not player then 
        return 
    end

    local hasItem = exports.ox_inventory:GetItem(source, chosenDrugToSell.item)

    if hasItem.count >= randomDrugAmount then
        lib.notify(source, {
            title = 'Accepted',
            description = "You accepted the offer",
            type = 'success'
        })
        if exports.ox_inventory:CanCarryItem(source, 'black_money', randomDrugPrice) then
            if exports.ox_inventory:RemoveItem(source, chosenDrugToSell.item, randomDrugAmount) then
                exports.ox_inventory:AddItem(source, 'black_money', randomDrugPrice)
            end
        end

        TriggerClientEvent('cornerselling:client:ToggleSellingState', source, true)
    end
end)

RegisterNetEvent('cornerselling:server:GetRobbed', function(chosenDrugToSell, randomDrugAmount)
    local player = QBCore.Functions.GetPlayer(source)

    if exports.ox_inventory:RemoveItem(source, chosenDrugToSell.item, randomDrugAmount) then
        table.insert(stolenDrugs, { 
            item = chosenDrugToSell.item, 
            amount = randomDrugAmount 
        })

        TriggerClientEvent('cornerselling:client:RefreshAvailableDrugs', source, GetAvailableDrugs(source))
    end
end)
