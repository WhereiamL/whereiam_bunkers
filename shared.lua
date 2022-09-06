Shared = {}
Shared.LockerRoom = "esx" --//ox is ox_appearance , esx is standard esx locker room

Shared.DrawDistance = 10
Shared.StashSize = 500000
Shared.StashSlots = 70
Shared.Locale = {
    bunker = "[E] - To open bunker settings",
    leave = "[E] - To leave your bunker",
    stash = "[E] - To open your bunker stash",
    wardrobe = "[E] - To open your wardrobe",
    alreadyHas = "You already own one bunker !",
    successBought = "You bought the bunker succesfully for : ",
    noMoney = "You don't have enought money : ",
    sellErorr = "You seem like not to own any bunker but you still try to sell it ? hmm",
    soldFor = "You successfully sold the bunker for : ",
    ChoseClothing = "Chose clothing",
    RemoveClothing = "Remove clothing",
    SaveClothing = "Save clothing",
    SaveCurrentClothing = "Save current clothing",
}



Shared.bunkers = {
    {
        position = vector3(-3158.24, 1371.72, 16.92),
        insideCoords = vector3(892.6384, -3245.8664, -98.2645),
        exitCoords = vector3(894.48, -3245.8, -98.24),
        stashCoords = vector3(835.24, -3244.52, -98.68),
        lockerRoom = vector3(831.56, -3243.12, -98.68),
        name = "Dangerous Bunker",
        price = 100000
    },
    --[[ Template ]]
--[[     {
        position = vector3(-3158.24, 1371.72, 16.92), --Position to enter
        insideCoords = vector3(892.6384, -3245.8664, -98.2645), --Position where he will ported
        exitCoords = vector3(894.48, -3245.8, -98.24), --exit coords from the bunkler
        stashCoords = vector3(835.24, -3244.52, -98.68), --stash coords
        lockerRoom = vector3(831.56, -3243.12, -98.68), --locker room coords
        name = "Dangerous Bunker", --name of the bunker
        price = 100000 --price of the bunker
    }, ]]
}