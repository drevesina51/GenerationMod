// Objectives

// 1) Maintain functionality but improve script performance
// 2) Extend script functionality into other 'post-map creation' initialization
// 3) Adding the ability to change certain values when creating interconnected industries
// 4) Increasing the realism of the generated map
// 5) Creating an opportunity for the player to adapt the game to their standards and ideals

require("progress.nut");

class GenerationMod extends GSController {
    // change based on setting
    industry_spacing = 0;
    farm_spacing = 0;
    raw_industry_min = 0;
    proc_industry_min = 0;
    tertiary_industry_min = 0;
    debug_level = 0;

 // End config set variables
    company_id = 0;
    build_limit = 0;
    chunk_size = 256;
    town_industry_counts = GSTownList();   

 constructor() {
        this.town_industry_limit = GSController.GetSetting("town_industry_limit");
        this.town_radius = GSController.GetSetting("town_radius");
        this.town_long_radius = GSController.GetSetting("town_long_radius");
        this.industry_spacing = GSController.GetSetting("industry_spacing");
        this.industry_newgrf = GSController.GetSetting("industry_newgrf");
        this.large_town_cutoff = GSController.GetSetting("large_town_cutoff");
        this.large_town_spacing = GSController.GetSetting("large_town_spacing");
        this.farm_spacing = GSController.GetSetting("farm_spacing");
        this.raw_industry_min = GSController.GetSetting("raw_industry_min");
        this.proc_industry_min = GSController.GetSetting("proc_industry_min");
        this.tertiary_industry_min = GSController.GetSetting("tertiary_industry_min");
        this.debug_level = GSController.GetSetting("debug_level");
    } 
    
// Save function
function GenerationMod::Save() {
    return {};
}

// Load function
function GenerationMod::Load() {
}

// Program start function
function GenerationMod::Start() { 
    industry_classes = GSIndustryTypeList();
    this.Init();
}

function IndustryPlacer::InArray(item, array) {
    for(local i = 0; i < array.len(); i++) {
        if(array[i] == item) {
            return true;
        }
    }
    return false;
}
 
Print("-----Primary industries:-----", 0);
    foreach(ind_id in rawindustry_list) {
        Print(GSIndustryType.GetName(ind_id) + ": " + industry_class_lookup[industry_classes.GetValue(ind_id)], 0);
    }
    Print("-----Secondary industries:-----", 0);
    foreach(ind_id in procindustry_list) {
        Print(GSIndustryType.GetName(ind_id) + ": " + industry_class_lookup[industry_classes.GetValue(ind_id)], 0);
    }
    Print("-----Tertiary industries:-----", 0);
    foreach(ind_id in tertiaryindustry_list) {
        Print(GSIndustryType.GetName(ind_id) + ": " + industry_class_lookup[industry_classes.GetValue(ind_id)], 0);
    }
    Print("-----Farm industries:-----", 0);
    foreach(ind_id in farmindustry_list) {
        Print(GSIndustryType.GetName(ind_id) + ": " + industry_class_lookup[industry_classes.GetValue(ind_id)], 0);
    }
    Print("-----Registration done.-----", 0)
}
function GenerationMod::Print(string, level) {
    if(level <= debug_level) {
        GSController.Print(false, (GSDate.GetSystemTime() % 3600) + " " + string);
    }
}

// Zero
function GenerationMod::Zero(x) {
    return 0;
}

// Identity
function GenerationMod::Id(x) {
    return 1;
}
