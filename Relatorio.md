1- O jogo começa em uma floresta, nela o jogador tem que subir em plataformas, achar uma 
passagem e também pode entrar em uma caverna. Escolhi essa paisagem pq é o oposto de uma 
caverna e achei que ficaia legal os dois juntos.

Durante o trajeto tem um portal para caverna, lá tem dois caminhos, mas somente um é o 
certo, o jogador tem que decifrar qual é o correto. Escolhi a caverna pq gostei do design 
dela quando estava procurando cenáios.

2 - Floresta 
		Fundo - 0.08
		meio - 0.28
		frente - 0.55
		
	 Caverna 
		 Fundo - 0.10, 0.12
		 Meio - 0.30, 0.34
		 Frente - 0.58, 0.64
		
Para chegar nesses valores, fui testando cada um até achar que estava bom.
Olhando para a versaõ final, parece muito mais realista que no começo,
as paisagens se movem em velocidades diferentes.

3- A pista da entrada secreta está em baixo do percurso original do jogador (na floresta) e 
a porta fica logo ao lado. Separei elas desse jeito para facilitar o acesso e n ser tão difícil 
para o jogador achar.

4- Foi utilizada a câmera como filha da personagem, escolhi essa forma porque ela é mais 
simples de configurar e garante que a câmera acompanhe a personagem automaticamente durante 
toda a fase. Como neste projeto existe apenas uma personagem principal, não precisa trocar o
alvo da câmera durante o jogo. Os limites da câmera foram configurados de acordo com o tamanho
de cada cenário, evitando que ela mostre áreas vazias depois do fim do mapa.
A outra opção seria criar a câmera como uma cena separada, que encontra a personagem por meio
de um grupo. Como neste projeto isso não é necessário, escolhi a câmera como filha da personagem.
Com essa escolha, perco principalmente essa flexibilidade de trocar o alvo da câmera com facilidade,
mas ganho uma implementação mais simples e adequada para o funcionamento das duas fases.

5 - Por que o sinal pode ser disparado enquanto a cena ainda está processando objetos e colisões.
O ideal é primeiro confirmar que quem entrou foi o jogador e então fazer a mudança de cena de
forma segura, evitando erros, chamadas duplicadas ou transições inesperadas.

6 - Uma coisa que me travou foi quando o chão ficou sem colisão e a personagem ficava meio flutuando.
No começo achei que eu tinha configurado alguma coisa errada no TileMap, fui mexendo nas colisões e 
olhando os erros que apareciam no Godot.
Depois percebi que o problema estava no TileSet, que não estava com a colisão configurada corretamente.
Arrumei a colisão dos tiles e fui testando até a personagem andar normalmente pelo cenário.
