local component = require("component")
local sides = require("sides")
local colors = require("colors")
local event = require("event")
local computer = require("computer")
local term = require("term")
local thread = require("thread")
local rs = component.redstone
local ms = component.motion_sensor

local function beeper()
    for i = 1,2,1
    do computer.beep(1500,0,1)
    end
end

local lasttrigger = 0
local treshold = 5 
rs.setOutput(0,15)
local function doortoggle()
    local time = computer.uptime()
    if time - lasttrigger >= treshold then
    beeper()
    rs.setOutput(0,0)--taakse
    computer.beep(1500,3)
    beeper()
    rs.setOutput(0,15)
    lasttrigger = time
    end
end

event.listen("motion",doortoggle)
--while true do
os.sleep(1)
--end