class_name Marble extends Resource

enum EFFECTS {
	SHOW,
	ANTIDMG,
	ANTIHEAL,
	MEGADMG,
	COIN,
	MEGAHEAL,
	STUN
}

@export var title: String
@export var cost: int = 0
@export var description: String
@export var texture: Texture2D

@export var damage: int
@export var heal: int
@export var effects: Array[EFFECTS]
@export var effects_impact: Array[int]
