------------------------------------------------------------------------
--  MODULE: Miscellaneous Stuff
------------------------------------------------------------------------
--
--  Copyright (C) 2009      Enhas
--  Copyright (C) 2009-2017 Andrew Apted
--  Copyright (C) 2019-2020 MsrSgtShooterPerson
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2,
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
------------------------------------------------------------------------

MISC_STUFF_QUAKE = { }

MISC_STUFF_QUAKE.LIGHTINGS =
{
  "flat",    _("FLAT"),
  "lower",   _("Lower"),
  "normal",  _("Normal"),
  "higher",  _("Higher"),
}

MISC_STUFF_QUAKE.LIGHT_CHOICES =
{
  "-3",   _("Pitch-black"),
  "-2",   _("Gloomy"),
  "-1",   _("Darker"),
  "none", _("NONE"),
  "+1",   _("Brighter"),
  "+2",   _("Vivid"),
  "+3",   _("Radiant"),
}

MISC_STUFF_QUAKE.LIVEMAP_CHOICES =
{
  "step", _("Per Step (Very Slow)"),
  "room", _("Per Room (Slightly Slow)"),
  "none", _("No Live Minimap"),
}

MISC_STUFF_QUAKE.SINK_STYLE_CHOICES =
{
  "themed", _("Per Theme"),
  "curved", _("Curved"),
  "sharp", _("Sharp"),
  "random", _("Random"),
}

MISC_STUFF_QUAKE.HEIGHT_CHOICES =
{
  "short",     _("Mostly Short"),
  "short-ish", _("Slightly Short"),
  "normal",    _("Normal"),
  "tall-ish",  _("Slightly Tall"),
  "tall",      _("Mostly Tall"),
  "mixed",     _("Mix It Up"),
}

MISC_STUFF_QUAKE.WINDOW_BLOCKING_CHOICES =
{
  "not_on_vistas", _("Not on Vistas"),
  "never",         _("Never"),
  "all",           _("All"),
}

MISC_STUFF_QUAKE.RAIL_BLOCKING_CHOICES =
{
  "never",       _("Never"),
  "on_occasion", _("Occasional"),
  "all",         _("All"),
}

MISC_STUFF_QUAKE.LIQUID_SINK_OPTIONS =
{
  "yes",          _("Yes"),
  "not_damaging", _("No Damaging"),
  "no",           _("No"),
}

MISC_STUFF_QUAKE.LINEAR_START_CHOICES =
{
  "100",     _("All"),
  "75",      _("75% of All Levels"),
  "50",      _("50% of All Levels"),
  "25",      _("25% of All Levels"),
  "12",      _("12% of All Levels"),
  "default", _("DEFAULT"),
}

MISC_STUFF_QUAKE.ROOM_SIZE_MULTIPLIER_CHOICES =
{
  "0.25", _("x0.25"),
  "0.5", _("x0.5"),
  "0.75", _("x0.75"),
  "1", _("x1"),
  "1.25", _("x1.25"),
  "1.5", _("x1.5"),
  "2", _("x2"),
  "4", _("x4"),
  "6", _("x6"),
  "8", _("x8"),
  "vanilla", _("Vanilla"),
  "mixed", _("Mix It Up")
}

MISC_STUFF_QUAKE.AREA_COUNT_MULTIPLIER_CHOICES =
{
  "0.15", _("x0.15"),
  "0.5", _("x0.5"),
  "0.75", _("x0.75"),
  "1", _("x1"),
  "1.5", _("x1.5"),
  "2", _("x2"),
  "4", _("x4"),
  "vanilla", _("Vanilla"),
  "mixed", _("Mix It Up")
}

MISC_STUFF_QUAKE.ROOM_SIZE_CONSISTENCY_CHOICES =
{
  "normal", _("Vanilla"),
  "strict", _("Strict"),
  "mixed", _("Mix It Up")
}

