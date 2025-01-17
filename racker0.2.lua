local computer = require("computer")
local robot = require("robot")
local component = require("component")
local event = require("event")

local running = true
local origx, origy, origz = 11, 36, 71
local hatchx,hatchy,hatchz = 15, 37, 71
local curx, cury, curz = origx, origy, origz
print("Charging port at:", origx, origy, origz)

print("Mining hole width:")
local width = tonumber(io.read())
print("Mine which direction?")
print("2:North, 3:South, 4:West(not in use), 5:East")
local direction = tonumber(io.read())
while direction < 2 or direction == 4 or direction > 5 do
    print("Enter valid direction")
    print("2:North, 3:South, 4:West(not in use), 5:East")
    direction = tonumber(io.read())
end

local function homeDirection(home)
    local home = nil
    if direction == 2
        then home = 3
        elseif direction == 3
        then home = 2
        elseif  direction == 4
        then home = 5
        elseif  direction == 5
        then home = 4
        end
    return home
end


local function updatePosition()
    local facingDirection = component.navigation.getFacing()
    if facingDirection == 2 then
        curz = curz - 1
    elseif facingDirection == 3 then
        curz = curz + 1
    elseif facingDirection == 4 then
        curx = curx - 1
    elseif facingDirection == 5 then
        curx = curx + 1
    end
end

local function gotostartpoint()
    while component.navigation.getFacing() ~= 5 do
        robot.turnRight()
    end
    for i = 1, 4 do
        updatePosition()
        robot.forward()
    end
    robot.up()
    cury = origy + 1
    print("X:", curx, "Y:", cury, "Z:", curz)
end

local function sortDescending(x, y, z)
    local values = {{value = x, index = 1}, {value = y, index = 2}, {value = z, index = 3}}
    
    table.sort(values, function(a, b) return a.value > b.value end)
    
    return values
end

local function gohome()
    

    while curx ~= hatchx or cury ~= hatchy or curz ~= hatchz do
        local tempx = math.abs(hatchx - curx)
        local tempy = math.abs(hatchy - cury)
        local tempz = math.abs(hatchz - curz)
        
        diff = sortDescending(tempx, tempy, tempz)
        print("DIFF",diff)
        print("CUR",curx,cury,curz)
        print("HATCH",hatchx,hatchy,hatchz)
        os.sleep(0.1)

    for i,v in ipairs(diff) do
        print("Index:",v.index,"Value:",v.value)
        if v.index == 1 then
            elseif curx > hatchx then
                print("Moving in X axis")
                while component.navigation.getFacing() ~= 4 do
                    robot.turnRight()
                end
                updatePosition()
                robot.forward()
            elseif curx < hatchx then
                while component.navigation.getFacing() ~= 5 do
                    robot.turnRight()
                end
                updatePosition()
                print("Moving in X axis")
                robot.forward()
            end
        if v.index == 2 then
            elseif cury > hatchy then
                print("Moving in Y axis")
                robot.down()
                cury = cury - 1
            elseif cury < hatchy then
                print("Moving in Y axis")
                robot.up()
                cury = cury + 1
            end
        if v.index == 3 then
            elseif curz > hatchz then
                while component.navigation.getFacing() ~= 2 do
                    robot.turnRight()
                end
                updatePosition()
                print("Moving in Z axis")
                robot.forward()
            elseif curz < hatchz then
                while component.navigation.getFacing() ~= 3 do
                    robot.turnRight()
                end
                updatePosition()
                print("Moving in Z axis")
                robot.forward()
            end
        end
    end
end

local function gotoscrapchest()
    while component.navigation.getFacing() ~= 4 do
        robot.turnRight()
    end
    for i = 1, 2 do
        robot.forward()
        curx = curx + 1
    end
    for i = 1, 2 do
        robot.up()
        cury = cury + 1
    end
    updatePosition()
    robot.forward()
    print("X:", curx, "Y:", cury, "Z:", curz)
end

local function gotochargeportoutside()
    while component.navigation.getFacing() ~= 4 do
        robot.turnRight()
    end
    robot.down()
    cury = cury - 1
    for i = 1, 4 do
        robot.forward()
        curx = curx - 1
    end
    print("X:", curx, "Y:", cury, "Z:", curz)
end

local function gotochargeportchest()
    while component.navigation.getFacing() ~= 5 do
        robot.turnRight()
    end
    updatePosition()
    robot.forward()
    for i = 1, 2 do
        robot.down()
        cury = cury - 1
    end
    for i = 1, 3 do
        robot.forward()
        curx = curx + 1
    end
    print("X:", curx, "Y:", cury, "Z:", curz)
end

local function offset()
    print("Offset for start position? y/n")
    local offsetconfirm = tostring(io.read())
    while offsetconfirm ~= "y" and offsetconfirm ~= "n" do
        print("Give either y or n to continue")
        offsetconfirm = tostring(io.read())
    end
    if offsetconfirm == "n" then
        return 0, 0, 0
    end
    if offsetconfirm == "y" then
        print("offset settings for x, y, z (Leave empty if undesired)")
        print("offset x?")
        local offsetx = tonumber(io.read()) or 0
        print("offset y?")
        local offsety = tonumber(io.read()) or 0
        print("offset z?")
        local offsetz = tonumber(io.read()) or 0
        print("offset complete")
        return offsetx, offsety, offsetz
    end
end

local function miner()
    local nowright = true
    while true do
        local charge = computer.energy() / computer.maxEnergy() * 100
        if charge < 40 then
            computer.beep(900, 1)
            break
        end

        updatePosition()
        robot.swing()
        robot.forward()
        robot.swingUp()

        if nowright then
            robot.turnRight()
            nowright = false
        else
            robot.turnLeft()
            nowright = true
        end

        for i = 1, width do
            updatePosition()
            robot.swing()
            robot.forward()
            robot.swingUp()
        end

        if nowright then
            robot.turnRight()
        else
            robot.turnLeft()
        end

        print("X:", curx, "Y:", cury, "Z:", curz)
    end
end
--Logic ends, program order starts
gotostartpoint()
local offsetx, offsety, offsetz = offset()
if offsetx > 0 then
    for i = 1, offsetx do
        updatePosition()
        robot.forward()
    end
end
if offsety ~= 0 then
    if offsety > 0 then
        for i = 1, offsety do
        robot.up()
        cury = cury + 1
        end
    if offsety < 0 then
        offsetyabs = math.abs(offsety)
        for i = 1, offsetyabs do
        robot.down()
        cury = cury - 1
        end
    end
end
if offsetz > 0 then
    for i = 1, offsetz do
        updatePosition()
        robot.forward()
    end
end
while component.navigation.getFacing() ~= direction do
    robot.turnRight()
end
while running do
    updatePosition()
    robot.forward()
    if robot.detect() then
        running = false
    end
end
end

miner()
gohome()
gotochargeportoutside()