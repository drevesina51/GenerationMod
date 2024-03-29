// Objectives

// 1) Maintain functionality but improve script performance
// 2) Extend script functionality into other 'post-map creation' initialization
// 3) Adding the ability to change certain values when creating interconnected industries
// 4) Increasing the realism of the generated map
// 5) Creating an opportunity for the player to adapt the game to their standards and ideals

// Imports
import("util.superlib", "SuperLib", 36);
Result 		<- SuperLib.Result;
Log 		<- SuperLib.Log;
Helper 		<- SuperLib.Helper;
ScoreList 	<- SuperLib.ScoreList;
Tile 		<- SuperLib.Tile;
Direction 	<- SuperLib.Direction;
Town 		<- SuperLib.Town;
Industry	<- SuperLib.Industry;

import("util.MinchinWeb", "MinchinWeb", 6);
SpiralWalker <- MinchinWeb.SpiralWalker;
						
// Extend GS class
class GenerationMod extends GSController{
	MAP_SIZE_X = 1.0;
	MAP_SIZE_Y = 1.0;
	MAP_SCALE = 1.0;
	
	BUILD_LIMIT = 0; 						                // Set from settings, in class constructor and each refresh.(initial is max ind per map, subs is max per refresh)
	CONTINUE_GS = null;								// True if whole script must continue.
	INIT_PERFORMED = false;								// True if GenerationMod.Init has run.
	LOAD_PERFORMED = false;								// Bool of load status
	FIRSTBUILD_PERFORMED = null;							// True if GenerationMod.Load OR GenerationMod.BuildIndustryClass has run.
	PRIMARY_PERFORMED = null;							// True if GenerationMod.BuildIndustryClass has run for primary industries.
	SECONDARY_PERFORMED = null;							// True if GenerationMod.BuildIndustryClass has run for secondary industries.
	TERTIARY_PERFORMED = null;							// True if GenerationMod.BuildIndustryClass has run for tertiary industries.
	SPECIAL_PERFORMED = null;							// True if GenerationMod.BuildIndustryClass has run for special industries.
	BUILD_SPEED = 0;								// Global build speed variable


	TOWNNODE_LIST_TOWN = [];							// Sub-array of town ids registered
	TOWNNODE_LIST_IND = []; 							// Sub-array of industry types, for town builder
	TOWNNODE_LIST_COUNT = [];							// Sub-array of industry count, for town builder
	
	IND_TYPE_LIST = 0;								// Is GSIndustryTypeList(), set in GenerationMod.Init.
	IND_TYPE_COUNT = 0;								// Count of industries in this.IND_TYPE_LIST, set in GenerationMod.Init.
	CARGO_PAXID = 0									// Passenger cargo ID, set in GenerationMod.Init.
	
	RAWINDUSTRY_LIST = [];								// Array of raw industry type ID's, set in GenerationMod.Init.
	RAWINDUSTRY_LIST_COUNT = 0;							// Count of primary industries, set in GenerationMod.Init.
	PROCINDUSTRY_LIST = [];								// Array of processor industry type ID's, set in GenerationMod.Init.
	PROCINDUSTRY_LIST_COUNT = 0;							// Count of secondary industries, set in GenerationMod.Init.
	TERTIARYINDUSTRY_LIST = [];							// Array of tertiary industry type ID's, set in GenerationMod.Init.
	TERTIARYINDUSTRY_LIST_COUNT = 0;						// Count of tertiary industries, set in GenerationMod.Init.
	SPECIALINDUSTRY_LIST = [];							// Array of special industry type ID's, set in GenerationMod.Init.
	SPECIALINDUSTRY_LIST_COUNT = 0;							// Count of special industries, set in GenerationMod.Init.
	SPECIALINDUSTRY_TYPES = ["Bank", "Oil Rig", "Water Tower", "Lumber Mill"];

	// User variables
	DENSITY_IND_TOTAL = 0;								// Set from settings, in GenerationMod.Init. Total industries, integer always >= 1
	DENSITY_IND_MIN = 0;								// Set from settings, in GenerationMod. Init.Min industry density %, float always < 1.
	DENSITY_IND_MAX = 0;								// Set from settings, in GenerationMod.Init. Max industry density %, float always > 1.
	DENSITY_RAW_PROP = 0;								// Set from settings, in GenerationMod.Init. Primary industry proportion, float always < 1.
	DENSITY_PROC_PROP = 0;								// Set from settings, in GenerationMod.Init. Secondary industry proportion, float always < 1.
	DENSITY_TERT_PROP = 0;								// Set from settings, in GenerationMod.Init. Tertiary industry proportion, float always < 1.
	DENSITY_SPEC_PROP = 0;								// Set from settings, in GenerationMod.Init. Special industry proportion, float always < 1.
	DENSITY_RAW_METHOD = 0;								// Set from settings, in GenerationMod.Init.
	DENSITY_PROC_METHOD = 0;							// Set from settings, in GenerationMod.Init.
	DENSITY_TERT_METHOD = 0;							// Set from settings, in GenerationMod.Init.

// construction
	constructor(){
		LOAD_PERFORMED = false;
		INIT_PERFORMED = false;
		CONTINUE_GS = true;
		MAP_SIZE_X = GSMap.GetMapSizeX();
		MAP_SIZE_Y = GSMap.GetMapSizeY();
		BUILD_LIMIT = GSController.GetSetting("BUILD_LIMIT");
		FIRSTBUILD_PERFORMED = false;
		PRIMARY_PERFORMED = false;
		SECONDARY_PERFORMED = false;
		TERTIARY_PERFORMED = false;
		SPECIAL_PERFORMED = false;
		
		// Create a new industry type list
		IND_TYPE_LIST = GSIndustryTypeList();
		// Count industry types
		IND_TYPE_COUNT = IND_TYPE_LIST.Count();
	}	
}
	
// Save function	
function GenerationMod::Save(){
	//Display save msg
	Log.Info("----------------------", Log.LVL_INFO);
	Log.Info("Saving data", Log.LVL_INFO);
	
	// Create the save data table
	local SV_DATA = {
						//SV_IND_TYPE_LIST = IND_TYPE_LIST
						SV_RAW = RAWINDUSTRY_LIST,
						SV_PROC = PROCINDUSTRY_LIST,
						SV_TERT = TERTIARYINDUSTRY_LIST,
						SV_SPECIAL = SPECIALINDUSTRY_LIST,
						SV_TOWNNODE_TOWN = TOWNNODE_LIST_TOWN,
						SV_TOWNNODE_IND = TOWNNODE_LIST_IND,
						SV_TOWNNODE_COUNT = TOWNNODE_LIST_COUNT
					};

	// Return save data to call
	this.ErrorHandler();
	return SV_DATA;
}

// Load function
function GenerationMod::Load(SV_VERSION, SV_TABLE){
	// Display load msg
	Log.Info("----------------------", Log.LVL_INFO);
	Log.Info("Loading data, saved with version " + SV_VERSION + " of game script", Log.LVL_INFO);
	
	// Loop through save table
	foreach(SV_KEY, SV_VAL in SV_TABLE){
		if(SV_KEY == "SV_IND_TYPE_LIST") IND_TYPE_LIST = SV_VAL;	
		if(SV_KEY == "SV_RAW") RAWINDUSTRY_LIST = SV_VAL;
		if(SV_KEY == "SV_PROC") PROCINDUSTRY_LIST = SV_VAL;
		if(SV_KEY == "SV_TERT") TERTIARYINDUSTRY_LIST = SV_VAL;
		if(SV_KEY == "SV_SPECIAL") SPECIALINDUSTRY_LIST = SV_VAL;
		if(SV_KEY == "SV_TOWNNODE_TOWN") TOWNNODE_LIST_TOWN = SV_VAL;
		if(SV_KEY == "SV_TOWNNODE_IND") TOWNNODE_LIST_IND = SV_VAL;
		if(SV_KEY == "SV_TOWNNODE_COUNT") TOWNNODE_LIST_COUNT = SV_VAL;
	}
	// Update load status
	LOAD_PERFORMED = true;
	FIRSTBUILD_PERFORMED = true;
	this.ErrorHandler();
}

