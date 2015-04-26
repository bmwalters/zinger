-- colors
color_green 					= Color(100, 255, 100, 255)
color_green_field				= Color(133, 183, 51, 255)
color_green_oob					= Color(107, 185, 8, 255)
color_red 						= Color(255, 70, 70, 255)
color_yellow 					= Color(255, 231, 88, 255)
color_yellow_dark				= Color(244, 210, 13, 255)
color_yellow_transparent 		= ColorAlpha(color_yellow, 180)
color_brown						= Color(157, 116, 74, 255)
color_shadow					= Color(0, 0, 0, 180)
color_team_orange				= Color(229, 105, 0, 255)
color_team_purple				= Color(134, 53, 148, 255)
color_white_translucent			= Color(255, 255, 255, 32)
color_white_translucent2		= Color(255, 255, 255, 96)

-- round states
ROUND_WAITING					= 1
ROUND_ACTIVE					= 2
ROUND_INTERMISSION				= 3
ROUND_OVER						= 4

-- game settings
GAME_LENGTH						= 20 -- minutes
GAME_WAIT_TIME					= 30
EXPLOSION_DISTANCE				= 256
MIN_VIEW_DISTANCE				= 100
MAX_VIEW_DISTANCE				= 700
OBSERVER_SPEED 					= 500
OBSERVER_HULL_MAX				= Vector(8, 8, 8)
OBSERVER_HULL_MIN				= Vector(-8, -8, -8)
TEE_TIME						= 8
HINT_MIN_DISTANCE				= 512
HINT_MAX_DISTANCE				= 1024
HINT_DELAY						= 4

-- hud element flag
ELEM_FLAG_ALWAYS				= 0
ELEM_FLAG_SPECTATORS			= 1
ELEM_FLAG_PLAYERS				= 2
ELEM_FLAG_HASBALL				= 3
ELEM_FLAG_ITEMEQUIPPED			= 4

-- types
SKY_DAWN						= 1
SKY_DAY							= 2
SKY_DUSK						= 3
SKY_NIGHT						= 4

-- sky settings
SKY_NUM_CLOUDS					= 6
INSECT_MAX_RANGE				= 512
INSECT_COUNT					= 3

-- notification types
NOTIFY_RING						= 1
NOTIFY_CRATE					= 2
NOTIFY_ITEMACTION				= 3
NOTIFY_ITEMPLAYER				= 4
NOTIFY_SINKCUP					= 5

-- loadout states
LOADOUT_NEW						= 1
LOADOUT_RESTORE					= 2
LOADOUT_COMPLETE				= 3

-- teams
TEAM_ORANGE						= TEAM_SPECTATOR + 1
TEAM_PURPLE						= TEAM_ORANGE + 1

-- scale
BALL_SIZE						= 10
DISTANCE_SCALE					= (1.62 / (BALL_SIZE * 2))
DAMAGE_MULTIPLIER				= 2

-- hint
HINT_RADIUS_SQR					= 128 ^ 2

-- points
POINTS_SUPPLY_CRATE				= 5
POINTS_SUPPLY_CRATE_FIRST		= 15
POINTS_RING						= 10
POINTS_RING_FIRST				= 30
POINTS_CUP						= 20
POINTS_CUP_FIRST				= 60
POINTS_CUP_LEAST_STROKES		= 60
POINTS_OOB						= -10

-- distances
FOLIAGE_DISTANCE_MIN			= 4096
FOLIAGE_DISTANCE_MAX			= 5120
FOLIAGE_DISTANCE_MIN_SQR		= FOLIAGE_DISTANCE_MIN * FOLIAGE_DISTANCE_MIN
FOLIAGE_DISTANCE_MAX_SQR		= FOLIAGE_DISTANCE_MAX * FOLIAGE_DISTANCE_MAX
FOLIAGE_FADE_DISTANCE_SQR_INV	= 1 / (FOLIAGE_DISTANCE_MAX_SQR - FOLIAGE_DISTANCE_MIN_SQR)

-- stuff
ROCKET_SPEED					= 2000
HOMING_ROCKET_SPEED				= 750
HOMING_TARGET_RADIUS			= 128
MAGNET_ATTRACT_RADIUS			= 256
MAGNET_ATTRACT_STRENGTH			= 0.1
MAGNET_DURATION					= 30
BOT_STROKE_STRENGTH				= 150
