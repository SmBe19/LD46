extends Node

var users = []
var user_types = []

func _ready():
	var config = read_json("res://cfg/users.json")
	for request_json in config:
		var user = UserType.new(request_json)
		user_types.append(user)
	for i in 2:
		generate_user()

func read_json(path):
	var file = File.new()
	file.open(path, file.READ)
	var json = file.get_as_text()
	var json_result = JSON.parse(json)
	file.close()
	return json_result.result

func generate_user():
	Root.daily_users_new += 1
	var index = randi() % len(user_types)
	var user = User.new(user_types[index])
	users.append(user)

func remove_user(user):
	users.erase(user)