// Program start function
function GenerationMod::Start(){
	// Welcome
	Log.Info("Starting Industry Constructor!", Log.LVL_INFO);

	// Welcome text
	//GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.WELCOME), GSCompany.COMPANY_INVALID);

	// Pause
	GSGame.Pause();

	this.Init();

	GSGame.Unpause();
	
	// Call build function if new game
	if(FIRSTBUILD_PERFORMED == false){
		// Display start msg
		//GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.START), GSCompany.COMPANY_INVALID);
		
		// Build function
		this.BuildIndustry();
		this.ErrorHandler();
		
		// Display end start msg
		//GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.END_START), GSCompany.COMPANY_INVALID);
	}

	// First sleep
	this.Sleep(Helper.Max(1, GSController.GetSetting("BUILD_SPEED") * 2252));
	
	//Define local loop variables
	local LOOP_START_TICK = 0;
	local TICKS_USED = 0;
	
	// Main loop, while GS is a go
	while (CONTINUE_GS == true){		
		// While paused, pause script
		while(GSGame.IsPaused() == true){
			this.Sleep(100)
		}
		// Get start tick
		LOOP_START_TICK = GSController.GetTick();
		
		// Assign build limit
		this.BUILD_LIMIT = GSController.GetSetting("BUILD_LIMIT");

		// Call build function, if manage is set in settings
		if(GSController.GetSetting("MANAGE_BOOL") == 1){
			this.BuildIndustry();
			this.ErrorHandler();
		}
		
		// Call event handler function
		this.HandleEvents();
		this.ErrorHandler();
		
		// Pause for x months
		// - Assign used ticks
		TICKS_USED = GSController.GetTick() - LOOP_START_TICK;
		// - 74 ticks = 1 day , 518 ticks = 1 week, 2252 ticks = 1 month, 27029 ticks = 1 year
		this.Sleep(Helper.Max(1, (GSController.GetSetting("BUILD_SPEED") * 2252) - TICKS_USED));
	}
	// Display exit
	Log.Warning("The game script has ended, and will now crash.", Log.LVL_INFO);
}

// Initialization function
function GenerationMod::Init(){
	// Check GS continue
	if(CONTINUE_GS == false) return;
	
	// Display status
	Log.Info("----------------------", Log.LVL_INFO);
	Log.Info("Initializing...", Log.LVL_INFO);
	
	// Set Advanced Setting parameters
	// - Check for multi ind per town setting
	// - - Check if valid
	if(GSGameSettings.IsValid("multiple_industry_per_town") == true){
		// - - Set to one in parameters
		GSGameSettings.SetValue("multiple_industry_per_town", GSController.GetSetting("MULTI_IND_TOWN"));
		// - - Check if false
		if(GSGameSettings.GetValue("multiple_industry_per_town") == 0) Log.Warning("Multiple industries per town disabled, will slow down or prevent some build methods!", Log.LVL_INFO);
	}
	// -- Else invalid
	else Log.Error("Multiple industries per town setting could not be detected!", Log.LVL_INFO);
	// - Check for oil ind distance setting
	// - - Check if valid
	if(GSGameSettings.IsValid("oil_refinery_limit") == true){
		// - - Set to one in parameters
		GSGameSettings.SetValue("oil_refinery_limit", GSController.GetSetting("MAX_OIL_DIST"));
		}
	// -- Else invalid
	else Log.Error("Max distance from edge for Oil Refineries setting could not be detected!", Log.LVL_INFO);

	// Assign PAX cargo id
	// - Create cargo list
	local CARGO_LIST = GSCargoList();
	// - Loop for each cargo
	foreach (CARGO_ID in CARGO_LIST){
		// - Assign passenger cargo ID 
		if(GSCargo.GetTownEffect(CARGO_ID) == GSCargo.TE_PASSENGERS) CARGO_PAXID = CARGO_ID;
	}

	// If load has not happened, then this is a new game
	if (this.LOAD_PERFORMED == false){
		// Display status
		Log.Info(">This is a new game, preparing...", Log.LVL_INFO);
		
		// Check if there are industries on map (if user has not set to funding only error...)
		// Define new industry list
		local IND_LIST = GSIndustryList();
		// Count industries
		local IND_LIST_COUNT = IND_LIST.Count();
			
		// If there are industries on the map
		if (IND_LIST_COUNT > 0)	{
			// Display error
			Log.Warning(">There are " + IND_LIST_COUNT + " industries on the map, when there must be none!", Log.LVL_INFO);
			
			// Set GS continue to false
			CONTINUE_GS = false;
			
			// End function
			return;
		}
		// Else no industries
		else{
			local IS_SPECIAL = false;
			local IND_NAME = "";
			// Display status msg
			Log.Info(">There are " + IND_TYPE_COUNT + " industry types.", Log.LVL_INFO);

			// Loop through list
			foreach(IND_ID, _ in IND_TYPE_LIST){
				// Get current ID name
				IND_NAME = GSIndustryType.GetName(IND_ID);
				
				// Loop through special list
				foreach(SPECIAL_NAME in SPECIALINDUSTRY_TYPES){
					// If current ID name is a special = SPECIALINDUSTRY_LIST
					if(IND_NAME == SPECIAL_NAME){
						// Display industry type name msg
						Log.Info(" ~Special Industry: " + IND_NAME, Log.LVL_SUB_DECISIONS);
						
						// Add industry id to raw list
						SPECIALINDUSTRY_LIST.push(IND_ID);
					
						// Assign true and end loop
						IS_SPECIAL = true;
						break;
					}
				}
				
				// If the current ID was special
				if(IS_SPECIAL == true){
					// Reset and jump to next id
					IS_SPECIAL = false;
					continue;
				}

				// If current ID is a raw producer = RAWINDUSTRY_LIST
				if (GSIndustryType.IsRawIndustry(IND_ID)){
					// Display industry type name msg
					Log.Info(" ~Raw Industry: " + IND_NAME, Log.LVL_SUB_DECISIONS);
			
					// Add industry id to raw list
					RAWINDUSTRY_LIST.push(IND_ID);
				}
				//else not a raw producer
				else{
					// If current ID is a processor = PROCINDUSTRY_LIST
					if (GSIndustryType.IsProcessingIndustry(IND_ID)){
						// Display industry type name msg
						Log.Info(" ~Processor Industry: " + IND_NAME, Log.LVL_SUB_DECISIONS);
						
						// Add industry id to processor list
						PROCINDUSTRY_LIST.push(IND_ID);
					}
					// Else is an other industry = TERTIARYINDUSTRY_LIST
					else{
						// Display industry type name msg
						Log.Info(" ~Tertiary Industry: " + IND_NAME, Log.LVL_SUB_DECISIONS);
						
						// Add industry id to other list
						TERTIARYINDUSTRY_LIST.push(IND_ID);
					}
				}
			}
		}
	}
	// Else not a new game
	else{
		// Display status msg
		Log.Info(">This is a loaded game, preparing...", Log.LVL_INFO);
	}
	
	// Count lists
	RAWINDUSTRY_LIST_COUNT = RAWINDUSTRY_LIST.len();
	PROCINDUSTRY_LIST_COUNT = PROCINDUSTRY_LIST.len();
	TERTIARYINDUSTRY_LIST_COUNT = TERTIARYINDUSTRY_LIST.len();
	SPECIALINDUSTRY_LIST_COUNT = SPECIALINDUSTRY_LIST.len();
	
	// Display statuses
	Log.Info(">There are " + RAWINDUSTRY_LIST_COUNT + " Primary industry types.", Log.LVL_INFO);
	Log.Info(">There are " + PROCINDUSTRY_LIST_COUNT + " Secondary industry types.", Log.LVL_INFO);
	Log.Info(">There are " + TERTIARYINDUSTRY_LIST_COUNT + " Tertiary industry types.", Log.LVL_INFO);
	Log.Info(">There are " + SPECIALINDUSTRY_LIST_COUNT + " Special industry types.", Log.LVL_INFO);
	
	// Import settings
		// - Determine map multiplier, as float
		MAP_SCALE = (MAP_SIZE_X / 256.0) * (MAP_SIZE_Y / 256.0)
		
		// - Display status msg
		Log.Info(">Map size scale is: " + MAP_SCALE, Log.LVL_INFO);
		
		// - Assign settings
		local RAW_PROP = GSController.GetSetting("DENSITY_RAW_PROP").tofloat();
			if(RAWINDUSTRY_LIST_COUNT < 1) RAW_PROP = 0.0;
		local PROC_PROP = GSController.GetSetting("DENSITY_PROC_PROP").tofloat();
			if(PROCINDUSTRY_LIST_COUNT < 1) PROC_PROP = 0.0;
		local TERT_PROP = GSController.GetSetting("DENSITY_TERT_PROP").tofloat();
			if(TERTIARYINDUSTRY_LIST_COUNT < 1) TERT_PROP = 0.0;
		local SPEC_PROP = GSController.GetSetting("DENSITY_SPEC_PROP").tofloat();
			if(SPECIALINDUSTRY_LIST_COUNT < 1) SPEC_PROP = 0.0;
		local TOTAL_PROP = RAW_PROP + PROC_PROP + TERT_PROP + SPEC_PROP;
		
		DENSITY_IND_TOTAL = (GSController.GetSetting("DENSITY_IND_TOTAL") * MAP_SCALE).tointeger();
			// Make 1 if below
		if (DENSITY_IND_TOTAL < 1) DENSITY_IND_TOTAL = 1;
		DENSITY_IND_MIN = GSController.GetSetting("DENSITY_IND_MIN").tofloat() / 100.0;
		DENSITY_IND_MAX = GSController.GetSetting("DENSITY_IND_MAX").tofloat() / 100.0;
		DENSITY_RAW_PROP = (GSController.GetSetting("DENSITY_RAW_PROP").tofloat() / TOTAL_PROP);
			if(RAWINDUSTRY_LIST_COUNT < 1) DENSITY_RAW_PROP = 0;
		DENSITY_PROC_PROP = (GSController.GetSetting("DENSITY_PROC_PROP").tofloat() / TOTAL_PROP);
			if(PROCINDUSTRY_LIST_COUNT < 1) DENSITY_PROC_PROP = 0;
		DENSITY_TERT_PROP = (GSController.GetSetting("DENSITY_TERT_PROP").tofloat() / TOTAL_PROP);
			if(TERTIARYINDUSTRY_LIST_COUNT < 1) DENSITY_TERT_PROP = 0;
		DENSITY_SPEC_PROP = (GSController.GetSetting("DENSITY_SPEC_PROP").tofloat() / TOTAL_PROP);
			if(SPECIALINDUSTRY_LIST_COUNT < 1) DENSITY_SPEC_PROP = 0;
		DENSITY_RAW_METHOD = GSController.GetSetting("DENSITY_RAW_METHOD");
		DENSITY_PROC_METHOD = GSController.GetSetting("DENSITY_PROC_METHOD");
		DENSITY_TERT_METHOD = GSController.GetSetting("DENSITY_TERT_METHOD");
		
		// - Display status msgs
		Log.Info(">Total industries assigned: " + DENSITY_IND_TOTAL, Log.LVL_SUB_DECISIONS);
		Log.Info(">Min per industry assigned: " + DENSITY_IND_MIN, Log.LVL_SUB_DECISIONS);
		Log.Info(">Max per industry assigned: " + DENSITY_IND_MAX, Log.LVL_SUB_DECISIONS);
		Log.Info(">Primary industry proportion assigned: " + DENSITY_RAW_PROP, Log.LVL_SUB_DECISIONS);
		Log.Info(">Secondary industry proportion assigned: " + DENSITY_PROC_PROP, Log.LVL_SUB_DECISIONS);
		Log.Info(">Tertiary industry proportion assigned: " + DENSITY_TERT_PROP, Log.LVL_SUB_DECISIONS);
		Log.Info(">Special industry proportion assigned: " + DENSITY_SPEC_PROP, Log.LVL_SUB_DECISIONS);
		Log.Info(">Primary industry method assigned: " + DENSITY_RAW_METHOD, Log.LVL_SUB_DECISIONS);
		Log.Info(">Secondary industry method assigned: " + DENSITY_PROC_METHOD, Log.LVL_SUB_DECISIONS);
		Log.Info(">Tertiary industry method assigned: " + DENSITY_TERT_METHOD, Log.LVL_SUB_DECISIONS);
		
	// Declare function status
	this.INIT_PERFORMED = true;
}

