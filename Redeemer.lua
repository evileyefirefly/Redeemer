--SavedVariables: RedeemernoTargetQuotes, RedeemerhunterQuotes, RedeemercombatQuotes, RedeemerwarlockQuotes, RedeemerselfQuotes, RedeemerengineerQuotes, RedeemerghoulQuotes, RedeemernoghoulQuotes, RedeemermassQuotes, RedeemerotherQuotes, RedeemerCurrentVersion
--SavedVariablesPerCharacter: RedeemerDisplaySay, RedeemerDisplayParty, RedeemerDisplayRaid, RedeemerDisplayWhisper

--The "RedeemerxxQuotes" variables store the user's copies of the quotes for
--each spell. "xxQuotes" variables, without the Redeemer prefix, refer to the
--default quote lists in the "RedeemerQuotes.lua" file.
--"RedeemerxxQuotesTemp" variables are used in the UIPanel to allow users to
--cancel changes to quotes.

--Master version number listing. Should be consistent with what the download site listed.
REDEEMER_CURRENT_VERSION = GetAddOnMetadata("Redeemer", "Version")
QUOTELIST_NAMES = {
    'noTargetQuotes',
    'hunterQuotes',
    'combatQuotes',
    'warlockQuotes',
    'selfQuotes',
    'engineerQuotes',
    'ghoulQuotes',
    'noghoulQuotes',
    'massQuotes',
    'otherQuotes',
};
--text color constants
REDEEMER_C_ON = "|cff00ff00"
REDEEMER_C_OFF = "|cffff0000"
REDEEMER_C_WHITE = "|cffffffff"
REDEEMER_C_DEFAULT_RED = 0.25
REDEEMER_C_DEFAULT_GREEN = 0.88
REDEEMER_C_DEFAULT_BLUE = 0.88

REDEEMER_LOADED = false
    --set to true when ADDON_LOADED fired, remains true thereafter
REDEEMER_TEMP = false

function Redeemer_Print(text)
    --prints a message with default colors
    DEFAULT_CHAT_FRAME:AddMessage(text, REDEEMER_C_DEFAULT_RED, REDEEMER_C_DEFAULT_GREEN, REDEEMER_C_DEFAULT_BLUE)
end

--returns quote list var
function Redeemer_GetQuoteList(name)
    return _G['Redeemer'..name];
end

--returns temporary quote list var
function Redeemer_GetTempQuoteList(name)
    return _G['Redeemer'..name..'Temp'];
end

function Redeemer_OnLoad(self)

    self:RegisterEvent("ADDON_LOADED");
    self:RegisterEvent("UNIT_SPELLCAST_SENT");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    self:RegisterEvent("PLAYER_DEAD");
    self:RegisterEvent("PLAYER_ALIVE");

    SLASH_REDEEMER1 = "/redeemer";
    SlashCmdList["REDEEMER"] = Redeemer_SlashOpts;
end

function Redeemer_GetDefaultQuotes(category)
    --takes the name of an xxQuotes variable found in the RedeemerQuotes.lua
    --file, as a string
    return _G[category];
end

