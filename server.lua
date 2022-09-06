RegisterServerEvent("buythebunker")
AddEventHandler("buythebunker", function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = xPlayer.getAccount('money').money
    MySQL.scalar('SELECT owner FROM bunkers WHERE owner = ?', {xPlayer.identifier}, function(ima)
        if not ima then
            if money >= price then
                MySQL.insert('INSERT INTO bunkers (owner) VALUES (@owner)', { ['@owner'] = xPlayer.identifier}, function(id)
                    xPlayer.removeAccountMoney('money', price)
                    TriggerClientEvent('esx:showNotification', source, Shared.Locale.successBought.. " " ..price)
                end)
            else
                TriggerClientEvent('esx:showNotification', source, Shared.Locale.noMoney.. " " ..price)
            end
        else
            TriggerClientEvent('esx:showNotification', source, Shared.Locale.alreadyHas)
        end
    end)
end)



lib.callback.register("isOwner", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rez =  MySQL.query.await('SELECT owner FROM bunkers WHERE owner = ?', { xPlayer.identifier })
    for i=1, #rez do
        local v = rez[i]
        if v.owner == xPlayer.identifier then 
            return true 
        end
    end
end)

RegisterServerEvent("sellit")
AddEventHandler("sellit", function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.scalar('SELECT owner FROM bunkers WHERE owner = ?', {xPlayer.identifier}, function(ima)
        if ima then
            MySQL.Async.execute("DELETE FROM bunkers WHERE owner like @owner", { ['@owner'] = xPlayer.identifier }, function(done)
                if done then
                    xPlayer.addAccountMoney('money', price)
                    TriggerClientEvent('esx:showNotification', source, Shared.Locale.soldFor.. "" ..price)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, Shared.Locale.sellErorr)
        end
    end)
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
    local source = source
    local val = promise.new()
    local xPlayer = ESX.GetPlayerFromId(source)
    local labels = {}
    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local count  = store.count('dressing')
        for i = 1, count, 1 do
            local entry = store.get('dressing', i)
            labels[#labels+1] = entry.label
            val:resolve(labels)
        end
    end)
    return Citizen.Await(val)
end)


lib.callback.register('getPlayerOutfit', function(source, num)
    local retval = promise.new()
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local outfit = store.get('dressing', num)
        retval:resolve(outfit.skin)
    end)
    return Citizen.Await(retval)
end)



RegisterServerEvent('clothingRemoveIt')
AddEventHandler('clothingRemoveIt', function(label)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local dressing = store.get('dressing') or {}

        table.remove(dressing, label)
        store.set('dressing', dressing)
    end)
end)
