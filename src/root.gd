extends Control

const TICK_PER_SECOND = 10

var request_handler
var servers = []
var dns = {}
var ipaddr = {}
var time_since_tick = 0

func _ready():
	add_new_server("shoutr", "10.0.0.1")

func random_ip():
	while true:
		var ip = str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256)
		if not ipaddr.has(ip):
			return ip

func add_new_server(name, ip):
	if dns.has(name) or ipaddr.has(ip):
		return false
	var new_server = Server.new(self, name, ip)
	servers.append(new_server)
	dns[name] = new_server
	ipaddr[ip] = new_server
	return true

func connect_servers(srv1, srv2):
	srv1.connections[srv1.ip] = srv1
	srv1.connections[srv2.ip] = srv2

func resolve_name(name):
	if dns.has(name):
		return dns[name].ip
	return name

func resolve_ip(ip):
	if ipaddr.has(ip):
		return ipaddr[ip]
	return null

func tick():
	for server in servers:
		server.tick()
	for server in servers:
		server.process_incoming()

func _process(delta):
	time_since_tick += delta
	while time_since_tick > 1.0/TICK_PER_SECOND:
		tick()
		time_since_tick -= 1.0/TICK_PER_SECOND
