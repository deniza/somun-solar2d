Somun = {
    rpc = {},
    auth = {},
    account = {},
    play = {},
    friends = {},
    groups = {},
    player = {},
    callbacks = {}
}

local network = require("somun.somun_network")

Somun.player = {
    id = 0,
    name = "",
    password = "",
    login = false
}

function Somun.start(host, port, onConnect, onDisconnect)    
    
    network.start(host, port, onConnect, onDisconnect)

end

function Somun.stop()
    
    network.stop()
    
end

local function callFunction(moduleName, funcName, params)
    
    network.callFunction(moduleName .. "_" .. funcName, params)
    
end

function Somun.triggerCallback(callback, params)

    local callback = Somun.callbacks[callback]

    if callback ~= nil then
        callback(unpack(params or {}))
        return true
    end
    
    return false

end

function Somun.registerCallback(callbackName, callbackFunction)
    
    Somun.callbacks[callbackName] = callbackFunction
    
end

function Somun.rpc.test(stringParam, intParam)
    
    local params = {
        {"string", stringParam},
        {"int", intParam}
    }
    
    callFunction("Rpc", "test", params)
    
end

function Somun.rpc.call(funcName, jsonData)
    
    local params = {
        {"string", funcName},
        {"string", jsonData}
    }
    
    callFunction("Rpc", "call", params)
    
end

function Somun.auth.loginUsingIdPassword(playerId, password, callback)
    
    Somun.callbacks["Auth_loginResponse"] = callback

    local params = {
        {"int", playerId},
        {"string", password}
    }
    
    callFunction("Auth", "loginUsingIdPassword", params)
    
end

function Somun.auth.loginFacebook(accessToken)
    
    local params = {
        {"string", accessToken}
    }
    
    callFunction("Auth", "loginUsingFacebook", params)

end

function Somun.account.createGuestAccount(callbackAccepted, callbackRejected)
    
    Somun.callbacks["Account_createGuestAccountAccepted"] = callbackAccepted
    Somun.callbacks["Account_createGuestAccountRejected"] = callbackRejected    

    callFunction("Account", "createGuestAccount", {})
    
end

function Somun.account.createAccount(username, password)
    
    local params = {
        {"string", username},
        {"string", password}
    }
    
    callFunction("Account", "createAccount", params)
        
end

function Somun.account.changeCredentials(username, password)
    
    local params = {
        {"string", username},
        {"string", password}
    }
    
    callFunction("Account", "changeCredentials", params)
    
end

function Somun.account.setNotificationToken(token, deviceType)
    
    local params = {
        {"string", token},
        {"int", deviceType}
    }
    
    callFunction("Account", "setNotificationToken", params)    

end

function Somun.play.enterGame(gameId, callback)
    
    Somun.callbacks["Play_enterGameResponse"] = callback

    local params = {
        {"int", gameId}
    }
    
    callFunction("Play", "enterGame", params)
    
end

function Somun.play.exitGame(gameId, callback)
    
    Somun.callbacks["Play_exitGameResponse"] = callback

    local params = {
        {"int", gameId}
    }
    
    callFunction("Play", "exitGame", params)
    
end

function Somun.play.resignGame(gameId, callback)
    
    Somun.callbacks["Play_resignGameResponse"] = callback

    local params = {
        {"int", gameId}
    }
    
    callFunction("Play", "resignGame", params)
    
end

function Somun.play.listGames(callback)
    
    Somun.callbacks["Play_listGamesResponse"] = callback
    
    callFunction("Play", "listGames", {})
    
end

function Somun.play.makeMove(gameId, moveDataJson, callback)
    
    Somun.callbacks["Play_makeMoveResponse"] = callback

    local params = {
        {"int", gameId},
        {"string", moveData}
    }
    
    callFunction("Play", "makeMove", params)
    
end

function Somun.play.createRandomGame(gameType, callback)
        
    Somun.callbacks["Play_createRandomGameResponse"] = callback

    local params = {
        {"int", gameType}
    }
    
    callFunction("Play", "createRandomGame", params)
    
end

