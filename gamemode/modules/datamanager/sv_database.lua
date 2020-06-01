RVR = RVR or {}
RVR.DataManager = RVR.DataManager or {}

local DB = RVR.DataManager

-- todo: all of this l o l
function DB.create()
    sql.Begin()
    sql.Query( [[
        CREATE TABLE player_data(SteamID TEXT, Money INTEGER)
    ]] )
end