local love = require("love")
local classes = require("classes")
local utils = require("utils")
local gameConfig = require("gameConfig")
local cores = require("cores")

local quantidadeInimigos = 5
local tempoTurno = 3
local tempoAtualTurno = 0
local tempoAnimacaoTurno = 0.2
local tempoAtualAnimacao = 0
local acaoDisponivel = true
local turnoEmAnimacao = false

Jogador = nil
Inimigos = {}
local setaJogador = {}
local proximoTurnoDados = {}

-- FUNÇÕES DE INICIALIZAÇÃO
function InicializarJogador()
  local imagemJogador = love.graphics.newImage("assets/characters/jogador.png")
  local escalaJogador = 0.4
  local offsetX = (imagemJogador:getWidth() * escalaJogador) / 2
  local offsetY = (imagemJogador:getHeight() * escalaJogador) / 2
  local x, y = utils.GerarPosicaoAleatoria(offsetX, offsetY)
  Jogador = classes.Jogador.new(x,y)
  Jogador.imagem = imagemJogador
  Jogador.escala = escalaJogador
  Jogador.offsetX = offsetX
  Jogador.offsetY = offsetY
  Jogador.desenhoX = x
  Jogador.desenhoY = y
  Jogador.maxDeslocamento = gameConfig.jogadorMaxDeslocamento
end

function InicializarInimigos(quantidade)
  local imagemInimigo = love.graphics.newImage("assets/characters/inimigo.png")
  for i = 1, quantidade do
    local escalaInimigo = 0.6
    local offsetX = (imagemInimigo:getWidth() * escalaInimigo) / 2
    local offsetY = (imagemInimigo:getHeight() * escalaInimigo) / 2
    local x, y = utils.GerarPosicaoAleatoria(offsetX, offsetY)
    local inimigo = classes.Inimigo.new(x, y)
    inimigo.imagem = imagemInimigo
    inimigo.escala = escalaInimigo
    inimigo.offsetX = offsetX
    inimigo.offsetY = offsetY
    inimigo.desenhoX = x
    inimigo.desenhoY = y
    inimigo.maxDeslocamento = gameConfig.inimigoMaxDeslocamento
    table.insert(Inimigos, inimigo)
  end
end

function InicializarSeta()
  setaJogador.comprimento = Jogador.maxDeslocamento
  setaJogador.cor = cores.seta
  setaJogador.vertices = {Jogador.posX, Jogador.posY, Jogador.posX + Jogador.maxDeslocamento, Jogador.posY}
end

function InicializarProximoTurnoDados()
  proximoTurnoDados.jogadorX = Jogador.posX
  proximoTurnoDados.jogadorY = Jogador.posY
end

-- FUNÇÕES DE CÁLCULO
-- Função que recebe as coordenadas do mouse e calcula a posição de destino da seta, considerando seu comprimento
function CalcularDestinoSeta(xMouse, yMouse)
  local dx = xMouse - Jogador.posX
  local dy = yMouse - Jogador.posY
  local modulo = math.sqrt(dx * dx + dy * dy)
  local xDestino = dx / modulo * setaJogador.comprimento + Jogador.posX
  local yDestino = dy / modulo * setaJogador.comprimento + Jogador.posY
  return xDestino, yDestino
end

-- FUNÇÕES DE ATUALIZAÇÃO
-- Função que recebe as coordenadas do mouse e atualiza a seta (move a seta para a posição do mouse), considerando seu comprimento
function AtualizarSetaPos(xMouse, yMouse)
  local xDestino, yDestino = CalcularDestinoSeta(xMouse, yMouse)
	setaJogador.vertices = {Jogador.posX, Jogador.posY, xDestino, yDestino}
end

-- Função que recebe as coordenadas do mouse e marca a posição do jogador para o próximo turno de acordo com o maxDeslocamento do Jogador
function AtualizarJogadorPos(xMouse, yMouse)
  local x, y = CalcularDestinoSeta(xMouse, yMouse)
  proximoTurnoDados.jogadorX = x
  proximoTurnoDados.jogadorY = y
end

function AtualizarAnimacaoTurno(dt)
  tempoAtualAnimacao = tempoAtualAnimacao + dt
  local progresso = math.min(tempoAtualAnimacao / tempoAnimacaoTurno, 1)

  if Jogador.animacao then
    Jogador.desenhoX = utils.Interpolar(Jogador.animacao.inicioX, Jogador.animacao.destinoX, progresso)
    Jogador.desenhoY = utils.Interpolar(Jogador.animacao.inicioY, Jogador.animacao.destinoY, progresso)
  end

  for _, inimigo in ipairs(Inimigos) do
    if inimigo.animacao then
      inimigo.desenhoX = utils.Interpolar(inimigo.animacao.inicioX, inimigo.animacao.destinoX, progresso)
      inimigo.desenhoY = utils.Interpolar(inimigo.animacao.inicioY, inimigo.animacao.destinoY, progresso)
    end
  end

  if progresso >= 1 then
    Jogador.desenhoX = Jogador.posX
    Jogador.desenhoY = Jogador.posY
    Jogador.animacao = nil

    for _, inimigo in ipairs(Inimigos) do
      inimigo.desenhoX = inimigo.posX
      inimigo.desenhoY = inimigo.posY
      inimigo.animacao = nil
    end

    turnoEmAnimacao = false
    acaoDisponivel = true
    tempoAtualTurno = 0
    tempoAtualAnimacao = 0
  end
end

