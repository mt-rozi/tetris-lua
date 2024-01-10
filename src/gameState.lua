local Gamestate = {
    states = {
        menu = "menu",
        game = "game",
        howToPlay = "howToPlay",
        save = "save",
        load = "load"
    }
}

function Gamestate:Init()
    self.state = self.states.menu
    self.prevState = self.states.menu
    self.pause = false
end

function Gamestate:setPrevState()
    local state = self.prevState
    self.state = self.prevState
    self.prevState = state
end

function Gamestate:tooglePause()
    self.pause = not self.pause
end

function Gamestate:check(state)
    return self.state == state
end

function Gamestate:checkMenu()
    return Gamestate:check(self.states.menu)
end

function Gamestate:checkGame()
    return Gamestate:check(self.states.game)
end

function Gamestate:checkHowToPlay()
    return Gamestate:check(self.states.howToPlay)
end

function Gamestate:checkLoad()
    return Gamestate:check(self.states.load)
end

function Gamestate:checkSave()
    return Gamestate:check(self.states.save)
end

function Gamestate:setState(state)
    self.prevState = self.state
    self.state = state
end

function Gamestate:setStateMenu()
    Gamestate:setState(self.states.menu)
end

function Gamestate:setStateGame()
    Gamestate:setState(self.states.game)
end

function Gamestate:setStateHowToPlay()
    Gamestate:setState(self.states.howToPlay)
end

function Gamestate:setStateLoad()
    Gamestate:setState(self.states.load)
end

function Gamestate:setStateSave()
    Gamestate:setState(self.states.save)
end

function Gamestate:gameover()
    self.prevState = self.states.menu
    self.state = self.states.menu
end

return Gamestate
