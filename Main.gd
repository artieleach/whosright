extends Control

onready var users = $CenterContainer/MainList/BottomList/Users
onready var user_name = $CenterContainer/MainList/TopList/names/user_name
onready var other_name = $CenterContainer/MainList/TopList/names/other_name
onready var user_score = $CenterContainer/MainList/TopList/scores/your_score
onready var other_score = $CenterContainer/MainList/TopList/scores/their_score
onready var text_input = $CenterContainer/MainList/BottomList/TextEdit
onready var delete = $CenterContainer/MainList/BottomList/delete
onready var set_user_name = $set_user_name
onready var title = $CenterContainer/MainList/TopList/title

var scores = {}
var user_name_string = ''
var focused_user = ''
var highlight_user = 0
var titles = [
"Wait, who was right?", 
"Didn't I win the las argument?", 
"Score Counter",
"I'm pretty sure I was right",
"Score Keeper",
"Argument Settler",
"Nah I have receipts",
"Hmm, lemme check"]

var database = {}

func _ready():
	randomize()
	load_game()
	update_names()
	title.text = titles[randi() % len(titles)]
	if len(scores.keys()) > 0:
		focused_user = scores.keys()[0]
	update_selection()
	if user_name_string == '':
		$CenterContainer.hide()
		$set_user_name.show()

func search_database(name):
	if name in database.keys():
		scores[name] = database[name][user_name_string]


func update_selection():
	user_name.text = user_name_string
	if focused_user != '':
		other_name.text = focused_user
		user_score.text = '%d' % scores[focused_user][0]
		other_score.text = '%d' % scores[focused_user][1]

func update_names():
	users.clear()
	for name in scores.keys():
		users.add_item(name)
		var new_name = Label.new()
		new_name.text = name
		new_name.set("custom_colors/font_color", Color(0, 0, 0))
		$CenterContainer/MainList/BottomList/ScrollContainer/NameList.add_child(new_name)

func save():
	var save_dict = {
		"scores": scores,
		"user_name_string": user_name_string,
	}
	return save_dict

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		for item in node_data.keys():
			set(item, node_data[item])

func _on_Users_item_activated(index):
	focused_user = scores.keys()[index]
	update_selection()


func _on_add_user_text_entered(new_text):
	$Panel.color = Color(0.5, 0.0, 0.5)
	scores[new_text] = [0, 0]
	focused_user = new_text
	update_names()
	update_selection()
	save_game()


func _on_left_button_pressed():
	if focused_user in scores.keys():
		scores[focused_user][0] = scores[focused_user][0] + 1
		update_selection()
	save_game()


func _on_right_button_pressed():
	if focused_user in scores.keys():
		scores[focused_user][1] = scores[focused_user][1] + 1
		update_selection()
	save_game()




func _on_TextEdit_text_changed():
	if '\n' in text_input.text:
		text_input.text = text_input.text.strip_edges()
		scores[text_input.text] = [0, 0]
		focused_user = text_input.text
		update_names()
		update_selection()
		text_input.text = ''
		save_game()


func _on_TextEdit_focus_entered():
	text_input.text = ''


func _on_TextEdit_focus_exited():
	text_input.text = 'add user...'


func _on_Users_item_selected(index):
	focused_user = scores.keys()[index]
	update_selection()
	highlight_user = index

func _on_delete_pressed():
	if len(scores.keys()) > 0:
		scores.erase(scores.keys()[highlight_user])
		highlight_user = 0
		update_names()
		save_game()


func _on_left_down_pressed():
	if focused_user in scores.keys():
		scores[focused_user][0] = scores[focused_user][0] - 1
		update_selection()
	save_game()



func _on_right_down_pressed():
	if focused_user in scores.keys():
		scores[focused_user][1] = scores[focused_user][1] - 1
		update_selection()
	save_game()


func _on_set_user_name_text_changed():
	if '\n' in set_user_name.text:
		set_user_name.text = set_user_name.text.strip_edges()
		user_name_string = set_user_name.text
		save_game()
		set_user_name.hide()
		update_selection()
		$CenterContainer.show()

func _on_set_user_name_focus_entered():
	set_user_name.text = ''
