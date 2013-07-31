require_relative 'Item'

def damageReductionFactor(resistance)
  return 100.0 / (100.0 + resistance)
end

def analyse(tankMode, level, items)
  vayneMode = false
  fullVayneMode = false
  dravenMode = false
  spinningAxesMode = false
  threshMode = false
  masterYiMode = true

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
  elsif threshMode
    baseAttackDamage = 46
    attackDamagePerLevel = 2.2
    baseAttackSpeed = 0.625
    attackSpeedPerLevel = 0.01
  elsif masterYiMode
    baseAttackDamage = 55.1
    attackDamagePerLevel = 3.1
    baseAttackSpeed = 0.679
    attackSpeedPerLevel = 0.0275
  end

  if !tankMode
    #Caitlyn stats
    health = 390 + 30 + (80 + 6) * level
    baseArmor = 13
    armorPerLevel = 3.5
    baseMagicResistance = 30
    magicResistancePerLevel = 0
    runeArmor = 13
    runeMagicResistance = 9 * 1.34
    masteryArmor = 5
    masteryMagicResistance = 0
    itemHealth = 0
    itemArmor = 0
    itemMagicResistance = 0
  else
    #Xin Zhao stats
    health = 445 + 30 + (87 + 6) * level
    baseArmor = 16.2
    armorPerLevel = 3.7
    baseMagicResistance = 30
    magicResistancePerLevel = 1.25
    runeArmor = 9 * 1.41
    runeMagicResistance = 9 * 0.15 * level
    masteryArmor = 5 + 1
    masteryMagicResistance = 5 + 1
    itemHealth = 450 + 1000
    itemArmor = 30 + 45
    itemMagicResistance = 25
  end

  health += itemHealth

  targetArmor = baseArmor + level * armorPerLevel + runeArmor + masteryArmor + itemArmor
  targetMagicResistance = baseMagicResistance + level * magicResistancePerLevel + runeMagicResistance + masteryMagicResistance + itemMagicResistance

  if threshMode
    masteryAttackDamage = 0
    runeAttackDamage = 0
  else
    masteryAttackDamage = 3 + 0.17 * 3 * level
    runeAttackDamage = 6.8
  end

  bonusAttackDamage = masteryAttackDamage + runeAttackDamage

  attackDamage = baseAttackDamage + level * attackDamagePerLevel
  masteryAttackSpeed = 0.04
  attackSpeed = level * attackSpeedPerLevel + masteryAttackSpeed
  criticalStrike = 0

  masteryCriticalStrikeDamage = 0.05
  criticalStrikeDamage = 2.0 + masteryCriticalStrikeDamage

  if threshMode
    masteryArmorPenetration = 0
    runeArmorPenetration = 0
  else
    masteryArmorPenetration = 5
    runeArmorPenetration = 12
  end
  armorPenetration = masteryArmorPenetration + runeArmorPenetration

  masteryArmorPenetrationPercentage = 0.08

  magicalDamage = 0

  uniqueStats = []

  descriptions = []

  gold = 0

  armorPenetrationPercentages = [masteryArmorPenetrationPercentage]

  statikkShiv = false
  bladeOfTheRuinedKing = false
  malady = false

  items.each do |item|
    gold += item.gold
    item.stats.each do |stats|
      if stats.statikkShiv
        statikkShiv = true
      end
      if stats.bladeOfTheRuinedKing
        bladeOfTheRuinedKing = true
      end
      if stats.malady
        malady = true
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
    shivDamage = (100 * (1 + criticalStrike)) / 10.0
    magicalDamage += shivDamage
  end

  if threshMode
    souls = 70
    deathSentence = souls + 2.0 * attackDamage / 3
    magicalDamage += deathSentence
  end

  if malady
    abilityPower = 25
    if threshMode
      abilityPower += 65
    end
    magicalDamage += 15 + 0.1 * abilityPower
    stacks = 1
    targetMagicResistance -= stacks * 4
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

  if masterYiMode
    if level >= 16
      attackSpeed += 0.8
    elsif level >= 11
      attackSpeed += 0.55
    elsif level >= 6
      attackSpeed += 0.3
    end

    if level >= 13
      attackDamage *= 1.15
    elsif level >= 12
      attackDamage *= 1.13
    elsif level >= 10
      attackDamage *= 1.11
    elsif level >= 8
      attackDamage *= 1.09
    elsif level >= 2
      attackDamage *= 1.07
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

  physicalDamage = attackDamage * (1 + criticalStrike * (criticalStrikeDamage - 1))

  if dravenMode
    physicalDamage += criticalStrike * (30 + 4 * level)
  end

  if spinningAxesMode
    physicalDamage += 0.85 * attackDamage
  end

  if bladeOfTheRuinedKing
    healthRatio = 0.5
    physicalDamage += healthRatio * 0.05 * health
  end

  singleShotDamage = physicalDamage * physicalDamageFactor + magicalDamage * magicalDamageFactor

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

  if masterYiMode
    if level >= 13
      singleShotDamage += 30 + 0.2 * attackDamage
    elsif level >= 12
      singleShotDamage += 30 + 0.175 * attackDamage
    elsif level >= 10
      singleShotDamage += 30 + 0.15 * attackDamage
    elsif level >= 8
      singleShotDamage += 30 + 0.125 * attackDamage
    elsif level >= 2
      singleShotDamage += 30 + 0.1 * attackDamage
    end
  end

  singleShotDamage = singleShotDamage.round(1)

  damagePerSecond = attacksPerSecond * singleShotDamage

  row = [
    description,
    gold.to_s,
    singleShotDamage.to_s,
    bonusAttackDamage.to_i.to_s,
    sprintf('%.1f', damagePerSecond),
    sprintf('%.4f', singleShotDamage / gold),
    sprintf('%.4f', damagePerSecond / gold),
  ]
  return row
end
