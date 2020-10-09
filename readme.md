# Generation Mod
Greetings. This project is a mod for the legendary OpenTTD game. 
Its main goals:
 1) Maintain functionality but improve script performance
 2) Extend script functionality into other 'post-map creation' initialization
 3) Adding the ability to change certain values when creating interconnected industries
 4) Increasing the realism of the generated map
 5) Creating an opportunity for the player to adapt the game to their standards and ideals

# Installation

Put the repo files in `<OpenTTD path>\game\GenerationMod`

# Required game settings

No. of industries				Funding only
Allow multiple similar industries per town	Yes 
Max distance from edge for Oil Refineries 	32 

# Recommended map settings

Towns				Normal
Terrain type			Hilly 
Sea level			Very low
Variety distribution		Low
Edges				All water
Snow line			4

# Parameters

Based on 256 x 256.

# General
- Max distance from edge for Oil Refineries.

- Allow multiple similar industries per town?

- Prospect abnormal industries rather than use methods?
	Use this setting when the script is getting stuck at the abnormal industries (see above).

# Manage
- Manage industry amount?
	Yes to build industries every X months based on current numbers.
- Industry build rate (months)
	The waiting period to build more industries.
- Industry build limit (per refresh)
	The max number to build every period.

# Debug
- Log level (higher = print more)


# Density
- Total industries
	The base number of industries (based on a 256 * 256 map).
- Min industries %
	Modifies chances based on total.
- Max industries %
	Modifies chances based on total.
- Primary industries proportion
	Proportion of "raw producer" industries.
- Secondary industries proportion
	Proportion of "processing" industries.
- Tertiary industries proportion
	Proportion of "accepting only" industries.
- Special industries proportion
	Proportion of "special" industries (see above section).
- Primary industries spawning method
	Method to use to spawn "raw producer" industries.
- Secondary industries spawning method
	Method to use to spawn "processing" industries.
- Tertiary industries spawning method
	Method to use to spawn "accepting only" industries.

# Scattered

- Minimum distance from towns
- Minimum distance from industries

# Cluster

 - Maximum industries per cluster
 - Minimum distance between same cluster industries
 - Maximum distance between same cluster industries
 - Minimum distance between clusters
 - Minimum distance from towns
 - Minimum distance from industries

# Town
 - Minimum population
 - Minimum distance from town
 - Maximum distance from town factor
 	Used in the calculation of minimum radius from town center (Radius = Houses# * (x / 100)).
 - Maximum total industries per town
 - Minimum distance from other industries
 - Multiple same industries in town?
