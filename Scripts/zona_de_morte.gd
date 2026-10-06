extends TileMapLayer

@export var tamanho_chunk: int = 32
@export var distancia_carregamento: float = 540.0
@export var distancia_descarregamento: float = 800.0
@export var intervalo_verificacao: float = 0.10
@export var quantidade_minima_tiles: int = 500
@export var grupo_player: StringName = &"player"

@export var nome_dado_tile: String = "mata_player"
@export var nome_dado_acido: String = "acido"
@export var offset_pe: float = 16.0

var player: Node2D
var chunks: Array[TileMapLayer] = []
var centros_chunks: Array[Vector2] = []
var raio_chunk: float = 0.0
var tempo_verificacao: float = 0.0
var preparado := false

var tem_dado_morte := false
var tem_dado_acido := false
var ultima_celula_player := Vector2i(999999, 999999)

var efeito_acido := preload("res://Cenas/splash.tscn")


func _ready() -> void:
	set_process(false)

	if tile_set != null:
		tem_dado_morte = tile_set.has_custom_data_layer_by_name(nome_dado_tile)
		tem_dado_acido = tile_set.has_custom_data_layer_by_name(nome_dado_acido)

	call_deferred("_criar_chunks")


func _criar_chunks() -> void:
	if preparado:
		return

	if tile_set == null:
		return

	var cells := get_used_cells()

	if cells.is_empty():
		return

	if cells.size() < quantidade_minima_tiles:
		preparado = true
		return

	player = _encontrar_player()

	if player == null:
		push_warning("Player nao encontrado. Otimizacao cancelada em: " + name)
		return

	var parent := get_parent()

	if parent == null:
		return

	var ordem_original := get_index()

	var container := Node2D.new()
	container.name = name + "_Chunks"

	container.transform = transform
	container.z_index = z_index
	container.z_as_relative = z_as_relative
	container.modulate = modulate
	container.self_modulate = self_modulate
	container.material = material
	container.texture_filter = texture_filter
	container.visibility_layer = visibility_layer
	container.y_sort_enabled = y_sort_enabled
	container.show_behind_parent = show_behind_parent

	parent.add_child(container)
	parent.move_child(container, ordem_original)

	var celulas_por_chunk: Dictionary = {}

	for cell in cells:
		var chunk_x := floori(float(cell.x) / float(tamanho_chunk))
		var chunk_y := floori(float(cell.y) / float(tamanho_chunk))
		var chave := Vector2i(chunk_x, chunk_y)

		if not celulas_por_chunk.has(chave):
			celulas_por_chunk[chave] = []

		celulas_por_chunk[chave].append(cell)

	var tamanho_mundo_chunk := Vector2(tile_set.tile_size) * float(tamanho_chunk)
	raio_chunk = tamanho_mundo_chunk.length() * 0.5

	for chave in celulas_por_chunk.keys():
		var celulas: Array = celulas_por_chunk[chave]

		if celulas.is_empty():
			continue

		var chunk := TileMapLayer.new()

		chunk.name = "Chunk_%d_%d" % [chave.x, chave.y]

		if name == "tileSet":
			chunk.light_mask = 0

		chunk.tile_set = tile_set
		chunk.collision_enabled = collision_enabled
		chunk.navigation_enabled = navigation_enabled
		chunk.occlusion_enabled = occlusion_enabled
		chunk.use_kinematic_bodies = use_kinematic_bodies
		chunk.physics_quadrant_size = physics_quadrant_size
		chunk.rendering_quadrant_size = rendering_quadrant_size
		chunk.y_sort_origin = y_sort_origin
		chunk.x_draw_order_reversed = x_draw_order_reversed

		chunk.modulate = modulate
		chunk.self_modulate = self_modulate
		chunk.material = material
		chunk.texture_filter = texture_filter
		chunk.visibility_layer = visibility_layer
		chunk.y_sort_enabled = y_sort_enabled

		container.add_child(chunk)

		for cell in celulas:
			var source_id := get_cell_source_id(cell)

			if source_id < 0:
				continue

			var atlas_coords := get_cell_atlas_coords(cell)
			var alternative_tile := get_cell_alternative_tile(cell)

			chunk.set_cell(
				cell,
				source_id,
				atlas_coords,
				alternative_tile
			)

		var centro_celula := Vector2i(
			chave.x * tamanho_chunk + tamanho_chunk / 2,
			chave.y * tamanho_chunk + tamanho_chunk / 2
		)

		var centro_global := to_global(map_to_local(centro_celula))

		chunks.append(chunk)
		centros_chunks.append(centro_global)

	enabled = false

	preparado = true

	set_process(true)

	_atualizar_chunks()


func _process(delta: float) -> void:
	if not preparado:
		return

	tempo_verificacao += delta

	if tempo_verificacao < intervalo_verificacao:
		return

	tempo_verificacao = 0.0

	if not is_instance_valid(player):
		player = _encontrar_player()

		if player == null:
			return

	_atualizar_chunks()

	_verificar_tile_mortal()


func _atualizar_chunks() -> void:
	if player == null:
		return

	var posicao_player := player.global_position

	for i in chunks.size():
		var chunk := chunks[i]

		if not is_instance_valid(chunk):
			continue

		var distancia := posicao_player.distance_to(centros_chunks[i])

		if chunk.enabled:
			if distancia > distancia_descarregamento + raio_chunk:
				chunk.enabled = false
		else:
			if distancia <= distancia_carregamento + raio_chunk:
				chunk.enabled = true


func _verificar_tile_mortal() -> void:
	if not is_instance_valid(player):
		return

	if not tem_dado_morte and not tem_dado_acido:
		return

	var posicao_pe := player.global_position + Vector2(0, offset_pe)
	var posicao_local := to_local(posicao_pe)
	var celula := local_to_map(posicao_local)

	if celula == ultima_celula_player:
		return

	ultima_celula_player = celula

	var tile_data := get_cell_tile_data(celula)

	if tile_data == null:
		return

	var mata := false
	var acido := false

	if tem_dado_morte:
		mata = tile_data.get_custom_data(nome_dado_tile) == true

	if tem_dado_acido:
		acido = tile_data.get_custom_data(nome_dado_acido) == true

	if not mata and not acido:
		return

	_matar_player(acido)


func _matar_player(acido: bool) -> void:
	if not is_instance_valid(player):
		return

	if acido:
		criar_efeito(player.global_position)

	if player.get_parent().has_method("gameover"):
		player.get_parent().gameover()
	elif player.has_method("gameover"):
		player.gameover()
	elif player.has_method("morrer"):
		player.morrer()


func criar_efeito(pos: Vector2) -> void:
	await get_tree().create_timer(0.2).timeout

	if not is_instance_valid(player):
		return

	var efeito = efeito_acido.instantiate()
	efeito.global_position = pos
	efeito.emitting = true
	get_tree().current_scene.add_child(efeito)


func _encontrar_player() -> Node2D:
	var encontrado := get_tree().get_first_node_in_group(grupo_player)

	if encontrado is Node2D:
		return encontrado

	var cena := get_tree().current_scene

	if cena == null:
		return null

	var nomes := [
		"Player",
		"player",
		"Mike",
		"mike",
		"Jogador",
		"jogador"
	]

	for nome in nomes:
		var node := cena.find_child(nome, true, false)

		if node is Node2D:
			return node

	return null
