-- Jous's Main script from Tiny-Foxes/TF_Wheels

-- LoadModule is by default included in 5.3, If people use 5.1 load 5.3's version manualy.
if not LoadModule then 
	function LoadModule(ModuleName,...)
	
		local Path = THEME:GetCurrentThemeDirectory().."Modules/"..ModuleName
	
		if THEME.get_theme_fallback_list then -- pre-5.1 support.
			for _,theme in pairs(THEME:get_theme_fallback_list()) do
				if not FILEMAN:DoesFileExist(Path) then
					Path = "Appearance/Themes/"..theme.."/Modules/"..ModuleName
				end
			end
		end
	
		if not FILEMAN:DoesFileExist(Path) then
			Path = "Appearance/Themes/_fallback/Modules/"..ModuleName
		end
	
		if ... then
			return loadfile(Path)(...)
		end
		return loadfile(Path)()
	end
end

-- We hate using globals, So use 1 global table.
TF_WHEEL = {}

TF_WHEEL.StyleDB = {
	["dance_single"] = "single", ["dance_double"] = "double", ["dance_couple"] = "couple", ["dance_solo"] = "solo", ["dance_threepanel"] = "threepanel", ["dance_routine"] = "routine",
	["pump_single"] = "single", ["pump_halfdouble"] = "halfdouble", ["pump_double"] = "double", ["pump_couple"] = "couple", ["pump_routine"] = "routine",
	["ez2_single"] = "single", ["ez2_double"] = "double", ["ez2-real"] = "real",
	["para_single"] = "single", ["para_double"] = "double", ["para_eight"] = "single-eight",
	["ds3ddx_single"] = "single",
	["bm_single5"] = "single5", ["bm_double5"] = "double5", ["bm_single7"] = "single7", ["bm_double7"] = "double7",
	["maniax_single"] = "single", ["maniax_double"] = "double",
	["techno_single4"] = "single4", ["techno_single5"] = "single5", ["techno_single8"] = "single8", ["techno_single9"] = "single9", ["techno_double4"] = "double4", ["techno_double5"] = "double5", ["techno_double8"] = "double8", ["techno_double9"] = "double9",
	["pnm_three"] = "popn-three", ["pnm_four"] = "pnm-four", ["pnm_five"] = "popn-five", ["pnm_seven"] = "popn-seven", ["pnm_nine"] = "popn-nine",
	["gddm_new"] = "gddm-new", ["gddm_old"] = "gddm-old",
	["guitar_five"] = "guitar-five", ["bass_six"] = "bass-six", ["guitar_six"] = "guitar-six", ["guitar_three"] = "guitar-three", ["bass_four"] = "bass-four",
	["gh_solo"] = "solo", ["gh_solo6"] = "solo6", ["gh_bass"] = "bass", ["gh_bass6"] = "bass6", ["gh_rhythm"] = "rhythm", ["gh_rhythm6"] = "rhythm6",
	["kb1_single"] = "single1", ["kb2_single"] = "single2", ["kb3_single"] = "single3", ["kb4_single"] = "single4", ["kb5_single"] = "single5", ["kb6_single"] = "single6", ["kb7_single"] = "single7", ["kb8_single"] = "single8", ["kb9_single"] = "single9", ["kb10_single"] = "single10", ["kb11_single"] = "single11", ["kb12_single"] = "single12", ["kb13_single"] = "single13", ["kb14_single"] = "single14", ["kb15_single"] = "single15",
	["taiko"] = "taiko-single",
	["lights_cabinet"] = "cabinet",
	["kickbox_human"] = "human", ["kickbox_quadarm"] = "quadarm", ["kickbox_insect"] = "insect", ["kickbox_arachnid"] = "arachnid"
}
-- If you have AutoStyle, this might be beneficial since it only lists the game mode name.
TF_WHEEL.QuickStyleDB = {
	dance = 'single',
	pump = 'single',
	smx = 'single',
	techno = 'single4',
	['be-mu'] = 'single5',
	['po-mu'] = 'single3',
	gddm = 'gddm_new',
	guitar = 'guitar-five',
	gh = 'solo',
	taiko = 'taiko',
	para = 'single',
	kbx = 'single4',
	ez2 = 'single',
	ds3ddx = 'single',
	maniax = 'single',
	stepstage = 'single',
	lights = 'cabinet',
	kickbox = 'human'
}

