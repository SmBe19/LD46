extends Node

class_name User

const DIFFICULTY_INCREASES = [
	2500,
	3500,
	6000,
	12000,
	15000,
	18000,
	21000,
	25000,
]
const INITIAL_CALMNESS = 1200
const HACKER_DURATION = 300
const HACKER_CREATION_CHANCE = 0.005
const HACKER_REQUEST_COUNT = 40

var happiness : float
var ip : String
var packets = []
var type
var sendsMails : bool = false
var start_tick : int
var happiness_speed : float
var last_new_user : int

func _init(type, init = true):
	self.type = type
	happiness = 0.5
	if not init:
		return
	start_tick = Root.game_tick
	last_new_user = 0
	happiness_speed = randf() + 0.2
	happiness_speed *= happiness_speed
	var existingMailer = false
	ip = Root.random_ip(randi()%42 + 101)
	var mailcount = 0
	for user in UserHandler.users:
		if user.sendsMails and user.type.hacker == type.hacker:
			mailcount += 1
			if user.type == type:
				existingMailer = true
	sendsMails = not existingMailer and randf() < 0.2 and mailcount < 5

func complete_request(request):
	if request in packets:
		packets.erase(request)
		happiness += 0.07 * happiness_speed
		happiness = min(1, happiness)
		if happiness == 1 and Root.game_tick - last_new_user > 100 and randf() < 0.1:
			last_new_user = Root.game_tick
			UserHandler.generate_user()

#reduce chance to send mails for large numbers of users
func throttle_chance(chance):
	return chance * pow(1.0 / len(UserHandler.users), 0.33)

func failed_request():
	if Root.game_tick > INITIAL_CALMNESS:
		happiness -= 0.04 * happiness_speed
	if happiness < 0.5 and sendsMails and randf() < throttle_chance(0.2):
		var mail = MailHandler.generate_mail("complaint", self)
		MailHandler.send_mail(mail)
	happiness = max(0, happiness)
	if type.hacker:
		if happiness < 0.5 and randf() < throttle_chance(0.1) and sendsMails:
			var mail = MailHandler.generate_mail("scam", self)
			MailHandler.send_mail(mail)
		if Root.game_tick - start_tick > HACKER_DURATION:
			Root.daily_users_left += 1
			UserHandler.remove_user(self)
	else:
		if happiness < 0.1 and randf() < HACKER_CREATION_CHANCE:
			UserHandler.generate_hacker()
		if happiness == 0 and randf() < 0.05:
			Root.daily_users_left += 1
			UserHandler.remove_user(self)

func generate_request(fake):
	var difficulty = 0
	var max_difficulty = 0
	for i in len(DIFFICULTY_INCREASES):
		if Root.game_tick > DIFFICULTY_INCREASES[i]:
			max_difficulty = i+1
	max_difficulty = min(RequestHandler.max_difficulty, max_difficulty)
	difficulty = randi() % (max_difficulty + 1)
	var type = RequestHandler.generate_request(difficulty)
	var uuid = Root.get_uuid()
	var request = Request.new(uuid, uuid, ip, type)
	request.fake_request = fake
	if Root.produce_request(request):
		request.connect("request_fulfilled", self, "complete_request")
		packets.append(request)
	else:
		failed_request()

func tick():
	for request in packets:
		if Root.game_tick - request.start_tick > 200:
			packets.erase(request)
			Root.daily_request_fail += 1
			failed_request()
	if (randf() < 0.1 and len(packets) < 3):
		generate_request(false)
	if type.hacker:
		if randf() < 0.5 and len(packets) < HACKER_REQUEST_COUNT:
			generate_request(true)
