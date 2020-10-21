SELF_VERSION <- 1;

class GenerationMod extends GSInfo 
{
	function GetAuthor()		{ return "IRONy"; }
	function GetName()		{ return "Generation Mod"; }
	function GetDescription() 	{ return "Modification of generating economic models"; }
	function GetVersion()		{ return SELF_VERSION; }
	function GetDate()		{ return "2020-10-07"; }
	function CreateInstance()	{ return "GenerationMod"; }
	function GetShortName()		{ return "GenM"; }
	function GetAPIVersion()	{ return "1.3"; }
	function GetUrl()		{ return ""; }
	function GetSettings()
	{	
		 AddSetting
		 ({
			 name = "MULTI_IND_TOWN", 
			 description = "Allow multiple similar industries per town (must be on)", 
			 easy_value = 1, 
			 medium_value = 1, 
			 hard_value = 1, 
			 custom_value = 1, 
			 flags = CONFIG_BOOLEAN | CONFIG_INGAME
		 }); 	
		 AddSetting
		 ({
			 name = "PROS_BOOL", 
			 description = "Prospect abnormal industries rather than use methods (must be on)",
			 easy_value = 1, 
			 medium_value = 1, 
			 hard_value = 1, 
			 custom_value = 1, 
			 flags = CONFIG_BOOLEAN | CONFIG_INGAME
		 });
		 AddSetting
		 ({
			 name = "MANAGE_BOOL", 
			 description = "Industry amount (must be on)", 
			 easy_value = 1, 
			 medium_value = 1, 
			 hard_value = 1, 
			 custom_value = 1, 
			 flags = CONFIG_INGAME | CONFIG_BOOLEAN
		 });
		AddSetting
		 ({
			 name = "BUILD_SPEED", 
			 description = "Industry build rate (months)", 
			 easy_value = 6, 
			 medium_value = 12, 
			 hard_value = 18 
			 custom_value = 12, 
			 flags = CONFIG_INGAME, 
			 min_value = 3, 
			 max_value = 48,
			 step_size = 3
		 });
		 AddSetting
		 ({
			 name = "BUILD_LIMIT", 
			 description = "Industry build limit (per period)", 
			 easy_value = 4, 
			 medium_value = 2, 
			 hard_value = 1, 
			 custom_value = 1, 
			 flags = CONFIG_INGAME, 
			 min_value = 1, 
			 max_value = 5
			 step_size = 1
		 });
		AddSetting
		({
			name = "log_level", 
			description = "Debug: Log level (higher = print more)", 
			easy_value = 1, 
			medium_value =1, 
			hard_value = 1, 
			custom_value = 1, 
			flags = CONFIG_INGAME, 
			min_value = 1, 
			max_value = 4
		});	
		AddSetting
		({
			name = "DENSITY_IND_TOTAL", 
			description = "Total industries", 
			easy_value = 90, 
			medium_value = 50, 
			hard_value = 10, 
			custom_value = 50, 
			flags = 0, 
			min_value = 10, 
			max_value = 90, 
			step_size = 20
		});
		AddLabels("DENSITY_IND_TOTAL", 
		{
			_10 = "Minimal (10)", 
			_30 = "Very Low (30)", 
			_50 = "Low (50)", 
			_70 = "Normal (70)", 
			_90 = "High (90)"
		});	 
		AddSetting
		({
			name = "DENSITY_IND_MIN", 
			description = "Min industries %", 
			easy_value = 75, 
			medium_value = 50, 
			hard_value = 25, 
			custom_value = 50, 
			flags = 0, 
			min_value = 25, 
			max_value = 75, 
			step_size = 5
		});	 
		AddSetting
		({
			name = "DENSITY_IND_MAX", 
			description = "Max industries %", 
			easy_value = 150, 
			medium_value = 125, 
			hard_value = 100, 
			custom_value = 125, 
			flags = 0, 
			min_value = 100, 
			max_value = 150, 
			step_size = 5
		});	 
		AddSetting
		({
			name = "DENSITY_RAW_PROP", 
			description = "Primary industries proportion", 
			easy_value = 6, 
			medium_value = 6, 
			hard_value = 6, 
			custom_value = 6, 
			flags = 0, 
			min_value = 1, 
			max_value = 16, 
			step_size = 1
		});	 
		AddSetting
		({
			name = "DENSITY_PROC_PROP", 
			description = "Secondary industries proportion", 
			easy_value = 3, 
			medium_value = 3, 
			hard_value = 3, 
			custom_value = 3, 
			flags = 0, 
			min_value = 1, 
			max_value = 16, 
			step_size = 1
		});	 
		AddSetting
		({
			name = "DENSITY_TERT_PROP", 
			description = "Tertiary industries proportion", 
			easy_value = 1, 
			medium_value = 1, 
			hard_value = 1, 
			custom_value = 1, 
			flags = 0, 
			min_value = 1, 
			max_value = 16, 
			step_size = 1
		}); 
		AddSetting
		({
			name = "DENSITY_SPEC_PROP", 
			description = "Special industries proportion", 
			easy_value = 1, 
			medium_value = 1, 
			hard_value = 1, 
			custom_value = 1, 
			flags = 0, 
			min_value = 1, 
			max_value = 16, 
			step_size = 1
		});
		AddSetting
		({
			name = "DENSITY_RAW_METHOD", 
			description = "Primary industries spawning method", 
			easy_value = 3, 
			medium_value = 3, 
			hard_value = 3, 
			custom_value = 3, 
			flags = 0, 
			min_value = 3, 
			max_value = 4
		});
		AddLabels("DENSITY_RAW_METHOD", 
		{ 
                        _3 = "Scattered", 
  		        _4 = "Random"
		});
		AddSetting
		({
			name = "DENSITY_PROC_METHOD", 
			description = "Secondary industries spawning method", 
			easy_value = 3, 
			medium_value = 3, 
			hard_value = 3, 
			custom_value = 3, 
			flags = 0, 
			min_value = 3, 
			max_value = 4
		});
		AddLabels("DENSITY_PROC_METHOD", 
		{ 
			_3 = "Scattered", 
			_4 = "Random"
		});
		AddSetting
		({
			name = "DENSITY_TERT_METHOD", 
			description = "Tertiary industries spawning method", 
			easy_value = 3, 
			medium_value = 3, 
			hard_value = 3, 
			custom_value = 3, 
			flags = 0, 
			min_value = 3, 
			max_value = 4
		});
		AddLabels("DENSITY_TERT_METHOD", 
		{
			_3 = "Scattered", 
			_4 = "Random"
		});									
		AddSetting
		({
			name = "SCATTERED_MIN_TOWN", 
			description = "Scattered: Minimum distance from towns", 
			easy_value = 25, 
			medium_value = 20, 
			hard_value = 15, 
			custom_value = 20, 
			flags = CONFIG_INGAME, 
			min_value = 5, 
			max_value = 30,
			step_size = 5
		});		
		AddSetting
		({
			name = "SCATTERED_MIN_IND", 
			description = "Scattered: Minimum distance from industries", 
			easy_value = 20, 
			medium_value = 15, 
			hard_value = 10, 
			custom_value = 15, 
			flags = CONFIG_INGAME, 
			min_value = 5, 
			max_value = 30,
			step_size = 5
		});		
		 AddSetting
		 ({
			name = "SPEC_BANK_MINPOP", 
			description = "Special: Minimum town pop for Banks", 
			easy_value = 1200, 
			medium_value = 1200, 
			hard_value = 1200, 
			custom_value = 1200, 
			flags = CONFIG_INGAME, 
			min_value = 600, 
			max_value = 3000,
			step_size = 200
		 });	
		 AddSetting
		 ({
			 name = "MAX_OIL_DIST", 
			 description = "Max distance from edge for Oil Refineries", 
			 easy_value = 40, 
			 medium_value = 40, 
			 hard_value = 40, 
			 custom_value = 40, 
			 flags = CONFIG_INGAME, 
			 min_value = 12, 
			 max_value = 48,
			 step_size = 1
		 }); 	
		 AddSetting
		 ({
			name = "SPEC_RIG_MINYEAR", 
			description = "Minimum year for Oil Rigs", 
			easy_value = 1950, 
			medium_value = 1950, 
			hard_value = 1950, 
			custom_value = 1950, 
			flags = CONFIG_INGAME, 
			min_value = 1900, 
			max_value = 2050,
			step_size = 1
		 });	

	}	
}
RegisterGS(GenerationMod());
