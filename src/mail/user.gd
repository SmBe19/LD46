extends Node

class_name User

const DIFFICULTY_INCREASE = 2560

var happiness : float
var packets = []
var type
var sendsMails : bool = false

func _init(type, init = true):
	self.type = type
	happiness = 0.5
	if not init:
		return
	var existingMailer = false
	for user in UserHandler.users:
		if user.type == type and user.sendsMails:
			existingMailer = true
	print("Existing mailer: ", existingMailer)
	sendsMails = not existingMailer and (randi() % 5 == 0)
	print("Sends mail: ", sendsMails)

func complete_request(request):
	if request in packets:
		packets.erase(request)
		happiness += 0.1
		print("Successfull request, I'm now happy")
		happiness = min(1, happiness)
		if happiness == 1 and randi() % 5 == 0:
			print("Great work, I recommended your product to other user")
			UserHandler.generate_user()

#reduce chance to send mails for large numbers of users
func throttle_chance(chance):
	return chance * (len(UserHandler.users)/2 + 5)
	
func failed_request():
	happiness -= 0.1
	if happiness < 0.5 and sendsMails and randi() % 5 == 0:
		var mail = MailHandler.generate_mail("complaint", self)
		print(type.user_name, " sent complaint")
		MailHandler.send_mail(mail)
	if happiness < 0:
		print("User left")
		Root.daily_users_left += 1
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
			Root.daily_request_fail += 1
			failed_request()
	if (randi() % 10 == 0 and len(packets) < 3):
		generate_request()
	pass
