module(..., package.seeall)

require("somun.somun_incoming")
local socketlib = require("socket")
local packetlib = require("somun.somun_packetlib")
--local util = require("he2apps_util")

local socket = nil
local host, port
local packetPoolingDelay = 100
local targetPacketLen
local targetHeaderLen
local readBuffer
local incomingBytes = 0
local outgoingBytes = 0
local somunStopped = true
local packetPoolingTimer = nil
local onConnectCallback = nil
local onDisconnectCallback = nil

local function processPacket(packet)
  
  local funcName, parameters = packetlib.parse(packet)
  
  print(system.getTimer()*0.001,"incoming packet",funcName,incomingBytes,outgoingBytes)
  
  --if not RELEASE_BUILD then
  --  util.binaryDump(packet)  
  --end
  
  if Somun[funcName] ~= nil then
    Somun[funcName](parameters)
  else
    print("UNDEFINED FUNCTION CALLED FROM SOMUN SERVER: ", funcName)
  end
  
end

local function readDataFromSocket(maxDataLen)

    local data, emsg, partial = socket:receive(maxDataLen)

    if data then
        incomingBytes = incomingBytes + maxDataLen
        return data
    end
    
    if partial and #partial > 0 then
        incomingBytes = incomingBytes + #partial
        return partial
    end

    return nil, emsg
end

local function readPackets()

    local function handleSocketClosed()
        stop("somun.readPackets handleSocketClosed")    
        Runtime:dispatchEvent({name="sunisnetwork_connectionClosed"})
    end

    if targetPacketLen > 0 then
    
        local data,err = readDataFromSocket(targetPacketLen)
        
        if data ~= nil then
        
            readBuffer = readBuffer .. data
            targetPacketLen = targetPacketLen - #data
            
            if targetPacketLen == 0 then
                
                --enable this for more extensive debugging with a better stack trace
                --processPacket(readBuffer)

                local completed, errMessage = pcall( processPacket, readBuffer )
                if not completed then
                  print("EXCEPTION ERROR in processPacket(...): ", errMessage)
                  Runtime:dispatchEvent({name="sunisnetwork_packetProcessingException", msg=errMessage})
                end
                readBuffer = ""
            else
                return
            end
            
        else 
            
            if err ~= nil then
                if err == "closed" then
                    print("socket found closed while reading packet", err)
                    handleSocketClosed()
                end

                print("read packet error", err)

                return
            end
            
        end
    
    end
  
    --read packet header
    local header,err = readDataFromSocket(targetHeaderLen)
    if header ~= nil then
    
        readBuffer = readBuffer .. header
        targetHeaderLen = targetHeaderLen - #header
    
        if targetHeaderLen > 0 then    
            return
        else
            --full header read
            header = readBuffer
        end
    end
  
    if err ~= nil then
        if err == "closed" then
            handleSocketClosed()
        end
        return
    end
  
    targetPacketLen = packetlib.bytes4ToNumber(header)
    
    targetHeaderLen = 4
    readBuffer = ""
    
    readPackets()
  
end

 
function start( _host, _port, _onConnect, _onDisconnect)

  if somunStopped == false then
    print("Somun.start() : somun already started! do not start it twice!!")
    return
  end

  print("Somun.start() -> ", _host, _port)

  host = _host
  port = _port
  onConnectCallback = _onConnect
  onDisconnectCallback = _onDisconnect

  targetPacketLen = 0
  targetHeaderLen = 4
  readBuffer = ""

  socket = socketlib.tcp();
  socket:settimeout(5)
  
  local result,err = socket:connect( host, port )
  if result == nil then
    Runtime:dispatchEvent({name="sunisnetwork_cannotConnectServer"})
    return
  end
  
  socket:settimeout(0)
  targetPacketLen = 0

  if packetPoolingTimer then
      timer.cancel(packetPoolingTimer)
      packetPoolingTimer = nil
  end
  
  packetPoolingTimer = timer.performWithDelay( packetPoolingDelay, readPackets, 0 )
  
  somunStopped = false

  Runtime:dispatchEvent({name="sunisnetwork_connectedToServer"})

  if onConnectCallback then
    onConnectCallback()
  end

end

function stop(callStackStr)

  print("Somun.stop:", callStackStr)

  if somunStopped then
    print("Somun.stop()  -- WARNING somun already stopped!")
    return
  end

  if packetPoolingTimer then
      timer.cancel(packetPoolingTimer)
      packetPoolingTimer = nil
  end

  socket:close()

  somunStopped = true

  if onDisconnectCallback then
    onDisconnectCallback()
  end

end

function isStopped()
  return somunStopped
end

function callFunction(funcName,parameters)

  print(system.getTimer()*0.001,"somun.callFunction:",funcName)

  local packet = packetlib.createPacket(funcName,parameters)
  local status,err = socket:send(packet)
  
  if err == nil then
    outgoingBytes = outgoingBytes + status
  else

    print("network status, err:", status, err)

    if somunStopped == false then

      stop("somun.callfunction")
      Runtime:dispatchEvent({name="sunisnetwork_connectionClosed"})

    end
    
  end
  
  --print(system.getTimer()*0.001,"Called function:",funcName)

end
