local comprimento = 20
local largura = 10
local charJogador = "P"
local charInimigo = "O"
local charProjetil = "*"
-- Quantos turnos o jogador precisa esperar para poder disparar outro projetil
local tempoCooldownProjetil = 2

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
    local xInimigo, yInimigo = inimigo:getPosicao()
    map.tiles[yInimigo][xInimigo] = charInimigo
  end

  for key, projetil in ipairs(Projeteis) do
    local xProjetil, yProjetil = projetil:getPosicao()
    map.tiles[yProjetil][xProjetil] = charProjetil
  end

  local xJogador, yJogador = Jogador:getPosicao()
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
function ClassEntidade:getPosicao()
  return self.posX, self.posY
end
-- Método para mover a entidade usando deslocamento como argumento
function ClassEntidade:mover(dx, dy)
  local novaPosX = self.posX + dx
  local novaPosY = self.posY + dy

  -- Verifica se a nova posição é válida, ou se a entidade for um projetil, ignore essa verificação 
  if PosicaoValida(novaPosX, novaPosY) or self.tipo == "projetil" then
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
-- Método para o jogador disparar um projetil, recebe a direção do projetil (dx, dy no intervalo [0,1])
function ClassJogador:DispararProjetil(dx, dy)
  if CooldownProjetil > 0 then
    return false
  end
  
  local projetil = ClassProjetil.new(self.posX, self.posY, dx, dy)
  table.insert(Projeteis, projetil)
  CooldownProjetil = tempoCooldownProjetil + 1
  return true
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

-- Declarando classe Projetil que herda de Entidade
ClassProjetil = setmetatable({}, ClassEntidade)
ClassProjetil.__index = ClassProjetil
ClassProjetil.dx = 0
ClassProjetil.dy = 0
-- Construtor
function ClassProjetil.new(posX, posY, dx, dy)
  local instance = setmetatable({}, ClassProjetil)
  instance.posX = posX
  instance.posY = posY
  instance.dx = dx
  instance.dy = dy
  instance.tipo = "projetil"
  return instance
end

-- FUNÇÕES PRINCIPAIS
function LidarComandos(digitado)
  -- Pegando o último caractere do texto digitado (para caso seja digitado um "aa" sem querer, por exemplo)
  local comando = string.sub(digitado, #digitado, #digitado)
  
  -- Mover
  if comando == "q" then
    Jogador:mover(-1, -1)
  elseif comando == "w" then
    Jogador:mover(0, -1)
  elseif comando == "e" then
    Jogador:mover(1, -1)
  elseif comando == "a" then
    Jogador:mover(-1, 0)
  elseif comando == "d" then
    Jogador:mover(1, 0)
  elseif comando == "z" then
    Jogador:mover(-1, 1)
  elseif comando == "x" or comando == "s" then
    Jogador:mover(0, 1)
  elseif comando == "c" then
    Jogador:mover(1, 1)
  -- Disparar projetil 
  elseif comando == "Q" then
    Jogador:DispararProjetil(-1, -1)
  elseif comando == "W" then
    Jogador:DispararProjetil(0, -1)
  elseif comando == "E" then
    Jogador:DispararProjetil(1, -1)
  elseif comando == "A" then
    Jogador:DispararProjetil(-1, 0)
  elseif comando == "D" then
    Jogador:DispararProjetil(1, 0)
  elseif comando == "Z" then
    Jogador:DispararProjetil(-1, 1)
  elseif comando == "X" or comando == "S" then
    Jogador:DispararProjetil(0, 1)
  elseif comando == "C" then
    Jogador:DispararProjetil(1, 1)
  -- Comando desconhecido
  else
    return false
  end

  return true
end

-- Função que lida com a lógica principal do jogo, como movimentação dos inimigos e verificação de colisões
function ProximoTurno()
  local xJogador, yJogador = Jogador:getPosicao()

  -- Mover todos os projeteis e suas consequências
  for key, projetil in ipairs(Projeteis) do
    projetil:mover(projetil.dx, projetil.dy)
    local xProjetil, yProjetil = projetil:getPosicao()

    -- Verificar se o projetil saiu do mapa
    if not PosicaoValida(xProjetil, yProjetil) then
      table.remove(Projeteis, key)
    else
      -- Verificar colisão com inimigos
      for i, inimigo in ipairs(Inimigos) do
        local xInimigo, yInimigo = inimigo:getPosicao()
        if xProjetil == xInimigo and yProjetil == yInimigo then
          print("Inimigo atingido!")
          table.remove(Inimigos, i)
          table.remove(Projeteis, key)
          break
        end
      end
    end
  end

  -- Mover todos inimigos e suas consequências
  for key, inimigo in ipairs(Inimigos) do
    -- Movimentação aleatória do inimigo em alguma direção
    local dx = math.random(-1, 1)
    local dy = math.random(-1, 1)
    inimigo:mover(dx, dy)
    -- Pegando a posição por meio do método já realiza as validações necessárias
    local xInimigo, yInimigo = inimigo:getPosicao()
    if xInimigo == xJogador and yInimigo == yJogador then
      print("Você foi pego por um inimigo! Fim de jogo.")
      os.exit()
    end
  end

  -- Verificando se não há mais inimigos
  if #Inimigos == 0 then
    print("Parabéns! Você derrotou todos os inimigos!")
    os.exit()
  end

  -- Atualizando tempo de cooldown
  if CooldownProjetil > 0 then
    CooldownProjetil = CooldownProjetil - 1
  end 
end

function Main()
  CriarMapa()

  local quantidadeInimigos;
  
  repeat
    io.write("Digite o numero de inimigos, ex: 5\n")
    quantidadeInimigos = tonumber(io.read())
  until quantidadeInimigos and quantidadeInimigos > 0

  Jogador = InicializarJogador()
  Inimigos = InicializarInimigos(quantidadeInimigos)
  Projeteis = {}
  CooldownProjetil = 0

  while true do 
    print("\n")
    if CooldownProjetil == 0 then
      print("Projetil pronto")
    else
      print("Projetil disponivel em " .. CooldownProjetil .. " turno(s)")
    end
    print("Insira um comando:")
    ImprimirMapa()
    repeat
      local input = io.read()
    until LidarComandos(input)
    ProximoTurno()
  end
end

Main()