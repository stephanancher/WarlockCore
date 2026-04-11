-- WarlockCore v1.2.3
-- Class Lock: Addon will only load if player is a WARLOCK.

local _, class = UnitClass("player")
if class ~= "WARLOCK" then return end

local iconUpdateTick = 0
local dragIconTex

local buffTextures = {
    ["Demon Armor"] = "Interface\\Icons\\Spell_Shadow_RagingScream",
    ["Demon Skin"] = "Interface\\Icons\\Spell_Shadow_DemonSkin"
}

local warlockSpells = { "None", "Immolate", "Corruption", "Curse of Agony", "Siphon Life", "Shadow Bolt", "Drain Life", "Life Tap" }
local warlockBuffs = { "None", "Demon Skin", "Demon Armor" }

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

local function HasDebuff(unit, spell)
    local tx = WRC_GetSpellTexture(spell); local texture = "Interface\\Icons\\" .. tx
    for i = 1, 16 do local dTex = UnitDebuff(unit, i); if not dTex then break end; if dTex == texture then return true end end
    return false
end

local function GetNextSpell()
    if not WarlockCore_Config then return "None" end
    if not UnitAffectingCombat("player") then return WarlockCore_Config.Opener or "None" end
    local s1, s2, s3, s4 = WarlockCore_Config.Rotation1, WarlockCore_Config.Rotation2, WarlockCore_Config.Rotation3, WarlockCore_Config.Rotation4
    local slots = { s1, s2, s3, s4 }
    for _, s in ipairs(slots) do
        if s and s ~= "None" then
            if s == "Immolate" or s == "Corruption" or s == "Curse of Agony" or s == "Siphon Life" then
                if not HasDebuff("target", s) then return s end
            else return s end
        end
    end
    return WarlockCore_Config.Rotation4 or "None"
end

function WarlockCore_Rotate()
    if not WarlockCore_Config then return end
    
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
        PetDefensiveMode(); PetAttack()
    end
    local ns = GetNextSpell()
    if ns and ns ~= "None" then CastSpellByName(ns) end
end

-- --- UI Styling ---
local function StyleButton(b)
    b:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-SliderBar-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 8, edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
    b:SetBackdropColor(0.1, 0.1, 0.1, 0.8); b:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
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
    local f = WarlockCoreMenuFrame; f:SetWidth(300); f:SetHeight(380); f:SetPoint("CENTER", 0, 0); f:SetFrameStrata("HIGH")
    f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } }); f:SetBackdropColor(0,0,0,0.95); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", function() this:StartMoving() end); f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); title:SetPoint("TOP", 0, -18); title:SetText("|cff9482c9WarlockCore|r")
    local function CreateTab() local t = CreateFrame("Frame", nil, f); t:SetWidth(280); t:SetHeight(300); t:SetPoint("TOPLEFT", 10, -60); t:Hide(); return t end
    local pRot = CreateTab(); local pPet = CreateTab(); local pBuf = CreateTab(); local pInf = CreateTab()
    local btnRot, btnPet, btnBuf, btnInf
    local function ShowTab(tab)
        pRot:Hide(); pPet:Hide(); pBuf:Hide(); pInf:Hide(); btnRot:SetBackdropColor(0.1,0.1,0.1,0.8); btnPet:SetBackdropColor(0.1,0.1,0.1,0.8); btnBuf:SetBackdropColor(0.1,0.1,0.1,0.8); btnInf:SetBackdropColor(0.1,0.1,0.1,0.8)
        if tab == 1 then pRot:Show(); btnRot:SetBackdropColor(0.3, 0.2, 0.5, 0.9) elseif tab == 2 then pPet:Show(); btnPet:SetBackdropColor(0.3, 0.2, 0.5, 0.9) elseif tab == 3 then pBuf:Show(); btnBuf:SetBackdropColor(0.3, 0.2, 0.5, 0.9) else pInf:Show(); btnInf:SetBackdropColor(0.3, 0.2, 0.5, 0.9) end
    end
    local function MakeTabBtn(txt, x, tab)
        local b = CreateFrame("Button", nil, f); b:SetWidth(65); b:SetHeight(24); b:SetPoint("TOPLEFT", x, -40); StyleButton(b); local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); t:SetPoint("CENTER", 0, 0); t:SetText(txt); b:SetScript("OnClick", function() ShowTab(tab) end); return b
    end
    btnRot = MakeTabBtn("Rotation", 15, 1); btnPet = MakeTabBtn("Pet", 85, 2); btnBuf = MakeTabBtn("Buff", 155, 3); btnInf = MakeTabBtn("Info", 225, 4)
    local function MakeDrop(parent, label, key, y, list)
        local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); l:SetPoint("TOPLEFT", 15, y); l:SetText("|cff9482c9"..label.."|r")
        local d = CreateFrame("Frame", "WRC_Drop_"..key, parent, "UIDropDownMenuTemplate"); d:SetPoint("TOPLEFT", 0, y-18); UIDropDownMenu_SetWidth(140, d)
        UIDropDownMenu_Initialize(d, function() for _, v in ipairs(list) do local i = { text = v, value = v, func = function() UIDropDownMenu_SetSelectedValue(d, this.value); WarlockCore_Config[key] = this.value; UIDropDownMenu_SetText(this.value, d) end }; UIDropDownMenu_AddButton(i) end end)
        UIDropDownMenu_SetSelectedValue(d, WarlockCore_Config[key] or "None"); UIDropDownMenu_SetText(WarlockCore_Config[key] or "None", d)
    end
    MakeDrop(pRot, "Opener:", "Opener", 0, warlockSpells); MakeDrop(pRot, "Slot 1:", "Rotation1", -50, warlockSpells); MakeDrop(pRot, "Slot 2:", "Rotation2", -100, warlockSpells); MakeDrop(pRot, "Slot 3:", "Rotation3", -150, warlockSpells); MakeDrop(pRot, "Slot 4:", "Rotation4", -200, warlockSpells)
    local function MakeToggle(parent, txt, key, y) local b = CreateFrame("Button", nil, parent); b:SetWidth(240); b:SetHeight(26); b:SetPoint("TOPLEFT", 15, y); StyleButton(b); local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); t:SetPoint("CENTER", 0, 0); local function Upd() t:SetText(txt..": "..(WarlockCore_Config[key] and "|cff00ff00ON|r" or "|cffff0000OFF|r")) end; Upd(); b:SetScript("OnClick", function() WarlockCore_Config[key] = not WarlockCore_Config[key]; Upd() end) end
    MakeToggle(pPet, "Pet Assist Mode", "PetAssist", 0); MakeToggle(pPet, "Smart Targeting", "SmartTargeting", -35); MakeToggle(pPet, "Fast Attack (0.0s)", "FastAttack", -70); MakeDrop(pBuf, "Selected Armor Buff:", "SelectedBuff", 0, warlockBuffs)
    local drag = CreateFrame("Button", nil, pInf); drag:SetWidth(50); drag:SetHeight(50); drag:SetPoint("TOPLEFT", 15,-10); StyleButton(drag); dragIconTex = drag:CreateTexture(nil, "OVERLAY"); dragIconTex:SetPoint("TOPLEFT", 4,-4); dragIconTex:SetPoint("BOTTOMRIGHT", -4,4); dragIconTex:SetTexture("Interface\\Icons\\Spell_Shadow_DeadlyBolt"); drag:RegisterForDrag("LeftButton"); drag:SetScript("OnDragStart", function() local n="WarlockRot"; local idx=WRC_GetMacroIndex(n); local b="/script WarlockCore_Rotate()"; local ic=WRC_GetSpellTexture(GetNextSpell()); if idx==0 then CreateMacro(n, ic, b, nil, nil) else EditMacro(idx, n, ic, b, nil, nil) end; PickupMacro(n) end)
    MakeToggle(pInf, "Debug Mode", "Debug", -80); local relB = CreateFrame("Button", nil, pInf); relB:SetWidth(120); relB:SetHeight(26); relB:SetPoint("TOPLEFT", 15, -120); StyleButton(relB); local relT = relB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); relT:SetPoint("CENTER", 0, 0); relT:SetText("Reload UI"); relB:SetScript("OnClick", function() ReloadUI() end)
    ShowTab(1); f:Show()
