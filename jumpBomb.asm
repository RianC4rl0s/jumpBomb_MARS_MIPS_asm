.data 
	bitmapbase: .word 0x10010000
	coordenadasFinaisPersonagem : .word 0,0
	#x da lateral, y 1, y2,y3,y4,y5
	coordenadasColisaoPersonagem: .word 0,0,0,0,0,0
	coordenadasFinaisInimigo : .word 0,0
	#x da lateral, y1,y2,y,3
	coordenadasColisaoInimigo: .word 0,0,0,0
	#branco 16777215
	#vermelho 16711680
	#verde 2263842
	#azulciano 18983107
	#marrom 25512780
	#amarelo 16776960
	#laranja 16753920
	#azulciano 18983107
	mensagemInicio: .asciiz "Deseja iniciar?"
	mensagem:  .asciiz "Deseja jogar novamente?"
	pontuacao: .asciiz "GAME OVER! \n Pontuação Final: "
	velocidade: .word 20
	posicaoX: .word 34
	posicaoY: .word 47
	#configurações
	#o bitmap display deve ter como largura de pixel 8x8 e largura de display em pixel 512 x 512, ou 4x e 256x 256 respectivamente
	#qualquer proporção q resulte em 64 pontos na tela
	#com endereço base 0x10010000 (static data)
	#o personagem tem tamanho 5x5 e pode ter sua posição inicial modificada
	
.globl main 
.text
main:
li $v0, 50
la $a0, mensagemInicio
syscall
beq $a0, 1, fim
comecarDeNovo:
	li $s1, 0 #Salva a pontuação.
	lw $s2, velocidade #velociade dos compenentes	
	li $s3, 3 #VIDAS, NAO MODIFICAR
	jal desenharCeu	#desenha ceu
	jal desenharTerreno #desenha terreno
	jal desenharVidas	#desenha vidas
	jal gerarInimigoAleatorio #cria o primeiro inimigo em uma posicão nova aleatoria
	lw $a0, posicaoX	#alterar x onde o personagem ira nascer
	lw $a1, posicaoY 	#alterar y onde o personagem ira nascer
	jal renderizarPersonagem #criando o personagem inicial
	jal pause
	
	cicloDeTeclado:
	
	#pegandoTeclaDoTeclado
	li $t0, 0xffff0000 #endereço base do teclado
	lw $t1, 0($t0)
	li $a0, 30 # tempo em mili secs
	li $v0, 32 #syscall para esperar
	syscall
	beq $t1,0, naoFazerNada #Se não  tiver 1  na entrada nao fzr nada
	li $t0, 0xffff0004 
	lw $t1, 0($t0)
	bne $t1, 119, naoFazerNada #verifica se a tecla foi o "w"
		
		la $t0, coordenadasFinaisPersonagem 
		lw $t2, 4($t0)
		slti $t2,$t2, 55
		bne $t2, 0, naoFazerNada #ve se o personagem está no ar
		li $v0, 1
		li $a0, 1
		syscall
		

	li $t1, 0
	sw $t1, 0xffff0004 #reseta o valor para n ficar pulando infinitamente
	jal pular #pula
		
	naoFazerNada:
		la $t0, coordenadasFinaisInimigo
		lw $a0 , 0($t0)
		lw $a1, 4($t0)
		jal movimentarInimigo
		li $v0, 1
		li $a0, 0
		syscall
	j cicloDeTeclado
fim:	
	li $v0, 10
	syscall
	
# retorna $v0 com o endereço da memoria

coordenadasParaEndereco:
	addi $sp, $sp, -12 #prepara oilha para  coordenadasParaEndereco
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	la $t0, bitmapbase #endereço base
	lw $t1, 0($t0)
	li $v0, 64 	#largura da tela
	mul $v0, $v0, $a1	#multiplicando me retorna a linha
	add $v0, $v0, $a0	#adiciono o x para saber a coluna
	mul $v0, $v0, 4		#multiplico por 4 para colocar no formato de endereço de word
	add $v0, $v0, $t1	#soma ao endereco base
	
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra			# retorna a memoria $v0			

		
#$a0 endereco $a1 cor	
desenharPixel:	
	sw $a1, 0($a0)  #salva no endereço do bitmap a cor
	jr $ra	
	
