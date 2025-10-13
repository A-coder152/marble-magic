extends Node

var coins = 0

var player_health: int = 25
var enemy_health: int = 5
var player_max_health: int = 25

var enemy_max_health: int = 5
var enemy_max_dmg: int = 2
var enemy_stunned = false

var all_marbles = [
	preload("uid://eonk3e3ilnxt"),
	preload("uid://d23vkr4npjgte"),
	preload("uid://boklkf4kph6xe"),
	preload("res://marbles/damage3.tres"),
	preload("uid://sgv8yovrj18k"),
	preload("uid://boxqq5clug2q1"),
	preload("uid://csl0ddj6vqiib"),
	preload("uid://crtcjdgkrp4r2"),
	preload("uid://dk2wotbuurs8o"),
	preload("uid://bad7q3xqjvvym"),
	preload("uid://m8wqtmrcn0h2"),
	preload("uid://bo6jao5010osi"),
	preload("uid://bpoq5wlbdfhxm"),
	preload("uid://bhdq2imcjsfcb"),
	preload("uid://b4lp6ovcquqov"),
	preload("uid://bf4ph26kmbl8v"),
	preload("uid://cntoynq237v6s"),
	preload("uid://brnx3vjdcscn0"),
	preload("uid://csirbqxk5dq7d")
]

var current_marbles: Array = []
var current_marbles_idx: Array[int] = []

var selected_marble_indices: Array = []

enum TurnPhase {
	TAKE_1_SELECTION, 
	TAKE_1_REVEAL,    
	TAKE_2_SELECTION, 
	TURN_END,          
	GAME_OVER           
}
var current_turn_phase: int = TurnPhase.TAKE_1_SELECTION

var potential_damage: int = 0
var bag_marbles: Array = [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5]

signal marble_selected(index: int)
signal selection_confirmed()
signal turn_phase_changed(new_phase: int)
signal health_changed(entity_type: String, current_hp: int, max_hp: int)
signal damage_dealt(amount: int, target: String)
signal game_over(win: bool)
signal close_bag()
signal close_shop()
signal refresh_shop()
signal change_stunned()
signal change_coins()

func _ready():
	print("GameManager ready and loaded!")
	start_new_game()
	
func start_next_turn():
	_generate_new_marbles()
	selected_marble_indices.clear()
	potential_damage = 0
	_set_turn_phase(TurnPhase.TAKE_1_SELECTION)
	health_changed.emit("player", player_health, player_max_health)
	health_changed.emit("enemy", enemy_health, enemy_max_health)
	

func start_new_game():
	enemy_max_health += 3
	enemy_max_dmg += 1
	#player_health = player_max_health
	enemy_health = enemy_max_health 
	start_next_turn()

func _generate_new_marbles():
	current_marbles.clear()
	while len(current_marbles) < 4:
		var next_marble_idx = randi_range(0, len(bag_marbles) - 1)
		if next_marble_idx not in current_marbles_idx:
			current_marbles.append(all_marbles[bag_marbles[randi_range(0, len(bag_marbles) - 1)]])
			current_marbles_idx.append(next_marble_idx)
	print("New marbles generated: ", current_marbles)

func handle_marble_selection(index: int):
	if current_turn_phase == TurnPhase.TAKE_1_SELECTION or current_turn_phase == TurnPhase.TAKE_2_SELECTION:
		if selected_marble_indices.has(index):
			selected_marble_indices.erase(index)
		else:
			if selected_marble_indices.size() < 2:
				selected_marble_indices.append(index)
			else:
				selected_marble_indices.pop_front()
				selected_marble_indices.append(index)
		print("Selected marbles: ", selected_marble_indices)
		marble_selected.emit(index)

