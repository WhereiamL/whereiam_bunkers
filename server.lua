RegisterServerEvent("buythebunker")
AddEventHandler("buythebunker", function(price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local money = xPlayer.getAccount('money').money
    MySQL.scalar('SELECT owner FROM bunkers WHERE owner = ?', {xPlayer.identifier}, function(ima)
        if not ima then
            if money >= price then
                MySQL.insert('INSERT INTO bunkers (owner) VALUES (@owner)', { ['@owner'] = xPlayer.identifier}, function(id)
                    xPlayer.removeAccountMoney('money', price)
                    TriggerClientEvent('esx:showNotification', src, Shared.Locale.successBought.. " " ..price)
                end)
            else
                TriggerClientEvent('esx:showNotification', src, Shared.Locale.noMoney.. " " ..price)
            end
        else
            TriggerClientEvent('esx:showNotification', src, Shared.Locale.alreadyHas)
        end
    end)
end)


ESX.RegisterServerCallback("isOwner", function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.scalar('SELECT owner FROM bunkers WHERE owner = ?', {xPlayer.identifier}, function(ima)
        if ima then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent("sellit")
AddEventHandler("sellit", function(price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.scalar('SELECT owner FROM bunkers WHERE owner = ?', {xPlayer.identifier}, function(ima)
        if ima then
            MySQL.Async.execute("DELETE FROM bunkers WHERE owner like @owner", { ['@owner'] = xPlayer.identifier }, function(done)
                if done then
                    xPlayer.addAccountMoney('money', price)
                    TriggerClientEvent('esx:showNotification', src, soldFor.. "" ..price)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', src, sellErorr)
        end
    end)
end)

RegisterServerEvent("enterTheBunker")
AddEventHandler("enterTheBunker", function(args)
    local src = source
    SetPlayerRoutingBucket(src, args.playerId)
    TriggerClientEvent("enterTheBunkerClient", src, args.id)
end)

RegisterServerEvent("leaveTheBunker")
AddEventHandler("leaveTheBunker", function()
    local src = source
    SetPlayerRoutingBucket(src, 0)
    TriggerClientEvent("leaveTheBunkerClient", src)
end)


RegisterServerEvent("openStash:bunker")
AddEventHandler("openStash:bunker", function()
    local src = source
    local name = GetPlayerName(src)
    exports.ox_inventory:RegisterStash(name, "Bunker Stash", Shared.StashSlots, Shared.StashSize)
    TriggerClientEvent('openStash:bunker2', src, name)
end)

ESX.RegisterServerCallback('getPlayerDressing', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local count  = store.count('dressing')
        local labels = {}

        for i = 1, count, 1 do
            local entry = store.get('dressing', i)
            table.insert(labels, entry.label)
        end
        cb(labels)
    end)
end)

ESX.RegisterServerCallback('getPlayerOutfit', function(source, cb, num)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local outfit = store.get('dressing', num)
        cb(outfit.skin)
    end)
end)


RegisterServerEvent('clothingRemoveIt')
AddEventHandler('clothingRemoveIt', function(label)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local dressing = store.get('dressing') or {}

        table.remove(dressing, label)
        store.set('dressing', dressing)
    end)
end)

