extends Node

var player_health: int = 20
var enemy_health: int = 20
var player_max_health: int = 25
var enemy_max_health: int = 5
var enemy_max_dmg: int = 2

var current_marbles: Array = []

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
var marble_values: Array = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]

signal marble_selected(index: int)
signal selection_confirmed()
signal turn_phase_changed(new_phase: int)
signal health_changed(entity_type: String, current_hp: int, max_hp: int)
signal damage_dealt(amount: int, target: String)
signal game_over(win: bool)

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
	enemy_max_health += 5
	enemy_max_dmg += 1
	player_health = player_max_health
	enemy_health = enemy_max_health 
	start_next_turn()

func _generate_new_marbles():
	current_marbles.clear()
	for i in range(4):
		current_marbles.append(marble_values[randi_range(0, len(marble_values) - 1)]) # Random value between 5 and 20
	print("New marbles generated: ", current_marbles)

func handle_marble_selection(index: int):
	if current_turn_phase == TurnPhase.TAKE_1_SELECTION or \
	   current_turn_phase == TurnPhase.TAKE_2_SELECTION:
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

	var chosen_values = []
	for index in selected_marble_indices:
		chosen_values.append(current_marbles[index])

	var total_chosen_damage = chosen_values[0] + chosen_values[1]

	if current_turn_phase == TurnPhase.TAKE_1_SELECTION:
		potential_damage = total_chosen_damage
		print("Take 1 Potential Damage: ", potential_damage)
		_set_turn_phase(TurnPhase.TAKE_1_REVEAL)
		get_tree().create_timer(1.5).timeout.connect(func():
			_set_turn_phase(TurnPhase.TAKE_2_SELECTION)
			selected_marble_indices.clear()
		)
	elif current_turn_phase == TurnPhase.TAKE_2_SELECTION:
		print("Take 2 Actual Damage: ", total_chosen_damage)
		_apply_damage_to_enemy(total_chosen_damage)
		_set_turn_phase(TurnPhase.TURN_END)
		await get_tree().create_timer(1.75 if enemy_health > 0 else 2.25).timeout
		_end_turn()

func _apply_damage_to_enemy(amount: int):
	enemy_health = max(0, enemy_health - amount)
	print("Enemy health after damage: ", enemy_health)
	health_changed.emit("enemy", enemy_health, enemy_max_health)
	damage_dealt.emit(amount, "enemy")

func _enemy_turn():
	var enemy_damage = randi_range(1, enemy_max_dmg) # Random damage for enemy
	player_health = max(0, player_health - enemy_damage)
	print("Player health after enemy attack: ", player_health)
	health_changed.emit("player", player_health, player_max_health)
	damage_dealt.emit(enemy_damage, "player")

func _end_turn():
	if player_health <= 0:
		_set_turn_phase(TurnPhase.GAME_OVER)
		game_over.emit(false)
	elif enemy_health <= 0:
		_set_turn_phase(TurnPhase.GAME_OVER)
		game_over.emit(true)
	else:
		_enemy_turn()
		if player_health <= 0:
			_set_turn_phase(TurnPhase.GAME_OVER)
			game_over.emit(false) 
		else:
			start_next_turn()

func _set_turn_phase(new_phase: int):
	current_turn_phase = new_phase
	turn_phase_changed.emit(new_phase)
