----------------------------------------------------------------
-- MONSTERS/HEALTH/AMMO
----------------------------------------------------------------
--
--  Oblige Level Maker (C) 2006,2007 Andrew Apted
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
----------------------------------------------------------------


-- FIXME: some kind of "inventory" info
AMMO_LIMITS =  -- double these for backpack
{
  bullet = 200, 
  shell  = 50,
  rocket = 50,
  cell   = 300
}

------------------------------------------------------------

TOUGH_FACTOR = { easy=0.75, medium=1.00, hard=1.33 }
ACCURACIES   = { easy=0.65, medium=0.75, hard=0.85 }

HITSCAN_RATIOS = { 1.0, 0.8, 0.6, 0.4, 0.2, 0.1 }
MISSILE_RATIOS = { 1.0, 0.4, 0.1, 0.03 }
MELEE_RATIOS   = { 1.0 }

HITSCAN_DODGES = { easy=0.11, medium=0.22, hard=0.33 }
MISSILE_DODGES = { easy=0.71, medium=0.81, hard=0.91 }
MELEE_DODGES   = { easy=0.85, medium=0.95, hard=0.99 }

HEALTH_DISTRIB = { 24, 50, 90, 40, 5 }
AMMO_DISTRIB   = { 50, 80, 50, 10, 2 }


------------------------------------------------------------


zprint = do_nothing
zdump_table = do_nothing


function compute_pow_factors()

  local function pow_factor(info)
    return 5 + 19 * info.hp ^ 0.5 * (info.dm / 50) ^ 1.2
  end

  for name,info in pairs(THEME.monsters) do
    info.pow = pow_factor(info)
  end
end


function add_thing(p, c, bx, by, name, blocking, angle, options)

  local kind = THEME.thing_nums[name]
  assert(kind)

--[[
if c.x==3 and c.y==3 then
print("add_thing",kind,bx,by,angle)
if options then dump_table(options, "options")
else print ("btw dude, no options")
end
end]]

  local B = p.blocks[c.blk_x+bx][c.blk_y+by]
  assert(B)

  if not B.things then B.things = {} end

  local THING =
  {
    name = name,
    kind = kind,
    angle = angle,
    options = options
  }

--[[
io.stderr:write("INSERTING ",kind," INTO BLOCK ", c.blk_x+bx, ",", c.blk_y+by, "\n")
--]]
  table.insert(B.things, THING)
  table.insert(p.all_things, THING)

  if blocking then
--- DOESNT TAKE SKILLS INTO ACCOUNT: assert(not B.has_blocker)
    B.has_blocker = true
  end

  return THING
end


function add_cage_spot(p,c, spot)
  if not c.cage_spots then
    c.cage_spots = {}
  end

  table.insert(c.cage_spots, spot)
end
  
function rectangle_to_spots(c, x,y, x2,y2)

  local w = x2-x+1
  local h = y2-y+1

  local spots = {}

  local function carve_it_up(x,y, w,h)
    local w2, h2 = int(w/2), int(h/2)
    
    if h > 2 then
      carve_it_up(x, y, w, h2)
      carve_it_up(x, y+h2, w, h-h2)
    elseif w > 2 then
      carve_it_up(x, y, w2, h)
      carve_it_up(x+w2, y, w-w2, h)
    else
      assert(w > 0 and h > 0)

      if (w==2) and (h==2) then
        table.insert(spots, {c=c, x=x, y=y, double=true })
      else
        for dx = 0,w-1 do for dy = 0,h-1 do
          table.insert(spots, {c=c, x=x+dx, y=y+dy})
        end end
      end
    end
  end

  carve_it_up(x,y, w,h)
  
  return spots
end


function hm_give_health(HM, value, limit)
  if HM.health < limit then
    HM.health = math.min(HM.health + value, limit)
  end
end

function hm_give_armor(HM, value, limit)
  if HM.armor < limit then
    HM.armor = math.min(HM.armor + value, limit)
  end
end

function hm_give_weapon(HM, weapon, ammo_mul)

  HM[weapon] = true

  local info = THEME.weapons[weapon]
  assert(info)

  if info.ammo and info.give then
    if info.ammo == "combo_mana" then
      HM.blue_mana  = HM.blue_mana  + info.give * (ammo_mul or 1)
      HM.green_mana = HM.green_mana + info.give * (ammo_mul or 1)
      return
    end

    HM[info.ammo] = HM[info.ammo] + info.give * (ammo_mul or 1)
  end
end

