local component = require("component")
local sides = require("sides")
local colors = require("colors")
local event = require("event")
local computer = require("computer")
local term = require("term")

function setRes()
component.gpu.setResolution(25,10)
end

tempmonitor = component.proxy("e87678ac-aaf5-49a0-b4c1-6dfcebd60325")
reactorcontroller = component.proxy("572f7b55-75bc-464c-ab61-87752298fee3")

local function exitcountdown()
    for i = 10,0,-1 do
        os.sleep(1)
    print("exiting program to ensure safety in",i)
    if i == 0 then
        os.exit()
        end
    end
end




local function cooler()
    reactorcontroller.setOutput(sides.top, 0)
    for i= 1,30,1 do
    computer.beep(2000,0.15)
    computer.beep(1000,0.15)
    os.sleep(1)
    end
reactorcontroller.setOutput(sides.top, 1)
end

local function startup()
    print("Starting...")
    for i= 1,3,1 do
    computer.beep(250,0.5)
    computer.beep(500,0.5)
    computer.beep(1000,0.5)
    end
reactorcontroller.setOutput(sides.top, 1)
end

local function shutdown()
    reactorcontroller.setOutput(sides.top, 0)
    print("Shutting down")
    for i= 1,3,1 do
    computer.beep(900,1)
    computer.beep(400,1)
    computer.beep(300,1)
    end
end

local function getcoreheat()
    return tempmonitor.getInput(sides.north)
end
local function running()
   return reactorcontroller.getOutput(sides.top)
end

--local function input()
    --return term.
--end

function main()
term.clear()
while true do
    corechanged = nil
    coreheat = getcoreheat()
    if coreheat < 5 then
    startup()
    else
    term.clear()
    print("REACTOR 2 OFFLINE\nIdling until core has cooled down\nCoreheat is now at:",coreheat,"\n\n(Automatic startup when core reaches 4)")

    end
        term.clear()
        while true do
        os.sleep(0.1)
        if running() == 0 then
        break
        end
        coreheat = getcoreheat()
        getcoreheat()


            if corechanged ~= coreheat then
            term.clear()               
            print("REACTOR 2 ONLINE\ncoretemp is",coreheat)
            corechanged = coreheat
            end

            if coreheat == 8 then
            print("CURRENTLY COOLING")
            cooler()
            end
            if coreheat > 8 then
            print("WARNING CORE HEAT IS DANGEROUSLY HIGH")
            computer.beep(1800,0.2)
            end
            if coreheat > 10 then
            print("MELTDOWN IMMINENT! ATTEMPTING CORE SHUTDOWN")
            shutdown()
            break
            end 
        end        
    end
    os.sleep(0.5)
end
setRes()
main()