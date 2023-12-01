extends RefCounted

class_name Lobby

var host
var id
var players = {}

func _init(host_id):
	host = host_id

func on_peer_disconnected(id):
	if str(id) in players:
		remove_player(str(id))

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

func remove_player(player_id):
	players.erase(player_id)
	
	if players.size() <= 0:
		Server.lobbies[id] = null
		Server.lobbies.erase(id)
