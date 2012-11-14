require_relative 'Item'

def damageReductionFactor(resistance)
  return 100.0 / (100.0 + resistance)
end

def analyse(tankMode, level, items)
  #Vayne stats
  baseAttackDamage = 50
  attackDamagePerLevel = 3.25
  baseAttackSpeed = 0.658
  attackSpeedPerLevel = 0.031

  if !tankMode
    #Caitlyn stats
    baseArmor = 13
    armorPerLevel = 3.5
    baseMagicResistance = 30
    magicResistancePerLevel = 0
    runeArmor = 13
    masteryArmor = 6
    itemArmor = 0
    itemMagicResistance = 0
  else
    #Gangplank stats
    baseArmor = 16.5
    armorPerLevel = 3.3
    baseMagicResistance = 30
    magicResistancePerLevel = 1.25
    runeArmor = 13
    masteryArmor = 6
    itemArmor = 30 + 45
    itemMagicResistance = 25
  end

  targetArmor = baseArmor + level * armorPerLevel + runeArmor + masteryArmor + itemArmor
  targetMagicResistance = baseMagicResistance + level * magicResistancePerLevel + itemMagicResistance

  masteryAttackDamage = 3
  runeAttackDamage = 6.8

  bonusAttackDamage = masteryAttackDamage + runeAttackDamage

  attackDamage = baseAttackDamage + level * attackDamagePerLevel
  masteryAttackSpeed = 0.06
  attackSpeed = level * attackSpeedPerLevel + masteryAttackSpeed
  masteryCriticalStrike = 0.04
  criticalStrike = masteryCriticalStrike

  masteryCriticalStrikeDamage = 0.1
  criticalStrikeDamage = 2.0 + masteryCriticalStrikeDamage

  masteryArmorPenetration = 6
  runeArmorPenetration = 15
  armorPenetration = masteryArmorPenetration + runeArmorPenetration

  masteryArmorPenetrationPercentage = 0.1
  armorPenetrationPercentage = 0.0

  magicalDamage = 0

  uniqueStats = []

  descriptions = []

  gold = 0

  items.each do |item|
    gold += item.gold
    item.stats.each do |stats|
      if uniqueStats.include?(stats)
        next
      end
      if stats.class == UniqueItemStats
        uniqueStats << stats
      end
      bonusAttackDamage += stats.attackDamage
      attackSpeed += stats.attackSpeed
      criticalStrike += stats.criticalStrike
      criticalStrikeDamage += stats.criticalStrikeBonus
      armorPenetration += stats.flatArmorPenetration
      armorPenetrationPercentage += stats.percentageArmorPenetration
      magicalDamage += stats.magicalDamage
    end
    descriptions << item.description
  end

  attackDamage += bonusAttackDamage

  description = descriptions.join(', ')

  criticalStrike = [criticalStrike, 1.0].min

  effectiveArmor = [targetArmor * (1 - armorPenetrationPercentage) * (1 - masteryArmorPenetrationPercentage) - armorPenetration, 0].max
  physicalDamageFactor = damageReductionFactor(effectiveArmor)

  magicalDamageFactor = damageReductionFactor(targetMagicResistance)

  attacksPerSecond = [baseAttackSpeed * (1 + attackSpeed), 2.5].min

  singleShotDamage = (attackDamage * (1 + criticalStrike * (criticalStrikeDamage - 1)) * physicalDamageFactor + magicalDamage * magicalDamageFactor).to_i
  damagePerSecond = attacksPerSecond * singleShotDamage

  row = [
    description,
    gold.to_s,
    singleShotDamage.to_s,
    bonusAttackDamage.to_i.to_s,
    sprintf('%.1f', damagePerSecond),
  ]
  return row
end
