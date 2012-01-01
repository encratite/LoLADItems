def damageReductionFactor(resistance)
  return 100.0 / (100.0 + resistance)
end

def getDPS(description, attackDamage, attackSpeed, criticalStrike, infinityEdge = false, lastWhisper = false, witsEnd = false, swordOfTheDivine = false, blackCleaver = false)
  level = 14

  #Caitlyn stats
  #baseAttackDamage = 40
  #attackDamagePerLevel = 3
  #baseAttackSpeed = 0.668
  #attackSpeedPerLevel = 0.03

  baseAttackDamage = 51.7
  attackDamagePerLevel = 3.5
  baseAttackSpeed = 0.694
  attackSpeedPerLevel = 0.03

  #Vayne stats
  baseArmor = 9.3
  armorPerLevel = 3.4
  baseMagicResistance = 30
  magicResistancePerLevel = 0

  runeArmor = 13
  masteryArmor = 3

  itemArmor = 0

  targetArmor = baseArmor + level * armorPerLevel + runeArmor + masteryArmor + itemArmor
  targetMagicResistance = baseMagicResistance + level * magicResistancePerLevel

  masteryAttackDamage = 3
  runeAttackDamage = 6.8
  attackDamage += baseAttackDamage + level * attackDamagePerLevel + masteryAttackDamage + runeAttackDamage

  masteryAttackSpeed = 0.06
  itemAttackSpeed = 0.2
  attackSpeed += level * attackSpeedPerLevel + masteryAttackSpeed + itemAttackSpeed

  masteryCriticalStrike = 0.04
  criticalStrike += masteryCriticalStrike
  criticalStrike = [criticalStrike, 1.0].min

  masteryCriticalStrikeDamage = 0.1
  criticalStrikeDamage = 2.0 + masteryCriticalStrikeDamage
  if infinityEdge
    criticalStrikeDamage += 0.5
  end

  masteryArmorPenetration = 6
  runeArmorPenetration = 15
  armorPenetration = masteryArmorPenetration + runeArmorPenetration

  masteryArmorPenetrationPercentage = 0.1
  armorPenetrationPercentage = 0.0
  if lastWhisper
    armorPenetrationPercentage += 0.4
  end

  if swordOfTheDivine
    armorPenetration += 30
  end

  if blackCleaver
    armorPenetration += 1 * 15
  end

  effectiveArmor = [targetArmor * (1 - armorPenetrationPercentage) * (1 - masteryArmorPenetrationPercentage) - armorPenetration, 0].max
  physicalDamageFactor = damageReductionFactor(effectiveArmor)

  magicalDamage = 0
  if witsEnd
    magicalDamage += 42
  end

  if swordOfTheDivine
    magicalDamage += 100 / 4
  end

  magicalDamageFactor = damageReductionFactor(targetMagicResistance)

  attacksPerSecond = [baseAttackSpeed * (1 + attackSpeed), 2.5].min
  #puts attackSpeed

  damagePerSecond = attacksPerSecond * (attackDamage * (1 + criticalStrike * (criticalStrikeDamage - 1)) * physicalDamageFactor + magicalDamage * magicalDamageFactor)

  printf("%s: %.1f dps\n", description, damagePerSecond)
end

#getDPS('IE, PD, PD, PD', 80, 0.2 + 3 * 0.55, 0.25 + 3 * 0.3, true)
#getDPS('IE, PD, PD, BT', 80 + 100, 0.2 + 2 * 0.55, 0.25 + 2 * 0.3, true)
#getDPS('IE, PD, PD, LW', 80 + 40, 0.2 + 2 * 0.55, 0.25 + 2 * 0.3, true, true)
#getDPS('BT, PD, PD, LW', 100 + 40, 0.2 + 2 * 0.55, 2 * 0.3, false, true)
#getDPS('IE, BT, BT, PD', 80 + 2 * 100, 0.2 + 0.55, 0.25 + 0.3, true)
#getDPS('IE, PD, LW, BT', 80 + 40 + 100, 0.2 + 2 * 0.55, 0.25 + 2 * 0.3, true, true)
#getDPS('BT, BT, BT, BT', 100 + 100 + 100 + 100, 0.2, 0)
#getDPS('IE, PD, PD', 80, 0.2 + 2 * 0.55, 0.25 + 2 * 0.3, true)
#getDPS('IE, PD, LW', 80 + 40, 0.2 + 0.55, 0.25 + 0.3, true, true)
#getDPS('IE, PD, BT', 80 + 100, 0.2 + 0.55, 0.25 + 0.3, true)

#getDPS('DB, BT, PD', 10 + 100, 0.2 + 0.55, 0.3)
#getDPS('DB, BT, SotD, PA', 10 + 100 + 25, 0.2 + 0.6, 0, false, false, false, true)
#getDPS('DB, BT, SotD', 10 + 100, 0.2 + 0.6, 0, false, false, false, true)

#3000
#getDPS('BT', 100, 0.2, 0)
#3000 + 420 = 3420
#getDPS('BT, D', 100, 0.2 + 0.15, 0)
#2290
#getDPS('LW', 40, 0.2, 0, false, true)
#2290 + 1195 = 3485
#getDPS('LW, Z',  40, 0.2 + 0.2, 0.1, false, true)
#475 + 4070
#getDPS('DB, TF', 10 + 30, 0.2 + 0.3, 0.15)
#475 + 3000 + 1195
#getDPS('DB, BT, Z', 10 + 100, 0.2 + 0.2, 0.1)

#getDPS("Wit's End", 0, 0.2 + 0.4, 0, false, false, true)
#getDPS("DB, BF", 10 + 45, 0.2, 0)


getDPS("Doran's Blade, fully charged Bloodthirster, Phantom Dancers", 10 + 100, 0.2 + 0.55, 0.3)
getDPS("Doran's Blade, fully charged Bloodthirster, Black Cleaver (1 stack)", 10 + 100 + 55, 0.2 + 0.3, 0, false, false, false, false, true)
getDPS("Doran's Blade, Berzerker's Greaves, Infinity Edge, Phantom Dancers", 10 + 80, 0.2 + 0.55, 0.25 + 0.3, true)
getDPS("Doran's Blade, Berzerker's Greaves, Infinity Edge, Black Cleaver (1 stack)", 10 + 80 + 55, 0.2 + 0.3, 0.25, true, false, false, false, true)
#2865 + 2290 + 475
getDPS("Doran's Blade, Black Cleaver (1 stack), Last Whisper", 10 + 55 + 40, 0.2 + 0.3, 0, false, true)
#3000 + 2845
getDPS("Doran's Blade, fully charged Bloodthirster, Phantom Dancers", 10 + 100, 0.2 + 0.55, 0.3)
