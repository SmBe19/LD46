extends Node

class_name User

const DIFFICULTY_INCREASE = 1000

var happiness : float
var packets = []
var type

func _init(type):
	self.type = type
	happiness = 0.5
	pass

func complete_request(request):
	if request in packets:
		packets.erase(request)
		happiness += 0.1
		print("Successfull request, I'm now happy")
		happiness = min(1, happiness)
		if happiness == 1 and randi() % 5 == 0:
			print("Great work, I recommended your product to other user")
			UserHandler.generate_user()

func failed_request():
	happiness -= 0.1
	if happiness < 0:
		print("User left")
		UserHandler.remove_user(self)

func generate_request():
	var difficulty = 0
	var max_difficulty = Root.game_tick / DIFFICULTY_INCREASE
	difficulty = min(RequestHandler.max_difficulty, randi() % (max_difficulty + 1))
	var type = RequestHandler.generate_request(difficulty)
	var uuid = Root.get_uuid()
	var ip = Root.random_ip(randi()%100 + 100)
	var request = Request.new(uuid, uuid, ip, type)
	if Root.produce_request(request):
		request.connect("request_fulfilled", self, "complete_request")
		packets.append(request)
	else:
		print("User couldn't make request, very disappointing.")
		failed_request()

func tick():
	for request in packets:
		if Root.game_tick - request.start_tick > 200:
			print("Took too long to process request", request.id)
			packets.erase(request)
			failed_request()
	if (randi() % 10 == 0 and len(packets) < 3):
		generate_request()
	pass
