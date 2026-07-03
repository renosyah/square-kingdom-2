extends Node
class_name CampaignMapGeneration

func generate_province(city_tile_position:Vector2, town_amount:int, fort_amount:int, province_size:int, rng :RandomNumberGenerator) -> Array:
	var result = []
	
	var min_town_radius := max(2, int(province_size * 0.3))
	var min_fort_radius := max(3, int(province_size * 0.6))
	var used_positions = {}
	# -------------------------
	# 1. GENERATE TOWNS
	# -------------------------
	var town_generated = 0
	var tries = 0
	
	while town_generated < town_amount and tries < town_amount * 20:
		tries += 1
		
		var angle = rng.randf() * PI * 2.0
		var radius = lerp(1.0, float(min_fort_radius), rng.randf())
		
		var offset = Vector2(cos(angle), sin(angle)) * radius
		var pos = city_tile_position + offset.round()
		
		if is_taken(used_positions, pos):
			continue
		
		if pos.distance_to(city_tile_position) < min_town_radius:
			continue
		
		mark(used_positions, pos)
		
		result.append({
			"tile_id": pos,
			"type": "town",
			"connected_to": [city_tile_position]
		})
		
		town_generated += 1
	
	# -------------------------
	# 2. GENERATE FORTS
	# -------------------------
	var fort_generated = 0
	tries = 0
	
	while fort_generated < fort_amount and tries < fort_amount * 30:
		tries += 1
		
		var angle = rng.randf() * PI * 2.0
		var radius = lerp(float(min_fort_radius), float(province_size), rng.randf())
		
		var pos = city_tile_position + Vector2(cos(angle), sin(angle)) * radius
		pos = pos.round()
		
		if is_taken(used_positions, pos):
			continue
		
		if pos.distance_to(city_tile_position) < min_fort_radius:
			continue
		
		mark(used_positions, pos)
		
		result.append({
			"tile_id": pos,
			"type": "fort",
			"connected_to": [city_tile_position]
		})
		
		fort_generated += 1
	
	# -------------------------
	# 3. CONNECT TOWNS TO CLOSEST FORT OR CITY
	# -------------------------
	for i in range(result.size()):
		var node = result[i]
		
		if node["type"] == "town":
			var closest = city_tile_position
			var closest_dist = node["tile_id"].distance_to(city_tile_position)
			
			for f in result:
				if f["type"] == "fort":
					var d = node["tile_id"].distance_to(f["tile_id"])
					if d < closest_dist:
						closest = f["tile_id"]
						closest_dist = d
			
			node["connected_to"].append(closest)
			result[i] = node
	
	return result

# helper to avoid overlap
func is_taken(used_positions :Dictionary, pos:Vector2) -> bool:
	return used_positions.has(pos)

func mark(used_positions :Dictionary, pos:Vector2):
	used_positions[pos] = true
	
