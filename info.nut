SELF_VERSION <- 1;

class GenerationMod extends GSInfo
{
  function GetAuthor()      { return "IRONy"; }
  function GetName()        { return "Generation Mod"; }
  function GetDescription() { return "Modification of generating economic models"; }
  function GetVersion()     { return SELF_VERSION; }
  function GetDate()        { return "2020-10-07"; }
  function CreateInstance() { return "GenerationMod"; }
  function GetShortName()   { return "GenMod"; }
  function GetAPIVersion()  { return "1.3"; }
  function GetUrl()         { return ""; }
  
    function GetSettings() {
		 AddSetting
		 ({
			 name = "MAX_OIL_DIST", 
			 description = "General: Max distance from edge for Oil Refineries", 
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
			 name = "MULTI_IND_TOWN", 
			 description = "General: Allow multiple similar industries per town?", 
			 easy_value = 0, 
			 medium_value = 0, 
			 hard_value = 0, 
			 custom_value = 0, 
			 flags = CONFIG_BOOLEAN | CONFIG_INGAME
		 }); 	
		 AddSetting
		 ({
			 name = "PROS_BOOL", 
			 description = "General: Prospect abnormal industries rather than use methods?", 			// Only affects climate specific cases, not foolproof
			 easy_value = 0, 
			 medium_value = 0, 
			 hard_value = 0, 
			 custom_value = 0, 
			 flags = CONFIG_BOOLEAN | CONFIG_INGAME
		 });
		 AddSetting
		 ({
			 name = "MANAGE_BOOL", 
			 description = "Manage: Manage industry amount?", 
			 easy_value = 1, 
			 medium_value = 1, 
			 hard_value = 1, 
			 custom_value = 1, 
			 flags = CONFIG_INGAME | CONFIG_BOOLEAN
		 });
		AddSetting
		 ({
			 name = "BUILD_SPEED", 
			 description = "Manage: Industry build rate (months)", 
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
			 description = "Manage: Industry build limit (per refresh)", 
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
			description = "Density: Total industries", 
			easy_value = 80, 
			medium_value = 25, 
			hard_value = 10, 
			custom_value = 55, 
			flags = 0, 
			min_value = 5, 
			max_value = 100, 
			step_size = 5
		});
		AddLabels("DENSITY_IND_TOTAL", 
		{
			_5 = "Minimal", 
			_10 = "Very Low", 
			_25 = "Low", 
			_55 = "Normal", 
			_80 = "High"
		});	 
		AddSetting
		({
			name = "DENSITY_IND_MIN", 
			description = "Density: Min industries %", 
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
			description = "Density: Max industries %", 
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
			description = "Density: Primary industries proportion", 
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
			description = "Density: Secondary industries proportion", 
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
			description = "Density: Tertiary industries proportion", 
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
			description = "Density: Special industries proportion", 
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
			description = "Density: Primary industries spawning method", 
			easy_value = 2, 
			medium_value = 3, 
			hard_value = 3, 
			custom_value = 3, 
			flags = 0, 
			min_value = 1, 
			max_value = 4
		});
		AddLabels("DENSITY_RAW_METHOD", 
		{
			_1 = "Town", 
			_2 = "Clusters", 
			_3 = "Scattered", 
			_4 = "Random"
		});
		AddSetting
		({
			name = "DENSITY_PROC_METHOD", 
			description = "Density: Secondary industries spawning method", 
			easy_value = 1, 
			medium_value = 1, 
			hard_value = 3, 
			custom_value = 1, 
			flags = 0, 
			min_value = 1, 
			max_value = 4
		});
		AddLabels("DENSITY_PROC_METHOD", 
		{
			_1 = "Town", 
			_2 = "Clusters", 
			_3 = "Scattered", 
			_4 = "Random"
		});
		AddSetting
		({
			name = "DENSITY_TERT_METHOD", 
			description = "Density: Tertiary industries spawning method", 
			easy_value = 3, 
			medium_value = 4, 
			hard_value = 4, 
			custom_value = 4, 
			flags = 0, 
			min_value = 1, 
			max_value = 4
		});
		AddLabels("DENSITY_TERT_METHOD", 
		{
			_1 = "Town", 
			_2 = "Clusters", 
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
			name = "CLUSTER_NODES", 
			description = "Cluster: Maximum industries per cluster", 
			easy_value = 6, 
			medium_value = 8, 
			hard_value = 10, 
			custom_value = 8, 
			flags = CONFIG_INGAME, 
			min_value = 3, 
			max_value = 15,
			step_size = 1
		});					
		AddSetting
		({
			name = "CLUSTER_RADIUS_MIN", 
			description = "Cluster: Minimum distance between same cluster industries", 
			easy_value = 10, 
			medium_value = 10, 
			hard_value = 10, 
			custom_value = 10, 
			flags = CONFIG_INGAME, 
			min_value = 5, 
			max_value = 15,
			step_size = 5
		});							
		AddSetting
		({
			name = "CLUSTER_RADIUS_MAX", 
			description = "Cluster: Maximum distance between same cluster industries", 
			easy_value = 20, 
			medium_value = 20, 
			hard_value = 20, 
			custom_value = 20, 
			flags = CONFIG_INGAME, 
			min_value = 15, 
			max_value = 30,
			step_size = 5
		});		
		AddSetting
		({
			name = "CLUSTER_MIN_NODE", 
			description = "Cluster: Minimum distance between clusters", 
			easy_value = 40, 
			medium_value = 30, 
			hard_value = 20, 
			custom_value = 30, 
			flags = CONFIG_INGAME, 
			min_value = 10, 
			max_value = 60,
			step_size = 5
		});				
		AddSetting
		({
			name = "CLUSTER_MIN_TOWN", 
			description = "Cluster: Minimum distance from towns", 
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
			name = "CLUSTER_MIN_IND", 
			description = "Cluster: Minimum distance from industries", 
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
			name = "TOWN_MIN_POP", 
			description = "Town: Minimum population", 
			easy_value = 750, 
			medium_value = 750, 
			hard_value = 750, 
			custom_value = 750, 
			flags = CONFIG_INGAME, 
			min_value = 0, 
			max_value = 2000,
			step_size = 250
		});				
		AddSetting
		({
			name = "TOWN_MIN_RADIUS", 
			description = "Town: Minimum distance from town factor", 
			easy_value = 30, 
			medium_value = 25, 
			hard_value = 10, 
			custom_value = 15, 
			flags = CONFIG_INGAME, 
			min_value = 0, 
			max_value = 50,
			step_size = 5
		});						
		AddSetting
		({
			name = "TOWN_MAX_RADIUS", 
			description = "Town: Maximum distance from town", 
			easy_value = 20, 
			medium_value = 25, 
			hard_value = 30, 
			custom_value = 25, 
			flags = CONFIG_INGAME, 
			min_value = 0, 
			max_value = 30,
			step_size = 5
		});							
		AddSetting
		({
			name = "TOWN_MAX_IND", 
			description = "Town: Maximum total industries per town", 
			easy_value = 9, 
			medium_value = 7, 
			hard_value = 5, 
			custom_value = 7, 
			flags = CONFIG_INGAME, 
			min_value = 3, 
			max_value = 10,
			step_size = 1
		});								
		AddSetting
		({
			name = "TOWN_MIN_IND", 
			description = "Town: Minimum distance from other industries", 
			easy_value = 5, 
			medium_value = 7, 
			hard_value = 9, 
			custom_value = 7, 
			flags = CONFIG_INGAME, 
			min_value = 5, 
			max_value = 15,
			step_size = 1
		});	
		 AddSetting
		 ({
			 name = "TOWN_MULTI_BOOL", 
			 description = "Town: Multiple same industries in town?", 
			 easy_value = 0, 
			 medium_value = 0, 
			 hard_value = 0, 
			 custom_value = 0, 
			 flags = CONFIG_BOOLEAN | CONFIG_INGAME
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
			name = "SPEC_RIG_MINYEAR", 
			description = "Special: Minimum year for Oil Rigs", 
			easy_value = 1950, 
			medium_value = 1950, 
			hard_value = 1950, 
			custom_value = 1950, 
			flags = CONFIG_INGAME, 
			min_value = 1900, 
			max_value = 2050,
			step_size = 1
		 });	
		 AddSetting
		 ({
			name = "SPEC_WTR_MINPOP", 
			description = "Special: Minimum town pop for Water Towers", 
			easy_value = 800, 
			medium_value = 1000, 
			hard_value = 1200, 
			custom_value = 1000, 
			flags = CONFIG_INGAME, 
			min_value = 500, 
			max_value = 3000,
			step_size = 100
		 });	
		 AddSetting
		 ({
			 name = "SPEC_LBR_BOOL", 
			 description = "Special: Build Lumber Mills?", 
			 easy_value = 0, 
			 medium_value = 0, 
			 hard_value = 0, 
			 custom_value = 0, 
			 flags = CONFIG_BOOLEAN | CONFIG_INGAME
		 });
	}	
}

RegisterGS(GenerationMod());
