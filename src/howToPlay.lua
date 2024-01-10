local HowToPlay = {}

local Config = require "config"
local Gamestate = require "gameState"
local Font = require "font"

function HowToPlay:keypressed(key)
    if key == "escape" then
        Gamestate:setPrevState()
    end
end

function HowToPlay:Draw()
    love.graphics.setFont(Font:getFont(10))
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(
        "How to play?",
        0, Config.height * 0.3, Config.width, "center")
    love.graphics.setFont(Font:getFont(3))
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(
        "Press 'up' to rotate block\nPress 'down' to speed up droping\nPress 'left' to move left\nPress 'right' to move right\nPress 'escape' to back",
        0, Config.height * 0.4, Config.width, "center")
end

return HowToPlay