function MISC_STUFF_QUAKE.setup(self)
  -- these parameters have to be instantiated in this hook
  -- because begin_level happens *after* level size decisions
  for name,opt in pairs(self.options) do
    if OB_CONFIG.batch == "yes" then
      if not PARAM[opt.name] then PARAM[opt.name] = OB_CONFIG[opt.name] end
      if RANDOMIZE_GROUPS then
        for _,group in pairs(RANDOMIZE_GROUPS) do
          if opt.randomize_group and opt.randomize_group == group then
            if opt.valuator then
              if opt.valuator == "button" then
                  PARAM[opt.name] = rand.sel(50, 1, 0)
                  goto done
              elseif opt.valuator == "slider" then
                  if opt.increment < 1 then
                    PARAM[opt.name] = rand.range(opt.min, opt.max)
                  else
                    PARAM[opt.name] = rand.irange(opt.min, opt.max)
                  end
                  goto done
              end
            else
              PARAM[opt.name] = rand.pick(opt.choices)
              goto done
            end
          end
        end
      end
      ::done::
    else
	    if opt.valuator then
		    if opt.valuator == "button" then
		        PARAM[opt.name] = gui.get_module_button_value(self.name, opt.name)
		    elseif opt.valuator == "slider" then
		        PARAM[opt.name] = gui.get_module_slider_value(self.name, opt.name)      
		    end
      else
        PARAM[opt.name] = opt.value
	    end
	  end
  end
    --Brightness sliders
    PARAM["wad_minimum_brightness"] = math.min(PARAM.float_minimum_brightness, PARAM.float_maximum_brightness)
    PARAM["wad_maximum_brightness"] = math.max(PARAM.float_minimum_brightness, PARAM.float_maximum_brightness)
end

function MISC_STUFF_QUAKE.begin_level(self)
  for _,opt in pairs(self.options) do
    if opt.valuator then goto continue end

    local name  = assert(opt.name)
    local value = opt.value

    if opt.choices == STYLE_CHOICES then
      if value ~= "mixed" then
        STYLE[name] = value
      end

    else
      -- pistol_starts, or other YES/NO stuff
      if opt.name == "liquid_sinks" then
        PARAM[name] = value
      end
      if value ~= "no" then
        PARAM[name] = value
      end
    end

    ::continue::
  end
end


