-- WarlockCore v1.4.9
-- Class Lock: Addon will only load if player is a WARLOCK.

local _, class = UnitClass("player")
if class ~= "WARLOCK" then return end

local iconUpdateTick = 0
local dragIconTex, dragPetIconTex
local lastPetAttack, lastPetTargetName = 0, ""
local myDots = {}

local buffTextures = {
    ["Demon Armor"] = "Interface\\Icons\\Spell_Shadow_RagingScream",
    ["Demon Skin"] = "Interface\\Icons\\Spell_Shadow_DemonSkin"
}
local petIcons = {
    ["Imp"] = "Spell_Shadow_SummonImp",
    ["Voidwalker"] = "Spell_Shadow_SummonVoidwalker",
    ["Succubus"] = "Spell_Shadow_SummonSuccubus",
    ["Felhunter"] = "Spell_Shadow_SummonFelhunter"
}

local warlockSpells = { "None", "Immolate", "Corruption", "Curse of Agony", "Siphon Life", "Shadow Bolt", "Drain Life", "Drain Soul", "Death Coil", "Searing Pain", "Life Tap", "Fear" }
local warlockBuffs = { "None", "Demon Skin", "Demon Armor" }
local warlockPets = { "None", "Imp", "Voidwalker", "Succubus", "Felhunter" }

-- --- Helpers ---
local function dbg(m)
    if WarlockCore_Config and WarlockCore_Config.Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[WRC]|r " .. m)
    end
end

local function WRC_GetSpellTexture(name)
    if not name or name == "None" then return "Spell_Shadow_DeadlyBolt" end
    for i = 1, 250 do
        local n = GetSpellName(i, BOOKTYPE_SPELL); if n == name then
            local tex = GetSpellTexture(i, BOOKTYPE_SPELL); if tex then local _, _, short = string.find(tex, "([^\\/]+)$"); return short end
        end
    end
    return "Spell_Shadow_DeadlyBolt"
end

local function WRC_GetMacroIndex(name)
    local numGeneral, numChar = GetNumMacros(); for i = 1, numGeneral + numChar do local mName = GetMacroInfo(i); if mName == name then return i end end
    return 0
end

local function HasBuff(unit, spell)
    local tex = buffTextures[spell]; if not tex then return false end
    for i = 1, 32 do local bTex = UnitBuff(unit, i); if not bTex then break end; if bTex == tex then return true end end
    return false
end

local function WRC_GetRestedString()
    local xp = GetXPExhaustion() or 0; local pct = math.floor(100 * xp / UnitXPMax("player"))
    if pct >= 112 then return "MAX" else return pct .. "%" end
end

local function WRC_UseHealthstone()
    for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
            local link = GetContainerItemLink(b, s)
            if link and string.find(link, "Healthstone") then
                local _, dur = GetContainerItemCooldown(b, s)
                if dur == 0 then UseContainerItem(b, s); return true end
            end
        end
    end
    return false
end

local function GetUnitFingerprint(unit)
    if not UnitExists(unit) then return nil end
    return UnitName(unit) .. "_" .. UnitLevel(unit) .. "_" .. UnitHealthMax(unit)
end

local function HasDebuff(unit, spell)
    local tx = WRC_GetSpellTexture(spell)
    if not tx then return false end
    local texture = "interface\\icons\\" .. string.lower(tx)
    
    local exists = false
    for i = 1, 64 do 
        local dTex = UnitDebuff(unit, i)
        if not dTex then break end
        if string.lower(dTex) == texture then exists = true; break end 
    end
    
    if not exists then return false end
    
    local record = myDots[spell]
    local fp = GetUnitFingerprint(unit)
    if record and record.target == fp then
        local elapsed = GetTime() - record.time
        if record.failed then
            if elapsed < 5 then return true end -- Retry cooldown for failed overwrites
        else
            local dur = 0
            if spell == "Corruption" then dur = 18
            elseif spell == "Curse of Agony" then dur = 24
            elseif spell == "Siphon Life" then dur = 30
            elseif spell == "Immolate" then dur = 15
            elseif spell == "Drain Life" then dur = 5
            elseif spell == "Drain Soul" then dur = 15
            elseif spell == "Fear" then dur = 20
            end
            if elapsed < (dur - 1.5) then return true end
        end
    end
    return false
