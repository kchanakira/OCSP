local component = require("component")
local sides = require("sides")
local GUI = require("GUI")

--------------------------------------------------------------------------------

-- Constants
local chest = sides.down
local spawner = sides.up
--local spawnerRedstone = sides.up
local crusherRedstone = sides.up
local spawnerMIPSlot = 7

-- Important stuff
local mips = {}
local currentMIPSlot
local currentMIPButton

local transposer
local redstone

--local enableSpawner = true
local enableCrusher = true

local function initComponents()
    transposer = component.transposer
    redstone = component.redstone

    --redstone.setOutput(spawnerRedstone, enableSpawner and 15 or 0)
    redstone.setOutput(crusherRedstone, enableCrusher and 15 or 0)
end

--------------------------------------------------------------------------------

-- GUI
local mainContainer = GUI.fullScreenContainer()
local grid = nil
local numColumns = 3

local function initGUI()
    --mainContainer:addChild(GUI.panel(1, 1, mainContainer.width, mainContainer.height, 0x2D2D2D))

    grid = mainContainer:addChild(GUI.layout(1, 1, mainContainer.width, mainContainer.height, 3, 2))
    grid:setRowHeight(1, GUI.SIZE_POLICY_RELATIVE, 0.8)
    grid:setRowHeight(2, GUI.SIZE_POLICY_RELATIVE, 0.2)
    
    for x = 1, 3 do
        for y = 1, 2 do
            grid:setAlignment(x, y, GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_CENTER)
            grid:setFitting(x, y, true, false, 2, 2)
        end
    end

    -- Create the spawner/crusher toggle buttons
    --[[
    local buttonEnableSpawner = grid:setPosition(2, 2, grid:addChild(GUI.framedButton(1, 1, 26, 3, 0x7C0A02, 0x000000, 0x014421, 0xFFFFFF, "Spawner")))

    buttonEnableSpawner.switchMode = true
    buttonEnableSpawner.pressed = enableSpawner
    buttonEnableSpawner.onTouch = function ()
        enableSpawner = not enableSpawner
        redstone.setOutput(spawnerRedstone, enableSpawner and 15 or 0)
    end
    --]]

    local buttonEnableCrusher = grid:setPosition(2, 2, grid:addChild(GUI.framedButton(1, 1, 26, 3, 0x7C0A02, 0xFFFFFF, 0x014421, 0xFFFFFF, "Crusher")))

    buttonEnableCrusher.switchMode = true
    buttonEnableCrusher.pressed = enableCrusher
    buttonEnableCrusher.onTouch = function ()
        enableCrusher = not enableCrusher
        redstone.setOutput(crusherRedstone, enableCrusher and 15 or 0)
    end
end

-- Creates a grid button for each filled MIP
local function createMIPButtons()
    grid:removeChildren(3)

    local gridY = 1

    -- Make a button for each MIP
    for i, mip in ipairs(mips) do
        local button = GUI.button(1, 1, 26, 5, 0x555555, 0xFFFFFF, 0x014421, 0xFFFFFF, mip.mobName)

        button.MIP = mip
        button.switchMode = true
        button.onTouch = function ()
            -- Retrieve the MIP currently in the spawner
            if currentMIPButton then
                transposer.transferItem(spawner, chest, 1, spawnerMIPSlot, currentMIPButton.MIP.chestSlot)
                currentMIPButton.pressed = false
                currentMIPButton = nil
            end

            -- Send the selected MIP to the spawner
            if button.pressed then
                transposer.transferItem(chest, spawner, 1, mip.chestSlot, spawnerMIPSlot)
                currentMIPButton = button
            end
        end

        grid:setPosition(((i - 1) % numColumns) + 1, gridY, grid:addChild(button))
    end

    -- Fill in the remaining grid cells
    for i = (#mips % numColumns) + 1, numColumns do
        grid:setPosition(i, gridY, grid:addChild(GUI.button(1, 1, 26, 5, 0x000000, 0x000000, 0x000000, 0x000000, "")))
    end
end

--------------------------------------------------------------------------------

-- Items

-- Moves all of the items in an inventory to the front
local function condenseItems(transposer, side)
    local lastOccupiedSlot = 1

    for slot = 1, transposer.getInventorySize(side) do
        local stack = transposer.getStackInSlot(side, slot)

        if stack ~= nil then
            if slot ~= lastOccupiedSlot then
                transposer.transferItem(side, side, stack.size, slot, lastOccupiedSlot)
            end

            lastOccupiedSlot = lastOccupiedSlot + 1
        end
    end
end

-- Pulls an item into the first empty slot in the destination
local function pullItem(transposer, source, sourceSlot, destination)
    local destinationSize = transposer.getInventorySize(destination)

    if transposer.getStackInSlot(source, sourceSlot) == nil then
        return true
    end

    -- Finds the first empty slot and moves the stack to it
    for slot = 1, destinationSize do
        local stack = transposer.getStackInSlot(destination, slot)

        if stack == nil then
            transposer.transferItem(source, destination, 1, sourceSlot, slot)

            return true
        end
    end

    return false
end

-- Scans and adds the mobs in MIPs to the MIP table
local function scanMIPs()
    -- Clear out the MIP table in case anything has changed
    mips = {}

    -- Scan the chest for MIPs containing mobs
    for slot = 1, transposer.getInventorySize(chest) do
        local stack = transposer.getStackInSlot(chest, slot)

        if stack == nil then
            break
        end

        -- Make sure to only accept Industrial Foregoing MIPs that contain mobs
        if stack.name == "industrialforegoing:mob_imprisonment_tool" then
            local mobName = string.match(stack.label, "%((.-)%)")

            if mobName ~= nil then
                -- Try to clean up the mob name in case the name on the MIP isn't properly set
                mobName = mobName:gsub("_", " ")
                mobName = mobName:gsub("(%a)([%w_']*)", function (first, rest) return first:upper()..rest:lower() end)

                table.insert(mips, {
                    chestSlot = slot,
                    mobName = mobName
                })
            end
        end
    end

    -- Sort the MIPs (in the table, not in the chest)
    table.sort(mips, function (a, b) return a.mobName < b.mobName end)
end

local function initItems()
    -- Retrieve the MIP currently in the spawner
    if pullItem(transposer, spawner, spawnerMIPSlot, chest) ~= true then
        GUI.alert("Unable to retrieve an MIP from the spawner: not enough room")
        os.exit()
    end

    -- Condense the items in the chest
    condenseItems(transposer, chest)

    -- Scan them and create buttons on the screen
    scanMIPs()
    createMIPButtons()
end

--------------------------------------------------------------------------------

initComponents()
initGUI()
initItems()

mainContainer:drawOnScreen(true)
mainContainer:startEventHandling()