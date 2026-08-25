return {
  DATA_STORE              = "TopTimePlayed" , --< Name of the Data store values will be saved in
  SCORE_UPDATE            = 1 , --< How often you want the score to be sent to datastore in minutes (no less than 1)
  LEADERBOARD_UPDATE      = 1 , --< How often you want the leaderboard to update in minutes (no less than 1) 
  NAME_OF_STAT            = "TimePlayed" , --< Stat name to save in the database
  USE_LEADERSTATS         = false , --< Should use the Roblox built-in Leaderboard system too? More info: https://create.roblox.com/docs/building-and-visuals/ui/leaderboard-system
  NAME_LEADERSTATS        = "Time Played" , --< What the name of the Leaderboard to use?
  SHOW_1ST_PLACE_AVATAR   = true ,
  DO_DEBUG                = false , --< Should it debug (print) messages to the console?
}
