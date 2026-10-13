
extends TileMapLayer

@export var tamanho_chunk: int = 32
@export var distancia_carregamento: float = 540.0
@export var distancia_descarregamento: float = 800.0
@export var intervalo_verificacao: float = 0.10
@export var quantidade_minima_tiles: int = 500
@export var grupo_player: StringName = &"player"
@export var nome_dado_tile: String = "mata_player"

@export var tiles_por_frame: int = 256
@export var maximo_descarregamentos_por_verificacao: int = 2

@export var tempo_prioridade_inicial: float = 3.0
@export var tiles_por_frame_inicial: int = 512

var tempo_desde_inicio: float = 0.0

var player: Node2D
var preparado: bool = false

var dados_chunks: Dictionary = {}
var centros_chunks: Dictionary = {}
var regioes_chunks: Dictionary = {}
var chunks_ativos: Dictionary = {}

var fila_carregamento: Array[Vector2i] = []
var chaves_na_fila: Dictionary = {}
var construcao_atual: Dictionary = {}

var raio_chunk: float = 0.0
var tamanho_regiao: float = 1024.0
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
	if preparado or tile_set == null:
		return

	if tamanho_chunk <= 0:
		push_warning("tamanho_chunk precisa ser maior que zero.")
		return

	if not is_instance_valid(player):
		player = _encontrar_player()

		if player == null:
			set_process(true)
			return

	var cells: Array[Vector2i] = get_used_cells()

	if cells.is_empty():
		preparado = true
		set_process(false)
		set_physics_process(tem_dado_morte)
		return

	if cells.size() < quantidade_minima_tiles:
		preparado = true
		set_process(false)
		set_physics_process(tem_dado_morte)
		return

	var parent_node: Node = get_parent()

	if parent_node == null:
		preparado = true
		set_process(false)
		set_physics_process(tem_dado_morte)
		return

	var ordem_original: int = get_index()

	container_chunks = Node2D.new()
	container_chunks.name = name + "_Chunks"

	container_chunks.transform = transform
	container_chunks.z_index = z_index
	container_chunks.z_as_relative = z_as_relative
	container_chunks.modulate = modulate
	container_chunks.self_modulate = self_modulate
	container_chunks.texture_filter = texture_filter
	container_chunks.visibility_layer = visibility_layer
	container_chunks.visible = visible
	container_chunks.y_sort_enabled = y_sort_enabled
	container_chunks.show_behind_parent = show_behind_parent

	parent_node.add_child(container_chunks)
	parent_node.move_child(container_chunks, ordem_original)

	var celulas_por_chunk: Dictionary = {}

	for cell: Vector2i in cells:
		var chunk_x: int = floori(float(cell.x) / float(tamanho_chunk))
		var chunk_y: int = floori(float(cell.y) / float(tamanho_chunk))

		var chave: Vector2i = Vector2i(chunk_x, chunk_y)

		if not celulas_por_chunk.has(chave):
			celulas_por_chunk[chave] = []

		var lista_celulas: Array = celulas_por_chunk[chave]
		lista_celulas.append(cell)

		celulas_por_chunk[chave] = lista_celulas

	var tamanho_mundo_chunk: Vector2 = (
		Vector2(tile_set.tile_size) * float(tamanho_chunk)
	)

	raio_chunk = tamanho_mundo_chunk.length() * 0.5

	for chave_var in celulas_por_chunk.keys():
		var chave: Vector2i = chave_var
		var celulas: Array = celulas_por_chunk[chave]

		var coordenadas: PackedInt32Array = PackedInt32Array()
		var fontes: PackedInt32Array = PackedInt32Array()
		var atlas_x: PackedInt32Array = PackedInt32Array()
		var atlas_y: PackedInt32Array = PackedInt32Array()
		var alternativas: PackedInt32Array = PackedInt32Array()

		for cell: Vector2i in celulas:
			var source_id: int = get_cell_source_id(cell)

			if source_id < 0:
				continue

			var atlas_coords: Vector2i = get_cell_atlas_coords(cell)
			var alternative_tile: int = get_cell_alternative_tile(cell)

			coordenadas.append(cell.x)
			coordenadas.append(cell.y)

			fontes.append(source_id)
			atlas_x.append(atlas_coords.x)
			atlas_y.append(atlas_coords.y)
			alternativas.append(alternative_tile)

		if coordenadas.is_empty():
			continue

		dados_chunks[chave] = {
			"coordenadas": coordenadas,
			"fontes": fontes,
			"atlas_x": atlas_x,
			"atlas_y": atlas_y,
			"alternativas": alternativas
		}

		var metade_chunk: int = floori(float(tamanho_chunk) / 2.0)

		var centro_celula: Vector2i = Vector2i(
			chave.x * tamanho_chunk + metade_chunk,
			chave.y * tamanho_chunk + metade_chunk
		)

		centros_chunks[chave] = to_global(map_to_local(centro_celula))

	if dados_chunks.is_empty():
		preparado = true
		set_process(false)
		set_physics_process(tem_dado_morte)
		return

	var distancia_maxima: float = maxf(
		maxf(0.0, distancia_carregamento),
		maxf(0.0, distancia_descarregamento)
	)

	tamanho_regiao = maxf(512.0, distancia_maxima + raio_chunk)

	for chave_var in centros_chunks.keys():
		var chave: Vector2i = chave_var
		var centro: Vector2 = centros_chunks[chave]

		var regiao: Vector2i = Vector2i(
			floori(centro.x / tamanho_regiao),
			floori(centro.y / tamanho_regiao)
		)

		if not regioes_chunks.has(regiao):
			regioes_chunks[regiao] = []

		var lista_chunks: Array = regioes_chunks[regiao]
		lista_chunks.append(chave)
		regioes_chunks[regiao] = lista_chunks

	enabled = false
	clear()

	var menor_distancia: float = INF
	var chave_inicial: Vector2i = Vector2i.ZERO

	for chave_var in centros_chunks.keys():
		var chave: Vector2i = chave_var
		var distancia: float = centros_chunks[chave].distance_squared_to(
			player.global_position
		)

		if distancia < menor_distancia:
			menor_distancia = distancia
			chave_inicial = chave

	_carregar_chunk_imediato(chave_inicial)

	preparado = true

	set_process(true)
	set_physics_process(tem_dado_morte)

	_atualizar_chunks()