function hm_give_item(HM, item)

  if item == "backpack" then
    HM.backpack = true
    HM.bullet = HM.bullet + 10
    HM.shell  = HM.shell  + 4 
    HM.rocket = HM.rocket + 1 
    HM.cell   = HM.cell   + 20

  elseif item == "armor" then
    hm_give_armor(HM, 200, 200)

  elseif item == "mega" then
    hm_give_armor (HM, 200, 200)
    hm_give_health(HM, 200, 200)

  elseif item == "berserk" then
    HM.berserk = true
    hm_give_health(HM, 100, 100)

  elseif item == "invis" or item == "invul" then

    HM[item] = (HM[item] or 0) + 6
  end
end


function initial_models()
  local MODELS = {}

  for zzz,SK in ipairs(SKILLS) do
    MODELS[SK] = copy_table(THEME.initial_model)
    MODELS[SK].skill = SK
    MODELS[SK].toughness = 0
  end

  return MODELS
end


function random_turn(angle)
  local r = con.random() * 100
  local step = sel(rand_odds(22), 90, 45)

  if r < 33 then
    -- no change
  elseif r < 66 then
    angle = angle - step
  else
    angle = angle + step
  end

  if angle <  0   then angle = angle + 360 end
  if angle >= 360 then angle = angle - 360 end

  return angle
end


function fire_power(wp_info)
  return wp_info.rate * wp_info.dm
end


----------------------------------------------------------------

