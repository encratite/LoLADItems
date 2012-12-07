require 'nil/console'

require_relative 'analyse'
require_relative 'Item'

class ItemCombinator
  DoransBlade = Item.new("Doran's Blade", 475, ItemStats.new(attackDamage: 10))
  BerserkersGreaves = Item.new("Berserker's Greaves", 900, ItemStats.new(attackSpeed: 0.2))
  Bloodthirster = Item.new("Bloodthirster", 3000, ItemStats.new(attackDamage: 100))
  Zeal = Item.new("Zeal", 1175, ItemStats.new(attackSpeed: 0.18, criticalStrike: 0.1))
  PhantomDancer = Item.new("Phantom Dancer", 2800, ItemStats.new(attackSpeed: 0.5, criticalStrike: 0.3))
  InfinityEdge = Item.new("Infinity Edge", 3800, [ItemStats.new(attackDamage: 70, criticalStrike: 0.25), UniqueItemStats.new(criticalStrikeBonus: 0.5)])
  BlackCleaver = Item.new("Black Cleaver (no stacks)", 3000, ItemStats.new(attackDamage: 50, flatArmorPenetration: 0.15))
  BlackCleaverStacks = Item.new("Black Cleaver (four stacks)", 3000, ItemStats.new(attackDamage: 50, flatArmorPenetration: 15, percentageArmorPenetration: 0.3))
  LastWhisper = Item.new("Last Whisper", 2135, [ItemStats.new(attackDamage: 40), UniqueItemStats.new(percentageArmorPenetration: 0.35)])
  WitsEnd = Item.new("Wit's End", 2200, [ItemStats.new(attackSpeed: 0.4), UniqueItemStats.new(magicalDamage: 42)])
  Zephyr = Item.new("Zephyr", 2850, [ItemStats.new(attackDamage: 20, attackSpeed: 0.5)])
  StatikkShiv = Item.new("Statikk Shiv", 2500, [ItemStats.new(attackSpeed: 0.4, criticalStrike: 0.2), UniqueItemStats.new(statikkShiv: true)])

  NonUniqueItems = [Bloodthirster, PhantomDancer]
  UniqueItems = [InfinityEdge, LastWhisper, BlackCleaver, BlackCleaverStacks, Zephyr, StatikkShiv]
  #UniqueItems = [InfinityEdge, LastWhisper]

  def self.combine(tankMode, level, limit, rows, uniqueItems = UniqueItems, usedCombinations = [], combination = [])
    if combination.size == limit
      stringCheckTargets = [
        'Black Cleaver',
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
    rows = []
    ItemCombinator.combine(tankMode, level, itemCount, rows)
    rows.sort! do |x, y|
      y[4] <=> x[4]
    end
    rows = [[
      'Description',
      'Gold',
      'Single shot damage',
      'Bonus attack damage',
      'Damage per second',
    ]] + rows
    itemCount += 1
    Nil.printTable(rows)
    puts ''
  end
end

processMode("Caitlyn with flat armor seals and 3/3 armor mastery", false)
processMode("Gangplank with Wriggle's, Atma's Impaler, flat armor seals and 3/3 armor mastery", true)
