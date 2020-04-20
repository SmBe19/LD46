extends Process

const VALID_UPGRADES = ['cpu', 'disk', 'ram', 'queue']
var VALID_UPGRADE_STR = PoolStringArray(VALID_UPGRADES).join(', ')

func usage():
	send_output('usage: buy_upgrade <item>. Available upgrades: ' + VALID_UPGRADE_STR)

func help():
	send_output("Buy upgrades for the current server.\n")
	usage()
	send_output("\nAlso see: buy_connection, buy_server")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 2:
		usage()
		return 1
	if not VALID_UPGRADES.has(args[1]):
		send_output('Unknown item ' + args[1] + '. Available upgrades: ' + VALID_UPGRADE_STR)
		return 1
	var res = ask_money(server.upgrade_price(args[1]))
	if res is GDScriptFunctionState:
		res = yield(res, 'completed')
	if not res:
		return 0
	var upgrade = server.upgrade(args[1])
	if upgrade:
		send_output(upgrade)
		return 1
	send_output('Successfully ugraded server')
	return 0
