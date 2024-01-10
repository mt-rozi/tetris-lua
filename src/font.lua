local Config = require "config"
local Font = {}

function Font:getFont(size)
    return love.graphics.newFont(Config.stoneSize * ((size + 1) / 10))
end

return Font
