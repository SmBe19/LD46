extends Node

const HACKER_CHANCE = 0.05
const NO_HACKER_BEFORE = 1200

var users = []
var user_types = []
var hacker_types = []

func _ready():
	var config = read_json("res://cfg/users.json")
	for request_json in config:
		var user = UserType.new(request_json)
		if user.hacker:
			hacker_types.append(user)
		else:
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
	if Root.game_tick > NO_HACKER_BEFORE and randf() < HACKER_CHANCE:
		generate_hacker()
		return
	print('Generate new user')
	Root.daily_users_new += 1
	var index = randi() % len(user_types)
	var user = User.new(user_types[index])
	users.append(user)

func generate_hacker():
	print('Generate new hacker')
	Root.daily_users_new += 1
	var index = randi() % len(hacker_types)
	var user = User.new(hacker_types[index])
	users.append(user)

func remove_user(user):
	print('Remove user')
	users.erase(user)
