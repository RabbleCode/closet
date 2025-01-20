closet = {};

closet.MountedSetName = 'Mounted'
closet.DismountedSetName = 'Dismounted'

function closet:OnLoad()
    SLASH_CLOSET_SAVESET1 = "/saveset";
    SLASH_CLOSET_DELETESET1 = "/deleteset";
    SLASH_CLOSET_DELETESET2 = "/delset";
    SLASH_CLOSET_LISTSETS1 = "/listsets";
	SlashCmdList["CLOSET_SAVESET"] = function(setName) closet:SaveSet(setName) end
    SlashCmdList["CLOSET_DELETESET"] = function(setName) closet:DeleteSet(setName) end
    SlashCmdList["CLOSET_LISTSETS"] = function() closet:ListSets() end

	closetFrame:RegisterEvent("PLAYER_LOGIN")
	closetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	closetFrame:RegisterEvent("ADDON_LOADED")
    closetFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
    closetFrame:RegisterEvent("EQUIPMENT_SWAP_PENDING")
    closetFrame:RegisterEvent("UNIT_AURA")
end

function closet:OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if event == "ADDON_LOADED" and arg1 == "closet" then
		closetFrame:UnregisterEvent("ADDON_LOADED");
	elseif event == "PLAYER_LOGIN" then
		closetFrame:UnregisterEvent("PLAYER_LOGIN");
		closet:Announce();
        closet.WasMounted = IsMounted() and not UnitOnTaxi("player")
        closet.PreviousSet = closet:GetEquippedSetName()
	elseif event == "PLAYER_ENTERING_WORLD" then
		closetFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
    elseif event == "EQUIPMENT_SWAP_FINISHED" then-- or event == "EQUIPMENT_SWAP_PENDING" then
        closet:AnnounceSetSwap(arg1, arg2)
    elseif event == "UNIT_AURA" and arg1 == "player" then
        closet:SwapMountSets()
    end
end

function closet:Announce()
    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    if(numSets > 1) then
        closet:PrintMessageWithClosetPrefix("activated. "..numSets.." sets found.");
    elseif(numSets == 1) then
        closet:PrintMessageWithClosetPrefix("activated. "..numSets.." set found.");
    else
	    closet:PrintMessageWithClosetPrefix("activated. No sets found.");
    end
end

function closet:PrintMessageWithClosetPrefix(message)
    closet:PrintMessage(YELLOW_FONT_COLOR_CODE.."CLOSET|r | "..message)
end
    
function closet:PrintMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

function closet:SetExists(setName)    
    return C_EquipmentSet.GetEquipmentSetID(setName) ~= nil
end

function closet:GetEquippedSetName()
    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    if(numSets > 0) then

        for _,id in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do 
            local name, _, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(id)
            if(equipped) then
                return name
            end
        end        
    end

    -- No set found
    return nil 
end

function closet:EquipSet(setName)
    if setName ~= nil and setName ~= "" then        
        local setID = C_EquipmentSet.GetEquipmentSetID(setName)
        if(setID ~= nil) then
            C_EquipmentSet.UseEquipmentSet(setID);
        else            
            closet:PrintMessage(RED_FONT_COLOR_CODE.."Equip set failed|r. Set \""..setName.."\" does not exist")
        end
    else
        closet:PrintMessage(RED_FONT_COLOR_CODE.."Equip set failed|r - No set name provided")
    end
end

function closet:SaveSet(setName)
    if setName ~= nil and setName ~= "" then
        local setID = C_EquipmentSet.GetEquipmentSetID(setName)
        if(setID == nil) then
            C_EquipmentSet.CreateEquipmentSet(setName)
            closet:PrintMessage(GREEN_FONT_COLOR_CODE.."Created set|r "..setName)
        else 
            C_EquipmentSet.SaveEquipmentSet(setID)
            closet:PrintMessage(GREEN_FONT_COLOR_CODE.."Saved set|r "..setName)
        end
     else
         closet:PrintMessage(RED_FONT_COLOR_CODE.."Save set failed|r - No set name provided")
     end
end

function closet:DeleteSet(setName)
    if setName ~= nil and setName ~= "" then    
        local setID = C_EquipmentSet.GetEquipmentSetID(setName)
        if(setID ~= nil) then
            C_EquipmentSet.DeleteEquipmentSet(setID)
            closet:PrintMessage(GREEN_FONT_COLOR_CODE.."Deleted set|r "..setName)
        else
            closet:PrintMessage(RED_FONT_COLOR_CODE.."Delete set failed|r - Set "..setName.." does not exist")
        end
    else
        closet:PrintMessage(RED_FONT_COLOR_CODE.."Delete set failed|r - No set name provided")
    end
end

function closet:ListSets() 
    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    if(numSets > 0) then
        closet:PrintMessage("Listing all sets...")
        
        for _,id in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do 
            local name = C_EquipmentSet.GetEquipmentSetInfo(id)
            closet:PrintMessage("  "..name)
        end
    else
        closet:PrintMessage("This character has no sets.")
    end
end

function closet:AnnounceSetSwap(success, setID)
    if(success and setID ~= nil) then        
        local name = C_EquipmentSet.GetEquipmentSetInfo(setID)
        closet:PrintMessage(GREEN_FONT_COLOR_CODE.."Equipped set|r "..name)
        if(name ~= closet.MountedSetName) then
            closet.PreviousSet = name -- If we're not equipping our mount set, save our current set as previous set
        end
    else
        closet:PrintMessage(RED_FONT_COLOR_CODE.."Equip set failed|r")
    end
end

function closet:SwapMountSets()
    local isMounted = IsMounted() and not UnitOnTaxi("player")
    -- Player is Dismounting
    if(closet.WasMounted and not isMounted) then
        if(closet:SetExists(closet.PreviousSet)) then
            closet:EquipSet(closet.PreviousSet) -- Re-equip what the character was wearing before mounting        
        end
        closet.WasMounted = isMounted;
    -- Player is Mounting
    elseif(not closet.WasMounted and isMounted) then
        if(closet:SetExists(closet.MountedSetName)) then
            closet:EquipSet(closet.MountedSetName); -- Equip saved mount set (if it exists)
        else
            closet:PrintMessage(RED_FONT_COLOR_CODE..'Equip set failed|r - Set \"'..closet.MountedSetName..'\" does not exist. Please create a new set with /saveset '..closet.MountedSetName)
        end
        closet.WasMounted = isMounted;
    end
end