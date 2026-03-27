class_name Dialogue
extends Control
  
onready var type_timer := get_node("TypeTyper") as Timer
onready var pause_timer := get_node("PauseTimer") as Timer

export var dialogPath = ""
export(float) var textSpeed = 0.035

var dialog
var phraseNum = 0
var finished = false

func _ready() -> void:
	type_timer.wait_time = textSpeed
	dialog = load_dialog()
	
func _process(delta):
	if not visible:
		return
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			$Content.visible_characters = len($Content.text)
	
func load_dialog():
	var file = File.new()
	assert(file.file_exists(dialogPath), "Dialog File doesn't exist")
	file.open(dialogPath, File.READ)
	var output = file.get_as_text()
	var json = parse_json(output)
	
	return json
	
func nextPhrase():
	if phraseNum >= len(dialog):
		queue_free()
		return
		
	finished = false
	
	$NameLabel.bbcode_text = dialog[phraseNum]["Name"]
	$Content.bbcode_text = dialog[phraseNum]["Text"]

	$Content.visible_characters = 0
	
	while $Content.visible_characters < len($Content.text):
		$Content.visible_characters += 1
		
		type_timer.start()
		yield(type_timer, "timeout")
		
	finished = true
	phraseNum += 1
	return
