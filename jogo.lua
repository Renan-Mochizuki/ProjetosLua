local comprimento = 20
local largura = 10
local charJogador = "P"
local charInimigo = "O"

-- Não usaremos o map para gerenciar nada, apenas para imprimir o estado atual do jogo
local map = {
  height = largura,
  width = comprimento,
  tiles = {}
}

-- FUNÇÕES PADRÕES/INICIALIZAÇÕES
function CriarMapa()
  for y = 1, map.height do
    map.tiles[y] = {}
    for x = 1, map.width do 
      map.tiles[y][x] = "."
    end
  end
end

function LimparMapa()
  for y = 1, map.height do
    for x = 1, map.width do
      map.tiles[y][x] = "."
    end
  end
end


-- Por ser mais fácil, para imprimir o mapa, primeiro limpamos ele, depois colocamos os objetos e entidades no mapa
function ImprimirMapa()
  LimparMapa()

  for key, inimigo in ipairs(Inimigos) do
    local xInimigo, yInimigo = inimigo:posicao()
    map.tiles[yInimigo][xInimigo] = charInimigo
  end

  local xJogador, yJogador = Jogador:posicao()
  map.tiles[yJogador][xJogador] = charJogador
  
  io.write("\n")
  for y = 1, map.height do
    for x = 1, map.width do
      io.write(map.tiles[y][x])
    end
    io.write("\n")
  end
  io.write("\n")
end

function InicializarJogador()
  local x, y = GerarPosicaoAleatoria()
  local jogador = ClassJogador.new(x,y)
  return jogador
end

function InicializarInimigos(quantidade)
  local inimigos = {}
  for i = 1, quantidade do
  local x, y = GerarPosicaoAleatoria()
    local inimigo = ClassInimigo.new(x, y)
    table.insert(inimigos, inimigo)
  end
  return inimigos
end

-- FUNÇÕES AUXILIARES/UTILS
-- Função auxiliar que verifica se a posição está dentro dos limites do mapa
function PosicaoValida(x, y)
  return x >= 1 and x <= map.width and y >= 1 and y <= map.height
end
-- Função auxiliar para gerar uma posição aleatória dentro do mapa
function GerarPosicaoAleatoria()
  local x = math.random(1, map.width)
  local y = math.random(1, map.height)
  return x, y
end

-- CLASSES
-- Declarando classe abstrata, que possui uma posição
ClassEntidade = {}
ClassEntidade.__index = ClassEntidade
-- Atibutos
ClassEntidade.posX = 0
ClassEntidade.posY = 0
ClassEntidade.tipo = nil
-- Método para retornar a posição da entidade
function ClassEntidade:posicao()
  return self.posX, self.posY
end
-- Método para mover a entidade usando deslocamento como argumento
function ClassEntidade:mover(dx, dy)
  local novaPosX = self.posX + dx
  local novaPosY = self.posY + dy

  if PosicaoValida(novaPosX, novaPosY) then
    self.posX = novaPosX
    self.posY = novaPosY
    return true
  end

  return false
end

-- Declarando classe Jogador que herda de Entidade
ClassJogador = setmetatable({}, ClassEntidade)
ClassJogador.__index = ClassJogador
-- Construtor
function ClassJogador.new(posX, posY)
    local instance = setmetatable({}, ClassJogador)
    instance.posX = posX
    instance.posY = posY
    instance.tipo = "jogador"
    return instance
end

-- Declarando classe Inimigo que herda de Entidade
ClassInimigo = setmetatable({}, ClassEntidade)
ClassInimigo.__index = ClassInimigo
-- Construtor
function ClassInimigo.new(posX, posY)
    local instance = setmetatable({}, ClassInimigo)
    instance.posX = posX
    instance.posY = posY
    instance.tipo = "inimigo"
    return instance
end

-- FUNÇÕES PRINCIPAIS
function LidarComandos(digitado)
  -- Pegando o último caractere do texto digitado (para caso seja digitado um "aa" sem querer, por exemplo)
  local comando = string.sub(digitado, #digitado, #digitado)
  
  -- Comando W
  if comando == "w" then
    Jogador:mover(0, -1)
  -- Comando A
  elseif comando == "a" then
    Jogador:mover(-1, 0)
  -- Comando S
  elseif comando == "s" then
    Jogador:mover(0, 1)
  -- Comando D
  elseif comando == "d" then
    Jogador:mover(1, 0)
  else
    -- Comando desconhecido
    return false 
  end

  return true
end

-- Função que lida com a lógica principal do jogo, como movimentação dos inimigos e verificação de colisões
function ProximoTurno()
  local xJogador, yJogador = Jogador:posicao()
  for key, inimigo in ipairs(Inimigos) do
    -- Movimentação aleatória do inimigo em alguma direção
    local dx = math.random(-1, 1)
    local dy = math.random(-1, 1)
    inimigo:mover(dx, dy)
    -- Pegando a posição por meio do método já realiza as validações necessárias
    local xInimigo, yInimigo = inimigo:posicao()
    if xInimigo == xJogador and yInimigo == yJogador then
      print("Você foi pego por um inimigo! Fim de jogo.")
      os.exit()
    end
  end
end

function Main()
  CriarMapa()

  Jogador = InicializarJogador()
  Inimigos = InicializarInimigos(5)

  while true do
    ImprimirMapa()
    local input = io.read()
    LidarComandos(input)
    ProximoTurno()
  end
end

Main()