desenharCeu:	
	addi $sp, $sp, -20 #prepara oilha para  desenharCeu
	sw $t2, 16($sp)
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	
	li $t0, 1
	li $t1, 55
	forDesenharCeuY: beq $t0, $t1,fimForDesenharCeuY
		li $t2, 0
		li $t3, 64
		forDesenharCeuX: beq $t2, $t3,fimForDesenharCeuX
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco
			addi $a0, $v0,0
			li $t4, 18983107
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
		j forDesenharCeuX
		fimForDesenharCeuX:
		addi $t0, $t0, 1
	j forDesenharCeuY
	fimForDesenharCeuY:
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20
	jr $ra	
		
desenharTerreno:	
	addi $sp, $sp, -20 #prepara oilha para  desenharTerreno
	sw $t2, 16($sp)
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	
	li $t0,55
	li $t1, 64
	forDesenharTerrenoY: beq $t0, $t1,fimForDesenharTerrenoY
		li $t2, 0
		li $t3, 64
		forDesenharTerrenoX: beq $t2, $t3,fimForDesenharTerrenoX
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco
			addi $a0, $v0,0
			li $t4, 2263842
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
		j forDesenharTerrenoX
		fimForDesenharTerrenoX:
		addi $t0, $t0, 1
	j forDesenharTerrenoY
	fimForDesenharTerrenoY:
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20
	jr $ra			#volta para instrução abaixo  da chamada da função
	
	
desenharVidas:	   #desenha as 3 vidas no canto superior direito
	addi $sp, $sp, -20 #prepara pilha para  desenharVidas
	sw $t2, 16($sp)
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	
	#Coordenadas onde será desenhado as 3 vidas na tela
	#Desenhando a 1a vida
	li $t0, 2 #Y inicial
	li $t1, 5 #Y final
	forDesenharVida1Y: beq $t0, $t1,fimForDesenharVida1Y #for desenha vida 1
		li $t2, 51 #X inicial
		li $t3, 54 #X final
		forDesenharVida1X:
			beq $t2, $t3,fimForDesenharVida1X
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco #Coverte a coordenada para um pixel na tela
			addi $a0, $v0,0	
			li $t4, 16711680 #cor que será pintada
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
			addi $t5,$t5,1
		j forDesenharVida1X
		fimForDesenharVida1X:
		addi $t0, $t0, 1
	j forDesenharVida1Y
	fimForDesenharVida1Y:
	
	#Desenhar a 2a vida
	li $t0, 2 #Y inicial
	li $t1, 5 #Y final	
	forDesenharVida2Y: beq $t0, $t1,fimForDesenharVida2Y #for desenhaVida 2
		li $t2, 56 #X inicial
		li $t3, 59 #X final
		forDesenharVida2X:
			beq $t2, $t3,fimForDesenharVida2X
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco #Coverte a coordenada para um pixel na tela
			addi $a0, $v0,0	
			li $t4, 16711680 #cor que será pintada
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
			addi $t5,$t5,1
		j forDesenharVida2X
		fimForDesenharVida2X:
		addi $t0, $t0, 1
	j forDesenharVida2Y
	fimForDesenharVida2Y:
	
	#Desenha a 3a vida
	li $t0, 2 #Y inicial
	li $t1, 5 #Y final	
	forDesenharVida3Y: beq $t0, $t1,fimForDesenharVida3Y #for desenha vida 3
		li $t2, 61 #X inicial
		li $t3, 64 #X final
		forDesenharVida3X:
			beq $t2, $t3,fimForDesenharVida3X 
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco #Coverte a coordenada para um pixel na tela
			addi $a0, $v0,0	
			li $t4, 16711680 #cor que será pintada
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
			addi $t5,$t5,1
		j forDesenharVida3X
		fimForDesenharVida3X:
		addi $t0, $t0, 1
	j forDesenharVida3Y
	fimForDesenharVida3Y:	
	
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
apagarVidas: #apaga as vidas de acordo com o reg $s3
#Essa função é chamada quando acontece uma colisão do personagem com o inimigo
	addi $sp, $sp, -20 #prepara pilha para apagarVidas
	sw $t2, 16($sp)
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	
#caso não seja a ultima vida, ele apenas apagará uma e seguirá o jogo
beq $s3,2,apagarVida3 #apaga a 3a vida se o $s3 receber o valor 2
beq $s3,1,apagarVida2 #apaga a 2a vida se o $s3 receber o valor 1