end

local function GetNextSpell()
    if not WarlockCore_Config then return "None" end
    if not UnitAffectingCombat("player") then return WarlockCore_Config.Opener or "None" end
    local s1, s2, s3, s4 = WarlockCore_Config.Rotation1, WarlockCore_Config.Rotation2, WarlockCore_Config.Rotation3, WarlockCore_Config.Rotation4
    local slots = { s1, s2, s3, s4 }
    for _, s in ipairs(slots) do
        if s and s ~= "None" then
            -- Smart Drain Soul: Only cast if target HP < threshold (if enabled)
            local hp = (UnitHealth("target") / UnitHealthMax("target")) * 100
            local threshold = WarlockCore_Config.DrainSoulHP or 20
            if s == "Drain Soul" and WarlockCore_Config.DrainSoulSmart and hp > threshold then
                -- skip item
            elseif s == "Immolate" or s == "Corruption" or s == "Curse of Agony" or s == "Siphon Life" or s == "Drain Life" or s == "Drain Soul" then
                if not HasDebuff("target", s) then return s end
            else return s end
        end
    end
    return "Shadow Bolt"
end

function WarlockCore_Rotate()
    if not WarlockCore_Config then return end
    
    -- 0. Emergency
    local hsHP = WarlockCore_Config.HealthstoneHP or 25
    if WarlockCore_Config.AutoHealthstone and (UnitHealth("player")/UnitHealthMax("player"))*100 < hsHP then
        if WRC_UseHealthstone() then dbg("Emergency Healthstone used!"); return end
    end

    -- 1. Buff Isolation
    if WarlockCore_Config.SelectedBuff and WarlockCore_Config.SelectedBuff ~= "None" then
        if not HasBuff("player", WarlockCore_Config.SelectedBuff) then
            dbg("Buffing: " .. WarlockCore_Config.SelectedBuff)
            CastSpellByName(WarlockCore_Config.SelectedBuff); return
        end
    end

    -- 2. Targeting
    local hadTarget = UnitExists("target")
    if WarlockCore_Config.SmartTargeting then
        if not UnitExists("target") or UnitIsDead("target") or not UnitCanAttack("player", "target") then TargetNearestEnemy() end
    end
    if not WarlockCore_Config.FastAttack and not hadTarget and UnitExists("target") then
        dbg("Target Acquired. Press again to attack."); return
    end

    -- 3. Combat
    if WarlockCore_Config.PetAssist and UnitExists("pet") and UnitExists("target") and not UnitIsDead("target") then
        if not UnitIsUnit("target", "pettarget") then
            local tName = UnitName("target")
            if tName ~= lastPetTargetName or (GetTime() - lastPetAttack > 1.5) then
                lastPetTargetName = tName; lastPetAttack = GetTime()
                PetDefensiveMode(); PetAttack()
            end
        end
    end
    local ns = GetNextSpell()
    if ns and ns ~= "None" then 
        WarlockCore_LastAttempt = ns
        CastSpellByName(ns)
        myDots[ns] = { target = GetUnitFingerprint("target"), time = GetTime() }
    end
end

function WarlockCore_Fear()
    if not WarlockCore_Config then return end
    if not UnitExists("target") or UnitIsDead("target") or not UnitCanAttack("player", "target") then return end
    
    local name = UnitName("target")
    if WarlockCore_Config.SmartFear and WarlockCore_Config.ImmuneMobs and WarlockCore_Config.ImmuneMobs[name] then
        dbg("Target is IMMUNE to Fear! Casting Shadow Bolt instead.")
        CastSpellByName("Shadow Bolt")
    else
        CastSpellByName("Fear")
    end
end

function WarlockCore_Summon()
    if not WarlockCore_Config or not WarlockCore_Config.SelectedPet or WarlockCore_Config.SelectedPet == "None" then return end
    CastSpellByName("Summon " .. WarlockCore_Config.SelectedPet)
end

