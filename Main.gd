extends Control

onready var users = $CenterContainer/MainList/BottomList/Users
onready var user_name = $CenterContainer/MainList/TopList/names/user_name
onready var other_name = $CenterContainer/MainList/TopList/names/other_name
onready var user_score = $CenterContainer/MainList/TopList/scores/your_score
onready var other_score = $CenterContainer/MainList/TopList/scores/their_score
onready var text_input = $CenterContainer/MainList/BottomList/TextEdit
onready var delete = $CenterContainer/MainList/BottomList/delete
onready var set_user_name = $set_user_name
var names = []
var scores = {}
var user_name_string = ''
var focused_user = ''
var highlight_user = 0


func _ready():
	load_game()
	update_names()
	if len(names) > 0:
		focused_user = names[0]
	update_selection()
	if user_name_string == '':
		$CenterContainer.hide()
		$set_user_name.show()

func update_selection():
	user_name.text = user_name_string
	if focused_user != '':
		other_name.text = focused_user
		user_score.text = '%d' % scores[focused_user][0]
		other_score.text = '%d' % scores[focused_user][1]

func update_names():
	users.clear()
	for name in names:
		users.add_item(name)

func save():
	var save_dict = {
		"names": names,
		"scores": scores,
		"user_name_string": user_name_string
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
	focused_user = names[index]
	update_selection()


func _on_add_user_text_entered(new_text):
	$Panel.color = Color(0.5, 0.0, 0.5)
	names.append(new_text)
	scores[new_text] = [0, 0]
	print('pn add user text')
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
		names.append(text_input.text)
		scores[text_input.text] = [0, 0]
		print('textedit')
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
	focused_user = names[index]
	update_selection()
	highlight_user = index

func _on_delete_pressed():
	if len(names) > 0:
		if names[highlight_user] in scores.keys():
			scores.erase(names[highlight_user])
			names.remove(highlight_user)
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
