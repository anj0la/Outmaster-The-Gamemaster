local GameSettings = {}

GameSettings.MINIMUM_PLAYERS = 1
GameSettings.INTERMISSION_DURATION = 10 -- seconds
GameSettings.PLAYER_HEAD_START_DURATION = 5 -- seconds
GameSettings.ROUND_DURATION = 5 * 60 -- seconds
GameSettings.TRANSITION_DURATION = 2 -- seconds
GameSettings.MAX_VOTABLE_MAPS = 3
GameSettings.MIN_KEYBOXES = 3
GameSettings.PROXIMITY_THRESHOLD = 5
GameSettings.BASE_WEIGHT = 1
GameSettings.MINIGAME_DURATION = 30
GameSettings.ACTIVATE_GAME_WINDOW = (5 * 60) - 10 -- seconds (or 2.16 * 60 seconds) -> should be 200 seconds (360 - 160 = 200)

return GameSettings
