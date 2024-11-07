print("Pizza shit ghost imp catcher script.")

local API = require("api")
local var1 = 0
local var2 = 0
local worldlist = {1, 2, 4, 5, 6, 9, 10, 12, 14, 15, 16, 21, 22, 23, 24, 25, 26, 27, 30, 31, 32, 35, 37, 39, 40, 42, 44,
                   45, 46, 47, 49, 50, 51, 52, 53, 54, 56, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73,
                   74, 75, 76, 77, 79, 82, 83, 84, 85, 87, 88, 89, 91, 92, 96, 97, 98, 99, 100, 104, 116, 117, 118, 119,
                   121, 123, 124, 134, 138, 139}
local currentIndex = 1
local lastIteratedWorldIndex = 1
local maxIterationsPerFrame = 1
local shouldBreak = false

local function findNPC(npcid, distance)
    local distance = distance or 10
    local npcCount = #API.GetAllObjArrayInteract({npcid}, distance, {1})
    print("Found " .. npcCount .. " NPCs with ID " .. npcid .. " within " .. distance .. " distance")
    return npcCount > 0
end

local function WorldHopAndDoAction(world)
    print("Attempting to hop to world " .. world)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1431, 0, 7, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(3200, 1500, 1200)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 1433, 65, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(3200, 1500, 1200)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 2, 1587, 8, world, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(10000, 2500, 1800)
    print("World hop complete")
end

-- main loop
while API.Read_LoopyLoop() do
    if shouldBreak then
        print("Breaking main loop")
        break
    end
    local gameState = API.GetGameState2()
    if (gameState == 3) then
        if findNPC(30175, 125) then
            API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, {30175}, 125)
            API.RandomSleep2(1800, 2000, 1600)
            API.WaitUntilMovingEnds()
            API.RandomSleep2(1800, 2000, 1600)

            local interactionTimeout = os.time() + 60 
            while API.CheckAnim(60) and os.time() < interactionTimeout do
                print("Waiting for interaction animation to complete")
                API.RandomSleep2(1800, 2000, 1600)
                if not API.Read_LoopyLoop() then
                    print("LoopyLoop ended, breaking interaction wait")
                    break
                end
            end
            print("Imp found, stopping the script")
            API.Write_LoopyLoop(false)
        else
            if not findNPC(30175, 125) then
                print("Imp not found after exploration, considering world hop")
                if currentIndex <= #worldlist then
                    if currentIndex == lastIteratedWorldIndex then
                        currentIndex = currentIndex + 1
                        if currentIndex > #worldlist then
                            currentIndex = 1 
                            print("Resetting to first world in list")
                        end
                    end

                    local world = worldlist[currentIndex]
                    WorldHopAndDoAction(world)
                    print("Hopped to world #: " .. world)
                    lastIteratedWorldIndex = currentIndex
                    currentIndex = currentIndex + 1
                else
                    print("Reached end of world list, resetting")
                    currentIndex = 1
                end
            else
                print("Imp found, attempting to interact")
                API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, {30175}, 125)
                API.RandomSleep2(1800, 2000, 1600)
                API.WaitUntilMovingEnds()
                API.RandomSleep2(1800, 2000, 1600)

                local interactionTimeout = os.time() + 60
                while API.CheckAnim(60) and os.time() < interactionTimeout do
                    print("Waiting for interaction animation to complete")
                    API.RandomSleep2(1800, 2000, 1600)
                    if not API.Read_LoopyLoop() then
                        print("LoopyLoop ended, breaking interaction wait")
                        break
                    end
                end
                print("Imp found, stopping the script")
                API.Write_LoopyLoop(false)
            end
        end
    else
        print("Not in game. Attempting to log in...")
        API.RandomSleep2(4800, 2000, 2600)
    end

    API.RandomSleep2(1000, 0, 400) -- Small delay between iterations to prevent excessive CPU usage
end
