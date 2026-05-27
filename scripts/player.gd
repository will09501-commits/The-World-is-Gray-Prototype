extends CharacterBody2D
enum State {IDLE, KNOCKED, FROZEN, SWORDING, FIREBALLING}
var current_state = State.IDLE
var attacking_states = [State.SWORDING, State.FIREBALLING]
@export var speed = 300
@export var gravity = 1800
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
	randomize()
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	mana_bar.max_value = MAX_MANA
	var current_state = State.IDLE
	tempSword.queue_free()
	tempFireball.queue_free()
	
func _physics_process(delta):
	if is_on_floor():
		ableDoubleJump = doubleJumpEnabled
	var horiz_direction = 0
	match current_state:
		State.KNOCKED:
			horiz_direction = 0
			velocity = knockback
			knockback_timer -= delta
			if knockback_timer < delta:
				freeze_time = damage_freeze_time
				current_state = State.FROZEN
				knockback = Vector2.ZERO
		State.FROZEN:
			freeze_time -= delta
			velocity = Vector2.ZERO
			if freeze_time <= 0:
				freeze_time = 0
				current_state = State.IDLE
				animated_sprite.play("idle")
			if casting_fireball and freeze_time <= 0.1:
				var fireball = FIREBALL.instantiate()
				get_parent().add_child(fireball)
				fireball.position = $Marker2D.global_position
				manaAmount -= fireballStats["manaCost"]
				fireballCooldown = fireballStats["cooldown"]
				current_state = State.FIREBALLING
				fireball.SPEED = fireball.SPEED * fireball_direction
				casting_fireball = false
		State.IDLE, State.SWORDING, State.FIREBALLING:
			#print('doing')
			fireball_direction = sign(attacksMarker.position)
			horiz_direction = Input.get_axis("move_left","move_right")
			
			# ----- Jumping -----
			if (Input.is_action_just_pressed("jump") and is_on_floor()):
				velocity.y = -jump_force
			elif (Input.is_action_just_pressed("jump") and ableDoubleJump):
				velocity.y = -jump_force - 20
				ableDoubleJump = false
				
			velocity.x = speed * horiz_direction
			if is_on_floor():
				if horiz_direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
				
			if current_state not in attacking_states:
				if horiz_direction < 0:
					animated_sprite.flip_h = true
				elif horiz_direction > 0:
					animated_sprite.flip_h = false
				
				
				# ----- Basic sword attacking -----
				if Input.is_action_just_pressed("attack") and manaAmount >= swordStats["manaCost"]:
					var weapon = SWORD.instantiate()
					manaAmount -= swordStats["manaCost"]
					weapon.position = attacksMarker.position
					self.add_child(weapon)
					current_state = State.SWORDING
					weaponCooldown = swordStats["cooldown"]
					
				# ----- Sword Cooldown -----
				if weaponCooldown > 0:
					weaponCooldown -= delta
				else:
					weaponCooldown = 0
					current_state = State.IDLE
					
				# ----- Player casts fireball -----
				if Input.is_action_just_pressed("attack2") and manaAmount >= fireballStats["manaCost"]:
					casting_fireball = true
					animated_sprite.play("cast")
					freeze_time = fireballStats["freeze_time"]
					current_state = State.FROZEN
				elif Input.is_action_just_pressed("attack2") and manaAmount < fireballStats["manaCost"]:
					freeze_time = fireballStats["freeze_time"]
					animated_sprite.play("failed_cast")
					current_state = State.FROZEN
				
				# ----- Fireball Cooldown -----
				if fireballCooldown > 0:
					fireballCooldown -= delta
				else:
					fireballCooldown = 0
					current_state = State.IDLE
					
				# ----- Update the Marker position -----
				if horiz_direction != 0 and current_state != State.SWORDING:
					attacksMarker.position = Vector2(markerPosx * horiz_direction, markerPosy)
		
	if current_state != State.FROZEN:
		if !is_on_floor():
			if velocity.y < 1000:
				velocity.y += gravity * delta
		

	# ----- I frames timer -----
	if invincible_timer > 0.0:
		invincible_timer -= delta
	if invincible_timer <= 0.0:
		invincible = false
		if animated_sprite.animation == "damage":
			animated_sprite.play("idle")

	# ----- Basic mana Stuff such as mana regen and adjusting bar value -----
	if manaAmount < MAX_MANA:
		manaAmount += (manaRegen*delta)
	elif manaAmount > MAX_MANA:
		manaAmount = MAX_MANA
	mana_bar.value = manaAmount

	
	#print(current_state)
	print(velocity)
	move_and_slide()



func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	if !invincible:
		if health <= 0:
			animated_sprite.play("death")
			_on_animated_sprite_2d_animation_finished()
			queue_redraw()
		animated_sprite.play("damage")
		current_state = State.KNOCKED
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