func _carregar_chunk_imediato(chave: Vector2i) -> void:
	if not dados_chunks.has(chave):
		return

	if chunks_ativos.has(chave):
		return

	var chunk: TileMapLayer = _iniciar_chunk(chave)
	var dados: Dictionary = dados_chunks[chave]

	var coordenadas: PackedInt32Array = dados["coordenadas"]
	var fontes: PackedInt32Array = dados["fontes"]
	var atlas_x: PackedInt32Array = dados["atlas_x"]
	var atlas_y: PackedInt32Array = dados["atlas_y"]
	var alternativas: PackedInt32Array = dados["alternativas"]

	var quantidade_celulas: int = coordenadas.size() / 2

	for i in range(quantidade_celulas):
		var indice: int = i * 2

		var celula: Vector2i = Vector2i(
			coordenadas[indice],
			coordenadas[indice + 1]
		)

		var atlas: Vector2i = Vector2i(
			atlas_x[i],
			atlas_y[i]
		)

		chunk.set_cell(
			celula,
			fontes[i],
			atlas,
			alternativas[i]
		)

	_finalizar_chunk(chave, chunk)

func _process(delta: float) -> void:
	if not preparado:
		if not is_instance_valid(player):
			player = _encontrar_player()

		if is_instance_valid(player):
			_criar_chunks()

		return

	tempo_desde_inicio += delta
	var intervalo: float = maxf(0.02, intervalo_verificacao)

	tempo_verificacao += delta

	if tempo_verificacao >= intervalo:
		tempo_verificacao = fmod(tempo_verificacao, intervalo)

		if not is_instance_valid(player):
			player = _encontrar_player()

		if is_instance_valid(player):
			_atualizar_chunks()

	_processar_fila_carregamento()


