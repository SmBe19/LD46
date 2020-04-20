extends Process

func usage():
	send_output('usage: accept_contract <contract number>')

func help():
	send_output("Accept a contract.\n")
	usage()
	send_output("Contracts are bonus tasks meant as a challenging bonus task. "+
		"If you manage to complete all requests in the alloted time frame, you can earn some additional money. "+
		"If you fail to do so however, you will have to pay in damages half of what you would have earned from the contract."+
		"\n\nThink well and check your available resources before accepting a contract.")
	
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
		send_output("Contract not found - maybe you already accepted or completed it, or it expired")
		return 1
	ContractHandler.available_contracts.erase(contract)
	ContractHandler.accepted_contracts.append(contract)
	contract.accept()
	return 0
