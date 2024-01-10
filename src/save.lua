local Save = {}
local Gamestate = require "gameState"

local Game = require "game"
local Config = require "config"
local Font = require "font"

FILENAME = ".save"

Save.filename = FILENAME

function Save:serializeMatrix(matrix)
    local lines = {}

    for _, row in ipairs(matrix) do
        table.insert(lines, table.concat(row, ","))
    end

    return table.concat(lines, ";")
end

function Save:serializeTetrisData(Tetris)
    local lines = {
        "gameover=" .. tostring(Tetris.gameover),
        "board=" .. Save:serializeMatrix(Tetris.board),
        "stoneShape=" .. Save:serializeMatrix(Tetris.stone.shape),
        "stoneX=" .. tostring(Tetris.stone.x),
        "stoneY=" .. tostring(Tetris.stone.y),
        "nextStoneShape=" .. Save:serializeMatrix(Tetris.nextStone.shape),
        "nextStoneX=" .. tostring(Tetris.nextStone.x),
        "nextStoneY=" .. tostring(Tetris.nextStone.y),
        "score=" .. tostring(Tetris.score),
        "level=" .. tostring(Tetris.level),
        "speed=" .. tostring(Tetris.speed),
        "bonus=" .. tostring(Tetris.bonus),
        "removedLines=" .. tostring(Tetris.removedLines)
    }
    return table.concat(lines, "\n")
end

function Save:deserializeMatrix(matrixStr)
    local matrix = {}
    for rowStr in matrixStr:gmatch("[^;]+") do
        local row = {}
        for value in rowStr:gmatch("[^,]+") do
            table.insert(row, tonumber(value) or value)
        end
        table.insert(matrix, row)
    end
    return matrix
end

function Save:deserializeTetrisData(data)
    local Tetris = {}
    for line in data:gmatch("[^\r\n]+") do
        local key, value = line:match("([^=]+)=(.*)")
        if key and value then
            if key == "gameover" then
                Tetris.gameover = value == "true"
            elseif key == "board" or key == "stoneShape" or key == "nextStoneShape" then
                Tetris[key] = Save:deserializeMatrix(value)
            else
                Tetris[key] = tonumber(value) or value
            end
        end
    end
    return Tetris
end

function Save:messageBox(message)
    love.graphics.setFont(Font:getFont(10))
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(message, 0, Config.height / 2, Config.width, "center")
    love.graphics.setFont(Font:getFont(3))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press 'escape' to continue", 0, Config.height / 2 + Config.stoneSize, Config.width, "center")
end

function Save:saveFile()
    local serializedData = Save:serializeTetrisData(Game:Store())
    return love.filesystem.write(self.filename, serializedData)
end

function Save:loadFile()
    if Save:CheckIfSaveExist() then
        local content, size = love.filesystem.read(FILENAME)
        if content == nil then
            return false
        end
        local deserializedData = Save:deserializeTetrisData(content)
        Game:Restore(deserializedData)
        return true
    end
    return false
end

function Save:Init()
end

function Save:CheckIfSaveExist()
    local fileInfo = love.filesystem.getInfo(self.filename)
    if fileInfo and fileInfo.type == "file" then
        return true
    end
    return false
end

function Save:keypressed(key)
    if key == "escape" then
        Gamestate:setStateGame()
    end
end

function Save:Draw()
    local result = nil
    local message = ""
    if Gamestate:checkLoad() then
        result = Save:loadFile()
        if result == nil then
            message = "Cannot load the save"
        else
            message = "Loaded"
        end
    elseif Gamestate:checkSave() then
        result = Save:saveFile()
        if result then
            message = "Saved"
        else
            message = "Cannot save the game"
        end
    end
    if message ~= "" then
        Save:messageBox(message)
    end
end

return Save
