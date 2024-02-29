require("somun.somun")
local widget = require("widget")

local playerId = 1
local playerName = ""
local password = ""
local gameId = 0
local number = 0
local isTurnOwner = false

local State = {
    DISCONNECTED = 0,
    CONNECTED = 1,
    LOGIN_SCREEN = 2,
    LOGGED_IN = 3,
    IN_GAME = 4
}

local state = State.DISCONNECTED
local group = display.newGroup()

-- function references
local setState

local function createButton(label, x, y, callback, isDisabled)
    local button = widget.newButton(
        {
            label = label,
            onEvent = callback,
            shape = "roundedRect",
            width = 200,
            height = 40,
            cornerRadius = 2,
            fillColor = {default = {1, 1, 1, 1}, over = {0.4, 0.4, 0.4, 1}},
            isEnabled = not (isDisabled == true)
        }
    )
    button.x = x
    button.y = y

    if isDisabled then
        button:setFillColor(1, 1, 1, 0.3)
    end

    group:insert(button)

    return button
end

local function handleConnectButtonEvent(event)
    if ("ended" == event.phase) then        
        Somun.start("localhost", 16666, function()
            print("connected")
            setState(State.CONNECTED)
        end,
        function()
            print("disconnected")
            setState(State.DISCONNECTED)
        end)
    end
end

local function handleCreateGuestAccountButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.account.createGuestAccount(function(_playerId, _playerName, _password)
            playerId = _playerId
            playerName = _playerName
            password = _password            
            print("guest account created: ", playerId, playerName, password)
            setState(State.LOGGED_IN)
        end,
        function()
            print("guest account creation failed")
        end)
    end
end

local function handleTestButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.rpc.test("hello world!", 1234)
        print("test button clicked")
    end
end

local function handleCreateRandomGameButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.play.createRandomGame(0, function(status)
            if status == 0 then
                print("random game creation failed")
            else
                print("registered to create random game")
            end
        end)
    end
end

local function handleEnterGameButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.play.enterGame(gameId, function(status, turnOwnerId)
            if status == 0 then
                print("game not found: ", gameId)                
            else
                print("game entered: ", gameId)
                isTurnOwner = (turnOwnerId == playerId)
                setState(State.IN_GAME)
            end            
        end)
    end
end

local function handleListGamesButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.play.listGames(function(games)
            if #games > 0 then
                gameId = games[1]
            end
        end)
    end
end

local function handleMakeMoveButtonEvent(event)
    if ("ended" == event.phase) then
        local moveData = "{'number': " .. number .. "}"
        Somun.play.makeMove(gameId, moveData, function(status)
            if status == 0 then
                print("move failed")
            else
                print("move succeeded")
            end
        end)
    end
end

local function handleExitGameButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.play.exitGame(gameId, function(status)
            if status == 0 then
                print("exit game failed")
            else
                print("exited game")
                setState(State.LOGGED_IN)
            end
        end)
    end
end

local function handleLoginScreenButtonEvent(event)
    if ("ended" == event.phase) then
        setState(State.LOGIN_SCREEN)
    end
end

local function handleLoginButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.auth.loginUsingIdPassword(playerId, password, function(status, _playerName)            
            if status == 0 then
                print("login failed")
                native.showAlert( "Error", "login failed")
            else
                playerName = _playerName
                print("logged in: ", playerName)
                setState(State.LOGGED_IN)
            end            
        end)
    end
end

local function handleDisconnectButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.stop()
        setState(State.DISCONNECTED)
    end
end

