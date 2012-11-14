require 'nil/console'

require_relative 'analyse'
require_relative 'Item'

class ItemCombinator
  DoransBlade = Item.new("Doran's Blade", 475, ItemStats.new(attackDamage: 10))
  BerserkersGreaves = Item.new("Berserker's Greaves", 920, ItemStats.new(attackSpeed: 0.2))
  Bloodthirster = Item.new("Bloodthirster", 3000, ItemStats.new(attackDamage: 100))
  Zeal = Item.new("Zeal", 1195, ItemStats.new(attackSpeed: 0.2, criticalStrike: 0.1))
  PhantomDancer = Item.new("Phantom Dancer", 2845, ItemStats.new(attackSpeed: 0.55, criticalStrike: 0.3))
  InfinityEdge = Item.new("Infinity Edge", 3830, [ItemStats.new(attackDamage: 80, criticalStrike: 0.25), UniqueItemStats.new(criticalStrikeBonus: 0.5)])
  BlackCleaver = Item.new("Black Cleaver (no stacks)", 2865, ItemStats.new(attackDamage: 55, attackSpeed: 0.3))
  FullyStackedBlackCleaver = Item.new("Black Cleaver (3 stacks)", 2865, [ItemStats.new(attackDamage: 55, attackSpeed: 0.3), UniqueItemStats.new(flatArmorPenetration: 3 * 15)])
  LastWhisper = Item.new("Last Whisper", 2290, [ItemStats.new(attackDamage: 40), UniqueItemStats.new(percentageArmorPenetration: 0.4)])
  WitsEnd = Item.new("Wit's End", 2000, UniqueItemStats.new(magicalDamage: 42))
  SwordOfTheDivine = Item.new("Sword of the Divine (without active)", 1970, [ItemStats.new(attackSpeed: 0.6), UniqueItemStats.new(magicalDamage: 100 / 4)])
  SwordOfTheDivineWithActive = Item.new("Sword of the Divine (with active)", 1970, [ItemStats.new(attackSpeed: 0.6), UniqueItemStats.new(magicalDamage: 100 / 4, flatArmorPenetration: 30)])
  ExecutionersCalling = Item.new("Executioner's Calling", 1350, ItemStats.new(criticalStrike: 0.1))

  NonUniqueItems = [Bloodthirster, PhantomDancer]
  UniqueItems = [InfinityEdge, BlackCleaver, FullyStackedBlackCleaver, LastWhisper, WitsEnd, SwordOfTheDivine, SwordOfTheDivineWithActive, ExecutionersCalling, Zeal]
  #UniqueItems = [InfinityEdge, LastWhisper]

  def self.combine(tankMode, level, limit, rows, uniqueItems = UniqueItems, usedCombinations = [], combination = [])
    if combination.size == limit
      stringCheckTargets = [
        'Black Cleaver',
        'Sword of the Divine',
      ]
      stringCheckTargets.each do |string|
        hitCounter = 0
        combination.each do |item|
          if item.description.index(string) != nil
            hitCounter += 1
          end
        end
        if hitCounter > 1
          return
        end
      end
      combinationCheck = combination.sort do |x, y|
        x.description <=> y.description
      end
      if usedCombinations.include?(combinationCheck)
        return
      end
      usedCombinations.push(combinationCheck)
      items = []
      if level <= 15
        items << DoransBlade
      end
      if level <= 12
        items << DoransBlade
      end
      items << BerserkersGreaves
      items += combination
      row = analyse(tankMode, level, items)
      rows.push(row)
    else
      uniqueItems.each do |item|
        currentCombination = combination + [item]
        currentUniqueItems = uniqueItems.dup
        currentUniqueItems.delete(item)
        combine(tankMode, level, limit, rows, currentUniqueItems, usedCombinations, currentCombination)
      end
      NonUniqueItems.each do |item|
        currentCombination = combination + [item]
        combine(tankMode, level, limit, rows, uniqueItems, usedCombinations, currentCombination)
      end
    end
  end
end

def processMode(description, tankMode)
  levels = [12, 15, 18, 18]

  print "Target: #{description}\n\n"

  itemCount = 1
  levels.each do |level|
    print "Number of big AD items at level #{level}: #{itemCount}\n\n"
    rows = [
      [
        'Description',
        'Gold',
        'Single shot damage',
        'Bonus attack damage',
        'Damage per second',
      ]
    ]
    ItemCombinator.combine(tankMode, level, itemCount, rows)
    itemCount += 1
    Nil.printTable(rows)
    puts ''
  end
end

processMode("Caitlyn with flat armor seals and 3/3 armor mastery", false)
processMode("Gangplank with Wriggle's, Atma's Impaler, flat armor seals and 3/3 armor mastery", true)
