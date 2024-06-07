closet = {};

function closet:OnLoad()
    SLASH_CLOSET_SAVESET1 = "/saveset";
    SLASH_CLOSET_DELETESET1 = "/deleteset";
    SLASH_CLOSET_DELETESET2 = "/delset";
    SLASH_CLOSET_LISTSETS1 = "/listsets";
	SlashCmdList["CLOSET_SAVESET"] = function(setName) closet:HandleSaveSet(setName) end
    SlashCmdList["CLOSET_DELETESET"] = function(setName) closet:HandleDeleteSet(setName) end
    SlashCmdList["CLOSET_LISTSETS"] = function() closet:HandleListSets() end

	closetFrame:RegisterEvent("PLAYER_LOGIN")
	closetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	closetFrame:RegisterEvent("ADDON_LOADED")
    closetFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
    closetFrame:RegisterEvent("EQUIPMENT_SWAP_PENDING")
end

function closet:OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if event == "ADDON_LOADED" and arg1 == "closet" then
		closetFrame:UnregisterEvent("ADDON_LOADED");
	elseif event == "PLAYER_LOGIN" then
		closetFrame:UnregisterEvent("PLAYER_LOGIN");
		closet:Announce();		
	elseif event == "PLAYER_ENTERING_WORLD" then
		closetFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
    elseif event == "EQUIPMENT_SWAP_FINISHED" then-- or event == "EQUIPMENT_SWAP_PENDING" then
        closet:HandleSetSwap(arg1, arg2)
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

function closet:HandleSaveSet(setName)
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

function closet:HandleDeleteSet(setName)
    if setName ~= nil and setName ~= "" then    
        local setID = C_EquipmentSet.GetEquipmentSetID(setName)
        if(setID ~= nil) then
            C_EquipmentSet.DeleteEquipmentSet(setID)
            closet:PrintMessage(GREEN_FONT_COLOR_CODE.."Deleted set|r "..setName)
        else
            closet:PrintMessage(RED_FONT_COLOR_CODE.."Delete set failed|r - No set found named "..setName)
        end
    else
        closet:PrintMessage(RED_FONT_COLOR_CODE.."Delete set failed|r - No set name provided")
    end
end

function closet:HandleListSets() 
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

function closet:HandleSetSwap(success, setID)
    if(success and setID ~= nil) then        
        local name = C_EquipmentSet.GetEquipmentSetInfo(setID)
        closet:PrintMessage(GREEN_FONT_COLOR_CODE.."Equipped set|r "..name)
    else
        closet:PrintMessage(RED_FONT_COLOR_CODE.."Equip set failed|r")
    end
end