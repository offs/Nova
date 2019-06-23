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


I have used comments thoughout this script so if you would like to read through please do,
comments are layed out like this:

NAME, Name of the function/hook.
ARGUMENTS, The arguments it takes (if any).
USES, The uses for it being here.



If you dont know what you're doing please dont edit below this line.

]]--
-- °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸--
-- START Init --

local curVer = "1.0" -- what is this shit
local Detoured = {} -- Table of past detoured functions
local Messages = {} -- Table of past detoured net messages
local fRead -- filestealing (file.Read)
local fOpen -- filestealing (file.Open)
local newfn -- filestealing (new Filename)
local toBlock -- should block function
local hide -- should hide file
local i = 1
local BlockedCommands = {"unbind","bind","bind_mac","bindtoggle","impulse","+forward","-forward","+back","-back","+moveleft","-moveleft","+moveright","-moveright","+left","-left","+right","-right","cl_yawspeed","pp_texturize","pp_texturize_scale","mat_texture_limit","pp_bloom","pp_dof","pp_bokeh","pp_motionblur","pp_toytown","pp_stereoscopy","retry","connect","kill","+voicerecord","-voicerecord","startmovie","record"}


if !fRead then
	fRead = file.Read
	fOpen = file.Open
end

-- END Init --
-- °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸--
-- START Main Functions --

-- NAME : ChatText, ARGUMENTS : message (the message to be displayed) type (the type of message, e.g notif, warn), USES : A clean way to display the user some text --
local function chatText(message, type)
    if (type == "warn") then
        MsgC(Color(255,0,0), "WARN! ", Color(255,255,0),"Nova > ", Color(255,255,255), message.."\n")
        surface.PlaySound("HL1/fvox/warning.wav")
    else
        MsgC(Color(255,255,0),"Nova > ", Color(255,255,255), message.."\n")
    end
end

-- NAME : detourFunctions, ARGUMENTS : original (the original function to be detoured) new (the new function, once detoured), USES : Detouring functions --
local function detourFunctions(original, new)
    Detoured[new] = original
    chatText("Detoured function: ".. original, "notif")
    return new
end

-- NAME : file.Open, ARGUMENTS : fn (File name) fm (File mode) path (path of file), USES : Detouring file.Open --
function file.Open( fn, fm, path)
    newfn = nil
    newfn = string.Explode("/",fn)
    if ( newfn[2] && (newfn[#newfn-1] == "lua" && (string.find(newfn[#newfn], ".lua") || string.find(newfn[#newfn], ".txt")) || newfn[#newfn-1] == "scripthook")) || newfn[1] && (string.find(newfn[1], ".lua") || string.find(newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") then
        chatText("someone tried using file.open to get your "..fn.." with the PATH: "..path.." and file mode: "..fm..".", "warn")
        return "Filestealing bypassed, nice coding dude!"
    else
        return fOpen( fn, fm, path)
    end
end

-- NAME : file.Read, ARGUMENTS : fn (File name) path (path of file), USES : Detouring file.Read --
function file.Read( fn, path )
    newfn = nil
    newfn = string.Explode("/",fn)
    if ( newfn[2] && (newfn[#newfn-1] == "lua" && (string.find(newfn[#newfn], ".lua") || string.find(newfn[#newfn], ".txt")) || newfn[#newfn-1] == "scripthook")) || newfn[1] && (string.find(newfn[1], ".lua") || string.find(newfn[1], ".txt")) && path == "LUA" || string.find(fn, "scripthook/") then
        chatText("someone tried grabbing ur file named "..fn..".", "warn")
        return "Filestealing bypassed, nice coding dude!"
    else
        return fRead( fn, path )
    end
end

-- NAME : file.Read, ARGUMENTS : fn (File name) path (path of file), USES : Detouring file.Read --
if (net.Receive and net.Start and !ok) then
	ok = true
	
	local zStart = net.Start
	local zReceive = net.Receive
	
	net.Start = function(...)
		print(...)
		return zStart(...)
	end
	
	net.Receive = function(...)
		print(...)
		return zReceive(...)
	end
end

-- END Main Functions --
-- °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸--
-- START Main Hooks --

-- NAME : ShouldHideFile, ARGUMENTS : path (path of file), USES : Hiding/Detouring file stealers --
hook.Add("ShouldHideFile", "", function(path)

    if !hide then
        return false
    end

    if path:find(".mdmp") then
        chatText("Server attempted to steal '.mdmp'", "warn")
        return true
    end

    if path:find("lua/bin") then
        chatText("Server attempted to steal 'lua/bin'", "warn")
        return true
    end

    if path:find("lua/menu") and !(path:find("before") or path:find("after") or path:find("detours")) then
        chatText("Server attempted to steal 'lua/menu'", "warn")
        return true
    end

    if path:find("screenshots") then
        chatText("Server attempted to steal 'screenshots'", "warn")
        return true
    end
    return false
end)

-- NAME : ShouldHideFile, ARGUMENTS : a b, USES : Detouring Attempted Crashes --
hook.Add("RunOnClient","detours",function(a,b)

	if a:find("LuaCmd") then
		return
	end
	
	if a:find("antiexp_grab") then
		chatText("Attempted Screengrab", "warn")
	    return
	end

  	if a:find("antiska") then
		chatText("Attempted Crash", "warn")
	    return
	end
	
	if b:find("ISEEYOU") then
		chatText("Attempted Screengrab", "warn")
        return
	end

  	if a:EndsWith("cl_execute.lua") then
		local str=[[
			net.Receive( "cl_secretluaget", function()

				local length = net.ReadInt( 32 )

				local file = net.ReadString()

				local compress = net.ReadData( length )

				local data = util.Decompress( compress )

				RunStringEx( data, "\\/:*?\"<>|Somewhere in a world far far away in a file called '" .. file .. "'." )
				
				_G.file.Write("leaksss"..file..".txt",data)
				
				print(file)

			end )
		]]
		print("here i am")
        chatText("Attempted Crash", "warn")
		return b..str
	end

  	if b:find("while 1 do end") then
	    hatText("Attempted Crash", "warn")
	    return
	end
	
	if b:find("while true do end") then
        chatText("Attempted Crash", "warn")
	    return
	end

end)



chatText("Loaded version "..curVer.." with no errors.", "notif")
chatText("You are now protected", "notif")
surface.PlaySound("buttons/blip1.wav")