require 'nil/console'

require_relative 'analyse'
require_relative 'Item'

doransBlade = Item.new("Doran's Blade", 475, ItemStats.new(attackDamage: 10))
berserkersGreaves = Item.new("Berserker's Greaves", 920, ItemStats.new(attackSpeed: 0.2))
bloodthirster = Item.new("Bloodthirster", 3000, ItemStats.new(attackDamage: 100))
zeal = Item.new("Zeal", 1195, ItemStats.new(attackSpeed: 0.2, criticalStrike: 0.1))
phantomDancer = Item.new("Phantom Dancer", 2845, ItemStats.new(attackSpeed: 0.55, criticalStrike: 0.3))
infinityEdge = Item.new("Infinity Edge", 3830, [ItemStats.new(attackDamage: 80, criticalStrike: 0.25), UniqueItemStats.new(criticalStrikeBonus: 0.5)])
blackCleaver = Item.new("Black Cleaver (1 stack)", 2865, [ItemStats.new(attackDamage: 55, attackSpeed: 0.3), UniqueItemStats.new(flatArmorPenetration: 15)])
lastWhisper = Item.new("Last Whisper", 2290, [ItemStats.new(attackDamage: 40), UniqueItemStats.new(percentageArmorPenetration: 0.4)])
witsEnd = Item.new("Wit's End", 2000, UniqueItemStats.new(magicalDamage: 42))
swordOfTheDivine = Item.new("Sword of the Divine (active)", 1970, [ItemStats.new(attackSpeed: 0.6), UniqueItemStats.new(magicalDamage: 100 / 4, flatArmorPenetration: 30)])

rows = [[
  'Description',
  'Gold',
  'Single shot damage',
  'Damage per second',
]]

level = 12
rows << analyse(level, [doransBlade, berserkersGreaves, bloodthirster])
rows << analyse(level, [doransBlade, berserkersGreaves, infinityEdge])

level = 15
rows << analyse(level, [doransBlade, berserkersGreaves, bloodthirster, phantomDancer])
rows << analyse(level, [doransBlade, berserkersGreaves, bloodthirster, blackCleaver])
rows << analyse(level, [doransBlade, berserkersGreaves, infinityEdge, phantomDancer])
rows << analyse(level, [doransBlade, berserkersGreaves, infinityEdge, blackCleaver])
rows << analyse(level, [doransBlade, berserkersGreaves, bloodthirster, infinityEdge])

Nil.printTable(rows)
