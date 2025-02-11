PodiumIP = Component.New("Podium Encoder")["IP.ADDRESS"]
EastWallIP = Component.New("East Wall Encoder")["IP.ADDRESS"]
NorthWall1IP = Component.New("North Wall 1 Encoder")["IP.ADDRESS"]
NorthWall2IP = Component.New("North Wall 2 Encoder")["IP.ADDRESS"]
SouthWallIP = Component.New("South Wall Encoder")["IP.ADDRESS"]
WestWallIP = Component.New("West Wall Encoder")["IP.ADDRESS"]
Cisco1IP = Component.New("Cisco 1 Encoder")["IP.ADDRESS"]
Cisco2IP = Component.New("Cisco 2 Encoder")["IP.ADDRESS"]
QuadIP = Component.New("Quad View Encoder")["IP.ADDRESS"]

Projector1Input = Component.New("East Disply Decoder")["encIP.all"]
Projector2Input = Component.New("West Dispaly Decoder")["encIP.all"]

ContentInput = Component.New("Content Decoder")["encIP.all"]
ContentOutput = Component.New("Content Decoder")["video.output.mode"]

Quad1Input = Component.New("Quad 1 Decoder")["encIP.all"]
Quad2Input = Component.New("Quad 2 Decoder")["encIP.all"]
Quad3Input = Component.New("Quad 3 Decoder")["encIP.all"]
Quad4Input = Component.New("Quad 4 Decoder")["encIP.all"]

SourceNameList = {"Podium", "East Wall", "North Wall 1", "North Wall 2", "South Wall", "West Wall", "Cisco 1", "Cisco 2", "Quad Viewer", "None"}
DestList = {Projector1Input, Projector2Input, ContentInput, Quad1Input, Quad2Input, Quad3Input, Quad4Input}


EncoderList = {PodiumIP, EastWallIP, NorthWall1IP, NorthWall2IP, SouthWallIP, WestWallIP, Cisco1IP, Cisco2IP, QuadIP}

QuadViewURL = "http://"..QuadIP.String.."/cgi-bin/wapi.cgi"
QuadViewUser = "admin"
QuadViewPass = "CTIr0cks!"
QuadCommand ={"STREAM.VIDEO=QUAD","STREAM.VIDEO=PIP","STREAM.VIDEO=PIP_2","STREAM.VIDEO=POP"}

BtURL = "http://"..SouthWallIP.String.."/cgi-bin/wapi.cgi"
BTCommand = {"BT.PAIR=TRUE",}


Projector1 = Component.New("Projector 1")
Projector2 = Component.New("Projector 2")
Relay1 = Component.New("Relay 1")
Relay2 = Component.New("Relay 2")

UI = Component.New("TP 1")

SourceIp = 0
Dest = 0

encIp = {}
encIp[1] = PodiumIP.String
encIp[2] = EastWallIP.String
encIp[3] = NorthWall1IP.String
encIp[4] = NorthWall2IP.String
encIp[5] = SouthWallIP.String
encIp[6] = WestWallIP.String
encIp[7] = Cisco1IP.String
encIp[8] = Cisco2IP.String
encIp[9] = QuadIP.String
encIp[10] = "172.30.1.10" --Dead input

function Take()
  DestList[Dest].String = encIp[SourceIp]
  if Dest == 3 then 
    if SourceIp == 10 then   
      ContentOutput.String = "OFF"
    else 
      ContentOutput.String = "NORMAL"
    end 
  end
  Controls.InputLable[Dest].String = SourceNameList[SourceIp] 
  SourceIp = 0
  Dest = 0
  for i, c in ipairs( Controls.SourceSelect) do 
    c.Boolean = false 
  end
  for i, c in ipairs( Controls.DestSelect) do 
    c.Boolean = false 
  end
end

function SourceSelect( ctl )
  for i, c in ipairs( Controls.SourceSelect ) do 
    if c ~= ctl then
      c.Boolean = false
    else
      SourceIp = i
      if Dest > 0 and SourceIp > 0 then 
        Take()
      end
    end 
  end
end

for ix, ctl in ipairs( Controls.SourceSelect ) do
  ctl.EventHandler = SourceSelect
