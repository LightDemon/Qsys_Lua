--video routing
switcherAddress = "172.30.0.151"
switcherPort = 23

pollProgramFlag = false
pollPreviewFlag = false

switcher = TcpSocket.New()
switcher.ReadTimeout = 0
switcher.WriteTimeout = 0
switcher.ReconnectTimeout = 5

sourceA = Component.New("Source A")["select.1"]
sourceA.Value = 2
sourceB = Component.New("Source B")["select.1"]
sourceB.Value = 5
sourceFbA = false
sourceFbB = false

projLsourceA = Component.New("ZeeVee")["Join.Output.1.Input.1"]
projLsourceA.Value = true
projLsourceB = Component.New("ZeeVee")["Join.Output.1.Input.2"]
projLsourceB.Value = false

projRsourceA = Component.New("ZeeVee")["Join.Output.2.Input.1"]
projRsourceA.Value = true
projRsourceB = Component.New("ZeeVee")["Join.Output.2.Input.2"]
projRsourceB.Value = false

OversourceA = Component.New("ZeeVee")["Join.Output.3.Input.1"]
OversourceA.Value = true
OversourceB = Component.New("ZeeVee")["Join.Output.3.Input.2"]
OversourceB.Value = false

display = Component.New("ZeeVee")["preset"]
overFlow = Component.New("OverFlow")["mute"]

--Camera Control

cameraSelect = Component.New("Camera")["select.1"]
cameraSelect.Value = 1

leftPan = Component.New("Buttons")["momentary.4"]
rightPan = Component.New("Buttons")["momentary.5"]
upTilt = Component.New("Buttons")["momentary.6"]
downTilt = Component.New("Buttons")["momentary.7"]

teleZoom = Component.New("Buttons")["momentary.8"]
wideZoom = Component.New("Buttons")["momentary.9"]

preset1 = Component.New("Buttons")["momentary.10"]
preset2 = Component.New("Buttons")["momentary.11"]
preset3 = Component.New("Buttons")["momentary.12"]

camBtns = {leftPan, rightPan, upTilt, downTilt, teleZoom, wideZoom}
camPresetBtns = {preset1, preset2, preset3}
camMoves = {"pan left", "pan right", "tilt up", "tilt down", "zoom in", "zoom out"}
camStop = {"pan stop", "pan stop", "tilt stop", "tilt stop", "zoom stop", "zoom stop"}
camLast = 0

--Projector
projLeftPower = Component.New("ProjLeft")["Power"]
projRightPower = Component.New("ProjRight")["Power"]
projectorStatus = Component.New("ProjLeft")["PowerStatus"]
projButton = Component.New("Buttons")["toggle.5"]


--Projector Screen

leftProjDown = Component.New("Relay1")["relay.2"]
leftProjUp = Component.New("Relay1")["relay.1"]
rightProjUp = Component.New("Relay2")["relay.1"]
rightProjDown = Component.New("Relay2")["relay.2"]

--Panel Control
Component.New("Buttons").toggle_5.IsDisabled = false

simpleBtn = Component.New("Buttons")["momentary.1"]
advBtn = Component.New("Buttons")["momentary.2"]
secretBtn = Component.New("Buttons")["momentary.3"]
shutDownBtn = Component.New("Buttons")["momentary.13"]
confirmBtn = Component.New("Buttons")["momentary.14"]
cancelBtn = Component.New("Buttons")["momentary.15"]

modes = {simpleBtn , advBtn}

projSourceBtn = Component.New("Buttons")["toggle.1"]
zoomSourceBtn = Component.New("Buttons")["toggle.2"]
cameraControlBtn = Component.New("Buttons")["toggle.3"]
lightControlBtn = Component.New("Buttons")["toggle.4"]
projSourceBtn.Value = 0
zoomSourceBtn.Value = 0
cameraControlBtn.Value = 0
lightControlBtn.Value = 0

lockOut = false

subLayers = {"Projector Source", "Zoom", "Camera", "Lighting"}

pageSelect = {projSourceBtn, zoomSourceBtn, cameraControlBtn, lightControlBtn}

Uci.SetLayerVisibility( "Innovation", "Main", "Simple", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Projector Source", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Zoom", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Camera", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Start", true, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Secret", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "ShutDown", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Lighting", false, "none" )
Uci.SetLayerVisibility( "Innovation", "Main", "Wait", false, "none" )

--Audio snapshots
audioDefault = Component.New("Audio Snapshot")["load.1"]

--Lighting