-- --- UI Styling ---
local function StyleButton(b)
    b:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
    b:SetBackdropColor(0, 0, 0, 0.8); b:SetBackdropBorderColor(0.5, 0.4, 0.7, 1)
    b:SetScript("OnEnter", function() this:SetBackdropBorderColor(0.7, 0.6, 1.0, 1); this:SetBackdropColor(0.1, 0.1, 0.1, 0.9) end)
    b:SetScript("OnLeave", function() this:SetBackdropBorderColor(0.5, 0.4, 0.7, 1); this:SetBackdropColor(0, 0, 0, 0.8) end)
end

function WarlockCore_Minimap_UpdatePosition()
    if not WarlockCore_Config or not WarlockCore_Config.MinimapPos then return end
    local angle = math.rad(WarlockCore_Config.MinimapPos)
    WarlockCoreMinimapButton:ClearAllPoints(); WarlockCoreMinimapButton:SetPoint("CENTER", "Minimap", "CENTER", math.cos(angle)*80, math.sin(angle)*80)
end
function WarlockCore_Minimap_OnUpdate()
    local x, y = GetCursorPosition(); local sc = Minimap:GetEffectiveScale(); local xm, ym = Minimap:GetLeft(), Minimap:GetBottom()
    x = x / sc; y = y / sc; local mx = xm + Minimap:GetWidth() / 2; local my = ym + Minimap:GetHeight() / 2
    WarlockCore_Config.MinimapPos = math.deg(math.atan2(y - my, x - mx)); WarlockCore_Minimap_UpdatePosition()
end

