local Sound = {}

Sound.dirpath = "sounds/"

Sound.muteModes = {
    all = "all",
    theme = "theme",
    off = "off"
}

function Sound:Init()
    self.mute = self.muteModes.off
    self.sounds = {
        theme = love.audio.newSource(self.dirpath .. "theme.wav", "stream"),
        removedLine = love.audio.newSource(self.dirpath .. "removeLine.wav", "stream"),
        rotate = love.audio.newSource(self.dirpath .. "rotate.wav", "stream"),
        drop = love.audio.newSource(self.dirpath .. "drop.wav", "stream"),
        levelUp = love.audio.newSource(self.dirpath .. "levelup.wav", "stream"),
        addBonus = love.audio.newSource(self.dirpath .. "bonus.wav", "stream"),
        menuChoice = love.audio.newSource(self.dirpath .. "menuChoice.wav", "stream"),
        menuSelect = love.audio.newSource(self.dirpath .. "menuSelect.wav", "stream"),
    }

    self.sounds.theme:setLooping(true)
    love.audio.play(self.sounds.theme)
end

function Sound:play(source)
    love.audio.play(source)
end

function Sound:menuChoice()
    Sound:play(self.sounds.menuChoice)
end

function Sound:menuSelect()
    Sound:play(self.sounds.menuSelect)
end

function Sound:removeLine()
    Sound:play(self.sounds.removedLine)
end

function Sound:rotate()
    Sound:play(self.sounds.rotate)
end

function Sound:drop()
    Sound:play(self.sounds.drop)
end

function Sound:levelUp()
    Sound:play(self.sounds.levelUp)
end

function Sound:addBonus()
    Sound:play(self.sounds.addBonus)
end

function Sound:nextState()
    if self.mute == self.muteModes.off then
        self.mute = self.muteModes.theme
        love.audio.stop(self.sounds.theme)
    elseif self.mute == self.muteModes.theme then
        self.mute = self.muteModes.all
        love.audio.setVolume(0)
    elseif self.mute == self.muteModes.all then
        self.mute = self.muteModes.off
        love.audio.play(self.sounds.theme)
        love.audio.setVolume(1)
    end
    return self.mute
end

return Sound
