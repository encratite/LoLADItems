require 'nil/symbol'

class Item
  attr_reader :description, :gold, :stats

  def initialize(description, gold, stats)
    @description = description
    @gold = gold
    if stats.class != Array
      stats = [stats]
    end
    @stats = stats
  end
end

class ItemStats
  include SymbolicAssignment

  Members = [
    :attackDamage,
    :attackSpeed,
    :criticalStrike,
    :criticalStrikeBonus,
    :flatArmorPenetration,
    :percentageArmorPenetration,
    :magicalDamage
  ]

  attr_reader *Members

  attr_reader :unique

  def initialize(statMap)
    Members.each do |symbol|
      setMember(symbol, 0)
    end
    statMap.each do |symbol, value|
      if !Members.include?(symbol)
        raise "Invalid symbol: #{symbol}"
      end
      setMember(symbol, value)
    end
    @unique = false
  end
end

class UniqueItemStats < ItemStats
  def initialize(statMap)
    super
    @unique = true
  end
end
