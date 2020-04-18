extends Control

const TICK_PER_SECOND = 10

var request_handler
var servers = []
var dns = {}
var ipaddr = {}
var time_since_tick = 0

func _ready():
	request_handler = RequestHandler.new()
	add_new_server("shoutr", "10.0.0.1")

func add_new_server(name, ip):
	var new_server = Server.new(self, name, ip)
	servers.append(new_server)
	dns[name] = new_server
	ipaddr[ip] = new_server

func connect_servers(srv1, srv2):
	srv1.connections.append(srv2)
	srv2.connections.append(srv1)

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

func _process(delta):
	time_since_tick += delta
	while time_since_tick > 1.0/TICK_PER_SECOND:
		tick()
		time_since_tick -= 1.0/TICK_PER_SECOND