function PrepararAnimacaoEntidade(entidade, destinoX, destinoY)
  entidade.animacao = {
    inicioX = entidade.posX,
    inicioY = entidade.posY,
    destinoX = destinoX,
    destinoY = destinoY
  }
  entidade.posX = destinoX
  entidade.posY = destinoY
  entidade.desenhoX = entidade.animacao.inicioX
  entidade.desenhoY = entidade.animacao.inicioY
end

-- FUNÇÕES DE MOVIMENTAÇÃO
function MoverJogador()
  PrepararAnimacaoEntidade(Jogador, proximoTurnoDados.jogadorX, proximoTurnoDados.jogadorY)
end

function MoverInimigoPerseguir(inimigo)
  local dx = Jogador.posX - inimigo.posX
  local dy = Jogador.posY - inimigo.posY
  local modulo = math.sqrt(dx * dx + dy * dy)
  if modulo > 0 then
    local xDestino = dx / modulo * inimigo.maxDeslocamento + inimigo.posX
    local yDestino = dy / modulo * inimigo.maxDeslocamento + inimigo.posY
    PrepararAnimacaoEntidade(inimigo, xDestino, yDestino)
  end
end

function MoverInimigoAleatoriamente(inimigo)
  local angulo = math.random() * 2 * math.pi
  local xDestino = math.cos(angulo) * inimigo.maxDeslocamento + inimigo.posX
  local yDestino = math.sin(angulo) * inimigo.maxDeslocamento + inimigo.posY
  if utils.PosicaoValida(xDestino, yDestino) then
    PrepararAnimacaoEntidade(inimigo, xDestino, yDestino)
  end
end

function MoverInimigos()
  local perseguirJogador = false

  for _, inimigo in ipairs(Inimigos) do
    if perseguirJogador then
      MoverInimigoPerseguir(inimigo)
    else
      MoverInimigoAleatoriamente(inimigo)
    end
  end
end

-- FUNÇÕES PARA LIDAR COM O PROXIMO TURNO
function ProximoTurno()
  MoverJogador()
  
  MoverInimigos()

  turnoEmAnimacao = true
  tempoAtualAnimacao = 0
  acaoDisponivel = false
end

-- FUNÇÕES DO LOVE
function love.load()
  math.randomseed(os.time() + math.floor(love.timer.getTime() * 1000))
  InicializarJogador()
  InicializarSeta()
  InicializarProximoTurnoDados()
  InicializarInimigos(quantidadeInimigos)
end

function love.update(dt)
  -- Atualizando a posição da seta para seguir o mouse
  local xMouse, yMouse = love.mouse.getPosition()
  AtualizarSetaPos(xMouse, yMouse)

  if turnoEmAnimacao then
    AtualizarAnimacaoTurno(dt)
  else
    -- Contando o tempo do turno e passando para o próximo turno quando o tempo acabar
    tempoAtualTurno = tempoAtualTurno + dt

    if tempoAtualTurno >= tempoTurno then
      ProximoTurno()
    end
  end
end

function love.mousepressed(x, y, button, istouch, presses)
  local xMouse, yMouse = love.mouse.getPosition()
  
  -- Botão esquerdo
	if button == 1 then
    -- Marca a posição do jogador para o próximo turno
    if acaoDisponivel then
      AtualizarJogadorPos(xMouse, yMouse)
      acaoDisponivel = false
    end
	end

  -- Botão direito
  if button == 2 then
    -- Dispara um projetil para o próximo turno
    if acaoDisponivel then
      
    end
  end
end

function love.draw()
  local larguraTela = love.graphics.getWidth()
  local tempoRestante = math.max(0, tempoTurno - tempoAtualTurno)

	-- Resetando configs do draw
	love.graphics.clear(0.25, 0.25, 0.5)
  love.graphics.setColor(cores.branco)
  love.graphics.setFont(gameConfig.fonteStatus)

  -- Desenhando texto de tempo do turno
  love.graphics.printf("Proximo Turno em: " .. string.format("%.1f", tempoRestante) .. "s", 0, 10, larguraTela - 10, "right")
  
  -- Desenhando o jogador
  love.graphics.draw(Jogador.imagem, Jogador.desenhoX - Jogador.offsetX, Jogador.desenhoY - Jogador.offsetY, 0, Jogador.escala, Jogador.escala)

  -- Desenhando todos os inimigos
	for _, inimigo in ipairs(Inimigos) do
    love.graphics.draw(inimigo.imagem, inimigo.desenhoX - inimigo.offsetX, inimigo.desenhoY - inimigo.offsetY, 0, inimigo.escala, inimigo.escala)
	end

  -- Se o jogador ainda não realizou uma ação no turno
	if acaoDisponivel then
    -- Desenhando a seta do jogador
    love.graphics.setColor(setaJogador.cor)
    love.graphics.line(setaJogador.vertices)

    -- Desenhando o texto de ação disponível
    love.graphics.setFont(gameConfig.fonteStatus)
    love.graphics.setColor(cores.branco)
    love.graphics.printf("Realize uma ação!", 0, 50, larguraTela - 10, "right")

  -- Se o jogador já realizou uma ação
  else
    if turnoEmAnimacao then
      -- 
    else
      -- Desenhando uma marcação para o destino do jogador do próximo turno
      love.graphics.setColor(cores.vermelho)
      love.graphics.circle("fill", proximoTurnoDados.jogadorX, proximoTurnoDados.jogadorY, 10)
    end
  end
end