extends TileMapLayer

@export var tamanho_chunk: int = 32
@export var distancia_carregamento: float = 540.0
@export var distancia_descarregamento: float = 800.0
@export var intervalo_verificacao: float = 0.10
@export var quantidade_minima_tiles: int = 500
@export var grupo_player: StringName = &"player"

@export var nome_dado_tile: String = "mata_player"

var player: Node2D
var preparado: bool = false

var dados_chunks: Dictionary = {}
var centros_chunks: Dictionary = {}
var chunks_ativos: Dictionary = {}

var raio_chunk: float = 0.0

var tempo_verificacao: float = 0.0

var container_chunks: Node2D

var tem_dado_morte: bool = false
var morte_acionada: bool = false


func _ready() -> void:
	set_process(false)
	set_physics_process(false)

	if tile_set != null:
		tem_dado_morte = tile_set.has_custom_data_layer_by_name(nome_dado_tile)

	player = _encontrar_player()

	call_deferred("_criar_chunks")


func _criar_chunks() -> void:
	if preparado:
		return

	if tile_set == null:
		return

	var cells: Array[Vector2i] = get_used_cells()

	if cells.is_empty():
		preparado = true
		set_physics_process(tem_dado_morte)
		return

	player = _encontrar_player()

	if player == null:
		push_warning("Player nao encontrado em: " + name)
		return

	if cells.size() < quantidade_minima_tiles:
		preparado = true
		set_physics_process(tem_dado_morte)
		return

	var parent: Node = get_parent()

	if parent == null:
		return

	var ordem_original: int = get_index()

	container_chunks = Node2D.new()
	container_chunks.name = name + "_Chunks"

	container_chunks.transform = transform
	container_chunks.z_index = z_index
	container_chunks.z_as_relative = z_as_relative
	container_chunks.modulate = modulate
	container_chunks.self_modulate = self_modulate
	container_chunks.material = material
	container_chunks.texture_filter = texture_filter
	container_chunks.visibility_layer = visibility_layer
	container_chunks.visible = visible
	container_chunks.y_sort_enabled = y_sort_enabled
	container_chunks.show_behind_parent = show_behind_parent

	parent.add_child(container_chunks)
	parent.move_child(container_chunks, ordem_original)

	var celulas_por_chunk: Dictionary = {}

	for cell: Vector2i in cells:
		var chunk_x: int = floori(float(cell.x) / float(tamanho_chunk))
		var chunk_y: int = floori(float(cell.y) / float(tamanho_chunk))

		var chave: Vector2i = Vector2i(chunk_x, chunk_y)

		if not celulas_por_chunk.has(chave):
			celulas_por_chunk[chave] = []

		var lista: Array = celulas_por_chunk[chave]
		lista.append(cell)
		celulas_por_chunk[chave] = lista

	var tamanho_mundo_chunk: Vector2 = Vector2(tile_set.tile_size) * float(tamanho_chunk)
	raio_chunk = tamanho_mundo_chunk.length() * 0.5

	for chave_var in celulas_por_chunk.keys():
		var chave: Vector2i = chave_var
		var celulas: Array = celulas_por_chunk[chave]

		if celulas.is_empty():
			continue

		var fontes: PackedInt32Array = PackedInt32Array()
		var atlas_x: PackedInt32Array = PackedInt32Array()
		var atlas_y: PackedInt32Array = PackedInt32Array()
		var alternativas: PackedInt32Array = PackedInt32Array()

		var celulas_validas: Array[Vector2i] = []

		for cell: Vector2i in celulas:
			var source_id: int = get_cell_source_id(cell)

			if source_id < 0:
				continue

			var atlas_coords: Vector2i = get_cell_atlas_coords(cell)
			var alternative_tile: int = get_cell_alternative_tile(cell)

			celulas_validas.append(cell)
			fontes.append(source_id)
			atlas_x.append(atlas_coords.x)
			atlas_y.append(atlas_coords.y)
			alternativas.append(alternative_tile)

		if celulas_validas.is_empty():
			continue

		dados_chunks[chave] = {
			"celulas": celulas_validas,
			"fontes": fontes,
			"atlas_x": atlas_x,
			"atlas_y": atlas_y,
			"alternativas": alternativas
		}

		var centro_celula: Vector2i = Vector2i(
			chave.x * tamanho_chunk + tamanho_chunk / 2,
			chave.y * tamanho_chunk + tamanho_chunk / 2
		)

		var centro_global: Vector2 = to_global(map_to_local(centro_celula))

		centros_chunks[chave] = centro_global

	clear()

	enabled = false

	preparado = true

	set_process(dados_chunks.size() > 0)
	set_physics_process(tem_dado_morte)

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


func _physics_process(_delta: float) -> void:
	if not preparado:
		return

	if morte_acionada:
		return

	if not tem_dado_morte:
		return

	if not is_instance_valid(player):
		player = _encontrar_player()

		if player == null:
			return

	_verificar_colisao_mortal()


