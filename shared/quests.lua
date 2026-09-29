--- SeaM_Npcs :: quests
---
--- A quest is offered and handed in through ordinary dialogue. The responses
--- that start and finish it live in shared/dialogue.lua and carry `quest`
--- conditions, so a player only ever sees the line that matches where they are
--- up to. Nothing here is checked client side.
---
--- Per quest:
---   label        shown in the tracker
---   summary      one line under it
---   objectives   what has to happen, in order
---   reward       money and items, granted on hand-in
---
--- Optional:
---   repeatable   false means once per character. Defaults to false
---   cooldown     minutes after hand-in before it can be taken again
---   cooldownType 'local' only cools down the character who finished it and
---                lets other players run it at the same time. 'global' lets
---                only one player run it, then cools it down for the server.
---                Defaults to 'local'. Global cooldowns survive restarts.
---   giver        the talk point that hands it out, for your own reference
---
--- Objective types:
---   collect   have `count` of `item` on you. Taken when you hand the quest in
---             unless `keep = true`
---   visit     reach `coords` within `radius`
---   talk      speak to the talk point named in `point`

Quests = {
    gideon_northbound = {
        label = 'Iron Shortage',
        summary = 'Bring Gideon Vance ten pieces of iron.',
        giver = 'gideon_vance',

        repeatable = true,
        cooldown = 20,
        cooldownType = 'local',

        objectives = {
            {
                type = 'collect',
                item = 'iron',
                count = 10,
                label = 'Bring Gideon 10 pieces of iron',
            },
        },

        reward = {
            money = {
                cash = 350,
            },
            items = {
                {
                    name = 'bandage',
                    count = 1,
                },
            },
        },
    },
    elias_lost_necklace = {
        label = 'The Drowned Necklace',
        summary = 'Find Elias Ward’s missing necklace and return it to him.',
        giver = 'elias_ward',

        -- The quest never expires once accepted.
        -- After completion, this character cannot repeat it.
        repeatable = false,

        objectives = {
            {
                type = 'collect',
                item = 'necklace',
                count = 1,
                label = 'Find the lost necklace',
            },
        },

        reward = {
            money = {
                cash = 20000,
            },
        },
    },
    first_voyage_telescope = {
        label = 'First Voyage',
        summary = 'Tobias Keel gave you a telescope for your first voyage.',
        giver = 'tobias_keel',

        -- Makes the free telescope claim one-time per character.
        repeatable = false,

        -- No objectives means Tobias can complete it immediately.
        objectives = {},

        reward = {
            items = {
                {
                    name = 'telescope',
                    count = 1,
                },
            },
        },
    },
}