startPreset = Component.New("Lutron")["SceneActivate 1"]
projectorPreset = Component.New("Lutron")["SceneActivate 2"]

--functions

function excludeLayer( ctl ) --Handel showing layers
  if ctl.Value == 1 then
    for i, c in ipairs( pageSelect ) do
      if c ~= ctl then
        c.Value = 0
        --Hide incorrect layer
        Uci.SetLayerVisibility( "Innovation", "Main", subLayers[i], false, "none" )
        else 
        Uci.SetLayerVisibility( "Innovation", "Main", subLayers[i], true, "none" )
        Uci.SetLayerVisibility( "Innovation", "Main", "Secret", false, "none" )
      end
    end
  end
end

for ix, ctl in ipairs( pageSelect ) do -- Page Select Buttons EventHandeler
  ctl.EventHandler = excludeLayer
  
end

function cameraMove( ctl ) --Camera Movemnts
  print("cam move")
  if not switcher.IsConnected then
    return
  end
  camNumber = cameraSelect.Value | 0
  if ctl.Value == 1 then
    for i, c in ipairs( camBtns ) do
      if c.Value == 1 then
        camLast = i
        switcher:Write("camera "..camNumber.." "..camMoves[i].."\r")
      end
    end
  else
    if camLast ~= 0 then
      switcher:Write("camera "..camNumber.." "..camStop[camLast].."\r")
    end
  end
end

for ix, ctl in ipairs( camBtns ) do -- Camera Control Buttons EventHandeler
  ctl.EventHandler = cameraMove
end

function cameraPreset(ctl) -- Camera Preset
  print("cam preset")
  if not switcher.IsConnected then
    return
  end
  camNumber = cameraSelect.Value | 0
  if ctl.Value == 1 then
    for i, c in ipairs( camPresetBtns ) do
      if c.Value == 1 then
        switcher:Write("camera "..camNumber.." preset recall "..i.."\r")
        print("camera "..camNumber.." preset recall "..i.."")
      end
    end
  end
end


for ix, ctl in ipairs( camPresetBtns ) do -- Camera Preset buttons EventHandler
  ctl.EventHandler = cameraPreset
end

