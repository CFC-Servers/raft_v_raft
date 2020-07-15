GM.Config = GM.Config or {}
GM.Config.Party = GM.Config.Party or {}

local config = GM.Config.Party

config.INVITE_LIFETIME = 30
config.MAX_PLAYERS = 4
config.ALLOW_FRIENDLY_FIRE = false
config.MIN_PARTY_NAME_LENGTH = 5
config.MAX_PARTY_NAME_LENGTH = 30
config.INVITE_COOLDOWN = 30

-- Don't change unless you're a dev / know what you're doing
config.OVERRIDE_CHAT_ADD = true
