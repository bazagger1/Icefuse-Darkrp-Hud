--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hud_darkrp_v2/lua/icefuse/hud/sh_init.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

--[[ -----------------------------------------------------------
	This script was made by ikefi
		http://steamcommunity.com/id/ikefi/
------------------------------------------------------------- ]]

IcefuseHUD = IcefuseHUD or {

    version = '2.1.0',
    versionNr = 210,

    name = 'Icefuse HUD',
    alias = 'IcefuseHUD',
    identifier = 'icefuse.hud'

}

--------------------------------------------------------------------------------

--[[
- Includes a file.
- @arg string file
- @arg string type
]]
function IcefuseHUD.include(file, type)
    if type == 'server' or type == 'shared' then
        if SERVER then
            include(file)
        end
    end
    if type == 'client' or type == 'shared' then
        if SERVER then
            AddCSLuaFile(file)
        else
            include(file)
        end
    end
end

--------------------------------------------------------------------------------

-- Include files
do
    IcefuseHUD.include('include/sv_view.lua', 'server')
    IcefuseHUD.include('include/cl_view.lua', 'client')
end