//Function to call to build industries.
//Call to build initial and each refresh period
//Runs through each industry class, checks if it has built that class already, builds random class once if not and sets to true, 
//     if all have been built resets all to false up until global max per refresh
//Builds a global set proportion of each industry class, minimum 1 of each industry.
//Checks how many of each industry are existing (if 0 then has a chance to build 1).
//Builds up to a random number of each industry, between min and max according to proportion.
//Builds each industry according to build method.
//Accounts for special industry types.

// Build function
function GenerationMod::BuildIndustry() {
	// Check GS continue, to exit
	if(CONTINUE_GS == false) return;
			
	// Display status msg
	Log.Info("----------------------", Log.LVL_INFO);
	Log.Info("Building industries...", Log.LVL_INFO);

	// Check initiaized
	if (this.INIT_PERFORMED == false){
		// Display error 
		Log.Error(">GenerationMod.Build: Script uninitialized!", Log.LVL_INFO);
		return;
	}

	// If first build has not happened, then this is a new game
	local LOCAL_BUILD_LIMIT = 0;			// Build limit in this function
	local LOCAL_IND_MAX = 0.0;				// Max factor in this function				
	if (FIRSTBUILD_PERFORMED == false){
		// If global build count is less than 1 minumum per ind set to 1, else set to global max
		if(DENSITY_IND_TOTAL < IND_TYPE_COUNT) LOCAL_BUILD_LIMIT = IND_TYPE_COUNT;
		else LOCAL_BUILD_LIMIT = DENSITY_IND_TOTAL;
		
		// Set max factor to 1
		LOCAL_IND_MAX = 1.0;
		
		// Display status msg
		Log.Info(">This is a new game, build limit is: " + LOCAL_BUILD_LIMIT, Log.LVL_INFO);
		
		// Set first build
		FIRSTBUILD_PERFORMED = true;
	}
	// Else build has happened
	else{
		// Set build limit to a random up to global
		LOCAL_BUILD_LIMIT = GSBase.RandRange(BUILD_LIMIT + 1);
		
		// Set max factor to global
		LOCAL_IND_MAX = DENSITY_IND_MAX;
		
		// Display status msg
		Log.Info(">This is a continuing game, build limit is: " + LOCAL_BUILD_LIMIT + " / " + BUILD_LIMIT + " (Max)", Log.LVL_INFO);
	}

	// Loop until build limit is reached
	local BUILD_COUNT = 0;				// Total build count for each build function
	local CURRENT_METHOD = null;			// Current build method for each loop
	local CURRENT_IND_PROP = null;			// Current industry proportion for each loop
	local CURRENT_LIST = null;			// Current industry list for each loop
	local CURRENT_LIST_COUNT = 0;			// Count of current list for each loop
	local BUILD_CONTINUE = true;
	local BUILD_NOW = null;				// Switch setting for which class to build
	
	// While below current build limit
	while(LOCAL_BUILD_LIMIT - BUILD_COUNT > 0){
		
		// Set parameters for loop
		// - Set multi industries per town to one in param
		// - -  Check if valid
		if(GSGameSettings.IsValid("multiple_industry_per_town") == true){
			// - - Set to one in parameters
			GSGameSettings.SetValue("multiple_industry_per_town", GSController.GetSetting("MULTI_IND_TOWN"));
		}
		//
		
		// reset loop
		BUILD_CONTINUE = true;
		// Selects a random industry class, not yet built....GSBase.RandRange(Max - 1)
		// - Build "town" first
		BUILD_NOW = GSBase.RandRange(4);
		if(PRIMARY_PERFORMED == false && DENSITY_RAW_METHOD == 1) BUILD_NOW = 0;
		if(SECONDARY_PERFORMED == false && DENSITY_PROC_METHOD == 1) BUILD_NOW = 1;
		if(TERTIARY_PERFORMED == false && DENSITY_RAW_METHOD == 1) BUILD_NOW = 2;
		
		switch(BUILD_NOW)
		{
			case 0:	
				if(RAWINDUSTRY_LIST_COUNT < 1) PRIMARY_PERFORMED = true;
				if(PRIMARY_PERFORMED == true){
					BUILD_CONTINUE = false;
					break;
				}
				Log.Info("----------------------", Log.LVL_INFO);
				Log.Info(">Building primary industries", Log.LVL_INFO);
				CURRENT_LIST = RAWINDUSTRY_LIST;
				CURRENT_LIST_COUNT = RAWINDUSTRY_LIST_COUNT;
				CURRENT_METHOD = DENSITY_RAW_METHOD;
				CURRENT_IND_PROP = DENSITY_RAW_PROP;
				PRIMARY_PERFORMED = true;
				break;
			case 1:	
				if(PROCINDUSTRY_LIST_COUNT < 1) SECONDARY_PERFORMED = true;
				if(SECONDARY_PERFORMED){
					BUILD_CONTINUE = false;
					break;
				}
				Log.Info("----------------------", Log.LVL_INFO);
				Log.Info(">Building secondary industries", Log.LVL_INFO);
				CURRENT_LIST = PROCINDUSTRY_LIST;
				CURRENT_LIST_COUNT = PROCINDUSTRY_LIST_COUNT;
				CURRENT_METHOD = DENSITY_PROC_METHOD;
				CURRENT_IND_PROP = DENSITY_PROC_PROP;
				SECONDARY_PERFORMED = true;
				break;
			case 2:	
				if(TERTIARYINDUSTRY_LIST_COUNT < 1) TERTIARY_PERFORMED = true;
				if(TERTIARY_PERFORMED == true){
					BUILD_CONTINUE = false;
					break;
				}
				Log.Info("----------------------", Log.LVL_INFO);
				Log.Info("Building tertiary industries", Log.LVL_INFO);
				CURRENT_LIST = TERTIARYINDUSTRY_LIST;
				CURRENT_LIST_COUNT = TERTIARYINDUSTRY_LIST_COUNT;
				CURRENT_METHOD = DENSITY_TERT_METHOD;
				CURRENT_IND_PROP = DENSITY_TERT_PROP;
				TERTIARY_PERFORMED = true;
				break;
			case 3:	
				if(SPECIALINDUSTRY_LIST_COUNT < 1) SPECIAL_PERFORMED = true;
				if(SPECIAL_PERFORMED == true){
					BUILD_CONTINUE = false;
					break;
				}
				Log.Info("+------------------------------+", Log.LVL_INFO);
				Log.Info(">Building special industries", Log.LVL_INFO);
				CURRENT_LIST = SPECIALINDUSTRY_LIST;
				CURRENT_LIST_COUNT = SPECIALINDUSTRY_LIST_COUNT;
				CURRENT_METHOD = 5;		// Special case non-selectable
				CURRENT_IND_PROP = DENSITY_SPEC_PROP;
				SPECIAL_PERFORMED = true;
				break;
			default:
				// Display error
				Log.Error(">GenerationMod.BuildIndustryClass: Incorrect industry class chosen!", Log.LVL_INFO);
				return;
		}

		// Check to continue loop
		if(BUILD_CONTINUE == false) continue;
	
		// Set densities
		// Mins are how much a map will start with and the start count for building extra.
		// Maxes are how much a map could get based on chance. At least 1 per industry

		local CLASS_MIN	= 0;					// Integer, could be 0.
		local CLASS_MAX = 0;					// Int, at least 1 per industry and CLASS_MIN
		local IND_MIN = 0;						// Integer truncated float, could be 0
		local IND_MAX = 0;						// Integer truncated float, always >= 1
		//// Min density per industry class is:
		//CLASS_MIN = (DENSITY_IND_TOTAL.tofloat() * CURRENT_IND_PROP).tointeger();
		//	if(CLASS_MIN < 1) CLASS_MIN = 1;	
		//Log.Info(" ~Industry class minimum is: " + CLASS_MIN, Log.LVL_INFO);
		//// Max density per industry class is:
		//CLASS_MAX = CLASS_MIN; 
		//	if(CLASS_MAX < CURRENT_LIST_COUNT) CLASS_MAX = CURRENT_LIST_COUNT;	
		//Log.Info(" ~Industry class maximum is: " + CLASS_MAX, Log.LVL_INFO);

		// Min per industry is:
		//IND_MIN = ((CLASS_MIN.tofloat() / CURRENT_LIST_COUNT.tofloat()) * DENSITY_IND_MIN).tointeger();	
		//Log.Info(" ~Industry type minimum is: " + IND_MIN, Log.LVL_INFO);
		//// Max per industry is:
		//IND_MAX = ((CLASS_MAX.tofloat() / CURRENT_LIST_COUNT.tofloat()) * LOCAL_IND_MAX).tointeger();	
		//Log.Info(" ~Industry type maximum is: " + IND_MAX, Log.LVL_INFO);
		
		
		// Min density per industry class is:
		CLASS_MIN = (DENSITY_IND_TOTAL.tofloat() * CURRENT_IND_PROP * DENSITY_IND_MIN).tointeger();
			if(CLASS_MIN < 1) CLASS_MIN = 1;	
		Log.Info(" ~Industry class minimum is: " + CLASS_MIN, Log.LVL_INFO);
		// Max density per industry class is:
		CLASS_MAX = (DENSITY_IND_TOTAL.tofloat() * CURRENT_IND_PROP * LOCAL_IND_MAX).tointeger(); 
			if(CLASS_MAX < CURRENT_LIST_COUNT) CLASS_MAX = CURRENT_LIST_COUNT;	
		Log.Info(" ~Industry class maximum is: " + CLASS_MAX, Log.LVL_INFO);

		// Min per industry is:
		IND_MIN = ((CLASS_MIN.tofloat() / CURRENT_LIST_COUNT.tofloat())).tointeger();	
		Log.Info(" ~Industry type minimum is: " + IND_MIN, Log.LVL_INFO);
		// Max per industry is:
		IND_MAX = ((CLASS_MAX.tofloat() / CURRENT_LIST_COUNT.tofloat())).tointeger();	
		Log.Info(" ~Industry type maximum is: " + IND_MAX, Log.LVL_INFO);
		
		// Loop through each industry in current list
		foreach(CURRENT_IND_ID in CURRENT_LIST){

		// Display status
		Log.Info(" ~Analyzing "+ GSIndustryType.GetName(CURRENT_IND_ID) + " (ID:  " + CURRENT_IND_ID + ")", Log.LVL_SUB_DECISIONS);
			
		// Count existing for ind id
		// - Create list (ALL INDUSTRIES)
		local EXIST_IND_LIST = GSIndustryList();
		local EXIST_IND_COUNT = 0;				// Count of current industry type
		// - Loop through current list
		foreach(EXIST_IND_ID,_ in EXIST_IND_LIST){
			// If match then inc count
			if(GSIndustry.GetIndustryType(EXIST_IND_ID) == CURRENT_IND_ID) EXIST_IND_COUNT++;
		}
		Log.Info(" ~Existing "+ GSIndustryType.GetName(CURRENT_IND_ID) + " count is: " + EXIST_IND_COUNT + " / " + IND_MAX + " (Max)", Log.LVL_SUB_DECISIONS);
		
		// Set build target 
		local BUILD_TARGET = 0;					// Random target for each function to build
		BUILD_TARGET = (IND_MIN - EXIST_IND_COUNT) + (GSBase.RandRange(IND_MAX + 1 - IND_MIN));
			if(BUILD_TARGET > (LOCAL_BUILD_LIMIT - BUILD_COUNT)) BUILD_TARGET = (LOCAL_BUILD_LIMIT - BUILD_COUNT);

		if(BUILD_TARGET > 0){
			// Display status
			Log.Info(" ~Building " + BUILD_TARGET + " " + GSIndustryType.GetName(CURRENT_IND_ID), Log.LVL_SUB_DECISIONS);
											
			//Loop for each industry to build
			local CURRENT_BUILD_COUNT = 0;
			for(local i = 0; i < BUILD_TARGET; i++){
				// Build
				switch(CURRENT_METHOD){
					case 1:				
						// Increment count using town build
						CURRENT_BUILD_COUNT += TownBuildMethod(CURRENT_IND_ID);
						break;
					case 3:	
						// Increment count using scatter build
						CURRENT_BUILD_COUNT += ScatteredBuildMethod(CURRENT_IND_ID);
						break;
					case 4:	
						// Increment count using random build
						CURRENT_BUILD_COUNT += RandomBuildMethod(CURRENT_IND_ID);
						break;
					case 5:	
						// Increment count using special build
						CURRENT_BUILD_COUNT += SpecialBuildMethod(CURRENT_IND_ID);
						break;
					default:
						// Display error msg
						Log.Error(" ~GenerationMod.BuildSwitch: Incorrect build method chosen!", Log.LVL_INFO);
						break;
					}		
					this.ErrorHandler();
				}
			// Display status
			Log.Info(" ~Built " + CURRENT_BUILD_COUNT + " / " + BUILD_TARGET, Log.LVL_SUB_DECISIONS);
			
			// Update build count
			BUILD_COUNT += CURRENT_BUILD_COUNT;
			}											
		}
	// Display status
	Log.Info(">Build a current total of: " + BUILD_COUNT + " / " + LOCAL_BUILD_LIMIT, Log.LVL_INFO);
						
	// Reset randoms if necessary
	if(PRIMARY_PERFORMED == true && SECONDARY_PERFORMED == true && TERTIARY_PERFORMED == true && SPECIAL_PERFORMED){
		PRIMARY_PERFORMED = false;
		SECONDARY_PERFORMED = false;
		TERTIARY_PERFORMED = false;
		SPECIAL_PERFORMED = false;
		// Display status
		Log.Info("----------------------", Log.LVL_INFO);
		Log.Info(">Built all industry class types ", Log.LVL_INFO);
		return;
		}
	}	// End while loop
}

