-- CLASSES
-- Declarando classe abstrata, que possui uma posição
Entidade = {}
Entidade.__index = Entidade
-- Atibutos
Entidade.posX = 0
Entidade.posY = 0
Entidade.tipo = nil
-- Método para retornar a posição da entidade
function Entidade:getPosicao()
  return self.posX, self.posY
end
-- Método para mover a entidade usando deslocamento como argumento
function Entidade:mover(dx, dy)
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
Jogador = setmetatable({}, Entidade)
Jogador.__index = Jogador
-- Construtor
function Jogador.new(posX, posY)
  local instance = setmetatable({}, Jogador)
  instance.posX = posX
  instance.posY = posY
  instance.tipo = "jogador"
  return instance
end
-- Método para o jogador disparar um projetil, recebe a direção do projetil (dx, dy no intervalo [0,1])
function Jogador:DispararProjetil(dx, dy)
  if CooldownProjetil > 0 then
    return false
  end

  local projetil = ClassProjetil.new(self.posX, self.posY, dx, dy)
  table.insert(Projeteis, projetil)
  CooldownProjetil = tempoCooldownProjetil + 1
  return true
end

-- Declarando classe Inimigo que herda de Entidade
Inimigo = setmetatable({}, Entidade)
Inimigo.__index = Inimigo
-- Construtor
function Inimigo.new(posX, posY)
  local instance = setmetatable({}, Inimigo)
  instance.posX = posX
  instance.posY = posY
  instance.tipo = "inimigo"
  return instance
end

-- Declarando classe Projetil que herda de Entidade
Projetil = setmetatable({}, Entidade)
Projetil.__index = Projetil
Projetil.dx = 0
Projetil.dy = 0
-- Construtor
function Projetil.new(posX, posY, dx, dy)
  local instance = setmetatable({}, Projetil)
  instance.posX = posX
  instance.posY = posY
  instance.dx = dx
  instance.dy = dy
  instance.tipo = "projetil"
  return instance
end

return {
  Entidade = Entidade,
  Jogador = Jogador,
  Inimigo = Inimigo,
  Projetil = Projetil
}