function Somun.play.createInvitation(opponentId, gameType, startOnline, callback)
    
    Somun.callbacks["Play_createInvitationResponse"] = callback

    local params = {
        {"int", opponentId},
        {"int", gameType},
        {"int", startOnline}
    }
    
    callFunction("Play", "createInvitation", params)
    
end

function Somun.play.acceptInvitation(invitationId, callback)
    
    Somun.callbacks["Play_acceptInvitationResponse"] = callback

    local params = {
        {"int", invitationId}
    }
    
    callFunction("Play", "acceptInvitation", params)
    
end

function Somun.play.rejectInvitation(invitationId, callback)
    
    Somun.callbacks["Play_rejectInvitationResponse"] = callback

    local params = {
        {"int", invitationId}
    }
    
    callFunction("Play", "rejectInvitation", params)
    
end

function Somun.play.listInvitations(callback)
    
    Somun.callbacks["Play_invitationsList"] = callback
    
    callFunction("Play", "listInvitations", {})
    
end

function Somun.friends.requestFriends(callback)
    
    Somun.callbacks["Friends_friendList"] = callback
    
    callFunction("Friends", "requestFriends", {})
    
end

function Somun.friends.requestAddFriend(playerId, callback)
    
    Somun.callbacks["Friends_requestAddFriendResponse"] = callback

    local params = {
        {"int", playerId}
    }
    
    callFunction("Friends", "requestAddFriend", params)
    
end

function Somun.friends.requestRemoveFriend(playerId, callback)
    
    Somun.callbacks["Friends_requestRemoveFriendResponse"] = callback

    local params = {
        {"int", playerId}
    }
    
    callFunction("Friends", "requestRemoveFriend", params)
    
end

function Somun.friends.requestAcceptFriend(playerId, callback)
    
    Somun.callbacks["Friends_requestAcceptFriendResponse"] = callback

    local params = {
        {"int", playerId}
    }
    
    callFunction("Friends", "requestAcceptFriend", params)
    
end

function Somun.friends.requestRejectFriend(playerId, callback)
    
    Somun.callbacks["Friends_requestRejectFriendResponse"] = callback

    local params = {
        {"int", playerId}
    }
    
    callFunction("Friends", "requestRejectFriend", params)
    
end

function Somun.friends.requestPrivateMessagesList(callback)
    
    Somun.callbacks["Friends_messageList"] = callback
    
    callFunction("Friends", "requestPrivateMessagesList", {})
    
end

function Somun.friends.requestSendPrivateMessage(playerId, message, callback)
    
    Somun.callbacks["Friends_requestSendPrivateMessageResponse"] = callback

    local params = {
        {"int", playerId},
        {"string", message}
    }
    
    callFunction("Friends", "requestSendPrivateMessage", params)
    
end

function Somun.friends.requestDeletePrivateMessage(messageId, callback)
    
    Somun.callbacks["Friends_requestDeletePrivateMessageResponse"] = callback

    local params = {
        {"int", messageId}
    }
    
    callFunction("Friends", "requestDeletePrivateMessage", params)
    
end

function Somun.friends.requestReadPrivateMessage(messageId, callback)
    
    Somun.callbacks["Friends_privateMessageContent"] = callback

    local params = {
        {"int", messageId}
    }
    
    callFunction("Friends", "requestReadPrivateMessage", params)
    
end

function Somun.groups.createGroup(groupName, callback)
    
    Somun.callbacks["Groups_createGroupResponse"] = callback

    local params = {
        {"string", groupName}
    }
    
    callFunction("Groups", "createGroup", params)
    
end

function Somun.groups.joinGroup(groupId, callback)
    
    Somun.callbacks["Groups_joinGroupResponse"] = callback

    local params = {
        {"int", groupId}
    }
    
    callFunction("Groups", "joinGroup", params)
    
end

function Somun.groups.leaveGroup(groupId, callback)
    
    Somun.callbacks["Groups_leaveGroupResponse"] = callback

    local params = {
        {"int", groupId}
    }
    
    callFunction("Groups", "leaveGroup", params)
    
end

