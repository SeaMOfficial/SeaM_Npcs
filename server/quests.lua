local Core = exports.SeaM_Core:GetCoreObject()
local SeaM = exports.SeaM_Core

local METADATA_KEY = 'quests'
local GLOBAL_COOLDOWN_KVP = 'questGlobalCooldown:'

local globalLocks = {}
local globalCooldowns = {}

Quest = {}

local function inventory()
    return GetResourceState('SeaM_Inventory') == 'started' and exports.SeaM_Inventory or nil
end

local function book(source)
    local stored = SeaM:GetMetadata(source, METADATA_KEY)
    return type(stored) == 'table' and stored or {}
end

local function save(source, quests)
    SeaM:SetMetadata(source, METADATA_KEY, quests)
end

local function definition(id)
    return Quests[id]
end

local function cooldownType(quest)
    return quest and quest.cooldownType == 'global' and 'global' or 'local'
end

local function cooldownSeconds(quest)
    return math.max(0, tonumber(quest and quest.cooldown) or 0) * 60
end

local function globalCooldownUntil(id)
    if globalCooldowns[id] == nil then
        globalCooldowns[id] = tonumber(GetResourceKvpString(GLOBAL_COOLDOWN_KVP .. id)) or 0
    end

    if globalCooldowns[id] > 0 and globalCooldowns[id] <= os.time() then
        globalCooldowns[id] = 0
        DeleteResourceKvp(GLOBAL_COOLDOWN_KVP .. id)
    end

    return globalCooldowns[id]
end

local function beginGlobalCooldown(id, quest)
    local seconds = cooldownSeconds(quest)

    if seconds <= 0 then
        globalCooldowns[id] = 0
        DeleteResourceKvp(GLOBAL_COOLDOWN_KVP .. id)
        return
    end

    local expiresAt = os.time() + math.floor(seconds)
    globalCooldowns[id] = expiresAt
    SetResourceKvp(GLOBAL_COOLDOWN_KVP .. id, tostring(expiresAt))
end

local function globalHolder(id)
    local holder = globalLocks[id]

    if holder and not GetPlayerName(holder) then
        globalLocks[id] = nil
        holder = nil
    end

    return holder
end

local function waitDescription(seconds)
    local minutes = math.max(1, math.ceil(seconds / 60))
    return ('%d minute%s'):format(minutes, minutes == 1 and '' or 's')
end

local function unavailableReason(source, id, quest, state)
    if state == 'busy' then
        return 'Someone else is already doing that job.'
    end

    if state == 'cooldown' then
        local remaining = Quest.cooldownRemaining(source, id)
        local who = cooldownType(quest) == 'global' and 'That job is on cooldown for everyone'
            or 'You are still on cooldown for that job'

        return ('%s. Try again in %s.'):format(who, waitDescription(remaining))
    end

    if state == 'done' then return 'You have already completed that job.' end
    if state == 'active' or state == 'complete' then return 'You already have that job.' end

    return 'You cannot take that on right now.'
end

function Quest.state(source, id)
    local quest = definition(id)
    if not quest then return 'available' end

    local entry = book(source)[id]

    if cooldownType(quest) == 'global' then
        if entry and entry.state == 'active' then
            local holder = globalHolder(id)

            if not holder then
                globalLocks[id] = source
                holder = source
            end

            if holder == source then
                return Quest.objectivesMet(source, id) and 'complete' or 'active'
            end

            return 'busy'
        end

        if globalHolder(id) then return 'busy' end
        if globalCooldownUntil(id) > os.time() then return 'cooldown' end
    end

    if not entry then return 'available' end

    if entry.state == 'done' then
        if not quest.repeatable then return 'done' end
        if cooldownType(quest) == 'global' then return 'available' end

        local seconds = cooldownSeconds(quest)
        if seconds <= 0 then return 'available' end

        local expiresAt = (entry.finishedAt or 0) + seconds
        return os.time() >= expiresAt and 'available' or 'cooldown'
    end

    if entry.state ~= 'active' then return entry.state or 'available' end

    return Quest.objectivesMet(source, id) and 'complete' or 'active'
end

function Quest.cooldownRemaining(source, id)
    local quest = definition(id)
    if not quest then return 0 end

    if cooldownType(quest) == 'global' then
        return math.max(0, globalCooldownUntil(id) - os.time())
    end

    local entry = book(source)[id]
    if not entry or entry.state ~= 'done' then return 0 end

    return math.max(0, ((entry.finishedAt or 0) + cooldownSeconds(quest)) - os.time())
