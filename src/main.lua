local Config = require "config"

local Gamestate = require "gameState"

local Menu = require "menu"
local Game = require "game"
local Save = require "save"
local Sound = require "sound"
local HowToPlay = require "howToPlay"

function love.load()
    local modes = love.window.getFullscreenModes()
    table.sort(modes, function(a, b) return a.width * a.height < b.width * b.height end)
    love.window.setTitle("Tetris")

    local mode = modes[#modes]

    Config:setWindowSize(mode.height * 0.9)

    love.window.setMode(Config.width, Config.height)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    Gamestate:Init()
    Save:Init()
    Sound:Init()
    Menu:Init()
    Game:Init()
end

function love.keypressed(key)
    if Gamestate:checkMenu() then
        Menu:keypressed(key)
    end
    if Gamestate:checkGame() then
        if Gamestate.pause then
            Menu:keypressed(key)
        else
            Game:keypressed(key)
        end
    end
    if Gamestate:checkSave() or Gamestate:checkLoad() then
        Save:keypressed(key)
    end
    if Gamestate:checkHowToPlay() then
        HowToPlay:keypressed(key)
    end
end

function love.update(dt)
    if Gamestate:checkGame() and not Gamestate.pause then
        Game:Update(dt)
    end
end

function love.draw()
    if Gamestate:checkMenu() then
        Menu:Draw()
    elseif Gamestate:checkGame() then
        Game:Draw()
        if Gamestate.pause then
            Menu:Draw()
        end
    elseif Gamestate:checkLoad() or Gamestate:checkSave() then
        Save:Draw()
    elseif Gamestate:checkHowToPlay() then
        HowToPlay:Draw()
    end
end