func confirm_selection():
	if selected_marble_indices.size() != 2:
		return

	var chosen_values: Array[Marble] = []
	for index in selected_marble_indices:
		chosen_values.append(current_marbles[index])

	var total_chosen_damage = chosen_values[0].damage + chosen_values[1].damage

	if current_turn_phase == TurnPhase.TAKE_1_SELECTION:
		potential_damage = total_chosen_damage
		print("Take 1 Potential Damage: ", potential_damage)
		var farter = calculate_effects(chosen_values)
		health_changed.emit("enemy", farter[1], enemy_max_health)
		health_changed.emit("player", farter[0], farter[3])
		if farter[4]: change_stunned.emit()
		if farter[2]:
			coins += farter[2]
			change_coins.emit()
		_set_turn_phase(TurnPhase.TAKE_1_REVEAL)
		get_tree().create_timer(1.5).timeout.connect(func():
			_set_turn_phase(TurnPhase.TAKE_2_SELECTION)
			selected_marble_indices.clear()
			health_changed.emit("enemy", max(enemy_health, 0), enemy_max_health)
			health_changed.emit("player", max(player_health, 0), player_max_health)
			if farter[4]: change_stunned.emit()
			if farter[2]:
				coins -= farter[2]
				change_coins.emit()
		)
	elif current_turn_phase == TurnPhase.TAKE_2_SELECTION:
		print("Take 2 Actual Damage: ", total_chosen_damage)
		apply_effects(chosen_values)
		_set_turn_phase(TurnPhase.TURN_END)
		await get_tree().create_timer(1.75 if enemy_health > 0 else 2.25).timeout
		_end_turn()

func _apply_damage_to_enemy(amount: int):
	enemy_health = max(0, enemy_health - amount)
	print("Enemy health after damage: ", enemy_health)
	health_changed.emit("enemy", enemy_health, enemy_max_health)
	damage_dealt.emit(amount, "enemy")

func apply_effects(marbles: Array[Marble]):
	var augh = calculate_effects(marbles)
	player_health = augh[0]
	_apply_damage_to_enemy(enemy_health - augh[1])
	coins += augh[2]
	player_max_health = augh[3]
	enemy_stunned = augh[4]
	health_changed.emit("player", player_health, player_max_health)
	change_coins.emit()
	if enemy_stunned: change_stunned.emit()

func calculate_effects(marbles: Array[Marble]):
	var sim_enemy_health = enemy_health
	var sim_player_health = player_health
	var sim_coins = 0
	var sim_stunned = false
	var sim_player_max_hp = player_max_health
	for marble in marbles:
		sim_enemy_health = max(0, min(enemy_max_health, sim_enemy_health - marble.damage))
		sim_player_health = max(0, min(player_max_health, sim_player_health + marble.heal))
		for effect in marble.effects:
			match effect:
				marble.EFFECTS.COIN:
					sim_coins += marble.effects_impact[marble.effects.find(effect)]
				marble.EFFECTS.STUN:
					sim_stunned = true
				marble.EFFECTS.MAXHP:
					sim_player_max_hp = player_max_health + marble.effects_impact[marble.effects.find(effect)]
				marble.EFFECTS.MEGADMG:
					sim_enemy_health *= 1 - (1. / marble.effects_impact[marble.effects.find(effect)])
				marble.EFFECTS.MEGAHEAL:
					sim_player_health += (1. / marble.effects_impact[marble.effects.find(effect)]) * (player_max_health - player_health)
	return [sim_player_health, sim_enemy_health, sim_coins, sim_player_max_hp, sim_stunned]

func _enemy_turn():
	if enemy_stunned: 
		enemy_stunned = false
		change_stunned.emit()
		return
	var enemy_damage = randi_range(1, enemy_max_dmg) # Random damage for enemy
	player_health = max(0, player_health - enemy_damage)
	print("Player health after enemy attack: ", player_health)
	health_changed.emit("player", player_health, player_max_health)
	damage_dealt.emit(enemy_damage, "player")
	return

func _end_turn():
	if player_health <= 0:
		_set_turn_phase(TurnPhase.GAME_OVER)
		game_over.emit(false)
	elif enemy_health <= 0:
		_set_turn_phase(TurnPhase.GAME_OVER)
		game_over.emit(true)
	else:
		await _enemy_turn()
		if player_health <= 0:
			_set_turn_phase(TurnPhase.GAME_OVER)
			game_over.emit(false) 
		else:
			start_next_turn()

func _set_turn_phase(new_phase: int):
	current_turn_phase = new_phase
	turn_phase_changed.emit(new_phase)
