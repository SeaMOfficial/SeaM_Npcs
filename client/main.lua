local Core = exports.SeaM_Core:GetCoreObject()

local talking = nil
local usingTarget
local interactionReady = false

local function notify(message, kind)
    TriggerEvent('SeaM_Core:notify', message, kind or 'inform')
end

local function send(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function modelAllowed(point, ped)
    if not point.models then return true end

    local model = GetEntityModel(ped)

    for _, name in ipairs(point.models) do
        if joaat(name) == model then return true end
    end

    return false
end

local function pedQualifies(point, ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return false end
    if IsPedAPlayer(ped) or IsEntityDead(ped) then return false end
    if not modelAllowed(point, ped) then return false end

    return #(GetEntityCoords(ped) - point.position) <= point.radius
end

local function nearestPed(point)
    local best, bestDistance = nil, Config.NearestPedDistance

    for _, ped in ipairs(GetGamePool('CPed')) do
        if pedQualifies(point, ped) then
            local distance = #(GetEntityCoords(ped) - point.position)
            if distance < bestDistance then best, bestDistance = ped, distance end
        end
    end

    return best
end

local function endConversation(tellServer)
    if not talking then return end

    local ped = talking.ped
    talking = nil

    SetNuiFocus(false, false)
    send('close')

    if ped and DoesEntityExist(ped) then ClearPedTasks(ped) end
    if tellServer ~= false then Core.Callbacks.await('npcs:end') end
end

local function startConversation(pointId, ped)
    if talking then return end

    local point = PointsById[pointId]
    if not point then return end

    local session, reason = Core.Callbacks.await('npcs:start', pointId)

    if not session then
        return notify(reason or 'They are not interested.', 'error')
    end

    talking = { id = pointId, ped = ped }

    if Config.Conversation.FacePlayer and ped and DoesEntityExist(ped) then
        TaskTurnPedToFaceEntity(ped, PlayerPedId(), 2000)
    end

    SetNuiFocus(true, true)
    send('open', session)
end

RegisterNUICallback('respond', function(data, cb)
    if not talking then return cb({ ok = false }) end

    local result, reason = Core.Callbacks.await('npcs:respond', data.index)

    if not result then
        if reason then notify(reason, 'error') end
        endConversation(false)
        return cb({ ok = false })
    end

    if result.done then
        endConversation(false)
        return cb({ ok = true, done = true })
    end

    cb({ ok = true, node = result.node })
end)

RegisterNUICallback('close', function(_, cb)
    endConversation(true)
    cb({ ok = true })
end)

RegisterNetEvent('SeaM_Npcs:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end)

local spawned = {}
local attachTarget

local function loadModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then return nil end

    RequestModel(hash)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(10) end

    return HasModelLoaded(hash) and hash or nil
end

function attachTarget(point, ped)
    if not usingTarget or not ped or not DoesEntityExist(ped) then return end

    exports[usingTarget]:addLocalEntity(ped, { {
        name = ('seam_npc_%s'):format(point.id),
        icon = point.icon or 'user',
        label = ('Talk to %s'):format(point.label),
        distance = Config.TargetDistance,
        canInteract = function() return talking == nil end,
        onSelect = function() startConversation(point.id, ped) end,
    } })
end

local function attachSpawnedTargets()
    for _, point in ipairs(TalkPoints) do
        if point.spawn then attachTarget(point, spawned[point.id]) end
    end
end

local function spawnPed(point)
    if spawned[point.id] then return end

    local model = loadModel(point.spawn.model)
    if not model then
        print(('[SeaM_Npcs] "%s" has an invalid model: %s')
            :format(point.id, tostring(point.spawn.model)))
        return
    end

    local ped = CreatePed(4, model, point.position.x, point.position.y,
        point.position.z, point.heading, false, false)
    SetModelAsNoLongerNeeded(model)

    if not DoesEntityExist(ped) then
        print(('[SeaM_Npcs] "%s" could not be created'):format(point.id))
        return
    end

    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)

    if point.spawn.scenario then
        TaskStartScenarioInPlace(ped, point.spawn.scenario, 0, true)
    elseif point.spawn.anim then
        local anim = point.spawn.anim

        RequestAnimDict(anim.dict)
        local deadline = GetGameTimer() + 4000
        while not HasAnimDictLoaded(anim.dict) and GetGameTimer() < deadline do Wait(10) end

        if HasAnimDictLoaded(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 3.0, -8.0, -1, 1, 0.0, false, false, false)
        end
    end

    spawned[point.id] = ped
    attachTarget(point, ped)
end

local function despawnPed(point)
    local ped = spawned[point.id]
    if not ped then return end

    if usingTarget and DoesEntityExist(ped) then
        exports[usingTarget]:removeLocalEntity(ped)
    end

    if DoesEntityExist(ped) then
        SetEntityAsMissionEntity(ped, true, true)
        DeletePed(ped)
    end

    spawned[point.id] = nil
end

local blips = {}

local function createBlips()
    for _, point in ipairs(TalkPoints) do
        if point.blip then
            local blip = AddBlipForCoord(point.position.x, point.position.y, point.position.z)

            SetBlipSprite(blip, point.blip.sprite or 1)
            SetBlipColour(blip, point.blip.colour or 0)
            SetBlipScale(blip, point.blip.scale or 0.7)
            SetBlipAsShortRange(blip, point.blip.shortRange ~= false)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(point.blip.label or point.label)
            EndTextCommandSetBlipName(blip)

            blips[#blips + 1] = blip
        end
    end
end

local function registerTargets(resource)
    for _, point in ipairs(TalkPoints) do
        if not point.spawn then
        exports[resource]:addGlobalPed({ {
            name = ('seam_npc_%s'):format(point.id),
            icon = point.icon or 'user',
            label = ('Talk to %s'):format(point.label),
            distance = Config.TargetDistance,
            job = point.job,
            groups = point.group,
            canInteract = function(entity)
                if talking then return false end
                return pedQualifies(point, entity)
            end,
            onSelect = function(data) startConversation(point.id, data.entity) end,
        } })
        end
    end
end

local function registerPoints()
    for _, point in ipairs(TalkPoints) do
        exports.SeaM_Core:RegisterPoint({
            id = ('seam_npc_%s'):format(point.id),
            coords = point.position,
            distance = Config.PointDistance,
            label = ('Talk to %s'):format(point.label),
            canInteract = function() return talking == nil end,
            onSelect = function()
                local ped = point.spawn and spawned[point.id] or nearestPed(point)

                if not ped or not DoesEntityExist(ped) then
                    return notify('There is nobody here right now.', 'error')
                end

                startConversation(point.id, ped)
            end,
        })
    end
end

local function targetResource()
    if Config.Interaction == 'marker' then return nil end

    local deadline = GetGameTimer() + 15000

    while GetGameTimer() < deadline do
        local resourceState = GetResourceState('SeaM_Target')

        if resourceState == 'started' then return 'SeaM_Target' end
        if resourceState == 'missing' or resourceState == 'unknown' then return nil end

        Wait(200)
    end

    return nil
end

CreateThread(function()
    createBlips()

    usingTarget = targetResource()

    if usingTarget then
        registerTargets(usingTarget)
    else
        registerPoints()
    end

    interactionReady = true

    for _, point in ipairs(TalkPoints) do
        if point.spawn then spawnPed(point) end
    end
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= 'SeaM_Target' or not usingTarget then return end

    registerTargets('SeaM_Target')
    attachSpawnedTargets()
end)

CreateThread(function()
    while true do
        Wait(500)

        if talking then
            local point = PointsById[talking.id]
            local coords = GetEntityCoords(PlayerPedId())

            local gone = not point
                or #(coords - point.position) > Config.Conversation.LeashDistance
                or IsPedDeadOrDying(PlayerPedId(), true)
                or (talking.ped and not DoesEntityExist(talking.ped))

            if gone then endConversation(true) end
        end
    end
end)

RegisterNetEvent('SeaM_Npcs:client:inspect', function()
    local coords = GetEntityCoords(PlayerPedId())
    local nearest, nearestDistance

    for _, point in ipairs(TalkPoints) do
        local distance = #(coords - point.position)
        if not nearestDistance or distance < nearestDistance then
            nearest, nearestDistance = point, distance
        end
    end

    print(('[SeaM_Npcs] vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))

    if not nearest then
        return TriggerEvent('SeaM_Core:notify', 'No talk points configured.', 'error')
    end

    local qualifying = 0
    local models = {}

    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and #(GetEntityCoords(ped) - nearest.position) <= nearest.radius then
            if pedQualifies(nearest, ped) then qualifying = qualifying + 1 end
            models[#models + 1] = GetEntityModel(ped)
        end
    end

    local line = ('%s [%s] %.0fm away | %d of %d peds qualify')
        :format(nearest.label, nearest.id, nearestDistance, qualifying, #models)

    TriggerEvent('SeaM_Core:notify', line, 'inform', 9000, 'Talk point')
    print(('[SeaM_Npcs] %s'):format(line))

    for _, model in ipairs(models) do
        print(('[SeaM_Npcs]   ped model hash %s'):format(model))
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    SetNuiFocus(false, false)

    for _, point in ipairs(TalkPoints) do
        if point.spawn then despawnPed(point) end
    end

    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
end)

RegisterNetEvent('SeaM_Core:player:unloaded', function() endConversation(false) end)

RegisterCommand('npcdebug', function()
    local coords = GetEntityCoords(PlayerPedId())

    print('[SeaM_Npcs] --- state ---')
    print(('[SeaM_Npcs] SeaM_Target: %s  |  using: %s  |  ready: %s')
        :format(GetResourceState('SeaM_Target'), tostring(usingTarget), tostring(interactionReady)))
    print(('[SeaM_Npcs] blips created: %d'):format(#blips))

    for _, point in ipairs(TalkPoints) do
        local ped = spawned[point.id]
        local distance = #(coords - point.position)

        print(('[SeaM_Npcs] %s  %.1fm  mode=%s  ped=%s  exists=%s')
            :format(point.id, distance, point.spawn and 'spawn' or 'attach',
                tostring(ped), tostring(ped ~= nil and DoesEntityExist(ped))))

        if ped and DoesEntityExist(ped) then
            local at = GetEntityCoords(ped)
            print(('[SeaM_Npcs]   ped at %.2f %.2f %.2f  (point z %.2f)')
                :format(at.x, at.y, at.z, point.position.z))
        end
    end
end, false)

exports('IsTalking', function() return talking ~= nil end)
exports('Talk', function(id, ped) startConversation(id, ped) end)