#apagando a 1a vida se atingido 3x pela flecha, quando o $s3 receber o valor 0
	li $t0, 2 #Y inicial
	li $t1, 5 #Y final
	forApagarVida1Y: beq $t0, $t1,fimForApagarVida1Y #for apagar vida
		li $t2, 51 #X inicial
		li $t3, 54 #X final
		forApagarVida1X:
			beq $t2, $t3,fimForApagarVida1X
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco #Coverte a coordenada para um pixel na tela
			addi $a0, $v0,0	
			li $t4, 18983107 #cor que será pintada
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
			addi $t5,$t5,1
		j forApagarVida1X
		fimForApagarVida1X:
		addi $t0, $t0, 1
	j forApagarVida1Y
	fimForApagarVida1Y:
	j sairApagarVidas #caso seja esta a selecionada, após apagar a vida ela sai da função apagarVidas 

#apagando a 3a vida se atingido 1x pela flecha, quando o $s3 receber o valor 2
apagarVida3:
	li $t0, 2 #Y inicial
	li $t1, 5 #Y final	
	forApagarVida3Y: beq $t0, $t1,fimForApagarVida3Y
		li $t2, 61 #X inicial
		li $t3, 64 #X final
		forApagarVida3X:
			beq $t2, $t3,fimForApagarVida3X
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco #Coverte a coordenada para um pixel na tela
			addi $a0, $v0,0	
			li $t4, 18983107 #cor que será pintada
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
			addi $t5,$t5,1
		j forApagarVida3X
		fimForApagarVida3X:
		addi $t0, $t0, 1
	j forApagarVida3Y
	fimForApagarVida3Y:
	j sairApagarVidas #caso seja esta a selecionada, após apagar a vida ela sai da função apagarVidas 

#apagando a 2a vida se atingido 2x pela flecha, quando o $s3 receber o valor 1
apagarVida2:
	li $t0, 2 #Y inicial
	li $t1, 5 #Y inicial
	forApagarVida2Y: beq $t0, $t1,fimForApagarVida2Y
		li $t2, 56 #X inicial
		li $t3, 59 #X final
		forApagarVida2X:
			beq $t2, $t3,fimForApagarVida2X
			addi $a0,$t2,0
			addi $a1, $t0,0
			jal coordenadasParaEndereco #Coverte a coordenada para um pixel na tela
			addi $a0, $v0,0	
			li $t4, 18983107 #cor que será pintada
			addi $a1, $t4, 0
			jal desenharPixel
			
			addi $t2,$t2,1
			addi $t5,$t5,1
		j forApagarVida2X
		fimForApagarVida2X:
		addi $t0, $t0, 1
	j forApagarVida2Y
	fimForApagarVida2Y:
	j sairApagarVidas #caso seja esta a selecionada, após apagar a vida ela sai da função apagarVidas 