function Redeemer_OnEvent(self, event, ...)

    if (event == "ADDON_LOADED") then
        local addon = select(1, ...);
        if (addon == "Redeemer") then
            REDEEMER_LOADED = true;
            --if quote variables are nil, load defaults
            for i, name in ipairs(QUOTELIST_NAMES) do
                if (_G["Redeemer"..name] == nil) then
                    _G["Redeemer"..name] = Redeemer_GetDefaultQuotes(name);
                    Redeemer_Print("Default quotes imported: "..REDEEMER_C_WHITE..""..name)
                end
            end
            if (RedeemerCurrentVersion == nil) then --probably a first-time installation
                RedeemerCurrentVersion = REDEEMER_CURRENT_VERSION;
                Redeemer_Print("Redeemer version "..REDEEMER_C_WHITE..""..RedeemerCurrentVersion)
            end
            Redeemer_Print("Redeemer is locked and loaded!")
            --if an option setting is not found, set it to default
            if (RedeemerDisplaySay == nil) then
                Redeemer_Print("Redeemer /say option default  set "..REDEEMER_C_WHITE.."["..REDEEMER_C_ON.."on"..REDEEMER_C_WHITE.."]")
                RedeemerDisplaySay = true;
            end
            if (RedeemerDisplayParty == nil) then
                Redeemer_Print("Redeemer /party option default set "..REDEEMER_C_WHITE.."["..REDEEMER_C_OFF.."off"..REDEEMER_C_WHITE.."]")
                RedeemerDisplayParty = false;
            end
            if (RedeemerDisplayRaid == nil) then
                Redeemer_Print("Redeemer /raid option default set "..REDEEMER_C_WHITE.."["..REDEEMER_C_OFF.."off"..REDEEMER_C_WHITE.."]")
                RedeemerDisplayRaid = false;
            end
            if (RedeemerDisplayWhisper == nil) then
                Redeemer_Print("Redeemer /whisper option default set "..REDEEMER_C_WHITE.."["..REDEEMER_C_OFF.."off"..REDEEMER_C_WHITE.."]")
                RedeemerDisplayWhisper = false;
            end
        end
    end

    if (event == "UNIT_SPELLCAST_SENT") then
        local unitID, target, _, spellID = ...;
        --arg3, rank, was deprecated in 4.0
        --[[
        DEFAULT_CHAT_FRAME:AddMessage(tostring(event));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(unitID));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(spellID));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(target));
        ]]--
        if (unitID == "player") then
            if (spellID == 7328) then
                Redeemer_Quotes("Paladin", target);
            elseif (spellID == 2006) then
                Redeemer_Quotes("Priest", target);
            elseif (spellID == 2008) then
                Redeemer_Quotes("Shaman", target);
            elseif (spellID == 50769) then
                Redeemer_Quotes("Druid", target);
            elseif (spellID == 115178) then
                Redeemer_Quotes("Monk", target);
            elseif (spellID == 982) then
                Redeemer_Quotes("Hunter", "");
            elseif (spellID == 20484) then
                Redeemer_Quotes("Combat", target);
            elseif (spellID == 54732) then
                Redeemer_Quotes("Engineer", target);
            elseif (spellID == 46584) then
                Redeemer_Quotes("DeathKnightDead", target);
            elseif (spellID == 61999) then
                Redeemer_Quotes("DeathKnightAlly", target)
            elseif (spellID == 95750) then
                Redeemer_Quotes("Warlock", target);
            elseif (spellID == 212051) then
                Redeemer_Quotes("Mass", "");
            elseif (spellID == 212040) then
                Redeemer_Quotes("Mass", "");
            elseif (spellID == 212056) then
                Redeemer_Quotes("Mass", "");
            elseif (spellID == 212036) then
                Redeemer_Quotes("Mass", "");
            elseif (spellID == 212048) then
                Redeemer_Quotes("Mass", "");
            end
        end
    end

    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local _, event_name, _, _, _, _, _, _, destName, destFlags, _ = ...;
        --[[
        DEFAULT_CHAT_FRAME:AddMessage(tostring(event));
        DEFAULT_CHAT_FRAME:AddMessage(string.format("0x%x",tostring(timestamp)));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(event_name));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(hideCaster));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(sourceGUID));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(sourceName));
        DEFAULT_CHAT_FRAME:AddMessage(string.format("0x%x",tostring(sourceFlags)));
        DEFAULT_CHAT_FRAME:AddMessage(string.format("0x%x",tostring(sourceRaidFlags)));
        DEFAULT_CHAT_FRAME:AddMessage(string.format("0x%x",tostring(destGUID)));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(destName));
        DEFAULT_CHAT_FRAME:AddMessage(string.format("0x%x",tostring(destFlags)));
        DEFAULT_CHAT_FRAME:AddMessage(tostring(destRaidFlags));
        ]]--
        --if pet dies, gets pet's name
        if (event_name == "UNIT_DIED") then
            if (destFlags == 0x1111) then
                PET_NAME = destName;
            end
        end
    end

    if (event == "PLAYER_DEAD") then
        if (HasSoulstone()) then
            RedeemerHasSoulstone = true;
        end
    end

    if (event == "PLAYER_ALIVE") then
        if (RedeemerHasSoulstone) then
            RedeemerHasSoulstone = false;
            Redeemer_Quotes("Self", "self");
        end
    end

