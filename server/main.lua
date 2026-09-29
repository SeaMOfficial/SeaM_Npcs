local Core = exports.SeaM_Core:GetCoreObject()
local SeaM = exports.SeaM_Core

local sessions = {}

local function inventory()
    return GetResourceState('SeaM_Inventory') == 'started' and exports.SeaM_Inventory or nil
end

local function asList(value)
    if type(value) ~= 'table' then return nil end
    if value.name then return { value } end
    return value
end

local function hasItems(source, requirement)
    local bag = inventory()
    if not bag then return false end

    if type(requirement) == 'string' then
        return bag:GetItemCount(source, requirement) > 0
    end

    for _, entry in ipairs(asList(requirement) or {}) do
        if bag:GetItemCount(source, entry.name) < (entry.count or 1) then return false end
    end

    return true
end

local function meetsJob(source, requirement)
    local job = SeaM:GetJob(source)
    if not job then return false end

    if type(requirement) == 'string' then return job.name == requirement end

    for key, value in pairs(requirement) do
        if type(key) == 'number' then
            if job.name == value then return true end
        elseif job.name == key then
            return (job.grade or 0) >= value
        end
    end

    return false
end

local function questAllows(source, requirement)
    if type(requirement) ~= 'table' then return true end

    local state = Quest.state(source, requirement.id)

    if type(requirement.state) == 'table' then
        for _, wanted in ipairs(requirement.state) do
            if state == wanted then return true end
        end
        return false
    end

    return state == requirement.state
end

local function allowed(source, entry)
    if entry.job and not meetsJob(source, entry.job) then return false end
    if entry.group and not SeaM:HasGroup(source, entry.group) then return false end
    if entry.item and not hasItems(source, entry.item) then return false end
    if entry.quest and not questAllows(source, entry.quest) then return false end

    for account, amount in pairs(entry.money or {}) do
        if not SeaM:HasMoney(source, account, amount) then return false end
    end

    return true
end

local function canTalkTo(source, point)
    if point.job and not meetsJob(source, point.job) then return false end
    if point.group and not SeaM:HasGroup(source, point.group) then return false end
    return true
end

local function nodeFor(source, nodeId)
    local node = Dialogue[nodeId]
    if not node then return nil end

    local responses = {}

    for index, response in ipairs(node.responses or {}) do
        if allowed(source, response) then
            responses[#responses + 1] = { index = index, text = response.text }
        end
    end

    return { id = nodeId, text = node.text, responses = responses }
end

local function log(source, action, detail)
    if not Config.LogRewards then return end

    Core.Log.audit('money', ('NPC %s'):format(action),
        ('`%s` %s'):format(GetPlayerName(source) or source, detail))
end

local function runActions(source, response)
    local bag = inventory()

    if response.charge then
        local charge = response.charge
        if not SeaM:RemoveMoney(source, charge.account or 'cash', charge.amount,
            'npc conversation') then
            return false, 'You cannot afford that.'
        end
        log(source, 'charge', ('paid %s'):format(Core.Util.formatMoney(charge.amount)))
    end

    local taken

    if response.take then
        local list = asList(response.take) or {}

        if not bag then
            if response.charge then
                SeaM:AddMoney(source, response.charge.account or 'cash',
                    response.charge.amount, 'npc refund')
            end
            return false, 'Nothing to hand over with.'
        end
        if not bag:RemoveItems(source, list) then
            if response.charge then
                SeaM:AddMoney(source, response.charge.account or 'cash',
                    response.charge.amount, 'npc refund')
            end
            return false, 'You do not have all of that.'
        end
        taken = list
    end

    if response.give then
        local list = asList(response.give) or {}

        -- Without an inventory the goods cannot be handed over, so treat it as a
        -- failed trade instead of taking payment for nothing.
        if not bag or not bag:AddItems(source, list) then
            if response.charge then
                SeaM:AddMoney(source, response.charge.account or 'cash',
                    response.charge.amount, 'npc refund')
            end
            -- Hand back anything already taken for this trade.
            if taken and bag then bag:AddItems(source, taken) end
            return false, 'You cannot carry that.'
        end
    end

    if response.pay then
        SeaM:AddMoney(source, response.pay.account or 'cash', response.pay.amount,
            'npc conversation')
        log(source, 'payout', ('was paid %s'):format(Core.Util.formatMoney(response.pay.amount)))
    end

    if response.startQuest then
        local ok, reason = Quest.start(source, response.startQuest)
        if not ok then return false, reason or 'You cannot take that on right now.' end
    end

    if response.finishQuest then
        local ok, reason = Quest.finish(source, response.finishQuest)
        if not ok then return false, reason end
    end

    if response.abandonQuest then Quest.abandon(source, response.abandonQuest) end

    if response.notify then
        SeaM:Notify(source, response.notify.text, response.notify.kind or 'inform')
    end

    if response.event then
        TriggerClientEvent(response.event, source, response.eventData)
    end

    if response.serverEvent then
        TriggerEvent(response.serverEvent, source, response.eventData)
    end

    return true
end

Core.Callbacks.register('npcs:start', function(source, pointId)
    local point = PointsById[pointId]
    if not point then return nil end

    local reach = (point.radius or 5.0) + Config.Conversation.LeashDistance

    if #(GetEntityCoords(GetPlayerPed(source)) - point.position) > reach then
        Core.RateLimit.flag(source, 'npc distance')
        return nil
    end

    if not canTalkTo(source, point) then
        return nil, 'They have nothing to say to you.'
    end

    local node = nodeFor(source, point.dialogue)
    if not node then return nil, 'They have nothing to say.' end

    sessions[source] = { point = pointId, node = point.dialogue }

    Quest.onTalk(source, pointId)

    return { label = point.label, node = node, accent = Config.UI.accent,
             showKeys = Config.UI.ShowKeys, speed = Config.Conversation.Speed }
end)

Core.Callbacks.register('npcs:respond', function(source, index)
    local session = sessions[source]
    if not session then return nil end

    local node = Dialogue[session.node]
    if not node then return nil end

    local response = node.responses and node.responses[math.floor(tonumber(index) or 0)]
    if not response then return nil end

    if not allowed(source, response) then
        Core.RateLimit.flag(source, 'npc response')
        return nil, 'You cannot say that.'
    end

    local ok, reason = runActions(source, response)
    if not ok then
        sessions[source] = nil
        return nil, reason
    end

    if response.close or not response.to then
        sessions[source] = nil
        return { done = true }
    end

    local next_ = nodeFor(source, response.to)
    if not next_ then
        sessions[source] = nil
        return { done = true }
    end

    session.node = response.to
    return { node = next_ }
end)

Core.Callbacks.register('npcs:end', function(source)
    sessions[source] = nil
    return true
end)

AddEventHandler('playerDropped', function() sessions[source] = nil end)
AddEventHandler('SeaM_Core:player:unloaded', function(source) sessions[source] = nil end)

Core.Commands.register('talkpoints', {
    help = 'Show the talk point you are standing in, and who qualifies there',
    permission = 'admin',
    handler = function(source)
        if source == 0 then
            print(('--- %d talk point(s) ---'):format(#TalkPoints))

            for _, point in ipairs(TalkPoints) do
                print(('  %-16s %-18s r=%.0f  %s'):format(
                    point.id, point.label, point.radius,
                    point.models and table.concat(point.models, ', ') or 'any ped'))
            end
            return
        end

        TriggerClientEvent('SeaM_Npcs:client:inspect', source)
    end,
})

exports('GetPoints', function() return TalkPoints end)
exports('IsTalking', function(source) return sessions[source] ~= nil end)
