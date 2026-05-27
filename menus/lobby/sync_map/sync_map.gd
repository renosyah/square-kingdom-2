extends Node

signal on_client_request_map(client_id)
signal on_map_received(client_id)

var manifest :TileMapFileManifest
var map_data :TileMapFileData

const CHUNK_SIZE := 8192
var _received_map_chunks := []
var _expected_map_chunks := 0

onready var timer = $Timer

func request_map_data():
	manifest = null
	map_data = null
	
	rpc_id(NetworkLobbyManager.host_id, "_request_map_data", NetworkLobbyManager.get_id())

# HOST
remote func _request_map_data(from_id : int):
	emit_signal("on_client_request_map", from_id)
	rpc_id(from_id, "_receive_map_manifest", var2bytes(manifest.to_dictionary()))
	
	var bytes : PoolByteArray = var2bytes(map_data.to_dictionary())
	var total_chunks := int(ceil(bytes.size() / float(CHUNK_SIZE)))
	
	for i in range(total_chunks):
		var start := i * CHUNK_SIZE
		var end := min(start + CHUNK_SIZE, bytes.size())
		var chunk := bytes.subarray(start, end - 1)
		
		timer.start()
		yield(timer,"timeout")
		
		rpc_id(from_id, "_receive_map_chunk", i, total_chunks, chunk)
	
# CLIENT
remote func _receive_map_manifest(data : PoolByteArray):
	manifest = TileMapFileManifest.new()
	manifest.from_dictionary(bytes2var(data))

# CLIENT
remote func _receive_map_chunk(chunk_index:int, total_chunks: int, chunk:PoolByteArray):
	if _received_map_chunks.empty():
		_expected_map_chunks = total_chunks
		_received_map_chunks.resize(total_chunks)
		
	_received_map_chunks[chunk_index] = chunk

	var completed := true
	for i in range(_expected_map_chunks):
		if _received_map_chunks[i] == null:
			completed = false
			break
	
	if completed:
		var final_bytes := PoolByteArray()
		for c in _received_map_chunks:
			final_bytes.append_array(c)
			
		map_data = TileMapFileData.new()
		map_data.from_dictionary(bytes2var(final_bytes))
		
		_received_map_chunks.clear()
		_expected_map_chunks = 0
		
		var id = NetworkLobbyManager.get_id()
		emit_signal("on_map_received", id)
		rpc_id(NetworkLobbyManager.host_id ,"_map_data_received", id)
		
remote func _map_data_received(player_network_unique_id :int):
	emit_signal("on_map_received", player_network_unique_id)

















