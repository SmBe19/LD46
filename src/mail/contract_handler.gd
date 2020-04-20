extends Node

const EXPIRY_TIME = 60*Root.TICK_PER_SECOND
const FIRST_CONTRACT = 5*60*Root.TICK_PER_SECOND

var contract_types = []

var next_contract_id : int = 1

var available_contracts = []
var accepted_contracts = []


func _ready():
	var config = UserHandler.read_json("res://cfg/contracts.json")
	for contract_json in config:
		var contract_type = ContractType.new(contract_json)
		contract_types.append(contract_type)
	#generate_contract()

func generate_contract():
	var index = randi() % len(contract_types)
	var user_index = randi() % len(UserHandler.user_types)
	var user = User.new(UserHandler.user_types[user_index])
	var contract = Contract.new(contract_types[index], user, next_contract_id)
	add_contract(contract)

func add_contract(contract):
	next_contract_id += 1
	available_contracts.append(contract)

func tick():
	if Root.game_tick >= FIRST_CONTRACT:
		if len(available_contracts) + len(accepted_contracts) < 3 && randi() % 300 == 0:
			generate_contract()

	for i in range(len(available_contracts)-1, -1, -1):
		if available_contracts[i].receive_time + EXPIRY_TIME < Root.game_tick:
			available_contracts.remove(i)
			
	for contract in accepted_contracts:
		contract.tick()
	for i in range(len(accepted_contracts)-1, -1, -1):
		if accepted_contracts[i].completed:
			accepted_contracts.remove(i)
