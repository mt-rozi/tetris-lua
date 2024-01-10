local Game = {}
local Config = require "config"
local Gamestate = require "gameState"

local Tetris = require "tetris"
local Font = require "font"
local Sound = require "sound"

function Draw_Stone(x, y, size, color, border)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x * size, y * size, size, size)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x * size + border, y * size + border, size - 2 * border, size - 2 * border)
end

function Game:DrawMatrix(matrix, offset, stoneSize, color)
    local offX, offY = offset[1], offset[2]
    for y, row in ipairs(matrix) do
        for x, val in ipairs(row) do
            if val > 0 then
                local c = color
                if c == nil then
                    c = Tetris.const.colors[val]
                end
                Draw_Stone(offX + x - 1, offY + y - 1, stoneSize, c, 2)
            end
        end
    end
end

function Game:RemoveLineEffect()
    if self.lineRemovalAnimationTimer > 0 and self.lineRemoved ~= nil then
        local line = { {} }
        for i = 1, Tetris.rows do
            line[1][i] = 1
        end
        Game:DrawMatrix(line, { Tetris.minX, self.lineRemoved - 1 }, Config.stoneSize,
            { 255, 255, 255, 0.6 * self.lineRemovalAnimationTimer })
    else
        self.lineRemoved = nil
        self.lineRemovalAnimationTimer = self.lineRemovalAnimationSpeed
    end
end

function Game:DrawPanel()
    local size = Config.panelSize
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Font:getFont(size))
    love.graphics.printf("Score: " .. Tetris.score, Tetris.minX + size, Tetris.minY, Config.width, "left")
    love.graphics.printf("Lines: " .. Tetris.removedLines, Tetris.minX, Tetris.minY, Config.width - size, "right")
    Game:DrawMatrix(Tetris.nextStone.shape,
        { math.floor(Tetris.cols / 2 - #Tetris.nextStone.shape), Tetris.minY + size / 2 },
        Config.stoneSize *
        (size / 20))
end

function RemoveLineEffect(line)
    Sound:removeLine()
    Game.lineRemoved = line
end

function RotateEffect()
    Sound:rotate()
end

function DropEffect()
    Sound:drop()
end

function MoveEffect()
    Sound:move()
end

function LevelUpEffect()
    Sound:levelUp()
end

function AddBonusEffect()
    Sound:addBonus()
end

function Game:Init()
    self.dropTimer = 0
    self.controlsTimer = 0
    Tetris:Init(Config.rows, Config.cols)
    Tetris.RemoveLineCb = RemoveLineEffect
    Tetris.RotateCb = RotateEffect
    Tetris.DropCb = DropEffect
    Tetris.LevelUpCb = LevelUpEffect
    Tetris.AddBonusCb = AddBonusEffect

    self.lineRemovalAnimationSpeed = Tetris.speed / 2
    self.lineRemoved = nil
    self.lineRemovalAnimationTimer = self.lineRemovalAnimationSpeed
end

function Game:Right()
    Tetris:Move(1)
end

function Game:Left()
    Tetris:Move(-1)
end

function Game:Down()
    Tetris:Drop()
end

function Game:Rotate()
    Tetris:RotateStone()
end

function Game:Controls()
    if love.keyboard.isDown("left") then
        Game:Left()
    elseif love.keyboard.isDown("right") then
        Game:Right()
    elseif love.keyboard.isDown("down") then
        Game:Down()
    end
end

function Game:keypressed(key)
    if key == "escape" then
        if Tetris.gameover then
            Gamestate:gameover()
            Game:Init()
        else
            Gamestate:tooglePause()
        end
    elseif key == "up" then
        Game:Rotate()
    end
end

function Game:gameover()
    if Tetris.gameover then
        love.graphics.setFont(Font:getFont(10))
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf("Gameover", 0, Config.height / 2, Config.width, "center")
        love.graphics.setFont(Font:getFont(3))
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.printf("Press 'escape' to back to menu", 0, Config.height / 2 + Config.stoneSize, Config.width,
            "center")
    end
end

function Game:Draw()
    Game:DrawMatrix(Tetris.board, { Tetris.minX, Tetris.minY }, Config.stoneSize)
    Game:DrawMatrix(Tetris.stone.shape, { Tetris.stone.x, Tetris.stone.y }, Config.stoneSize)
    Game:RemoveLineEffect()
    Game:DrawPanel()
    Game:gameover()
end

function Game:Update(dt)
    self.dropTimer = self.dropTimer + dt
    self.controlsTimer = self.controlsTimer + dt

    if self.lineRemoved ~= nil then
        self.lineRemovalAnimationTimer = self.lineRemovalAnimationTimer - dt
    end

    if self.dropTimer >= Tetris.speed then
        Game:Down()
        self.dropTimer = 0
    end
    if self.controlsTimer >= Tetris.const.maxSpeed then
        Game:Controls()
        self.controlsTimer = 0
    end
end

function Game:Store()
    return {
        gameover = Tetris.gameover,
        board = Tetris.board,
        stone = Tetris.stone,
        nextStone = Tetris.nextStone,
        score = Tetris.score,
        level = Tetris.level,
        speed = Tetris.speed,
        bonus = Tetris.bonus,
        removedLines = Tetris.removedLines
    }
end

function Game:Restore(data)
    Game:Init()
    Tetris.gameover = data.gameover
    Tetris.board = data.board
    Tetris.stone.shape = data.stoneShape
    Tetris.stone.x = data.stoneX
    Tetris.stone.y = data.stoneY
    Tetris.nextStone.shape = data.nextStoneShape
    Tetris.nextStone.x = data.nextStoneX
    Tetris.nextStone.y = data.nextStoneY
    Tetris.score = data.score
    Tetris.level = data.level
    Tetris.speed = data.speed
    Tetris.bonus = data.bonus
    Tetris.removedLines = data.removedLines
end

return Game