end


function Redeemer_Quotes(playerClass, target)

    --DEFAULT_CHAT_FRAME:AddMessage("Redeemer called: " .. playerClass .. target);
    --SendChatMessage("Redeemer called!");
    local chatMessage;
    local quoteSource;
    if (string.upper(target) == "UNKNOWN") then
        quoteSource = RedeemernoTargetQuotes;
    elseif (playerClass == "Mass") then
        quoteSource = RedeemermassQuotes;
    elseif (playerClass == "Hunter") then
        quoteSource = RedeemerhunterQuotes;
    elseif (playerClass == "Combat") then
        quoteSource = RedeemercombatQuotes;
    elseif (playerClass == "Engineer") then
        quoteSource = RedeemerengineerQuotes
    elseif (playerClass == "Warlock") then
        quoteSource = RedeemerwarlockQuotes;
    elseif (playerClass == "Self") then
        quoteSource = RedeemerselfQuotes;
    elseif (playerClass == "DeathKnightDead") then
        quoteSource = RedeemernoghoulQuotes;
    elseif (playerClass == "DeathKnightAlly") then
        quoteSource = RedeemerghoulQuotes;
    else
        quoteSource = RedeemerotherQuotes;
    end
    if (#(quoteSource) > 0) then    --preventing Lua errors for empty quote categories
        chatMessage = quoteSource[random(#(quoteSource))];

        chatMessage = string.gsub(chatMessage, "%%t", target);

        Redeemer_SendQuotes(chatMessage, target);
    end
    --quote = quote + 1;

end

function Redeemer_SendQuotes(chatMessage, target)

    if (RedeemerDisplayRaid and UnitInRaid("player")) then
        SendChatMessage(chatMessage, "RAID");
    elseif (RedeemerDisplayParty and GetNumSubgroupMembers() > 0) then
        --Send to instance chat if in LFG group; party chat otherwise
        if ( HasLFGRestrictions() ) then
            SendChatMessage(chatMessage, "INSTANCE_CHAT");
        else
            SendChatMessage(chatMessage, "PARTY");
        end
    elseif (RedeemerDisplaySay and IsInGroup()) then
        SendChatMessage(chatMessage, "SAY");
	else
		SendChatMessage(chatMessage, "WHISPER", nil, UnitName("Player"))
    end

    if (RedeemerDisplayWhisper and string.upper(target) ~= "UNKNOWN" and target ~= "") then
        SendChatMessage(chatMessage, "WHISPER", nil, target);
    end

end

function Redeemer_SlashOpts(cmd)

    cmd = string.lower(cmd);

    if (cmd == "say") then
        RedeemerDisplaySay = not RedeemerDisplaySay;
        sayText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplaySay) then
            sayText = sayText..""..REDEEMER_C_ON.."on";
        else
            sayText = sayText..""..REDEEMER_C_OFF.."off";
        end
        sayText = sayText..""..REDEEMER_C_WHITE.."]";
        Redeemer_Print("Quotes sent to /say toggled "..sayText)

    elseif (cmd == "party") then
        RedeemerDisplayParty = not RedeemerDisplayParty;
        partyText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplayParty) then
            partyText = partyText..""..REDEEMER_C_ON.."on";
        else
            partyText = partyText..""..REDEEMER_C_OFF.."off";
        end
        partyText = partyText..""..REDEEMER_C_WHITE.."]";
        Redeemer_Print("Quotes sent to /party toggled "..partyText)

    elseif (cmd == "raid") then
        RedeemerDisplayRaid = not RedeemerDisplayRaid;
        raidText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplayRaid) then
            raidText = raidText..""..REDEEMER_C_ON.."on";
        else
            raidText = raidText..""..REDEEMER_C_OFF.."off";
        end
        raidText = raidText..""..REDEEMER_C_WHITE.."]";
        Redeemer_Print("Quotes sent to /raid toggled "..raidText)

    elseif (cmd == "whisper") then
        RedeemerDisplayWhisper = not RedeemerDisplayWhisper;
        whisperText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplayWhisper) then
            whisperText = whisperText..""..REDEEMER_C_ON.."on";
        else
            whisperText = whisperText..""..REDEEMER_C_OFF.."off";
        end
        whisperText = whisperText..""..REDEEMER_C_WHITE.."]";
        Redeemer_Print("Quotes whispered to target toggled "..whisperText)

    else
        sayText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplaySay) then
            sayText = sayText..""..REDEEMER_C_ON.."on";
        else
            sayText = sayText..""..REDEEMER_C_OFF.."off";
        end
        sayText = sayText..""..REDEEMER_C_WHITE.."]";
        partyText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplayParty) then
            partyText = partyText..""..REDEEMER_C_ON.."on";
        else
            partyText = partyText..""..REDEEMER_C_OFF.."off";
        end
        partyText = partyText..""..REDEEMER_C_WHITE.."]";
        raidText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplayRaid) then
            raidText = raidText..""..REDEEMER_C_ON.."on";
        else
            raidText = raidText..""..REDEEMER_C_OFF.."off";
        end
        raidText = raidText..""..REDEEMER_C_WHITE.."]";
        whisperText = ""..REDEEMER_C_WHITE.."[";
        if (RedeemerDisplayWhisper) then
            whisperText = whisperText..""..REDEEMER_C_ON.."on";
        else
            whisperText = whisperText..""..REDEEMER_C_OFF.."off";
        end
        whisperText = whisperText..""..REDEEMER_C_WHITE.."]";
        Redeemer_Print("/redeemer say: Toggle sending quotes to /say "..sayText)
        Redeemer_Print("/redeemer party: Toggle sending quotes to /party "..partyText)
        Redeemer_Print("/redeemer raid: Toggle sending quotes to /raid "..raidText)
        Redeemer_Print("/redeemer whisper: Toggle whispering quotes to target "..whisperText)
    end
    RedeemerUIPanel_Update();
    --DEFAULT_CHAT_FRAME:AddMessage("Command: "..cmd);

