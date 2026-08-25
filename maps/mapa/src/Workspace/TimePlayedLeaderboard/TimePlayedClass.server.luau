--[[
  TimePlayedClass, RenanMSV @2023

  A script designed to update a leaderboard with
  the top 10 players who most play your game.
  
  Do not change this script. All configurations can be found
  in the Settings script.
]]

local PlayersService = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(script.Parent.Settings)

local TimePlayedClass = {}
TimePlayedClass.__index = TimePlayedClass


function TimePlayedClass.new()
  local new = {}
  setmetatable(new, TimePlayedClass)

  new._dataStoreName = Config.DATA_STORE
  new._dataStoreStatName = Config.NAME_OF_STAT
  new._scoreUpdateDelay = Config.SCORE_UPDATE * 60
  new._boardUpdateDelay = Config.LEADERBOARD_UPDATE * 60
  new._useLeaderstats = Config.USE_LEADERSTATS
  new._nameLeaderstats = Config.NAME_LEADERSTATS
  new._show1stPlaceAvatar = Config.SHOW_1ST_PLACE_AVATAR
  if new._show1stPlaceAvatar == nil then new._show1stPlaceAvatar = true end
  new._doDebug = Config.DO_DEBUG

  new._datastore = nil
  new._scoreBlock = script.Parent.ScoreBlock
  new._updateBoardTimer = script.Parent.UpdateBoardTimer.Timer.TextLabel

  new._apiServicesEnabled = false
  new._isMainScript = nil

  new._isDancingRigEnabled = false
  new._dancingRigModule = nil
  
  new._usernameCache = {}
  new._thumbnailCache = {}

  new:_init()

  return new
end


function TimePlayedClass:_init()

  if self._doDebug then
    warn("TopTimePlayed Board: Debugging is enabled.")
  end

  self:_checkIsMainScript()

  if self._isMainScript then
    if not self:_checkDataStoreUp() then
      self:_clearBoard()
      self._scoreBlock.NoAPIServices.Warning.Visible = true
      return
    end
  else
    self._apiServicesEnabled = (ServerStorage:WaitForChild("TopTimePlayedLeaderboard_NoAPIServices_Flag", 99) :: BoolValue).Value
    if not self._apiServicesEnabled then
      self:_clearBoard()
      self._scoreBlock.NoAPIServices.Warning.Visible = true
      return
    end
  end

  local suc, err = pcall(function ()
    self._datastore = game:GetService("DataStoreService"):GetOrderedDataStore(self._dataStoreName)
  end)
  if not suc or self._datastore == nil then warn("Failed to load OrderedDataStore. Error:", err) script.Parent:Destroy() end

  self:_checkDancingRigEnabled()

  -- puts leaderstat value in player
  if self._useLeaderstats and self._isMainScript then
    local function createLeaderstats (player)
      task.spawn(function ()
        local stat = Instance.new("NumberValue")
        stat.Name = self._nameLeaderstats
        if self._doDebug then print("Searching for the player's leaderstats folder") end
        -- creates the leaderstats folder in case it does not find one in 8 seconds
        local leaderstatsFolder = player:WaitForChild("leaderstats", 8)
        if not leaderstatsFolder then
          if self._doDebug then print("Could not find the player's leaderstats folder. Creating one.") end
          leaderstatsFolder = Instance.new("Configuration")
          leaderstatsFolder.Name = "leaderstats"
          leaderstatsFolder.Parent = player
        end
        stat.Parent = leaderstatsFolder
        -- retrieves and updates leaderstat value to the player's time saved in the datastore
        local success, resultOrError = pcall(function ()
          return self._datastore:GetAsync(self._dataStoreStatName .. player.UserId)
        end)
        stat.Value = not success and 0 or resultOrError
        if self._doDebug and not success then print("Failed to GetAsync the player's time played. Will retry later.") end
      end)
    end
    for _, player: Player in pairs(PlayersService:GetPlayers()) do
      createLeaderstats(player)
    end
    PlayersService.PlayerAdded:Connect(function (player)
      createLeaderstats(player)
    end)
  end
  -- increments players time in the datastore
  task.spawn(function ()
    if not self._isMainScript then return end
    while true do
      task.wait(self._scoreUpdateDelay)
      self:_updateScore()
    end
  end)

  -- update leaderboard
  task.spawn(function ()
    self:_updateBoard() -- update once
    local count = self._boardUpdateDelay
    while true do
      task.wait(1)
      count -= 1
      self._updateBoardTimer.Text = ("Updating the board in %d seconds"):format(count)
      if count <= 0 then
        self:_updateBoard()
        count = self._boardUpdateDelay
      end
    end
  end)

