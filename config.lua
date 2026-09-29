--- SeaM_Npcs :: configuration
--- The places you can talk to someone are in shared/points.lua and what they
--- say is in shared/dialogue.lua. Nothing is spawned: these attach to whoever
--- is already standing there.

Config = {}

--- Interaction --------------------------------------------------------------
--- 'auto' uses SeaM_Target when it is running and a walk-in prompt when it is
--- not. Nothing is drawn on the ground either way.
Config.Interaction = 'auto' -- 'auto' | 'target' | 'marker'

--- How close the walk-in prompt appears, when there is no target script.
Config.PointDistance = 2.0

--- Reach of the third eye option, from you to the ped.
Config.TargetDistance = 2.5

--- Without a target script the prompt has to pick someone for you. This is how
--- far it will look for a ped, from the point itself.
Config.NearestPedDistance = 8.0

--- Conversation -------------------------------------------------------------
Config.Conversation = {
    --- Milliseconds per character as the NPC's line types out. 0 shows it all
    --- at once.
    Speed = 18,

    --- The NPC turns to face you while you are talking to them.
    FacePlayer = true,

    --- Walking away ends it. Metres from where the conversation started.
    LeashDistance = 6.0,
}

--- Interface ----------------------------------------------------------------
Config.UI = {
    --- Brass-gold accent used by the parchment interface.
    accent = '#c7923e',

    --- Show 1-9 beside each answer. The keys work either way.
    ShowKeys = true,
}

--- Quests -------------------------------------------------------------------
Config.Quests = {
    --- The on-screen list of what you are part way through.
    Tracker = true,

    --- Where that list sits. 0 to 1 across the screen.
    TrackerX = 0.885,
    TrackerY = 0.34,

    --- Put a blip on `visit` objectives.
    Waypoint = true,

    --- Write completions through the core logger.
    Log = true,
}

--- Logging ------------------------------------------------------------------
--- Anything a conversation hands over or takes away goes through the core
--- logger, so a dialogue tree that pays out is auditable.
Config.LogRewards = true