end

--Interface Options Panel functions
function RedeemerUIPanel_Update()
    RedeemerUIPanelDisplayOptionsSay:SetChecked(_G["RedeemerDisplaySay"]);
    RedeemerUIPanelDisplayOptionsParty:SetChecked(_G["RedeemerDisplayParty"]);
    RedeemerUIPanelDisplayOptionsRaid:SetChecked(_G["RedeemerDisplayRaid"]);
    RedeemerUIPanelDisplayOptionsWhisper:SetChecked(_G["RedeemerDisplayWhisper"]);

    QuoteButtonText_Update(TypeDropDown_CurrentValue, QuoteList_CurrentStartIndex);
end

function RedeemerUIPanelOnLoad(panel)
    panel.name = "Redeemer "..REDEEMER_CURRENT_VERSION;
    panel.refresh = function(self) RedeemerUIPanel_Update(); end;
    panel.okay = function(self) RedeemerUIPanel_Okay(); end;
    panel.cancel = function(self) RedeemerUIPanel_Cancel(); end;
    panel.default = function(self) RedeemerUIPanel_Default(); end;
    InterfaceOptions_AddCategory(panel);
end

function RedeemerUIPanel_Default()
    RedeemerDisplaySay = true;
    RedeemerDisplayParty = false;
    RedeemerDisplayRaid = false;
    RedeemerDisplayWhisper = false;

    TypeDropDown_CurrentValue = 1;
    QuoteList_CurrentStartIndex = 1;
    QuoteList_SelectedItem = nil;
    QuoteButton_Select(nil);

    if not REDEEMER_TEMP then
        RedeemerUIPanel_InitTempVars();
    end
    --set all Quote Lists to RedeemerQuotes.lua defaults
    for i, name in ipairs(QUOTELIST_NAMES) do
        _G['Redeemer'..name..'Temp'] = _G[name];
    end

    RedeemerUIPanel_Update();
