module(..., package.seeall)

local INT_PARAM_TYPE = 0
local BYTE_PARAM_TYPE = 1
local LONG_PARAM_TYPE = 3
local STRING_PARAM_TYPE = 7
local ARRAY_PARAM_TYPE = 8
local OBJECT_PARAM_TYPE = 9

local string_char = string.char
local math_modf = math.modf

local function bytes_to_int(b1, b2, b3, b4)
  local n = b1*16777216 + b2*65536 + b3*256 + b4
  n = (n > 2147483647) and (n - 4294967296) or n
  return n
end    

-- convert a 32-bit two's complement integer into a four bytes (network order)
function int_to_bytes(n)
  if n > 2147483647 then error(n.." is too large",2) end
  if n < -2147483648 then error(n.." is too small",2) end
  -- adjust for 2's complement
  n = (n < 0) and (4294967296 + n) or n
  return (math_modf(n/16777216))%256, (math_modf(n/65536))%256, (math_modf(n/256))%256, n%256
end

local function int_to_bytes2(n)
  -- adjust for 2's complement
  n = (n < 0) and (4294967296 + n) or n
  return (math_modf(n/256))%256, n%256
end

local function numberToBytes4(number)
  local b0, b1, b2, b3 = int_to_bytes(number)
  return string_char(b0,b1,b2,b3)

end

local function numberToBytes2(number)
  local b0, b1 = int_to_bytes2(number)
  return string_char(b0,b1)
end

function bytes2ToNumber(bytes)
  return bytes:byte(1)*256 + bytes:byte(2)
end

function bytes4ToNumber(bytes)
  return bytes_to_int(bytes:byte(1), bytes:byte(2), bytes:byte(3), bytes:byte(4))
end
local _bytes4ToNumber = bytes4ToNumber

-- TODO fix not working with negative values
local function bytes8ToNumber(bytes)
  return bytes:byte(1)*2^56 + bytes:byte(2)*2^48 + bytes:byte(3)*2^40 + bytes:byte(4)*2^32 + bytes:byte(5)*2^24 + bytes:byte(6)*2^16 + bytes:byte(7)*2^8 + bytes:byte(8)
end

local function convertToUTF8(inputString)
  return numberToBytes2(inputString:len())..inputString
end

local function readAsInteger(data)
  return bytes_to_int(data:byte(1), data:byte(2), data:byte(3), data:byte(4))
end

function createPacket( funcName, params )
  
  local paramCount = #params
  local data = convertToUTF8(funcName) .. string_char(paramCount)

  for i=1,paramCount do
    local param = params[i]
    local _type = param[1]
    local value = param[2]

    if _type == "string" then
      data = data .. string_char(STRING_PARAM_TYPE) .. convertToUTF8( tostring(value) )
    
    elseif _type == "int" then
      data = data .. string_char(INT_PARAM_TYPE) .. numberToBytes4( tonumber(value) )
    
    elseif _type == "string_array" then

      data = data .. string_char(ARRAY_PARAM_TYPE) .. numberToBytes4(#value)
      data = data .. string_char(STRING_PARAM_TYPE)

      for index=1,#value do
        data = data .. convertToUTF8( tostring(value[index]) )
      end
      
    elseif _type == "obj_array" then
      
      data = data .. string_char(ARRAY_PARAM_TYPE) .. numberToBytes4(#value)
      data = data .. string_char(OBJECT_PARAM_TYPE)
      
      for k=1,#value do      
        
        local v = value[k]
        local objType = v[1]
        local objValue = v[2]
        
        if objType == "int" then
          data = data .. string_char(INT_PARAM_TYPE) .. numberToBytes4( tonumber(objValue) )
        
        elseif objType == "string" then
          data = data .. string_char(STRING_PARAM_TYPE) .. convertToUTF8( tostring(objValue) )

        elseif objType == "int_array" then
        
          data = data .. string_char(ARRAY_PARAM_TYPE) .. numberToBytes4(#objValue)
          data = data .. string_char(INT_PARAM_TYPE)
          
          for index=1,#objValue do
            data = data .. numberToBytes4( tonumber(objValue[index]) )
          end
        
        end
        
      end 
      
    end
    
  end  
  
  return numberToBytes4(data:len()) .. data
  
end

local function readAsUTF8(data)
  local strLen = bytes2ToNumber(data)
  return data:sub(3,2+strLen)  
end

local function readAsArray(data)

  local arrayLen = _bytes4ToNumber(data)
  local dataType = data:byte(5)
  
  local readDataLength = 5
  local dataIndex = 6
  local dataArray = {}
  
  for i=1,arrayLen do
  
    local value
  
    if dataType == BYTE_PARAM_TYPE then
      value = data:byte(dataIndex)
                  
      dataIndex = dataIndex + 1
      readDataLength = readDataLength + 1
    
    elseif dataType == INT_PARAM_TYPE then
      value = _bytes4ToNumber(data:sub(dataIndex,dataIndex+4))
                  
      dataIndex = dataIndex + 4
      readDataLength = readDataLength + 4
    
    elseif dataType == LONG_PARAM_TYPE then
      value = bytes8ToNumber(data:sub(dataIndex,dataIndex+8))
                  
      dataIndex = dataIndex + 8
      readDataLength = readDataLength + 8
    
    elseif dataType == STRING_PARAM_TYPE then
    
      value = readAsUTF8(data:sub(dataIndex,-1))
      dataIndex = dataIndex + value:len() + 2
      readDataLength = readDataLength + value:len() + 2
    end
    
    dataArray[i] = value
  
  end
  
  return dataArray, readDataLength

end

function parse(packet)

  local currentIndex = 1
  
  local funcName = readAsUTF8(packet:sub(currentIndex,-1))
  --print("funcName: ",funcName)
  
  currentIndex = currentIndex + funcName:len() + 2
  
  local paramCount = packet:byte(currentIndex)
  currentIndex = currentIndex + 1
  
  local parameters = {}
  
  for paramIdx=1,paramCount do
  
    local paramType = packet:byte(currentIndex)
    currentIndex = currentIndex + 1
    
    local paramValue
    if paramType == BYTE_PARAM_TYPE then
    
      paramValue = packet:byte(currentIndex)
      currentIndex = currentIndex + 1

    elseif paramType == INT_PARAM_TYPE then
    
      paramValue = _bytes4ToNumber(packet:sub(currentIndex,-1))
      currentIndex = currentIndex + 4
    
    elseif paramType == LONG_PARAM_TYPE then
    
      paramValue = bytes8ToNumber(packet:sub(currentIndex,-1))
      currentIndex = currentIndex + 8
         
    elseif paramType == STRING_PARAM_TYPE then
    
      paramValue = readAsUTF8(packet:sub(currentIndex,-1))
      currentIndex = currentIndex + paramValue:len() + 2
         
    elseif paramType == ARRAY_PARAM_TYPE then
                 
      paramValue, readLength = readAsArray(packet:sub(currentIndex,-1))
      currentIndex = currentIndex + readLength
    
    end
    
    parameters[paramIdx] = paramValue
  
  end
  
  return funcName,parameters

end
