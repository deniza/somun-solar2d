local function debug_print_function_call(funcName, params)
    
    local output = ""
    for _, value in pairs(params) do        
        output = output .. value .. ", "
    end

    print("["..funcName.."]", output)
    
end

local function triggerCallback(callback, params)

    local callback = Somun.callbacks[callback]

    if callback ~= nil then
        callback(params)
    end
    
end

function Somun.Auth_loginResponse(params)
    
    debug_print_function_call("Auth_loginResponse", params)

    triggerCallback("Auth_loginResponse", params)
    
end

function Somun.Auth_facebookLoginResponse(params)
    
    debug_print_function_call("Auth_facebookLoginResponse", params)

    triggerCallback("Auth_facebookLoginResponse", params)
    
end

function Somun.Account_createAccountAccepted(params)
    
    debug_print_function_call("Account_createAccountAccepted", params)

    Somun.player.id = params[1]
    Somun.player.name = params[2]
    Somun.player.password = params[3]

    triggerCallback("Account_createAccountAccepted", params)
    
end

function Somun.Account_createAccountRejected(params)
    
    debug_print_function_call("Account_createAccountRejected", params)

    triggerCallback("Account_createAccountRejected", params)
    
end

function Somun.Account_createGuestAccountAccepted(params)
    
    debug_print_function_call("Account_createGuestAccountAccepted", params)

    Somun.player.id = params[1]
    Somun.player.name = params[2]
    Somun.player.password = params[3]

    triggerCallback("Account_createGuestAccountAccepted", params)
    
end

function Somun.Account_createGuestAccountRejected(params)
    
    debug_print_function_call("Account_createGuestAccountRejected", params)

    triggerCallback("Account_createGuestAccountRejected", params)
    
end

function Somun.Account_changeCredentialsResponse(params)
    
    debug_print_function_call("Account_changeCredentialsResponse", params)

end