func _physics_process(_delta: float) -> void:
	if not preparado or morte_acionada or not tem_dado_morte:
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

	var distancia_carregamento_total: float = (
		maxf(0.0, distancia_carregamento) + raio_chunk
	)

	var distancia_descarregamento_total: float = (
		maxf(0.0, distancia_descarregamento) + raio_chunk
	)

	var carregamento_quadrado: float = (
		distancia_carregamento_total * distancia_carregamento_total
	)

	var descarregamento_quadrado: float = (
		distancia_descarregamento_total * distancia_descarregamento_total
	)

	var limite_remocoes: int = maxi(
		1,
		maximo_descarregamentos_por_verificacao
	)

	var remocoes_feitas: int = 0

	for chave_var in chunks_ativos.keys():
		var chave: Vector2i = chave_var
		var chunk: TileMapLayer = chunks_ativos[chave]

		if not is_instance_valid(chunk):
			chunks_ativos.erase(chave)
			continue

		var centro: Vector2 = centros_chunks[chave]

		if posicao_player.distance_squared_to(centro) <= descarregamento_quadrado:
			continue

		if remocoes_feitas >= limite_remocoes:
			continue

		chunk.enabled = false
		chunk.queue_free()

		chunks_ativos.erase(chave)
		remocoes_feitas += 1

	if not construcao_atual.is_empty():
		var chave_construcao: Vector2i = construcao_atual["chave"]
		var centro_construcao: Vector2 = centros_chunks[chave_construcao]

		if posicao_player.distance_squared_to(centro_construcao) > carregamento_quadrado:
			var chunk_construindo: TileMapLayer = construcao_atual["chunk"]

			if is_instance_valid(chunk_construindo):
				chunk_construindo.queue_free()

			construcao_atual.clear()

	_remover_fila_distante(posicao_player, carregamento_quadrado)

	var menor_x: int = floori(
		(posicao_player.x - distancia_carregamento_total) / tamanho_regiao
	)

	var maior_x: int = floori(
		(posicao_player.x + distancia_carregamento_total) / tamanho_regiao
	)

	var menor_y: int = floori(
		(posicao_player.y - distancia_carregamento_total) / tamanho_regiao
	)

	var maior_y: int = floori(
		(posicao_player.y + distancia_carregamento_total) / tamanho_regiao
	)

	for x in range(menor_x, maior_x + 1):
		for y in range(menor_y, maior_y + 1):
			var regiao: Vector2i = Vector2i(x, y)

			if not regioes_chunks.has(regiao):
				continue

			var lista_chunks: Array = regioes_chunks[regiao]

			for chave_var in lista_chunks:
				var chave: Vector2i = chave_var

				if chunks_ativos.has(chave):
					continue

				if chaves_na_fila.has(chave):
					continue

				if not construcao_atual.is_empty():
					if construcao_atual["chave"] == chave:
						continue

				var centro: Vector2 = centros_chunks[chave]

				if posicao_player.distance_squared_to(centro) > carregamento_quadrado:
					continue

				fila_carregamento.append(chave)
				chaves_na_fila[chave] = true

	if fila_carregamento.size() > 1:
		fila_carregamento.sort_custom(
			func(a: Vector2i, b: Vector2i) -> bool:
				var distancia_a: float = centros_chunks[a].distance_squared_to(posicao_player)
				var distancia_b: float = centros_chunks[b].distance_squared_to(posicao_player)

				return distancia_a < distancia_b
		)


func _remover_fila_distante(
	posicao_player: Vector2,
	distancia_quadrada: float
) -> void:
	for i in range(fila_carregamento.size() - 1, -1, -1):
		var chave: Vector2i = fila_carregamento[i]

		if not centros_chunks.has(chave):
			fila_carregamento.remove_at(i)
			chaves_na_fila.erase(chave)
			continue

		var centro: Vector2 = centros_chunks[chave]

		if posicao_player.distance_squared_to(centro) > distancia_quadrada:
			fila_carregamento.remove_at(i)
			chaves_na_fila.erase(chave)