// return 1 if built and 0 if not
function GenerationMod::SpecialBuildMethod(INDUSRTY_ID){
		
	// Check if industry is not buildable
	if(!GSIndustryType.CanBuildIndustry(INDUSRTY_ID)){
		// Display error
		Log.Error(" ~GenerationMod.SpecialBuildMethod: Industry " + GSIndustryType.GetName(INDUSRTY_ID) + " not buildable!", Log.LVL_INFO);
		return 0;
	}
	
	// Switch ind id for each type, must be same as in SPECIALINDUSTRY_TYPES
	switch(GSIndustryType.GetName(INDUSRTY_ID)){
		case SPECIALINDUSTRY_TYPES[0]:			// "Bank"
			// Check towns with pop > parameter
			// - Create town list
			local LOCAL_TOWN_LIST = GSTownList();
			// - Valuate by population
			LOCAL_TOWN_LIST.Valuate(GSTown.GetPopulation);
			// - Remove below parameter
			LOCAL_TOWN_LIST.RemoveBelowValue(GSController.GetSetting("SPEC_BANK_MINPOP"));
			
			// Check if valid
			if(LOCAL_TOWN_LIST.IsEmpty() == true){
				Log.Warning(" ~GenerationMod.SpecialBuildMethod: No towns with more than " + GSController.GetSetting("SPEC_BANK_MINPOP") + " for Banks!", Log.LVL_SUB_DECISIONS);
				return 0;
			}
			// Try prospect
			if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
			break;
		case SPECIALINDUSTRY_TYPES[1]:			// "Oil Rig"
			// Check if current date is before param
			if(GSDate.GetCurrentDate() < GSDate.GetDate(GSController.GetSetting("SPEC_RIG_MINYEAR"), 1, 1)){
				Log.Warning(" ~GenerationMod.SpecialBuildMethod: Year is less than " + GSController.GetSetting("SPEC_RIG_MINYEAR") + " for Oil Rig!", Log.LVL_SUB_DECISIONS);
				return 0;
			}
			// Try prospect
			if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;
			break;
		case SPECIALINDUSTRY_TYPES[2]:			// "Water Tower"
			// Check towns with pop > parameter
			// - Create town list
			local LOCAL_TOWN_LIST = GSTownList();
			// - Valuate by population
			LOCAL_TOWN_LIST.Valuate(GSTown.GetPopulation);
			// - Remove below parameter
			LOCAL_TOWN_LIST.RemoveBelowValue(GSController.GetSetting("SPEC_WTR_MINPOP"));
			
			// Check if valid
			if(LOCAL_TOWN_LIST.IsEmpty() == true){
				Log.Warning(" ~GenerationMod.SpecialBuildMethod: No towns with more than " + GSController.GetSetting("SPEC_WTR_MINPOP") + " for Water Towers!", Log.LVL_SUB_DECISIONS);
				return 0;
			}
			// Try prospect
			if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
			break;
		case SPECIALINDUSTRY_TYPES[3]:			// "Lumber Mill"
			// Check if must not build param
			if(GSController.GetSetting("SPEC_LBR_BOOL") == 0) return 0;
			// Try prospect
			if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;
			break;
		default:
			// Display error
			Log.Error(" ~GenerationMod.SpecialBuildMethod: Industry " + GSIndustryType.GetName(INDUSRTY_ID) + " not supported!", Log.LVL_INFO);
	}
	return 0;	
}

