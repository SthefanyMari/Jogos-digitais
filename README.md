# A1 - Caminho do Pinguim: Dois Finais

Projeto demonstrativo para a atividade **A1: mini cenario jogavel**, da disciplina Jogos Digitais II.

## Como abrir

1. Instale e abra a Godot 4.7.1.
2. No Gerenciador de Projetos, escolha **Importar**.
3. Selecione o arquivo `project.godot` desta pasta.
4. Aguarde a importacao das imagens.
5. Pressione **F5** para jogar.

Use as setas para andar e **Espaco** para pular.

O jardim secreto fica sob a parte central do mapa. A entrada esta escondida
pelos dois arbustos posicionados entre as pequenas plataformas antes do
corredor. Depois da descida, existem duas escolhas:

- subir pelas plataformas e retornar ao percurso da casa principal;
- continuar pela parte inferior, atravessar o tunel e encontrar a casa florida,
  que representa o final alternativo.

## O que o projeto possui

- Personagem como cena separada (`entities/player.tscn`).
- `CharacterBody2D`, `CollisionShape2D` e `AnimatedSprite2D`.
- Animacoes `idle`, `walk` e `jump` do pinguim do Sprite Pack 6.
- Cenario Grassland criado com `TileMapLayer` e grade 16 x 16.
- Camadas separadas `Terreno` e `Fundo`, sendo `Fundo` sem fisica e com Z Index -1.
- Colisao solida, colisao de sentido unico e decoracao sem colisao.
- Dez transicoes que exigem pulo do inicio ate a casa.
- Duas subidas obrigatorias atravessando plataformas por baixo.
- Tres obstaculos de manobras diferentes:
  1. corredor baixo, no qual pular faz o personagem bater no teto;
  2. vao largo, que exige um salto proximo do limite de alcance;
  3. escada de plataformas em alturas crescentes, que exige saltos em sequencia.
- Duas casas como marcos de chegada e dois finais jogaveis.
- A casa principal encerra o caminho superior.
- A casa florida encerra a rota secreta inferior e acende um brilho especial.
- Jardim secreto elaborado, com entrada escondida, plataforma de descida,
  vegetacao, tunel inferior e escada de retorno ao percurso principal.
- As portas das duas casas se abrem quando o pinguim chega.
- Tela limpa, sem contador, painel de instrucoes ou mensagens sobrepostas.

## Por que o caminho alternativo e secreto

A passagem fica camuflada por dois arbustos antes do corredor. Nesse ponto, o
caminho principal continua para a direita e em uma parte mais alta da tela, por
isso o jogador tende a olhar para as plataformas superiores e evita cair. A
queda que parece perigosa, na verdade, termina em uma plataforma segura e leva
ao jardim inferior. A segunda casa tambem fica abaixo do percurso principal e
so pode ser vista por quem decide continuar pelo tunel.

## Arquivos importantes

- `scenes/game.tscn`: cenario final completo.
- `scenes/game_sem_colisao.tscn`: copia preparada para o Print 2.
- `entities/player.tscn`: personagem e animacoes.
- `scripts/player.gd`: movimento, pulo, animacao e reinicio apos queda.
- `scripts/level.gd`: TileSet, celulas, colisoes e percurso.
- `sprites/`: imagens originais CC0 de GrafxKid.

## Licenca dos recursos

Os sprites de GrafxKid incluidos nas pastas `sprites/player` e `sprites/grassland` sao CC0. Os arquivos `LICENSE.txt` originais acompanham o projeto.
