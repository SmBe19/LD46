extends Node


var contract_types = []

var contracts = []


func _ready():
	var config = UserHandler.read_json("res://cfg/contracts.json")
	for contract_json in config:
		var contract_type = ContractType.new(contract_json)
		contract_types.append(contract_type)
	generate_contract()

func generate_contract():
	var index = randi() % len(contract_types)
	var user_index = randi() % len(UserHandler.user_types)
	var user = User.new(UserHandler.user_types[user_index])
	var contract = Contract.new(contract_types[index], user)
	contracts.append(contract)