// ONLY STORES 1 IND ID IN REFERENCE ARRAY, SO WILL ONLY SET EACH ITERATION TO CURRENT ID
// FINE ON MAP CREATION BUT WILL NOT WORK ON CONSECUTIVE RUNS
// TO FIX NEED A 2D ARRAY FOR THAT LIST< THEN TO LOOP FOR EACH IND ID IF HIT ON TOWN
// Town build method function (1)
// return 1 if built and 0 if not
function GenerationMod::TownBuildMethod(INDUSRTY_ID){

	// Check if industry is not buildable
	if(!GSIndustryType.CanBuildIndustry(INDUSRTY_ID)){
		// Display error
		Log.Error(" ~GenerationMod.TownBuildMethod: Industry not buildable!", Log.LVL_INFO);
		return 0;
	}
		
	local IND_NAME = GSIndustryType.GetName(INDUSRTY_ID)						// Industry name string
	
	// Assign and moderate map multiplier
	local MULTI = 1;
	if (MAP_SCALE <= MULTI)	MULTI = MAP_SCALE;

	// Create town list for townbuilder
	local LOCAL_TOWN_LIST = GSTownList();
	// Valuate by population
	LOCAL_TOWN_LIST.Valuate(GSTown.GetPopulation);
	// Remove below parameter
	LOCAL_TOWN_LIST.RemoveBelowValue(GSController.GetSetting("TOWN_MIN_POP"));
					
	// Check abnormal industries, for towns
	// - Oil Refinery
	if(IND_NAME == "Oil Refinery"){
		// - Check to rather prospect
		if(GSController.GetSetting("PROS_BOOL") == 1){
			// Try prospect
			if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
			else return 0;
		}
		// - Check oil ind setting, and remove towns further from edge
		//   Mainly for speed purposes...
		if(GSGameSettings.IsValid("oil_refinery_limit") == true){
			// Valuate by edge distance
			LOCAL_TOWN_LIST.Valuate(GetTownDistFromEdge);
			// Remove towns farther than max, including town radius
			local MAX_DIST = GSGameSettings.GetValue("oil_refinery_limit") + (GSController.GetSetting("TOWN_MAX_RADIUS") - 2)
			if(MAX_DIST < 0) MAX_DIST = 0;
			LOCAL_TOWN_LIST.RemoveAboveValue(MAX_DIST);
		}
	}
	// - Farm
	if(IND_NAME == "Farm"){
		// - Check climate
		local ISCLIMATE_ARCTIC = (GSGame.GetLandscape () == GSGame.LT_ARCTIC);
		if(ISCLIMATE_ARCTIC == true){
			// - Check to rather prospect
			if(GSController.GetSetting("PROS_BOOL") == 1) { return GSIndustryType.ProspectIndustry(INDUSRTY_ID) ? 1 : 0; } // Try prospect
		}
	}
	// - Forest
	if(IND_NAME == "Forest"){
		// - Check climate
		if(ISCLIMATE_ARCTIC == true){
			// - Check to rather prospect
			if(GSController.GetSetting("PROS_BOOL") == 1) { return GSIndustryType.ProspectIndustry(INDUSRTY_ID) ? 1 : 0; } // Try prospect
		}
	}
	// - Water Supply
	if(IND_NAME == "Water Supply"){
		// - Check climate
		local ISCLIMATE_TROPIC = (GSGame.GetLandscape () == GSGame.LT_TROPIC);
		if(ISCLIMATE_TROPIC == true){
			// - Check to rather prospect
			if(GSController.GetSetting("PROS_BOOL") == 1) { return GSIndustryType.ProspectIndustry(INDUSRTY_ID) ? 1 : 0; } // Try prospect
		}
	}
		
	// Loop through town list arrays
	for(local i = 0; i < this.TOWNNODE_LIST_TOWN.len(); i++){
	
		// Remove towns with ind ID in if TOWN_MULTI_BOOL
		// If - TOWN_MULTI_BOOL
		if(GSController.GetSetting("TOWN_MULTI_BOOL") == 0){
			// - If current list id == ind id, remove town
			if(this.TOWNNODE_LIST_IND[i] == INDUSRTY_ID) LOCAL_TOWN_LIST.RemoveItem(this.TOWNNODE_LIST_TOWN[i])
		}
	
		// Remove towns with max
		// - If loop town count >= setting, remove from list
		if(this.TOWNNODE_LIST_COUNT[i] >= GSController.GetSetting("TOWN_MAX_IND")) LOCAL_TOWN_LIST.RemoveItem(this.TOWNNODE_LIST_TOWN[i])
	}
	
	// Check if the list is not empty
	if(LOCAL_TOWN_LIST.IsEmpty() == true){
		Log.Error(" ~GenerationMod.TownBuildMethod: Town list is empty!", Log.LVL_INFO);
		return 0;
	}
	
	// Loop until tries are maxed (mainly debug)
	local BUILD_TRIES = LOCAL_TOWN_LIST.Count() * 3;
	while (BUILD_TRIES > 0){	
				
		// Get start ID
		local TOWN_ID = LOCAL_TOWN_LIST.Begin();
		// Get random ID
		for(local i = 0; i < GSBase.RandRange(LOCAL_TOWN_LIST.Count()); i++){
			TOWN_ID = LOCAL_TOWN_LIST.Next();
		}
		// Debug msg
		Log.Info("   ~Trying to build in " + GSTown.GetName(TOWN_ID), Log.LVL_DEBUG);		
		
		// Create list of town tiles
		//local TOWN_TILE_LIST = this.GetTownHouseList(TOWN_ID, CARGO_PAXID);
		//(2nd option)//local TOWN_TILE_LIST = Tile.GetTownTiles(TOWN_ID);
		local TOWN_RADIUS = (GSTown.GetHouseCount(TOWN_ID).tofloat() * (GSController.GetSetting("TOWN_MAX_RADIUS").tofloat() / 100.0)).tointeger();
		local TOWN_TILE_LIST = Tile.MakeTileRectAroundTile(GSTown.GetLocation(TOWN_ID),TOWN_RADIUS);
		// Debug msg
		Log.Info("   ~Got town tile list!", Log.LVL_DEBUG);
		
		// Get min/ max tiles
		local MIN_MAX_TILE_LIST = ListMinMaxXY(TOWN_TILE_LIST, true)
		// Debug msg
		Log.Info("   ~Got min/max tile list!", Log.LVL_DEBUG);
		
		// Create list for border tiles
		local BORDER_TILE_LIST = Tile.GrowTileRect(TOWN_TILE_LIST, GSController.GetSetting("TOWN_MAX_RADIUS"));
		// - Remove the town rectangle
		BORDER_TILE_LIST.RemoveRectangle(MIN_MAX_TILE_LIST.Begin(), MIN_MAX_TILE_LIST.Next());
		// Debug msg
		Log.Info("   ~Got border tile list!", Log.LVL_DEBUG);
		
		// Sort by random
		BORDER_TILE_LIST.Valuate(GSBase.RandItem);
		// Debug msg
		Log.Info("   ~Got random list!", Log.LVL_DEBUG);
		
		// Debug msg
		Log.Info("   ~Got tile list!", Log.LVL_DEBUG);	
		
		// Loop for each tile in list
		local BORDER_TILE = null;
		local IND = null;
		local IND_DIST = 0;
		for(local i = 0; i < BORDER_TILE_LIST.Count(); i++){
						
			// If first loop, start at beginning
			if(i == 0) BORDER_TILE = BORDER_TILE_LIST.Begin();
			// Else go to next
			else BORDER_TILE = BORDER_TILE_LIST.Next();
					
			// If invalid tile, reloop
			if(GSMap.IsValidTile(BORDER_TILE) == false) continue;
			
			// If water tile, reloop
			if(GSTile.IsWaterTile(BORDER_TILE) == true) continue;
					
			// Debug msg			
			if(GSGameSettings.GetValue("log_level") >= 4)Log.Info(GSMap.IsValidTile(BORDER_TILE), Log.LVL_DEBUG);
			if(GSGameSettings.GetValue("log_level") >= 4) GSSign.BuildSign(BORDER_TILE, "Try")
											
			// Check abnormal industries
			local TILE_TERRAIN = GSTile.GetTerrainType(BORDER_TILE);
			// - Oil Refinery
			if(IND_NAME == "Oil Refinery"){
				// - Check oil ind setting, and compare to current tile and re loop if above
				if(GSGameSettings.IsValid("oil_refinery_limit") == true) if(GSMap.DistanceFromEdge(BORDER_TILE) > GSGameSettings.GetValue("oil_refinery_limit")) continue;
			}
			// - Farm
			if(IND_NAME == "Farm"){
				// - Check climate
				if(ISCLIMATE_ARCTIC == true){
					// - Check if tile is snow and re loop if true
					if(TILE_TERRAIN == GSTile.TERRAIN_SNOW) continue;	
				}
			}
			// - Forest
			if(IND_NAME == "Forest"){
				// - Check climate
				if(ISCLIMATE_ARCTIC == true){
					// - Check if tile is not snow and re loop if true
					if(TILE_TERRAIN != GSTile.TERRAIN_SNOW) continue;
				}
			}
			
			//Check dist from ind
			// - Get industry
			IND = this.GetClosestIndustry(BORDER_TILE);
			// - If not null (null - no indusrties)
			if(IND != null){
				// - Get distance
				IND_DIST = GSIndustry.GetDistanceManhattanToTile(IND,BORDER_TILE);
				// - If less than minimum, re loop
				if(IND_DIST < (GSController.GetSetting("TOWN_MIN_IND") * MULTI)) continue;
			}
				
			// Try build	
			if(GSIndustryType.BuildIndustry(INDUSRTY_ID, BORDER_TILE) == true){
					
				// Debug msg	
				Log.Info("   ~Built!", Log.LVL_DEBUG);	
		
				// Loop through town list arrays
				local EXIST_TOWN = false;
				for(local i = 0; i < TOWNNODE_LIST_TOWN.len(); i++){
					// If current town is in array
					if(TOWNNODE_LIST_TOWN[i] == TOWN_ID){
						// Set bool
						EXIST_TOWN = true;
						// Inc count in array
						TOWNNODE_LIST_COUNT[i]++
						// Set ind in array
						TOWNNODE_LIST_IND[i] = INDUSRTY_ID;
					}
				}
				
				// If town was not in array
				if(EXIST_TOWN == false){
					// Add town to array
					TOWNNODE_LIST_TOWN.push(TOWN_ID);
					// Add ind id to array
					TOWNNODE_LIST_IND.push(INDUSRTY_ID);					
					// Add count to array
					TOWNNODE_LIST_COUNT.push(1);
				}
				return 1;
			}
		}	
		
		// Dec tries
		BUILD_TRIES--
	}
	// Display error msg
	Log.Error("GenerationMod.TownBuildMethod: Couldn't find a valid tile to set node on!", Log.LVL_INFO)
	return 0;
}


