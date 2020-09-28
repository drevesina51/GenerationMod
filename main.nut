// Objectives

// 1) Maintain functionality but improve script performance
// 2) Extend script functionality into other 'post-map creation' initialization
// 3)Adding the ability to change certain values ​​when creating interconnected industries
// 4) Increasing the realism of the generated map
// 5) Creating an opportunity for the player to adapt the game to their standards and ideals

require("progress.nut");

class IndustryPlacer extends GSController {
    // change based on setting
    farm_spacing = 0;
    raw_industry_min = 0;
    proc_industry_min = 0;
    tertiary_industry_min = 0;
    debug_level = 0;

// Save function
function IndustryPlacer::Save() {
    return {};
}

// Load function
function IndustryPlacer::Load() {
}

// Program start function
function IndustryPlacer::Start() {
    industry_classes = GSIndustryTypeList();
    this.Init();
}

.......

// Zero
function IndustryPlacer::Zero(x) {
    return 0;
}

// Identity
function IndustryPlacer::Id(x) {
    return 1;
}