end


function TimePlayedClass:_clearBoard ()
  for _, folder in pairs({self._scoreBlock.Leaderboard.Names, self._scoreBlock.Leaderboard.Photos, self._scoreBlock.Leaderboard.Score}) do
    for _, item in pairs(folder:GetChildren()) do
      item.Visible = false
    end
  end
end


function TimePlayedClass:_updateBoard ()
  if self._doDebug then print("Updating board") end
  local results = nil

  local suc, results = pcall(function ()
    return self._datastore:GetSortedAsync(false, 10, 1):GetCurrentPage()
  end)

  if not suc or not results then
    if self._doDebug then warn("Failed to retrieve top 10 with most time. Error:", results) end
    return
  end

  local sufgui = self._scoreBlock.Leaderboard
  self._scoreBlock.Credits.Enabled = true
  self._scoreBlock.Leaderboard.Enabled = #results ~= 0
  self._scoreBlock.NoDataFound.Enabled = #results == 0
  self:_clearBoard()
  for k, v in pairs(results) do
    local userid = tonumber(string.split(v.key, self._dataStoreStatName)[2])
    local name: string, thumbnail: string
    if userid <= 0 then -- ids below 0 are given for roblox studio test players
      name = "Studio Test Profile"
      thumbnail = "rbxassetid://11569282129"
    else
      name = self:_getUsernameAsync(userid)
      thumbnail = self:_getThumbnailAsync(userid)
    end
    local score = self:_timeToString(v.value)
    self:_onPlayerScoreUpdate(userid, v.value)
    sufgui.Names["Name"..k].Visible = true
    sufgui.Score["Score"..k].Visible = true
    sufgui.Photos["Photo"..k].Visible = true
    sufgui.Names["Name"..k].Text = name
    sufgui.Score["Score"..k].Text = score
    sufgui.Photos["Photo"..k].Image = thumbnail
    if k == 1 and self._dancingRigModule then
      task.spawn(function ()
        self._dancingRigModule.SetRigHumanoidDescription(userid > 0 and userid or 1)
      end)
    end
  end
  if self._scoreBlock:FindFirstChild("_backside") then self._scoreBlock["_backside"]:Destroy() end
  local temp = self._scoreBlock.Leaderboard:Clone()
  temp.Parent = self._scoreBlock
  temp.Name = "_backside"
  temp.Face = Enum.NormalId.Back
  if self._doDebug then print("Board updated sucessfully") end
end


function TimePlayedClass:_updateScore ()
  local suc, err = coroutine.resume(coroutine.create(function ()
    local players = PlayersService:GetPlayers()
    for _, player in pairs(players) do
      local stat = self._dataStoreStatName .. player.UserId
      local newval = self._datastore:IncrementAsync(stat, self._scoreUpdateDelay / 60)
      if self._doDebug then print("Incremented time played stat of", player, stat, "to", newval) end
    end
  end))
  if not suc then warn(err) end
end


