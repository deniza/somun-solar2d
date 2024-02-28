require("somun.somun")
local widget = require("widget")

local playerId = 1
local playerName = "guest"
local password = "xnof7rwap3ez256k"

local function createButton(label, x, y, callback)
    local button = widget.newButton(
        {
            label = label,
            onEvent = callback,
            shape = "roundedRect",
            width = 200,
            height = 40,
            cornerRadius = 2,
            fillColor = {default = {1, 1, 1, 1}, over = {1, 1, 1, 0.1}},
        }
    )
    button.x = x
    button.y = y
    return button
end

local function handleConnectButtonEvent(event)
    if ("ended" == event.phase) then        
        Somun.start("localhost", 16666)
    end
end

local function handleCreateGuestAccountButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.account.createGuestAccount(function(params)            
            playerId = params[1]
            playerName = params[2]
            password = params[3]
            print("guest account created: ", playerId, playerName, password)
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

local function handleLoginButtonEvent(event)
    if ("ended" == event.phase) then
        Somun.auth.loginUsingIdPassword(playerId, password, function(params)
            print("login status: ", params[1])
        end)
    end
end

local connectButton = createButton("Connect", display.contentCenterX, display.contentCenterY, handleConnectButtonEvent)
local createGuestAccountButton = createButton("Create Guest Account", connectButton.x, connectButton.y + connectButton.height + 10, handleCreateGuestAccountButtonEvent)
local loginButton = createButton("Login", createGuestAccountButton.x, createGuestAccountButton.y + connectButton.height + 10, handleLoginButtonEvent)
local sendTestButton = createButton("Test", loginButton.x, loginButton.y + loginButton.height + 10, handleTestButtonEvent)