-- Simulate the battle for skill SK (2|3|4).
-- Updates the given player HModel.
--
function simulate_battle(p, HM, mon_set, quest)
 
  local shoot_accuracy = ACCURACIES[HM.skill]

  local active_mon = {}

  local cur_weap = "pistol"
  local remain_shots = 0


  local function dump_active_mon()
    zprint("  Monsters {")
    for zzz,AC in ipairs(active_mon) do
      zprint("    ", AC.name, AC.health)
    end
    zprint("  }")
  end

  local function give_monster_stuff(AC)
    if not THEME.mon_give then return end
    if AC.caged then return end

    local stuff = THEME.mon_give[AC.name]
    if not stuff then return end

    for zzz,item in ipairs(stuff) do
      if item.weapon then
        hm_give_weapon(HM, item.weapon, 0.5) -- dropped
      elseif item.ammo then
        assert(item.ammo ~= "combo_mana")
        HM[item.ammo] = HM[item.ammo] + item.give * 0.5
      else
        error("UKNOWN ITEM GIVEN BY " .. AC.name)
      end
    end
  end

  local function remove_dead_mon()
    for i = #active_mon,1,-1 do
      if active_mon[i].health <= 0 then
        give_monster_stuff(active_mon[i])
        table.remove(active_mon, i)
      end
    end
  end

  local function active_toughness()
    local T = 0
    for zzz,AC in ipairs(active_mon) do
      T = T + AC.health
    end
    return T
  end

  local function hurt_mon(idx, damage)
    local AC = active_mon[idx]
    if AC and AC.health > 0 then
      AC.health = AC.health - damage
    end
  end

  local function hurt_player(damage)
    -- ignore damage when Invulerable
    if HM.invul then return end

    if HM.armor > 0 then
      local saved = damage * 0.4  -- approximation
      if saved < HM.armor then
        HM.armor = HM.armor - saved
      else
        saved = HM.armor
        HM.armor = 0
      end
      damage = damage - saved
    end
    HM.health = HM.health - damage
  end


  local function player_shoot()

    local function select_weapon()
      
      -- firstly, select best weapon which has real ammo
      --[[ DISABLED -- provides better ammo 
      local wp

      for name,info in pairs(THEME.weapons) do
        if HM[name] and info.ammo and HM[info.ammo] > 0 then

          if not wp or firepower(wp) < firepower(name) then
            wp = name
          end
        end
      end
      if wp then return wp end
      --]]

      -- aha, ammo all gone, virtual reality mode.
      -- use current weapon for a small time, then switch

      if remain_shots > 0 then return cur_weap end

      local first_mon = active_mon[1].name
      assert(first_mon)

      -- preferred weapon based on monster
      local MW_prefs
      if THEME.mon_weap_prefs then MW_prefs = THEME.mon_weap_prefs[first_mon] end

      local names = {}
      local probs = {}
      
      for name,info in pairs(THEME.weapons) do
        if HM[name] then
          local freq = info.freq
          freq = freq * (MW_prefs and MW_prefs[name] or 1.0)

          table.insert(names, name)
          table.insert(probs, freq)
        end
      end

      assert(#names >= 1)
      assert(#names == #probs)

      local idx = rand_index_by_probs(probs)

      local wp = names[idx]
      local info = THEME.weapons[wp]
      assert(info)

      remain_shots = 1 + con.random() + con.random()
      remain_shots = int(remain_shots * info.rate)

      if remain_shots < 1 then remain_shots = 1 end

      return wp
    end

    local function blast_monsters(num, damage)
      for i = 1,num do
        hurt_mon(i, damage * (num - i + 1) / num)
      end
    end

    local function shoot_weapon(name, info)

zprint("PLAYER SHOOT: ", name, remain_shots, "ammo",
info.ammo and HM[info.ammo] or "-")

      hurt_mon(1, info.dm * shoot_accuracy)

zprint(active_mon, #active_mon, active_mon[1])
      -- shotguns can kill multiple monsters
      if (name == "shotty" or name == "super") and
          active_mon[1].health <= 0 and active_mon[2] then
        hurt_mon(2, info.dm * shoot_accuracy / 2.0)
      end

      if name == "bfg"    then blast_monsters(9, 50) end
      if name == "launch" then blast_monsters(3, 64) end

      if info.ammo then
        if info.ammo == "combo_mana" then
          HM[blue_mana]  = HM[blue_mana]  - info.per
          HM[green_mana] = HM[green_mana] - info.per
        else
          HM[info.ammo] = HM[info.ammo] - info.per
        end
      end

      remain_shots = remain_shots - 1
    end

    ------ player_shoot ------
    --
    -- 1. select weapon
    -- 2. apply damage to monster #1
    -- 2a. if shotgun killed #1, hit monster #2
    -- 2b. for BFG, spray monsters #1..#9
    -- 2c. rocket damage: partial for #1..#3
    -- 3. update ammo
    -- 4. return time taken

    cur_weap = select_weapon()

    local info = THEME.weapons[cur_weap]
    assert(info)

    shoot_weapon(cur_weap, info)

    return 1 / info.rate
  end


  local function monster_shoot(time)

    local function mon_hurts_mon(m1, m2)
      if m1 == m2 then
        return THEME.monsters[m1].hitscan and (m1 ~= "vile")
      end

      if (m1 == "knight" and m2 == "baron") or
         (m1 == "baron"  and m2 == "knight") then
        return false
      end

      return true
    end

    local function distance_ratio(idx, AC)
      -- vile fire is not blocked
      if AC.name == "vile" then return 1 end

      if AC.info.hitscan then return HITSCAN_RATIOS[idx] or 0 end
      if AC.info.melee   then return MELEE_RATIOS[idx] or 0 end
      return MISSILE_RATIOS[idx] or 0
    end

    local function dodge_ratio(AC)
      if AC.info.hitscan then return HITSCAN_DODGES[HM.skill] end
      if AC.info.melee   then return MELEE_DODGES[HM.skill] end
      return MISSILE_DODGES[HM.skill]
    end

    -------- monster_shoot ---------
    -- 
    -- 1. monster #1 does full damage to player
    -- 1a.  (all other melee monsters do ZERO dm)
    -- 2. monster #2..#N does partial damage:
    -- 2a. assuming other monsters get in way
    -- 2b. 2 -> 1/2, 3->1/3, 4->1/5, 5->1/8  factorial
    -- 2c. in-fighting (damage previous mon)
    -- 3. player dodging:
    -- 3a. hitscan: dodged 20%
    -- 3b. missile: dodged 50%
    -- 3c. melee: dodged 80%

    for idx,AC in ipairs(active_mon) do
      if AC.health > 0 then
        local ratio = distance_ratio(idx, AC)
        local dodge = 1.0 - dodge_ratio(AC)

        if HM.invis then dodge = dodge / 2 end

        local mon_walk = 0.5 -- monster walking/pain time

        hurt_player(AC.info.dm * time * ratio * dodge * mon_walk)

        -- simulate infighting
        local infight_prob = 0.75
        if idx >= 2 and mon_hurts_mon(AC.name, active_mon[idx-1].name) then
          hurt_mon(idx-1, AC.info.dm * time * mon_walk * infight_prob)
        end
      end 
    end
  end

  local function update_powerups(HM)

    if HM.invis then
      HM.invis = HM.invis - 1
      if HM.invis <= 0 then
        HM.invis = nil
        zprint("LOST POWERUP:", "invis")
      end
    end

    if HM.invul then
      HM.invul = HM.invul - 1
      if HM.invul <= 0 then
        HM.invul = nil
        zprint("LOST POWERUP:", "invul")
      end
    end
  end

  local function handle_quest()
    if quest then
      if quest.kind == "weapon" then
        hm_give_weapon(HM, quest.item)
        zprint("PICKED UP QUEST WEAPON", quest.item)
      
      elseif quest.kind == "item" then
        hm_give_item(HM, quest.item)
        zprint("PICKED UP QUEST ITEM", quest.item)
      end
    end
  end

  ---=== simulate_battle ===---

  update_powerups(HM)  -- tick 1 of 2

  -- create list of monsters
  assert(mon_set)

  for zzz,th in ipairs(mon_set) do
    for num = 1,th.horde do
      table.insert(active_mon,
        { name=th.name, info=th.info, health=th.info.hp, caged=th.caged })
    end
  end

  if #active_mon == 0 then
    update_powerups(HM)  -- tick 2 of 2
    handle_quest(do_quest)

    return
  end

  -- put toughest monster first, weakest last.
  table.sort(active_mon, function(A,B) return A.health > B.health end)

  local do_quest = true

  local total_time = 0
  local round_time

  local total_tough = active_toughness()

  repeat

zprint("\n  ----------------------\n")
zprint("  Time ", total_time)
dump_active_mon(active_mon)
zdump_table(HM, "HModel")

    round_time = player_shoot()

    monster_shoot(round_time)

    remove_dead_mon()

    -- get quest item at the half-way point
    if do_quest and active_toughness() < total_tough/2 then
      update_powerups(HM) -- tick 2 of 2
      handle_quest()

      do_quest = nil
    end

    total_time = total_time + round_time

  until #active_mon == 0

  assert(not do_quest)

zprint("BATTLE OVER.")
zdump_table(HM, "HModel")
zprint("\n\n\n")
end


----------------------------------------------------------------


function distribute_pickups(p, c, HM)

  local R -- table[SKILL] -> required num

  local SK = HM.skill
  assert(SK)

  local function add_pickup(c, name, info, cluster)
    if not c.pickup_set then
      c.pickup_set = { easy={}, medium={}, hard={} }
    end
    table.insert(c.pickup_set[SK], { name=name, info=info, cluster=cluster })
  end


  local function be_nice_to_player()

    if (settings.game == "doom") or (settings.game == "doom2") then

      -- let poor ol' player have a shotgun near start

      if c.along == #c.quest.path then return end

      if not HM.shotty and rand_odds(66) then
        add_pickup(c, "shotty", THEME.weapons.shotty, 1)
        hm_give_weapon(HM, "shotty")
      end

      if not HM.chain and c.quest.level >= 3 and rand_odds(11) then
        add_pickup(c, "chain", THEME.weapons.chain, 1)
        hm_give_weapon(HM, "chain")
      end

      if HM.armor <= 0 and rand_odds(2) then
        add_pickup(c, "green_armor", THEME.pickups.green_armor, 1)
        hm_give_armor(HM, 100, 100)
      end

    else
      -- FIXME: be nice to Heretic and Hexen players too!!
    end
  end


  local function compute_want(stat)
    return sel(stat == "health", 75, 0)
  end

  local function decide_pickup(stat, R)

    local infos = {}
    local probs = {}
    local names = {}

    for name,info in pairs(THEME.pickups) do
      if info.stat == stat then
        if info.give <= R * 3 then
          local prob = info.prob or 50
          if info.give > R then
            prob = prob / 3
          end
          table.insert(names, name)
          table.insert(infos, info)
          table.insert(probs, prob)
        end
      end
    end
    
    if #infos == 0 then return nil, nil end  -- SHIT!

    local idx = rand_index_by_probs(probs)
    local th_info = infos[idx]

    local cluster = int(rand_range(10,40) / th_info.give)

    if cluster < 1 then cluster = 1 end
    if cluster > 9 then cluster = 9 end  -- FIXME
  
    local max_cluster = 1 + int(R / th_info.give)

    if cluster > max_cluster then cluster = max_cluster end

--[[ if stat ~= "health" then
print("PICKUP ", names[idx], cluster, c.x, c.y)
end ]]
    return names[idx], th_info, cluster
  end

  local function get_distrib_targets(c)
    local distrib = copy_table(AMMO_DISTRIB)
    local targets = {}

    for n = 1,5 do
      local idx = c.along + n - 3
      if (1 <= idx) and (idx <= #c.quest.path) then
        targets[n] = c.quest.path[idx]
      else
        distrib[n] = 0
      end
    end

    return distrib, targets
  end

  local function add_coop_pickup(targets, ...)
    add_pickup(targets[3], ...)

    local L = targets[2] or targets[1] or targets[4]
    local H = targets[4] or targets[5] or targets[2]

    if L and rand_odds(70) then
      add_pickup(L, ...)
    end

    if H and rand_odds(70) then
      add_pickup(H, ...)
    end

    if not L and not H then
      add_pickup(targets[3], ...)
    end
  end


  ---=== distribute_pickups ===---

  local distrib, targets = get_distrib_targets(c)

  be_nice_to_player()


  for zzz,stat in ipairs(THEME.pickup_stats) do

    local want = compute_want(stat, HM)


    -- create pickups until target reached
    while HM[stat] < want do

      local r_max = want - HM[stat]

      local name, info, cluster = decide_pickup(stat, r_max)

      if not info then break end

      if p.coop and stat ~= "health" then
        add_coop_pickup(targets, name, info, cluster)
      else
        local tc = targets[rand_index_by_probs(distrib)]
        add_pickup(tc, name, info, cluster)
      end

      HM[stat] = HM[stat] + cluster * info.give
    end
  end
end


function place_battle_stuff(p, c)

  local SK

  local function copy_shuffle_spots(list)
    local copies = {}
    for zzz, spot in ipairs(list) do
      table.insert(copies, copy_table(spot))
    end
    rand_shuffle(copies)
    return copies
  end

  local function dump_spots(list)
    print("{")
    for zzz, sp in ipairs(list) do
      print(string.format("  (%d,%d) %s",
        sp.x, sp.y, sel(sp.double, "DOUBLE", "-")))
    end
    print("}")
  end
  
  local function spot_dist(s1, s2)
    local dx = math.abs(s1.x - s2.x)
    local dy = math.abs(s1.y - s2.y)
    return math.max(dx, dy)
  end
  
  local function alloc_spot(spots, want_big, near_to)

    if #spots == 0 then return nil, nil end

    if near_to and not want_big then
      local best = 0
      local best_d = 999

      -- our search is not exhaustive (too expensive!)
      for i = 1,math.min(#spots,BW) do
        if not spots[i].double then
          local d = spot_dist(spots[i], near_to)
          if d < best_d then best, best_d = i, d end
        end
      end

      if best > 0 then
        return table.remove(spots, best)
      end
    end
    
    for i = 1,#spots do
      if (not spots[i].double) == (not want_big) then
        return table.remove(spots, i)
      end
    end

    local spot = table.remove(spots, 1)

    -- split the double into four singles
    if spot.double then
      assert(not want_big)

      spot.double = nil

      table.insert(spots, { x=spot.x+1, y=spot.y+0 })
      table.insert(spots, { x=spot.x+0, y=spot.y+1 })
      table.insert(spots, { x=spot.x+1, y=spot.y+1 })

      -- intermingle the new singles
      rand_shuffle(spots)
    end

    return spot
  end

  local function place_pickup(spots, dat)

    local spot = alloc_spot(spots, dat.cluster >= 5)

    if not spot then
      con.printf("UNABLE TO PLACE: %s\n", dat.name)
      -- FIXME: put in next cell
      return
    end

    local options = { [SK]=true }

    assert(dat.cluster <= 9)
    for i = 1,dat.cluster do
      
      local dx = (int(i / 3) - 1) * 20 -- TEMP JUNK
      local dy = (int(i % 3) - 1) * 20
      if dat.cluster == 1 then dx,dy = 0,0 end

      local th = add_thing(p, c, spot.x, spot.y, dat.name, false, 0, options)
      th.dx, th.dy = dx, dy

      if spot.dx then th.dx = (th.dx or 0) + spot.dx end
      if spot.dy then th.dy = (th.dy or 0) + spot.dy end
    end
  end

  local function place_pickup_list(pickups)

    local spots = copy_shuffle_spots(c.free_spots)

    -- perform two passes, place big clusters first
    for pass = 1,2 do
      for zzz,dat in ipairs(pickups) do
        if (pass==1) == (dat.cluster >= 5) then
          place_pickup(spots, dat)

---###          -- more stuff for CO-OP gameplay
---###          if p.coop and rand_odds(72) then
---###            place_pickup(spots, dat)
---###          end

          -- re-use spots if we run out
          if #spots == 0 then 
            spots = copy_shuffle_spots(c.free_spots)
          end
        end
      end
    end
  end

  local function place_monster(spots, dat)
    assert(dat.info)

    if dat.caged then return end

    local angle = rand_irange(0,7) * 45

    local is_big = (dat.info.r >= 32)
    local spot = alloc_spot(spots, is_big)

    for i = 1,dat.horde do

      if not spot or (is_big and not spot.double) then
        con.printf("UNABLE TO PLACE: %s\n", dat.name)
        -- FIXME: put in next cell
        return
      end

      local options = { [SK]=true }

      if rand_odds(sel(c.along == #c.quest.path, 88, 44)) then
        options.ambush = true
      end

      local th = add_thing(p, c, spot.x, spot.y, dat.name, true, angle, options)

      if is_big then
        -- Note: cannot handle monsters with radius >= 64 
        th.dx = 32; th.dy = 32
      end

      if spot.dx then th.dx = (th.dx or 0) + spot.dx end
      if spot.dy then th.dy = (th.dy or 0) + spot.dy end

      angle = random_turn(angle)

      spot = alloc_spot(spots, is_big, spot)
    end
  end

  local function place_monster_list(mons)

    local spots = copy_shuffle_spots(c.free_spots)

    -- perform two passes, place big monsters first
    for pass = 1,2 do
      for zzz, dat in ipairs(mons) do
        local info = THEME.monsters[dat.name]
        if (pass==1) == (info.r >= 32) then
          place_monster(spots, dat)
        end
      end
    end
  end

  --- place_battle_stuff ---

  for zzz,skill in ipairs(SKILLS) do

    SK = skill

    if c.pickup_set then
      place_pickup_list(c.pickup_set[SK])
    end

    if c.mon_set then
      place_monster_list(c.mon_set[SK])
    end
  end
end

function place_quest_stuff(p, Q)

  for zzz,c in ipairs(Q.path) do
    if c.mon_set or c.pickup_set then
      place_battle_stuff(p, c)
      c.mon_set = nil
      c.pickup_set = nil
    end
  end
end


----------------------------------------------------------------


function battle_in_cell(p, c)

  local T, U, SK

  local function T_average()
    return (T.easy + T.medium + T.hard) / 3.0
  end

  local function T_max()
    return math.max(T.easy, T.medium, T.hard)
  end

  local function best_weapon(skill)
    local best_name
    local best_info

    -- most basic weapon
    for name,info in pairs(THEME.weapons) do
      if info.melee and info.held then
        best_name = name
        best_info = info
        break;
      end
    end

    assert(best_name)

    for name,info in pairs(THEME.weapons) do
      if p.models[skill][name] and not info.melee then
        if fire_power(info) > fire_power(best_info) then
          best_name, best_info = name, info
        end
      end
    end

    return best_info, best_name
  end

  local function free_spot(bx, by)
    local B = p.blocks[c.blk_x+bx][c.blk_y+by]

    return (B and not B.solid and (not B.fragments or B.can_thing) and
            not B.has_blocker and not B.is_cage and not B.near_player)
  end

  local function free_double_spot(bx, by)
    local f_min =  99999
    local f_max = -99999

    for dx = 0,1 do for dy = 0,1 do
      if not free_spot(bx+dx, by+dy) then return false end

      local B = p.blocks[c.blk_x+bx+dx][c.blk_y+by+dy]
      if B.fragments then
        B = B.fragments[1][1]
        assert(B)
      end

      f_min = math.min(f_min, B.f_h)
      f_max = math.max(f_max, B.f_h)
    end end

    return f_max <= (f_min + 10)
  end

  local function find_free_spots()
    local list = {}
    local total = 0
    for bx = 1,BW,2 do for by = 1,BH,2 do
      if bx < BW and by < BH and free_double_spot(bx, by) then
        table.insert(list, { c=c, x=bx, y=by, double=true})
        total = total + 4
      else
        for dx = 0,1 do for dy = 0,1 do
          if bx+dx <= BW and by+dy <= BH and free_spot(bx+dx, by+dy) then
            table.insert(list, { c=c, x=bx+dx, y=by+dy })
            total = total + 1
          end
        end end
      end
    end end

    return list, total
  end

---###  local function how_much_space()
---###    local count = 0
---###    for bx = 1,BW do
---###      for by = 1,BH do
---###        if free_spot(bx, by) then
---###          count = count + 1
---###        end
---###      end
---###    end
---###    return count / (BW * BH / 2)
---###  end


  local function decide_monster(firepower)

    local names = { "none" }
    local probs = { 30     }

    for name,info in pairs(THEME.monsters) do
      if (info.pow < T*2) and (info.fp < firepower*2) then

        local prob = info.prob
        if info.pow > T then
          prob = prob / 4
        end
        if (info.fp > firepower) then
          prob = prob / 4
        end

        table.insert(names, name)
        table.insert(probs, prob)
      end
    end

    if #probs == 1 then return nil, nil end

    local idx = rand_index_by_probs(probs)
    local name = names[idx]

    if name == "none" then return name, 0 end

    local info = THEME.monsters[name]
    assert(info)

    local horde = 1
    local max_horde = 1 + int(T / info.pow)

    if info.hp <= 500 and rand_odds(30) then horde = horde + 1 end
    if info.hp <= 100 then horde = horde + rand_index_by_probs { 90, 40, 10, 3, 0.5 } end

    if horde > max_horde then horde = max_horde end

    return name, horde
  end

  local function create_monsters()

    local fp = fire_power(best_weapon(SK))

    -- create monsters until T is exhausted
    for loop = 1,99 do
      local name, horde = decide_monster(fp)

      if not name then break end

      if name == "none" then
        T = T-20; U = U+20
      else
        local info = THEME.monsters[name]
        table.insert(c.mon_set[SK], { name=name, horde=horde, info=info })
        T = T - horde * info.pow
      end
    end
  end

  local function decide_cage_monster(firepower, x_horde, allow_big, allow_horde, allow_melee)

    local names = {}
    local probs = {}

    for name,info in pairs(THEME.monsters) do
      if (info.cage_fallback) or 
         ((info.pow * x_horde < T*2) and (info.fp < firepower*2))
      then
        local prob = info.cage_prob or info.cage_fallback or 0

        if info.melee and not allow_melee then prob = 0 end
        if info.r >= 31 and not allow_big then prob = 0 end

        if prob > 0 then
          table.insert(names, name)
          table.insert(probs, prob)
        end
      end
    end

    assert(#probs > 0)

    local idx = rand_index_by_probs(probs)
    local info = THEME.monsters[names[idx]]
    assert(info)

    local horde = 1
    if allow_horde and (info.r < 25) then
      if info.hp <= 100 then horde = 4
      elseif info.hp <= 450 then horde = 3
      else horde = 2
      end
    end

    return names[idx], horde
  end

  local function fill_cages()

    if not c.cage_spots then return end

    local orig_T = T

    local fp = fire_power(best_weapon(SK))
    
    local sml_name, sml_horde = decide_cage_monster(fp, #c.cage_spots)
    local big_name, big_horde = decide_cage_monster(fp, #c.cage_spots, true, true)

    for zzz,spot in ipairs(c.cage_spots) do

      local m_name  = sel(spot.double, big_name, sml_name)
      local m_horde = sel(spot.double, big_horde,sml_horde)

      if spot.different then
        m_name, m_horde = decide_cage_monster(fp, sel(spot.double,2,1), spot.double, spot.double)
      end

      local m_info = THEME.monsters[m_name]
      assert(m_info)

      for i = 1,m_horde do
        local angle = rand_irange(0,7) * 45
        local options = { [SK]=true }

        local dx = int((i-1)%2) * 64
        local dy = int((i-1)/2) * 64

        local th = add_thing(p, c, spot.x, spot.y, m_name, true, angle, options)

        if m_info.r >= 32 then  -- big monster
          dx, dy = dx+32, dy+32
        end

        if spot.dx then dx = dx + spot.dx end
        if spot.dy then dy = dy + spot.dy end

        th.dx = dx
        th.dy = dy

        -- allow monster to take part in battle simulation
        table.insert(c.mon_set[SK], { name=m_name, horde=1, info=m_info, caged=true })

        -- caged monsters affect the total toughness
        T = T - m_info.pow
      end
    end

    -- don't use up all the toughness, allow non-caged monsters
    T = math.max(T, orig_T / 3)
  end

  local function try_fill_closet(surp)
    if not surp then return end
    if surp.trigger_cell ~= c then return end

    local fp = fire_power(best_weapon(SK))

--print(c.x, c.y, table_to_string(surp,3))

    for zzz,place in ipairs(surp.places) do

      for yyy,spot in ipairs(place.spots) do

        local allow_big = not surp.depot_cell and spot.double
        local m_name, m_horde = decide_cage_monster(fp, 1, allow_big, spot.double, true)
        local m_info = THEME.monsters[m_name]
        assert(m_info)

        for i = 1,m_horde do
          local dx = int((i-1)%2) * 64
          local dy = int((i-1)/2) * 64

          local angle = delta_to_angle(5-(spot.x+dx/64), 5-(spot.y+dy/64))
          local options = { [SK]=true }

--con.printf("CLOSET %s @ cell %d,%d  block %d,%d\n",
--m_name, spot.c.x, spot.c.y, spot.x, spot.y)

          local th = add_thing(p, spot.c, spot.x, spot.y, m_name, true, angle, options)

          if m_info.r >= 32 then  -- big monster
            dx, dy = dx+32, dy+32
          end

          if spot.dx then dx = dx + spot.dx end
          if spot.dy then dy = dy + spot.dy end

          th.dx = dx
          th.dy = dy

          table.insert(place.mon_set[SK], { name=m_name, horde=1, info=m_info, caged=true })
        end
      end  -- spots
    end  -- places

    -- health/ammo are added later (in backtrack_to_cell)
  end

  local function fill_closets()
    try_fill_closet(c.quest.closet)
    try_fill_closet(c.quest.depot)
  end

  local function add_teleports_for_depot(spots)
    local prev
    
    for zzz,place in ipairs(c.quest.depot.places) do
      if place.c == c then

        if not prev or #spots >= 3 then
          prev = table.remove(spots)
        end

        if not prev then
          print("No room for TELEPORTER @ ", c.x, c.y)
          return
        end

print("ADD_TELEPORTER @ ", c.x, c.y, "tag", place.tag)

        local x,y = prev.x, prev.y
        add_thing(p, c, x, y, "teleport_spot", true)
        p.blocks[c.blk_x+x][c.blk_y+y].tag = place.tag
      end
    end
  end

  ---=== battle_in_cell ===---

zprint("BATTLE IN", c.x, c.y)

  local spots, free_space = find_free_spots() --FIXME: move out of here
  rand_shuffle(spots)
  c.free_spots = spots

  if c.quest.depot then
    add_teleports_for_depot(c.free_spots)
  end

  if free_space < 2 then return end
  free_space = free_space * 1.5 / (BW * BH)

  c.mon_set = { easy={}, medium={}, hard={} }

  for zzz,skill in ipairs(SKILLS) do
  
    SK = skill

    T = c.toughness * (free_space ^ 0.7) * TOUGH_FACTOR[SK]
    T = T + p.models[SK].toughness
    U = 0

    fill_closets()
    fill_cages()

    create_monsters(space)

    -- left over toughness gets compounded (but never decreased)
    p.models[SK].toughness = math.max(0, T + U)

    local quest = (c.along == #c.quest.path) and c.quest

zprint("SIMULATE in CELL", c.x, c.y, SK)

    simulate_battle(p, p.models[SK], c.mon_set[SK], quest)

    distribute_pickups(p, c, p.models[SK])
  end
end

function backtrack_to_cell(p, c)

  local function surprise_me(surp)
    for zzz,place in ipairs(surp.places) do
      if c == place.c then
        for zzz,SK in ipairs(SKILLS) do

          simulate_battle(p, p.models[SK], place.mon_set[SK]) 

          -- FIXME!!! (a) put stuff in closet (b) don't be_nice_to_player
          distribute_pickups(p, c, p.models[SK])
        end
      end
    end
  end

  if c.quest.closet then
    surprise_me(c.quest.closet)
  end

  if c.quest.depot then
    surprise_me(c.quest.depot)
  end
end


function battle_in_quest(p, Q)
  for zzz,c in ipairs(Q.path) do
    if c.toughness then
      battle_in_cell(p, c)
    end
  end

  for idx = #Q.path,1,-1 do
    local c = Q.path[idx]
    if c.toughness then
      backtrack_to_cell(p, Q.path[idx])
      c.toughness = nil
    end
  end
end

function battle_through_level(p)

  -- step 1: decide monsters, simulate battles, decide health/ammo

  for zzz,Q in ipairs(p.quests) do
    battle_in_quest(p, Q)
    for yyy,R in ipairs(Q.children) do
      battle_in_quest(p, R)
    end
  end

  -- step 2: place monsters and health/ammo into level

  for zzz,Q in ipairs(p.quests) do
    place_quest_stuff(p, Q)
    for yyy,R in ipairs(Q.children) do
      place_quest_stuff(p, R)
    end
  end
end