func _atualizar_chunks() -> void:
	if not is_instance_valid(player):
		return

	var posicao_player: Vector2 = player.global_position

	var distancia_carregamento_total: float = distancia_carregamento + raio_chunk
	var distancia_descarregamento_total: float = distancia_descarregamento + raio_chunk

	var distancia_carregamento_quadrado: float = (
		distancia_carregamento_total * distancia_carregamento_total
	)

	var distancia_descarregamento_quadrado: float = (
		distancia_descarregamento_total * distancia_descarregamento_total
	)

	for chave_var in dados_chunks.keys():
		var chave: Vector2i = chave_var

		if chunks_ativos.has(chave):
			continue

		var centro: Vector2 = centros_chunks[chave]
		var distancia_quadrada: float = posicao_player.distance_squared_to(centro)

		if distancia_quadrada <= distancia_carregamento_quadrado:
			_criar_chunk(chave)

	var chunks_para_remover: Array[Vector2i] = []

	for chave_var in chunks_ativos.keys():
		var chave: Vector2i = chave_var
		var chunk: TileMapLayer = chunks_ativos[chave]

		if not is_instance_valid(chunk):
			chunks_para_remover.append(chave)
			continue

		var centro: Vector2 = centros_chunks[chave]
		var distancia_quadrada: float = posicao_player.distance_squared_to(centro)

		if distancia_quadrada > distancia_descarregamento_quadrado:
			chunk.enabled = false
			chunk.queue_free()
			chunks_para_remover.append(chave)

	for chave in chunks_para_remover:
		chunks_ativos.erase(chave)


func _criar_chunk(chave: Vector2i) -> void:
	if chunks_ativos.has(chave):
		return

	if not dados_chunks.has(chave):
		return

	if container_chunks == null:
		return

	var dados: Dictionary = dados_chunks[chave]

	var celulas: Array[Vector2i] = dados["celulas"]
	var fontes: PackedInt32Array = dados["fontes"]
	var atlas_x: PackedInt32Array = dados["atlas_x"]
	var atlas_y: PackedInt32Array = dados["atlas_y"]
	var alternativas: PackedInt32Array = dados["alternativas"]

	var chunk: TileMapLayer = TileMapLayer.new()

	chunk.name = "Chunk_%d_%d" % [chave.x, chave.y]

	chunk.tile_set = tile_set

	chunk.collision_enabled = collision_enabled
	chunk.collision_visibility_mode = collision_visibility_mode

	chunk.navigation_enabled = navigation_enabled
	chunk.navigation_visibility_mode = navigation_visibility_mode

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

	if name == "tileSet":
		chunk.light_mask = 0
	else:
		chunk.light_mask = light_mask

	for i in celulas.size():
		var cell: Vector2i = celulas[i]

		var source_id: int = fontes[i]

		var atlas_coords: Vector2i = Vector2i(
			atlas_x[i],
			atlas_y[i]
		)

		var alternative_tile: int = alternativas[i]

		chunk.set_cell(
			cell,
			source_id,
			atlas_coords,
			alternative_tile
		)

	container_chunks.add_child(chunk)

	chunks_ativos[chave] = chunk


func _verificar_colisao_mortal() -> void:
	var quantidade_colisoes: int = player.get_slide_collision_count()

	if quantidade_colisoes <= 0:
		return

	for i in quantidade_colisoes:
		var colisao: KinematicCollision2D = player.get_slide_collision(i)

		if colisao == null:
			continue

		var objeto: Object = colisao.get_collider()

		if objeto == null:
			continue

		var chunk: TileMapLayer = objeto as TileMapLayer

		if chunk == null:
			continue

		if chunk.get_parent() != container_chunks:
			continue

		if not chunk.enabled:
			continue

		var posicao_colisao: Vector2 = colisao.get_position()
		var normal: Vector2 = colisao.get_normal()

		var ponto_no_tile: Vector2 = posicao_colisao - normal * 2.0
		var ponto_local: Vector2 = chunk.to_local(ponto_no_tile)
		var celula: Vector2i = chunk.local_to_map(ponto_local)

		var source_id: int = chunk.get_cell_source_id(celula)

		if source_id < 0:
			continue

		var tile_data: TileData = chunk.get_cell_tile_data(celula)

		if tile_data == null:
			continue

		var mata: Variant = tile_data.get_custom_data(nome_dado_tile)

		if mata == true:
			morte_acionada = true
			_matar_player()
			return


func _matar_player() -> void:
	if not is_instance_valid(player):
		return

	var cena: Node = get_tree().current_scene

	if cena == null:
		return

	if not cena.has_method("gameover"):
		return

	cena.gameover()


func _encontrar_player() -> Node2D:
	var encontrado: Node = get_tree().get_first_node_in_group(grupo_player)

	if encontrado is Node2D:
		return encontrado

	var cena: Node = get_tree().current_scene

	if cena == null:
		return null

	var nomes: Array[String] = [
		"Player",
		"player",
		"Mike",
		"mike",
		"Jogador",
		"jogador"
	]

	for nome in nomes:
		var node: Node = cena.find_child(nome, true, false)

		if node is Node2D:
			return node

	return null
