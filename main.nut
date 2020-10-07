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
 
 function IndustryPlacer::RegisterIndustryGRF(industry_newgrf) {
    local name = "";

    Print("Registering " + name + " industries.", 0);
    local water_based_industries = [];
    local shore_based_industries = [];
    local townbldg_based_industries = [];
    local neartown_based_industries = [];
    local nondesert_based_industries = [];
    local nonsnow_based_industries = [];
    local nonsnowdesert_based_industries = [];
    local farm_industries = [];
    local skip_industries = [];
    // Overrides are for industries that we want to force into a tier or terrain type
    // If the industry is in the right tier and has the right terrain type (check the first logs printed when a new map is created) then it doesn't need to be in here.
    /*
     * From the API docs:
     *   Industries might be neither raw nor processing. This is usually the
     *   case for industries which produce nothing (e.g. power plants), but
     *   also for weird industries like temperate banks and tropic lumber
     *   mills.
     */
    local primary_override = [];
    local secondary_override = [];
    local tertiary_override = [];
    local farm_override = [];

        water_based_industries = [
                                  "Oil Rig"
                                  ];
        townbldg_based_industries = [
                                     "Bank"
                                     ];
        farm_override = [
                         "Farm"
                         ]; 
    
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

// Initialization function
function IndustryPlacer::Init() {
    Sleep(1);
    company_id = GSCompany.ResolveCompanyID(GSCompany.COMPANY_FIRST);
    RegisterIndustryGRF(industry_newgrf);
    MapPreprocess();
    InitializeTowns();
    Print("-----Building tertiary industry:-----", 0);
    local build_counter = 0;
    local exhausted_list = [];
    while(build_counter < tertiary_industry_min &&
          exhausted_list.len() != tertiaryindustry_list.len()) {
        foreach(ind_id in tertiaryindustry_list) {
            local build = 0;
            while(build == 0) {
                build = TownBuildMethod(ind_id);
            }
            if(build == -1) {
                // This specific industry has been exhausted
                // Add it to the skip list
                exhausted_list.append(ind_id);
            }
        }
        build_counter += 1;
    }
   InitializeMap();
    build_counter = 0;
    exhausted_list = [];
    Print("-----Building primary industry:-----", 0);
    while(build_counter < raw_industry_min &&
          exhausted_list.len() != rawindustry_list.len()) {
        foreach(ind_id in rawindustry_list) {
            local build = 0;
            if(build == -1) {
                exhausted_list.append(ind_id);
            }
        }
        build_counter += 1;
    }
    build_counter = 0;
    exhausted_list = [];
    Print("-----Building secondary industry:-----", 0);
    while(build_counter < proc_industry_min &&
          exhausted_list.len() != procindustry_list.len()) {
        foreach(ind_id in procindustry_list) {
            local build = 0;
            while(build == 0) {
                build = ScatteredBuildMethod(ind_id);
            }
            if(build == -1) {
                exhausted_list.append(ind_id);
            }
        }
        build_counter += 1;
    }
    FillFarms();
    Print("Done!", 0)
}

function IndustryPlacer::FillCash() {
    if(GSCompany.GetBankBalance(company_id) < 100000000) {
        GSCompany.ChangeBankBalance(company_id, 1500000000, GSCompany.EXPENSES_OTHER);
    }
}
function IndustryPlacer::Build(industry_id, tile_index) {
    FillCash();
    local mode = GSCompanyMode(company_id);
    local build_status = false;
    // Industries are built from their top left corner; but a shore industry also has to touch land on one side
    // We'll spam build in a 6x6 region up and to the left of the desired tile
    if(industry_classes.GetValue(industry_id) == 2) {
        local top_corner = GSMap.GetTileIndex(max(GSMap.GetTileX(tile_index) - 6, 1),
                                              max(GSMap.GetTileY(tile_index) - 6, 1));
        local build_zone = GSTileList();
        build_zone.AddRectangle(top_corner, tile_index);
        foreach(tile_id, value in build_zone) {
            build_status = GSIndustryType.BuildIndustry(industry_id, tile_id);
            if(build_status) {
                return build_status;
            }
        }
        return false;
    }
    return GSIndustryType.BuildIndustry(industry_id, tile_index);
}
function IndustryPlacer::InitializeTowns() {
    town_eligibility_default.Valuate(Id)
    town_eligibility_water.Valuate(Id);
    town_eligibility_shore.Valuate(Id);
    town_eligibility_townbldg.Valuate(Id);
    town_eligibility_neartown.Valuate(Id);
    town_eligibility_nondesert.Valuate(Id);
    town_eligibility_nonsnow.Valuate(Id);
    town_eligibility_nonsnowdesert.Valuate(Id);
    town_industry_counts.Valuate(Zero);
}
// Map preprocessor
// Creates data for all tiles on the map

function IndustryPlacer::MapPreprocess() {
    Print("Building map tile list.", 0);
    local all_tiles = GSTileList();
    all_tiles.AddRectangle(GSMap.GetTileIndex(1, 1),
                           GSMap.GetTileIndex(GSMap.GetMapSizeX() - 2,
                                              GSMap.GetMapSizeY() - 2));
    Print("Map list size: " + all_tiles.Count(), 0);
    local chunks = (GSMap.GetMapSizeX() - 2) * (GSMap.GetMapSizeY() - 2) / (chunk_size * chunk_size);
    Print("Loading " + chunks + " chunks:", 0);
    // Hybrid approach:
    // Break the map into chunk_size x chunk_size chunks and valuate on each of them
    local progress = ProgressReport(chunks);
    for(local y = 1; y < GSMap.GetMapSizeY() - 1; y += chunk_size) {
        for(local x = 1; x < GSMap.GetMapSizeX() - 1; x += chunk_size) {
            local chunk_land = GetChunk(x, y);
            local chunk_shore = GetChunk(x, y);
            local chunk_water = GetChunk(x, y);
            local chunk_nondesert = GSTileList();
            local chunk_nonsnow = GSTileList();
            chunk_land.Valuate(GSTile.IsCoastTile);
            chunk_land.KeepValue(0);
            chunk_land.Valuate(GSTile.IsWaterTile);
            chunk_land.KeepValue(0);
            chunk_land.Valuate(IsFlatTile);
            chunk_land.KeepValue(1);
            chunk_land.Valuate(GSBase.RandItem);

            chunk_shore.Valuate(GSTile.IsCoastTile);
            chunk_shore.KeepValue(1);
            chunk_shore.Valuate(GSBase.RandItem);

            chunk_water.Valuate(GSTile.IsWaterTile);
            chunk_water.KeepValue(1);
            chunk_water.Valuate(IsFlatTile);
            chunk_water.KeepValue(1);
            chunk_water.Valuate(GSBase.RandItem);

            chunk_nondesert.AddList(chunk_land);
            chunk_nondesert.Valuate(GSTile.IsDesertTile);
            chunk_nondesert.KeepValue(0);
            chunk_nondesert.Valuate(GSBase.RandItem);

            chunk_nonsnow.AddList(chunk_land);
            chunk_nonsnow.Valuate(GSTile.IsSnowTile);
            chunk_nonsnow.KeepValue(0);
            chunk_nonsnow.Valuate(GSBase.RandItem);

            land_tiles.AddList(chunk_land);
            shore_tiles.AddList(chunk_shore);
            water_tiles.AddList(chunk_water);
            nondesert_tiles.AddList(chunk_nondesert);
            nonsnow_tiles.AddList(chunk_nonsnow);
            if(progress.Increment()) {
                Print(progress, 0);
            }
        }
    }
    land_tiles.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
    shore_tiles.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
    water_tiles.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
    nondesert_tiles.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
    nonsnow_tiles.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
    BuildEligibleTownTiles();
    Print("Land tile list size: " + land_tiles.Count(), 0);
    Print("Shore tile list size: " + shore_tiles.Count(), 0);
    Print("Water tile list size: " + water_tiles.Count(), 0);
    Print("Nondesert tile list size: " + nondesert_tiles.Count(), 0);
    Print("Nonsnow tile list size: " + nonsnow_tiles.Count(), 0);
    Print("Town tile list size: " + town_tiles.Count(), 0);
    Print("Outer town tile list size: " + outer_town_tiles.Count(), 0);
}

function IndustryPlacer::IsFlatTile(tile_id) {
    return GSTile.GetSlope(tile_id) == GSTile.SLOPE_FLAT;
}

// Returns the map chunk with x, y in the upper left corner
// i.e. GetChunk(1, 1) will give you (1, 1) to (257, 257)
function IndustryPlacer::GetChunk(x, y) {
    local chunk = GSTileList();
    chunk.AddRectangle(GSMap.GetTileIndex(x, y),
                       GSMap.GetTileIndex(min(x + 256, GSMap.GetMapSizeX() - 2),
                                          min(y + 256, GSMap.GetMapSizeY() - 2)));
    return chunk;
}
// Zero
function GenerationMod::Zero(x) {
    return 0;
}

// Identity
function GenerationMod::Id(x) {
    return 1;
}