// Scattered build method function (3), return 1 if built and 0 if not
function GenerationMod::ScatteredBuildMethod(INDUSRTY_ID){
	
	local IND_NAME = GSIndustryType.GetName(INDUSRTY_ID)						// Industry name string
	local TILE_ID = null;
	local BUILD_TRIES = ((256 * 256 * 3) * MAP_SCALE).tointeger();
	local TOWN_DIST = 0;
	local IND = null;
	local IND_DIST = 0;
	local MULTI = 0;

	// Check if industry is not buildable
	if(!GSIndustryType.CanBuildIndustry(INDUSRTY_ID)){
		// Display error
		Log.Error(" ~Industry not buildable!", Log.LVL_INFO);
		return 0;
	}
	
	// Assign and moderate map multiplier
	if(MAP_SCALE > 1) MULTI = 1;
	else MULTI = MAP_SCALE;

	// Loop until correct tile
	while(BUILD_TRIES > 0){
		// Get a random tile
		TILE_ID = Tile.GetRandomTile();
		
		// Check abnormal industries
		// - Oil Refinery
		if(IND_NAME == "Oil Refinery"){
			// - Check to rather prospect
			if(GSController.GetSetting("PROS_BOOL") == 1){
				// Try prospect
				if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
				else return 0;
			}
			// - Check oil ind setting, and compare to current tile and re loop if above
				if(GSGameSettings.IsValid("oil_refinery_limit") == true) if(GSMap.DistanceFromEdge(BORDER_TILE) > GSGameSettings.GetValue("oil_refinery_limit")) continue;
		}
		// - Farm
		if(IND_NAME == "Farm"){
			// - Check climate
			if(GSGame.GetLandscape () == GSGame.LT_ARCTIC){
				// - Check to rather prospect
				if(GSController.GetSetting("PROS_BOOL") == 1){
					// Try prospect
					if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
					else return 0;
				}
				// - Check if tile is snow and re loop if true
				if(GSTile.GetTerrainType(TILE_ID) == GSTile.TERRAIN_SNOW) continue;
			}
		}
		// - Forest
		if(IND_NAME == "Forest"){
			// - Check climate
			if(GSGame.GetLandscape () == GSGame.LT_ARCTIC){
				// - Check to rather prospect
				if(GSController.GetSetting("PROS_BOOL") == 1){
					// Try prospect
					if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
					else return 0;
				}
				// - Check if tile is not snow and re loop if true
				if(GSTile.GetTerrainType(TILE_ID) != GSTile.TERRAIN_SNOW) continue;
			}
		}
		// - Water Supply
		if(IND_NAME == "Water Supply"){
			// - Check climate
			if(GSGame.GetLandscape () == GSGame.LT_TROPIC){
				// - Check to rather prospect
				if(GSController.GetSetting("PROS_BOOL") == 1){
					// Try prospect
					if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
					else return 0;
				}
				// - Check if tile is not desert and re loop if true
				if(GSTile.GetTerrainType(TILE_ID) != GSTile.TERRAIN_DESERT) continue;
			}
		}
		
		// Check dist from town
		// - Get distance to town
		TOWN_DIST = GSTown.GetDistanceManhattanToTile(GSTile.GetClosestTown(TILE_ID),TILE_ID);
		// - If less than minimum, re loop
		if(TOWN_DIST < (GSController.GetSetting("SCATTERED_MIN_TOWN") * MULTI)) continue;
		
		// Check dist from ind
		// - Get industry
		IND = this.GetClosestIndustry(TILE_ID);
		// - If not null (null - no indusrties)
		if(IND != null){
			// - Get distance
			IND_DIST = GSIndustry.GetDistanceManhattanToTile(IND,TILE_ID);
			// - If less than minimum, re loop
			if(IND_DIST < (GSController.GetSetting("SCATTERED_MIN_IND") * MULTI)) continue;
		}
		
		// Try build
		if (GSIndustryType.BuildIndustry(INDUSRTY_ID, TILE_ID) == true) return 1;
		
		// Increment and check counter
		BUILD_TRIES--
		if(BUILD_TRIES == ((256 * 256 * 2.5) * MAP_SCALE).tointeger()) Log.Warning(" ~Tries left: " + BUILD_TRIES, Log.LVL_INFO);
		if(BUILD_TRIES == ((256 * 256 * 1.5) * MAP_SCALE).tointeger()) Log.Warning(" ~Tries left: " + BUILD_TRIES, Log.LVL_INFO);
		if(BUILD_TRIES == ((256 * 256 * 0.5) * MAP_SCALE).tointeger()) Log.Warning(" ~Tries left: " + BUILD_TRIES, Log.LVL_INFO);
		if(BUILD_TRIES == 0){
			Log.Error("GenerationMod.ScatteredBuildMethod: Couldn't find a valid tile!", Log.LVL_INFO)
		}
	}
	Log.Error("GenerationMod.ScatteredBuildMethod: Build failed!", Log.LVL_INFO)
	return 0;
}