end

function RedeemerUIPanel_Okay()
    if not REDEEMER_TEMP then
        RedeemerUIPanel_InitTempVars();
    end
    RedeemerDisplaySay = Redeemer_YesOrNo(RedeemerUIPanelDisplayOptionsSay);
    RedeemerDisplayParty = Redeemer_YesOrNo(RedeemerUIPanelDisplayOptionsParty);
    RedeemerDisplayRaid = Redeemer_YesOrNo(RedeemerUIPanelDisplayOptionsRaid);
    RedeemerDisplayWhisper = Redeemer_YesOrNo(RedeemerUIPanelDisplayOptionsWhisper);

    TypeDropDown_CurrentValue = 1;
    QuoteList_CurrentStartIndex = 1;
    QuoteList_SelectedItem = nil;
    QuoteButton_Select(nil);

    --commit changes to RedeemerxxxQuotes tables
    for i, name in ipairs(QUOTELIST_NAMES) do
        _G['Redeemer'..name] = _G['Redeemer'..name..'Temp'];
    end
    RedeemerUIPanel_DeleteTempVars();
end

function RedeemerUIPanel_Cancel()
    --cancel changes to RedeemerxxxQuotes tables
    RedeemerUIPanel_DeleteTempVars();
    QuoteButton_Select(nil);

    RedeemerUIPanel_Update();
end

function Redeemer_YesOrNo(checkbox)
    --checkbox:GetChecked() returns 1 or nil, which isn't quite what I want
    if (checkbox:GetChecked() == nil) then
        return false;
    else
        return true;
    end
end

--Temp vars allow UI Panel Cancel button to work
function RedeemerUIPanel_InitTempVars()
    if REDEEMER_LOADED then
        for i, name in ipairs(QUOTELIST_NAMES) do
            local quoteList = _G['Redeemer'..name];
            _G['Redeemer'..name..'Temp'] = {};
            local tempList  = _G['Redeemer'..name..'Temp'];
            for j, quote in ipairs(quoteList) do
                table.insert(tempList, j, quote);
            end
        end
        REDEEMER_TEMP = true;
    end
end

function RedeemerUIPanel_DeleteTempVars()
    for i, name in ipairs(QUOTELIST_NAMES) do
        _G['Redeemer'..name..'Temp'] = nil;
    end
    REDEEMER_TEMP = false;
end

--TypeDropDown handling starts
TypeDropDown_CurrentValue = 1;    --tracks currently active quote type
QuoteList_CurrentStartIndex = 1;  --tracks first index of currently shown quotes
QuoteList_SelectedItem = nil;     --tracks selected quote (current start index + button offset)
QuoteButton_SelectedButton = nil; --tracks selected button for highlighting
                                  --use QuoteButton_Select(nil) to unselect

