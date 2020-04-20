extends Control

const TICK_PER_SECOND = 10
const LEVEL_MULTIPLIER = [
	1,
	4,
	27,
	42,
	270,
	333,
	0,
	0,
	0,
	0,
	0,
	0,
]

var request_handler
var servers = []
var dns = {}
var ipaddr = {}
var time_since_tick = 0
var game_tick = 0
var global_uuid = 0
var money = 2048
var money_log = []
var daily_report_sender_type
var daily_report_sender
var daily_request_complete = 0
var daily_request_complete_fake = 0
var daily_request_fail = 0
var daily_request_drop = 0
var daily_request_block = 0
var daily_request_fake_checked = 0
var daily_request_fake_detected = 0
var daily_request_fake_detected_wrong = 0
var daily_request_fake_dropped = 0
var daily_request_fake_blocked = 0
var daily_users_new = 0
var daily_users_left = 0

var game_running = true

func _init():
	randomize()
	add_new_server("shoutr", "10.0.0.1")
	servers[0].disk *= 4
	servers[0].ram *= 2
	servers[0].upgrade_level['disk'] = 2
	servers[0].upgrade_level['ram'] = 1
	init_daily_report()

func init_daily_report():
	daily_report_sender_type = UserType.new({
		'name': 'Daily Report',
		'mail': 'daily-report@shoutr.io',
		'hacker': false,
		'politeness': 0,
	})
	daily_report_sender = User.new(daily_report_sender_type, false)

func average(values):
	var sum = 0
	for value in values:
		sum += value
	if len(values) > 0:
		sum /= len(values)
	return sum

func random_ip(prefix):
	if not prefix:
		prefix = randi()%256
	while true:
		var ip = str(prefix) + "." + str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256)
		if not ipaddr.has(ip):
			return ip

func buy_something(price, what):
	if money < price:
		return 'Not enough money ($' + str(price) + ' required)'
	money_log.append("-$" + str(price) + ": " + what)
	money -= price
	return ''

func make_transaction(description, x):
	money_log.append(("-" if x < 0 else "+") + "$" + str(abs(x)) + ": " + description)
	money += x

func new_server_price():
	return 1024

func add_new_server(name, ip):
	var res = buy_something(new_server_price(), 'Server ' + name)
	if res:
		return res
	if dns.has(name) or ipaddr.has(ip):
		return 'Name or IP already in use'
	var new_server = Server.new(name, ip)
	servers.append(new_server)
	dns[name] = new_server
	ipaddr[ip] = new_server
	return ''

func new_connection_price(srv1, srv2):
	return 128 * (max(len(srv1.connections), len(srv2.connections)) + 1)

func connect_servers(srv1, srv2):
	if srv1.connections.has(srv2.ip):
		return 'Connection already exists'
	var res = buy_something(new_connection_price(srv1, srv2), 'Connection ' + srv1.server_name + ' <-> ' + srv2.server_name)
	if res:
		return res
	srv1.connections[srv2.ip] = srv2
	srv2.connections[srv1.ip] = srv1
	srv1.update_fs()
	srv2.update_fs()
	return ''

func resolve_name(name):
	if dns.has(name):
		return dns[name].ip
	return name

func resolve_ip(ip):
	if ipaddr.has(ip):
		return ipaddr[ip]
	return null

func get_uuid():
	global_uuid += 1
	return global_uuid

func request_completed(request):
	if request.fake_request:
		daily_request_complete_fake += 1
		return
	daily_request_complete += 1
	var duration = game_tick - request.start_tick
	if duration == 0:
		duration += 1
	var multiplier = LEVEL_MULTIPLIER[request.type.level]
	var new_money = multiplier * 64 / duration
	if new_money > 0:
		money_log.append("+$" + str(new_money) + ": " + request.type.full_name + " " + str(request.id))
		money += new_money

