extends RefCounted

class_name Lobby

var host
var players = {}

func _init(host_id):
	host = host_id

func add_player(player_data):
	players[player_data.client_id] = player_data
	
	if players.size() == 2:
		for p in players:
			var message = {
				"message" : Server.Message.LOBBY,
				"state" : "start",
				"players" : JSON.stringify(players)
			}
			Server.send_to_client(int(p) , message)
		pass
	pass
