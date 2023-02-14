local lastPoz = {}
local visitor = false

CreateThread(function()
    local bunkers = Shared.bunkers
    for i=1, #bunkers do
        local bunker = bunkers[i]
        local spawnCoords = bunker.insideCoords
        local bunkerName = bunker.name
        local price = bunker.price
        local table = {
            bunkerEntrance = bunker.position,
            exitCoords = bunker.exitCoords,
            stashCoords = bunker.stashCoords,
            lockerRoom = bunker.lockerRoom,
        }
        for _,v in pairs(table) do
            local poFirst = lib.points.new(v, 8, {})
            function poFirst:nearby()
                DrawMarker(2, v, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 200, 20, 20, 50, false, true, 2, nil, nil, false)
                if self.currentDistance  < 2.0 then
                    if v == table.bunkerEntrance then 
                        lib.showTextUI(Shared.Locale.bunker)
                        if IsControlJustPressed(0, 38) then
                            self.owner = lib.callback.await('isOwner', false)
                            if self.owner then
                                lib.registerContext({
                                    id = 'ownerMenu',
                                    title = "Bunker - " ..bunkerName,
                                    options = {
                                        ["Enter your bunker"] = {
                                            serverEvent = 'enterTheBunker',
                                            args = {
                                                spawnCoords = spawnCoords, 
                                                playerId = GetPlayerServerId(PlayerId()),
                                                type = "owner"
                                            }
                                        },
                                        ["Sell your bunker"] = {
                                            serverEvent = 'sellit',
                                            args = price
                                        },
                                    }
                                })
                                lib.showContext('ownerMenu')
                            else
                                lib.registerContext({
                                    id = 'buyMenu',
                                    title = "Bunker - " ..bunkerName,
                                    options = {
                                        ["Buy the bunker for " ..price.. " $"] = {
                                            serverEvent = 'buythebunker',
                                            args = price
                                        },
                                        ["Preview the bunker"] = {
                                            serverEvent = 'enterTheBunker',
                                            visitor = true,
                                            args = {spawnCoords = spawnCoords, playerId = GetPlayerServerId(PlayerId()), type = "preview" }
                                        },
                                    }
                                })
                                lib.showContext('buyMenu')
                            end
                        end
                    elseif v == table.exitCoords then
                        lib.showTextUI(Shared.Locale.leave)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent("leaveTheBunker")
                        end
                    elseif v == table.stashCoords and not visitor then
                        lib.showTextUI(Shared.Locale.stash)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent("openStash:bunker")
                        end
                    elseif v == table.lockerRoom and not visitor  then
                        lib.showTextUI(Shared.Locale.wardrobe)
                        if IsControlJustPressed(0, 38) then
                            TriggerEvent("openLocker")
                        end
                    end
                end
                function poFirst:onExit()
                    lib.hideTextUI()
                end
            end
        end
    end
end)

RegisterNetEvent("enterTheBunkerClient")
AddEventHandler("enterTheBunkerClient", function(bunker, type)
    if type == "owner" then 
        lastPoz[#lastPoz+1] = GetEntityCoords(cache.ped)
        visitor = false
        SetEntityCoords(cache.ped, bunker)
    elseif type == "preview" then 
        visitor = true
        lastPoz[#lastPoz+1] = GetEntityCoords(cache.ped)
        SetEntityCoords(cache.ped, bunker)
    end
end)

RegisterNetEvent("leaveTheBunkerClient")
AddEventHandler("leaveTheBunkerClient", function()
    poz = table.unpack(lastPoz)
    if poz ~= nil then
        SetEntityCoords(cache.ped,poz)
        lastPoz[#lastPoz+1] = nil
    else
        SetEntityCoords(Shared.bunkers.position)
    end
end)

RegisterNetEvent("openStash:bunker2")
AddEventHandler("openStash:bunker2", function(name)
    TriggerEvent('ox_inventory:openInventory', 'stash', name)
end)

AddEventHandler("openLocker", function()
    if Shared.LockerRoom == "ox" then
        TriggerEvent("ox_appearance:wardrobe")
    elseif Shared.LockerRoom == "esx" then
        lib.registerContext({
            id = 'clothingMain',
            title = "Clothing",
            options = {
                [Shared.Locale.ChoseClothing] = {
                    event = 'openClotihg',
                    arrow = true,
                },
                [Shared.Locale.RemoveClothing] = {
                    event = 'removeClothing',
                    arrow = true,
                },
                [Shared.Locale.SaveClothing] = {
                    event = 'saveMenu',
                    arrow = true,
                },
            }
        })
        lib.showContext('clothingMain')
    else
        print("not valid")
    end
end)


AddEventHandler("openClotihg", function()
    local dressing = lib.callback.await('getPlayerDressing', false)
    local table = dressing
    local options = {}
    for k,v in pairs(table) do
        options[k] = {
            title = v,
            icon = "fa-regular fa-hand-pointer",
            description = 'Click to take dressing',
            event = "takeClothing",
            args = k
        }
    end
    lib.registerContext({
        id = 'clothing',
        title = 'Saved clothes',
        options = options,
        menu = "clothingMain"
    })
    lib.showContext('clothing')
end)


RegisterNetEvent("takeClothing")
AddEventHandler("takeClothing", function(v)
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothes = lib.callback.await('getPlayerOutfit', false, v)
        TriggerEvent('skinchanger:loadClothes', skin, clothes)
        TriggerEvent('esx_skin:setLastSkin', skin)
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_skin:save', skin)
        end)
    end)
end)

AddEventHandler("removeClothing", function()
    local dressing = lib.callback.await('getPlayerDressing', false)
    local table = dressing
    local options = {}
    for k,v in pairs(table) do
        options[k] = {
            title = v,
            icon = "fa-regular fa-hand-pointer",
            description = 'Click to remove clothing',
            serverEvent = "clothingRemoveIt",
            args = k
        }
    end
    lib.registerContext({
        id = 'clothingRemove',
        title = 'Remove clothes',
        options = options,
        menu = "clothingMain"
    })
    lib.showContext('clothingRemove')
end)

AddEventHandler("saveMenu", function()
    lib.registerContext({
        id = 'saveMenuOption',
        title = "Clothing Save",
        options = {
            [Shared.Locale.SaveCurrentClothing] = {
                event = 'saveCurrentClothing',
                arrow = true,
            },
        }
    })
    lib.showContext('saveMenuOption')
end)

AddEventHandler("saveCurrentClothing", function()
    local input = lib.inputDialog('Save menu', {'Name of the outfit'})
    if input then
        local name = input[1]
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_clotheshop:saveOutfit', name, skin)
            ESX.ShowNotification("Outfit " .. name .. " saved!")
        end)
    end
end)


CreateThread(function()
    local bunkers = Shared.bunkers
    for i = 1, #bunkers do
    	local blip = AddBlipForCoord(bunkers[i].position)
        SetBlipSprite(blip, 557)
        SetBlipScale(blip, 0.9)
        SetBlipColour(blip, 34)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(bunkers[i].name)
        EndTextCommandSetBlipName(blip)
        SetBlipCategory(blip, 11)
    end
end)