end

-- --- Loader ---
local loader = CreateFrame("Frame")
loader:RegisterEvent("VARIABLES_LOADED"); loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnUpdate", function() 
    local elapsed = arg1 or 0; iconUpdateTick = iconUpdateTick + elapsed; if iconUpdateTick < 0.33 then return end; iconUpdateTick = 0
    local iconSpell = "None"
    if WarlockCore_Config and WarlockCore_Config.SelectedBuff ~= "None" and not HasBuff("player", WarlockCore_Config.SelectedBuff) then iconSpell = WarlockCore_Config.SelectedBuff else iconSpell = GetNextSpell() end
    local icon = WRC_GetSpellTexture(iconSpell); if dragIconTex then dragIconTex:SetTexture("Interface\\Icons\\" .. icon) end
    local mIdx = WRC_GetMacroIndex("WarlockRot"); if mIdx > 0 then EditMacro(mIdx, "WarlockRot", icon, "/script WarlockCore_Rotate()", nil, nil) end 
end)
loader:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if not WarlockCore_Config then WarlockCore_Config = {} end
        if WarlockCore_Config.FastAttack == nil then WarlockCore_Config.FastAttack = true end
    elseif event == "PLAYER_LOGIN" then
        if not WarlockCoreMinimapButton then
            WarlockCoreMinimapButton = CreateFrame("Button", "WarlockCoreMinimapButton", Minimap); WarlockCoreMinimapButton:SetWidth(32); WarlockCoreMinimapButton:SetHeight(32); WarlockCoreMinimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5); local ic = WarlockCoreMinimapButton:CreateTexture(nil, "ARTWORK"); ic:SetTexture("Interface\\Icons\\Spell_Shadow_SummonImp"); ic:SetPoint("CENTER", 0, 0); ic:SetWidth(20); ic:SetHeight(20); ic:SetTexCoord(0.08, 0.92, 0.08, 0.92); local bd = WarlockCoreMinimapButton:CreateTexture(nil, "OVERLAY"); bd:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); bd:SetWidth(52); bd:SetHeight(52); bd:SetPoint("TOPLEFT", 0, 0); WarlockCoreMinimapButton:SetScript("OnClick", function() if not WarlockCoreMenuFrame then CreateMenu() end; if WarlockCoreMenuFrame:IsShown() then WarlockCoreMenuFrame:Hide() else WarlockCoreMenuFrame:Show() end end); WarlockCoreMinimapButton:SetScript("OnDragStart", function() this:SetScript("OnUpdate", WarlockCore_Minimap_OnUpdate) end); WarlockCoreMinimapButton:SetScript("OnDragStop", function() this:SetScript("OnUpdate", nil) end); local angle = math.rad(WarlockCore_Config.MinimapPos or 120); WarlockCoreMinimapButton:SetPoint("CENTER", "Minimap", "CENTER", math.cos(angle)*80, math.sin(angle)*80)
        end
    end
end)