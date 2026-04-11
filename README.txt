WARLOCKCORE - UDVIKLINGSNOTER (VANILLA WOW / TURTLE WOW)
=========================================================

Dette dokument forklarer de vigtigste tekniske regler, vi skal følge for at lave addons til Turtle WoW (baseret på den gamle version 1.12.1).

1. INTERFACE VERSION (TOC FIL)
------------------------------
Brug altid '## Interface: 11200'. 
Hvis tallet er højere, tror spillet, at addonen er forældet, og den bliver måske slet ikke indlæst.

2. LUA VERSIONSMAGI (INGEN MODERNE GENVEJE)
------------------------------------------
Turtle WoW bruger en gammel version af Lua (5.0). Det betyder:
- INGEN 'SetSize(x, y)': Du skal bruge 'SetWidth(x)' og 'SetHeight(y)' separat.
- INGEN '...': I event-funktioner kan du ikke bruge de tre prikker. Du skal i stedet bruge den globale variabel 'arg1', 'arg2', osv.
- INGEN 'self' i scripts: Når du bruger 'SetScript', får funktionen ikke automatisk 'self' med. Brug i stedet det globale ord 'this' for at referere til framen.

3. EVENT HANDLING (ADDON_LOADED VS PLAYER_LOGIN)
------------------------------------------------
- 'ADDON_LOADED': Her bliver de gemte variabler (SavedVariables) indlæst.
- 'PLAYER_LOGIN': Her er hele spilverdenen (inkl. Minimap) klar. Det er her, vi tegner knappen første gang for at være sikre på, at Minimap eksisterer.

4. MINIMAP KNAP LOGIK
---------------------
For at få en knap til at køre pænt rundt om minimappet, bruger vi matematik:
- Vi måler musens position i forhold til midten af minimappet.
- Vi bruger 'math.atan2' til at finde vinklen.
- Vi gemmer vinklen i 'WarlockCore_Config.MinimapPos'.

5. FREMTIDIGE FEJL?
-------------------
Hvis du ser fejlen 'attempt to call method X (a nil value)', er det næsten altid fordi, du har brugt en funktion fra en nyere version af WoW (som f.eks. 'SetSize' eller 'SetPoint' med for mange argumenter).

Tjek altid PaladinCore.lua hvis du er i tvivl - den bruger de helt rigtige Vanilla-metoder!
