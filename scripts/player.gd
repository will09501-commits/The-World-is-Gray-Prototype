extends CharacterBody2D
@export var speed = 300
@export var gravity = 30
@export var jump_force = 300
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $healthBar
@onready var mana_bar: ProgressBar = $manaBar
@onready var attacksMarker: Marker2D = $Marker2D
@onready var markerPosx = attacksMarker.position.x
@onready var markerPosy = attacksMarker.position.y
@onready var manaAmount = 0.0
@onready var casting_fireball = false
@export var manaRegen = 5.0
@export var doubleJumpEnabled = true
@export var damage_freeze_time = 0.3

const FIREBALL = preload("res://scenes/fireball.tscn")
const SWORD = preload("res://scenes/base_weapon.tscn")

const MAX_HEALTH: int = 6

@export var MAX_MANA = 100.0
@export var baseWeaponKnockback = 100
@export var baseWeaponKnockbackDuration = 0.12
@export var iframes: float = 1.0
@export var health: int = 6
@onready var fireballCooldown = 0
@onready var freeze_time = 0
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var invincible = false
var invincible_timer = 0.0
var attack2On = false
var fireball_direction = 1

@onready var weaponCooldown = 0
@onready var ableDoubleJump = doubleJumpEnabled

@onready var tempSword = SWORD.instantiate()
@onready var swordStats = tempSword.stats
@onready var overwrite_animations = ["cast","damage","failed_cast"]

@onready var tempFireball = FIREBALL.instantiate()
@onready var fireballStats = tempFireball.stats
func _ready() -> void:
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	mana_bar.max_value = MAX_MANA
	tempSword.queue_free()
	tempFireball.queue_free()
	
func _physics_process(delta):
	if is_on_floor():
		ableDoubleJump = doubleJumpEnabled
	var horiz_direction = 0
	if knockback_timer <= 0.0 and Input.get_axis("move_left", "move_right") != 0:
		fireball_direction = Input.get_axis("move_left", "move_right")
	if knockback_timer <= 0.0:
		horiz_direction = Input.get_axis("move_left","move_right")
	else:
		horiz_direction = 0
	var vert_direction = Input.get_axis("down","up")
	if invincible_timer > 0.0:
		invincible_timer -= delta
	if invincible_timer <= 0.0:
		invincible = false
		if animated_sprite.animation == "damage":
			animated_sprite.play("idle")
		
	# Basic mana Stuff such as mana regen and adjusting bar value
	if manaAmount < MAX_MANA:
		manaAmount += (manaRegen*delta)
	elif manaAmount > MAX_MANA:
		manaAmount = 0
	mana_bar.value = manaAmount
	if knockback_timer > 0 and knockback_timer < delta * 2:
		freeze_time = damage_freeze_time
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
	if knockback_timer <= 0.0:
		knockback = Vector2.ZERO
	
	if weaponCooldown > 0:
		weaponCooldown -= delta
	else:
		weaponCooldown = 0
	if fireballCooldown > 0:
		fireballCooldown -= delta
	else:
		fireballCooldown = 0
		
	if !is_on_floor():
		if velocity.y < 1000:
			velocity.y += gravity
	if horiz_direction != 0 and weaponCooldown <= 0:
		attacksMarker.position = Vector2(markerPosx * horiz_direction, markerPosy)
	
	# ----- Basic sword attacking -----
	
	if Input.is_action_just_pressed("attack") and weaponCooldown <= 0 and manaAmount >= swordStats["manaCost"]:
		var weapon = SWORD.instantiate()
		manaAmount -= swordStats["manaCost"]
		weapon.position = attacksMarker.position
		self.add_child(weapon)
		weaponCooldown = swordStats["cooldown"]

		
	# ----- Jumping -----
	
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = -jump_force
	elif (Input.is_action_just_pressed("jump") and ableDoubleJump):
		velocity.y = -jump_force
		ableDoubleJump = false
	
	if horiz_direction < 0 and weaponCooldown <= 0:
		animated_sprite.flip_h = true
	elif horiz_direction > 0 and weaponCooldown <= 0:
		animated_sprite.flip_h = false
	
	if (!(animated_sprite.animation in overwrite_animations)):
		if is_on_floor():
			if horiz_direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
		
	velocity.x = speed * horiz_direction
	if freeze_time > 0:
		freeze_time -= delta	
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			
	# ----- Player casts fireball -----
	if Input.is_action_just_pressed("attack2") and fireballCooldown <= 0 and manaAmount >= fireballStats["manaCost"]:
		print(freeze_time)
		casting_fireball = true
		animated_sprite.play("cast")
		freeze_time = fireballStats["freeze_time"]
	elif Input.is_action_just_pressed("attack2") and manaAmount < fireballStats["manaCost"]:
		freeze_time = fireballStats["freeze_time"]
		animated_sprite.play("failed_cast")
		
	if casting_fireball and freeze_time <= 0.1:
		var fireball = FIREBALL.instantiate()
		get_parent().add_child(fireball)
		fireball.position = $Marker2D.global_position
		manaAmount -= fireballStats["manaCost"]
		fireballCooldown = fireballStats["cooldown"]
		fireball.SPEED = fireball.SPEED * fireball_direction
		casting_fireball = false
		
	# ----- Player casts mine
		
	# ----- Move and reset animations -----
	if animated_sprite.animation in overwrite_animations and freeze_time <= 0:
		animated_sprite.play("idle")
	if freeze_time <= 0:
		move_and_slide()



func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	if !invincible:
		if health <= 0:
			animated_sprite.play("death")
			_on_animated_sprite_2d_animation_finished()
			queue_redraw()
		animated_sprite.play("damage")
		knockback = direction * force
		print(knockback)
		knockback_timer = knockback_duration
		invincible = true
		invincible_timer = iframes
		health -= 1
		health_bar.value = health



#func _on_area_2d_body_entered(body: Node2D) -> void:
	#var knockback_direction = (body.global_position - global_position).normalized()
	#print(body.get_class())
	#if body.get_class() == "CharacterBody2D":
		#body.apply_damage(damage, knockback_direction, baseWeaponKnockback, baseWeaponKnockbackDuration)


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_redraw()
