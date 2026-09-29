local tracked = {}
local reached = {}

local function label(text, x, y, scale, red, green, blue, alpha)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(red, green, blue, alpha)
    SetTextDropShadow()
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(text)
    DrawText(x, y)
end

local function draw()
    local rows = 0
    for _, quest in ipairs(tracked) do rows = rows + 1 + #quest.objectives end

    local height = 0.03 + (rows * 0.021)
    local top = Config.Quests.TrackerY

    DrawRect(Config.Quests.TrackerX, top + height / 2 - 0.012, 0.21, height, 8, 14, 18, 170)
    DrawRect(Config.Quests.TrackerX, top - 0.012, 0.21, 0.002, 111, 216, 205, 200)

    local y = top
    local left = Config.Quests.TrackerX - 0.095

    for _, quest in ipairs(tracked) do
        label(quest.label, left, y, 0.28, 111, 216, 205, 235)
        y = y + 0.021

        for _, objective in ipairs(quest.objectives) do
            local text = objective.need > 1
                and ('%s  %d/%d'):format(objective.label, objective.have, objective.need)
                or objective.label

            if objective.done then
                label(('- %s'):format(text), left + 0.006, y, 0.25, 120, 190, 150, 210)
            else
                label(('- %s'):format(text), left + 0.006, y, 0.25, 210, 218, 220, 220)
            end

            y = y + 0.021
        end
    end
end

RegisterNetEvent('SeaM_Npcs:client:questSync', function(list)
    tracked = type(list) == 'table' and list or {}
    reached = {}
end)

RegisterNetEvent('SeaM_Npcs:client:questStarted', function(_, name, summary)
    TriggerEvent('SeaM_Core:notify', summary or name, 'inform', 8000, ('Taken on: %s'):format(name))
end)

RegisterNetEvent('SeaM_Npcs:client:questFinished', function(_, name)
    TriggerEvent('SeaM_Core:notify', name, 'success', 8000, 'Job done')
end)

CreateThread(function()
    while true do
        if #tracked == 0 or not Config.Quests.Tracker then
            Wait(1000)
        else
            draw()
            Wait(0)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1500)

        if #tracked > 0 then
            local coords = GetEntityCoords(PlayerPedId())

            for _, quest in ipairs(tracked) do
                local definition = Quests[quest.id]

                for index, objective in ipairs(definition and definition.objectives or {}) do
                    local key = ('%s:%d'):format(quest.id, index)
                    local row = quest.objectives[index]

                    if objective.type == 'visit' and row and not row.done and not reached[key]
                        and #(coords - objective.coords) <= (objective.radius or 20.0) then
                        reached[key] = true
                        TriggerServerEvent('SeaM_Npcs:server:reachedObjective', quest.id, index)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(2000)

        if not Config.Quests.Waypoint then
            Wait(5000)
        else
            for _, quest in ipairs(tracked) do
                local definition = Quests[quest.id]

                for index, objective in ipairs(definition and definition.objectives or {}) do
                    local row = quest.objectives[index]

                    if objective.type == 'visit' and row and not row.done then
                        if not reached[('blip:%s:%d'):format(quest.id, index)] then
                            reached[('blip:%s:%d'):format(quest.id, index)] = true

                            local blip = AddBlipForCoord(objective.coords.x, objective.coords.y,
                                objective.coords.z)
                            SetBlipSprite(blip, 1)
                            SetBlipColour(blip, 5)
                            SetBlipScale(blip, 0.8)
                            SetBlipAsShortRange(blip, false)

                            BeginTextCommandSetBlipName('STRING')
                            AddTextComponentSubstringPlayerName(objective.label or quest.label)
                            EndTextCommandSetBlipName(blip)
                        end
                    end
                end
            end
        end
    end
end)

exports('GetTracked', function() return tracked end)
