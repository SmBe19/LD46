extends Process

func usage():
	send_output('usage: accept_contract <contract number>')

func help():
	send_output("Accept a contract.\n")
	usage()
	
func run(args):
	if len(args) != 2:
		usage()
		return 1
	var num = int(args[1])
	if num <= 0:
		send_output("Invalid contract number.")
		return 1
	var contract
	for c in ContractHandler.available_contracts:
		if c.id == num:
			contract = c
			break
	if contract == null:
		send_output("Unknown contract")
		return 1
	ContractHandler.available_contracts.erase(contract)
	ContractHandler.accepted_contracts.append(contract)
	contract.accept()
	return 0
