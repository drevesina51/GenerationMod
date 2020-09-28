SELF_VERSION <- 1;

class GenerationMod extends AIInfo
{
  function GetAuthor()      { return "IRONy"; }
  function GetName()        { return "GenerationMod"; }
  function GetDescription() { return "Modification of generating economic models; }
  function GetVersion()     { return SELF_VERSION; }
  function GetDate()        { return "2020-2021"; }
  function CreateInstance() { return "GenerationMod"; }
  function GetShortName()   { return "GenMod"; }
  function GetAPIVersion()  { return "1.3"; }
  function GetUrl()         { return ""; }
  function GetSettings()
              
        AddSetting({
            name = "industry_spacing",
            description = "Space between any two industries",
            flags = CONFIG_INGAME,
            easy_value = 5,
            medium_value = 5,
            hard_value = 5,
            custom_value = 5,
            min_value = 0,
            max_value = 100,
            step_size = 10
       });
       AddSetting({
            name = "farm_spacing",
            description = "Spacing between farm fill",
            flags = CONFIG_INGAME,
            easy_value = 40,
            medium_value = 40,
            hard_value = 40,
            custom_value = 40,
            min_value = 0,
            max_value = 500,
            step_size = 10
        });
       AddSetting({
            name = "raw_industry_min",
            description = "Attempt to build this many clusters of raw industry",
            flags = CONFIG_INGAME,
            easy_value = 5000,
            medium_value = 5000,
            hard_value = 5000,
            custom_value = 5000,
            min_value = 0,
            max_value = 5000,
            step_size = 10
        });                    
       AddSetting({
            name = "proc_industry_min",
            description = "Attempt to build this many processing industries",
            flags = CONFIG_INGAME,
            easy_value = 10,
            medium_value = 10,
            hard_value = 10,
            custom_value = 10,
            min_value = 0,
            max_value = 5000,
            step_size = 10
        });
        AddSetting({
            name = "tertiary_industry_min",
            description = "Attempt to build this many tertiary industries",
            flags = CONFIG_INGAME,
            easy_value = 5000,
            medium_value = 5000,
            hard_value = 5000,
            custom_value = 5000,
            min_value = 0,
            max_value = 5000,
            step_size = 10
        });
        AddSetting({
            name = "debug_level",
            description = "Debug log level - 3 for most verbose",
            flags = CONFIG_INGAME,
            easy_value = 0,
            medium_value = 0,
            hard_value = 0,
            custom_value = 0,
            min_value = 0,
            max_value = 3,
            step_size = 1
        });
}
  
RegisterAI(MyNewAI());
