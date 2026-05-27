local width = 1024
local height = 768
local charJogador = "J"
local charInimigo = "O"
local charProjetil = "*"
local fonteStatus = love.graphics.newFont(18)
local jogadorMaxDeslocamento = 100
local inimigoMaxDeslocamento = 100

return {
  width = width,
  height = height,
  charJogador = charJogador,
  charInimigo = charInimigo,
  charProjetil = charProjetil,
  fonteStatus = fonteStatus,
  jogadorMaxDeslocamento = jogadorMaxDeslocamento,
  inimigoMaxDeslocamento = inimigoMaxDeslocamento
}