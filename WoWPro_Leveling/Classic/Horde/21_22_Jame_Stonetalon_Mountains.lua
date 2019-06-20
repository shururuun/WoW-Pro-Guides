-- WoWPro Guides by "The WoW-Pro Community" are licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
-- Permissions beyond the scope of this license may be available at http://www.wow-pro.com/License.

local guide = WoWPro:RegisterGuide('Classic-21-22-Jame-StonetalonMountains', 'Leveling', 'Stonetalon Mountains', 'Jame', 'Horde', 1)
WoWPro:GuideName(guide, 'Stonetalon Mountains')
WoWPro:GuideLevels(guide, 21, 22, 21)
WoWPro:GuideNextGuide(guide, 'Classic-22-24-Jame-HillsbradFoothills')
WoWPro:GuideSteps(guide, function() return [[
h Orgrimmar|QID|6284|M|54.1,68.5|Z|Orgrimmar|
f Orgrimmar|QID|1492|M|45.3,63.9|Z|Orgrimmar|N|If you don't have this flight path get it.|
A Call of Water|QID|1528|C|Shaman|M|38.06,37.38|Z|Orgrimmar|N|From Searn Firewarder.|

R The Barrens|QID|1492|M|34.2,42.2|Z|The Barrens|N|If you've been to The Barrens, fly to Ratchet and skip the next few steps.|
R The Crossroads|QID|1492|M|52,30.6|Z|The Barrens|
f The Crossroads|QID|1492|M|51.5,30.3|Z|The Barrens|

R Ratchet|QID|1483|M|62,37|Z|The Barrens|
f Ratchet|QID|1492|M|63.1,37.2|Z|The Barrens|
A Ziz Fizziks|QID|1483|M|63.0,37.2|Z|The Barrens|

T Call of Water|QID|1528|C|Shaman|M|65.87,43.75|Z|The Barrens|N|To Islen Waterseer.|
A Call of Water|QID|1530|C|Shaman|M|65.87,43.75|Z|The Barrens|N|From Islen Waterseer.|
f Camp Taurajo|QID|1530|C|Shaman|M|44.46,59.10|Z|The Barrens|

T Call of Water|QID|1530|C|Shaman|M|43.46,77.41|Z|The Barrens|N|To Brine.|
A Call of Water|QID|1535|C|Shaman|M|43.46,77.41|Z|The Barrens|N|From Brine.|
C Call of Water|QID|1535|C|Shaman|M|44.08,76.69|Z|The Barrens|QO|1|N|Filled Brown Waterskin:1/1|
T Call of Water|QID|1535|C|Shaman|M|43.46,77.41|Z|The Barrens|N|From Brine.|
A Call of Water|QID|1536|C|Shaman|M|43.46,77.41|Z|The Barrens|N|From Brine.|
f The Crossroads|QID|1492|C|Shaman|Z|The Barrens|M|51.5,30.3|

A Goblin Invaders|QID|1062|M|35.2,27.8|

R Stonetalon Mountains|QID|6284|M|34.1,27.6|Z|The Barrens|
A Arachnophobia|QID|6284|M|59.1,75.8|
K Kill Besseleth for Besseleth's Fang|QID|6284|M|52.6,71.7|QO|Besseleth's Fang: 1/1|N|Ahead of you there will be a little valley with spiders and spider eggs. Clear your way into it until you see a big orange spider called "Besseleth". Kill it and loot its fang.|
C Arachnophobia|QID|6284|M|54.6,71.9|
T Arachnophobia|QID|6284|M|47.2,61.2|
f Sun Rock Retreat|QID|1483|M|45.2,59.8|
A Boulderslide Ravine|QID|6421|M|47.2,64.2|

T Ziz Fizziks|QID|1483|M|59.0,62.6|
A Super Reaper 6000|QID|1093|M|59.0,62.6|
K Venture Co. Loggers|QID|1062|M|65,50|QO|Venture Co. Logger slain: 15/15|
C Goblin Invaders|QID|1062|
K Venture Co. Operators for Blueprints|QID|1093|M|62.5,53.3|QO|Super Reaper 6000 Blueprints: 1/1|
C Super Reaper 6000|QID|1093|M|62.6,53.8|

T Super Reaper 6000|QID|1093|M|59.0,62.6|
A Further Instructions (Part 1)|QID|1094|M|59.0,62.6|

N Collect: Resonite Crystals|QID|6421|M|61.5,93.2|QO|Resonite Crystal: 10/10|N|Enter northernmost cave.|
N Explore cave at Boulderslide Ravine|QID|6421|M|58.9,90.3|QO|Investigate Cave in Boulderslide Ravine|N|Go deeper into the cave until you get complete message.|
C Boulderslide Ravine|QID|6421|M|61.3,92.4|

T Goblin Invaders|QID|1062|M|35.2,27.8|

R The Barrens|QID|1094|M|34.1,27.6|N|Ride to the Stonetalon Mountains and Barrens border, enroute to The Crossroads.|
R The Crossroads|QID|1094|M|52,30.6|Z|The Barrens|

F Ratchet|QID|1094|M|51.5,30.3|Z|The Barrens|
T Further Instructions (Part 1)|QID|1094|M|63.0,37.2|

F Sun Rock Retreat|QID|6421|M|63.1,37.2|Z|The Barrens|
T Boulderslide Ravine|QID|6421|M|47.2,64.2|
]]
end)
