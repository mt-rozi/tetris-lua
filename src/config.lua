local Config = {}

Config = {
    width = 0,
    height = 0,
    panelSize = 5,
    stoneSize = 0,
    rows = 20,
    cols = 10
}

function Config:setWindowSize(size)
    self.width = size / 2
    self.height = size
    self.stoneSize = self.height / self.rows
end

return Config