sairApagarVidas: #final da função, chamada após a escolha
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20
jr $ra
	
	#a função renderizar personagem é a função inicial para o mesmo, a partir dela a coisao com o chao e a gravidade sao 
	#calculadas, usa o pixel mais a cima na esquerda como referencia
	#onde #a0 = x inicial , $a1, = y inicial
	renderizarPersonagem:
	addi $sp, $sp, -16 #prepara oilha para  renderizarPersonagem
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
		addi $t0, $a0,0#salva o a0 e a1
		addi $t1, $a1,0		
		
		jal desenharPersonagem #usa o a0 e a1 para desenhar o personagem
		
		la $t3, coordenadasFinaisInimigo #apos desenhar o personagem movimentar o inimigo usando o vetor que salva a sua ultima 
		# coordenada
		lw $a0 , 0($t3)
		lw $a1, 4($t3)
		jal movimentarInimigo
		
		la $t3, coordenadasFinaisPersonagem #salva coordenadas finais do personagem e chama função que testa a colisao com terreno
		addi $a0, $t0 ,5
		sw $a0, 0($t3)
		addi $a1, $t1,  5
		sw $a1, 4($t3)
		jal testarColisaoPersonagemTerreno			
								
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16	
	jr $ra	
	
	#usa o pixel mais a baixo na direita como referencia
	# onde $a0 = x final, e $a1 = y final
	testarColisaoPersonagemTerreno:	
	
	addi $sp, $sp, -16 #prepara pilha para  testarColisao
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	
		addi $t3, $a0,0 #salva o a0 e a1
		addi $t1,  $a1,0
		
		jal pause
		slti $t0, $t1, 55	# se o ultimo y do personagem for menor q o primeiro y do terreno
		li $t2, 0
		beq $t0, $t2, colisaoPersonagemTerrenoVerdadeira # se verdadeira, nao faz nada, se falso chama renderizar personagem 1 pixel a baixo
	
		#Se a colisao for falsa desenha apaga um linha a cima , usando a ultima coordenada
		addi $a0, $t3, -5
		addi $a1, $t1, -5
		jal coordenadasParaEndereco
		addi $a0, $v0, 0
		li $a1, 18983107
		jal desenharPixel
	
		addi $a0, $t3, -4
		addi $a1, $t1, -5
		jal coordenadasParaEndereco
		addi $a0, $v0, 0
		li $a1, 18983107
		jal desenharPixel
	
		addi $a0, $t3, -3
		addi $a1, $t1, -5
		jal coordenadasParaEndereco
		addi $a0, $v0, 0
		li $a1, 18983107
		jal desenharPixel
	
		addi $a0, $t3, -2
		addi $a1, $t1, -5
		jal coordenadasParaEndereco
		addi $a0, $v0, 0
		li $a1, 18983107
		jal desenharPixel
	
		addi $a0, $t3, -1
		addi $a1, $t1, -5
		jal coordenadasParaEndereco
		addi $a0, $v0, 0
		li $a1, 18983107
		jal desenharPixel
	#apos apagar uma linha, chama a função de renderizar personagem novamente, porem uma linha a baixo
	# se a referencia da colisao do personagem é o ultimo pixel, para desenhar o personagem a partir do peimeiro pixel, basta subtrair 
	# a largura  e a altura - 1
	addi $a0, $t3,-5
	addi $a1, $t1, -4
	jal renderizarPersonagem

	colisaoPersonagemTerrenoVerdadeira: # simplismente sai 

	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16	
	jr $ra	
	#usa como referencia o primeiro pixel 
	#a0  = x inicial a1 = y inicial
	desenharPersonagem:
		addi $sp, $sp , -16 #prepara pilha para desenhar Personagem
		sw $t3, 12($sp)
		sw $t0, 8($sp)
		sw $ra, 4($sp)
		sw $t1, 0($sp)
		
		addi $t0, $a0, 0
		addi $t1, $a1, 0
			
		#linha 1
		addi $a0,$t0,0
		addi $a1, $t1,0
		li $a3 , 16711680
		jal desenho 
		
		addi $a0,$t0,1
		addi $a1, $t1,0
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,0
		li $a3, 0
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,0
		li $a3, 0
		jal desenho
		
		addi $a0,$t0,4
		addi $a1, $t1,0
		li $a3, 16711680
		jal desenho
		
		
		#linha 2
		addi $a0,$t0,0
		addi $a1, $t1,1
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,1
		addi $a1, $t1,1
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,1
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,1
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,4
		addi $a1, $t1,1
		li $a3, 167116800
		jal desenho
		
		#linha 3
		addi $a0,$t0,0
		addi $a1, $t1,2
		li $a3, 0
		jal desenho
		
		addi $a0,$t0,1
		addi $a1, $t1,2
		li $a3, 16777215
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,2
		li $a3, 0
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,2
		li $a3, 16777215
		jal desenho
		
		addi $a0,$t0,4
		addi $a1, $t1,2
		li $a3, 0
		jal desenho
	
		#linha 4
		addi $a0,$t0,0
		addi $a1, $t1,3
		li $a3, 16777215
		jal desenho
		
		addi $a0,$t0,1
		addi $a1, $t1,3
		li $a3, 0
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,3
		li $a3, 16777215
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,3
		li $a3, 0
		jal desenho
		
		addi $a0,$t0,4
		addi $a1, $t1,3
		li $a3, 16777215
		jal desenho
		
		#linha 5
		addi $a0,$t0,0
		addi $a1, $t1,4
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,1
		addi $a1, $t1,4
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,4
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,4
		li $a3, 16711680
		jal desenho
		
		addi $a0,$t0,4
		addi $a1, $t1,4
		li $a3, 16711680
		jal desenho
		
		#Salvando vetor de colisao
		#Primeiro Valor é a poição x inicial + 5, os outros 5 são os y da altura no caso yi , yi + 1, ... ,yi + 4
		la $t3,  coordenadasColisaoPersonagem
		addi $a0, $t0, 5
		sw $a0 ,0($t3) # salvando x 
		
		#li $t1, 1
		addi $a0, $t1,0
		sw $a0 ,4($t3) #salvando y 1
		addi $a0, $t1,1
		sw $a0 ,8($t3) #salvando y 2
		addi $a0, $t1,2
		sw $a0 ,12($t3) #salvando y 3
		addi $a0, $t1,3
		sw $a0 ,16($t3) #salvando y 4
		addi $a0, $t1,4
		sw $a0 ,20($t3) #salvando y 5
		
		lw $t1, 0($sp)
		lw $ra, 4($sp)
		lw $t0, 8($sp)
		lw $t3, 12($sp)
		addi $sp , $sp, 16
		jr $ra				
	pular: # nao recebe nenhum parametro, apernas calcula baseado no vetor salvo em renderizar
		addi $sp , $sp , -24 #prepara pilha para função pular
		sw $t4, 20($sp)
		sw $t5, 16($sp)
		sw $t2, 12($sp)
		sw $t1, 8($sp)
		sw $ra , 4($sp)
		sw $t0, 0($sp)
		
		la $t0, coordenadasFinaisPersonagem #carrega o vetor com a coordenada do ultimo pixel
		lw $t1, 0($t0)
		lw $t2, 4($t0)
		li $t5,-5	# calula a altura do persoagem
		forPulo: beq $t5, -17 ,fimForPulo #define o tamanho do pulo
			#apaga o antigo
			la $t0, coordenadasFinaisPersonagem
			lw $t1, 0($t0)
			lw $t2, 4($t0)
			addi $a0, $t1,-5
			add $a1, $t2, $t5
			jal apagarRastroPersonagem
			#desenha o personagem um pouco acima
			la $t0, coordenadasFinaisPersonagem
			lw $t1, 0($t0)
			lw $t2, 4($t0)
			addi $a0, $t1, -5
			addi $t4, $t5, -1
			add $a1, $t2, $t4
			jal desenharPersonagem
			jal pause
			#movimentando inimigo
			la $t4, coordenadasFinaisInimigo
			lw $a0 , 0($t4)
			lw $a1, 4($t4)
			jal movimentarInimigo
			
			addi $t5 , $t5 , -1
		j forPulo
		fimForPulo:
		#renderia um novo personagem mais acima, para ele começar a calular a queda
		la $t0, coordenadasFinaisPersonagem
		lw $t1, 0($t0)
		lw $t2, 4($t0)
		addi $a0, $t1, -5
	        addi $t4, $t5, -1
		add $a1, $t2, $t4
		jal renderizarPersonagem
		#movimentando inimigo
		la $t4, coordenadasFinaisInimigo
		lw $a0 , 0($t4)
		lw $a1, 4($t4)
		jal movimentarInimigo

		lw $t0, 0($sp)
		lw $ra, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t5, 16($sp)
		lw $t4, 20($sp)
		addi $sp, $sp, 24
		jr $ra
