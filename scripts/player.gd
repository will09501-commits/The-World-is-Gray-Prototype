extends CharacterBody2D
enum State {IDLE, KNOCKED, FROZEN, SWORDING}
var current_state = State.IDLE
var attacking_states = [State.SWORDING]
@export var speed = 300
@export var gravity = 1800
@export var jump_force = 300
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $healthBar
@onready var mana_bar: ProgressBar = $manaBar
@onready var manaAmount = 0.0
@onready var casting_fireball = false
@export var manaRegen = 5.0
@export var doubleJumpEnabled = true
@export var damage_freeze_time = 0.4
const FIREBALL = preload("res://scenes/fireball.tscn")
const SWORD = preload("res://scenes/base_weapon.tscn")
var in_fbcast = false
const MAX_HEALTH: int = 6
@export var MAX_MANA = 100.0
@export var baseWeaponKnockback = 100
@export var baseWeaponKnockbackDuration = 0.12
@export var iframes: float = 1.0
@export var health: int = 6
@onready var fireballCooldown = 0
@onready var weaponCooldown = 0
@onready var cooldowns = [fireballCooldown, weaponCooldown]
@onready var freeze_time = 0
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var invincible = false
var invincible_timer = 0.0
@onready var ableDoubleJump = doubleJumpEnabled
@onready var horiz_direction = 0
@onready var overwrite_animations = ["cast","damage","failed_cast"]
@onready var markerBasePos = $Marker2D.position
func _ready() -> void:
	randomize()
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	mana_bar.max_value = MAX_MANA
func _physics_process(delta):
	if is_on_floor():
		ableDoubleJump = doubleJumpEnabled
	#print(current_state)
	
	match current_state:
		State.KNOCKED:
			horiz_direction = 0
			velocity = knockback
			knockback_timer = cooldownCalc(knockback_timer, delta)
			if knockback_timer < delta:
				freeze_time = damage_freeze_time
				current_state = State.FROZEN
				$Damage.visible = true
				$Damage.play('default')
				
				knockback = Vector2.ZERO
		State.FROZEN:
			freeze_time = cooldownCalc(freeze_time, delta)
			velocity = Vector2.ZERO
			if freeze_time <= 0:
				current_state = State.IDLE
				animated_sprite.play("idle")
		State.IDLE, State.SWORDING:
			# ----- Get direction player is facing to align sprite
			horiz_direction = Input.get_axis("move_left","move_right")
			
			# ----- Jumping -----
			if (Input.is_action_just_pressed("jump") and is_on_floor()):
				velocity.y = -jump_force
			elif (Input.is_action_just_pressed("jump") and ableDoubleJump):
				velocity.y = -jump_force - 20
				ableDoubleJump = false
			
			# ----- Horizontal movement -----
			velocity.x = speed * horiz_direction
			
			# ----- Do animations -----
			if is_on_floor():
				if horiz_direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
			
			
			if current_state not in attacking_states:
				# ----- Flip sprite if not  attacking -----
				if horiz_direction < 0:
					animated_sprite.flip_h = true
				elif horiz_direction > 0:
					animated_sprite.flip_h = false
					
				# ----- Update the Marker position -----
				if horiz_direction != 0:
					$Marker2D.position = Vector2(markerBasePos.x * horiz_direction, markerBasePos.y)
				
				# ----- Basic sword attacking -----
				if Input.is_action_just_pressed("attack"):
					sword_attack()
				
				# ----- Player casts fireball -----
				if Input.is_action_just_pressed("attack2"):
					fireball_attack()
					
			# ----- Weapon Cooldown -----
			#weaponCooldown = cooldownCalc(weaponCooldown, delta)
			#fireballCooldown = cooldownCalc(fireballCooldown, delta)
			#var cooledDown = true
			#cooldowns = [weaponCooldown, fireballCooldown]
			#print(weaponCooldown)
			#print(cooldowns)
			#for cooldown in cooldowns:
				#if cooldown > 0:
					#cooledDown = false
			#if cooledDown:
				#current_state = State.IDLE

	# ----- Apply Gravity ----- 
	if current_state != State.FROZEN and !is_on_floor() and velocity.y < 1000:
		velocity.y += gravity * delta
		

	# ----- I frames timer -----
	invincible_timer =  cooldownCalc(invincible_timer, delta)
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

	move_and_slide()



func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	if !invincible:
		if health <= 0:
			animated_sprite.play("death")
			_on_animated_sprite_2d_animation_finished()
			queue_redraw()
		animated_sprite.play("damage")
		$Damage.play('default')
		current_state = State.KNOCKED
		knockback = direction * force

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
# ----- Advance cooldowns of things ----- 
func cooldownCalc(timer_thing, delta):
	if timer_thing > 0:
		return timer_thing - delta
	else:
		return 0
		
func sword_attack():
	var weapon = SWORD.instantiate()
	if manaAmount >= weapon.stats["manaCost"]:
		manaAmount -= weapon.stats["manaCost"]
		weapon.position = $Marker2D.position
		self.add_child(weapon)
		current_state = State.SWORDING
		weaponCooldown = weapon.stats["cooldown"]
		await get_tree().create_timer(weapon.stats["cooldown"]).timeout
		current_state = State.IDLE
	else:
		weapon.queue_free()

func fireball_attack():
	var fireball = FIREBALL.instantiate()
	if manaAmount >= fireball.stats["manaCost"] and !in_fbcast:
		in_fbcast = true
		animated_sprite.play("cast")
		freeze_time = fireball.stats["freeze_time"]
		current_state = State.FROZEN
		await get_tree().create_timer(fireball.stats["freeze_time"] - 0.1).timeout
		get_parent().add_child(fireball)
		fireball.position = $Marker2D.global_position
		manaAmount -= fireball.stats["manaCost"]
		fireballCooldown = fireball.stats["cooldown"]
		fireball.SPEED = fireball.SPEED * sign($Marker2D.position.x)
		$fireballCooldown.play('default')
		await get_tree().create_timer(fireball.stats["cooldown"]).timeout
		in_fbcast = false
		current_state = State.IDLE
	elif manaAmount < fireball.stats["manaCost"]:
		freeze_time = fireball.stats["freeze_time"]
		animated_sprite.play("failed_cast")
		current_state = State.FROZEN
		fireball.queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_redraw()
