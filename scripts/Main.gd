extends Node2D

onready var spawn_location = get_node("CrosshairsPath/CrosshairSpawnLocation")
var score = 0
var highscore = 0
var new_highscore = false
var speed = 300
var perfect_streak = 0
var time = 0


func _ready():
	VisualServer.set_default_clear_color(Color("#FED9B7"))
	highscore = Settings.load_score()
	set_highscore_on_homescreen()

func new_game():
	reset_on_start()
	$Target.set_target_position()
	prepare_crosshair()
	$Target.visible = true
	$Crosshairs.visible = true
	$HUD.show()
	$SessionTimer.start()

func game_over():
	$SessionTimer.stop()
	$Target.visible = false
	$Crosshairs.visible = false
	update_highscore()
	$HUD.hide()
	$Screens.game_over()

func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		$HitSound.play()
		var points = $Target.hit_detection($Crosshairs)
		handle_points_and_update_HUD(points)
		prepare_crosshair()

func _on_SessionTimer_timeout():
	time += 1
	$HUD.update_time(time)
	update_speed()


# HELPER METHODS

func reset_on_start():
	score = 0
	time = 0
	perfect_streak = 0
	speed = 150
	new_highscore = false
	$HUD.update_score(score)
	$HUD.update_time(time)
	$HUD.update_streak(perfect_streak)

func prepare_crosshair():
	spawn_location.offset = Util.generate_random_number()
	var direction = Util.calculate_direction(spawn_location.position, $Target.position)
	$Crosshairs.set_new_position_and_velocity(spawn_location.position, direction * speed)

func update_speed():
	if perfect_streak < 10 or speed <= 1500:
		speed += 10

func handle_points_and_update_HUD(points):
	if points == 4:
		perfect_streak += 1
	else:
		perfect_streak = 0
	score += points
	$HUD.update_score(score)
	$HUD.update_streak(perfect_streak)

func update_highscore():
	if score > highscore:
		highscore = score
		new_highscore = true
		Settings.save_score(highscore)
	set_highscore_on_homescreen()
	set_highscore_on_gameoverscreen(new_highscore)

func set_highscore_on_homescreen():
	$Screens/HomeScreen/VBoxContainer/Score/HighscoreLabel.text = str(highscore)

func set_highscore_on_gameoverscreen(is_new_highscore):
	if is_new_highscore:
		$Screens/GameOverScreen/VBoxContainer/Score/ScoreLabel.text = "New Highscore!"
		$Screens/GameOverScreen/VBoxContainer/Score/HighscoreLabel.text = str(highscore)
	else:
		$Screens/GameOverScreen/VBoxContainer/Score/ScoreLabel.text = "Your Score:"
		$Screens/GameOverScreen/VBoxContainer/Score/HighscoreLabel.text = str(score)
