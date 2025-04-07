Mute1_address = "172.30.0.221"
Mute2_address = "172.30.0.222"
Mute3_address = "172.30.0.223"
Mute4_address = "172.30.0.224"
Mic1_address = "172.30.1.214"
Mic2_address = "172.30.0.231"
port = 2202

Mute1 = TcpSocket.New()
Mute1.ReadTimeout = 0
Mute1.WriteTimeout = 0
Mute1.ReconnectTimeout = 5

Mute2 = TcpSocket.New()
Mute2.ReadTimeout = 0
Mute2.WriteTimeout = 0
Mute2.ReconnectTimeout = 5

Mute3 = TcpSocket.New()
Mute3.ReadTimeout = 0
Mute3.WriteTimeout = 0
Mute3.ReconnectTimeout = 5

Mute4 = TcpSocket.New()
Mute4.ReadTimeout = 0
Mute4.WriteTimeout = 0
Mute4.ReconnectTimeout = 5

Mic1 = TcpSocket.New()
Mic1.ReadTimeout = 0
Mic1.WriteTimeout = 0
Mic1.ReconnectTimeout = 5

Mic2 = TcpSocket.New()
Mic2.ReadTimeout = 0
Mic2.WriteTimeout = 0
Mic2.ReconnectTimeout = 5



Mutes = {Mute1, Mute2, Mute3, Mute4, Mic1, Mic2}

HID_Mute = Component.New("HID")["spk.phone.mute"]



function data_decode( msg, raw )
  if msg[2] == "REP" then
    --print("REP")
    local ch = tonumber( msg[3] )
    -- channel message
    if ch == nil then
      local key = msg[3]
      local val = msg[4]
      --print( key , val)
      if key == "MUTE_BUTTON_STATUS" and val == "ON" then
        Mute_Change()
        --print("Mute Call")
      end 
     end   
  end
end




Mute1.Data = function(sock)
  
  local msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    while msg do
      tokens = {}
      for i in string.gmatch( msg, "%S+" ) do
        table.insert( tokens, i )
      end
      data_decode( tokens, msg )
      msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    end
end

Mute2.Data = function(sock)
  
  local msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    while msg do
      tokens = {}
      for i in string.gmatch( msg, "%S+" ) do
        table.insert( tokens, i )
      end
      data_decode( tokens, msg )
      msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    end
end

Mute3.Data = function(sock)
  
  local msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    while msg do
      tokens = {}
      for i in string.gmatch( msg, "%S+" ) do
        table.insert( tokens, i )
      end
      data_decode( tokens, msg )
      msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    end
end

Mute4.Data = function(sock)
  
  local msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    while msg do
      tokens = {}
      for i in string.gmatch( msg, "%S+" ) do
        table.insert( tokens, i )
      end
      data_decode( tokens, msg )
      msg = sock:ReadLine( TcpSocket.EOL.Custom, ">" )
    end
end

Mute1.Connected = function(sock)
  print("Mute 1 Connected")
  if HID_Mute.Boolean == true then
    Mute1:Write("< SET LED_COLOR_UNMUTED RED >")
  else 
    Mute1:Write("< SET LED_COLOR_UNMUTED GREEN >")
  end
end

Mute2.Connected = function(sock)
  print("Mute 2 Connected")
  if HID_Mute.Boolean == true then
    Mute2:Write("< SET LED_COLOR_UNMUTED RED >")
  else 
    Mute2:Write("< SET LED_COLOR_UNMUTED GREEN >")
  end
end

Mute3.Connected = function(sock)
  print("Mute 3 Connected")
  if HID_Mute.Boolean == true then
    Mute3:Write("< SET LED_COLOR_UNMUTED RED >")
  else 
    Mute3:Write("< SET LED_COLOR_UNMUTED GREEN >")
  end
end

Mute4.Connected = function(sock)
  print("Mute 4 Connected")
  if HID_Mute.Boolean == true then
    Mute4:Write("< SET LED_COLOR_UNMUTED RED >")
  else 
    Mute4:Write("< SET LED_COLOR_UNMUTED GREEN >")
  end
end

Mic1.Connected = function(sock)
  print("Mic 1 Connected")
  if HID_Mute.Boolean == true then
    Mic1:Write("< SET LED_COLOR_UNMUTED RED >")
  else 
    Mic1:Write("< SET LED_COLOR_UNMUTED GREEN >")
  end
end

Mic2.Connected = function(sock)
  print("Mic 2 Connected")
  if HID_Mute.Boolean == true then
    Mic2:Write("< SET LED_COLOR_UNMUTED RED >")
  else 
    Mic2:Write("< SET LED_COLOR_UNMUTED GREEN >")
  end
end

function toboolean(str)
    local bool = false
    if str == "ON" then
        bool = true
    end
    return bool
end


function Mute_Change()
  HID_Mute.Boolean = not HID_Mute.Boolean
  --print(HID_Mute.Boolean)
end

HID_Mute.EventHandler = function()
  --print("Hid Change")
  if HID_Mute.Boolean == true then
    --Mic.String = "Red"
    
  else
    --Mic.String = "Green"
  end

  for k,v in ipairs(Mutes) do 
    if v.IsConnected  then

      if HID_Mute.Boolean == true then
        v:Write("< SET LED_COLOR_UNMUTED RED >")
      else 
        v:Write("< SET LED_COLOR_UNMUTED GREEN >")
      end
    end
  end
end

Mute1:Connect(Mute1_address, port)
Mute2:Connect(Mute2_address, port)
Mute3:Connect(Mute3_address, port)
Mute4:Connect(Mute4_address, port)
Mic1:Connect(Mic1_address, port)
Mic2:Connect(Mic2_address, port)