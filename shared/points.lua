--- SeaM_Npcs :: where you can talk to someone
---
--- Coordinates are vector4. The fourth number is the heading, which matters
--- when the point spawns its own ped.
---
--- A point works one of two ways:
---
---   with `spawn`     the ped is created there, facing the heading. Use this
---                    anywhere the game does not already put people, which is
---                    most of the map outside the city
---
---   without `spawn`  it attaches to whoever is already standing there. Good
---                    behind a shop counter or a police desk, where the game
---                    reliably places someone
---
--- Per point:
---   id         used by the server and by /talkpoints
---   label      the name shown above their line
---   coords     vector4, the fourth number being the heading
---   radius     how far from the point a ped still counts
---   dialogue   which node in shared/dialogue.lua they open with
---
--- Optional:
---   spawn      { model, scenario, anim = { dict, clip } }
---   blip       { sprite, colour, scale, label, shortRange }
---   models     attach mode only. Restricts which ped models qualify
---   icon       third eye icon. Defaults to a person
---   job        only staff of that job get the option
---   group      only that permission group gets the option

TalkPoints = {
    {
        id = 'guard1',
        label = 'Guard',
        coords = vector4(4992.1367, -5715.2036, 18.8802, 141.3860),
        radius = 5.0,
        dialogue = 'guard1_start',
        spawn = {
            model = 'ig_skeleton_01', -- A rugged, older country/biker looking model
            scenario = 'WORLD_HUMAN_GUARD_STAND', -- Guard stance (will hold a weapon if given by the script)
        },
        blip = false,
    },
    {
        id = 'guard2',
        label = 'Guard',
        coords = vector4(4988.1416, -5719.7817, 18.8802, 317.2373),
        radius = 5.0,
        dialogue = 'guard1_start',
        spawn = {
            model = 'ig_skeleton_01', -- A rugged, older country/biker looking model
            scenario = 'WORLD_HUMAN_GUARD_STAND', -- Guard stance (will hold a weapon if given by the script)
        },
        blip = false,
    },
    {
        id = 'guard3',
        label = 'Guard',
        coords = vector4(4987.3301, -5711.9268, 19.0245, 134.7444),
        radius = 5.0,
        dialogue = 'guard1_start',
        spawn = {
            model = 'ig_skeleton_01', -- A rugged, older country/biker looking model
            scenario = 'WORLD_HUMAN_GUARD_STAND', -- Guard stance (will hold a weapon if given by the script)
        },
        blip = false,
    },
    {
        id = 'gideon_vance',
        label = 'Gideon Vance',
        coords = vector4(4983.2646, -5711.3228, 24.2356, 227.3065),
        radius = 4.0,
        dialogue = 'gideon_start',
        icon = 'fas fa-store',
        spawn = {
            model = 'a_m_m_bevhills_02',
            scenario = 'WORLD_HUMAN_SMOKING',
        },
        blip = {
            sprite = 52,
            colour = 5,
            scale = 0.65,
            label = 'Gideon Vance',
            shortRange = true,
        },
    },
    {
        id = 'silas_rook',
        label = 'Silas Rook',
        coords = vector4(5079.6694, -5759.9688, 14.6776, 141.6414),
        radius = 4.0,
        dialogue = 'silas_start',
        icon = 'fas fa-skull-crossbones',
        spawn = {
            model = 'ig_ortega',
            scenario = 'WORLD_HUMAN_SMOKING',
        },
        blip = {
            sprite = 84,
            colour = 1,
            scale = 0.65,
            label = 'Silas Rook',
            shortRange = true,
        },
    },
    {
        id = 'elias_ward',
        label = 'Elias Ward',
        coords = vector4(4959.8735, -5791.6968, 25.2663, 151.4774),
        radius = 4.0,
        dialogue = 'elias_start',
        icon = 'fas fa-shield-halved',
        spawn = {
            model = 's_m_m_security_01',
            scenario = 'WORLD_HUMAN_SMOKING',
        },
        blip = {
            sprite = 60,
            colour = 3,
            scale = 0.65,
            label = 'Elias Ward',
            shortRange = true,
        },
    },
    {
        id = 'tobias_keel',
        label = 'Tobias Keel',
        coords = vector4(4929.4365, -5145.3882, 1.4412, 246.6239),
        radius = 4.0,
        dialogue = 'tobias_start',
        icon = 'fas fa-anchor',
        spawn = {
            model = 's_m_y_dockwork_01',
            scenario = 'WORLD_HUMAN_DRINKING',
        },
        blip = {
            sprite = 410,
            colour = 5,
            scale = 0.7,
            label = 'Tobias Keel - Dock Worker',
            shortRange = true,
        },
    },


}

PointsById = {}

for _, point in ipairs(TalkPoints) do
    point.position = vector3(point.coords.x, point.coords.y, point.coords.z)
    point.heading = point.coords.w or 0.0
    point.radius = point.radius or 5.0

    PointsById[point.id] = point
end