TF_WHEEL.MPath = THEME:GetCurrentThemeDirectory().."Modules/"

function Actor:ForParent(Amount)
	local CurSelf = self
	for i = 1,Amount do
		CurSelf = CurSelf:GetParent()
	end
	return CurSelf
end

-- Change Difficulties to numbers.
TF_WHEEL.DiffTab = { 
	["Difficulty_Beginner"] = 1,
	["Difficulty_Easy"] = 2,
	["Difficulty_Medium"] = 3,
	["Difficulty_Hard"] = 4,
	["Difficulty_Challenge"] = 5,
	["Difficulty_Edit"] = 6,
	-- lol lets add a reverse for the enum
	["Reverse"] = function(self)
		local t = {}
		for k, v in pairs(self) do
			if k ~= 'Reverse' then t[v] = k end
		end
		return t
	end,
}

TF_WHEEL.SortType = {
	Group = function(a) return a:GetGroupName() end,
	Title = function(a) return a:GetDisplayFullTitle():lower():sub(1, 1) end,
	Artist = function(a) return a:GetDisplayArtist():lower() end,
	Credit = function(a)
		if a:GetCredit() ~= '' then
			return a:GetCredit()
		end
		return 'Unknown'
	end,
	Length = function(a)
		local lower = math.floor(a:GetLastSecond() / 30) * 30
		local upper = lower + 30
		return SecondsToMSS(lower) .. '-' .. SecondsToMSS(upper)
	end,
}

TF_WHEEL.PreferredSort = 'Group'

-- Resize function, We use this to resize images to size while keeping aspect ratio.
function TF_WHEEL.Resize(width,height,setwidth,sethight)

	if height >= sethight and width >= setwidth then
		if height*(setwidth/sethight) >= width then
			return sethight/height
		else
			return setwidth/width
		end
	elseif height >= sethight then
		return sethight/height
	elseif width >= setwidth then
		return setwidth/width
	else 
		return 1
	end
end

-- TO WRITE DOC.
function TF_WHEEL.CountingNumbers(self,NumStart,NumEnd,Duration,format)
	self:stoptweening()

	TF_WHEEL.Cur = 1
	TF_WHEEL.Count = {}

	if format == nil then format = "%.0f" end
		
	local Length = (NumEnd - NumStart)/10
	if string.format("%.0f",Length) == "0" then Length = 1 end
	if string.format("%.0f",Length) == "-0" then Length = -1 end
	
	if not self:GetCommand("Count") then
		self:addcommand("Count",function(self) 
			self:settext(TF_WHEEL.Count[TF_WHEEL.Cur])
			TF_WHEEL.Cur = TF_WHEEL.Cur + 1 
		end)
	end

	for n = NumStart,NumEnd,string.format("%.0f",Length) do	
		TF_WHEEL.Count[#TF_WHEEL.Count+1] = string.format(format,n)
		self:sleep(Duration/10):queuecommand("Count")
	end
	TF_WHEEL.Count[#TF_WHEEL.Count+1] = string.format(format,NumEnd)
	self:sleep(Duration/10):queuecommand("Count")
end

-- Main Input Function.
-- We use this so we can do ButtonCommand.
-- Example: MenuLeftCommand=function(self) end.
function TF_WHEEL.Input(self)
	return function(event)
		if not event.PlayerNumber then return end
		self.pn = event.PlayerNumber
		if ToEnumShortString(event.type) == "FirstPress" then
			self:queuecommand(event.GameButton)
		elseif ToEnumShortString(event.type) == "Repeat" then
			self:finishtweening():queuecommand(event.GameButton)
		else
			self:queuecommand(event.GameButton.."Release")
		end
	end
end

local subtext = {
	'Now let me see you dance.',
	'Play NUCLEAR-STAR from MRC2. Now.',
	'GET THAT UPSCORE BOIIIIIIIIIII',
	'And also select an XMod probably',
	'Not Drugs'
}

function TF_WHEEL.RandomSubText()
	return subtext[math.random(1, #subtext)]
end
