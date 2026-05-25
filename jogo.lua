local comprimento = 20
local largura = 10
local charJogador = "P"
local charInimigo = "O"

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

function ImprimirMapa()
  local xJogador, yJogador = Jogador:posicao()

  io.write("\n")
  for y = 1, map.height do
    for x = 1, map.width do
      -- Se a posição atual for a do jogador, imprime o caractere do jogador
      if x == xJogador and y == yJogador then
        io.write(charJogador)
      else
        -- Percorra todos os inimigos para verificar se algum deles está na posição atual
        local inimigoPresente = false
        for _, inimigo in ipairs(Inimigos) do
          local xInimigo, yInimigo = inimigo:posicao()
          if x == xInimigo and y == yInimigo then
            io.write(charInimigo)
            inimigoPresente = true
            break
          end
        end
        if not inimigoPresente then
          io.write(map.tiles[y][x])
        end
      end
    end
    io.write("\n")
  end
  io.write("\n")
end

function InicializarJogador()
  local x, y = GerarPosicaoAleatoria()
  local jogador = ClassJogador.new(x,y)
  -- AtualizarPosNoMapa(jogador, jogador.posX, jogador.posY)
  return jogador
end

function InicializarInimigos(quantidade)
  local inimigos = {}
  for i = 1, quantidade do
  local x, y = GerarPosicaoAleatoria()
    local inimigo = ClassInimigo.new(x, y)
    -- AtualizarPosNoMapa(inimigo, inimigo.posX, inimigo.posY)
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
-- Função para atualizar a posição de uma entidade no mapa
-- Chamar essa função antes de atualizar o objeto da entidade, se não perdemos as posições do self
-- function AtualizarPosNoMapa(self, novaPosX, novaPosY)
--   map.tiles[self.posY][self.posX] = "."
--   if self.tipo == "jogador" then
--     map.tiles[novaPosY][novaPosX] = charJogador
--   elseif self.tipo == "inimigo" then
--     map.tiles[novaPosY][novaPosX] = charInimigo
--   end
-- end


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
    -- AtualizarPosNoMapa(self, novaPosX, novaPosY)
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
  
  if comando == "w" then
    Jogador:mover(0, -1)
  elseif comando == "s" then
    Jogador:mover(0, 1)
  elseif comando == "a" then
    Jogador:mover(-1, 0)
  elseif comando == "d" then
    Jogador:mover(1, 0)
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
  end
end

Main()