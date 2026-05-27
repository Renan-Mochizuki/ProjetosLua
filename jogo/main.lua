local love = require("love")
local classes = require("classes")
local utils = require("utils")
local gameConfig = require("gameConfig")
local cores = require("cores")
local tempoTurno = 3
local tempoAtualTurno = 0
local proximoTurnoDados = {}
local acaoDisponivel = true

Jogador = nil
Inimigos = {}
local setaJogador = {}

function InicializarJogador()
  local imagemJogador = love.graphics.newImage("assets/characters/jogador.png")
  local escalaJogador = 0.5
  local offsetX = (imagemJogador:getWidth() * escalaJogador) / 2
  local offsetY = (imagemJogador:getHeight() * escalaJogador) / 2
  local x, y = utils.GerarPosicaoAleatoria(offsetX, offsetY)
  Jogador = classes.Jogador.new(x,y)
  Jogador.imagem = imagemJogador
  Jogador.escala = escalaJogador
  Jogador.offsetX = offsetX
  Jogador.offsetY = offsetY
  Jogador.maxDeslocamento = gameConfig.jogadorMaxDeslocamento
end

function InicializarInimigos(quantidade)
  local imagemInimigo = love.graphics.newImage("assets/characters/inimigo.png")
  for i = 1, quantidade do
    local escalaInimigo = 0.3
    local offsetX = (imagemInimigo:getWidth() * escalaInimigo) / 2
    local offsetY = (imagemInimigo:getHeight() * escalaInimigo) / 2
    local x, y = utils.GerarPosicaoAleatoria(offsetX, offsetY)
    local inimigo = classes.Inimigo.new(x, y)
    inimigo.imagem = imagemInimigo
    inimigo.escala = escalaInimigo
    inimigo.offsetX = offsetX
    inimigo.offsetY = offsetY
    inimigo.maxDeslocamento = gameConfig.inimigoMaxDeslocamento
    table.insert(Inimigos, inimigo)
  end
end

function InicializarSeta()
  setaJogador.comprimento = Jogador.maxDeslocamento
  setaJogador.cor = cores.amarelo
  setaJogador.vertices = {Jogador.posX, Jogador.posY, Jogador.posX + Jogador.maxDeslocamento, Jogador.posY}
end

function InicializarProximoTurnoDados()
  proximoTurnoDados.jogadorX = Jogador.posX
  proximoTurnoDados.jogadorY = Jogador.posY
end

function CalcularDestinoSeta(xMouse, yMouse)
  local dx = xMouse - Jogador.posX
  local dy = yMouse - Jogador.posY
  local modulo = math.sqrt(dx * dx + dy * dy)
  local xDestino = dx / modulo * setaJogador.comprimento + Jogador.posX
  local yDestino = dy / modulo * setaJogador.comprimento + Jogador.posY
  return xDestino, yDestino
end

function AtualizarSetaPos(xMouse, yMouse)
  local xDestino, yDestino = CalcularDestinoSeta(xMouse, yMouse)
	setaJogador.vertices = {Jogador.posX, Jogador.posY, xDestino, yDestino}
end

function AtualizarJogadorPos(xMouse, yMouse)
  local x, y = CalcularDestinoSeta(xMouse, yMouse)
  proximoTurnoDados.jogadorX = x
  proximoTurnoDados.jogadorY = y
end

function love.load()
  math.randomseed(os.time() + math.floor(love.timer.getTime() * 1000))
  InicializarJogador()
  InicializarSeta()
  InicializarProximoTurnoDados()
  InicializarInimigos(5)
end

function ProximoTurno()
  Jogador.posX = proximoTurnoDados.jogadorX
  Jogador.posY = proximoTurnoDados.jogadorY
  acaoDisponivel = true
  local perseguirJogador = false

  for i = 1, #Inimigos do
    local inimigo = Inimigos[i]
    if perseguirJogador then
      local dx = Jogador.posX - inimigo.posX
      local dy = Jogador.posY - inimigo.posY
      local modulo = math.sqrt(dx * dx + dy * dy)
      if modulo > 0 then
        local xDestino = dx / modulo * inimigo.maxDeslocamento + inimigo.posX
        local yDestino = dy / modulo * inimigo.maxDeslocamento + inimigo.posY
        inimigo.posX = xDestino
        inimigo.posY = yDestino
      end
    else
      local angulo = math.random() * 2 * math.pi
      local xDestino = math.cos(angulo) * inimigo.maxDeslocamento + inimigo.posX
      local yDestino = math.sin(angulo) * inimigo.maxDeslocamento + inimigo.posY
      if utils.PosicaoValida(xDestino, yDestino) then
        inimigo.posX = xDestino
        inimigo.posY = yDestino
      end
    end
  end
end

function love.update(dt)
  tempoAtualTurno = tempoAtualTurno + dt

  if tempoAtualTurno >= tempoTurno then
    tempoAtualTurno = 0

    ProximoTurno()
  end
  local xMouse, yMouse = love.mouse.getPosition()
  AtualizarSetaPos(xMouse, yMouse)
end

function love.mousepressed(x, y, button, istouch, presses)
  local xMouse, yMouse = love.mouse.getPosition()
	if button == 1 then
    if acaoDisponivel then
      AtualizarJogadorPos(xMouse, yMouse)
      acaoDisponivel = false
    end
	end
  if button == 2 then
    if acaoDisponivel then
      
    end
  end
end

function love.draw()
  local larguraTela = love.graphics.getWidth()

	-- limpando a tela com um azul acinzentado
	love.graphics.clear(0.25, 0.25, 0.5)
  love.graphics.setColor(cores.branco)


  love.graphics.printf("Proximo Turno em: " .. string.format("%.1f", tempoTurno - tempoAtualTurno) .. "s", 0, 10, larguraTela - 10, "right")
  
  -- desenhando o jogador na posição
  love.graphics.draw(Jogador.imagem, Jogador.posX - Jogador.offsetX, Jogador.posY - Jogador.offsetY, 0, Jogador.escala, Jogador.escala)

	for _, inimigo in ipairs(Inimigos) do
	  love.graphics.draw(inimigo.imagem, inimigo.posX - inimigo.offsetX, inimigo.posY - inimigo.offsetY, 0, inimigo.escala, inimigo.escala)
	end
	if acaoDisponivel then
    love.graphics.setColor(setaJogador.cor)
    love.graphics.line(setaJogador.vertices)
    love.graphics.setFont(gameConfig.fonteStatus)
    love.graphics.setColor(cores.branco)
    love.graphics.printf("Realize uma ação!", 0, 50, larguraTela - 10, "right")
  else
    love.graphics.setFont(gameConfig.fonteStatus)
    love.graphics.setColor(cores.vermelho)
    love.graphics.circle("fill", proximoTurnoDados.jogadorX, proximoTurnoDados.jogadorY, 10)
  end


end