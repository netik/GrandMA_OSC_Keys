-- !! On any showfile, make sure to run the plugin from the pool once before using it over OSC !!
-- !! Also do this after changing the settings below !!

-- source: https://riksolo.com/blog/grandma3-osc-keys/

-- Edit the variables below to set your preferences for where things are stored

-- The plugin uses and re-assigns 10 quickey pool items.
-- this should be set so they don't interfere with the rest of your show
local first_quickey = 101;

-- The plugin also uses 10 blank execs. As with the quickeys, make sure these are somewhere out of the way
local exec_page = 5;
local first_exec = 181;

-- No need to edit anything underneath this line,
-- unless you want to change how the plugin actually functions

local RB_OSCKey_map = {}

local function setup()
	RB_OSCKey_map = {}
	-- In MA3, "Store page N" targets the wrong object type and often errors with
	-- "cannot create object: store page N". Executor pages are not created that way.
	-- Per MA help: the executor page must exist before Assign — create/ensure
	-- exec page exec_page in the show (e.g. playback/executor page bar) first.
	Cmd("Store quickey " .. first_quickey .. " thru " .. first_quickey + 9)
	Cmd("Assign quickey " .. first_quickey .. " thru " .. first_quickey + 9 .. " at page " .. exec_page .. " exec " .. first_exec .. " thru " .. first_exec + 9)
end

local function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function findPressed(keycode)
	for index, code in ipairs(RB_OSCKey_map) do
		if(code == keycode) then
			return index
		end
	end
	
	return nil
end

local function findFreeIndex()
	local length = tableLength(RB_OSCKey_map)
	Printf("length " .. length)

	for i=1,(length + 1),1 do
		if(RB_OSCKey_map[i] == nil or RB_OSCKey_map[i] == "") then
			return i
		end
	end
	
	Printf('default')
	return length + 1
end

local function printMap()
	Printf("=== map ===")
	for index, val in ipairs(RB_OSCKey_map) do
		local printval = val
		if(val == nil) then
			printval = "nil"
		end
		Printf(index .. ":" .. printval)
	end
	Printf("===========")
end

local function main(display, rawArgs)
	if(rawArgs == "print") then
		printMap()
		return
	end
	
	if(rawArgs == "reset") then
		RB_OSCKey_map = nil
		return
	end
	
	if(rawArgs == nil) then
		setup()
		return
	end

	if(RB_OSCKey_map == nil) then
		setup()
	end	

	local args = {}
	
	for arg in string.gmatch(rawArgs, '[^ ]+') do
		args[#args+1] = arg
	end
	
	
	local keycode = args[1]
	local state = args[2] -- "press"/"release"
	local pressedIndex = findPressed(keycode)

	if(state == "press" and pressedIndex == nil) then
		local index = findFreeIndex()
		RB_OSCKey_map[index] = keycode
		GetObject("Quickey " .. first_quickey + index - 1)['CODE'] = keycode
		CmdIndirect("Press Page ".. exec_page .." Exec " .. first_exec - 1 + index)
	elseif (state == "release" and pressedIndex ~= nil) then
		CmdIndirect("Unpress Page ".. exec_page .." Exec " .. first_exec - 1 + pressedIndex)
		RB_OSCKey_map[pressedIndex] = ""
	end	
end

return main
