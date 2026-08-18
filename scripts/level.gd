@tool
extends Node2D

@export var sem_colisao: bool = false

const TAMANHO_TILE := Vector2i(16, 16)
const FONTE_TERRENO := 0
const FONTE_DECORACAO := 1
const TILE_SOLIDO := Vector2i(15, 3)
const TILE_SENTIDO_UNICO := Vector2i(10, 3)
const TILE_ARBUSTO := Vector2i(1, 5)
const TILE_PLACA := Vector2i(3, 5)

const TEXTURA_TERRENO: Texture2D = preload("res://sprites/grassland/terrain.png")
const TEXTURA_ENTIDADES: Texture2D = preload("res://sprites/grassland/entities.png")

@onready var terreno: TileMapLayer = $Terreno
@onready var fundo: TileMapLayer = $Fundo
@onready var casa_principal: Sprite2D = $CasaPrincipal
@onready var casa_alternativa: Sprite2D = $JardimSecreto/CasaAlternativa
@onready var final_principal: Area2D = $FinalPrincipal
@onready var final_alternativo: Area2D = $FinalAlternativo
@onready var brilho_alternativo: Polygon2D = $JardimSecreto/BrilhoFinal


func _ready() -> void:
	_montar_tileset()
	_desenhar_cenario()

	if Engine.is_editor_hint():
		return

	final_principal.body_entered.connect(_abrir_final_principal)
	final_alternativo.body_entered.connect(_abrir_final_alternativo)


func _montar_tileset() -> void:
	var conjunto := TileSet.new()
	conjunto.tile_size = TAMANHO_TILE
	conjunto.add_physics_layer()

	var atlas_terreno := TileSetAtlasSource.new()
	atlas_terreno.texture = TEXTURA_TERRENO
	atlas_terreno.texture_region_size = TAMANHO_TILE
	atlas_terreno.create_tile(TILE_SOLIDO)
	atlas_terreno.create_tile(TILE_SENTIDO_UNICO)
	conjunto.add_source(atlas_terreno, FONTE_TERRENO)

	var solido := atlas_terreno.get_tile_data(TILE_SOLIDO, 0)
	solido.add_collision_polygon(0)
	solido.set_collision_polygon_points(
		0,
		0,
		PackedVector2Array([
			Vector2(-8, -8),
			Vector2(8, -8),
			Vector2(8, 8),
			Vector2(-8, 8),
		])
	)

	var sentido_unico := atlas_terreno.get_tile_data(TILE_SENTIDO_UNICO, 0)
	sentido_unico.add_collision_polygon(0)
	sentido_unico.set_collision_polygon_points(
		0,
		0,
		PackedVector2Array([
			Vector2(-8, -8),
			Vector2(8, -8),
			Vector2(8, -4),
			Vector2(-8, -4),
		])
	)
	sentido_unico.set_collision_polygon_one_way(0, 0, true)
	sentido_unico.set_collision_polygon_one_way_margin(0, 0, 6.0)

	var atlas_decoracao := TileSetAtlasSource.new()
	atlas_decoracao.texture = TEXTURA_ENTIDADES
	atlas_decoracao.texture_region_size = TAMANHO_TILE
	atlas_decoracao.create_tile(TILE_ARBUSTO)
	atlas_decoracao.create_tile(TILE_PLACA)
	conjunto.add_source(atlas_decoracao, FONTE_DECORACAO)

	terreno.tile_set = conjunto
	fundo.tile_set = conjunto
	terreno.collision_enabled = not sem_colisao
	fundo.collision_enabled = false