function TimePlayedClass:_onPlayerScoreUpdate (userid, minutes)
  -- updates leaderstats if enabled
  if not self._useLeaderstats then return end
  if not self._isMainScript then return end
  local player = PlayersService:GetPlayerByUserId(userid)
  if not player or not player:FindFirstChild("leaderstats") then return end
  local leaderstat = player.leaderstats[self._nameLeaderstats]
  leaderstat.Value = tonumber(minutes)
end


function TimePlayedClass:_checkDancingRigEnabled()
  if self._show1stPlaceAvatar then
    local rigFolder = script.Parent:FindFirstChild("First Place Avatar")
    if not rigFolder then return end
    local rig = rigFolder:FindFirstChild("Rig")
    local rigModule = rigFolder:FindFirstChild("PlayAnimationInRig")
    if not rig or not rigModule then return end
    self._dancingRigModule = require(rigModule)
    if self._dancingRigModule then
      self._isDancingRigEnabled = true
    end
  else
    local rigFolder = script.Parent:FindFirstChild("First Place Avatar")
    if not rigFolder then return end
    rigFolder:Destroy()
  end
end


function TimePlayedClass:_checkIsMainScript()
  local timePlayedClassRunning = ServerStorage:FindFirstChild("TopTimePlayedLeaderboard_Running_Flag")
  if timePlayedClassRunning then
    self._isMainScript = false
  else
    self._isMainScript = true
    local boolValue = Instance.new("BoolValue", ServerStorage)
    boolValue.Name = "TopTimePlayedLeaderboard_Running_Flag"
    boolValue.Value = true
  end
end


function TimePlayedClass:_checkDataStoreUp()
  local status, message = pcall(function()
    -- This will error if current instance has no Studio API access:
    DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
  end)
  if status == false and
    (string.find(message, "404", 1, true) ~= nil or 
      string.find(message, "403", 1, true) ~= nil or -- Cannot write to DataStore from studio if API access is not enabled
      string.find(message, "must publish", 1, true) ~= nil) then -- Game must be published to access live keys
    local boolValue = Instance.new("BoolValue", ServerStorage)
    boolValue.Value = false
    boolValue.Name = "TopTimePlayedLeaderboard_NoAPIServices_Flag"
    return false
  end
  self._apiServicesEnabled = true
  local boolValue = Instance.new("BoolValue", ServerStorage)
  boolValue.Value = true
  boolValue.Name = "TopTimePlayedLeaderboard_NoAPIServices_Flag"
  return self._apiServicesEnabled
end


function TimePlayedClass:_getUsernameAsync(userid: number)
  if self._usernameCache[userid] then -- already cached, return
    return self._usernameCache[userid]
  end
  local success: boolean, resultOrError: string = pcall(function ()
    return PlayersService:GetNameFromUserIdAsync(userid)
  end)
  if not success then
    if self._doDebug then
      warn(("TopTimePlayed Board: Error retrieving username for userid %d. Cause: %s"):format(userid, resultOrError))
    end
    return "Name not found"
  else
    self._usernameCache[userid] = resultOrError
    return resultOrError
  end
end


function TimePlayedClass:_getThumbnailAsync(userid: number)
  if self._thumbnailCache[userid] then -- already cached, return
    return self._thumbnailCache[userid]
  end
  local success: boolean, resultOrError: string = pcall(function ()
    return PlayersService:GetUserThumbnailAsync(userid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
  end)
  if not success then
    if self._doDebug then
      warn(("TopTimePlayed Board: Error retrieving thumbnail for userid %d. Cause: %s"):format(userid, resultOrError))
    end
    return "rbxassetid://5107154082"
  else
    self._thumbnailCache[userid] = resultOrError
    return resultOrError
  end
end


function TimePlayedClass:_timeToString(_time)
  _time = _time * 60
  local days = math.floor(_time / 86400)
  local hours = math.floor(math.fmod(_time, 86400) / 3600)
  local minutes = math.floor(math.fmod(_time, 3600) / 60)
  return string.format("%02dd : %02dh : %02dm",days,hours,minutes)
end


TimePlayedClass.new()
