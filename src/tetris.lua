local Tetris = {}

Tetris.const = {}
Tetris.const.colors = {
    { 1, 0,   0, 1 }, -- 1 Red
    { 0, 1,   0, 1 }, -- 2 Green
    { 0, 0,   1, 1 }, -- 3 Blue
    { 1, 1,   0, 1 }, -- 4 Yellow
    { 1, 0,   1, 1 }, -- 5 Magenta
    { 0, 1,   1, 1 }, -- 6 Cyan
    { 1, 0.5, 0, 1 }, -- 7 Orange
}
Tetris.const.shapes = {
    {
        { 1, 1, 1 },
        { 0, 1, 0 }
    },
    {
        { 0, 2, 2 },
        { 2, 2, 0 }
    },
    {
        { 3, 3, 0 },
        { 0, 3, 3 }
    },
    {
        { 4, 0, 0 },
        { 4, 4, 4 }
    },
    {
        { 0, 0, 5 },
        { 5, 5, 5 }
    },
    {
        { 6, 6, 6, 6 }
    },
    {
        { 7, 7 },
        { 7, 7 }
    }
}

Tetris.const.speed = 1
Tetris.const.maxSpeed = 0.08
Tetris.const.linesToBonus = 50

function Tetris:RotateClockwise(shape)
    local newShape = {}
    for x = #shape[1], 1, -1 do
        local row = {}
        for y = 1, #shape do
            table.insert(row, shape[y][x])
        end
        table.insert(newShape, row)
    end
    return newShape
end

function Tetris:CheckCollision(shape, offset)
    local offX, offY = offset[1], offset[2]
    for cy, row in ipairs(shape) do
        for cx, cell in ipairs(row) do
            if cell ~= 0 then
                local x = offX + cx
                local y = offY + cy

                if x < self.minX or x > self.cols or y > self.rows or y < self.minY or self.board[y][x] ~= 0 then
                    return true
                end
            end
        end
    end
    return false
end

function Tetris:RemoveRow(row)
    Tetris:RemoveLineEffect(row)
    table.remove(self.board, row)
    local line = {}
    for i = 1, self.cols do
        line[i] = 0
    end
    table.insert(self.board, 1, line)
end

function Tetris:JoinShapeToBoard()
    local offX, offY = self.stone.x, self.stone.y
    for cy, row in ipairs(self.stone.shape) do
        for cx, val in ipairs(row) do
            self.board[cy + offY - 1][cx + offX] = self.board[cy + offY - 1][cx + offX] + val
        end
    end
end

function Tetris:NewBoard()
    local board = {}

    for y = 1, self.rows do
        board[y] = {}
        for x = 1, self.cols do
            board[y][x] = 0
        end
    end
    return board
end

function Table_Contains(table, value)
    for i = 1, #table do
        if (table[i] == value) then
            return true
        end
    end
    return false
end

function Tetris:NewStone()
    local randomIndex = math.random(1, #self.const.shapes)
    local stone = {}
    stone.shape = self.const.shapes[randomIndex]
    stone.x = math.floor(self.cols / 2 - #stone.shape[1] / 2)
    stone.y = self.minY

    if Tetris:CheckCollision(stone.shape, { stone.x, stone.y }) then
        self.gameover = true
    end
    return stone
end

function Tetris:Move(deltaX)
    if not self.gameover then
        local newX = self.stone.x + deltaX
        if newX < self.minX then
            newX = self.minX
        elseif newX > self.cols - #self.stone.shape[1] then
            newX = self.cols - #self.stone.shape[1]
        end
        if not Tetris:CheckCollision(self.stone.shape, { newX, self.stone.y }) then
            self.stone.x = newX
        end
    end
end

function Tetris:Score(removedLines, distance)
    if removedLines > 0 then
        self.removedLines = self.removedLines + removedLines
        if removedLines == 1 then
            self.score = self.score + 50
        elseif removedLines == 2 then
            self.score = self.score + 150
        elseif removedLines == 3 then
            self.score = self.score + 300
        else
            self.AddBonusCb()
            self.score = self.score + 600
        end
    end

    if self.removedLines > self.bonus and self.removedLines % self.const.linesToBonus == 0 then
        self.score = self.score + 2500
        self.bonus = self.removedLines
        self.AddBonusCb()
    end

    if distance >= self.rows - 1 then
        self.score = self.score + 5
    end

    self.score = self.score + 1
end

function Tetris:LevelUp()
    if self.removedLines > self.level and self.removedLines % (self.const.linesToBonus / 2) == 0 then
        self.speed = self.speed - 0.05
        self.speed = math.max(self.speed, self.const.maxSpeed)
        self.level = self.removedLines
        self.LevelUpCb()
    end
end

function Tetris:Drop()
    if not self.gameover then
        local removedLines = 0
        self.stone.y = self.stone.y + 1
        if Tetris:CheckCollision(self.stone.shape, { self.stone.x, self.stone.y }) then
            Tetris:JoinShapeToBoard()
            self.DropCb()
            self.stone = self.nextStone
            self.nextStone = Tetris:NewStone()
            while true do
                local removed = false
                for i, row in ipairs(self.board) do
                    if not Table_Contains(row, 0) then
                        Tetris:RemoveRow(i)
                        removedLines = removedLines + 1
                        removed = true
                        break
                    end
                end
                if not removed then
                    break
                end
            end
        end
        Tetris:Score(removedLines, self.stone.y)
        Tetris:LevelUp()
    end
end

function Tetris:RotateStone()
    if not self.gameover then
        local rotatedStone = Tetris:RotateClockwise(self.stone.shape)
        if not Tetris:CheckCollision(rotatedStone, { self.stone.x, self.stone.y }) then
            self.stone.shape = rotatedStone
            self.RotateCb()
        end
    end
end

function Tetris:RemoveLineEffect(line)
    if self.RemoveLineCb ~= nil then
        self.RemoveLineCb(line)
    end
end

function Tetris:Init(rows, cols)
    self.rows = rows
    self.cols = cols
    self.minX = 0
    self.minY = 0
    self.gameover = false
    self.board = Tetris:NewBoard()
    self.stone = Tetris:NewStone()
    self.nextStone = Tetris:NewStone()
    self.score = 0
    self.level = 0
    self.speed = self.const.speed
    self.bonus = 0
    self.removedLines = 0
    self.RemoveLineCb = nil
    self.RotateCb = nil
    self.DropCb = nil
    self.LevelUpCb = nil
    self.AddBonusCb = nil
end

return Tetris