function Somun.groups.processJoinRequest(groupId, playerId, accepted, callback)
    
    Somun.callbacks["Groups_processJoinRequestResponse"] = callback

    local params = {
        {"int", groupId},
        {"int", playerId},
        {"int", accepted}
    }
    
    callFunction("Groups", "processJoinRequest", params)
    
end

function Somun.groups.inviteToJoinGroup(groupId, playerId, callback)
    
    Somun.callbacks["Groups_inviteToJoinGroupResponse"] = callback

    local params = {
        {"int", groupId},
        {"int", playerId}
    }
    
    callFunction("Groups", "inviteToJoinGroup", params)
    
end

function Somun.groups.kickFromGroup(groupId, playerId, callback)
    
    Somun.callbacks["Groups_kickFromGroup"] = callback

    local params = {
        {"int", groupId},
        {"int", playerId}
    }
    
    callFunction("Groups", "kickFromGroup", params)
    
end

function Somun.groups.processGroupInvitation(invitationId, accepted, callback)
    
    Somun.callbacks["Groups_processGroupInvitationResponse"] = callback

    local params = {
        {"int", invitationId},
        {"int", accepted}
    }
    
    callFunction("Groups", "processGroupInvitation", params)
    
end

function Somun.groups.setGroupType(groupId, groupType, callback)
    
    Somun.callbacks["Groups_setGroupType"] = callback

    local params = {
        {"int", groupId},
        {"int", groupType}
    }
    
    callFunction("Groups", "setGroupType", params)
    
end

function Somun.groups.requestGroupList(startId, count, callback) 
    
    Somun.callbacks["Groups_groupList"] = callback

    local params = {
        {"int", startId},
        {"int", count},
    }

    callFunction("Groups", "requestGroupList", params)
    
end

function Somun.groups.requestGroupInfo(groupId, callback)
    
    Somun.callbacks["Groups_groupInfo"] = callback

    local params = {
        {"int", groupId}
    }
    
    callFunction("Groups", "requestGroupInfo", params)
    
end

function Somun.groups.requestGroupMembers(groupId, callback)
    
    Somun.callbacks["Groups_groupMembers"] = callback

    local params = {
        {"int", groupId}
    }
    
    callFunction("Groups", "requestGroupMembers", params)
    
end

function Somun.groups.requestGroupJoinRequests(groupId, callback)
    
    Somun.callbacks["Groups_groupJoinRequests"] = callback

    local params = {
        {"int", groupId}
    }
    
    callFunction("Groups", "requestGroupJoinRequests", params)
    
end

function Somun.groups.changeGroupMemberRole(groupId, playerId, role, callback)
    
    Somun.callbacks["Groups_changeGroupMemberRole"] = callback

    local params = {
        {"int", groupId},
        {"int", playerId},
        {"int", role}
    }
    
    callFunction("Groups", "changeGroupMemberRole", params)
    
end

function Somun.groups.changeGroupDescription(groupId, description, callback)
    
    Somun.callbacks["Groups_changeGroupDescription"] = callback

    local params = {
        {"int", groupId},
        {"string", description}
    }
    
    callFunction("Groups", "changeGroupDescription", params)
    
end

function Somun.groups.sendGroupMessage(groupId, message, callback)
    
    Somun.callbacks["Groups_sendGroupMessage"] = callback

    local params = {
        {"int", groupId},
        {"string", message}
    }
    
    callFunction("Groups", "sendGroupMessage", params)
    
end

function Somun.groups.requestGroupMessages(groupId, startId, count, callback)
    
    Somun.callbacks["Groups_groupMessages"] = callback

    local params = {
        {"int", groupId},
        {"int", startId},
        {"int", count}
    }
    
    callFunction("Groups", "requestGroupMessages", params)
    
end

function Somun.groups.requestGroupMessagesPaginated(groupId, page, pageSize, callback)
    
    Somun.callbacks["Groups_groupMessagesPaginated"] = callback

    local params = {
        {"int", groupId},
        {"int", page},
        {"int", pageSize}
    }
    
    callFunction("Groups", "requestGroupMessagesPaginated", params)
    
end