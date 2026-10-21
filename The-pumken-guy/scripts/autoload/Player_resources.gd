extends Node

var corpses : int = 1
var souls : int = 2
var armory : int = 0
var close_quarters_combat_weapon : int = 0
var ranged_combat_weapon : int = 0

func reload():
	corpses = 1
	souls = 2
	armory = 0
	close_quarters_combat_weapon = 0
	ranged_combat_weapon = 0

func GOD():
	corpses = 999
	souls = 999
	armory = 999
	close_quarters_combat_weapon = 999
	ranged_combat_weapon = 999
