extends Node


const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 3234

var network = NetworkedMultiplayerENet.new()

var selected_ip
var selected_port

var local_player_id = 0
sync var players = {}
sync var player_data = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _connect_to_server():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(selected_ip, selected_port)
	get_tree().set_network_peer(network)

func _player_connected(id):
	print("Player: %d connected" % id)

func _player_disconnected(id):
	print("Player: %d disconnected" % id)

func _connected_ok():
	print("successfully connected")

func _connected_fail():
	print("failed to connect")

func _server_disconnected():
	print("server disconnected")