// Random build method function (4), return 1 if built and 0 if not
function GenerationMod::RandomBuildMethod(INDUSRTY_ID){
	
	local IND_NAME = GSIndustryType.GetName(INDUSRTY_ID);						// Industry name string
	local TILE_ID = null;
	local BUILD_TRIES = ((256 * 256 * 2) * MAP_SCALE).tointeger();
	
	//Check if industry is not buildable
	if(!GSIndustryType.CanBuildIndustry(INDUSRTY_ID)){
		// Display error
		Log.Error(" ~Industry not buildable!", Log.LVL_INFO);
		return 0;
	}
	
	// Loop until correct tile
	while(BUILD_TRIES > 0){
		// Get a random tile
		TILE_ID = Tile.GetRandomTile();
		
		// Check abnormal industries
		// - Oil Refinery
		if(IND_NAME == "Oil Refinery"){
			// - Check to rather prospect
			if(GSController.GetSetting("PROS_BOOL") == 1){
				// Try prospect
				if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
				else return 0;
			}
			// - Check oil ind setting, and compare to current tile and re loop if above
				if(GSGameSettings.IsValid("oil_refinery_limit") == true) if(GSMap.DistanceFromEdge(TILE_ID) > GSGameSettings.GetValue("oil_refinery_limit")) continue;
		}
		// - Farm
		if(IND_NAME == "Farm"){
			// - Check climate
			if(GSGame.GetLandscape () == GSGame.LT_ARCTIC){
				// - Check to rather prospect
				if(GSController.GetSetting("PROS_BOOL") == 1){
					// Try prospect
					if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
					else return 0;
				}
				// - Check if tile is snow and re loop if true
				if(GSTile.GetTerrainType(TILE_ID) == GSTile.TERRAIN_SNOW) continue;
			}
		}
		// - Forest
		if(IND_NAME == "Forest"){
			// - Check climate
			if(GSGame.GetLandscape () == GSGame.LT_ARCTIC){
				// - Check to rather prospect
				if(GSController.GetSetting("PROS_BOOL") == 1){
					// Try prospect
					if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
					else return 0;
				}
				// - Check if tile is not snow and re loop if true
				if(GSTile.GetTerrainType(TILE_ID) != GSTile.TERRAIN_SNOW) continue;
			}
		}
		// - Water Supply
		if(IND_NAME == "Water Supply"){
			// - Check climate
			if(GSGame.GetLandscape () == GSGame.LT_TROPIC){
				// - Check to rather prospect
				if(GSController.GetSetting("PROS_BOOL") == 1){
					// Try prospect
					if(GSIndustryType.ProspectIndustry (INDUSRTY_ID) == true) return 1;	
					else return 0;
				}
				// - Check if tile is not desert and re loop if true
				if(GSTile.GetTerrainType(TILE_ID) != GSTile.TERRAIN_DESERT) continue;
			}
		}
		
		// Try build
		if (GSIndustryType.BuildIndustry(INDUSRTY_ID, TILE_ID) == true) return 1;
		
		// Increment and check counter
		BUILD_TRIES--
		if(BUILD_TRIES == ((256 * 256 * 1.5) * MAP_SCALE).tointeger()) Log.Warning(" ~Tries left: " + BUILD_TRIES, Log.LVL_INFO);
		if(BUILD_TRIES == ((256 * 256 * 1.0) * MAP_SCALE).tointeger()) Log.Warning(" ~Tries left: " + BUILD_TRIES, Log.LVL_INFO);
		if(BUILD_TRIES == ((256 * 256 * 0.5) * MAP_SCALE).tointeger()) Log.Warning(" ~Tries left: " + BUILD_TRIES, Log.LVL_INFO);
		if(BUILD_TRIES == 0){
			Log.Error("GenerationMod.RandomBuildMethod: Couldn't find a valid tile!", Log.LVL_INFO);
		}
	}
	Log.Error("GenerationMod.RandomBuildMethod: Build failed!", Log.LVL_INFO);
	return 0;
}

// NOTE: Has to be called from the HandleEvents of main.
function GenerationMod::HandleEvents(){
	// Check GS continue
	if(CONTINUE_GS == false){
		return;
	}
	
	// Display status msg
	Log.Info("----------------------", Log.LVL_INFO);
	Log.Info("Event handling...", Log.LVL_INFO);
	
	// While events are waiting
	while (GSEventController.IsEventWaiting()) {
		// Next event in variable
  		local NEXT_EVENT = GSEventController.GetNextEvent();
  		switch (NEXT_EVENT.GetEventType()) {
  			// Event: New industry
		    case GSEvent.ET_INDUSTRY_OPEN:
		    	// Display status msg
		    	Log.Info(">New industry opened event", Log.LVL_SUB_DECISIONS);
		    	// Convert the event
		      	local EVENT_CONTROLER = GSEventIndustryOpen.Convert(NEXT_EVENT);
		      	// Get the industry ID
		      	local INDUSTRY_ID  = EVENT_CONTROLER.GetIndustryID();
		      	// Get the tile of the industry
		      	local TILE_ID = GSIndustry.GetLocation(INDUSTRY_ID);
		      	// Demolish the industry
		      	GSTile.DemolishTile(TILE_ID);
		      	break;
  			// Event: Industry
		    case GSEvent.ET_INDUSTRY_CLOSE:
		    	// Display status msg
		    	Log.Info(">Industry closed event", Log.LVL_SUB_DECISIONS)
		    	// Convert the event
		      	local EVENT_CONTROLER = GSEventIndustryClose.Convert(NEXT_EVENT);
		      	// Get the industry ID
		      	local INDUSTRY_ID  = EVENT_CONTROLER.GetIndustryID();
		      	// Do nothing, as reduced number of industries will be handeled in the next refresh loop
		      	break;
		     // Unhandled events
		    default:
		    	// Display status msg
		    	//Log.Info(">Unhandled event", Log.LVL_INFO)
		      	break;
  		}
	}
}

// Custom get closest industry function
function GenerationMod::GetClosestIndustry(TILE){
	// Create a list of all industries
	local IND_LIST = GSIndustryList();
	
	// If count is 0, return null
	if(IND_LIST.Count() == 0) return null;
	
	// Valuate by distance from tile
	IND_LIST.Valuate(GSIndustry.GetDistanceManhattanToTile, TILE);
	
	// Sort smallest to largest
	IND_LIST.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
	
	// Return the top one
	return IND_LIST.Begin();
}

// Town house list function, returns a list of tiles with houses on from a town
function GenerationMod:: GetTownHouseList(TOWN_ID, CARGO_ID){
  	// Below requires
	//	TOWN_ID // ID of town
	//	CARGO_PAXID	//	Passenger cargo ID
	
	// Configure variables
	local HOUSE_COUNT_FACTOR = 1.25;		// Account for multi tile buildings
	local MAX_TRIES = (128 * 128);			// Maximum size for search, to prevent infinite loop

	// Create a blank tile list
	local TOWN_HOUSE_LIST = GSTileList();
	local TOWN_HOUSE_LIST_COUNT = 0;
	
	// Create a cargo counter
	local CARGO_COUNTER = 0;
	//GSLog.Info(GSCargo.GetCargoLabel(CARGO_PAXID));
	
	// Get town house count
	local TOWN_HOUSE_COUNT = GSTown.GetHouseCount(TOWN_ID);
	
	// Set current tile
	local CURRENT_TILE = GSTown.GetLocation(TOWN_ID);

	//GSLog.Info(TOWN_ID);
	//GSLog.Info("===");
	//GSLog.Info(GSTile.IsWithinTownInfluence(CURRENT_TILE,TOWN_ID));
	//GSLog.Info(GSTile.GetTownAuthority(CURRENT_TILE)); //= TOWN_ID
	//GSLog.Info(GSTile.IsBuildable(CURRENT_TILE));	//=false
	//GSLog.Info(GSTile.GetOwner(CURRENT_TILE));	//=-1
	//GSLog.Info(GSTile.IsStationTile(CURRENT_TILE));	//=false
	//GSLog.Info(GSTile.GetCargoAcceptance(CURRENT_TILE, CARGO_PAXID,1,1,0)); 	//=0
	
	// Create spiral walker
	local SPIRAL_WALKER = SpiralWalker();
	// Set spiral walker on town center tile, always a road
	SPIRAL_WALKER.Start(CURRENT_TILE);
	
	// Create try counter
	local TRIES = 0;
	
	// Loop till list count matches house count
	while(TOWN_HOUSE_LIST_COUNT < (TOWN_HOUSE_COUNT * HOUSE_COUNT_FACTOR) && TRIES < MAX_TRIES){		
		// Inc tries
		TRIES++;
		
		// Walk one tile
		SPIRAL_WALKER.Walk();
		// Get tile
		CURRENT_TILE = SPIRAL_WALKER.GetTile();
		
		// Debug sign
  		if(GSGameSettings.GetValue("log_level") >= 4)GSSign.BuildSign(CURRENT_TILE,"" + TRIES);

		// Debug msgs
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("---" + TRIES + "---");
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("In current town inf: " + GSTile.IsWithinTownInfluence(CURRENT_TILE,TOWN_ID));
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("Town authority id: " + GSTile.GetTownAuthority(CURRENT_TILE));
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("Buildable: " + GSTile.IsBuildable(CURRENT_TILE));
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("Owner id: " + GSTile.GetOwner(CURRENT_TILE));
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("Station: " + GSTile.IsStationTile(CURRENT_TILE));
		if(GSGameSettings.GetValue("log_level") >= 4) GSLog.Info("Passenger acceptance: " + GSTile.GetCargoAcceptance(CURRENT_TILE, CARGO_PAXID,1,1,0));

		// If not the current town, continue 
		if(GSGameSettings.GetValue("log_level") >= 4) if(GSTile.IsWithinTownInfluence(CURRENT_TILE,TOWN_ID) == false);
		// If not a ??? (non town center buildings are always 65535)
		if(GSTile.GetTownAuthority(CURRENT_TILE) != TOWN_ID) continue;
		// If buildable, continue
		if(GSTile.IsBuildable(CURRENT_TILE) != false) continue;
		// If owned by anyone, continue
		if(GSTile.GetOwner(CURRENT_TILE) != -1) continue;
		// If station, continue
		//if(GSTile.IsStationTile(CURRENT_TILE) != false) continue;
		// If industry, continue
		if(IsIndustry(CURRENT_TILE) != false) continue;

		// Get passenger acceptance
		CARGO_COUNTER = GSTile.GetCargoAcceptance(CURRENT_TILE, CARGO_PAXID,1,1,0);

		// If the current tile accepts passengers
		if(GSTile.GetCargoAcceptance(CURRENT_TILE, CARGO_PAXID,1,1,0) > 0){
			// Add the tile
			TOWN_HOUSE_LIST.AddTile(CURRENT_TILE);
		
			// Inc counter
			TOWN_HOUSE_LIST_COUNT++;
						
			// Debug sign
  			if(GSGameSettings.GetValue("log_level") >= 4) GSSign.BuildSign(CURRENT_TILE,"H: " + TOWN_HOUSE_LIST_COUNT);
  			}
	}
	
	// Display status msg
	//GSLog.Info("Created list of " + TOWN_HOUSE_LIST.Count() + " of " + TOWN_HOUSE_COUNT + " houses in town " + GSTown.GetName(TOWN_ID));

	// Return the list
	return TOWN_HOUSE_LIST;
}