simpleBtn.EventHandler = function() --Start button
  if simpleBtn.Value == 1 and lockOut == false then
    Uci.SetLayerVisibility( "Innovation", "Main", "Start", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Simple", true, "none" )
    audioDefault:Trigger()
  end
end

shutDownBtn.EventHandler = function() -- Shutdown button
  if shutDownBtn.Value == 1 then
    Uci.SetLayerVisibility( "Innovation", "Main", "ShutDown", true, "none" )
  end
end

cancelBtn.EventHandler = function() -- Cancel Shutdown button
  if cancelBtn.Value == 1 then
    Uci.SetLayerVisibility( "Innovation", "Main", "ShutDown", false, "none" )
  end
end

confirmBtn.EventHandler = function() -- Confirm Shutdown button
  if confirmBtn.Value == 1 then
    lockOut = true
    Uci.SetLayerVisibility( "Innovation", "Main", "Simple", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Projector Source", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Zoom", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Camera", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Start", true, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Secret", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "ShutDown", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Lighting", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Wait", true, "none" )
    projButton.Value = 0
    overFlow.Value = 1
    projLsourceA.Value = true
    projLsourceB.Value = false
    projRsourceA.Value = true
    projRsourceB.Value = false
    OversourceA.Value = true
    OversourceB.Value = false
    projSourceBtn.Value = 0
    zoomSourceBtn.Value = 0
    cameraControlBtn.Value = 0
    lightControlBtn.Value = 0
    Timer.CallAfter(Unlock, 30)
    sourceA.Value = 2
  end
end

overFlow.EventHandler = function()
  if overFlow.Value == 1 then
    display.String = "DispOff"
    print("Display Off")
  else
    print("Set to HDMI and ON")
    display.String = "DispOn"
    Timer.CallAfter(setHdmi,15)
  end
end

function setHdmi()
  display.String = "DispHdmi"
end

projButton.EventHandler = function()
  if projButton.Value == 1 then
    projRightPower.Value = 1
    projLeftPower.Value = 1
    ScreensDown()
    print("Projectors ON")
  else
    projRightPower.Value = 0
    projLeftPower.Value = 0
    ScreensUp()
    print("Projectors OFF")
  end
  Component.New("Buttons").toggle_5.IsDisabled = true
  Timer.CallAfter(EnablePowerButton,30)
end

function EnablePowerButton()
  Component.New("Buttons").toggle_5.IsDisabled = false
end

function DownPulse() -- Open Down Relay
  leftProjDown.Value = 0
  rightProjDown.Value = 0
end

function UpPulse() -- Open Up Relay
  leftProjUp.Value = 0
  rightProjUp.Value = 0
end


function ScreensDown() -- Close Down Relay
  leftProjDown.Value = 1
  rightProjDown.Value = 1
  Timer.CallAfter(DownPulse, 1)
end

function ScreensUp() -- Close Down Relay
  leftProjUp.Value = 1
  rightProjUp.Value = 1
  Timer.CallAfter(UpPulse, 1)
end

secretBtn.EventHandler = function() -- First press of secret button
  if secretBtn.Value == 1 then
    Timer.CallAfter(ShowSecret, 5)
    print("secret BTN press")
  end
end

function ShowSecret() -- Check if secret button is still pressed
  print("secret button check: "..secretBtn.Value)
  if secretBtn.Value == 1 then
    Uci.SetLayerVisibility( "Innovation", "Main", "Projector Source", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Zoom", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Camera", false, "none" )
    Uci.SetLayerVisibility( "Innovation", "Main", "Secret", true, "none" )
    projSourceBtn.Value = 0
    zoomSourceBtn.Value = 0
    cameraControlBtn.Value = 0
  end
end

  switcher.Connected = function(switcher) -- Switcher Connected
    print("Switcher Connected")
  end


  switcher.Data = function(switcher) -- Receive data from Switcher
    line = switcher:Read(switcher.BufferLength)
    processFB(line)
  end
  
  function processFB(data)
    --print(data)
      if string.find(data,"Last login:") then
        pollProgramFlag = true
        Timer.CallAfter(pollProgram,1)
      elseif string.find(data,"login:") then
        switcher:Write('admin\x0d\x0a')
      end
      if string.find(data,"Password:") then
        switcher:Write('password\x0d\x0a')
      end
      if string.find(data,"source:") then
        if pollProgramFlag then
          programSource = tonumber(data:sub(14,15))
          --print("Program Source is " .. programSource)
          sourceFbA = true
          if programSource == 1 then
            sourceA.Value = 3
          elseif programSource == 2 then
            sourceA.Value = 4
          elseif programSource == 8 then
            sourceA.Value = 2
            --print("Set Source 2")
          end
          pollProgramFlag = false
          Timer.CallAfter(pollPreview, 30)
          pollPreviewFlag = true
          return
        end
        if pollPreviewFlag then
          previewSource = tonumber(data:sub(14,15))
          --print("Preview Source is " .. previewSource)
          sourceFbB = true
          if previewSource == 1 then
            sourceB.Value = 3
          elseif previewSource == 2 then
            sourceB.Value = 4
          elseif previewSource == 8 then
            sourceB.Value = 2
          end
          pollPreviewFlag = false
          Timer.CallAfter(pollProgram, 30)
          pollProgramFlag = true
        end
      end
  end
  
  function makeSwitch(output , input) -- Send video switch Command
    switcher:Write("video "..output.." source set "..input.."\r")
    switcher:Write("switch "..output.." take\r")
  end
  
  function pollProgram()
    switcher:Write("video program source get\r")
  end
  
  function pollPreview()
    switcher:Write("video preview source get\r")
  end
  
  sourceA.EventHandler = function() -- Select Bus A Source
    if sourceFbA then
      sourceFbA = false
      return
    end
  print(sourceA.Value)
    if sourceA.Value == 1 then
      makeSwitch("program", "input7")
    elseif sourceA.Value == 2 then
      makeSwitch("program", "input8")
    elseif sourceA.Value == 3 then
      makeSwitch("program", "input1")
    elseif sourceA.Value == 4 then
      makeSwitch("program", "input2")
    end
  end
  
    sourceB.EventHandler = function() -- Select Bus B Source
    if sourceFbB then
      sourceFbB = false
      return
    end
  print(sourceB.Value)
    if sourceB.Value == 1 then
      makeSwitch("preview", "input7")
    elseif sourceB.Value == 2 then
      makeSwitch("preview", "input8")
    elseif sourceB.Value == 3 then
      makeSwitch("preview", "input1")
    elseif sourceB.Value == 4 then
      makeSwitch("preview", "input2")
    end
  end
  
  function Unlock()
     Uci.SetLayerVisibility( "Innovation", "Main", "Wait", false, "none" )
    lockOut = false
  end
  
  switcher:Connect(switcherAddress, switcherPort) -- Connect to Switcher-