end

function Quest.progress(source, id)
    local quest = definition(id)
    if not quest then return false, {} end

    local entry = book(source)[id] or {}
    local marks = entry.progress or {}
    local bag = inventory()

    local rows = {}
    local met = true

    for index, objective in ipairs(quest.objectives) do
        local have, need = 0, objective.count or 1

        if objective.type == 'collect' then
            have = bag and bag:GetItemCount(source, objective.item) or 0
        else
            have = marks[tostring(index)] and 1 or 0
        end

        local done = have >= need
        if not done then met = false end

        rows[index] = {
            label = objective.label,
            have = math.min(have, need),
            need = need,
            done = done,
        }
    end

    return met, rows
end

function Quest.objectivesMet(source, id)
    local met = Quest.progress(source, id)
    return met
end

function Quest.start(source, id)
    local quest = definition(id)
    if not quest then return false, 'That job does not exist.' end

    local state = Quest.state(source, id)
    if state ~= 'available' then
        return false, unavailableReason(source, id, quest, state)
    end

    if cooldownType(quest) == 'global' then
        local holder = globalHolder(id)

        if holder and holder ~= source then
            return false, 'Someone else is already doing that job.'
        end

        local remaining = Quest.cooldownRemaining(source, id)
        if remaining > 0 then
            return false, ('That job is on cooldown for everyone. Try again in %s.')
                :format(waitDescription(remaining))
        end

        globalLocks[id] = source
    end

    local quests = book(source)
    quests[id] = { state = 'active', startedAt = os.time(), progress = {} }
    save(source, quests)

    TriggerClientEvent('SeaM_Npcs:client:questStarted', source, id, quest.label, quest.summary)
    Quest.push(source)

    return true
end

function Quest.mark(source, id, index)
    local quests = book(source)
    local entry = quests[id]
    local quest = definition(id)

    if not quest or not entry or entry.state ~= 'active' then return false end

    if cooldownType(quest) == 'global' then
        local holder = globalHolder(id)

        if not holder then
            globalLocks[id] = source
        elseif holder ~= source then
            return false
        end
    end

    entry.progress = entry.progress or {}
    if entry.progress[tostring(index)] then return false end

    entry.progress[tostring(index)] = true
    save(source, quests)

    Quest.push(source)
    return true
end

