require_relative 'Item'

def damageReductionFactor(resistance)
  return 100.0 / (100.0 + resistance)
end

def analyse(tankMode, level, items)
  vayneMode = true
  fullVayneMode = false
  dravenMode = false
  spinningAxesMode = false

  if vayneMode
    baseAttackDamage = 50
    attackDamagePerLevel = 3.25
    baseAttackSpeed = 0.658
    attackSpeedPerLevel = 0.031
  elsif dravenMode
    baseAttackDamage = 46.5
    attackDamagePerLevel = 3.5
    baseAttackSpeed = 0.679
    attackSpeedPerLevel = 0.026
  end

  if !tankMode
    #Caitlyn stats
    health = 390 + 30 + (80 + 6) * level
    baseArmor = 13
    armorPerLevel = 3.5
    baseMagicResistance = 30
    magicResistancePerLevel = 0
    runeArmor = 13
    masteryArmor = 5
    masteryMagicResistance = 13
    itemArmor = 0
    itemMagicResistance = 0
  else
    #Xin Zhao stats
    health = 445 + 30 + (87 + 6) * level + 1000
    baseArmor = 16.2
    armorPerLevel = 3.7
    baseMagicResistance = 30
    magicResistancePerLevel = 1.25
    runeArmor = 9 * 1.41
    masteryArmor = 5 + 1
    masteryMagicResistance = 5 + 1
    itemArmor = 30 + 45
    itemMagicResistance = 25
  end

  targetArmor = baseArmor + level * armorPerLevel + runeArmor + masteryArmor + itemArmor
  targetMagicResistance = baseMagicResistance + level * magicResistancePerLevel + masteryMagicResistance + itemMagicResistance

  masteryAttackDamage = 3 + 0.17 * 3 * level
  runeAttackDamage = 6.8

  bonusAttackDamage = masteryAttackDamage + runeAttackDamage

  attackDamage = baseAttackDamage + level * attackDamagePerLevel
  masteryAttackSpeed = 0.04
  attackSpeed = level * attackSpeedPerLevel + masteryAttackSpeed
  criticalStrike = 0

  masteryCriticalStrikeDamage = 0.05
  criticalStrikeDamage = 2.0 + masteryCriticalStrikeDamage

  masteryArmorPenetration = 5
  runeArmorPenetration = 12
  armorPenetration = masteryArmorPenetration + runeArmorPenetration

  masteryArmorPenetrationPercentage = 0.08

  magicalDamage = 0

  uniqueStats = []

  descriptions = []

  gold = 0

  armorPenetrationPercentages = [masteryArmorPenetrationPercentage]

  statikkShiv = false
  bladeOfTheRuinedKing = false

  items.each do |item|
    gold += item.gold
    item.stats.each do |stats|
      if stats.statikkShiv
        statikkShiv = true
      end
      if stats.bladeOfTheRuinedKing
        bladeOfTheRuinedKing = true
      end
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
      if stats.percentageArmorPenetration > 0
        armorPenetrationPercentages << stats.percentageArmorPenetration
      end
      magicalDamage += stats.magicalDamage
    end
    descriptions << item.description
  end

  if statikkShiv
    magicalDamage += (100 * (1 + criticalStrike)) / 4.0
  end

  attackDamage += bonusAttackDamage

  if fullVayneMode
    if level >= 16
      attackDamage += 55
    elsif level >= 11
      attackDamage += 40
    elsif level >= 6
      attackDamage += 25
    end
  end

  description = descriptions.join(', ')

  criticalStrike = [criticalStrike, 1.0].min

  effectiveArmor = targetArmor
  armorPenetrationPercentages.each do |penetrationPercentage|
    effectiveArmor *= 1 - penetrationPercentage
  end

  effectiveArmor = [effectiveArmor - armorPenetration, 0].max
  physicalDamageFactor = damageReductionFactor(effectiveArmor)

  magicalDamageFactor = damageReductionFactor(targetMagicResistance)

  attacksPerSecond = [baseAttackSpeed * (1 + attackSpeed), 2.5].min

  singleShotDamage = (attackDamage * (1 + criticalStrike * (criticalStrikeDamage - 1)) * physicalDamageFactor + magicalDamage * magicalDamageFactor).to_i

  if fullVayneMode
    if level >= 13
      singleShotDamage += (60 + 0.08 * health) / 3
    elsif level >= 12
      singleShotDamage += (50 + 0.07 * health) / 3
    elsif level >= 10
      singleShotDamage += (40 + 0.06 * health) / 3
    elsif level >= 8
      singleShotDamage += (30 + 0.05 * health) / 3
    elsif level >= 3
      singleShotDamage += (20 + 0.04 * health) / 3
    end
  end

  if dravenMode
    singleShotDamage += criticalStrike * (30 + 4 * level)
  end

  if spinningAxesMode
    singleShotDamage += 0.85 * attackDamage
  end

  if bladeOfTheRuinedKing
    singleShotDamage += 0.5 * 0.05 * health
  end

  singleShotDamage = singleShotDamage.round(1)

  damagePerSecond = attacksPerSecond * singleShotDamage

  row = [
    description,
    gold.to_s,
    singleShotDamage.to_s,
    bonusAttackDamage.to_i.to_s,
    sprintf('%.1f', damagePerSecond),
    sprintf('%.4f', damagePerSecond / gold),
  ]
  return row
end
