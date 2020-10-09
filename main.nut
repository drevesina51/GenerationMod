// Objectives

// 1) Maintain functionality but improve script performance
// 2) Extend script functionality into other 'post-map creation' initialization
// 3) Adding the ability to change certain values when creating interconnected industries
// 4) Increasing the realism of the generated map
// 5) Creating an opportunity for the player to adapt the game to their standards and ideals

require("progress.nut");

class GenerationMod extends GSController {
    // change based on setting
    town_industry_limit = 0;
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
   
   // Tile lists
    land_tiles = GSTileList();
    shore_tiles = GSTileList();
    water_tiles = GSTileList();
    nondesert_tiles = GSTileList();
    nonsnow_tiles = GSTileList();
    town_tiles = GSTileList();
    outer_town_tiles = GSTileList();
    core_town_tiles = GSTileList();

    // Town eligibility lists: 1 for eligible in that category, 0 else
    // A town is 'eligible' if any tiles in its influence are still available for industry construction
    town_eligibility_default = GSTownList();
    town_eligibility_water = GSTownList();
    town_eligibility_shore = GSTownList();
    town_eligibility_townbldg = GSTownList();
    town_eligibility_neartown = GSTownList();
    town_eligibility_nondesert = GSTownList();
    town_eligibility_nonsnow = GSTownList();
    town_eligibility_nonsnowdesert = GSTownList();
    
    farmindustry_list = [];
    rawindustry_list = []; // array of raw industry type id's, set in industryconstructor.init.
    rawindustry_list_count = 0; // count of primary industries, set in industryconstructor.init.
    procindustry_list = []; // array of processor industry type id's, set in industryconstructor.init.
    procindustry_list_count = 0; // count of secondary industries, set in industryconstructor.init.
    tertiaryindustry_list = []; // array of tertiary industry type id's, set in industryconstructor.init.
    tertiaryindustry_list_count = 0; // count of tertiary industries, set in industryconstructor.init.
    industry_classes = GSIndustryTypeList(); // Stores the build-type of industries
 
