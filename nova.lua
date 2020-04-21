--[[
 _   _                  
| \ | |                  
|  \| | _____   ____ _   
| . ` |/ _ \ \ / / _` |  
| |\  | (_) \ V / (_| |_ 
\_| \_/\___/ \_/ \__,_(_)
                         
                        
Nova is an all-in-one security tool for your Garry's mod client

This script blocks servers from attacking you in most ways possible,
including; Reading your files, Crashing your game, and sending unwanted commands -
to your client.


°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸


Last Update (21st April 2020)
~ Rewrite of all code
~ new GUI
~ better methods
 >> WIP <<


If you dont know what you're doing please dont edit below this line.

]]--
-- °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸--

if (SERVER) then return end

local nova = {}
nova.detouredfuncs, nova.detourednets, nova.detouredhooks, nova.detouredcmds = {}, {}, {}, {}
nova.defaultbadcommands = {"unbind","bind","bind_mac","bindtoggle","impulse","+forward","-forward","+back","-back","+moveleft","-moveleft","+moveright","-moveright","+left","-left","+right","-right","cl_yawspeed","pp_texturize","pp_texturize_scale","mat_texture_limit","pp_bloom","pp_dof","pp_bokeh","pp_motionblur","pp_toytown","pp_stereoscopy","retry","connect","kill","+voicerecord","-voicerecord","startmovie","record"}
local Meta_PLY = FindMetaTable("Player")
nova.logs = {}
nova.commands = {
	["nova_menu"] = function() if (!nova.madeGUI) then nova.makeGUI() else nova.popGUI() nova.loadPanel(1) end end,
	["nova_check"] = function() nova.scanACs() end,
	["nova_unload"] = function() nova.addLog("Unloading...") nova.base:Remove() for k,v in pairs(nova.commands) do nova.removeCommand(k) end nova = {}  end,
}
nova.vars = {
	["nova_detourscreen"] = {[1] = "Block render.Capture, render.RenderView, render.Clear", [2] = 1},
	["nova_detourfile"] = {[1] = "Block servers from viewing and editing your files", [2] = 1},
	["nova_detourcmd"] = {[1] = "Block servers from sending you unwanted commands", [2] = 1},
	["nova_detourlua"] = {[1] = "Block servers from sending you lua", [2] = 0},
	["nova_detourcrash"] = {[1] = "Block servers from crashing your client", [2] = 1},
	["nova_detourip"] = {[1] = "Block servers from getting your IP Address", [2] = 1},

	["nova_logconsole"] = {[1] = "Show logs in console", [2] = 1},
	["nova_logpopup"] = {[1] = "Show logs in popup window", [2] = 0},
	["nova_logsound"] = {[1] = "Play sound on log", [2] = 0},

	["nova_scanjoin"] = {[1] = "Automatically scan for Anti-cheats on server join", [2] = 1},
	["nova_scanupdate"] = {[1] = "Automatically update the script when available", [2] = 0},
}

nova.allowedfiles = {
	"lua/vgui/dpanelselect.lua",
	"lua/derma/init.lua",
	"lua/includes/modules/spawnmenu.lua",
	"lua/vgui/spawnicon.lua",
	"lua/vgui/dform.lua",
	"lua/vgui/dlabel.lua",
	"lua/vgui/dbutton.lua",
	"lua/vgui/dframe.lua",
	"gamemodes/sandbox/gamemode/spawnmenu/controls/control_presets.lua",
	"lua/vgui/dcolormixer.lua",
	"lua/vgui/propselect.lua",
	"lua/vgui/matselect.lua",
	"gamemodes/sandbox/gamemode/spawnmenu/controlpanel.lua",
	"lua/vgui/dpanelselect.lua",
	"gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenticon.lua",
	"lua/vgui/dhtml.lua",
	"gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/dupes.lua",
	"lua/vgui/dbutton.lua",
	"lua/includes/modules/undo.lua",
	"gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/saves.lua",
	"addons/chatbox/lua/scorpy_chatbox/vgui/scorpy_chatbox_panels.lua",
	"gamemodes/sandbox/gamemode/editor_player.lua",
	"lua/vgui/dmenuoptioncvar.lua",
	"gamemodes/darkrp/gamemode/cl_init.lua",
	"gamemodes/base/gamemode/cl_deathnotice.lua",
	"gamemodes/darkrp/gamemode/modules/f4menu/cl_init.lua",
	"gamemodes/darkrp/entities/entities/chatindicator/cl_init.lua",
	"lua/autorun/wac_aircraft_input.lua",
	"lua/includes/extensions/file.lua",
}


nova.runCC = RunConsoleCommand
nova.runSTR = RunString
nova.runSTREX = RunStringEx
nova.compSTR = CompileString
nova.rCap = render.Capture
nova.rCapPixels = render.CapturePixels

nova.sndLUA = Meta_PLY.SendLUA

nova.fOpen = file.Open
nova.fWrite = file.Write
nova.fAppend = file.Append
nova.fRead = file.Read
nova.fSize = file.Size
nova.fIsDir = file.IsDir
nova.fExists = file.Exists
--nova.fExistsEx = file.ExistsEx
nova.fTime = file.Time


function nova.addLog(message, type)
	table.insert(nova.logs, os.date("%I:%M:%S %p").." | "..message)
end

function nova.consoleWarn(message, type)
	if (nova.get("nova_logconsole") == 1) then 
		if (type == "warn") then
			MsgC(Color(255,0,0), "WARN! ", Color(255,255,0),"Nova > ", Color(255,255,255), message.."\n")
			surface.PlaySound("HL1/fvox/warning.wav")
			nova.addLog(message)
		else
			MsgC(Color(255,255,0),"Nova > ", Color(255,255,255), message.."\n")
			nova.addLog(message)
		end
	end
end

function nova.popupWarn(message, type)

end


function nova.detourFunction(original, new)
    detouredfuncs[new] = original
    consoleWarn("Detoured function: ".. original, "notif")
	--nova.addLog("Detoured function: ".. original)
    return new
end

function nova.addCommand( name, func, completefunc, help, flags )
	concommand.Add(name, func, completefunc, help, flags)
	nova.consoleWarn("Added command: "..name)
	--nova.addLog("Added command: "..name)
end

function nova.removeCommand(name)
	concommand.Remove(name)
	nova.consoleWarn("Removed command: "..name)
	--nova.addLog("Removed command: "..name)
end

function nova.scanACs()
end

function nova.get(var)
	return (nova.vars[var][2])
end

function nova.set(var, val)
	nova.vars[var][2] = val
end


-- function render.Capture(data)
-- 	if (nova.get("nova_detourscreen") == 1) then
-- 		nova.detourFunction(render.Capture(), render_Capture)
-- 		return false
-- 	end
-- end

-- function render.CapturePixels(data)
-- 	if (nova.get("nova_detourscreen") == 1) then
-- 		nova.detourFunction(render.CapturePixels(), render_CapturePixels)
-- 		return false
-- 	end
-- end

function file.Open( fn, fm, path)
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file stealing. File: "..fn.." Path: "..path)
			return false
		else
			nova.consoleWarn("Allowed attemped file.Open function. File: "..fn.." Path: "..path)
			return nova.fOpen( fn, fm, path)
		end
	else
return nova.fOpen( fn, fm, path)
end
end

function file.Read( fn, path )
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file.Read function. File: "..fn.." Path: "..path)
			return false
		else
			return nova.fRead( fn, path )
		end
	else
	return nova.fRead(fn,path)
end end

function file.Write( fn, data )
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file.Write function. File: "..fn)
			return false
		else
			return nova.fWrite( fn, data )
		end
	else
	return nova.fWrite(fn,data)
end end

function file.Append( fn, data )
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file.Append function. File: "..fn)
			return false
		else
			return nova.fAppend( fn, data )
		end
	else
	return nova.fAppend(fn,data)
end end

function file.Size( fn, path )
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file.Size function. File: "..fn.." Path: "..path)
			return false
		else
			return nova.fSize( fn, path )
		end
	else
	return nova.fSize(fn,path)
end end

function file.Open( fn, mode, data )
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file.Open function. File: "..fn.." Path: "..path)
			return false
		else
			return nova.fOpen( fn, mode, data )
		end
	else
	return nova.fOpen( fn, mode, data )
end end

function file.IsDir(dir, path)
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",dir)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(nova.newfn[1], "scripthook/") || !table.HasValue(nova.allowedfiles, nova.newfn[1]) then
			nova.consoleWarn("Blocked attemped file.IsDir function. File: "..dir.." Path: "..path)
			return false
		else
			return nova.IsDir(dir, path)
		end
	else
	return nova.IsDir(dir, path)
end end

function file.Exists(fn, path)
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file.Exists function. File: "..fn.." Path: "..path)
			return false
		else
			return nova.Exists(fn, path)
		end
	else
	return nova.Exists(fn, path)
end
end

-- function file.ExistsEx(fn, path)
-- 	if (nova.get("nova_detourfile") == 1) then
-- 		nova.newfn = nil
-- 		nova.newfn = string.Explode("/",fn)
-- 		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
-- 			nova.consoleWarn("Blocked attemped file stealing. File: "..fn.." Path: "..path)
-- 			return false
-- 		else
-- 			return file.ExistsEx(fn, path)
-- 		end
-- 	else
-- 	return file.ExistsEx(fn, path)
-- end
-- end

function file.Time(fn, data)
	if (nova.get("nova_detourfile") == 1) then
		nova.newfn = nil
		nova.newfn = string.Explode("/",fn)
		if ( nova.newfn[2] && (nova.newfn[#nova.newfn-1] == "lua" && (string.find(nova.newfn[#nova.newfn], ".lua") || string.find(nova.newfn[#nova.newfn], ".txt")) || nova.newfn[#nova.newfn-1] == "scripthook")) || nova.newfn[1] && (string.find(nova.newfn[1], ".lua") || string.find(nova.newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") || !table.HasValue(nova.allowedfiles, fn) then
			nova.consoleWarn("Blocked attemped file stealing. File: "..fn.." Data: "..data)
			return false
		else
			return nova.Time(fn, path)
		end
	else
	return nova.Time(fn, path)
end
end

-- Blocking this by default
function file.Delete(fn)
	return false
end


function Meta_PLY.SendLua(ply,cmd)
	if (nova.get("nova_detourlua") == 1) then
		if (!table.HasValue(nova.allowedfiles, cmd)) then
		nova.consoleWarn("Blocked SendLUA, Command: "..cmd)
		return false
	else
		nova.consoleWarn("Allowed SendLUA, Command: "..cmd)
	end
	else
	return nova.sndLUA(ply,cmd)
end
end

function Meta_PLY.IPAddress()
	if (nova.get("nova_detourip") == 1) then
		nova.consoleWarn("Blocked attempted IP grab")
		return "0.0.0.0"
	end
end



function RunConsoleCommand(cmd, val)
	if (nova.get("nova_detourcmd") == 1) then
		if (table.HasValue(nova.defaultbadcommands, cmd)) then
			nova.consoleWarn("Blocked attempted RunConsoleCommand execution, Command: "..cmd.." Value: "..val)
			return false
		else
			return nova.runCC(cmd,val)
		end
	end
	return nova.runCC(cmd,val)
end

function RunString(str)
	if (nova.get("nova_detourcmd") == 1) then
		if (!table.HasValue(nova.allowedfiles, str)) then
			nova.consoleWarn("Blocked attempted RunString execution, String: "..str)
			return false
		else
			return nova.runSTR(str)
		end
	end
	return nova.runSTR(str)
end

function RunStringEx(str)
	if (nova.get("nova_detourcmd") == 1) then
		if (!table.HasValue(nova.allowedfiles, str)) then
			nova.consoleWarn("Blocked attempted RunStringEX execution, String: "..str)
			return false
		else
			return nova.runSTREX(str)
		end
	end
	return nova.runSTREX(str)
end

function CompileString(str)
	if (nova.get("nova_detourcmd") == 1) then
		if (!table.HasValue(nova.allowedfiles, str)) then
			nova.consoleWarn("Blocked attempted CompileString execution, String: "..str)
			return false
		else
			return nova.compSTR(str)
		end
	end
	return nova.compSTR(str)
end


function render.Capture(data)
	if (nova.get("nova_detourscreen") == 1) then
		nova.consoleWarn("Blocked attempted render.Capture")
		return false
	else
	return nova.rCap(data) end
end

function render.CapturePixels(data)
	if (nova.get("nova_detourscreen") == 1) then
		nova.consoleWarn("Blocked attempted render.CapturePixels")
		return false
	else
	return nova.rCapPixels(data) end
end



function nova.addCheck(name,var,x,y)
	local check = vgui.Create("DButton", nova.panel)
	check:SetText("")
	check:SetSize(20,20)
	check:SetPos(x * 2, y * 2)
	check.Paint = function(self,w,h) draw.RoundedBox(0,0,0,w,h,Color(25,25,25,255)) if (nova.get(var) == 1) then draw.RoundedBox(0,3,3,w-6,h-6,Color(255,255,255)) else draw.RoundedBox(0,3,3,w-6,h-6,Color(25,25,25)) end  end
	check.DoClick = function() if (nova.get(var) == 1) then nova.set(var,0) else nova.set(var,1)  end end

	local label = vgui.Create("DLabel", nova.panel)
	label:SetText(name)
	label:SetPos(x * 2 + 25, y * 2)
	label:SetWide(100)
end


function nova.addButton(name,func,x,y)
	local but = vgui.Create("DButton", nova.panel)
	but:SetText(name)
	but:SetSize(30,30)
	but:SetPos(x * 2, y * 2)
end

function nova.addLabel(text,x,y)
	local label = vgui.Create("DLabel", nova.panel)
	label:SetText(text)
	label:SetPos(x * 2, y * 2)
	label:SetWide(200)
end


function nova.loadPanel(panelnum)
	if(panelnum == 1) then
		nova.addLabel("Block / Detour", 10, 0)
		nova.addCheck("Screengrab","nova_detourscreen",10,15)
		nova.addCheck("Filestealing","nova_detourfile",10,30)
		nova.addCheck("Bad Commands","nova_detourcmd",10,45)
		nova.addCheck("Lua Execution","nova_detourlua",10,60)
		nova.addCheck("Attemped Crashes","nova_detourcrash",10,75)
		nova.addCheck("IP Address","nova_detourip",10,90)
		--nova.addCheck("Testing","nova_nosg",200,20)

		nova.addLabel("Logging", 100, 0)
		nova.addCheck("Console","nova_logconsole",100,15)
		nova.addCheck("Popups","nova_logpopup",100,30)
		nova.addCheck("Play Sound","nova_logsound",100,45)

		nova.addLabel("Other", 200, 0)
		nova.addCheck("Auto-scan on Join","nova_scanjoin",200,15)
		nova.addCheck("Auto-bypass","nova_scanjoin",200,30)
		nova.addCheck("Auto-update","nova_scanupdate",200,45)



		nova.addLabel("Scroll over a feature to know more", 210, 145)
	elseif (panelnum == 2) then
		local logs = vgui.Create("RichText", nova.panel)
		logs:Dock(FILL)
		logs:InsertColorChange(255, 255, 255, 255)
		for k,v in ipairs(nova.logs) do
			logs:AppendText(v.."\n")
		end
	else
	end
end

function nova.popGUI()
	if (!nova.madeGUI) then
		nova.makeGUI()
	else
		nova.base:MakePopup()
	end
end

function nova.makeGUI()
	if (ss) then return end
	nova.base = vgui.Create("DFrame")
	nova.base:SetSize(600, 400)
	nova.base:Center()
	nova.base:SetTitle("")
	nova.base:MakePopup()
	nova.base:RequestFocus()
	nova.base:ShowCloseButton(false)
	nova.base:SetBackgroundBlur(true)
	nova.base:IsDraggable(true)
	nova.base.Paint = function(self,w,h)
		draw.RoundedBoxEx(0,0,0,w,h,Color(18,18,18,255))
		draw.RoundedBoxEx(0,0,0,w,20,Color(25,25,25,255))
		draw.SimpleText("Nova.", "DermaLarge", 50, 25, Color(255,255,0), TEXT_ALIGN_CENTER)
		draw.RoundedBoxEx(0,0,60,w,1,Color(255,255,255,255))
	end

	nova.panel = vgui.Create("DPanel", nova.base)
	nova.panel:SetSize(600, 320)
	nova.panel:SetPos(0,80)
	nova.panel.Paint = function(self,w,h)
	end

	nova.tab1 = vgui.Create("DButton", nova.base)
	nova.tab1:SetSize(100,40)
	nova.tab1:SetPos(300,20)
	nova.tab1:SetText("")
	nova.tab1.Paint = function(self,w,h) draw.DrawText("main", "TargetID",50, 10, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)end
	nova.tab1.DoClick = function() nova.panel:Clear() nova.loadPanel(1) end

	nova.tab2 = vgui.Create("DButton", nova.base)
	nova.tab2:SetSize(100,40)
	nova.tab2:SetPos(400,20)
	nova.tab2:SetText("")
	nova.tab2.Paint = function(self,w,h) draw.DrawText("logs", "TargetID",50, 10, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)end
	nova.tab2.DoClick = function() nova.panel:Clear() nova.loadPanel(2) end

	nova.tab3 = vgui.Create("DButton", nova.base)
	nova.tab3:SetSize(100,40)
	nova.tab3:SetPos(500,20)
	nova.tab3:SetText("")
	nova.tab3.Paint = function(self,w,h) draw.DrawText("settings", "TargetID",50, 10, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)end
	nova.tab3.DoClick = function() nova.panel:Clear() nova.loadPanel(3) end



	nova.close = vgui.Create("DButton", nova.base)
	nova.close:SetText("")
	nova.close:SetSize(30,20)
	nova.close:SetPos(600-30,0)
	nova.close.DoClick = function() nova.base:Close() end
	nova.close.Paint = function(self,w,h) draw.RoundedBoxEx(100, 0, 0, w, h, Color(250,100,100)) end
 
	nova.guiMade = true
	nova.loadPanel(1)
end


function nova.onStart()
	nova.addLog("Loading...")
	for k,v in pairs(nova.commands) do
		nova.addCommand(k,v)
	end
	nova.addLog("Finished")
	surface.PlaySound("garrysmod/content_downloaded.wav")
	nova.makeGUI()
end

nova.onStart()