local function CreateMenu()
    if WarlockCoreMenuFrame then return end
    WarlockCoreMenuFrame = CreateFrame("Frame", "WarlockCoreMenuFrame", UIParent)
    local f = WarlockCoreMenuFrame; f:SetWidth(350); f:SetHeight(430); f:SetPoint("CENTER", 0, 0); f:SetFrameStrata("HIGH")
    f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } }); f:SetBackdropColor(0,0,0,0.95); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", function() this:StartMoving() end); f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); title:SetPoint("TOP", 0, -18); title:SetText("|cff9482c9WarlockCore v1.4.9|r")
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -5, -5); close:SetScript("OnClick", function() f:Hide() end)
    local function CreateTab() local t = CreateFrame("Frame", nil, f); t:SetWidth(330); t:SetHeight(300); t:SetPoint("TOPLEFT", 10, -75); t:Hide(); return t end
    local pRot = CreateTab(); local pPet = CreateTab(); local pBuf = CreateTab(); local pInf = CreateTab()
    local btnRot, btnPet, btnBuf, btnInf
    local function ShowTab(tab)
        pRot:Hide(); pPet:Hide(); pBuf:Hide(); pInf:Hide(); btnRot:SetBackdropColor(0.1,0.1,0.1,0.8); btnPet:SetBackdropColor(0.1,0.1,0.1,0.8); btnBuf:SetBackdropColor(0.1,0.1,0.1,0.8); btnInf:SetBackdropColor(0.1,0.1,0.1,0.8)
        if tab == 1 then pRot:Show(); btnRot:SetBackdropColor(0.3, 0.2, 0.5, 0.9) elseif tab == 2 then pPet:Show(); btnPet:SetBackdropColor(0.3, 0.2, 0.5, 0.9) elseif tab == 3 then pBuf:Show(); btnBuf:SetBackdropColor(0.3, 0.2, 0.5, 0.9) else pInf:Show(); btnInf:SetBackdropColor(0.3, 0.2, 0.5, 0.9) end
    end
    local function MakeTabBtn(txt, x, tab)
        local b = CreateFrame("Button", nil, f); b:SetWidth(75); b:SetHeight(24); b:SetPoint("TOPLEFT", x, -40); StyleButton(b); local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); t:SetPoint("CENTER", 0, 0); t:SetText(txt); b:SetScript("OnClick", function() ShowTab(tab) end); return b
    end
    btnRot = MakeTabBtn("Rotation", 20, 1); btnPet = MakeTabBtn("Pet", 100, 2); btnBuf = MakeTabBtn("Buff", 180, 3); btnInf = MakeTabBtn("Info", 260, 4)
    local function MakeDrop(parent, label, key, x, y, list, width)
        local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); l:SetPoint("TOPLEFT", x + 15, y); l:SetText("|cff9482c9"..label.."|r")
        local d = CreateFrame("Frame", "WRC_Drop_" .. key, parent, "UIDropDownMenuTemplate"); d:SetPoint("TOPLEFT", x, y - 15); UIDropDownMenu_SetWidth(width or 100, d)
        UIDropDownMenu_Initialize(d, function() for _, v in ipairs(list) do local val = v; local i = { text = v, value = v, func = function() UIDropDownMenu_SetSelectedValue(d, val); WarlockCore_Config[key] = val; UIDropDownMenu_SetText(val, d) end }; UIDropDownMenu_AddButton(i) end end)
        UIDropDownMenu_SetSelectedValue(d, WarlockCore_Config[key] or "None"); UIDropDownMenu_SetText(WarlockCore_Config[key] or "None", d)
    end
    local function MakeToggle(parent, txt, key, x, y, w) 
        local b = CreateFrame("Button", nil, parent); b:SetWidth(w or 240); b:SetHeight(24); b:SetPoint("TOPLEFT", x, y); StyleButton(b)
        local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); t:SetPoint("CENTER", 0, 0)
        local function Upd() t:SetText(txt..": "..(WarlockCore_Config[key] and "|cff00ff00ON|r" or "|cffff0000OFF|r")) end; Upd()
        b:SetScript("OnClick", function() WarlockCore_Config[key] = not WarlockCore_Config[key]; Upd() end) 
    end
    local function MakeSlider(parent, label, key, x, y, min, max, w)
        local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); l:SetPoint("TOPLEFT", x, y); 
        local function UpdText() l:SetText("|cff9482c9"..label..": "..(WarlockCore_Config[key] or min).."%|r") end; UpdText()
        local s = CreateFrame("Slider", "WRC_Slider_"..key, parent, "OptionsSliderTemplate"); s:SetPoint("TOPLEFT", x, y-20); s:SetWidth(w or 240); s:SetHeight(16); s:SetMinMaxValues(min, max); s:SetValueStep(1); s:SetValue(WarlockCore_Config[key] or min)
        getglobal(s:GetName().."Low"):SetText(min); getglobal(s:GetName().."High"):SetText(max); s:SetScript("OnValueChanged", function() WarlockCore_Config[key] = math.floor(this:GetValue()); UpdText() end)
    end
    local function MakeEditBox(parent, label, key, x, y, w)
        local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); l:SetPoint("TOPLEFT", x, y - 6); l:SetText("|cff9482c9"..label.."|r")
        local b = CreateFrame("EditBox", "WRC_Edit_"..key, parent); b:SetWidth(w or 40); b:SetHeight(26); b:SetPoint("TOPLEFT", x + 40, y + 1); b:SetNumeric(true); b:SetMaxLetters(2); b:SetAutoFocus(false); b:SetText(WarlockCore_Config[key] or "25")
        b:SetFontObject("GameFontHighlightSmall"); b:SetTextInsets(8, 0, 0, 0); StyleButton(b)
        b:SetScript("OnEnterPressed", function() WarlockCore_Config[key] = tonumber(this:GetText()) or 25; this:ClearFocus() end)
        b:SetScript("OnEscapePressed", function() this:ClearFocus() end); b:SetScript("OnEditFocusLost", function() this:SetText(WarlockCore_Config[key] or "25") end)
    end

    -- Rotation Tab
    MakeDrop(pRot, "Opener:", "Opener", 90, 0, warlockSpells, 130)
    MakeDrop(pRot, "Slot 1:", "Rotation1", 5, -60, warlockSpells, 120)
    MakeDrop(pRot, "Slot 2:", "Rotation2", 175, -60, warlockSpells, 120)
    MakeDrop(pRot, "Slot 3:", "Rotation3", 5, -120, warlockSpells, 120)
    MakeDrop(pRot, "Slot 4:", "Rotation4", 175, -120, warlockSpells, 120)

    local line = pRot:CreateTexture(nil, "ARTWORK"); line:SetHeight(1); line:SetWidth(310); line:SetPoint("TOP", 0, -170); line:SetTexture(0.5, 0.4, 0.7, 0.5)

    MakeToggle(pRot, "Smart Fear", "SmartFear", 15, -185, 152)
    MakeToggle(pRot, "Smart Drain", "DrainSoulSmart", 175, -185, 152)
    MakeToggle(pRot, "Auto Healthstone", "AutoHealthstone", 15, -220, 152)
    MakeEditBox(pRot, "@ %:", "HealthstoneHP", 175, -220, 45)
    MakeSlider(pRot, "Drain Soul Threshold", "DrainSoulHP", 20, -260, 5, 50, 290)

    -- Pet Tab
    MakeToggle(pPet, "Pet Assist Mode", "PetAssist", 20, 0, 290)
    MakeToggle(pPet, "Smart Targeting", "SmartTargeting", 20, -35, 290)
    MakeToggle(pPet, "Fast Attack", "FastAttack", 20, -70, 290)
    MakeDrop(pPet, "Selected Pet:", "SelectedPet", 10, -110, warlockPets, 140)
    local dragPet = CreateFrame("Button", nil, pPet); dragPet:SetWidth(50); dragPet:SetHeight(50); dragPet:SetPoint("TOPLEFT", 20,-165); StyleButton(dragPet); dragPetIconTex = dragPet:CreateTexture(nil, "OVERLAY"); dragPetIconTex:SetPoint("TOPLEFT", 4,-4); dragPetIconTex:SetPoint("BOTTOMRIGHT", -4,4); dragPetIconTex:SetTexture("Interface\\Icons\\Spell_Shadow_SummonImp"); dragPet:RegisterForDrag("LeftButton"); dragPet:SetScript("OnDragStart", function() local n="WarlockSummon"; local idx=WRC_GetMacroIndex(n); local b="/script WarlockCore_Summon()"; local ic=petIcons[WarlockCore_Config.SelectedPet or "Imp"] or "Spell_Shadow_SummonImp"; if idx==0 then idx=CreateMacro(n, ic, b, nil, nil) else EditMacro(idx, n, ic, b, nil, nil) end; if idx and idx > 0 then PickupMacro(idx) end end)
    local dragPetL = pPet:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); dragPetL:SetPoint("TOPLEFT", 20, -220); dragPetL:SetText("Drag Macro: Summon")

    -- Buff Tab
    MakeDrop(pBuf, "Selected Armor Buff:", "SelectedBuff", 10, 0, warlockBuffs, 140)

    -- Info Tab
    local drag = CreateFrame("Button", nil, pInf); drag:SetWidth(50); drag:SetHeight(50); drag:SetPoint("TOPLEFT", 20,-10); StyleButton(drag); dragIconTex = drag:CreateTexture(nil, "OVERLAY"); dragIconTex:SetPoint("TOPLEFT", 4,-4); dragIconTex:SetPoint("BOTTOMRIGHT", -4,4); dragIconTex:SetTexture("Interface\\Icons\\Spell_Shadow_DeadlyBolt"); drag:RegisterForDrag("LeftButton"); drag:SetScript("OnDragStart", function() local n="WarlockRot"; local idx=WRC_GetMacroIndex(n); local b="/script WarlockCore_Rotate()"; local ic=WRC_GetSpellTexture(GetNextSpell()); if idx==0 then idx=CreateMacro(n, ic, b, nil, nil) else EditMacro(idx, n, ic, b, nil, nil) end; if idx and idx > 0 then PickupMacro(idx) end end)
    local dragFear = CreateFrame("Button", nil, pInf); dragFear:SetWidth(50); dragFear:SetHeight(50); dragFear:SetPoint("TOPLEFT", 80,-10); StyleButton(dragFear); local dragFearTex = dragFear:CreateTexture(nil, "OVERLAY"); dragFearTex:SetPoint("TOPLEFT", 4,-4); dragFearTex:SetPoint("BOTTOMRIGHT", -4,4); dragFearTex:SetTexture("Interface\\Icons\\Spell_Shadow_Possession"); dragFear:RegisterForDrag("LeftButton"); dragFear:SetScript("OnDragStart", function() local n="WarlockFear"; local idx=WRC_GetMacroIndex(n); local b="/script WarlockCore_Fear()"; local ic="Spell_Shadow_Possession"; if idx==0 then idx=CreateMacro(n, ic, b, nil, nil) else EditMacro(idx, n, ic, b, nil, nil) end; if idx and idx > 0 then PickupMacro(idx) end end)
    local dragL = pInf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); dragL:SetPoint("TOPLEFT", 20, -65); dragL:SetText("Drag Macros: Rot & Fear")

    local restL = pInf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); restL:SetPoint("TOPLEFT", 20, -100); restL:SetText("|cff9482c9Rested XP: |r" .. WRC_GetRestedString())

    MakeToggle(pInf, "Debug Mode", "Debug", 20, -140, 290)
    local relB = CreateFrame("Button", nil, pInf); relB:SetWidth(120); relB:SetHeight(26); relB:SetPoint("TOPLEFT", 20, -180); StyleButton(relB); local relT = relB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); relT:SetPoint("CENTER", 0, 0); relT:SetText("Reload UI"); relB:SetScript("OnClick", function() ReloadUI() end)
    ShowTab(1); f:Show()