    constructor() {
        this.town_industry_limit = GSController.GetSetting("town_industry_limit");
        this.farm_spacing = GSController.GetSetting("farm_spacing");
        this.raw_industry_min = GSController.GetSetting("raw_industry_min");
        this.proc_industry_min = GSController.GetSetting("proc_industry_min");
        this.tertiary_industry_min = GSController.GetSetting("tertiary_industry_min");
        this.debug_level = GSController.GetSetting("debug_level");
    } 
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

function GenerationMod::InArray(item, array) {
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
       foreach(ind_id, value in industry_classes) {
        local ind_name = GSIndustryType.GetName(ind_id);
        if(InArray(ind_name, water_based_industries)) {
            industry_classes.SetValue(ind_id, 1);
        }
        if(InArray(ind_name, shore_based_industries)) {
            industry_classes.SetValue(ind_id, 2);
        }
        if(InArray(ind_name, townbldg_based_industries)) {
            industry_classes.SetValue(ind_id, 3);
        }
        if(InArray(ind_name, neartown_based_industries)) {
            industry_classes.SetValue(ind_id, 4);
        }
        if(InArray(ind_name, nondesert_based_industries)) {
            industry_classes.SetValue(ind_id, 5);
        }
        if(InArray(ind_name, nonsnow_based_industries)) {
            industry_classes.SetValue(ind_id, 6);
        }
        if(InArray(ind_name, nonsnowdesert_based_industries)) {
            industry_classes.SetValue(ind_id, 7);
        }
        if(InArray(ind_name, skip_industries)) {
            industry_classes.SetValue(ind_id, 8);
        }
    } 
       foreach(ind_id, value in GSIndustryTypeList()) {
        local ind_name = GSIndustryType.GetName(ind_id);
        // We have to descend down these if else statements in order
        // Otherwise the overrides don't work
        if(!InArray(ind_name, skip_industries)) {
            if(InArray(ind_name, farm_override)) {
                farmindustry_list.push(ind_id);
            } else if(InArray(ind_name, primary_override)) {
                rawindustry_list.push(ind_id);
            } else if(InArray(ind_name, secondary_override)) {
                procindustry_list.push(ind_id);
            } else if(InArray(ind_name, tertiary_override)) {
                tertiaryindustry_list.push(ind_id);
            } else if(GSIndustryType.IsRawIndustry(ind_id)) {
                rawindustry_list.push(ind_id);
            } else if(GSIndustryType.IsProcessingIndustry(ind_id)) {
                procindustry_list.push(ind_id);
            } else {
                tertiaryindustry_list.push(ind_id);
            }
        }
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

// Initialization function
function GenerationMod::Init() {
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

function GenerationMod::FillCash() {
    if(GSCompany.GetBankBalance(company_id) < 100000000) {
        GSCompany.ChangeBankBalance(company_id, 1500000000, GSCompany.EXPENSES_OTHER);
    }
}
function GenerationMod::Build(industry_id, tile_index) {
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
function GenerationMod::InitializeTowns() {
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

function GenerationMod::MapPreprocess() {
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

function GenerationMod::IsFlatTile(tile_id) {
    return GSTile.GetSlope(tile_id) == GSTile.SLOPE_FLAT;
}

// Returns the map chunk with x, y in the upper left corner
// GetChunk(1, 1) will give you (1, 1) to (257, 257)
function GenerationMod::GetChunk(x, y) {
    local chunk = GSTileList();
    chunk.AddRectangle(GSMap.GetTileIndex(x, y),
                       GSMap.GetTileIndex(min(x + 256, GSMap.GetMapSizeX() - 2),
                                          min(y + 256, GSMap.GetMapSizeY() - 2)));
    return chunk;
}

// Go through each town and identify every valid tile_id (do we have a way to ID the town of a tile?)
function GenerationMod::BuildEligibleTownTiles() {
    /*
    1. get every town
    2. get every tile in every town
    3. cull based on config parameters
     */
    Print("Building town tile list.", 0);
    local town_list = GSTownList();
    town_list.Valuate(GSTown.GetLocation);
    local progress = ProgressReport(town_list.Count());
    foreach(town_id, tile_id in town_list) {
        core_town_tiles.AddList(RectangleAroundTile(tile_id, 4));
        local local_town_tiles = RectangleAroundTile(tile_id, town_radius);
        local distant_town_tiles = RectangleAroundTile(tile_id, town_long_radius);

        foreach(tile, value in distant_town_tiles) {
            if(local_town_tiles.HasItem(tile)) {
                outer_town_tiles.RemoveItem(tile);
                if(!town_tiles.HasItem(tile)) {
                    town_tiles.AddItem(tile, value);
                }
            } else {
                if(!outer_town_tiles.HasItem(tile) && !town_tiles.HasItem(tile)) {
                    outer_town_tiles.AddItem(tile, value);
                }
            }
        }
        if(progress.Increment()) {
            Print(progress, 0);
        }
    }
    // Cull all outer town tiles that 'splashed' into nearby towns
    foreach(tile, value in outer_town_tiles) {
        if(town_tiles.HasItem(tile)) {
            outer_town_tiles.RemoveItem(tile);
        }
    }
}

// Paints on the map all tiles in a given list
function GenerationMod::DiagnosticTileMap(tilelist, persist = false) {
    foreach(tile_id, value in tilelist) {
        GSSign.BuildSign(tile_id, ".");
    }
    GSController.Sleep(1);
    if(!persist) {
        foreach(sign_id, value in GSSignList()) {
            if(GSSign.GetName(sign_id) == ".") {
                GSSign.RemoveSign(sign_id);
            }
        }
    }
}

function GenerationMod::RectangleAroundTile(tile_id, radius) {
    local tile_x = GSMap.GetTileX(tile_id);
    local tile_y = GSMap.GetTileY(tile_id);
    local from_x = min(max(tile_x - radius, 1), GSMap.GetMapSizeX() - 2);
    local from_y = min(max(tile_y - radius, 1), GSMap.GetMapSizeY() - 2);
    local from_tile = GSMap.GetTileIndex(from_x, from_y);
    local to_x = min(max(tile_x + radius, 1), GSMap.GetMapSizeX() - 2);
    local to_y = min(max(tile_y + radius, 1), GSMap.GetMapSizeY() - 2);
    local to_tile = GSMap.GetTileIndex(to_x, to_y);
    local tiles = GSTileList();
    tiles.AddRectangle(from_tile, to_tile);
    return tiles;
}

// Fetch eligible tiles belonging to the town with the given ID
function GenerationMod::GetEligibleTownTiles(town_id, terrain_class) {
    local local_town_tiles = RectangleAroundTile(GSTown.GetLocation(town_id), town_radius);
    // now do a comparison between local town tiles and the terrain lists
    local local_eligible_tiles = GSTileList();
    local terrain_tiles = GSTileList();
    switch(terrain_class) {
    case "Water":
        terrain_tiles.AddList(water_tiles);
        break;
    case "Shore":
        terrain_tiles.AddList(shore_tiles);
        break;
    case "TownBldg":
        terrain_tiles.AddList(core_town_tiles);
        break;
    case "NearTown":
        terrain_tiles.AddList(town_tiles);
        break;
    case "Nondesert":
        terrain_tiles.AddList(nondesert_tiles);
        break;
    case "Nonsnow":
        terrain_tiles.AddList(nonsnow_tiles);
        break;
    case "Nonsnowdesert":
        terrain_tiles.AddList(nonsnow_tiles);
        terrain_tiles.KeepList(nondesert_tiles);
        break;
    case "Default":
        terrain_tiles.AddList(land_tiles);
        foreach(tile_id, value in terrain_tiles){} // WTF IS THIS
        break;
    case "All":
        return local_town_tiles;
    }
    foreach(tile_id, value in local_town_tiles) {
        if(terrain_tiles.HasItem(tile_id)) {
            local_eligible_tiles.AddItem(tile_id, value);
        }
    }
    return local_eligible_tiles;
}

// Given a tile list, filter to only tiles of that terrain class
function GenerationMod::FilterToTerrain(tile_list, terrain_class) {
    local filtered_list = GSTileList();
    foreach(tile_id, value in tile_list) {
        switch(terrain_class) {
        case "Water":
            if(water_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            };
            break;
        case "Shore":
            if(shore_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
            break;
        case "TownBldg":
            if(core_town_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
        case "NearTown":
            if(town_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
            break;
        case "Nondesert":
            if(nondesert_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
            break;
        case "Nonsnow":
            if(nonsnow_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
            break;
        case "Nonsnowdesert":
            if(nonsnow_tiles.HasItem(tile_id) && nondesert_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
            break;
        case "Default":
            if(land_tiles.HasItem(tile_id)) {
                filtered_list.AddTile(tile_id);
            }
            break;
        }
    }
    return filtered_list;
}

function GenerationMod::GetEligibleTowns(terrain_class) {
    local town_list = GSTownList();
    switch(terrain_class) {
    case "Water":
        town_list = town_eligibility_water;
        break;
    case "Shore":
        town_list = town_eligibility_shore;
        break;
    case "TownBldg":
        town_list = town_eligibility_townbldg;
        break
    case "NearTown":
        town_list = town_eligibility_neartown;
        break
    case "Nondesert":
        town_list = town_eligibility_nondesert;
        break
    case "Nonsnow":
        town_list = town_eligibility_nonsnow;
        break
    case "Nonsnowdesert":
        town_list = town_eligibility_nonsnowdesert;
        break
    case "Default":
        town_list = town_eligibility_default;
        break
    }
    town_list.KeepValue(1);
    return town_list;
}

// Town build method function
// return 1 if built and 0 if not
function GenerationMod::TownBuildMethod(industry_id) {
    local ind_name = GSIndustryType.GetName(industry_id);
    local terrain_class = industry_class_lookup[industry_classes.GetValue(industry_id)];
    local eligible_towns = GetEligibleTowns(terrain_class);
    if(eligible_towns.IsEmpty() == true) {
        Print("No more eligible " + terrain_class + " towns!", 2);
        return -1;
    }
    local town_id = SampleGSList(eligible_towns);
    local eligible_tiles = GetEligibleTownTiles(town_id, terrain_class);
    eligible_tiles.Valuate(GSBase.RandItem);
    eligible_tiles.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);
    Print("Attempting " + ind_name + " in " + GSTown.GetName(town_id), 3);

    if(eligible_tiles.Count() == 0) {
        Print("Exhausted " + terrain_class + " in " + GSTown.GetName(town_id), 2);
        DropTown(town_id, terrain_class);
        return 0;
    }
    // Exclude eligible tiles based on industry class:
    //DiagnosticTileMap(eligible_tiles);
    // For each tile in the town tile list, try to build in one of them randomly
    // - Maintain spacing as given by config file
    // - Once built, remove the tile ID from the global eligible tile list
    // - Two checks at the end:
    //    - Check for town industry limit here and cull from eligible_towns if this puts it over the limit
    //    - Check if the town we just built in now no longer has any eligible tiles
    while(eligible_tiles.Count() > 0) {
        local attempt_tile = eligible_tiles.Begin();
        eligible_tiles.RemoveTop(1);
        ClearTile(attempt_tile);
        local build_success = Build(industry_id, attempt_tile);
        if(build_success) {
            Print("Founded " + ind_name + " in " + GSTown.GetName(town_id), 3);
            // Check town industry limit (TK) and remove town from global eligible town list if so
            local town_current_industries = town_industry_counts.GetValue(town_id) + 1;
            town_industry_counts.SetValue(town_id, town_current_industries);
            if(town_current_industries == town_industry_limit) {
                // Remove town from eligible list AND remove its tiles from the eligible tiles list
                foreach(tile_id, value in GetEligibleTownTiles(town_id, "All")) {
                    ClearTile(tile_id);
                }
                eligible_towns.RemoveItem(town_id);
            }
            return 1;
        }
    }
    Print(GSTown.GetName(town_id) + " exhausted.", 2);
    // Tiles exhausted, return
    return 0;
}

function GenerationMod::DropTown(town_id, terrain_class) {
    switch(terrain_class) {
    case "Water":
        town_eligibility_water.SetValue(town_id, 0);
        break;
    case "Shore":
        town_eligibility_shore.SetValue(town_id, 0);
        break;
    case "TownBldg":
        town_eligibility_townbldg.SetValue(town_id, 0);
        break;
    case "NearTown":
        town_eligibility_neartown.SetValue(town_id, 0);
        break;
    case "Nondesert":
        town_eligibility_nondesert.SetValue(town_id, 0);
        break;
    case "Nonsnow":
        town_eligibility_nonsnow.SetValue(town_id, 0);
        break;
    case "Nonsnowdesert":
        town_eligibility_nonsnowdesert.SetValue(town_id, 0);
        break;
    case "Default":
        town_eligibility_default.SetValue(town_id, 0);
        break;
    }
}

function GenerationMod::SampleGSList(gslist) {
    if(gslist.Count() == 0) {
        return -1;
    }
    local index = [];
    foreach(item, value in gslist) {
        index.push(item);
    }
    return index[GSBase.RandRange(index.len())];
}

// Clean remove function for tiles
// We maintain several parallel lists of tiles (each can be thought of as an 'information layer'
// So when we remove a tile from eligibility, we should remove them from all of these lists
// Be sure to come back and update this if new information layers are added
// This is a TILE ID based function
function GenerationMod::ClearTile(tile_id) {
    land_tiles.RemoveItem(tile_id);
    shore_tiles.RemoveItem(tile_id);
    water_tiles.RemoveItem(tile_id);
    nondesert_tiles.RemoveItem(tile_id);
    nonsnow_tiles.RemoveItem(tile_id);
    town_tiles.RemoveItem(tile_id);
    outer_town_tiles.RemoveItem(tile_id);
    core_town_tiles.RemoveItem(tile_id);
}


// Check that the tile is sufficiently far from towns
// Two conditions:
// 1. Far enough from all 'big' towns.
// 2. Far enough from any town.
function GenerationMod::FarFromTown(tile_id) {
    local nearestTown = GSTile.GetClosestTown(tile_id);
    local population = GSTown.GetPopulation(nearestTown);
    local nearestTownLocation = GSTown.GetLocation(nearestTown);
    local distanceToTown = GSTile.GetDistanceSquareToTile(tile_id, nearestTownLocation);

    // Checking nearest like this can have an issue in the pathological case
    // where the nearest town is small and it's 1 tile closer than the second-nearest town
    // A. nearest town small, slightly further town big - behavior is to accept cluster construction (incorrectly)
    // B. nearest town big, slightly further town small - behavior is to reject cluster construction (correctly)
    return (distanceToTown > large_town_spacing && population < large_town_cutoff);
}

// Scans a radius around a tile for the number of tiles in the tile list around a given tile
function GenerationMod::GetFootprint(tile_id, tile_list, radius) {
    local footprint = RectangleAroundTile(tile_id, radius);
    footprint.KeepList(tile_list)
    return footprint;
}

function GenerationMod::ScatteredBuildMethod(industry_id) {
    local ind_name = GSIndustryType.GetName(industry_id);
    local terrain_class = industry_class_lookup[industry_classes.GetValue(industry_id)];
    local terrain_tiles = GSList();
    Print("Attempting to build " + ind_name, 3);
    switch(terrain_class) {
    case "Water":
        terrain_tiles.AddList(water_tiles);
        break;
    case "Shore":
        terrain_tiles.AddList(shore_tiles);
        break;
    case "NearTown":
        terrain_tiles.AddList(town_tiles);
        break;
    case "Nondesert":
        terrain_tiles.AddList(nondesert_tiles);
        break;
    case "Nonsnow":
        terrain_tiles.AddList(nonsnow_tiles);
        break;
    case "Nonsnowdesert":
        terrain_tiles.AddList(nondesert_tiles);
        terrain_tiles.KeepList(nonsnow_tiles);
        break;
    case "Default":
        terrain_tiles.AddList(land_tiles);
        break;
    }
    if(terrain_tiles.Count() == 0) {
        Print("Exhausted " + terrain_class + " tiles!", 2);
        return -1;
    }
    local attempt_tile = terrain_tiles.Begin();
    ClearTile(attempt_tile);
    local build_success = Build(industry_id, attempt_tile);
    if(build_success) {
        local industry_footprint = RectangleAroundTile(attempt_tile, industry_spacing);
        foreach(tile_id, value in industry_footprint) {
            ClearTile(tile_id);
        }
        Print("Built " + ind_name, 3);
    }
    return build_success ? 1 : 0;
}

function GenerationMod::FillFarms() {
    if(farmindustry_list.len() > 0) {
        Print("Filling in farmland.", 0);
        while(outer_town_tiles.Count() > 0) {
            local industry_id = farmindustry_list[GSBase.RandRange(farmindustry_list.len())];
            local ind_name = GSIndustryType.GetName(industry_id);
            local attempt_tile = SampleGSList(outer_town_tiles);
            ClearTile(attempt_tile);
            local build_success = Build(industry_id, attempt_tile);
            if(build_success) {
                foreach(tile_id, value in RectangleAroundTile(attempt_tile, farm_spacing)) {
                    ClearTile(tile_id);
                }
            }
        }
    }
}

/*
Helper functions
 */

// Custom get closest industry function
function GenerationMod::GetClosestIndustry(tile_id) {
    // Create a list of all industries
    local ind_list = GSIndustryList();

    // If count is 0, return null
    if(ind_list.Count() == 0) return null;

    // Valuate by distance from tile
    ind_list.Valuate(GSIndustry.GetDistanceManhattanToTile, tile_id);

    // Sort smallest to largest
    ind_list.Sort(GSList.SORT_BY_VALUE, GSList.SORT_ASCENDING);

    // Return the top one
    return ind_list.Begin();
}

// Min/Max X/Y list function, returns a 4 tile list with X Max, X Min, Y Max, Y Min, or blank list on fail.
// If second param is == true, returns a 2 tile list with XY Min and XY Max, or blank list on fail.
function GenerationMod::ListMinMaxXY(tile_list, two_tile) {
    // Squirrel is pass-by-reference
    local local_list = GSList();
    local_list.AddList(tile_list);
    local_list.Valuate(GSMap.IsValidTile);
    local_list.KeepValue(1);

    if(local_list.IsEmpty()) {
        return null;
    }

    local_list.Valuate(GSMap.GetTileX);
    local_list.Sort(GSList.SORT_BY_VALUE, false);
    x_max_tile = local_list.Begin();
    local_list.Sort(GSList.SORT_BY_VALUE, true);
    x_min_tile = local_list.Begin();

    local_list.Valuate(GSMap.GetTileY);
    local_list.Sort(GSList.SORT_BY_VALUE, false);
    y_max_tile = local_list.Begin();
    local_list.Sort(GSList.SORT_BY_VALUE, true);
    y_min_tile = local_list.Begin();

    local output_tile_list = GSTileList();

    if(two_tile) {
        local x_min = GSMap.GetTileX(x_min_tile);
        local x_max = GSMap.GetTileX(x_max_tile);
        local y_min = GSMap.GetTileY(y_min_tile);
        local y_max = GSMap.GetTileY(y_max_tile);
        output_tile_list.AddTile(GSMap.GetTileIndex(x_min, y_min));
        output_tile_list.AddTile(GSMap.GetTileIndex(x_max, y_max));
    } else {
        output_tile_list.AddTile(x_max_tile);
       output_tile_list.AddTile(x_min_tile);
        output_tile_list.AddTile(y_max_tile);
        output_tile_list.AddTile(y_min_tile);
    }
    return output_tile_list;
}

// Function to check if tile is industry, returns true or false
function IsIndustry(tile_id) {return (GSIndustry.GetIndustryID(tile_id) != 65535);}

function GetTownDistFromEdge(town_id) {
    return GSMap.DistanceFromEdge(GSTown.GetLocation(town_id));
}

// Given a tile, returns true if the nearest industry is further away than TOWN_MIND_IND
function GenerationMod::FarFromIndustry(tile_id) {
    local nearest_industry_tile = this.GetClosestIndustry(tile_id);
    if(nearest_industry_tile == null) {
        return true; // null case - no industries on map
    }
    local ind_distance = GSIndustry.GetDistanceManhattanToTile(nearest_industry_tile, tile_id);
    return ind_distance > (GSController.GetSetting("TOWN_MIN_IND"));
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
