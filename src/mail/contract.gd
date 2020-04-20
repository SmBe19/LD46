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
	
	var content = type.mailContent + "\n---\n\nThis is contract #%d. Run 'accept_contract %d' to accept. " % [id, id]
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

func tick():
	if Root.game_tick > accept_time + type.time_limit:
		completed = true
		if len(requests) == 0 && len(sent_requests) == 0:
			# success
			print('sucessful contract!')
			Root.make_transaction('%s from %s' % [type.mailSubject, user.type.user_name], type.reward)
			if type.repeating:
				# generate new contract
				var nextContract = get_script().new(type, user, ContractHandler.next_contract_id)
				ContractHandler.add_contract(nextContract)
		else:
			#failure
			print('failed contract!')
			Root.make_transaction('Failed: %s from %s' % [type.mailSubject, user.type.user_name], -0.5*type.reward)

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
				print('failed')
		
