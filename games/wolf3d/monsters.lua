------------------------------------------------------------------------
--  WOLF3D MONSTERS
------------------------------------------------------------------------
--
--  Copyright (C) 2006-2017 Andrew Apted
--  Copyright (C)      2008 Sam Trenholme
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2,
--  of the License, or (at your option) any later version.
--
------------------------------------------------------------------------

WOLF.MONSTERS =
{
  dog =
  {
    id = 174,
    r = 30,
    h = 60,
    prob=20,
    health=1, 
    damage=5, 
    attack="melee",
  },

  guard =
  {
    id = 144,
    r = 30,
    h = 60,
    prob=60,
    health=25,
    damage=10, 
    attack="hitscan",
    give={ {ammo="bullet",count=4} },
  },

  officer =
  {
    id = 152,
    r = 30,
    h = 60,
    prob=30,
    health=50,  
    damage=20, 
    attack="hitscan",
    give={ {ammo="bullet",count=4} },
  },

  mutant =
  {
    id = 234,
    r = 30,
    h = 60,
    prob=20,
    health=55,  
    damage=35, 
    attack="hitscan",
    give={ {ammo="bullet",count=4} },
  },

  ss_dude =
  {
    id = 162,
    r = 30,
    h = 60,
    prob=5,
    health=100, 
    damage=30, 
    attack="hitscan",
    give={ {weapon="machine_gun"}, {ammo="bullet",count=4} },
  },

  fake_hitler =
  {
    id = 160,
    r = 30,
    h = 60,
    health=350, 
    damage=50, 
    attack="missile",
  },

  --| WOLF BOSSES |--

  -- FIXME: hit-points are just averages of skill 2 and 3

  -- FIXME: proper damage values

  Hans =
  {
    id = 214,
    r = 30,
    h = 60,
    health=1000, 
    damage=40, 
    attack="hitscan",
    give={ {key="k_gold"} }
  },

  Gretel =
  {
    id = 197,
    r = 30,
    h = 60,
    health=1000, 
    damage=50, 
    attack="hitscan",
    give={ {key="k_gold"} }
  },

  Fatface =
  {
    id = 179,
    r = 30,
    h = 60,
    health=1000, 
    damage=50, 
    attack="hitscan",
  },

  Giftmacher =
  {
    id = 215,
    r = 30,
    h = 60,
    health=1000, 
    damage=50, 
    attack="missile",
  },

  Schabbs =
  {
    id = 196,
    r = 30,
    h = 60,
    health=1250, 
    damage=60, 
    attack="missile",
  },

  -- this includes both Hitlers (in and out of the armor suit)
  Hitler =
  {
    id = 178,
    r = 30,
    h = 60,
    health=1100, 
    damage=60, 
    attack="hitscan"
  },

  -- NOTES:
  --
  -- The SS only drops a machine gun (which gives _6_ bullets)
  -- when you don't already have it, otherwise he drops a _4_
  -- bullet clip.  To maintain ammo balance, we assume it is
  -- always 4 bullets.

}