end

-- --- Loader ---
local loader = CreateFrame("Frame")
loader:RegisterEvent("VARIABLES_LOADED"); loader:RegisterEvent("PLAYER_LOGIN"); loader:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE"); loader:RegisterEvent("UI_ERROR_MESSAGE")
loader:SetScript("OnUpdate", function() 
    local elapsed = arg1 or 0; iconUpdateTick = iconUpdateTick + elapsed; if iconUpdateTick < 0.33 then return end; iconUpdateTick = 0
    local iconSpell = "None"
    if WarlockCore_Config and WarlockCore_Config.SelectedBuff ~= "None" and not HasBuff("player", WarlockCore_Config.SelectedBuff) then iconSpell = WarlockCore_Config.SelectedBuff else iconSpell = GetNextSpell() end
    local icon = WRC_GetSpellTexture(iconSpell); if dragIconTex then dragIconTex:SetTexture("Interface\\Icons\\" .. icon) end
    local mIdx = WRC_GetMacroIndex("WarlockRot"); if mIdx > 0 then EditMacro(mIdx, "WarlockRot", icon, "/script WarlockCore_Rotate()", nil, nil) end 
    
    local fIdx = WRC_GetMacroIndex("WarlockFear"); if fIdx > 0 then
        local fIcon = "Spell_Shadow_Possession"
        local name = UnitName("target")
        if name and WarlockCore_Config.SmartFear and WarlockCore_Config.ImmuneMobs[name] then fIcon = "Spell_Shadow_ShadowBolt" end
        EditMacro(fIdx, "WarlockFear", fIcon, "/script WarlockCore_Fear()", nil, nil)
    end
    local sIdx = WRC_GetMacroIndex("WarlockSummon"); if sIdx > 0 then
        local sIcon = petIcons[WarlockCore_Config.SelectedPet or "Imp"] or "Spell_Shadow_SummonImp"
        EditMacro(sIdx, "WarlockSummon", sIcon, "/script WarlockCore_Summon()", nil, nil)
    end
    if dragPetIconTex then
        local sIcon = petIcons[WarlockCore_Config.SelectedPet or "Imp"] or "Spell_Shadow_SummonImp"
        dragPetIconTex:SetTexture("Interface\\Icons\\" .. sIcon)
    end
end)
loader:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if not WarlockCore_Config then WarlockCore_Config = {} end
        if WarlockCore_Config.FastAttack == nil then WarlockCore_Config.FastAttack = true end
        if WarlockCore_Config.AutoHealthstone == nil then WarlockCore_Config.AutoHealthstone = true end
        if WarlockCore_Config.HealthstoneHP == nil then WarlockCore_Config.HealthstoneHP = 25 end
        if WarlockCore_Config.SmartFear == nil then WarlockCore_Config.SmartFear = true end
        if WarlockCore_Config.DrainSoulSmart == nil then WarlockCore_Config.DrainSoulSmart = true end
        if WarlockCore_Config.DrainSoulHP == nil then WarlockCore_Config.DrainSoulHP = 20 end
        if not WarlockCore_Config.ImmuneMobs then WarlockCore_Config.ImmuneMobs = {} end
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        -- Pattern: Your Fear failed. [Name] is immune.
        local _, _, mob = string.find(arg1, "Your Fear failed%. (.+) is immune%.")
        if not mob then _, _, mob = string.find(arg1, "Your Fear was resisted by (.+)%.") end -- Just in case they meant resisted too, but user said immune.
        if mob then
            if mob == "Target" then mob = UnitName("target") end
            if mob and not WarlockCore_Config.ImmuneMobs[mob] and not UnitIsPlayer("target") then
                WarlockCore_Config.ImmuneMobs[mob] = true
                DEFAULT_CHAT_FRAME:AddMessage("|cff9482c9[WRC]|r Added |cffff0000" .. mob .. "|r to Fear Immune list.")
            end
        elseif string.find(arg1, "Fear") and string.find(arg1, "immune") then
            -- Fallback if pattern fails
            local targetName = UnitName("target")
            if targetName and not WarlockCore_Config.ImmuneMobs[targetName] and not UnitIsPlayer("target") then
                WarlockCore_Config.ImmuneMobs[targetName] = true
                DEFAULT_CHAT_FRAME:AddMessage("|cff9482c9[WRC]|r Added |cffff0000" .. targetName .. "|r to Fear Immune list (Fallback).")
            end
        end
    elseif event == "UI_ERROR_MESSAGE" then
        if arg1 == "A more powerful spell is already active." or arg1 == "The spell is already active." then
            if WarlockCore_LastAttempt then
                myDots[WarlockCore_LastAttempt] = { target = GetUnitFingerprint("target"), time = GetTime(), failed = true }
            end
        end
    elseif event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff9482c9WarlockCore v1.4.9|r Loaded. Currently |cff00ff00" .. WRC_GetRestedString() .. "|r Rested.")
        if not WarlockCoreMinimapButton then
            WarlockCoreMinimapButton = CreateFrame("Button", "WarlockCoreMinimapButton", Minimap); WarlockCoreMinimapButton:SetWidth(32); WarlockCoreMinimapButton:SetHeight(32); WarlockCoreMinimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5); local ic = WarlockCoreMinimapButton:CreateTexture(nil, "ARTWORK"); ic:SetTexture("Interface\\Icons\\Spell_Shadow_SummonImp"); ic:SetPoint("CENTER", 0, 0); ic:SetWidth(20); ic:SetHeight(20); ic:SetTexCoord(0.08, 0.92, 0.08, 0.92); local bd = WarlockCoreMinimapButton:CreateTexture(nil, "OVERLAY"); bd:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); bd:SetWidth(52); bd:SetHeight(52); bd:SetPoint("TOPLEFT", 0, 0); WarlockCoreMinimapButton:SetScript("OnClick", function() if not WarlockCoreMenuFrame then CreateMenu() end; if WarlockCoreMenuFrame:IsShown() then WarlockCoreMenuFrame:Hide() else WarlockCoreMenuFrame:Show() end end); WarlockCoreMinimapButton:SetScript("OnDragStart", function() this:SetScript("OnUpdate", WarlockCore_Minimap_OnUpdate) end); WarlockCoreMinimapButton:SetScript("OnDragStop", function() this:SetScript("OnUpdate", nil) end)
            WarlockCoreMinimapButton:SetScript("OnEnter", function() 
                GameTooltip:SetOwner(this, "ANCHOR_LEFT")
                GameTooltip:AddLine("|cff9482c9WarlockCore|r")
                GameTooltip:AddLine("Currently |cff00ff00" .. WRC_GetRestedString() .. "|r Rested", 1, 1, 1)
                GameTooltip:AddLine("Left-Click to toggle menu", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            end)
            WarlockCoreMinimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
            local angle = math.rad(WarlockCore_Config.MinimapPos or 120); WarlockCoreMinimapButton:SetPoint("CENTER", "Minimap", "CENTER", math.cos(angle)*80, math.sin(angle)*80)
        end
    end
end)