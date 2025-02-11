heldTimer = Timer.New()

pressed = 0

function Pressed()
    --Do Pressed Stuff
    print("Pressed " .. pressed)

end

function Held()
    --DO Held Stuff
  print("Held " .. pressed)
end

function ButtonCheck()
    if Controls.Preset[pressed].Boolean then
        Held()
        heldTimer:Stop()
    end
end
  
function PresetPress(ctl)
  for i, c in ipairs( Controls.Preset) do 
    if c == ctl then 
      pressed = i
    end
  end
    if ctl.Boolean then 
      heldTimer:Start(10)
    else 
      if heldTimer:IsRunning() then
        heldTimer:Stop()
        Pressed()
      end
      pressed = 0
    end
end

for ix, ctl in ipairs ( Controls.Preset ) do
    ctl.EventHandler = PresetPress
end

heldTimer.EventHandler = ButtonCheck