function RedeemerUIPanelQuoteOptionsTypeDropDown_Menu(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo();
    info.func = RedeemerUIPanelQuoteOptionsTypeDropDown_OnClick;
    for k, v in ipairs(QUOTELIST_NAMES) do
        info.text = v;
        info.arg1 = v;
        info.arg2 = k;
        info.checked = k == TypeDropDown_CurrentValue;
        UIDropDownMenu_AddButton(info)
    end
end

function RedeemerUIPanelQuoteOptionsTypeDropDown_OnClick(self, arg1, arg2, checked)
    UIDropDownMenu_SetText(RedeemerUIPanelQuoteOptionsTypeDropDown, QUOTELIST_NAMES[arg2]);
    TypeDropDown_CurrentValue = arg2;
    QuoteButtonText_Update(TypeDropDown_CurrentValue, 1);
    QuoteButton_Select(nil);
end
--TypeDropDown handling ends

--QuoteButton handling starts
function MakeQuoteButtons(frame)
    for i = 1,10 do
        button = CreateFrame("Button", "QuoteButton"..i, frame, "QuoteButton", i);
        local relFrame = "QuoteButton"..(i-1);
        if i==1 then
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -4);
            button:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 5, -23);
        else
            button:SetPoint("TOPLEFT", relFrame, "BOTTOMLEFT", 0, -1);
            button:SetPoint("BOTTOMRIGHT", relFrame, "BOTTOMRIGHT", 0, -23);
        end
        button:Show();
    end
    QuoteList_CurrentStartIndex = 1;
    QuoteButton_Select(nil);
end

--quoteType is a QUOTELIST_NAMES index number
--startIndex is the starting index, to be used for scrolling
function QuoteButtonText_Update(quoteType, startIndex)
    if not REDEEMER_LOADED then
        return
    end
    if not REDEEMER_TEMP then
        RedeemerUIPanel_InitTempVars();
    end
    local maxLength = 85
    local quotes = Redeemer_GetTempQuoteList(QUOTELIST_NAMES[quoteType]);
    QuoteList_CurrentStartIndex = startIndex;
    for i = 0,9 do
        button = _G["QuoteButton"..(i+1)];
        button:Enable();
        if quotes[startIndex+i] == nil then
            button:SetText("");
            button:Disable();
        elseif string.len(quotes[startIndex+i]) > maxLength then
            button:SetText(startIndex+i..". "..string.sub(quotes[startIndex+i], 1, maxLength).."...");
        else
            button:SetText(startIndex+i..". "..quotes[startIndex+i]);
        end
    end
    QuoteListRange_Update(quoteType, startIndex);
end

function RedeemerUIPanelQuoteOptionsPrevious_OnClick()
    if QuoteList_CurrentStartIndex-10 > 1 then
        QuoteButtonText_Update(TypeDropDown_CurrentValue, QuoteList_CurrentStartIndex-10);
    else
        QuoteButtonText_Update(TypeDropDown_CurrentValue, 1);
    end
    QuoteButton_Select(nil);
end

function RedeemerUIPanelQuoteOptionsNext_OnClick()
    if QuoteList_CurrentStartIndex+10 <= #(Redeemer_GetTempQuoteList(QUOTELIST_NAMES[TypeDropDown_CurrentValue])) then
        QuoteButtonText_Update(TypeDropDown_CurrentValue, QuoteList_CurrentStartIndex+10);
    end
    QuoteButton_Select(nil);
end

function QuoteListRange_Update(quoteType, startIndex)
    local numQuotes = #(Redeemer_GetTempQuoteList(QUOTELIST_NAMES[quoteType]));
    local finalIndex = startIndex+9;
    if startIndex < 1 then
        startIndex = 1;
    end
    if startIndex+9 > numQuotes then
        finalIndex = numQuotes;
    end
    if RedeemerUIPanelQuoteOptionsRangeText then
        RedeemerUIPanelQuoteOptionsRangeText:SetText(startIndex.."-"..finalIndex.." of "..numQuotes);
    end
end