func produce_request(request):
	var server = servers[0]
	if len(server.input_queue) + server.incoming_requests_count >= server.queue_length:
		if request.fake_request:
			daily_request_fake_dropped += 1
		else:
			daily_request_drop += 1
		return false
	if server.receive_request(request):
		request.connect("request_fulfilled", self, "request_completed")
		return true
	else:
		if request.fake_request:
			daily_request_fake_blocked += 1
		else:
			daily_request_block += 1
	return false


func update_displays():
	var happiness = 0.0
	for user in UserHandler.users:
		happiness += user.happiness
	if len(UserHandler.users) > 0:
		happiness /= len(UserHandler.users)
	$"/root/ScnRoot/Angry Users".value = 1 - happiness

	var maildir = Root.servers[0].fs_root.get_node('var/mail')
	var count = 0
	if maildir is FSDir:
		for mail in maildir.children.values():
			if mail.accessed == mail.created:
				count += 1
	$"/root/ScnRoot/Mail".value = min(1.0, count / 11.0)

	var queue = 0.0
	for server in servers:
		queue += float(len(server.input_queue) + server.incoming_requests_count) / server.queue_length
	queue /= len(servers)
	$"/root/ScnRoot/Queue".value = min(1.0, queue)

	var ddos = 0.0
	var enabled = 0
	for server in servers:
		if server.has_ddos_installed:
			enabled += 1
			var checked = 0
			for i in server.ddos_checked:
				checked += i
			var blocked = 0
			for i in server.ddos_detected:
				blocked += i
			if checked > 0:
				ddos += float(blocked) / checked
	if enabled > 0:
		ddos /= enabled
	$"/root/ScnRoot/DDoS".value = ddos

func send_daily_report():
	var content = ''
	content += 'Users\n'
	content += 'Total: ' + str(len(UserHandler.users)) + '\n'
	content += 'New: ' + str(daily_users_new) + '\n'
	content += 'Lost: ' + str(daily_users_left) + '\n'
	content += '\n'
	content += 'Real Requests\n'
	content += 'Served: ' + str(daily_request_complete) + '\n'
	content += 'Timeout: ' + str(daily_request_fail) + '\n'
	content += 'Dropped: ' + str(daily_request_drop) + '\n'
	content += 'Blocked: ' + str(daily_request_block) + '\n'
	content += '\n'
	content += 'DDoS Requests\n'
	content += 'Served: ' + str(daily_request_complete_fake) + '\n'
	content += 'Dropped: ' + str(daily_request_fake_dropped) + '\n'
	content += 'Blocked: ' + str(daily_request_fake_blocked) + '\n'
	content += 'Checked: ' + str(daily_request_fake_checked) + '\n'
	content += 'Detected Correct: ' + str(daily_request_fake_detected) + '\n'
	content += 'Detected Wrong: ' + str(daily_request_fake_detected_wrong) + '\n'
	daily_request_complete = 0
	daily_request_complete_fake = 0
	daily_request_fail = 0
	daily_request_drop = 0
	daily_request_block = 0
	daily_request_fake_checked = 0
	daily_request_fake_detected = 0
	daily_request_fake_detected_wrong = 0
	daily_request_fake_dropped = 0
	daily_request_fake_blocked = 0
	daily_users_new = 0
	daily_users_left = 0
	var mail = Mail.new('Daily Report', content, daily_report_sender)
	MailHandler.send_mail(mail)

func tick():
	game_tick += 1
	for user in UserHandler.users:
		user.tick()
	ContractHandler.tick()
	for server in servers:
		server.tick()
	for server in servers:
		server.process_incoming()
	# TODO check lose condition
	if false:
		game_running = false
	if game_tick % (TICK_PER_SECOND * 45) == 0:
		send_daily_report()
	update_displays()

func _process(delta):
	if not game_running:
		return
	time_since_tick += delta
	while time_since_tick > 1.0/TICK_PER_SECOND:
		tick()
		time_since_tick -= 1.0/TICK_PER_SECOND