end

function DestSelect( ctl )
  for i, c in ipairs( Controls.DestSelect ) do 
    if c ~= ctl then
      c.Boolean = false
    else
      Dest = i
      if Dest > 0 and SourceIp > 0 then 
        Take()
      end
    end 
  end
end

for ix, ctl in ipairs( Controls.DestSelect ) do
  ctl.EventHandler = DestSelect
end

function done(a,b,c,d,e)
  --if b == 200 then 
    --return 
  --else
    print(b)
    print(c)
    print(d)
    print(e)
  --end
end

function SetQuadMode(mode)
  local auth = Crypto.Base64Encode(QuadViewUser..":"..QuadViewPass)
  HttpClient.Upload{
    Url = QuadViewURL,
    Method = "POST",
    Data = "CMD=START&UNIT.ID=ALL&"..QuadCommand[mode].."&CMD=END",
    Headers ={
      ["Content-Type"] = "application/x-www-form-urlencoded",
      Authorization = "Basic ".. auth,
    },
    Timeout = 5,
    EventHandler = done
  }
end

function SetBT()
  local auth = Crypto.Base64Encode(QuadViewUser..":"..QuadViewPass)
  HttpClient.Upload{
    Url = BtURL,
    Method = "POST",
    Data = "CMD=START&UNIT.ID=ALL&BT.BUTTON_ENABLED=TRUE&CMD=END",
    Headers ={
      ["Content-Type"] = "application/x-www-form-urlencoded",
      Authorization = "Basic ".. auth,
    },
    Timeout = 5,
    EventHandler = done
  }
end

function QuadLayout( ctl )
  for i, c in ipairs( Controls.QuadLayout ) do 
    if c ~= ctl then
      c.Boolean = false
    else
      SetQuadMode(i)
    end 
  end
end

for ix, ctl in ipairs( Controls.QuadLayout ) do
  ctl.EventHandler = QuadLayout
end

function SetQuadAudio(input)
  local auth = Crypto.Base64Encode(QuadViewUser..":"..QuadViewPass)
  HttpClient.Upload{
    Url = QuadViewURL,
    Method = "POST",
    Data = "CMD=START&UNIT.ID=ALL&STREAM.AUDIO=DECODER_"..input.."&CMD=END",
    Headers ={
      ["Content-Type"] = "application/x-www-form-urlencoded",
      Authorization = "Basic ".. auth,
    },
    Timeout = 5,
    EventHandler = done
  }
end

function QuadAudio( ctl )
  for i, c in ipairs( Controls.QuadAudio) do 
    if c ~= ctl then
      c.Boolean = false
    else
      SetQuadAudio(i)
    end 
  end
end

for ix, ctl in ipairs( Controls.QuadAudio ) do
  ctl.EventHandler = QuadAudio
end

function EncodeUpdate( ctl )
  for i, c in ipairs( EncoderList ) do 
    if c == ctl then  
      encIp[i] = EncoderList[i].String
    end 
  end
end

for ix, ctl in ipairs( EncoderList ) do
  ctl.EventHandler = EncodeUpdate
end

--Screen Control
Projector1["Power"].EventHandler = function()
  if Projector1["Power"].Boolean then
    Relay1["relay.1"].Boolean = true 
    Timer.CallAfter(function() Relay1["relay.1"].Boolean = false end,0.2)
    Relay2["relay.1"].Boolean = true 
    Timer.CallAfter(function() Relay2["relay.1"].Boolean = false end,0.2)
  else 
    Relay1["relay.2"].Boolean = true 
    Timer.CallAfter(function() Relay1["relay.2"].Boolean = false end,0.2)
    Relay2["relay.2"].Boolean = true 
    Timer.CallAfter(function() Relay2["relay.1"].Boolean = false end,0.2)
  end
end

function SourceReset()
  Dest = 1
  SourceIp = 7
  Take()
  Dest = 2
  SourceIp = 8
  Take()
  Dest = 3
  SourceIp = 10
  Take()

end

UI["Confirm"].EventHandler = function()
  Projector1["Power"].Boolean = false
  SourceReset()
end

SourceReset()
