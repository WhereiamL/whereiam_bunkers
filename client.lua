local lastPoz = {}

CreateThread(function()
    while true do
        local bunkers = Shared.bunkers
        sleep = 1000
        for i=1, #bunkers do

            local playerCoords = GetEntityCoords(cache.ped)
            local bunker = bunkers[i].position
            local bunkerName = bunkers[i].name
            local price = bunkers[i].price

            local idBunkera = bunkers[i].insideCoords
            local exitCoords = bunkers[i].exitCoords
            local stashCoords = bunkers[i].stashCoords
            local lockerRoom2 = bunkers[i].lockerRoom

            local distance = #(playerCoords - bunker)
            local distance2 = #(playerCoords - exitCoords)
            local distance3 = #(playerCoords - stashCoords)
            local distance4 = #(playerCoords - lockerRoom2)


            if distance <= 10 then
                sleep = 0
                DrawMarker(2, bunker.x, bunker.y, bunker.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255,  0,  5, 100, false, true, 2, true, false, false, false)
                if distance <= 2 then
                    sleep = 0
                    lib.showTextUI(Shared.Locale.buy)
                    if IsControlJustPressed(0, 38) then
                        ESX.TriggerServerCallback("isOwner", function(owner)
                            if owner then
                                lib.registerContext({
                                    id = 'ownerMenu',
                                    title = "Bunker - " ..bunkerName,
                                    options = {
                                        ["Enter your bunker"] = {
                                            serverEvent = 'enterTheBunker',
                                            args = {
                                                id = idBunkera,
                                                playerId = GetPlayerServerId(PlayerId()),
                                                currentPos = playerCoords
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
                                            event = 'previewin',
                                            args = idBunkera
                                        },
                                    }
                                })
                                lib.showContext('buyMenu')
                            end
                        end)
                    end
                else
                    lib.hideTextUI()
                end
            elseif distance2 <= 10 then
                sleep = 0
                DrawMarker(2, exitCoords.x, exitCoords.y, exitCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255,  0,  5, 100, false, true, 2, true, false, false, false)
                if distance2 <= 2 then
                    lib.showTextUI(Shared.Locale.leave)
                    sleep = 0
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent("leaveTheBunker")
                    end
                else
                    lib.hideTextUI()
                end
            elseif distance3 <= 10 then
                sleep = 0
                DrawMarker(2, stashCoords.x, stashCoords.y, stashCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255,  0,  5, 100, false, true, 2, true, false, false, false)
                DrawMarker(2, lockerRoom2.x, lockerRoom2.y, lockerRoom2.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255,  0,  5, 100, false, true, 2, true, false, false, false)
                if distance3 <= 2 then
                    sleep = 0
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent("openStash:bunker")
                    end
                end
                if distance4 <= 2 then
                    sleep = 0
                    lib.showTextUI(Shared.Locale.wardrobe)
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent("openLocker")
                        print("slash")
                    end
                else
                    lib.hideTextUI()
                end
                break
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("enterTheBunkerClient")
AddEventHandler("enterTheBunkerClient", function(bunker)
    lastPoz[#lastPoz+1] = GetEntityCoords(cache.ped)
    SetEntityCoords(cache.ped, bunker)
end)

RegisterNetEvent("leaveTheBunkerClient")
AddEventHandler("leaveTheBunkerClient", function()
    poz = table.unpack(lastPoz)
    SetEntityCoords(cache.ped,poz )
    lastPoz[#lastPoz+1] = nil
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
    ESX.TriggerServerCallback('getPlayerDressing', function(dressing)
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
end)

RegisterNetEvent("takeClothing")
AddEventHandler("takeClothing", function(v)
    TriggerEvent('skinchanger:getSkin', function(skin)
        ESX.TriggerServerCallback('getPlayerOutfit', function(clothes)
            TriggerEvent('skinchanger:loadClothes', skin, clothes)
            TriggerEvent('esx_skin:setLastSkin', skin)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
            end)
        end, v)
    end)
end)

AddEventHandler("removeClothing", function()
    ESX.TriggerServerCallback('getPlayerDressing', function(dressing)
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