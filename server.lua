RegisterServerEvent("buythebunker")
AddEventHandler("buythebunker", function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    ESX.TriggerServerCallback('isOwner', function(isOwner)
        if not isOwner then
            local money = xPlayer.getAccount('money').money

            if money >= price then
                MySQL.Async.execute('INSERT INTO bunkers (owner) VALUES (@owner)', {
                    ['@owner'] = identifier
                }, function()
                    xPlayer.removeAccountMoney('money', price)
                    local message = string.format(Shared.Locale.successBought, price)
                    TriggerClientEvent('esx:showNotification', source, message)
                end)
            else
                local message = string.format(Shared.Locale.noMoney, price)
                TriggerClientEvent('esx:showNotification', source, message)
            end
        else
            TriggerClientEvent('esx:showNotification', source, Shared.Locale.alreadyHas)
        end
    end, identifier)
end)


lib.callback.register("isOwner", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local result = MySQL.Sync.fetchScalar("SELECT owner FROM bunkers WHERE owner = @owner", {
        ['@owner'] = xPlayer.identifier
    })

    return result == xPlayer.identifier
end)

RegisterServerEvent("sellit")
AddEventHandler("sellit", function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    ESX.TriggerServerCallback('isOwner', function(isOwner)
        if isOwner then
            MySQL.Async.execute('DELETE FROM bunkers WHERE owner = @owner', {
                ['@owner'] = identifier
            }, function(rowsAffected)
                if rowsAffected > 0 then
                    xPlayer.addAccountMoney('money', price)
                    local message = string.format(Shared.Locale.soldFor, price)
                    TriggerClientEvent('esx:showNotification', source, message)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, Shared.Locale.sellErorr)
        end
    end, identifier)
end)

RegisterServerEvent("enterTheBunker")
AddEventHandler("enterTheBunker", function(args)
    local source = source
    SetPlayerRoutingBucket(source, args.playerId)
    TriggerClientEvent("enterTheBunkerClient", source, args.spawnCoords, args.type)
end)

RegisterServerEvent("leaveTheBunker")
AddEventHandler("leaveTheBunker", function()
    local source = source
    SetPlayerRoutingBucket(source, 0)
    TriggerClientEvent("leaveTheBunkerClient", source)
end)


RegisterServerEvent("openStash:bunker")
AddEventHandler("openStash:bunker", function()
    local source = source
    local name = GetPlayerName(source)
    exports.ox_inventory:RegisterStash(name, "Bunker Stash", Shared.StashSlots, Shared.StashSize)
    TriggerClientEvent('openStash:bunker2', source, name)
end)

lib.callback.register('getPlayerDressing', function(source)
    local val = promise.new()
    local xPlayer = ESX.GetPlayerFromId(source)
    local labels = {}

    ESX.TriggerServerCallback('esx_datastore:getDataStore', function(store)
        store.get('property', xPlayer.identifier, function(data)
            local count = data.count('dressing')
            for i = 1, count do
                local entry = data.get('dressing', i)
                labels[#labels + 1] = entry.label
            end
            val:resolve(labels)
        end)
    end)

    return Citizen.Await(Val)
end)


lib.callback.register('getPlayerOutfit', function(source, num)
    local retval = promise.new()
    local xPlayer = ESX.GetPlayerFromId(source)

    ESX.TriggerServerCallback('esx_datastore:getDataStore', function(store)
        store.get('property', xPlayer.identifier, function(data)
            local outfit = data.get('dressing', num)
            if outfit then
                retval:resolve(outfit.skin)
            else
                retval:reject('Outfit not found')
            end
        end)
    end)

    return Citizen.Await(retval)
end)

RegisterServerEvent('clothingRemoveIt')
AddEventHandler('clothingRemoveIt', function(label)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    ESX.TriggerServerCallback('esx_datastore:getDataStore', function(store)
        store.get('property', xPlayer.identifier, function(data)
            local dressing = data.get('dressing') or {}

            for i, outfit in ipairs(dressing) do
                if outfit.label == label then
                    table.remove(dressing, i)
                    break
                end
            end

            data.set('dressing', dressing)
        end)
    end)
end)