func _processar_fila_carregamento() -> void:
	if not is_instance_valid(player) or container_chunks == null:
		return

	var orcamento: int = maxi(1, tiles_por_frame)

	if tempo_desde_inicio < tempo_prioridade_inicial:
		orcamento = maxi(orcamento, tiles_por_frame_inicial)

	var distancia_total: float = (
		maxf(0.0, distancia_carregamento) + raio_chunk
	)

	var distancia_quadrada: float = distancia_total * distancia_total

	while orcamento > 0:
		if construcao_atual.is_empty():
			if fila_carregamento.is_empty():
				return

			var nova_chave: Vector2i = fila_carregamento[0]
			fila_carregamento.remove_at(0)
			chaves_na_fila.erase(nova_chave)

			if chunks_ativos.has(nova_chave):
				continue

			if not dados_chunks.has(nova_chave):
				continue

			var centro: Vector2 = centros_chunks[nova_chave]

			if player.global_position.distance_squared_to(centro) > distancia_quadrada:
				continue

			var novo_chunk: TileMapLayer = _iniciar_chunk(nova_chave)

			if novo_chunk == null:
				return

			construcao_atual = {
				"chave": nova_chave,
				"chunk": novo_chunk,
				"indice": 0
			}

		var chave_atual: Vector2i = construcao_atual["chave"]

		if not dados_chunks.has(chave_atual):
			var chunk_invalido: TileMapLayer = construcao_atual["chunk"]

			if is_instance_valid(chunk_invalido):
				chunk_invalido.queue_free()

			construcao_atual.clear()
			continue

		var dados: Dictionary = dados_chunks[chave_atual]

		var coordenadas: PackedInt32Array = dados["coordenadas"]
		var fontes: PackedInt32Array = dados["fontes"]
		var atlas_x: PackedInt32Array = dados["atlas_x"]
		var atlas_y: PackedInt32Array = dados["atlas_y"]
		var alternativas: PackedInt32Array = dados["alternativas"]

		var chunk: TileMapLayer = construcao_atual["chunk"]

		if not is_instance_valid(chunk):
			construcao_atual.clear()
			continue

		var quantidade_celulas: int = coordenadas.size() / 2
		var inicio: int = construcao_atual["indice"]

		if inicio >= quantidade_celulas:
			_finalizar_chunk(chave_atual, chunk)
			construcao_atual.clear()
			continue

		var fim: int = mini(
			inicio + orcamento,
			quantidade_celulas
		)

		for i in range(inicio, fim):
			var indice_coordenada: int = i * 2

			var cell: Vector2i = Vector2i(
				coordenadas[indice_coordenada],
				coordenadas[indice_coordenada + 1]
			)

			var atlas_coords: Vector2i = Vector2i(
				atlas_x[i],
				atlas_y[i]
			)

			chunk.set_cell(
				cell,
				fontes[i],
				atlas_coords,
				alternativas[i]
			)

		orcamento -= fim - inicio

		if fim >= quantidade_celulas:
			_finalizar_chunk(chave_atual, chunk)
			construcao_atual.clear()
		else:
			construcao_atual["indice"] = fim
			return


func _iniciar_chunk(chave: Vector2i) -> TileMapLayer:
	var chunk: TileMapLayer = TileMapLayer.new()

	chunk.name = "Chunk_%d_%d" % [chave.x, chave.y]
	chunk.tile_set = tile_set

	chunk.visible = false

	chunk.collision_enabled = false
	chunk.collision_visibility_mode = collision_visibility_mode

	chunk.navigation_enabled = false
	chunk.navigation_visibility_mode = navigation_visibility_mode

	chunk.occlusion_enabled = false

	chunk.use_kinematic_bodies = use_kinematic_bodies

	chunk.physics_quadrant_size = physics_quadrant_size
	chunk.rendering_quadrant_size = rendering_quadrant_size

	chunk.y_sort_origin = y_sort_origin
	chunk.x_draw_order_reversed = x_draw_order_reversed

	chunk.material = material
	chunk.texture_filter = texture_filter
	chunk.visibility_layer = visibility_layer
	chunk.self_modulate = self_modulate
	chunk.y_sort_enabled = y_sort_enabled

	if name == "tileSet":
		chunk.light_mask = 0
	else:
		chunk.light_mask = light_mask

	container_chunks.add_child(chunk)

	return chunk


func _finalizar_chunk(
	chave: Vector2i,
	chunk: TileMapLayer
) -> void:
	chunk.collision_enabled = collision_enabled
	chunk.navigation_enabled = navigation_enabled
	chunk.occlusion_enabled = occlusion_enabled

	chunk.visible = visible
	chunk.enabled = true

	chunks_ativos[chave] = chunk


func _verificar_colisao_mortal() -> void:
	var corpo_player: CharacterBody2D = player as CharacterBody2D

	if corpo_player == null:
		return

	var quantidade_colisoes: int = corpo_player.get_slide_collision_count()

	if quantidade_colisoes <= 0:
		return

	for i in range(quantidade_colisoes):
		var colisao: KinematicCollision2D = corpo_player.get_slide_collision(i)

		if colisao == null:
			continue

		var objeto: Object = colisao.get_collider()

		if objeto == null:
			continue

		var chunk: TileMapLayer = objeto as TileMapLayer

		if chunk == null:
			continue

		if chunk != self and chunk.get_parent() != container_chunks:
			continue

		if not chunk.enabled:
			continue

		var posicao_colisao: Vector2 = colisao.get_position()
		var normal: Vector2 = colisao.get_normal()

		var ponto_no_tile: Vector2 = posicao_colisao - normal * 2.0
		var ponto_local: Vector2 = chunk.to_local(ponto_no_tile)
		var celula: Vector2i = chunk.local_to_map(ponto_local)

		if chunk.get_cell_source_id(celula) < 0:
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
		return encontrado as Node2D

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
			return node as Node2D

	return null