function Quest.finish(source, id)
    local quest = definition(id)
    if not quest then return false, 'That job does not exist.' end
    if Quest.state(source, id) ~= 'complete' then return false, 'You have not finished that yet.' end

    local bag = inventory()
    local taking = {}

    for _, objective in ipairs(quest.objectives) do
        if objective.type == 'collect' and not objective.keep then
            taking[#taking + 1] = { name = objective.item, count = objective.count or 1 }
        end
    end

    if #taking > 0 then
        if not bag then return false, 'You have nothing to hand over with.' end
        if not bag:RemoveItems(source, taking) then
            return false, 'You are missing some of that now.'
        end
    end

    local reward = quest.reward or {}

    if reward.items and bag and not bag:AddItems(source, reward.items) then
        for _, entry in ipairs(taking) do bag:AddItem(source, entry.name, entry.count) end
        return false, 'You cannot carry the reward.'
    end

    for account, amount in pairs(reward.money or {}) do
        if (tonumber(amount) or 0) > 0 then
            SeaM:AddMoney(source, account, amount, ('quest: %s'):format(quest.label))
        end
    end

    local quests = book(source)
    quests[id] = { state = 'done', finishedAt = os.time(), progress = {} }
    save(source, quests)

    if cooldownType(quest) == 'global' then
        if globalLocks[id] == source then globalLocks[id] = nil end
        beginGlobalCooldown(id, quest)
    end

    TriggerClientEvent('SeaM_Npcs:client:questFinished', source, id, quest.label)
    Quest.push(source)

    if Config.Quests.Log then
        Core.Log.audit('join', 'Quest complete',
            ('`%s` finished **%s**'):format(GetPlayerName(source) or source, quest.label))
    end

    return true
end

function Quest.abandon(source, id)
    local quests = book(source)
    if not quests[id] or quests[id].state ~= 'active' then return false end

    quests[id] = nil
    save(source, quests)

    local quest = definition(id)
    if cooldownType(quest) == 'global' and globalLocks[id] == source then
        globalLocks[id] = nil
    end

    Quest.push(source)
    return true
end

function Quest.releaseGlobalLocks(source)
    local quests = book(source)
    local changed = false

    for id, entry in pairs(quests) do
        local quest = definition(id)

        if entry.state == 'active' and cooldownType(quest) == 'global' then
            quests[id] = nil
            changed = true
        end
    end

    for id, holder in pairs(globalLocks) do
        if holder == source then globalLocks[id] = nil end
    end

    if changed then save(source, quests) end
end

function Quest.restoreGlobalLocks(source)
    local quests = book(source)
    local changed = false
    local displaced = {}

    for id, entry in pairs(quests) do
        local quest = definition(id)

        if entry.state == 'active' and cooldownType(quest) == 'global' then
            local holder = globalHolder(id)

            if globalCooldownUntil(id) > os.time() or (holder and holder ~= source) then
                quests[id] = nil
                changed = true
                displaced[#displaced + 1] = quest.label
            else
                globalLocks[id] = source
            end
        end
    end

    if changed then save(source, quests) end

    if #displaced > 0 then
        SeaM:Notify(source,
            ('No longer reserved: %s'):format(table.concat(displaced, ', ')),
            'inform', 7000, 'Shared job')
    end

    Quest.push(source)
end

function Quest.push(source)
    local tracked = {}

    for id, entry in pairs(book(source)) do
        if entry.state == 'active' then
            local quest = definition(id)
            local state = quest and Quest.state(source, id)

            if quest and (state == 'active' or state == 'complete') then
                local met, rows = Quest.progress(source, id)

                tracked[#tracked + 1] = {
                    id = id,
                    label = quest.label,
                    summary = quest.summary,
                    objectives = rows,
                    complete = met,
                }
            end
        end
    end

    table.sort(tracked, function(a, b) return a.label < b.label end)
    TriggerClientEvent('SeaM_Npcs:client:questSync', source, tracked)
end

RegisterNetEvent('SeaM_Npcs:server:reachedObjective', function(id, index)
    local source = source
    local quest = definition(id)
    if not quest then return end

    local objective = quest.objectives[tonumber(index) or 0]
    if not objective or objective.type ~= 'visit' then return end

    local distance = #(GetEntityCoords(GetPlayerPed(source)) - objective.coords)
    if distance > (objective.radius or 20.0) + 10.0 then
        Core.RateLimit.flag(source, 'quest objective')
        return
    end

    if Quest.mark(source, id, tonumber(index)) then
        SeaM:Notify(source, objective.label, 'success', 6000, 'Objective done')
    end
end)

function Quest.onTalk(source, pointId)
    for id, entry in pairs(book(source)) do
        if entry.state == 'active' then
            local quest = definition(id)

            for index, objective in ipairs(quest and quest.objectives or {}) do
                if objective.type == 'talk' and objective.point == pointId then
                    if Quest.mark(source, id, index) then
                        SeaM:Notify(source, objective.label, 'success', 6000, 'Objective done')
                    end
                end
            end
        end
    end
end

AddEventHandler('SeaM_Core:player:loaded', function(source)
    SetTimeout(3000, function()
        if GetPlayerName(source) then Quest.restoreGlobalLocks(source) end
    end)
end)

AddEventHandler('playerDropped', function()
    Quest.releaseGlobalLocks(source)
end)

AddEventHandler('SeaM_Core:player:unloaded', function(source)
    Quest.releaseGlobalLocks(source)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    SetTimeout(1000, function()
        for _, player in ipairs(GetPlayers()) do
            local source = tonumber(player)
            if source and GetPlayerName(source) then Quest.restoreGlobalLocks(source) end
        end
    end)
end)

Core.Commands.register('quests', {
    help = 'List the jobs you have taken',
    handler = function(source)
        if source == 0 then return end

        local lines = {}

        for id, entry in pairs(book(source)) do
            local quest = definition(id)
            if quest then
                lines[#lines + 1] = ('%s - %s'):format(quest.label, Quest.state(source, id))
            end
        end

        SeaM:Notify(source, #lines > 0 and table.concat(lines, '\n') or 'You have not taken any.',
            'inform', 9000, 'Jobs')
    end,
})

exports('GetQuestState', function(source, id) return Quest.state(source, id) end)
exports('GetQuestCooldown', function(source, id) return Quest.cooldownRemaining(source, id) end)
exports('StartQuest', function(source, id) return Quest.start(source, id) end)
exports('FinishQuest', function(source, id) return Quest.finish(source, id) end)
exports('AbandonQuest', function(source, id) return Quest.abandon(source, id) end)
