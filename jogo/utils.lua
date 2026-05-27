local gameConfig = require("gameConfig")

-- FUNÇÕES AUXILIARES/UTILS
-- Função auxiliar que verifica se a posição está dentro dos limites do mapa
function PosicaoValida(x, y)
  return x >= 1 and x <= gameConfig.width and y >= 1 and y <= gameConfig.height
end
-- Função auxiliar para gerar uma posição aleatória dentro do mapa
function GerarPosicaoAleatoria(offsetX, offsetY)
  local limiteMinX = math.max(1, math.floor(offsetX or 1))
  local limiteMinY = math.max(1, math.floor(offsetY or 1))
  local limiteMaxX = math.max(limiteMinX, math.floor(gameConfig.width - (offsetX or 0)))
  local limiteMaxY = math.max(limiteMinY, math.floor(gameConfig.height - (offsetY or 0)))

  local x = math.random(limiteMinX, limiteMaxX)
  local y = math.random(limiteMinY, limiteMaxY)
  return x, y
end

return {
  PosicaoValida = PosicaoValida,
  GerarPosicaoAleatoria = GerarPosicaoAleatoria
}