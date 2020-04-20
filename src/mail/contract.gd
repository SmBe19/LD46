extends Node

class_name Contract

var type : ContractType
var user : User
var id : int

var requests : Array = []
var sent_requests : Array = []

var completed : bool = false

var accept_time : int

func _init(type: ContractType, user: User, id: int):
	self.type = type
	self.user = user
	self.id = id
	
	var ip = Root.random_ip(randi()%100 + 100)
	
	var content = type.mailContent
	content +=  "\n---\n\n"
	content += "This is contract #%d. Run 'accept_contract %d' to accept.\n" % [id, id]
	content += "You will need to handle the following requests:\n"
	for k in type.requests.keys():
		content += " - %d x %s\n" % [type.requests[k], RequestHandler.request_types[k].full_name]
	content += "\n"
	content += "The allowed timeframe is: %d days\n" % type.time_limit
	if type.repeating:
		content += "This contract is repeating. After completion, it will be available to complete again."
	var mail = Mail.new(type.mailSubject, content.replace("$ip", str(ip)), user)
	MailHandler.send_mail(mail)
	
	
	for k in type.requests.keys():
		if not k in RequestHandler.request_types:
			push_warning("Unknown request type %s" % k)
			continue
		for i in type.requests[k]:
			var uuid = Root.get_uuid()
			requests.append(
				Request.new(
					uuid, uuid, ip, 
					RequestHandler.request_types[k]))
	requests.shuffle()

func accept():
	accept_time = Root.game_tick

func completed_request(request):
	print('contract %d: completed a request' % id)
	sent_requests.erase(request)

func complete_contract():
	print('sucessful contract!')
	var mail = MailHandler.generate_mail("completed_contract", user)
	mail.subject = mail.subject.replace("$prevSubject", type.mailSubject)
	MailHandler.send_mail(mail)
	Root.make_transaction('%s from %s' % [type.mailSubject, user.type.user_name], type.reward)
	if type.repeating:
		# generate new contract
		var nextContract = get_script().new(type, user, ContractHandler.next_contract_id)
		ContractHandler.add_contract(nextContract)
	completed = true


func fail_contract():
	print('failed contract!')
	var mail = MailHandler.generate_mail("failed_contract", user)
	mail.subject = mail.subject.replace("$prevSubject", type.mailSubject)
	MailHandler.send_mail(mail)
	Root.make_transaction('Failed: %s from %s' % [type.mailSubject, user.type.user_name], -0.5*type.reward)
	completed = true

func tick():
	if completed:
		return
	if Root.game_tick > accept_time + type.time_limit:
		if len(requests) == 0 && len(sent_requests) == 0:
			complete_contract()
		else:
			fail_contract()
		return
	
	if len(requests) == 0:
		return
	if len(sent_requests) < 3:
		if randi() % 10 == 0:
			print('sending request!')
			var request = requests.back()
			if Root.produce_request(request):
				request.connect("request_fulfilled", self, "completed_request")
				requests.pop_back()
				sent_requests.append(request)
			else:
				fail_contract()
		