func _desenhar_cenario() -> void:
	terreno.clear()
	fundo.clear()

	var solidos: Array[Vector2i] = []
	var sentido_unico: Array[Vector2i] = []

	# Dez transicoes obrigatorias: inicio, plataformas, subida, corredor,
	# vao largo, escada e chegada.
	_segmento(solidos, 0, 6, 14)      # inicio
	_segmento(solidos, 9, 14, 14)     # salto 1
	_segmento(solidos, 17, 21, 12)    # salto 2
	_segmento(solidos, 24, 29, 14)    # salto 3
	_segmento(solidos, 30, 35, 16)    # poco controlado da subida
	_segmento(sentido_unico, 31, 35, 14) # subida por baixo 1
	_segmento(sentido_unico, 35, 39, 12) # subida por baixo 2
	_segmento(solidos, 42, 43, 13)    # salto 6
	_segmento(solidos, 45, 46, 13)    # entrada secreta em x=44
	_segmento(solidos, 47, 52, 14)    # corredor baixo
	_segmento(solidos, 47, 52, 11)    # teto do corredor
	_segmento(solidos, 55, 61, 14)    # obstaculo 2: vao largo no limite
	_segmento(solidos, 63, 67, 12)    # salto 8 - escada crescente
	_segmento(solidos, 69, 73, 10)    # salto 9 - escada crescente
	_segmento(solidos, 76, 84, 14)    # salto 10 - chegada

	# Jardim secreto e final alternativo: a abertura em x=44 fica escondida
	# pelos arbustos. O jogador ve o percurso principal acima e tende a seguir
	# reto, sem imaginar que a queda leva a uma rota segura e a outra casa.
	_segmento(solidos, 40, 74, 21)          # piso do jardim e da casa secreta
	_segmento(solidos, 40, 42, 18)          # mirante ao lado da arvore
	_segmento(sentido_unico, 43, 45, 17)    # plataforma de entrada
	_segmento(sentido_unico, 47, 49, 19)    # retorno 1
	_segmento(sentido_unico, 51, 53, 17)    # retorno 2
	_segmento(sentido_unico, 53, 54, 16)    # retorno 3 para o caminho
	_segmento(solidos, 58, 62, 18)          # tunel baixo rumo ao final alternativo
	for y in range(17, 21):
		solidos.append(Vector2i(74, y))       # parede final do jardim escondido

	for celula in solidos:
		terreno.set_cell(celula, FONTE_TERRENO, TILE_SOLIDO, 0)

	for celula in sentido_unico:
		terreno.set_cell(celula, FONTE_TERRENO, TILE_SENTIDO_UNICO, 0)

	# Decoracao sem colisao: prova o terceiro tipo pedido pela atividade.
	for posicao in [
		Vector2i(2, 13), Vector2i(11, 13), Vector2i(19, 11),
		Vector2i(27, 13), Vector2i(43, 12), Vector2i(44, 12),
		Vector2i(58, 13), Vector2i(65, 11), Vector2i(71, 9),
		Vector2i(79, 13), Vector2i(41, 20), Vector2i(44, 20),
		Vector2i(47, 20), Vector2i(50, 20), Vector2i(54, 20),
		Vector2i(57, 20), Vector2i(60, 20), Vector2i(63, 20),
		Vector2i(67, 20), Vector2i(71, 20), Vector2i(73, 20),
	]:
		fundo.set_cell(posicao, FONTE_DECORACAO, TILE_ARBUSTO, 0)

	for posicao in [Vector2i(1, 13), Vector2i(30, 15), Vector2i(77, 13)]:
		fundo.set_cell(posicao, FONTE_DECORACAO, TILE_PLACA, 0)

	terreno.update_internals()
	fundo.update_internals()


func _segmento(destino: Array[Vector2i], inicio: int, fim: int, y: int) -> void:
	for x in range(inicio, fim + 1):
		destino.append(Vector2i(x, y))


func _abrir_final_principal(body: Node2D) -> void:
	if body.name == "Player":
		casa_principal.region_rect = Rect2(120, 0, 120, 96)


func _abrir_final_alternativo(body: Node2D) -> void:
	if body.name == "Player":
		casa_alternativa.region_rect = Rect2(120, 0, 120, 96)
		brilho_alternativo.visible = true