#para simplificar a chamada para desenhar 1 pixel, inves de usar duas funções e 6 linhas, se usa 1 função e 3 ou 4 linhas durante a chamada
#onde $a0 = x, $a1 = y, $a3 = cor
desenho: 
	addi $sp, $sp, -4 #prepara pilha para desenho
	sw $ra, 0($sp)

		jal coordenadasParaEndereco
		addi $a0, $v0,0
		addi $a1, $a3,0
		jal desenharPixel
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	#usa como referencia o primeiro pixel mais acima na exquerda(funcionar parecido com desenhar, porem usa um laço)
	#onde a0 = x inicial a1 = y inicial
apagarRastroPersonagem: 
	addi $sp, $sp , -12 #prepara pilha para apagar rastro Personagem
		sw $t0, 8($sp)
		sw $ra, 4($sp)
		sw $t1, 0($sp)	
		
		addi $t0, $a0, 0
		addi $t1, $a1, 0
		li $t2, 0
		li $t4, 0
	apagar:			
		addi $a0,$t0,0
		addi $a1, $t1,0
		li $a3 , 18983107
		jal desenho
		addi $t2, $t2, 1
		addi $t0, $t0, 1
		blt $t2, 5, apagar
		li $t2, 0
		addi $t0, $t0, -5
		addi $t1, $t1, 1
		addi $t4, $t4, 1
		blt $t4, 5, apagar 
		
		lw $t1, 0($sp)
		lw $ra, 4($sp)
		lw $t0, 8($sp)
		addi $sp , $sp, 12
		jr $ra		
	#onde #a0 = x inicial , $a1, = y inicial
	renderizarInimigo1:
	addi $sp, $sp, -24 #prepara oilha para  renderizar Inimigo
	sw $t2, 20($sp)
	sw $t4, 16($sp)
	sw $t3, 12($sp)
	sw $ra, 8($sp)
	sw $t1, 4($sp) 
	sw $t0,0($sp)
	
		addi $t0, $a0,0 #salva os valores de a0 e a1
		addi $t1, $a1,0		
		jal desenharInimigo1 #desenhar o inimigo nas coordenadas desejadas (definido na chamada)
		#salvando coordenadas finais do inimigo
		la $t3, coordenadasFinaisInimigo
		addi $a0, $t0, 4
		addi $a1, $t1, 3 
		sw $a0, 0($t3)
		sw $a1, 4($t3)		
		
		#salvando coordenadas de colisao do inimigo 
		la $t3 ,coordenadasColisaoInimigo
		sw $t0, 0($t3)
		addi $t2, $t1, 0
		sw $t2 , 4($t3)
		addi $t2, $t1, 1
		sw $t2 , 8($t3)
		addi $t2, $t1, 2
		sw $t2 , 12($t3)
														
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t2, 20 ($sp)
	addi $sp, $sp, 24	
	jr $ra	
	#onde #$a0 = ultimo x , $a1 = ultimo Y
	movimentarInimigo:
		addi $sp, $sp, -20 #prepara oilha para  renderizarPersonagem
		sw $t4, 16($sp)
		sw $t3, 12($sp)
		sw $ra, 8($sp)
		sw $t1, 4($sp) 
		sw $t0,0($sp)
			
			addi $t0, $a0, -4 #calcul o x e y do peimeiro pixel mais acima na esquerda
			addi $t1, $a1, -3
			
			addi $a0, $t0 -1	#subtrai 1 de x, para movimentar
			addi $a1, $t1, 0
			
			
			jal renderizarInimigo1 #gera novo inimigo
			
			#apagando rastro(apaga os ultimos pixel de cada linha)
			addi $a0,$t0,3
			addi $a1, $t1,0
			li $a3 , 18983107
			jal desenho 
			
			addi $a0,$t0,3
			addi $a1, $t1,1
			li $a3 , 18983107
			jal desenho
			
			addi $a0,$t0,3
			addi $a1, $t1,2
			li $a3 , 18983107
			jal desenho
			jal calcularColisaoInimigoParede #testa colisao com parede
			jal verificarColisaoPersonagemInimigo  #testa colisao com personagem
		lw $t0,0($sp)
		lw $t1,4($sp)
		lw $ra, 8($sp)
		lw $t3, 12($sp)
		lw $t4, 16($sp)
		addi $sp, $sp, 20	
		jr $ra	
	#nao tem paramentro, apenas usa o valor salvo no vetor
	calcularColisaoInimigoParede:
		addi $sp, $sp, -20 #prepara oilha para  renderizarPersonagem
		sw $t4, 16($sp)
		sw $t3, 12($sp)
		sw $ra, 8($sp)
		sw $t1, 4($sp) 
		sw $t0,0($sp)
				la $t3, coordenadasFinaisInimigo #carrega vetor
				lw $t0, 0($t3)
				lw $t1 , 4 ($t3)
				addi $t0 , $t0 , -4  #calcula o x e y do pixel mais acima na esquerda
				addi $t1, $t1, -3
				
				slti $t2, $t0, 1
				beq $t2,  1,  inimigoColideComParede #verifica a posicao
				
				j inimigoNaoColideComParede
				inimigoColideComParede:
					addi $s1, $s1, 10
					jal gerarInimigoAleatorio # se verdadeira, gera um novo inimigo
					
					addi $a0, $t0,0
					addi $a1, $t1,0
					jal apagarInimigo1 #apaga o inimigo na ultima posicao conhecida
				inimigoNaoColideComParede:
		lw $t0,0($sp)
		lw $t1,4($sp)
		lw $ra, 8($sp)
		lw $t3, 12($sp)
		lw $t4, 16($sp)
		addi $sp, $sp, 20	
		jr $ra						
	#onde $a0 = x inicial, $a1 = y inicial
	desenharInimigo1:
		addi $sp, $sp , -16 #prepara pilha para desenhar inimigo
		sw $t3, 12($sp)
		sw $t0, 8($sp)
		sw $ra, 4($sp)
		sw $t1, 0($sp)
		
		addi $t0, $a0, 0
		addi $t1, $a1, 0
			
		#linha 1
		addi $a0,$t0,0
		addi $a1, $t1,0
		li $a3 , 18983107
		jal desenho 
		
		addi $a0,$t0,1
		addi $a1, $t1,0
		li $a3, 16777215
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,0
		li $a3, 18983107
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,0
		li $a3, 18983107
		jal desenho
		
		#linha 2
		addi $a0,$t0,0
		addi $a1, $t1,1
		li $a3 , 16777215
		jal desenho 
		
		addi $a0,$t0,1
		addi $a1, $t1,1
		li $a3, 25512780
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,1
		li $a3, 25512780
		jal desenho
		
		addi $a0,$t0,3
		addi $a1, $t1,1
		li $a3, 16777215
		jal desenho
		
		
		#linha 3
		addi $a0,$t0,0
		addi $a1, $t1,2
		li $a3 , 18983107
		jal desenho 
		
		addi $a0,$t0,1
		addi $a1, $t1,2
		li $a3, 16777215
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,2
		li $a3 , 18983107
		jal desenho 
		
		addi $a0,$t0,3
		addi $a1, $t1,2
		li $a3 , 18983107
		jal desenho 
		
		#salvando vetor de colisao inimigo onde o primeiro campo é x, e os outros 3 são y, onde yi , yi +1 , yi + 2
		la $t3 ,coordenadasColisaoInimigo
		sw $t0 ,  0($t3) #salvando x
		
		addi $a1 , $t1, 0
		sw $a1 ,  4($t3) #salvando y 1
		addi $a1 , $t1, 1
		sw $a1 ,  8($t3) #salvando y 2
		addi $a1 , $t1, 2
		sw $a1 ,  12($t3) #salvando y 3
		
		lw $t1, 0($sp)
		lw $ra, 4($sp)
		lw $t0, 8($sp)
		lw $t3, 12($sp)
		addi $sp, $sp , 16 	
		jr $ra
		#onde $a0 = x inicial, $a1 = y inicial
	apagarInimigo1:
		
		addi $sp, $sp , -12 #prepara pilha para desenhar inimigo
		sw $t0, 8($sp)
		sw $ra, 4($sp)
		sw $t1, 0($sp)
		
		addi $t0, $a0, 0
		addi $t1, $a1, 0
			
		#linha 1
		addi $a0,$t0,0
		addi $a1, $t1,0
		li $a3 , 18983107
		jal desenho 
		addi $a0,$t0,1
		addi $a1, $t1,0
		li $a3, 18983107
		jal desenho
		addi $a0,$t0,2
		addi $a1, $t1,0
		li $a3, 18983107
		jal desenho
		addi $a0,$t0,3
		addi $a1, $t1,0
		li $a3, 18983107
		jal desenho
		#linha 2
		addi $a0,$t0,0
		addi $a1, $t1,1
		li $a3 , 18983107
		jal desenho 
		addi $a0,$t0,1
		addi $a1, $t1,1
		li $a3, 18983107
		jal desenho
		addi $a0,$t0,2
		addi $a1, $t1,1
		li $a3, 18983107
		jal desenho
		addi $a0,$t0,3
		addi $a1, $t1,1
		li $a3, 18983107
		jal desenho
		#linha 3
		addi $a0,$t0,0
		addi $a1, $t1,2
		li $a3 , 18983107
		jal desenho 
		
		addi $a0,$t0,1
		addi $a1, $t1,2
		li $a3, 18983107
		jal desenho
		
		addi $a0,$t0,2
		addi $a1, $t1,2
		li $a3 , 18983107
		jal desenho 
		
		addi $a0,$t0,3
		addi $a1, $t1,2
		li $a3 , 18983107
		jal desenho 
		
		lw $t1, 0($sp)
		lw $ra, 4($sp)
		lw $t0, 8($sp)
		addi $sp, $sp , 12 
				
		jr $ra
	
	gerarInimigoAleatorio: 
		addi $sp, $sp, -12 #prepara pilha para gerar inimigo aleatorio
		sw $ra,8($sp)
		sw $t0, 4($sp)
		sw $t1, 0($sp)
			
		numeroAleatorio: li $v0, 41 #chamar syscall de pseudo random 
			li $a0, 10
			syscall
			li $v0, 42 # para tornar mais aleatorio, chama outro pseudo random, com limites usando o numero gerado anteriormente, 
			#como chave
			addi $a0, $a0, 0
			li $a1, 53
			syscall
			addi $t0, $a0, 0 
			slti $t1, $t0, 45
			beq $t1, 0, estaNoIntervalo #verifica se o numero esta no intervalo desejado (entre 45 e 53)
			j numeroAleatorio
			estaNoIntervalo: #cria um inimigo em um local aleatorio
				li $a0, 59
				addi $a1, $t0,0
				jal renderizarInimigo1
			
		lw $t1, 0($sp)
		lw $t0, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp , 12
		jr $ra
	pause: #sleep do sistema, sem ele as operações são quase instantaneas, causam travamento no mars, e mips(ocorrem diversos bugs)
		li $v0, 32
		add $a0, $s2,$zero
		syscall
		jr $ra
	verificarColisaoPersonagemInimigo:
		addi $sp, $sp , -12 #prepara pilha verificarColisaoPersonagemInimigo
		sw $ra, 8($sp)
		sw $t6, 4($sp)
		sw $t5, 0($sp)
		
		
		la $a0, coordenadasColisaoPersonagem 
		lw $t2,0($a0) #carrega o x da colisao
		la $a0, coordenadasColisaoInimigo
		lw $t3,0($a0) #carrega o y da colisao
		
		bne $t2, $t3, NaoColideComPersonagemFim # se forem diferentes nao colidem
		li $t0, 1
		forVerificarColisaoPI1:beq $t0, 6, fimForVerificarColisaoPI1 #percorre o vetorColisaoPersonagem (1 é o primeiro y , 5 é o ultimo, 6 sai do for)
			li $t1, 1
			forVerificarColisaoPI2:beq $t1, 4,fimForVerificarColisaoPI2 #percorre o vetor #percorre o vetorColisaoInimigo(1 é o primeir y, 3, o ultimo, 4 sai)
					la $t6, coordenadasColisaoPersonagem # pega vetor
					sll $t5, $t0, 2 #multiplica por 4
					add $t6, $t6, $t5 #soma ao endereço base
					lw $t2, 0($t6) #carrega
					
					la $t6, coordenadasColisaoInimigo #pega vetor
					sll $t5, $t1, 2 #multiplica por 4
					add $t6, $t6, $t5 # adiciona ao endereço base
					lw $t3, 0($t6) # carrega 
					beq $t2, $t3, ColisaoPIVerdadeira # verifica se os valores sao iguais
					
				addi $t1, $t1, 1	#aumenta o contador	
			j forVerificarColisaoPI2
			fimForVerificarColisaoPI2:	
			
			addi $t0, $t0, 1 #aumenta o contador
		j forVerificarColisaoPI1
		fimForVerificarColisaoPI1:
		j NaoColideComPersonagemFim #pula a colisao
		ColisaoPIVerdadeira:

			addi $s3, $s3, -1 #diminui uma vida
			jal apagarVidas # indo apagar uma vida da tela
			la $t3, coordenadasFinaisInimigo # cerrega ultimo endereço de inimigo
			lw $t0, 0($t3)
			lw $t1 , 4 ($t3)
			addi $a0, $t0,-4 #calcula o x inicial
			addi $a1, $t1,-3# calcula o y inicial 
			jal apagarInimigo1 # apaga o inimigo antigo
			jal gerarInimigoAleatorio #cria um novo inimigo
			beq $s3, 0, reiniciar
		NaoColideComPersonagemFim:		
		lw $t5, 0($sp)
		lw $t6, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra

reiniciar:
	#Mostra a pontuação 
	li $v0, 56
	la $a0, pontuacao
	li $a1, 0
	add $a1, $s1, 0
	syscall
	
	#Pegunta se quer jogar de novo.
	li $v0, 50
	la $a0, mensagem
	syscall
	beq $a0, 1, fim
	j comecarDeNovo