OB_MODULES["misc_quake"] =
{

  name = "misc_quake",

  label = _("Miscellaneous"),

  game = "quake",

  side = "left",
  priority = 101,

  hooks =
  {
    setup = MISC_STUFF_QUAKE.setup,
    begin_level = MISC_STUFF_QUAKE.begin_level
  },

  options =
  {
    {
      name="bool_pistol_starts",
      label=_("Pistol Starts"),
      valuator = "button",
      default = 1,
      tooltip=_("Ensure every map can be completed from a zorcher start (ignore weapons obtained from earlier maps)")
    },
    {
      name="bool_alt_starts",
      label=_("Alt-start Rooms"),
      valuator = "button",
      default = 0,
      tooltip=_("For Co-operative games, sometimes have players start in different rooms")
    },
    
    {
      name = "bool_foreshadowing_exit",
      label = _("Foreshadowing Exit"),
      valuator = "button",
      default = 1,
      tooltip = "Gets exit room theme to follow the theme of the next level, if different.",
      gap=1,
    },

    {
      name="room_size_multiplier", label=_("Room Size Multiplier"),
      choices = MISC_STUFF_QUAKE.ROOM_SIZE_MULTIPLIER_CHOICES,
      default = "mixed",
      tooltip = "Alters the general size and ground coverage of rooms.\n\n" ..
        "Vanilla: No room size multipliers.\n\n" ..
        "Mix It Up: All multiplier ranges are randomly used with highest and lowest multipliers being rarest.",
    },
    {
      name="room_area_multiplier", label=_("Area Count Multiplier"),
      choices = MISC_STUFF_QUAKE.AREA_COUNT_MULTIPLIER_CHOICES,
      default = "mixed",
      tooltip = "Alters the amount of areas in a room. Influences the amount rooms are divided into different elevations or "..
        "simply different ceilings if a level has no steepness.\n\n" ..
        "Vanilla: No area quantity multipliers.\n\n" ..
        "Mix It Up: All multiplier ranges are randomly used with highest and lowest multipliers being rarest.",
    },
    {
      name="room_size_consistency", label=_("Size Consistency"),
      choices = MISC_STUFF_QUAKE.ROOM_SIZE_CONSISTENCY_CHOICES,
      default = "mixed",
      tooltip = "Changes whether rooms follow a strict single size or not. " ..
        "Can be paired with above choices for more enforced results.\n\n" ..
        "Vanilla: Original behavior. Rooms in a level have vary in size from each other. Big Rooms options are respected.\n\n" ..
        "Strict: All rooms in the level have a single set size/coverage.\n\n" ..
        "Mix It Up: A mixture of 75% Vanilla, 25% Strict.",
      gap = 1,
    },

    { name="big_rooms",   label=_("Big Rooms"),      choices=STYLE_CHOICES },
    { name="big_outdoor_rooms", label=_("Big Outdoors"), choices=STYLE_CHOICES },
    {
      name="room_heights",
      label=_("Room Heights"),
      choices=MISC_STUFF_QUAKE.HEIGHT_CHOICES,
      tooltip=_("Determines if rooms should have a height limit or should exaggerate their height. " ..
      "Short means room areas strictly have at most 128 units of height, tall means rooms immediately have " ..
      "doubled heights. Normal is the default Oblige behavior."),
      default="normal",
      gap=1,
    },


    { name="parks",       label=_("Parks"),          choices=STYLE_CHOICES },
    {
      name="natural_parks",
      label=_("Natural Cliffs"),
      tooltip=_("Percentage of parks that use completely naturalistic walls."),
      choices=STYLE_CHOICES,
      default="none",
    },
    { name="park_detail",
      label=_("Park Detail"),
      tooltip=_("Reduces or increases the probability of park decorations such as trees on park rooms."),
      choices=STYLE_CHOICES,
      gap=1,
    },

    { name="windows",     label=_("Windows"),        choices=STYLE_CHOICES },
    {
      name="passable_windows",
      label=_("Passable Windows"),
      choices=MISC_STUFF_QUAKE.WINDOW_BLOCKING_CHOICES,
      tooltip=_("Sets the preferences for passability on certain windows. On Vistas Only means only windows " ..
                "that look out to vistas/map border scenics have a blocking line."),
      default="not_on_vistas",
    },
    {
      name="passable_railings",
      label=_("Passable Railings"),
      choices=MISC_STUFF_QUAKE.RAIL_BLOCKING_CHOICES,
      tooltip=_("Sets the passability of railing junctions between full impassability or the 3D midtex flag. " ..
            "Occasional means 3D midtex is only used on railings between areas the player is supposed to " ..
            "circumvent. Always means the inclusion of cages and scenic rails, allowing flying monsters to " ..
            "potentially escape.\n\nNote: 3D midtex lines currently *block* projectiles as well."),
      default="never",
      gap=1,
    },

    { name="symmetry",    label=_("Symmetry"),       choices=STYLE_CHOICES },
    { name="beams",       label=_("Beams"),          choices=STYLE_CHOICES,
      tooltip = "Allows the appearance of thin pillars to appear between the borders of different elevations.",
    },
    { name="fences",      label=_("Fences"),         choices=STYLE_CHOICES,
      tooltip = "Creates thick solid fences and fence posts between areas of varying height for outdoor rooms.",
    },
    { name="porches",     label=_("Porches\\Gazebos"),        choices=STYLE_CHOICES,
      tooltip = "Occasional outdoor areas with a lowered indoor-ish ceiling.",
    },
    { name="scenics",     label=_("Scenics"),          choices=STYLE_CHOICES,
      tooltip = "Controls the amount of fancy scenics visible at room bordering the maps.",
      gap = 1,
    },
    { name = "corner_style",
      label=_("Sink Style"),
      choices=MISC_STUFF_QUAKE.SINK_STYLE_CHOICES,
      tooltip = "Determines the style for corners with sunken " ..
                "ceilings and floors. Curved makes sink " ..
                "corners soft, while Sharp leaves the corners angular. " ..
                "Per Theme means choice is controlled by theme profile instead. " ..
                "Tech-ish maps favor sharp corners while hell-ish favor curved.",
      default = "themed",
    },
    {
      name = "liquid_sinks",
      label=_("Liquid Sinks"),
      choices=MISC_STUFF_QUAKE.LIQUID_SINK_OPTIONS,
      tooltip = "Enables or disables liquid sinks. Liquid sinks are walkable floors that " ..
                "are often converted into depressions with the level's liquid. " ..
                "May greatly inconvenience the player but default Oblige behavior is 'Yes'.",
      default = "yes",
      gap = 1,
    },

    { name="darkness",    label=_("Dark Outdoors"),  choices=STYLE_CHOICES },
    { 
      name="float_minimum_brightness", 
      label=_("Minimum Brightness"),
      valuator = "slider",
      units = "",
      min = 0,
      max = 256,
      increment = 16,
      default = 0,
      nan = "",
      presets = "",
      tooltip = "Sets the minimum brightness for the map.",
      longtip = "",
    },

    { 
      name="float_maximum_brightness", 
      label=_("Maximum Brightness"),
      valuator = "slider",
      units = "",
      min = 0,
      max = 256,
      increment = 16,
      default = 256,
      nan = "",
      presets = "",
      tooltip = "Sets the maximum brightness for the map.",
      longtip = "",
    },
    { name="barrels",     label=_("Canisters"),        choices=STYLE_CHOICES, gap=1 },

    { name="doors",       label=_("Doors"),          choices=STYLE_CHOICES },
    { name="keys",        label=_("Keyed Doors"),    choices=STYLE_CHOICES },
--[[    { name="trikeys",     label=_("Triple-Keyed Doors"),          choices=STYLE_CHOICES,
      tooltip = "Controls the chance to get three key door whenever three keys are present.",
    },
]]
    { name="switches",    label=_("Switched Doors"), choices=STYLE_CHOICES, gap=1 },
    
    { name="local_switches",    label=_("Switch Rooms"), choices=STYLE_CHOICES, 
      tooltip = "Controls the chance same-room switches and locks.",
      gap=1 
    },
--[[    {
      name="bool_road_markings",
      label=_("Road Markings"),
      valuator = "button",
      default = 1,
      tooltip = _("Adds street markings to roads."),
    },
    {
      name="street_traffic",
      label=_("Street Traffic"),
      choices=STYLE_CHOICES,
      tooltip = _("If Street Mode is enabled, changes the density of prefabs such " ..
      "as cars, barriers, crates, and relevant items on the roads."),
      gap = 1,
    },

    {
      name="bool_exit_signs",
      label=_("Exit Signs")
      valuator = "button",
      default = 1,
      tooltip=_("Places exit signs by exiting room")
      gap=1,
    },
--]]
    {
      name="linear_start",
      label=_("Linear Start"),
      choices=MISC_STUFF_QUAKE.LINEAR_START_CHOICES,
      tooltip=_("Stops start rooms from having more than one external room connection. " ..
      "Can help reduce being overwhelmed by attacks from multiple directions " ..
      "when multiple neighboring rooms connect into the start room. Default means " ..
      "no control, and levels can have linear starts at random based on shape grammars as " ..
      "per original Oblige 7.7 behavior."),
      default = "default",
    },
    {
      name="dead_ends",
      label=_("Dead Ends"),
      choices=STYLE_CHOICES,
      tooltip=_("Cleans up and removes areas with staircases that lead to nowhere.\n" ..
      "NONE means all dead ends are removed.\n" ..
      "Heaps means all dead ends are preserved (Oblige default)."),
      default = "heaps",
      gap = 1,
    },

    {
      name="live_minimap",
      label=_("Live Growth Minimap"),
      choices=MISC_STUFF_QUAKE.LIVEMAP_CHOICES,
      tooltip=_("Shows more steps Oblige performs on rooms as they are grown on the GUI minimap. May take a hit on generation speed.")
    },

  },
}
