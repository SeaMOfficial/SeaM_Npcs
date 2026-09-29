--- SeaM_Npcs :: what they say
---
--- Only the harbour_* nodes are reachable at the moment, since there is one
--- talk point configured. The fence, doctor and police nodes below are left in
--- as worked examples: add a point in shared/points.lua pointing at one of
--- them and it comes alive with no other change.
---
--- Every node is what the NPC says plus the answers you can give back.
---
--- A response can have:
---   text        what you say
---   to          the next node. Not "goto" - that is a reserved word in Lua
---   close       true to end the conversation
---
--- Conditions, all checked on the server. A response that fails one is not
--- sent to the client at all, so it cannot be picked or even seen:
---   job         'police', or { police = 2 } for a minimum grade
---   group       a core permission group
---   item        an item you must be carrying, or a list
---   money       { cash = 500 }, what you must have
---   quest       { id = 'scrap_run', state = 'available' } or a list of states.
---               States are available, active, complete, done and cooldown, so
---               one node can hold the offer, the nudge and the hand-in and a
---               player only ever sees the one that fits
---
--- Actions, also run on the server:
---   give        { name = 'water', count = 2 } or a list
---   take        the same shape, removed from your bag
---   pay         { account = 'cash', amount = 250 } paid to you
---   charge      the same shape, taken from you
---   notify      { text = '...', kind = 'success' }
---   event       a client event fired on the person talking
---   serverEvent a server event, with their source
---   startQuest  takes a job on
---   finishQuest hands it in. Fails with a reason if it is not finished
---   abandonQuest drops it
---
--- A response with an action it cannot complete, such as charging someone who
--- cannot pay, stops and says so rather than half-running.

