local Menu = {}
local Config = require "config"
local Gamestate = require "gameState"
local Save = require "save"
local Sound = require "sound"
local Font = require "font"

local MENU = {
    play = "Play",
    continue = "Continue",
    howToPlay = "How to play?",
    load = "Load",
    save = "Save",
    mute = "Mute: off",
    quit = "Quit"
}
Menu.currentMenu = {}
Menu.mainMenu = { MENU.play, MENU.howToPlay, MENU.load, MENU.mute, MENU.quit }
Menu.gameMenus = { MENU.continue, MENU.howToPlay, MENU.save, MENU.mute, MENU.quit }

function Menu:Init()
    self.selectedItem = 1
    self.currentMenu = self.mainMenu
    self.height = Config.height / 2 / #self.currentMenu 
end

function Menu:CheckMenu()
    self.currentMenu = self.mainMenu
    if Gamestate.pause and Gamestate:checkGame() then
        self.currentMenu = self.gameMenus
    end
end

function Menu:Draw()
    Menu:CheckMenu()
    for i = 1, #self.currentMenu do
        if i == self.selectedItem then
            love.graphics.setColor(1, 1, 0, 1)
        elseif not Save:CheckIfSaveExist() and self.currentMenu[i] == MENU.load then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        local startY = Config.height / 2 - (self.height * (#self.currentMenu) / 2)

        love.graphics.setFont(Font:getFont(10))
        love.graphics.printf(self.currentMenu[i], 0, startY + self.height * (i), Config.width, 'center')
    end
end

function Menu:skipLoadItem(name, skip)
    if self.currentMenu[self.selectedItem] == name and not Save:CheckIfSaveExist() then
        self.selectedItem = self.selectedItem + skip
    end
end

function Menu:keypressed(key)
    Menu:CheckMenu()
    if key == 'up' or key == 'down' then
        Sound:menuSelect()
    end
    if key == 'up' then
        self.selectedItem = self.selectedItem - 1
        Menu:skipLoadItem(MENU.load, -1)

        if self.selectedItem < 1 then
            self.selectedItem = #self.currentMenu
        end
    elseif key == 'down' then
        self.selectedItem = self.selectedItem + 1
        Menu:skipLoadItem(MENU.load, 1)

        if self.selectedItem > #self.currentMenu then
            self.selectedItem = 1
        end
    elseif key == 'return' then
        Sound:menuChoice()
        if self.currentMenu[self.selectedItem] == MENU.play then
            Gamestate:setStateGame()
        elseif self.currentMenu[self.selectedItem] == MENU.continue then
            Gamestate:tooglePause()
        elseif self.currentMenu[self.selectedItem] == MENU.howToPlay then
            Gamestate:setStateHowToPlay()
        elseif self.currentMenu[self.selectedItem] == MENU.load then
            Gamestate:setStateLoad()
        elseif self.currentMenu[self.selectedItem] == MENU.save then
            Gamestate:setStateSave()
        elseif self.currentMenu[self.selectedItem] == self.currentMenu[4] then
            local muteMode = Sound:nextState()
            self.currentMenu[self.selectedItem] = "Mute: " .. muteMode
        elseif self.currentMenu[self.selectedItem] == MENU.quit then
            love.event.quit()
        end
    elseif key=="escape" and Gamestate.pause then
        Gamestate:tooglePause()
    end
end

return Menu
