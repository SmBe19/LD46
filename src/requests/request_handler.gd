extends Node

class_name RequestHandler

func _init():
	print("Hello world!")
	var config = read_json("res://cfg/requests.json")
	print(config[0])

func read_json(path):
	var file = File.new()
	file.open(path, file.READ)	
	var json = file.get_as_text()
	var json_result = JSON.parse(json)
	file.close()
	return json_result.result
