local Config = {
    TextUI = 'ox_lib' -- ak chceš používať sk_textui, zmeň na 'sk_textui'
}

local cooldown = false
local currentProp = nil
local currentPropModel = nil
local currentPropHeading = 0
local isHoldingProp = false
local currentAnimDict = nil
local currentAnimName = nil
local currentItemName = nil

local function ShowTextUI(text)
    if Config.TextUI == 'sk_textui' then
        exports['sk_textui']:showTextUI(text)
    else
        lib.showTextUI(text)
    end
end

local function HideTextUI()
    if Config.TextUI == 'sk_textui' then
        exports['sk_textui']:hideTextUI()
    else
        lib.hideTextUI()
    end
end

local function Cooldown()
    if cooldown then
        ShowNotification('Nemôžeš tak rýchlo pokladať objekty', 'error')
    else
        cooldown = true
        SetTimeout(4000, function()
            cooldown = false
        end)
        return true
    end
end

local function RemovePropFromHand()
    if currentProp and DoesEntityExist(currentProp) then
        DeleteEntity(currentProp)
    end
    currentProp = nil
    currentPropModel = nil
    currentPropHeading = 0
    isHoldingProp = false
    currentAnimDict = nil
    currentAnimName = nil
    currentItemName = nil
    HideTextUI()
    
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end

local function PlaceProp()
    if not currentProp or not DoesEntityExist(currentProp) then return end
    if not Cooldown() then return end
    
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
    
    DetachEntity(currentProp, true, true)
    SetEntityCoords(currentProp, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(currentProp, GetEntityHeading(playerPed) + currentPropHeading)
    PlaceObjectOnGroundProperly(currentProp)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(currentProp), true)
    
    if currentItemName then
        TriggerServerEvent('sk_pdprops:removeItem', currentItemName)
    end
    
    currentProp = nil
    currentPropModel = nil
    currentPropHeading = 0
    isHoldingProp = false
    currentAnimDict = nil
    currentAnimName = nil
    currentItemName = nil
    HideTextUI()
    
    ClearPedTasks(playerPed)
end

local function SpawnPropInHand(model, headingOffset, boneId, animDict, animName, xOffset, yOffset, zOffset, xRot, yRot, zRot, itemName)
    if isHoldingProp then
        RemovePropFromHand()
    end
    
    local playerPed = PlayerPedId()

    boneId = boneId or 42 
    animDict = animDict or "anim@heists@box_carry@"
    animName = animName or "idle"
    xOffset = xOffset or 0.0
    yOffset = yOffset or 0.0
    zOffset = zOffset or 0.0
    xRot = xRot or 0.0
    yRot = yRot or 0.0
    zRot = zRot or 0.0
    
    lib.requestModel(model)
    
    local coords = GetEntityCoords(playerPed)
    local object = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    
    AttachEntityToEntity(object, playerPed, GetPedBoneIndex(playerPed, boneId), xOffset, yOffset, zOffset, xRot, yRot, zRot, true, true, false, true, 1, true)

    lib.requestAnimDict(animDict)
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)
    
    currentProp = object
    currentPropModel = model
    currentPropHeading = headingOffset or 0.0
    isHoldingProp = true
    currentAnimDict = animDict
    currentAnimName = animName
    currentItemName = itemName
    
    ShowTextUI('[E] Položiť | [X] Schovať')
end

local jobs = {
    ['police'] = 0,
    ['sheriff'] = 0,
    ['sahp'] = 0,
}

RegisterNetEvent('sk_pdprops:useItem', function(itemName)
    if itemName == 'pd_cone' then
        SpawnPropInHand(`prop_roadcone02a`, 0.0, -1, "anim@move_m@trash", "idle", 0.44920921632604, 0.0027554267506569, -0.57718551712304, -5.011174307809, 2.3070357679939, -5.4542326996024, itemName)
    elseif itemName == 'pd_spikestrip' then
        SpawnPropInHand(`p_ld_stinger_s`, 90.0, -1, "anim@heists@box_carry@", "idle", 0.0, 0.41230256627394, 0.097604029029892, 0.0, 0.0, 93.308311001757, itemName)
    elseif itemName == 'pd_barrier' then
        SpawnPropInHand(`prop_barrier_work05`, 0.0, -1, "anim@heists@box_carry@", "idle", 0.0013230442833674, 0.31314459885509, -0.83013720446842, 0.0, 0.0, 0.0, itemName)
    end
end)

CreateThread(function()
    exports.ox_target:addModel({ `prop_roadcone02a`, `p_ld_stinger_s`, `prop_barrier_work05` }, {
        {
            name = 'remove_prop',
            icon = 'fa-solid fa-trash',
            label = 'Odstrániť objekt',
            groups = jobs,
            onSelect = function(data)
                local tick = 0
                lib.progressCircle({
                    duration = 3500,
                    position = 'bottom',
                    label = 'Odstraňuješ objekt...',
                    useWhileDead = false,
                    canCancel = false,
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_player'
                    },
                    disable = {
                        move = true,
                        car = false
                    },
                })
                while not NetworkHasControlOfEntity(data.entity) and tick < 50 do
                    NetworkRequestControlOfEntity(data.entity)
                    tick = tick + 1
                    Wait(0)
                end
                
                local modelHash = GetEntityModel(data.entity)
                local itemName = nil
                
                if modelHash == `prop_roadcone02a` then
                    itemName = 'pd_cone'
                elseif modelHash == `p_ld_stinger_s` then
                    itemName = 'pd_spikestrip'
                elseif modelHash == `prop_barrier_work05` then
                    itemName = 'pd_barrier'
                end
                
                DeleteEntity(data.entity)
                
                if itemName then
                    TriggerServerEvent('sk_pdprops:giveItem', itemName)
                end
            end
        }
    })
    
    while true do
        if IsPedInAnyVehicle(PlayerPedId(), true) then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, `p_ld_stinger_s`, false, false, false)
            if object ~= 0 then
                if IsPedInAnyVehicle(playerPed, false) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
        
                    for i=0, 7, 1 do
                        if not IsVehicleTyreBurst(vehicle, i, true) then
                            SetVehicleTyreBurst(vehicle, i, true, 1000)
                        end
                    end
                end
            end
            Wait(500)
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        if isHoldingProp then
            if IsControlJustPressed(0, 38) then 
                PlaceProp()
            elseif IsControlJustPressed(0, 73) then 
                RemovePropFromHand()
            end

            if currentAnimDict and currentAnimName then
                local playerPed = PlayerPedId()
                if not IsEntityPlayingAnim(playerPed, currentAnimDict, currentAnimName, 3) then
                    TaskPlayAnim(playerPed, currentAnimDict, currentAnimName, 8.0, -8.0, -1, 49, 0, false, false, false)
                end
            end
        end
        Wait(0)
    end
end)