StaticPopupDialogs["REDEEMER_ADD_EDIT"] = {
    text= "Enter the quote:",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnShow = function (self, data, data2)
        if not REDEEMER_TEMP then
            RedeemerUIPanel_InitTempVars();
        end
        local selectedQuote;
        if QuoteList_SelectedItem then
            selectedQuote = Redeemer_GetTempQuoteList(QUOTELIST_NAMES[TypeDropDown_CurrentValue])[QuoteList_SelectedItem];
        else
            selectedQuote = ""
        end
        self.editBox:SetText(selectedQuote);
        --selectedQuote should be "" when adding a new quote
    end,
    hasEditBox = true,
    --data and data2 should be the quoteType and quoteIndex respectively
    OnAccept = function (self, data, data2)
        ChangeQuote(self, data, data2, self.editBox:GetText());
    end,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    timeout = 0,
}

--should only be called from REDEEMER_ADD_EDIT pop-up accept function
function ChangeQuote(popup, quoteType, quoteIndex, newQuote)
    if not REDEEMER_TEMP then
        RedeemerUIPanel_InitTempVars();
    end
    local quoteList = Redeemer_GetTempQuoteList(QUOTELIST_NAMES[quoteType]);
    if quoteIndex > #(quoteList) then
        table.insert(quoteList, quoteIndex, newQuote);
    else
        quoteList[quoteIndex] = newQuote;
    end
    if quoteType == TypeDropDown_CurrentValue then
        local startIndex = quoteIndex-(quoteIndex-1)%10
        --startIndex should be 1, 11, 21, 31, etc.
        local button = quoteIndex % 10;
        if button == 0 then
            button = 10;
        end
        QuoteButtonText_Update(quoteType, startIndex);
        QuoteButton_Select(_G["QuoteButton"..button]);
    end
end

function QuoteButton_Select(button)
    if QuoteButton_SelectedButton then
        QuoteButton_SelectedButton:UnlockHighlight();
    end
    QuoteButton_SelectedButton = nil;
    QuoteList_SelectedItem = nil;
    RedeemerUIPanelQuoteOptionsEdit:Disable();
    RedeemerUIPanelQuoteOptionsDelete:Disable();
    if button then
        button:LockHighlight();
        QuoteList_SelectedItem = QuoteList_CurrentStartIndex+(button:GetID()-1);
        QuoteButton_SelectedButton = button;
        RedeemerUIPanelQuoteOptionsEdit:Enable();
        RedeemerUIPanelQuoteOptionsDelete:Enable();
    end
end

function RedeemerEditQuote_OnClick()
    if QuoteList_SelectedItem then
        local popup = StaticPopup_Show("REDEEMER_ADD_EDIT");
        if popup then
            popup.data = TypeDropDown_CurrentValue;
            popup.data2 = QuoteList_SelectedItem
        end
    end
end

function RedeemerDeleteQuote_OnClick()
    if QuoteList_SelectedItem then
        if not REDEEMER_TEMP then
            RedeemerUIPanel_InitTempVars();
        end
        local currentList = Redeemer_GetTempQuoteList(QUOTELIST_NAMES[TypeDropDown_CurrentValue]);
        table.remove(currentList, QuoteList_SelectedItem);
        local startIndex;
        if QuoteList_CurrentStartIndex > #(currentList) then
            startIndex = #(currentList)-9;
        else
            startIndex = QuoteList_CurrentStartIndex;
        end
        QuoteButtonText_Update(TypeDropDown_CurrentValue, startIndex)
    end
end

function RedeemerAddQuote_OnClick()
    if not REDEEMER_TEMP then
        RedeemerUIPanel_InitTempVars();
    end
    local currentList = Redeemer_GetTempQuoteList(QUOTELIST_NAMES[TypeDropDown_CurrentValue]);
    QuoteList_SelectedItem = nil;
    local popup = StaticPopup_Show("REDEEMER_ADD_EDIT");
    if popup then
        popup.data = TypeDropDown_CurrentValue;
        popup.data2 = #(currentList)+1;
    end
end