Dialogue = {

    --- guardScenario ------------------------------------------------------

    guard1_start = {
        text = "Halt! State your business at the docks, landlubber. I don't like the look of you, and me weapon likes it even less.",
        responses = {
            { text = "Where am I?", to = "guard1_where" },
            { text = "Relax, I am an officer of the law.", job = "police", to = "guard1_police" },
            { text = "Just passing through. What are you guarding?", to = "guard1_guarding" },
            { text = "Nothing, sorry. *Walk away*", close = true },
        },
    },

    guard1_where = {
        text = "Cayo Perico, boyo. Salt, rust, and heavy cargo. Unless you've got business with the ships, you're trespassing.",
        responses = {
            { text = "What exactly are you guarding here?", to = "guard1_guarding" },
            { text = "Right. I'll be leaving.", close = true },
        },
    },

    guard1_guarding = {
        text = "That's on a need-to-know basis, and you don't need to know. Move along before I lose what little patience I have left.",
        responses = {
            { text = "Fair enough. Goodbye.", close = true },
        },
    },

    guard1_police = {
        text = "Ah... the law. Right. Well, everything is in order here, officer. Just keeping the peace. No trouble from me.",
        responses = {
            { text = "Carry on then.", close = true },
        },
    },
    --- Gideon Vance --------------------------------------------------------

    gideon_start = {
        text = 'Gideon Vance. Water, bandages and island gossip. What do you need?',
        responses = {
            {
                text = 'Show me what you are selling.',
                to = 'gideon_shop',
            },
            {
                text = 'What can you tell me about Cayo?',
                to = 'gideon_cayo',
            },
            {
                text = 'What is beyond this harbour?',
                to = 'gideon_beyond',
            },
            {
                text = 'Do you have any work?',
                quest = {
                    id = 'gideon_northbound',
                    state = 'available',
                },
                to = 'gideon_quest_offer',
            },
            {
                text = 'About your northern supply spot.',
                quest = {
                    id = 'gideon_northbound',
                    state = 'active',
                },
                to = 'gideon_quest_active',
            },
            {
                text = 'I found the northern supply spot.',
                quest = {
                    id = 'gideon_northbound',
                    state = 'complete',
                },
                to = 'gideon_quest_complete',
            },
            {
                text = 'Do you have any more work?',
                quest = {
                    id = 'gideon_northbound',
                    state = 'cooldown',
                },
                to = 'gideon_quest_cooldown',
            },
            {
                text = 'Nothing right now.',
                close = true,
            },
        },
    },

    gideon_shop = {
        text = 'Nothing fancy, but everything here might keep you alive.',
        responses = {
            {
                text = 'Buy water - $15',
                money = {
                    cash = 15,
                },
                charge = {
                    account = 'cash',
                    amount = 15,
                },
                give = {
                    name = 'water',
                    count = 1,
                },
                notify = {
                    text = 'Gideon hands you a bottle of water.',
                    kind = 'success',
                },
                to = 'gideon_shop',
            },
            {
                text = 'Buy a sandwich - $20',
                money = {
                    cash = 20,
                },
                charge = {
                    account = 'cash',
                    amount = 20,
                },
                give = {
                    name = 'sandwich',
                    count = 1,
                },
                notify = {
                    text = 'Gideon hands you a wrapped sandwich.',
                    kind = 'success',
                },
                to = 'gideon_shop',
            },
            {
                text = 'Buy a bandage - $45',
                money = {
                    cash = 45,
                },
                charge = {
                    account = 'cash',
                    amount = 45,
                },
                give = {
                    name = 'bandage',
                    count = 1,
                },
                notify = {
                    text = 'Gideon hands you a clean bandage.',
                    kind = 'success',
                },
                to = 'gideon_shop',
            },
            {
                text = 'That is everything.',
                to = 'gideon_start',
            },
        },
    },

    gideon_cayo = {
        text = 'Cayo Perico is rich, isolated and watched. Stay away from the main roads, keep an eye on the towers and never assume an empty beach is safe.',
        responses = {
            {
                text = 'Where should I look for loot?',
                to = 'gideon_north',
            },
            {
                text = 'What is beyond the harbour?',
                to = 'gideon_beyond',
            },
            {
                text = 'Let me ask something else.',
                to = 'gideon_start',
            },
        },
    },

    gideon_north = {
        text = 'Head north. That is your best shot for loot, so I have heard. Old sheds, forgotten supply crates and fewer patrols than you will find near the compound.',
        responses = {
            {
                text = 'Anything I should watch for?',
                to = 'gideon_danger',
            },
            {
                text = 'Good to know.',
                to = 'gideon_start',
            },
        },
    },

    gideon_beyond = {
        text = 'Beyond this harbour? Head north. Best shot for loot, so I have heard. Follow the coast and search around the old supply buildings, but keep your head down.',
        responses = {
            {
                text = 'What makes it dangerous?',
                to = 'gideon_danger',
            },
            {
                text = 'Thanks for the information.',
                to = 'gideon_start',
            },
        },
    },

    gideon_danger = {
        text = 'Every man is for theemselves out here, keep yourself to yourself and watch the towers. The guards are not the only danger, and you will find that out the hard way if you are not careful.',
        responses = {
            {
                text = 'I will remember that.',
                to = 'gideon_start',
            },
        },
    },

    gideon_quest_offer = {
        text = 'I am running short on iron. Bring me ten good pieces and I will make it worth your time.',
        responses = {
            {
                text = 'I will bring you the iron.',
                startQuest = 'gideon_northbound',
                close = true,
            },
            {
                text = 'Not right now.',
                close = true,
            },
        },
    },

    gideon_quest_active = {
        text = 'I need ten pieces of iron. Come back when you have all of it.',
        responses = {
            {
                text = 'I am still looking.',
                close = true,
            },
            {
                text = 'I am done with this job.',
                abandonQuest = 'gideon_northbound',
                notify = {
                    text = 'You abandoned Gideon’s iron job.',
                    kind = 'inform',
                },
                close = true,
            },
        },
    },

    gideon_quest_complete = {
        text = 'That looks like all ten pieces. Hand them over and I will pay you.',
        responses = {
            {
                text = 'Here is your iron.',
                finishQuest = 'gideon_northbound',
                close = true,
            },
        },
    },

    gideon_quest_cooldown = {
        text = 'You have already done a run for me recently. Other people can still take the work, but you need to give it some time.',
        responses = {
            {
                text = 'I will come back later.',
                close = true,
            },
            {
                text = 'Show me your supplies instead.',
                to = 'gideon_shop',
            },
        },
    },
  --- Silas Rook ----------------------------------------------------------

    silas_start = {
        text = 'Easy now, sailor. Silas Rook is the name. I know these shores, the people on them and the places best left undisturbed.',
        responses = {
            {
                text = 'Who are you?',
                to = 'silas_identity',
            },
            {
                text = 'Tell me about Cayo.',
                to = 'silas_cayo',
            },
            {
                text = 'Do you know Gideon Vance?',
                to = 'silas_gideon',
            },
            {
                text = 'I heard there is a secret bounty place.',
                to = 'silas_bounty',
            },
            {
                text = 'What should I know about other pirates?',
                to = 'silas_pirates',
            },
            {
                text = 'Where is the best place to find loot?',
                to = 'silas_north',
            },
            {
                text = 'Give me some advice.',
                to = 'silas_advice',
            },
            {
                text = 'That is all.',
                close = true,
            },
        },
    },

    silas_identity = {
        text = 'I once charted waters for crews with more greed than sense. Now I watch ships arrive, watch fools vanish and sell the truth to anyone willing to listen.',
        responses = {
            {
                text = 'Why stay on Cayo?',
                to = 'silas_staying',
            },
            {
                text = 'What do you know about this island?',
                to = 'silas_cayo',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_staying = {
        text = 'Every island has secrets. Cayo has enough to keep a man wealthy, hunted or dead. I prefer standing still and letting the secrets come to me.',
        responses = {
            {
                text = 'What secrets?',
                to = 'silas_secrets',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_secrets = {
        text = 'Hidden cargo, forgotten tunnels, guarded stores and a bounty room buried inside the villa. That is only what I am willing to say aloud.',
        responses = {
            {
                text = 'Tell me about the bounty room.',
                to = 'silas_bounty',
            },
            {
                text = 'Tell me about the villa.',
                to = 'silas_villa',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_cayo = {
        text = 'Cayo is no peaceful island. It is a private kingdom built on guarded roads, hidden wealth and men who shoot before asking questions. Stay off the open paths whenever you can.',
        responses = {
            {
                text = 'What is inside the villa?',
                to = 'silas_villa',
            },
            {
                text = 'Where should I search for loot?',
                to = 'silas_north',
            },
            {
                text = 'What lies beyond the island?',
                to = 'silas_beyond',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_gideon = {
        text = 'Gideon Vance keeps himself near the harbour. He sells water, food, bandages and whatever else washes into his hands. He is useful, but usefulness and kindness are not the same thing.',
        responses = {
            {
                text = 'Can Gideon be trusted?',
                to = 'silas_gideon_trust',
            },
            {
                text = 'Does Gideon offer work?',
                to = 'silas_gideon_work',
            },
            {
                text = 'Where does Gideon find his supplies?',
                to = 'silas_north',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_gideon_trust = {
        text = 'Gideon keeps his word when coin or goods are involved. Just count what he gives you and never tell him more than he needs to know.',
        responses = {
            {
                text = 'Does he offer work?',
                to = 'silas_gideon_work',
            },
            {
                text = 'I understand.',
                to = 'silas_start',
            },
        },
    },

    silas_gideon_work = {
        text = 'He has been searching for iron lately. Bring him ten good pieces and he will usually pay. Other pirates can take the same work, so do not expect the island to be empty.',
        responses = {
            {
                text = 'Where might I find iron?',
                to = 'silas_north',
            },
            {
                text = 'I will speak with Gideon.',
                to = 'silas_start',
            },
        },
    },

    silas_bounty = {
        text = 'There is a secret bounty place inside the villa. Most walk straight past it. Look around the private rooms and watch for an entrance that does not belong with the surrounding stonework.',
        responses = {
            {
                text = 'What happens inside?',
                to = 'silas_bounty_details',
            },
            {
                text = 'Is it guarded?',
                to = 'silas_villa_guards',
            },
            {
                text = 'Why keep it secret?',
                to = 'silas_bounty_secret',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_bounty_details = {
        text = 'That is where the island keeps work meant for hunters. Names, rewards and people worth tracking. Take a bounty if you dare, but remember that the person being hunted may be more prepared than you.',
        responses = {
            {
                text = 'Can other pirates take the same bounty?',
                to = 'silas_bounty_rivals',
            },
            {
                text = 'Tell me about the villa guards.',
                to = 'silas_villa_guards',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_bounty_rivals = {
        text = 'Never assume a bounty belongs only to you. Another pirate may be tracking the same prize, following you to it or waiting for you to finish the dangerous part before taking the reward.',
        responses = {
            {
                text = 'How do I protect myself?',
                to = 'silas_pirate_safety',
            },
            {
                text = 'Good to know.',
                to = 'silas_start',
            },
        },
    },

    silas_bounty_secret = {
        text = 'A public bounty board attracts desperate men. A hidden one attracts useful men. The villa prefers useful men, especially the sort who know when to keep quiet.',
        responses = {
            {
                text = 'What happens inside?',
                to = 'silas_bounty_details',
            },
            {
                text = 'I will keep quiet.',
                to = 'silas_start',
            },
        },
    },

    silas_pirates = {
        text = 'Other pirates are not part of the scenery. They are sailors like you, hungry for coin and watching for weakness. Some will trade. Some will lie. Some will wait until your pockets are full before striking.',
        responses = {
            {
                text = 'Can they take my loot?',
                to = 'silas_looting',
            },
            {
                text = 'How do I stay safe?',
                to = 'silas_pirate_safety',
            },
            {
                text = 'Can any pirate be trusted?',
                to = 'silas_trust',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_looting = {
        text = 'If another pirate puts you down while you are carrying valuables, expect them to search you and take whatever catches their eye. Secure your haul before greed makes you careless.',
        responses = {
            {
                text = 'How do I protect my loot?',
                to = 'silas_pirate_safety',
            },
            {
                text = 'Where can I find loot?',
                to = 'silas_north',
            },
            {
                text = 'I will remember that.',
                to = 'silas_start',
            },
        },
    },

    silas_pirate_safety = {
        text = 'Travel light, listen for footsteps and never stare into a crate for too long. Watch the water for approaching boats and keep an escape route behind you.',
        responses = {
            {
                text = 'What about travelling with a crew?',
                to = 'silas_crew',
            },
            {
                text = 'Where is the safest route?',
                to = 'silas_routes',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_trust = {
        text = 'Trust is another kind of currency. Spend too much and you become poor. A pirate may sail beside you today and empty your pockets tomorrow.',
        responses = {
            {
                text = 'What about joining a crew?',
                to = 'silas_crew',
            },
            {
                text = 'Fair warning.',
                to = 'silas_start',
            },
        },
    },

    silas_crew = {
        text = 'A steady crew means more eyes, more blades and someone to drag you home. It also means splitting the haul. Choose sailors who value survival more than a quick purse.',
        responses = {
            {
                text = 'Any other advice?',
                to = 'silas_advice',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_north = {
        text = 'Head north if loot is what you want. Best chance on the island, so I have heard. Search the old sheds, supply buildings and shoreline, but remember that every pirate eventually hears the same rumour.',
        responses = {
            {
                text = 'What might I find?',
                to = 'silas_north_loot',
            },
            {
                text = 'Will other pirates be there?',
                to = 'silas_north_rivals',
            },
            {
                text = 'Which route should I take?',
                to = 'silas_routes',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_north_loot = {
        text = 'Iron, abandoned supplies, washed-up cargo and whatever previous crews were forced to leave behind. Nothing is guaranteed except the danger.',
        responses = {
            {
                text = 'Gideon needs iron.',
                to = 'silas_gideon_work',
            },
            {
                text = 'What danger?',
                to = 'silas_north_rivals',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_north_rivals = {
        text = 'Most likely. The northern shore is quieter than the villa, not safer. Other pirates may already be searching, or waiting nearby to loot whoever finds something first.',
        responses = {
            {
                text = 'How do I stay safe?',
                to = 'silas_pirate_safety',
            },
            {
                text = 'I will take the risk.',
                to = 'silas_start',
            },
        },
    },

    silas_routes = {
        text = 'Follow the coast and avoid the main road. High ground lets you see patrols and sails approaching, but it also makes you easy to spot against the sky.',
        responses = {
            {
                text = 'Tell me more about the north.',
                to = 'silas_north',
            },
            {
                text = 'What about the villa?',
                to = 'silas_villa',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_villa = {
        text = 'The villa sits at the heart of the island like a crown on a thief. It holds wealth, guarded rooms and the hidden bounty place, but every entrance is watched.',
        responses = {
            {
                text = 'Where is the bounty place?',
                to = 'silas_bounty',
            },
            {
                text = 'Tell me about the guards.',
                to = 'silas_villa_guards',
            },
            {
                text = 'Is there another way inside?',
                to = 'silas_villa_entry',
            },
            {
                text = 'Let me ask something else.',
                to = 'silas_start',
            },
        },
    },

    silas_villa_guards = {
        text = 'The guards know the obvious roads and gates. They watch anyone who walks with confidence and shoot anyone who runs. Move slowly, use cover and do not stay in one place.',
        responses = {
            {
                text = 'Is there another entrance?',
                to = 'silas_villa_entry',
            },
            {
                text = 'Tell me about the bounty place.',
                to = 'silas_bounty',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_villa_entry = {
        text = 'Every grand building has servant paths, drainage routes and walls nobody checks often enough. I will not draw you a map, but the coastline reveals more than the front gate.',
        responses = {
            {
                text = 'Why not tell me exactly?',
                to = 'silas_no_map',
            },
            {
                text = 'I will search for myself.',
                to = 'silas_start',
            },
        },
    },

    silas_no_map = {
        text = 'Because if you are caught holding my directions, the guards come looking for me. A clue keeps us both alive. A map only makes one of us rich.',
        responses = {
            {
                text = 'Fair enough.',
                to = 'silas_start',
            },
        },
    },

    silas_beyond = {
        text = 'Beyond Cayo is open sea, scattered islands and crews chasing rumours. Some sail for trade, some for treasure and some only to take what another crew has earned.',
        responses = {
            {
                text = 'Is it safe to sail alone?',
                to = 'silas_sailing',
            },
            {
                text = 'Tell me about other pirates.',
                to = 'silas_pirates',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_sailing = {
        text = 'No sea is safe alone, but a quiet sailor can survive where a loud crew cannot. Keep supplies aboard, watch the horizon and never let another ship choose the distance between you.',
        responses = {
            {
                text = 'What supplies should I carry?',
                to = 'silas_supplies',
            },
            {
                text = 'Back to my other questions.',
                to = 'silas_start',
            },
        },
    },

    silas_supplies = {
        text = 'Water, food, bandages and a working radio. Gideon Vance can sell you the basics near the harbour. Buy them before you need them.',
        responses = {
            {
                text = 'Tell me about Gideon.',
                to = 'silas_gideon',
            },
            {
                text = 'Anything else?',
                to = 'silas_advice',
            },
        },
    },

    silas_advice = {
        text = 'Carry only what you can afford to lose. Bank your coin, secure your loot and remember that the quietest pirate nearby may be the one watching you closest.',
        responses = {
            {
                text = 'Where should I begin?',
                to = 'silas_north',
            },
            {
                text = 'Where can I buy supplies?',
                to = 'silas_gideon',
            },
            {
                text = 'Tell me about the secret bounty place.',
                to = 'silas_bounty',
            },
            {
                text = 'That is enough for now.',
                close = true,
            },
        },
    },

    --- Elias Ward ----------------------------------------------------------

    elias_start = {
        text = 'Elias Ward. I wore an LSPD badge before the sea swallowed the city. I saw the end of Los Santos with my own eyes.',
        responses = {
            {
                text = 'What happened to Los Santos?',
                to = 'elias_flood',
            },
            {
                text = 'You were really there?',
                to = 'elias_firsthand',
            },
            {
                text = 'Where did all these islands come from?',
                to = 'elias_islands',
            },
            {
                text = 'What happened to the LSPD?',
                to = 'elias_lspd',
            },
            {
                text = 'How did people become pirates?',
                to = 'elias_pirates',
            },
            {
                text = 'Is there anything I can do for you?',
                quest = {
                    id = 'drowned_necklace',
                    state = 'available',
                },
                to = 'elias_quest_offer',
            },
            {
                text = 'Tell me about the necklace again.',
                quest = {
                    id = 'drowned_necklace',
                    state = 'active',
                },
                to = 'elias_quest_active',
            },
            {
                text = 'I found your necklace.',
                quest = {
                    id = 'drowned_necklace',
                    state = 'complete',
                },
                to = 'elias_quest_complete',
            },
            {
                text = 'How are you holding up?',
                quest = {
                    id = 'drowned_necklace',
                    state = 'done',
                },
                to = 'elias_quest_done',
            },
            {
                text = 'I should get moving.',
                close = true,
            },
        },
    },

    elias_flood = {
        text = 'It began with rain that refused to stop. Then the drains reversed, the sea walls failed and water came pouring through every street from Vespucci to Mission Row.',
        responses = {
            {
                text = 'How quickly did it happen?',
                to = 'elias_flood_speed',
            },
            {
                text = 'What happened after the water arrived?',
                to = 'elias_islands',
            },
            {
                text = 'What were the police doing?',
                to = 'elias_lspd',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_flood_speed = {
        text = 'By sunrise, Del Perro was beneath the waves. By nightfall, downtown had become a maze of rooftops and broken towers. The city disappeared faster than anyone could evacuate it.',
        responses = {
            {
                text = 'You saw all of that?',
                to = 'elias_firsthand',
            },
            {
                text = 'Where did the islands come from?',
                to = 'elias_islands',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_firsthand = {
        text = 'I was a sergeant at Mission Row. Dispatch calls came from every district at once. Families trapped on roofs, officers swept from roads and boats sinking beneath the weight of survivors.',
        responses = {
            {
                text = 'Did you try to evacuate people?',
                to = 'elias_evacuation',
            },
            {
                text = 'What happened to Mission Row?',
                to = 'elias_mission_row',
            },
            {
                text = 'How did you escape?',
                to = 'elias_escape',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_evacuation = {
        text = 'We used patrol boats, seized fishing vessels and tied doors together as rafts. For every person we pulled aboard, ten more were calling for help.',
        responses = {
            {
                text = 'What happened to the other officers?',
                to = 'elias_lspd',
            },
            {
                text = 'How did you survive?',
                to = 'elias_escape',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_mission_row = {
        text = 'Mission Row became an island for a few hours. Then the lower floors flooded and the foundations gave way. The last transmission said the emergency beacon was still running.',
        responses = {
            {
                text = 'Is any of it still there?',
                to = 'elias_ruins',
            },
            {
                text = 'What happened to the LSPD?',
                to = 'elias_lspd',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_ruins = {
        text = 'Pieces of the old city still break the surface. Rooftops, radio towers and the tops of buildings. Pirates search those ruins for weapons, metal and anything the water has not destroyed.',
        responses = {
            {
                text = 'Are the ruins dangerous?',
                to = 'elias_ruins_danger',
            },
            {
                text = 'Where did the new islands come from?',
                to = 'elias_islands',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_ruins_danger = {
        text = 'The buildings are unstable, the water hides sharp wreckage and other pirates may already be searching. A full bag makes you valuable prey.',
        responses = {
            {
                text = 'Tell me about the pirates.',
                to = 'elias_pirates',
            },
            {
                text = 'I will be careful.',
                to = 'elias_start',
            },
        },
    },

    elias_escape = {
        text = 'I found a police launch near the courthouse. Six of us left the city aboard it. A wave took four before we reached open water. I have carried their names ever since.',
        responses = {
            {
                text = 'Where did you go?',
                to = 'elias_islands',
            },
            {
                text = 'Did you lose anything else?',
                quest = {
                    id = 'drowned_necklace',
                    state = 'available',
                },
                to = 'elias_quest_offer',
            },
            {
                text = 'I am sorry.',
                to = 'elias_start',
            },
        },
    },

    elias_islands = {
        text = 'The strangest part came after the flood. The seabed began to shake. Land rose through the water where no land had ever been marked on our charts.',
        responses = {
            {
                text = 'The islands appeared from nowhere?',
                to = 'elias_islands_rise',
            },
            {
                text = 'What was on them?',
                to = 'elias_island_contents',
            },
            {
                text = 'How did people survive?',
                to = 'elias_survivors',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_islands_rise = {
        text = 'Some rose slowly over weeks. Others appeared overnight after violent storms. Forests, ruins and beaches surfaced as if they had been waiting beneath us for centuries.',
        responses = {
            {
                text = 'Does anyone know why?',
                to = 'elias_cause',
            },
            {
                text = 'What was found on them?',
                to = 'elias_island_contents',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_cause = {
        text = 'Scientists blamed shifting plates. Sailors blamed curses. The government stopped answering before anyone found the truth. Believe whichever story helps you sleep.',
        responses = {
            {
                text = 'What do you believe?',
                to = 'elias_belief',
            },
            {
                text = 'Tell me about the survivors.',
                to = 'elias_survivors',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_belief = {
        text = 'I believe the sea took one world and gave us another. Whether that was nature or punishment no longer matters. We still have to survive it.',
        responses = {
            {
                text = 'How do people survive now?',
                to = 'elias_survivors',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_island_contents = {
        text = 'Some islands carried old ruins. Others had forests, caves and strange structures. Every new shore offered supplies, treasure and another reason for crews to fight.',
        responses = {
            {
                text = 'Is that how piracy began?',
                to = 'elias_pirates',
            },
            {
                text = 'What should I search for?',
                to = 'elias_loot',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_survivors = {
        text = 'Survivors gathered on rooftops, ships and the new islands. Coin replaced banks, crews replaced governments and a strong vessel became more valuable than any house.',
        responses = {
            {
                text = 'What happened to the law?',
                to = 'elias_lspd',
            },
            {
                text = 'Is that how people became pirates?',
                to = 'elias_pirates',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_lspd = {
        text = 'The LSPD tried to hold together, but there was no city left to police. Precincts vanished, communications failed and officers became rescuers, sailors or bodies beneath the water.',
        responses = {
            {
                text = 'Did any officers survive?',
                to = 'elias_officers',
            },
            {
                text = 'Do you still consider yourself police?',
                to = 'elias_badge',
            },
            {
                text = 'What happened at Mission Row?',
                to = 'elias_mission_row',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_officers = {
        text = 'A few survived. Some protect settlements. Some became mercenaries. Others discovered that a badge and a pirate flag are not as different as they once believed.',
        responses = {
            {
                text = 'What about you?',
                to = 'elias_badge',
            },
            {
                text = 'Tell me about the pirates.',
                to = 'elias_pirates',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_badge = {
        text = 'The badge meant something when there were courts, laws and people waiting for help. Now I keep it to remember who I was, not to pretend I still have authority.',
        responses = {
            {
                text = 'Did you lose anyone?',
                quest = {
                    id = 'drowned_necklace',
                    state = 'available',
                },
                to = 'elias_quest_offer',
            },
            {
                text = 'I understand.',
                to = 'elias_start',
            },
        },
    },

    elias_pirates = {
        text = 'When supplies became scarce, ships became kingdoms. Some crews traded and protected people. Others discovered it was easier to loot another sailor than search the ruins themselves.',
        responses = {
            {
                text = 'Can other pirates take my loot?',
                to = 'elias_pirate_warning',
            },
            {
                text = 'Can anyone be trusted?',
                to = 'elias_trust',
            },
            {
                text = 'Where should I search for supplies?',
                to = 'elias_loot',
            },
            {
                text = 'Let me ask something else.',
                to = 'elias_start',
            },
        },
    },

    elias_pirate_warning = {
        text = 'Other pirates may follow you, kill you and take whatever you are carrying. Store valuable cargo whenever possible and never assume another crew is friendly.',
        responses = {
            {
                text = 'How do I stay safe?',
                to = 'elias_safety',
            },
            {
                text = 'Can anyone be trusted?',
                to = 'elias_trust',
            },
            {
                text = 'I will remember that.',
                to = 'elias_start',
            },
        },
    },

    elias_trust = {
        text = 'Trust actions, not flags. A friendly wave costs nothing. A pirate who shares food, guards your back and divides the haul fairly may be worth keeping close.',
        responses = {
            {
                text = 'Any other advice?',
                to = 'elias_safety',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_safety = {
        text = 'Carry water, bandages and only as much loot as you can defend. Watch the horizon, listen for engines and always know where your boat is.',
        responses = {
            {
                text = 'Where can I buy supplies?',
                to = 'elias_supplies',
            },
            {
                text = 'Where should I search?',
                to = 'elias_loot',
            },
            {
                text = 'That is useful.',
                to = 'elias_start',
            },
        },
    },

    elias_supplies = {
        text = 'Gideon Vance sells simple supplies nearby. Water, food, bandages and radios. He also pays well for iron when he has work available.',
        responses = {
            {
                text = 'Where does Gideon find his goods?',
                to = 'elias_loot',
            },
            {
                text = 'I will speak with Gideon.',
                to = 'elias_start',
            },
        },
    },

    elias_loot = {
        text = 'The northern shores are usually your best chance. Search old buildings, shipwrecks and anything recently exposed by the tide. Just remember that other pirates know the same places.',
        responses = {
            {
                text = 'What might I find?',
                to = 'elias_loot_items',
            },
            {
                text = 'What about the old city?',
                to = 'elias_ruins',
            },
            {
                text = 'Back to my other questions.',
                to = 'elias_start',
            },
        },
    },

    elias_loot_items = {
        text = 'Iron, food, medical supplies, jewellery and old-world equipment. Something worthless to one sailor may be worth thousands of coins to another.',
        responses = {
            {
                text = 'Jewellery?',
                quest = {
                    id = 'drowned_necklace',
                    state = 'available',
                },
                to = 'elias_quest_offer',
            },
            {
                text = 'I will start searching.',
                to = 'elias_start',
            },
        },
    },

    elias_quest_offer = {
        text = 'My wife wore a silver necklace the night Los Santos flooded. It was inside a blue case aboard our evacuation boat when the vessel broke apart.',
        responses = {
            {
                text = 'Do you think it survived?',
                to = 'elias_necklace_story',
            },
            {
                text = 'What will you pay for it?',
                to = 'elias_necklace_reward',
            },
            {
                text = 'I will find it.',
                startQuest = 'drowned_necklace',
                close = true,
            },
            {
                text = 'I cannot help you.',
                close = true,
            },
        },
    },

    elias_necklace_story = {
        text = 'The sea gives old possessions back every day. Pirates have reported seeing the necklace traded between wrecks and hidden caches. I know it is still out there.',
        responses = {
            {
                text = 'Is there a deadline?',
                to = 'elias_necklace_deadline',
            },
            {
                text = 'What will you pay?',
                to = 'elias_necklace_reward',
            },
            {
                text = 'I will search for it.',
                startQuest = 'drowned_necklace',
                close = true,
            },
            {
                text = 'Not right now.',
                close = true,
            },
        },
    },

    elias_necklace_deadline = {
        text = 'There is no deadline. Bring it back tomorrow or a lifetime from now. I have already waited through the end of the world.',
        responses = {
            {
                text = 'I will find it.',
                startQuest = 'drowned_necklace',
                close = true,
            },
            {
                text = 'What is the reward?',
                to = 'elias_necklace_reward',
            },
            {
                text = 'I cannot promise anything.',
                close = true,
            },
        },
    },

    elias_necklace_reward = {
        text = 'Twenty thousand coins. More than the silver is worth, but I am not paying for silver. I am paying for what it carries.',
        responses = {
            {
                text = 'We have a deal.',
                startQuest = 'drowned_necklace',
                close = true,
            },
            {
                text = 'I need to think about it.',
                close = true,
            },
        },
    },

    elias_quest_active = {
        text = 'The necklace is silver with a small blue stone. It may be inside a wreck, a hidden cache or the pockets of another pirate. There is no deadline.',
        responses = {
            {
                text = 'I will keep searching.',
                close = true,
            },
            {
                text = 'Where should I search?',
                to = 'elias_necklace_search',
            },
        },
    },

    elias_necklace_search = {
        text = 'Start with shipwrecks and caches along the northern shores. If another pirate has it, coin or steel may be the only language they understand.',
        responses = {
            {
                text = 'I will bring it back.',
                close = true,
            },
        },
    },

    elias_quest_complete = {
        text = 'That blue stone... I never thought I would see it again. Hand it to me and the twenty thousand coins are yours.',
        responses = {
            {
                text = 'Here is the necklace.',
                finishQuest = 'drowned_necklace',
                close = true,
            },
            {
                text = 'I am not ready to hand it over.',
                close = true,
            },
        },
    },

    elias_quest_done = {
        text = 'You gave me back the last piece of my old life. There are not enough coins left in the world to properly repay that.',
        responses = {
            {
                text = 'Tell me about Los Santos again.',
                to = 'elias_flood',
            },
            {
                text = 'Take care of yourself.',
                close = true,
            },
        },
    },
    --- Tobias Keel ---------------------------------------------------------

    tobias_start = {
        text = 'Mind the wet boards. Tobias Keel, dock worker and unwilling expert on anything that floats.',
        responses = {
            {
                text = 'What kinds of boats are there?',
                to = 'tobias_boat_types',
            },
            {
                text = 'Tell me about the old medieval ships.',
                to = 'tobias_medieval',
            },
            {
                text = 'What were the old war boats like?',
                to = 'tobias_warships',
            },
            {
                text = 'What modern boats are available?',
                to = 'tobias_modern',
            },
            {
                text = 'Tell me about the new technology.',
                to = 'tobias_new_technology',
            },
            {
                text = 'Which boat should I choose?',
                to = 'tobias_choose_boat',
            },
            {
                text = 'I am going on my first voyage.',
                quest = {
                    id = 'first_voyage_telescope',
                    state = 'available',
                },
                startQuest = 'first_voyage_telescope',
                to = 'tobias_first_voyage',
            },
            {
                text = 'About that telescope.',
                quest = {
                    id = 'first_voyage_telescope',
                    state = 'complete',
                },
                to = 'tobias_telescope_retry',
            },
            {
                text = 'I should get moving.',
                close = true,
            },
        },
    },

    tobias_boat_types = {
        text = 'Boats are like sailors. Some are quick, some are stubborn and some need a dozen people just to stop them falling apart.',
        responses = {
            {
                text = 'What is best for one sailor?',
                to = 'tobias_sloop',
            },
            {
                text = 'What is best for a small crew?',
                to = 'tobias_brigantine',
            },
            {
                text = 'What is best for a large crew?',
                to = 'tobias_galleon',
            },
            {
                text = 'Tell me about medieval ships.',
                to = 'tobias_medieval',
            },
            {
                text = 'Tell me about modern ships.',
                to = 'tobias_modern',
            },
            {
                text = 'Back to my other questions.',
                to = 'tobias_start',
            },
        },
    },

    tobias_medieval = {
        text = 'Medieval sailors had cogs for cargo, longships for raiding and galleys powered by rows of exhausted men. Slow by modern standards, but strong enough to build kingdoms.',
        responses = {
            {
                text = 'Tell me about cogs.',
                to = 'tobias_cog',
            },
            {
                text = 'Tell me about longships.',
                to = 'tobias_longship',
            },
            {
                text = 'Tell me about galleys.',
                to = 'tobias_galley',
            },
            {
                text = 'What did they use for war?',
                to = 'tobias_warships',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_cog = {
        text = 'A cog is broad, heavy and dependable. Merchants filled them with timber, iron, grain and coin. They were not quick, but they could carry enough cargo to supply an entire settlement.',
        responses = {
            {
                text = 'Were they good in battle?',
                to = 'tobias_cog_battle',
            },
            {
                text = 'Tell me about another ship.',
                to = 'tobias_medieval',
            },
        },
    },

    tobias_cog_battle = {
        text = 'Not by choice. Crews built raised platforms for archers and reinforced the sides, but a cog was still a merchant vessel pretending to be a warship.',
        responses = {
            {
                text = 'What was a proper warship?',
                to = 'tobias_warships',
            },
            {
                text = 'Back to the other boats.',
                to = 'tobias_boat_types',
            },
        },
    },

    tobias_longship = {
        text = 'Longships were narrow, shallow and frighteningly fast. They could cross open water, enter rivers and land directly on a beach before defenders knew a raid had begun.',
        responses = {
            {
                text = 'Did they only use sails?',
                to = 'tobias_longship_power',
            },
            {
                text = 'Tell me about another ship.',
                to = 'tobias_medieval',
            },
        },
    },

    tobias_longship_power = {
        text = 'Sails when the wind behaved, oars when it did not. That made a longship dangerous in places where larger sailing vessels became trapped.',
        responses = {
            {
                text = 'What about modern fast boats?',
                to = 'tobias_fast_boats',
            },
            {
                text = 'Back to the old ships.',
                to = 'tobias_medieval',
            },
        },
    },

    tobias_galley = {
        text = 'A galley carried sails, but rows of oars gave it control without wind. Naval powers used them for ramming, boarding and moving soldiers along calm coastal waters.',
        responses = {
            {
                text = 'Were they good on the open sea?',
                to = 'tobias_galley_ocean',
            },
            {
                text = 'Tell me about another ship.',
                to = 'tobias_medieval',
            },
        },
    },

    tobias_galley_ocean = {
        text = 'Not particularly. A galley needed too many people, too many supplies and calm enough water for its low deck. Oceans punish ships built for sheltered seas.',
        responses = {
            {
                text = 'What replaced them?',
                to = 'tobias_warships',
            },
            {
                text = 'Back to the other boats.',
                to = 'tobias_boat_types',
            },
        },
    },

    tobias_warships = {
        text = 'Warships grew from longships and galleys into carracks, galleons and great ships lined with cannon. Battles stopped being about ramming and became thunder heard across the sea.',
        responses = {
            {
                text = 'Tell me about carracks.',
                to = 'tobias_carrack',
            },
            {
                text = 'Tell me about galleons.',
                to = 'tobias_galleon_history',
            },
            {
                text = 'What about modern warships?',
                to = 'tobias_modern_warship',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_carrack = {
        text = 'Carracks were tall ocean-crossing ships with high castles at the bow and stern. They carried cargo, soldiers and cannon, making them useful for trade and conquest.',
        responses = {
            {
                text = 'How did that become a galleon?',
                to = 'tobias_galleon_history',
            },
            {
                text = 'Back to the warships.',
                to = 'tobias_warships',
            },
        },
    },

    tobias_galleon_history = {
        text = 'Galleons lowered the bulky castles, lengthened the hull and carried heavy cannon along both sides. They hauled treasure across oceans and became prizes every pirate dreamed of taking.',
        responses = {
            {
                text = 'Can I sail one?',
                to = 'tobias_galleon',
            },
            {
                text = 'Back to the warships.',
                to = 'tobias_warships',
            },
        },
    },

    tobias_modern = {
        text = 'Modern boats trade canvas and oars for engines, steel hulls and electronics. They move without wind, travel faster and tell a captain what is nearby before it can be seen.',
        responses = {
            {
                text = 'Tell me about fast boats.',
                to = 'tobias_fast_boats',
            },
            {
                text = 'Tell me about modern warships.',
                to = 'tobias_modern_warship',
            },
            {
                text = 'What technology do they carry?',
                to = 'tobias_new_technology',
            },
            {
                text = 'Are old ships still useful?',
                to = 'tobias_old_against_new',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_fast_boats = {
        text = 'Fast boats use powerful engines and light hulls. Good for scouting, chasing smugglers or escaping a larger vessel before its guns find the range.',
        responses = {
            {
                text = 'What is the weakness?',
                to = 'tobias_fast_boat_weakness',
            },
            {
                text = 'Tell me about another boat.',
                to = 'tobias_modern',
            },
        },
    },

    tobias_fast_boat_weakness = {
        text = 'Small fuel tanks, limited cargo and very little protection. Speed keeps you alive until the engine fails. Then you are sitting in a wooden coffin without the wood.',
        responses = {
            {
                text = 'What should I carry aboard?',
                to = 'tobias_supplies',
            },
            {
                text = 'Back to modern boats.',
                to = 'tobias_modern',
            },
        },
    },

    tobias_modern_warship = {
        text = 'Modern warships are steel fortresses with engines, radar and weapons that strike beyond sight. Powerful, expensive and useless without a trained crew keeping every system alive.',
        responses = {
            {
                text = 'What technology do they use?',
                to = 'tobias_new_technology',
            },
            {
                text = 'Could an old ship defeat one?',
                to = 'tobias_old_against_new',
            },
            {
                text = 'Back to the warships.',
                to = 'tobias_warships',
            },
        },
    },

    tobias_new_technology = {
        text = 'Radar finds ships through darkness and fog. Sonar listens beneath the water. Reinforced hulls survive harder impacts, while navigation equipment replaces stars and guesswork.',
        responses = {
            {
                text = 'What if the technology fails?',
                to = 'tobias_technology_failure',
            },
            {
                text = 'Does technology make sailing easy?',
                to = 'tobias_sailing_skill',
            },
            {
                text = 'Back to the modern boats.',
                to = 'tobias_modern',
            },
        },
    },

    tobias_technology_failure = {
        text = 'Then the modern captain reaches for an old compass and discovers whether he is a sailor or merely someone who knew which buttons to press.',
        responses = {
            {
                text = 'What should every sailor know?',
                to = 'tobias_sailing_skill',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_old_against_new = {
        text = 'A new boat has speed and machinery. An old sailing ship has silence, range and no need for fuel. With the right crew and weather, either one can send the other beneath the waves.',
        responses = {
            {
                text = 'Which would you choose?',
                to = 'tobias_personal_choice',
            },
            {
                text = 'Help me choose a boat.',
                to = 'tobias_choose_boat',
            },
        },
    },

    tobias_personal_choice = {
        text = 'Give me a sturdy brigantine, a loyal crew and enough canvas to outrun whatever I cannot outfight.',
        responses = {
            {
                text = 'Tell me about brigantines.',
                to = 'tobias_brigantine',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_choose_boat = {
        text = 'Tell me how you plan to sail and I will tell you what should carry you.',
        responses = {
            {
                text = 'I will usually sail alone.',
                to = 'tobias_sloop',
            },
            {
                text = 'I have a small crew.',
                to = 'tobias_brigantine',
            },
            {
                text = 'I have a large crew.',
                to = 'tobias_galleon',
            },
            {
                text = 'I want to move cargo.',
                to = 'tobias_cargo_boat',
            },
            {
                text = 'I want speed above everything.',
                to = 'tobias_fast_boats',
            },
            {
                text = 'I want to fight.',
                to = 'tobias_combat_choice',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_sloop = {
        text = 'Choose a sloop. Small, quick to turn and manageable by one sailor. It will not win a broadside against a galleon, but it can sail circles around one.',
        responses = {
            {
                text = 'What should I carry aboard?',
                to = 'tobias_supplies',
            },
            {
                text = 'What if I find a crew?',
                to = 'tobias_brigantine',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_brigantine = {
        text = 'A brigantine suits a small crew. Faster than a galleon, stronger than a sloop and large enough to carry supplies without becoming impossible to manage.',
        responses = {
            {
                text = 'Is it good for fighting?',
                to = 'tobias_combat_choice',
            },
            {
                text = 'What should we carry?',
                to = 'tobias_supplies',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_galleon = {
        text = 'A galleon gives a large crew cannon, cargo space and enough hull to survive a proper fight. Without enough hands, it becomes a slow-moving gift for pirates.',
        responses = {
            {
                text = 'What crew does it need?',
                to = 'tobias_galleon_crew',
            },
            {
                text = 'What should we carry?',
                to = 'tobias_supplies',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_galleon_crew = {
        text = 'You need someone steering, someone watching the sails, someone repairing and several hands on the cannon. A captain trying to do everything will do nothing well.',
        responses = {
            {
                text = 'What about combat?',
                to = 'tobias_combat_choice',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_cargo_boat = {
        text = 'For cargo, choose stability and storage before speed. A heavy vessel earns coin only if it survives long enough to reach another harbour.',
        responses = {
            {
                text = 'How do I protect the cargo?',
                to = 'tobias_protect_cargo',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_protect_cargo = {
        text = 'Avoid predictable routes, keep lookouts posted and never show strangers how much you loaded. A pirate cannot plan an ambush around cargo he does not know exists.',
        responses = {
            {
                text = 'What if pirates attack?',
                to = 'tobias_combat_choice',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_combat_choice = {
        text = 'For direct combat, bring a crewed galleon. For hunting and escape, use a brigantine. A skilled sloop captain should fight with speed and position, never pride.',
        responses = {
            {
                text = 'Tell me about the galleon.',
                to = 'tobias_galleon',
            },
            {
                text = 'Tell me about the brigantine.',
                to = 'tobias_brigantine',
            },
            {
                text = 'Tell me about the sloop.',
                to = 'tobias_sloop',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_sailing_skill = {
        text = 'Learn the wind, read the waves and watch the horizon. Technology helps, but good judgement keeps a ship afloat when everything else stops working.',
        responses = {
            {
                text = 'What supplies should I carry?',
                to = 'tobias_supplies',
            },
            {
                text = 'Help me choose a boat.',
                to = 'tobias_choose_boat',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_supplies = {
        text = 'Carry water, food, bandages, repair materials and a working radio. A telescope is worth keeping too. Seeing trouble early is better than surviving it late.',
        responses = {
            {
                text = 'I am going on my first voyage.',
                quest = {
                    id = 'first_voyage_telescope',
                    state = 'available',
                },
                startQuest = 'first_voyage_telescope',
                to = 'tobias_first_voyage',
            },
            {
                text = 'Back to the dock.',
                to = 'tobias_start',
            },
        },
    },

    tobias_first_voyage = {
        text = 'Your first voyage? Then take this telescope. No charge. Every sailor deserves to see danger before danger sees them.',
        responses = {
            {
                text = 'Thank you. I will put it to good use.',
                finishQuest = 'first_voyage_telescope',
                close = true,
            },
        },
    },

    tobias_telescope_retry = {
        text = 'I still have that telescope for you. Make some room and take it before your ship leaves without you.',
        responses = {
            {
                text = 'I have room for it now.',
                finishQuest = 'first_voyage_telescope',
                close = true,
            },
        },
    },

 
}
