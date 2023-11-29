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
	CHECK_IN
}

var peer = WebSocketMultiplayerPeer.new()

func _ready():
	connect_to_server("")

	pass

func _process(delta):
	peer.poll()



func connect_to_server(ip):
	var error = peer.create_client("ws://localhost:8915")
	
	var message = {
		"message" : Message.USER_CONNECTED,
		"data" : "test"
	}
	
	send_to_server(message)
	


func send_to_server(data):
	var message_bytes = JSON.stringify(data).to_utf8_buffer()
	
	peer.put_packet(message_bytes)
	


func _on_send_data_pressed():
	var message = {
		"message" : Message.USER_CONNECTED,
		"data" : "test"
	}
	
	
	send_to_server(message)
	pass