// Min/Max X/Y list function, returns a 4 tile list with X Max, X Min, Y Max, Y Min, or blank list on fail.
// If second param is == true, returns a 2 tile list with XY Min and XY Max, or blank list on fail.
function GenerationMod:: ListMinMaxXY(TILE_LIST, TWO_TILE_BOOL){
	
	local LOCAL_LIST = GSList();	
	
	local X_MAX_TILE = -1;
	local X_MIN_TILE = -1;
	local Y_MAX_TILE = -1;
	local Y_MIN_TILE = -1;

	// Add list
	LOCAL_LIST.AddList(TILE_LIST);
	
	// Remove invalid tiles
	LOCAL_LIST.Valuate(GSMap.IsValidTile);
	LOCAL_LIST.KeepValue(1);
	
	// If list is not empty
	if(!LOCAL_LIST.IsEmpty()){
		// Valuate by x coord
		LOCAL_LIST.Valuate(GSMap.GetTileX);
		// Sort from highest to lowest
		LOCAL_LIST.Sort(GSList.SORT_BY_VALUE, false);
		// Assign highest
		X_MAX_TILE = LOCAL_LIST.Begin();		
		// Sort from lowest to highest
		LOCAL_LIST.Sort(GSList.SORT_BY_VALUE, true);
		// Assign lowest
		X_MIN_TILE = LOCAL_LIST.Begin();
		// Valuate by y coord
		LOCAL_LIST.Valuate(GSMap.GetTileY);
		// Sort from highest to lowest
		LOCAL_LIST.Sort(GSList.SORT_BY_VALUE, false);
		Y_MAX_TILE = LOCAL_LIST.Begin();
		// Sort from lowest to highest
		LOCAL_LIST.Sort(GSList.SORT_BY_VALUE, true);
		// Assign lowest
		Y_MIN_TILE = LOCAL_LIST.Begin();

		// Debug sign
  		if(GSGameSettings.GetValue("log_level") >= 4) GSSign.BuildSign(X_MAX_TILE,"X Max tile");
  		if(GSGameSettings.GetValue("log_level") >= 4) GSSign.BuildSign(X_MIN_TILE,"X Min tile");
  		if(GSGameSettings.GetValue("log_level") >= 4) GSSign.BuildSign(Y_MAX_TILE,"Y Max tile");
  		if(GSGameSettings.GetValue("log_level") >= 4) GSSign.BuildSign(Y_MIN_TILE,"Y Min tile");

		// Debug msgs
		//GSLog.Info("X Max: " + X_MAX + " X Min: " + X_MIN + " Y Max: " + Y_MAX + " Y Min: ");
		
		//Create tile list
		local OUTPUT_TILE_LIST = GSTileList();
			
		if(TWO_TILE_BOOL == true){
			// Get 2 max and min tiles
			local X_MIN = GSMap.GetTileX(X_MIN_TILE);
			local X_MAX = GSMap.GetTileX(X_MAX_TILE);
			local Y_MIN = GSMap.GetTileY(Y_MIN_TILE);
			local Y_MAX = GSMap.GetTileY(Y_MAX_TILE);
			
			local XY_MIN_TILE = GSMap.GetTileIndex(X_MIN, Y_MIN);
			local XY_MAX_TILE = GSMap.GetTileIndex(X_MAX, Y_MAX);
			
			//GSLog.Info(GSMap.IsValidTile(XY_MIN_TILE) + " " + GSMap.IsValidTile(XY_MAX_TILE));
			
			// Add tiles
			OUTPUT_TILE_LIST.AddTile(XY_MIN_TILE);
			OUTPUT_TILE_LIST.AddTile(XY_MAX_TILE);
		}
		else{
			// Add tiles
			OUTPUT_TILE_LIST.AddTile(X_MAX_TILE);
			OUTPUT_TILE_LIST.AddTile(X_MIN_TILE);
			OUTPUT_TILE_LIST.AddTile(Y_MAX_TILE);
			OUTPUT_TILE_LIST.AddTile(Y_MIN_TILE);
		}
		
		return OUTPUT_TILE_LIST;	

	}
	else GSLog.Error("GenerationMod.ListMinMaxXY: List is Empty!");
	
	return LOCAL_LIST;
}

// Error handler function
function GenerationMod:: ErrorHandler(){
	// Get error
	local ERROR = GSError.GetLastError();
	
	// Check if error is not nothing
	if (ERROR == GSError.ERR_NONE) return;	
	
	// Error category
	 switch(GSError.GetErrorCategory()){
	case GSError.ERR_CAT_NONE:
		GSLog.Error("Error not related to any category.")
		break;
	case GSError.ERR_CAT_GENERAL:
		GSLog.Error("Error related to general things.")
		break;
	case GSError.ERR_CAT_VEHICLE:
		GSLog.Error("Error related to building / maintaining vehicles.")
		break;
	case GSError.ERR_CAT_STATION:
		GSLog.Error("Error related to building / maintaining stations.")
		break;
	case GSError.ERR_CAT_BRIDGE:
		GSLog.Error("Error related to building / removing bridges.")	
		reak;
	case GSError.ERR_CAT_TUNNEL:
		GSLog.Error("Error related to building / removing tunnels.")
		break;
	case GSError.ERR_CAT_TILE:
		GSLog.Error("Error related to raising / lowering and demolishing tiles.")
		break;
	case GSError.ERR_CAT_SIGN:
		GSLog.Error("Error related to building / removing signs.")
		break;
	case GSError.ERR_CAT_RAIL:
		GSLog.Error("Error related to building / maintaining rails.")
		break;
	case GSError.ERR_CAT_ROAD:
		GSLog.Error("Error related to building / maintaining roads.")
		break;
	case GSError.ERR_CAT_ORDER:
		GSLog.Error("Error related to managing orders.")
		break;
	case GSError.ERR_CAT_MARINE:
		GSLog.Error("Error related to building / removing ships, docks and channels.")
		break;
	case GSError.ERR_CAT_WAYPOINT:
		GSLog.Error("Error related to building / maintaining waypoints.")
		break; 
	 default:
      	GSLog.Error("Unhandled error category!" + GSError.GetErrorCategory());
      	break;
	 }
	
	// Errors
	 switch(ERROR){
	 case GSSign.ERR_SIGN_TOO_MANY_SIGNS: 
	 	GSLog.Error("Too many signs!");
	 	break;
	 	
	 default:
      	GSLog.Error("Unhandled error: " + GSError.GetLastErrorString());
      	break;
	 }
}

// Function to check if tile is industry, returns true or false
function IsIndustry(TILE_ID) { return (GSIndustry.GetIndustryID(TILE_ID) != 65535); }

// Function to valuate town by dist from edge
function GetTownDistFromEdge(TOWN_ID){
	return GSMap.DistanceFromEdge(GSTown.GetLocation(TOWN_ID));
}
