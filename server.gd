extends Node

enum Message {
	ID,
	JOIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	LOBBY,
	CANDIDATE,
	OFFER,
	ANSWER,
	CHECK_IN,
	JOIN_QUEUE,
	CANCEL_QUEUE
}

var peer = WebSocketMultiplayerPeer.new()
var users = []
var match_queuing = {}
var lobbies = {}
signal receive_data(data)

func _ready():
	receive_data.connect(on_receive_data)
	start_server()
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)
	pass

func on_receive_data(data):
	if data.message == Message.JOIN_QUEUE:
		match_queuing[data.client_id] = {
			"client_id" : data.client_id,
			"deck" : JSON.parse_string(data.deck),
			"player_id" : data.player_id,
			"rp" : data.rp,
			"elo" : data.elo,
			"gamemode" : data.gamemode
		}
	
	if data.message == Message.LOBBY:
		if data.lobby == "create new lobby":
			var l = Lobby.new(data.client_id)
			l.add_player(data)
			
			var lobby_id
			while true:
				lobby_id = generate_random_string()
				if !lobby_id in lobbies: break
			
			data.lobby = lobby_id
			lobbies[lobby_id] = l
			
			var message = {
				"message" : Message.LOBBY,
				"state" : "create",
				"lobby" : lobby_id
			}
			
			send_to_client(int(data.client_id) , message)
		else:
			lobbies[data.lobby].add_player(data)

	if data.message == Message.CANCEL_QUEUE:
		match_queuing.erase(data.client_id)

func _process(delta):
	peer.poll()
	if !(peer.get_available_packet_count() > 0): return #No data sent
	
	var packet = peer.get_packet()
	
	if packet == null: return #trash packet
		
	var data_string = packet.get_string_from_utf8()
	var data = JSON.parse_string(data_string)
	
	receive_data.emit(data)
	pass
	
func peer_connected(id):
	var message = {
		"message" : Message.ID,
		"id" : JSON.stringify(id)
	}
	send_to_client(id , message)
	
	users.append(JSON.stringify(id))
	pass

func peer_disconnected(id):
	match_queuing.erase(JSON.stringify(id))
	users.pop_at(users.find(JSON.stringify(id)))
	pass

func start_server():
	var error = peer.create_server(8915)
	
	if error == OK:
		print("succesfully created server")
		
		
func send_to_client(id , data):
	var message_bytes = JSON.stringify(data).to_utf8_buffer()
	
	peer.get_peer(id).put_packet(message_bytes)

func generate_random_string():
	var Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result = ""
	for i in range(32):
		var index = randi() % Characters.length()
		result += Characters[index]
	return result