local function renderUI()

    if group ~= nil then
        group:removeSelf()
        group = display.newGroup()        
    end

    if state == State.DISCONNECTED then
        
        local connectButton = createButton("Connect", display.contentCenterX, display.contentCenterY, handleConnectButtonEvent)
    
        display.setDefault("background", 0.0, 0.0, 0.0)

    elseif state == State.CONNECTED then

        local createGuestAccountButton = createButton("Create Guest Account", display.contentCenterX, display.contentCenterY, handleCreateGuestAccountButtonEvent)
        local loginButton = createButton("Login", createGuestAccountButton.x, createGuestAccountButton.y + createGuestAccountButton.height + 10, handleLoginScreenButtonEvent)
        local disconnectButton = createButton("Disconnect", loginButton.x, loginButton.y + loginButton.height + 10, handleDisconnectButtonEvent)

        display.setDefault("background", 0.3, 0.3, 0.3)
        
    elseif state == State.LOGIN_SCREEN then

        local playerIdInput = native.newTextField( display.contentCenterX, display.contentCenterY, 180, 20 )
        playerIdInput.placeholder = "playerId"
        local passwordInput = native.newTextField( display.contentCenterX, playerIdInput.y + playerIdInput.height + 10, 180, 20 )
        passwordInput.placeholder = "password"

        group:insert(playerIdInput)
        group:insert(passwordInput)

        local loginButton = createButton("Login", passwordInput.x, passwordInput.y + passwordInput.height + 30, function(event)
            if ("ended" == event.phase) then
                playerId = tonumber(playerIdInput.text) or 0
                password = passwordInput.text or ""
                handleLoginButtonEvent(event)
            end
        end)
        local backButton = createButton("Cancel", loginButton.x, loginButton.y + loginButton.height + 10, function(event)
            if ("ended" == event.phase) then
                setState(State.CONNECTED)
            end
        end)

        display.setDefault("background", 0.3, 0.3, 0.3)

    elseif state == State.LOGGED_IN then

        local sendTestButton = createButton("Test", display.contentCenterX, display.contentCenterY, handleTestButtonEvent)
        local createRandomGameButton = createButton("Create Random Game", sendTestButton.x, sendTestButton.y + sendTestButton.height + 10, handleCreateRandomGameButtonEvent)
        local enterGameButton = createButton("Enter Game", createRandomGameButton.x, createRandomGameButton.y + createRandomGameButton.height + 10, handleEnterGameButtonEvent)
        local listGamesButton = createButton("List Games", enterGameButton.x, enterGameButton.y + enterGameButton.height + 10, handleListGamesButtonEvent)
        local disconnectButton = createButton("Disconnect", listGamesButton.x, listGamesButton.y + listGamesButton.height + 10, handleDisconnectButtonEvent)

        display.setDefault("background", 0.2, 0.2, 0.5)

    elseif state == State.IN_GAME then

        local numberInput = native.newTextField( display.contentCenterX, display.contentCenterY, 180, 20 )
        numberInput.placeholder = "number"

        group:insert(numberInput)

        local makeMoveButton = createButton("Make Move", display.contentCenterX, numberInput.y + numberInput.height + 30, function(event)
            if ("ended" == event.phase) then
                number = tonumber(numberInput.text) or 0
                handleMakeMoveButtonEvent(event)
            end
        end, not isTurnOwner)
        local exitGameButton = createButton("Exit Game", makeMoveButton.x, makeMoveButton.y + makeMoveButton.height + 10, handleExitGameButtonEvent)
        local disconnectButton = createButton("Disconnect", exitGameButton.x, exitGameButton.y + exitGameButton.height + 10, handleDisconnectButtonEvent)
        
        display.setDefault("background", 0.2, 0.5, 0.2)
    
    end

    local statusText = display.newText({
        text = "",
        x = display.contentCenterX,
        y = display.contentHeight,
        fontSize = 16,
        align = "center"
    })
    group:insert(statusText)

    if state == State.DISCONNECTED then
        statusText.text = "Disconnected"
    elseif state == State.CONNECTED then
        statusText.text = "Connected"
    elseif state == State.LOGIN_SCREEN then
        statusText.text = "Login Screen"
    elseif state == State.LOGGED_IN then
        statusText.text = "Logged In pid: " .. playerId .. " name: " .. playerName
    elseif state == State.IN_GAME then
        statusText.text = "In Game pid: " .. playerId .. " name: " .. playerName .. " gameId: " .. gameId
    end

end

setState = function(newState)
    state = newState
    renderUI()
end

setState(State.DISCONNECTED)

Somun.registerCallback("Play_gameCreated", function(gameId, playerIds, turnOwnerId, stateJson)
    print("game created: ", gameId, playerIds, turnOwnerId, stateJson)
end)

Somun.registerCallback("Play_gameStateUpdated", function(gameId, stateJson)
    print("game state updated: ", gameId, stateJson)
end)

Somun.registerCallback("Play_turnOwnerChanged", function(gameId, turnOwnerId)
    print("turn owner changed: ", gameId, turnOwnerId)
    isTurnOwner = (turnOwnerId == playerId)
    renderUI()
end)