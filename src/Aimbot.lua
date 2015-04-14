--[[

Made by Nebelwolfi & acecross

Big credit to Dienofail, Klokje for old I'mAiming

Credits to iCreative and Bilbao for packetusage

]]--
if not VIP_USER then return end -- VIP only :/
local version = 0.27 -- REMEMBER: UPDATE .version FILE ASWELL FOR IN-GAME PUSH!
HookPackets()

local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/nebelwolfi/scripts/master/src/Aimbot.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Aimbot.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Aimbot:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTO_UPDATE then
  local ServerData = GetWebResult(UPDATE_HOST, "/nebelwolfi/scripts/master/src/Aimbot.version")
  if ServerData then
    ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
    if ServerVersion then
      if tonumber(version) < ServerVersion then
        AutoupdaterMsg("New version available v"..ServerVersion)
        AutoupdaterMsg("Updating, please don't press F9")
        DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
      else
        AutoupdaterMsg("Loaded the latest version (v"..ServerVersion..")")
      end
    end
  else
    AutoupdaterMsg("Error downloading version info")
  end
end
if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
--[[ SUPPORTED LATER
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
  require "DivinePred" 
  DP = DivinePred()
end ]]

champions2 = {
["Lux"] = {charName = "Lux", skillshots = {
["Light Binding"] =  {name = "LightBinding", spellName = "LuxLightBinding", spellDelay = 250, projectileName = "LuxLightBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
["Lux LightStrike Kugel"] = {name = "LuxLightStrikeKugel", spellName = "LuxLightStrikeKugel", spellDelay = 250, projectileName = "LuxLightstrike_mis.troy", projectileSpeed = 1400, range = 1100, radius = 275, type = "circle", cc = "false", collision = "false", shieldnow = "false"},
}},
["Nidalee"] = {charName = "Nidalee", skillshots = {
["Javelin Toss"] = {name = "JavelinToss", spellName = "JavelinToss", spellDelay = 125, projectileName = "nidalee_javelinToss_mis.troy", projectileSpeed = 1300, range = 1500, radius = 60, type = "line", cc = "true", collision = "true", shieldnow = "true"}
}},
["Kennen"] = {charName = "Kennen", skillshots = {
["Thundering Shuriken"] = {name = "ThunderingShuriken", spellName = "KennenShurikenHurlMissile1", spellDelay = 180, projectileName = "kennen_ts_mis.troy", projectileSpeed = 1700, range = 1050, radius = 50, type = "line", cc = "false", collision = "true", shieldnow = "true"}
}},
["Amumu"] = {charName = "Amumu", skillshots = {
["Bandage Toss"] = {name = "BandageToss", spellName = "BandageToss", spellDelay = 250, projectileName = "Bandage_beam.troy", projectileSpeed = 2000, range = 1100, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"}
}},
["Lee Sin"] = {charName = "LeeSin", skillshots = {
["Sonic Wave"] = {name = "SonicWave", spellName = "BlindMonkQOne", spellDelay = 250, projectileName = "blindMonk_Q_mis_01.troy", projectileSpeed = 1800, range = 1100, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"}
}},
["Morgana"] = {charName = "Morgana", skillshots = {
["Dark Binding Missile"] = {name = "DarkBinding", spellName = "DarkBindingMissile", spellDelay = 250, projectileName = "DarkBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Sejuani"] = {charName = "Sejuani", skillshots = {
["SejuaniR"] = {name = "SejuaniR", spellName = "SejuaniGlacialPrisonCast", spellDelay = 250, projectileName = "Sejuani_R_mis.troy", projectileSpeed = 1600, range = 1200, radius = 110, type="line", cc = "true", collision = "false", shieldnow = "true"},    
}},
["Sona"] = {charName = "Sona", skillshots = {
["Crescendo"] = {name = "Crescendo", spellName = "SonaCrescendo", spellDelay = 240, projectileName = "SonaCrescendo_mis.troy", projectileSpeed = 2400, range = 1000, radius = 160, type = "line", cc = "true", collision = "false", shieldnow = "true"},        
}},
["Gragas"] = {charName = "Gragas", skillshots = {
["Barrel Roll"] = {name = "BarrelRoll", spellName = "GragasBarrelRoll", spellDelay = 250, projectileName = "gragas_barrelroll_mis.troy", projectileSpeed = 1000, range = 1115, radius = 180, type = "circle", cc = "false", collision = "false", shieldnow = "false"},
["Barrel Roll Missile"] = {name = "BarrelRollMissile", spellName = "GragasBarrelRollMissile", spellDelay = 0, projectileName = "gragas_barrelroll_mis.troy", projectileSpeed = 1000, range = 1115, radius = 180, type = "circle", cc = "false", collision = "false", shieldnow = "false"},
}},
["Syndra"] = {charName = "Syndra", skillshots = {
["Q"] = {name = "Q", spellName = "SyndraQ", spellDelay = 250, projectileName = "Syndra_Q_fall.troy", projectileSpeed = 500, range = 825, radius = 175, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
["W"] = {name = "W", spellName = "syndrawcast", spellDelay = 250, projectileName = "Syndra_W_fall.troy", projectileSpeed = 500, range = 950, radius = 200, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
}},
["Malphite"] = {charName = "Malphite", skillshots = {
["UFSlash"] = {name = "UFSlash", spellName = "UFSlash", spellDelay = 0, projectileName = "UnstoppableForce_cas.troy", projectileSpeed = 550, range = 1000, radius = 300, type="circular", cc = "true", collision = "false", shieldnow = "true"},    
}},
["Ezreal"] = {charName = "Ezreal", skillshots = {
["Mystic Shot"]             = {name = "MysticShot",      spellName = "EzrealMysticShot",      spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 2000, range = 1200,  radius = 80,  type = "line", cc = "false", collision = "true", shieldnow = "true"},
["Essence Flux"]            = {name = "EssenceFlux",     spellName = "EzrealEssenceFlux",     spellDelay = 250, projectileName = "Ezreal_essenceflux_mis.troy", projectileSpeed = 1500, range = 1050,  radius = 80,  type = "line", cc = "false", collision = "false", shieldnow = "true"},
["Trueshot Barrage"]        = {name = "TrueshotBarrage", spellName = "EzrealTrueshotBarrage", spellDelay = 1000, projectileName = "Ezreal_TrueShot_mis.troy",    projectileSpeed = 2000, range = 20000, radius = 160, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Ahri"] = {charName = "Ahri", skillshots = {
["Orb of Deception"] = {name = "OrbofDeception", spellName = "AhriOrbofDeception", spellDelay = 250, projectileName = "Ahri_Orb_mis.troy", projectileSpeed = 2500, range = 900, radius = 100, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["Orb of Deception Back"] = {name = "OrbofDeceptionBack", spellName = "AhriOrbofDeceptionherpityderp", spellDelay = 250+360, projectileName = "Ahri_Orb_mis_02.troy", projectileSpeed = 915, range = 900, radius = 100, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["Charm"] = {name = "Charm", spellName = "AhriSeduce", spellDelay = 250, projectileName = "Ahri_Charm_mis.troy", projectileSpeed = 1000, range = 1000, radius = 60, type = "line", cc = "true", collision = "true", shieldnow = "true"}
}},
["Olaf"] = {charName = "Olaf", skillshots = {
["Undertow"] = {name = "Undertow", spellName = "OlafAxeThrow", spellDelay = 250, projectileName = "olaf_axe_mis.troy", projectileSpeed = 1600, range = 1000, radius = 90, type = "line", cc = "true", collision = "false", shieldnow = "true"}
}},
["Leona"] = {charName = "Leona", skillshots = {
["Zenith Blade"] = {name = "LeonaZenithBlade", spellName = "LeonaZenithBlade", spellDelay = 250, projectileName = "Leona_ZenithBlade_mis.troy", projectileSpeed = 2000, range = 950, radius = 110, type = "line", cc = "true", collision = "false", shieldnow = "true"},
["Leona Solar Flare"] = {name = "LeonaSolarFlare", spellName = "LeonaSolarFlare", spellDelay = 250, projectileName = "Leona_SolarFlare_cas.troy", projectileSpeed = 1500, range = 1200, radius = 300, type = "circular", cc = "true", collision = "false", shieldnow = "true"}
}},
["Karthus"] = {charName = "Karthus", skillshots = {
["Lay Waste"] = {name = "LayWaste", spellName = "KarthusLayWasteA", spellDelay = 250, projectileName = "Karthus_Base_Q_Point_red.troy", projectileSpeed = 1750, range = 875, radius = 140, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
}},
["Chogath"] = {charName = "Chogath", skillshots = {
["Rupture"] = {name = "Rupture", spellName = "Rupture", spellDelay = 0, projectileName = "rupture_cas_01_red_team.troy", projectileSpeed = 950, range = 950, radius = 250, type = "circular", cc = "true", collision = "false", shieldnow = "true"}
}},
["Blitzcrank"] = {charName = "Blitzcrank", skillshots = {
["Rocket Grab"] = {name = "RocketGrab", spellName = "RocketGrabMissile", spellDelay = 250, projectileName = "FistGrab_mis.troy", projectileSpeed = 1800, range = 1050, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Anivia"] = {charName = "Anivia", skillshots = {
["Flash Frost"] = {name = "FlashFrost", spellName = "FlashFrostSpell", spellDelay = 250, projectileName = "cryo_FlashFrost_mis.troy", projectileSpeed = 850, range = 1100, radius = 110, type = "line", cc = "true", collision = "false", shieldnow = "true"}
}},
["Zyra"] = {charName = "Zyra", skillshots = {
["Grasping Roots"] = {name = "GraspingRoots", spellName = "ZyraGraspingRoots", spellDelay = 250, projectileName = "Zyra_E_sequence_impact.troy", projectileSpeed = 1150, range = 1150, radius = 70,  type = "line", cc = "true", collision = "false", shieldnow = "true"},
["Zyra Passive Death"] = {name = "ZyraPassive", spellName = "zyrapassivedeathmanager", spellDelay = 500, projectileName = "zyra_passive_plant_mis.troy", projectileSpeed = 2000, range = 1474, radius = 60,  type = "line", cc = "false", collision = "false", shieldnow = "true"},
["Deadly Bloom"] = {name = "DeadlyBloom", spellName = "ZyraQFissure", spellDelay = 1000, projectileName = "Zyra_Q_cas.troy", projectileSpeed = 0, range = 800, radius = 250, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
}},
["Nautilus"] = {charName = "Nautilus", skillshots = {
["Dredge Line"] = {name = "DredgeLine", spellName = "NautilusAnchorDrag", spellDelay = 250, projectileName = "Nautilus_Q_mis.troy", projectileSpeed = 2000, range = 1080, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Caitlyn"] = {charName = "Caitlyn", skillshots = {
["Piltover Peacemaker"] = {name = "PiltoverPeacemaker", spellName = "CaitlynPiltoverPeacemaker", spellDelay = 625, projectileName = "caitlyn_Q_mis.troy", projectileSpeed = 2200, range = 1300, radius = 90, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["Caitlyn Entrapment"] = {name = "CaitlynEntrapment", spellName = "CaitlynEntrapment", spellDelay = 150, projectileName = "caitlyn_entrapment_mis.troy", projectileSpeed = 2000, range = 950, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Mundo"] = {charName = "DrMundo", skillshots = {
["Infected Cleaver"] = {name = "InfectedCleaver", spellName = "InfectedCleaverMissile", spellDelay = 250, projectileName = "dr_mundo_infected_cleaver_mis.troy", projectileSpeed = 2000, range = 1050, radius = 75, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Brand"] = {charName = "Brand", skillshots = {
["BrandBlaze"] = {name = "BrandBlaze", spellName = "BrandBlaze", spellDelay = 250, projectileName = "BrandBlaze_mis.troy", projectileSpeed = 1600, range = 1100, radius = 80, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["Pillar of Flame"] = {name = "PillarofFlame", spellName = "BrandFissure", spellDelay = 250, projectileName = "BrandPOF_tar_green.troy", projectileSpeed = 900, range = 1100, radius = 240, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
}},
["Corki"] = {charName = "Corki", skillshots = {
["Missile Barrage"] = {name = "MissileBarrage", spellName = "MissileBarrage", spellDelay = 250, projectileName = "corki_MissleBarrage_mis.troy", projectileSpeed = 2000, range = 1300, radius = 40, type = "line", cc = "false", collision = "true", shieldnow = "true"},
["Missile Barrage big"] = {name = "MissileBarragebig", spellName = "MissileBarrage!", spellDelay = 250, projectileName = "Corki_MissleBarrage_DD_mis.troy", projectileSpeed = 2000, range = 1300, radius = 40, type = "line", cc = "false", collision = "true", shieldnow = "true"}
}},
["TwistedFate"] = {charName = "TwistedFate", skillshots = {
["Loaded Dice"] = {name = "LoadedDice", spellName = "WildCards", spellDelay = 250, projectileName = "Roulette_mis.troy", projectileSpeed = 1000, range = 1450, radius = 40, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Swain"] = {charName = "Swain", skillshots = {
["Nevermove"] = {name = "Nevermove", spellName = "SwainShadowGrasp", spellDelay = 250, projectileName = "swain_shadowGrasp_transform.troy", projectileSpeed = 1000, range = 900, radius = 180, type = "circular", cc = "true", collision = "false", shieldnow = "true"}
}},
["Cassiopeia"] = {charName = "Cassiopeia", skillshots = {
["Noxious Blast"] = {name = "NoxiousBlast", spellName = "CassiopeiaNoxiousBlast", spellDelay = 250, projectileName = "CassNoxiousSnakePlane_green.troy", projectileSpeed = 500, range = 850, radius = 130, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
}},
["Sivir"] = {charName = "Sivir", skillshots = {
["Boomerang Blade"] = {name = "BoomerangBlade", spellName = "SivirQ", spellDelay = 250, projectileName = "Sivir_Base_Q_mis.troy", projectileSpeed = 1350, range = 1150, radius = 101, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Ashe"] = {charName = "Ashe", skillshots = {
["Enchanted Arrow"] = {name = "EnchantedArrow", spellName = "EnchantedCrystalArrow", spellDelay = 250, projectileName = "Ashe_Base_R_mis.troy", projectileSpeed = 1600, range = 25000, radius = 120, type = "line", cc = "true", collision = "false", shieldnow = "true"},
}},
["KogMaw"] = {charName = "KogMaw", skillshots = {
["Living Artillery"] = {name = "LivingArtillery", spellName = "KogMawLivingArtillery", spellDelay = 250, projectileName = "KogMawLivingArtillery_mis.troy", projectileSpeed = 1050, range = 2200, radius = 225, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
}},
["Khazix"] = {charName = "Khazix", skillshots = {
["KhazixW"] = {name = "KhazixW", spellName = "KhazixW", spellDelay = 250, projectileName = "Khazix_W_mis_enhanced.troy", projectileSpeed = 1700, range = 1025, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["khazixwlong"] = {name = "khazixwlong", spellName = "khazixwlong", spellDelay = 250, projectileName = "Khazix_W_mis_enhanced.troy", projectileSpeed = 1700, range = 1025, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Zed"] = {charName = "Zed", skillshots = {
["ZedShuriken"] = {name = "ZedShuriken", spellName = "ZedShuriken", spellDelay = 250, projectileName = "Zed_Q_Mis.troy", projectileSpeed = 1700, range = 925, radius = 50, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Leblanc"] = {charName = "Leblanc", skillshots = {
["Ethereal Chains"] = {name = "EtherealChains", spellName = "LeblancSoulShackle", spellDelay = 250, projectileName = "leBlanc_shackle_mis.troy", projectileSpeed = 1600, range = 960, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["Ethereal Chains R"] = {name = "EtherealChainsR", spellName = "LeblancSoulShackleM", spellDelay = 250, projectileName = "leBlanc_shackle_mis_ult.troy", projectileSpeed = 1600, range = 960, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Draven"] = {charName = "Draven", skillshots = {
["Stand Aside"] = {name = "StandAside", spellName = "DravenDoubleShot", spellDelay = 250, projectileName = "Draven_E_mis.troy", projectileSpeed = 1400, range = 1100, radius = 130, type = "line", cc = "true", collision = "false", shieldnow = "true"},
["DravenR"] = {name = "DravenR", spellName = "DravenRCast", spellDelay = 500, projectileName = "Draven_R_mis!.troy", projectileSpeed = 2000, range = 25000, radius = 160, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Elise"] = {charName = "Elise", skillshots = {
["Cocoon"] = {name = "Cocoon", spellName = "EliseHumanE", spellDelay = 250, projectileName = "Elise_human_E_mis.troy", projectileSpeed = 1450, range = 1100, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"}
}},
["Lulu"] = {charName = "Lulu", skillshots = {
["LuluQ"] = {name = "LuluQ", spellName = "LuluQ", spellDelay = 250, projectileName = "Lulu_Q_Mis.troy", projectileSpeed = 1450, range = 1000, radius = 50, type = "line", cc = "true", collision = "false", shieldnow = "true"}
}},
["Thresh"] = {charName = "Thresh", skillshots = {
["ThreshQ"] = {name = "ThreshQ", spellName = "ThreshQ", spellDelay = 500, projectileName = "Thresh_Q_whip_beam.troy", projectileSpeed = 1900, range = 1100, radius = 65, type = "line", cc = "true", collision = "true", shieldnow = "true"}
}},
["Shen"] = {charName = "Shen", skillshots = {
["ShadowDash"] = {name = "ShadowDash", spellName = "ShenShadowDash", spellDelay = 0, projectileName = "shen_shadowDash_mis.troy", projectileSpeed = 3000, range = 575, radius = 50, type = "line", cc = "true", collision = "false", shieldnow = "true"}
}},
["Quinn"] = {charName = "Quinn", skillshots = {
["QuinnQ"] = {name = "QuinnQ", spellName = "QuinnQ", spellDelay = 250, projectileName = "Quinn_Q_missile.troy", projectileSpeed = 1550, range = 1050, radius = 80, type = "line", cc = "false", collision = "true", shieldnow = "true"}
}},
["Veigar"] = {charName = "Veigar", skillshots = {
["Dark Matter"] = {name = "VeigarDarkMatter", spellName = "VeigarDarkMatter", spellDelay = 250, projectileName = "!", projectileSpeed = 900, range = 900, radius = 225, type = "circular", cc = "false", collision = "false", shieldnow = "true"}
}},
["Jayce"] = {charName = "Jayce", skillshots = {
["JayceShockBlast"] = {name = "JayceShockBlast", spellName = "jayceshockblast", spellDelay = 250, projectileName = "JayceOrbLightning.troy", projectileSpeed = 1450, range = 1050, radius = 70, type = "line", cc = "false", collision = "true", shieldnow = "true"},
["JayceShockBlastCharged"] = {name = "JayceShockBlastCharged", spellName = "jayceshockblast", spellDelay = 250, projectileName = "JayceOrbLightningCharged.troy", projectileSpeed = 2350, range = 1600, radius = 70, type = "line", cc = "false", collision = "true", shieldnow = "true"},
}},
["Nami"] = {charName = "Nami", skillshots = {
["NamiQ"] = {name = "NamiQ", spellName = "NamiQ", spellDelay = 250, projectileName = "Nami_Q_mis.troy", projectileSpeed = 1500, range = 1625, radius = 225, type = "circle", cc = "true", collision = "false", shieldnow = "true"}
}},
["Fizz"] = {charName = "Fizz", skillshots = {
["Fizz Ultimate"] = {name = "FizzULT", spellName = "FizzMarinerDoom", spellDelay = 250, projectileName = "Fizz_UltimateMissile.troy", projectileSpeed = 1350, range = 1275, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
}},
["Varus"] = {charName = "Varus", skillshots = {
["Varus Q Missile"] = {name = "VarusQMissile", spellName = "somerandomspellnamethatwillnevergetcalled", spellDelay = 0, projectileName = "VarusQ_mis.troy", projectileSpeed = 1900, range = 1600, radius = 70, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["VarusR"] = {name = "VarusR", spellName = "VarusR", spellDelay = 250, projectileName = "VarusRMissile.troy", projectileSpeed = 1950, range = 1250, radius = 100, type = "line", cc = "true", collision = "false", shieldnow = "true"},
}},
["Karma"] = {charName = "Karma", skillshots = {
["KarmaQ"] = {name = "KarmaQ", spellName = "KarmaQ", spellDelay = 250, projectileName = "TEMP_KarmaQMis.troy", projectileSpeed = 1700, range = 1050, radius = 90, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Aatrox"] = {charName = "Aatrox", skillshots = {
["Blade of Torment"] = {name = "BladeofTorment", spellName = "AatroxE", spellDelay = 250, projectileName = "AatroxBladeofTorment_mis.troy", projectileSpeed = 1200, range = 1075, radius = 75, type = "line", cc = "true", collision = "false", shieldnow = "true"},
["AatroxQ"] = {name = "AatroxQ", spellName = "AatroxQ", spellDelay = 250, projectileName = "AatroxQ.troy", projectileSpeed = 450, range = 650, radius = 145, type = "circle", cc = "true", collision = "false", shieldnow = "true"},
}},
["Xerath"] = {charName = "Xerath", skillshots = {
["Xerath Arcanopulse"] =  {name = "xeratharcanopulse21", spellName = "xeratharcanopulse2", spellDelay = 400, projectileName = "hiu", projectileSpeed = 25000, range = 0, radius = 125, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["XerathArcaneBarrage2"] = {name = "XerathArcaneBarrage2", spellName = "XerathArcaneBarrage2", spellDelay = 750, projectileName = "Xerath_Base_W_cas.troy", projectileSpeed = 0, range = 1100, radius = 375, type = "circular", cc = "true", collision = "false", shieldnow = "true"},
["XerathMageSpear"] = {name = "XerathMageSpear", spellName = "XerathMageSpear", spellDelay = 250, projectileName = "Xerath_Base_E_mis.troy", projectileSpeed = 1600, range = 1050, radius = 125, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["xerathlocuspulse"] = {name = "xerathlocuspulse", spellName = "xerathlocuspulse", spellDelay = 250, projectileName = "Xerath_Base_R_mis.troy", projectileSpeed = 300, range = 5600, radius = 265, type = "circular", cc = "false", collision = "false", shieldnow = "true"},
}},
["Lucian"] = {charName = "Lucian", skillshots = {
["LucianQ"] =  {name = "LucianQ", spellName = "LucianQ", spellDelay = 350, projectileName = "Lucian_Q_laser.troy", projectileSpeed = 25000, range = 570*2, radius = 65, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["LucianW"] =  {name = "LucianW", spellName = "LucianW", spellDelay = 300, projectileName = "Lucian_W_mis.troy", projectileSpeed = 1600, range = 1000, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Viktor"] = {charName = "Viktor", skillshots = {
["ViktorDeathRay1"] =  {name = "ViktorDeathRay1", spellName = "ViktorDeathRay!", spellDelay = 500, projectileName = "Viktor_DeathRay_Fix_Mis.troy", projectileSpeed = 780, range = 700, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["ViktorDeathRay2"] =  {name = "ViktorDeathRay2", spellName = "ViktorDeathRay!", spellDelay = 500, projectileName = "Viktor_DeathRay_Fix_Mis_Augmented.troy", projectileSpeed = 780, range = 700, radius = 80, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Rumble"] = {charName = "Rumble", skillshots = {
["RumbleGrenade"] =  {name = "RumbleGrenade", spellName = "RumbleGrenade", spellDelay = 250, projectileName = "rumble_taze_mis.troy", projectileSpeed = 2000, range = 950, radius = 90, type = "line", cc = "true", collision = "true", shieldnow = "true"},
}},
["Nocturne"] = {charName = "Nocturne", skillshots = {
["NocturneDuskbringer"] =  {name = "NocturneDuskbringer", spellName = "NocturneDuskbringer", spellDelay = 250, projectileName = "NocturneDuskbringer_mis.troy", projectileSpeed = 1400, range = 1125, radius = 60, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Yasuo"] = {charName = "Yasuo", skillshots = {
["yasuoq3"] =  {name = "yasuoq3", spellName = "yasuoq3w", spellDelay = 250, projectileName = "Yasuo_Q_wind_mis.troy", projectileSpeed = 1200, range = 1000, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
["yasuoq1"] =  {name = "yasuoq1", spellName = "yasuoQW", spellDelay = 250, projectileName = "Yasuo_Q_WindStrike.troy", projectileSpeed = 25000, range = 475, radius = 40, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["yasuoq2"] =  {name = "yasuoq2", spellName = "yasuoq2w", spellDelay = 250, projectileName = "Yasuo_Q_windstrike_02.troy", projectileSpeed = 25000, range = 475, radius = 40, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Orianna"] = {charName = "Orianna", skillshots = {
["OrianaIzunaCommand"] =  {name = "OrianaIzunaCommand", spellName = "OrianaIzunaCommand", spellDelay = 0, projectileName = "Oriana_Ghost_mis.troy", projectileSpeed = 1300, range = 800, radius = 80, type = "line", cc = "true", collision = "false", shieldnow = "true"},
["OrianaDetonateCommand"] =  {name = "OrianaDetonateCommand", spellName = "OrianaDetonateCommand", spellDelay = 100, projectileName = "Oriana_Shockwave_nova.troy", projectileSpeed = 400, range = 2000, radius = 400, type = "circular", cc = "true", collision = "false", shieldnow = "true"},   
}},
["Ziggs"] = {charName = "Ziggs", skillshots = {
["ZiggsQ"] =  {name = "ZiggsQ", spellName = "ZiggsQ", spellDelay = 250, projectileName = "ZiggsQ.troy", projectileSpeed = 1700, range = 1400, radius = 155, type = "line", cc = "false", collision = "true", shieldnow = "true"},
}},
["Annie"] = {charName = "Annie", skillshots = {
["AnnieR"] =  {name = "AnnieR", spellName = "InfernalGuardian", spellDelay = 100, projectileName = "nothing", projectileSpeed = 0, range = 600, radius = 300, type = "circular", cc = "true", collision = "false", shieldnow = "true"},
}},
["Galio"] = {charName = "Galio", skillshots = {
["GalioResoluteSmite"] =  {name = "GalioResoluteSmite", spellName = "GalioResoluteSmite", spellDelay = 250, projectileName = "galio_concussiveBlast_mis.troy", projectileSpeed = 850, range = 2000, radius = 200, type = "circle", cc = "true", collision = "false", shieldnow = "true"},
}},
["Jinx"] = {charName = "Jinx", skillshots = {
["W"] =  {name = "Zap", spellName = "JinxW", spellDelay = 600, projectileName = "Jinx_W_Beam.troy", projectileSpeed = 3300, range = 1450, radius = 70, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["R"] =  {name = "SuperMegaDeathRocket", spellName = "JinxRWrapper", spellDelay = 600, projectileName = "Jinx_R_Mis.troy", projectileSpeed = 1700, range = 20000, radius = 120, type = "line", cc = "false", collision = "false", shieldnow = "true"},
}},
["Velkoz"] = {charName = "Velkoz", skillshots = {
["PlasmaFission"] =  {name = "PlasmaFission", spellName = "VelKozQ", spellDelay = 250, projectileName = "Velkoz_Base_Q_mis.troy", projectileSpeed = 1200, range = 1050, radius = 120, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["Plasma Fission Split"] =  {name = "VelKozQSplit", spellName = "VelKozQ", spellDelay = 250, projectileName = "Velkoz_Base_Q_Split_mis.troy", projectileSpeed = 1200, range = 1050, radius = 120, type = "line", cc = "true", collision = "true", shieldnow = "true"},
["Void Rift"] =  {name = "VelkozW", spellName = "VelkozW", spellDelay = 250, projectileName = "Velkoz_Base_W_Turret.troy", projectileSpeed = 1200, range = 1050, radius = 125, type = "line", cc = "false", collision = "false", shieldnow = "true"},
["Tectonic Disruption"] =  {name = "VelkozE", spellName = "VelkozE", spellDelay = 250, projectileName = "DarkBinding_mis.troy", projectileSpeed = 1200, range = 800, radius = 225, type = "circular", cc = "true", collision = "false", shieldnow = "true"},
}}, 
["Heimerdinger"] = {charName = "Heimerdinger", skillshots = {
--["Micro-Rockets"] = {name = "MicroRockets", spellName = "HeimerdingerW1", spellDelay = 500, projectileName = "Heimerdinger_Base_w_Mis.troy", projectileSpeed = 902, range = 1325, radius = 100, type = "line", cc = "false", collision = "true", shieldnow = "true"},
--["Storm Grenade"] = {name = "StormGrenade", spellName = "HeimerdingerE", spellDelay = 250, projectileName = "Heimerdinger_Base_E_Mis.troy", projectileSpeed = 2500, range = 970, radius = 180, type = "circular", cc = "true", collision = "false", shieldnow = "true"},
--["Micro-RocketsUlt"] = {name = "MicroRocketsUlt", spellName = "HeimerdingerW2", spellDelay = 500, projectileName = "Heimerdinger_Base_W_Mis_Ult.troy", projectileSpeed = 902, range = 1325, radius = 100, type = "line", cc = "false", collision = "true", shieldnow = "true"},
--["Storm Grenade"] = {name = "StormGrenade", spellName = "HeimerdingerE2", spellDelay = 250, projectileName = "Heimerdinger_Base_E_Mis_Ult.troy", projectileSpeed = 2500, range = 970, radius = 180, type = "line", cc = "true", collision = "false", shieldnow = "true"},
}},
["Malzahar"] = {charName = "Malzahar", skillshots = {
["Call Of The Void"] = {name = "CallOfTheVoid", spellName ="AlZaharCalloftheVoid1", spellDelay = 0, projectileName = "AlzaharCallofthevoid_mis.troy", projectileSpeed = 1600, range = 450, radius = 100, type = "line", cc = "true", collision = "false", shieldnow = "true"},
}}  ,
["Janna"] = {charName = "Janna", skillshots = {
["Howling Gale"] = {name = "HowlingGale", spellName ="HowlingGale", spellDelay = 0, projectileName = "HowlingGale_mis.troy", projectileSpeed = 500, range = 0, radius = 100, type = "line", cc = "true", collision = "false", shieldnow = "true"},
}},
["Braum"] = {charName = "Braum", skillshots = {
["Winters Bite"] = {name = "WintersBite", spellName = "BraumQ", spellDelay = 225, projectileName = "Braum_Base_Q_mis.troy", projectileSpeed = 1600, range = 1000, radius = 100, type = "line", cc = "false", collision = "true", shieldnow = "true"},
["Glacial Fissure"] = {name = "GlacialFissure", spellName = "BraumRWrapper", spellDelay = 500, projectileName = "Braum_Base_R_mis.troy", projectileSpeed = 1250, range = 1250, radius = 100, type = "line", cc = "false", collision = "true", shieldnow = "true"},
}}      
}
_G.Champs = {
    ["Aatrox"] = {
        [_Q] = { speed = 450, delay = 0.27, range = 650, minionCollisionWidth = 280},
        [_E] = { speed = 1200, delay = 0.27, range = 1000, minionCollisionWidth = 80}
    },
        ["Ahri"] = {
        [_Q] = { speed = 1670, delay = 0.24, range = 895, minionCollisionWidth = 50},
        [_E] = { speed = 1550, delay = 0.24, range = 920, minionCollisionWidth = 80}
    },
        ["Amumu"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1100, minionCollisionWidth = 80}
    },
        ["Anivia"] = {
        [_Q] = { speed = 860.05, delay = 0.250, range = 1100, minionCollisionWidth = 110},
        [_R] = { speed = math.huge, delay = 0.100, range = 615, minionCollisionWidth = 350}
    },
        ["Annie"] = {
        [_W] = { speed = math.huge, delay = 0.25, range = 625, minionCollisionWidth = 0},
        [_R] = { speed = math.huge, delay = 0.2, range = 600, minionCollisionWidth = 0}
    },
        ["Ashe"] = {
        [_W] = { speed = 2000, delay = 0.120, range = 1200, minionCollisionWidth = 85},
        [_R] = { speed = 1600, delay = 0.5, range = 1200, minionCollisionWidth = 0}
    },
        ["Blitzcrank"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 1050, minionCollisionWidth =  90}
    },
        ["Brand"] = {
        [_Q] = { speed = 1600, delay = 0.625, range = 1100, minionCollisionWidth = 90},
        [_W] = { speed = 900, delay = 0.25, range = 1100, minionCollisionWidth = 0},
    },
        ["Braum"] = {
        [_Q] = { speed = 1600, delay = 225, range = 1000, minionCollisionWidth = 100},
        [_R] = { speed = 1250, delay = 500, range = 1250, minionCollisionWidth = 0},
    },    
        ["Caitlyn"] = {
        [_Q] = { speed = 2200, delay = 0.625, range = 1300, minionCollisionWidth = 0},
        [_E] = { speed = 2000, delay = 0.400, range = 1000, minionCollisionWidth = 80},
    },
        ["Cassiopeia"] = {
        [_Q] = { speed = math.huge, delay = 0.535, range = 850, minionCollisionWidth = 0},
        [_W] = { speed = math.huge, delay = 0.350, range = 850, minionCollisionWidth = 80},
        [_R] = { speed = math.huge, delay = 0.535, range = 850, minionCollisionWidth = 350}
    },
        ["Chogath"] = {
        [_Q] = { speed = 950, delay = 0, range = 950, minionCollisionWidth = 0},
        [_W] = { speed = math.huge, delay = 0.25, range = 700, minionCollisionWidth = 0},
        },
        ["Corki"] = {
        [_Q] = { speed = 1500, delay = 0.350, range = 840, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.200, range = 1225, minionCollisionWidth = 60},
    },
        ["Darius"] = {
        [_E] = { speed = 1500, delay = 0.550, range = 530, minionCollisionWidth = 0}
    },
        ["Diana"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 830, minionCollisionWidth = 0}
    },
        ["DrMundo"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1050, minionCollisionWidth = 80}
    },
        ["Draven"] = {
        [_E] = { speed = 1400, delay = 0.250, range = 1100, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.5, range = 2500, minionCollisionWidth = 0}
    },
        ["Elise"] = {
        [_E] = { speed = 1450, delay = 0.250, range = 975, minionCollisionWidth = 80}
    },
        ["Ezreal"] = {
        [_Q] = { speed = 2000, delay = 0.251, range = 1200, minionCollisionWidth = 80},
        [_W] = { speed = 1600, delay = 0.25, range = 1050, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 1, range = 20000, minionCollisionWidth = 150}
    },
        ["Fizz"] = {
        [_R] = { speed = 1350, delay = 0.250, range = 1150, minionCollisionWidth = 0}
    },
        ["Galio"] = {
        [_Q] = { speed = 850, delay = 0.25, range = 940, minionCollisionWidth = 0},
        --[_E] = { speed = 2000, delay = 0.400, range = 1180, minionCollisionWidth = 0},
    },
        ["Gragas"] = {
        [_Q] = { speed = 1000, delay = 0.250, range = 1100, minionCollisionWidth = 0}
    },
        ["Graves"] = {
        [_Q] = { speed = 1950, delay = 0.265, range = 950, minionCollisionWidth = 85},
        [_W] = { speed = 1650, delay = 0.300, range = 950, minionCollisionWidth = 0},
        [_R] = { speed = 2100, delay = 0.219, range = 1000, minionCollisionWidth = 30}
    },
        ["Heimerdinger"] = {
                [_W] = { speed = 1200, delay = 0.200, range = 1100, minionCollisionWidth = 70},
                [_E] = { speed = 1000, delay = 0.1, range = 925, minionCollisionWidth = 0},
        },
        ["Irelia"] = {
        [_R] = { speed = 1700, delay = 0.250, range = 1000, minionCollisionWidth = 0}
    },
        ["JarvanIV"] = {
                [_Q] = { speed = 1400, delay = 0.2, range = 800, minionCollisionWidth = 0},
                [_E] = { speed = 200, delay = 0.2, range = 850, minionCollisionWidth = 0},
        },
        ["Jinx"] = {
                [_W] = { speed = 3300, delay = 0.600, range = 1500, minionCollisionWidth = 70},
                [_E] = { speed = 887, delay = 0.500, range = 950, minionCollisionWidth = 0},
                [_R] = { speed = 2500, delay = 0.600, range = 2000 , minionCollisionWidth = 0}
        },
        ["Karma"] = {
        [_Q] = { speed = 1700, delay = 0.250, range = 1050, minionCollisionWidth = 80}
    },
        ["Karthus"] = {
        [_Q] = { speed = 1750, delay = 0.25, range = 875, minionCollisionWidth = 0},
    },
        ["Kennen"] = {
        [_Q] = { speed = 1700, delay = 0.180, range = 1050, minionCollisionWidth = 70}
    },
        ["Khazix"] = {
        [_W] = { speed = 828.5, delay = 0.225, range = 1000, minionCollisionWidth = 100}
    },
        ["KogMaw"] = {
        [_R] = { speed = 1050, delay = 0.250, range = 2200, minionCollisionWidth = 0}
    },
        ["Leblanc"] = {
        [_E] = { speed = 1600, delay = 0.250, range = 960, minionCollisionWidth = 0},
        [_R] = { speed = 1600, delay = 0.250, range = 960, minionCollisionWidth = 0},
    },
        ["LeeSin"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 1100, minionCollisionWidth = 100}
    },
        ["Leona"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 900, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.250, range = 1200, minionCollisionWidth = 0},
    },
        ["Lissandra"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 725, minionCollisionWidth = 00}
    },
        ["Lucian"] = {
        [_W] = { speed = 1470, delay = 0.288, range = 1000, minionCollisionWidth = 25}
    },
        ["Lulu"] = {
        [_Q] = { speed = 1530, delay = 0.250, range = 945, minionCollisionWidth = 80}
    },
        ["Lux"] = {
        [_Q] = { speed = 1200, delay = 0.245, range = 1300, minionCollisionWidth = 50},
        [_E] = { speed = 1400, delay = 0.245, range = 1100, minionCollisionWidth = 0},
        [_R] = { speed = math.huge, delay = 0.245, range = 3500, minionCollisionWidth = 0}
    },
        ["Malzahar"] = {
        [_Q] = { speed = 1170, delay = 0.600, range = 900, minionCollisionWidth = 50}
    },
        ["Mordekaiser"] = {
        [_E] = { speed = math.huge, delay = 0.25, range = 700, minionCollisionWidth = 0},
        },
        ["Morgana"] = {
        [_Q] = { speed = 1200, delay = 0.250, range = 1300, minionCollisionWidth = 80}
    },
        ["Nami"] = {
        [_Q] = { speed = math.huge, delay = 0.8, range = 850, minionCollisionWidth = 0}
    },
        ["Nautilus"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1080, minionCollisionWidth = 100}
    },
        ["Nidalee"] = {
        [_Q] = { speed = 1300, delay = 0.125, range = 1500, minionCollisionWidth = 60},
    },
        ["Nocturne"] = {
        [_Q] = { speed = 1600, delay = 0.250, range = 1200, minionCollisionWidth = 0}
    },
        ["Olaf"] = {
        [_Q] = { speed = 1600, delay = 0.25, range = 1000, minionCollisionWidth = 0}
    },
        ["Quinn"] = {
        [_Q] = { speed = 1600, delay = 0.25, range = 1050, minionCollisionWidth = 100}
    },
        ["Rumble"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 950, minionCollisionWidth = 80}
    },
        ["Sejuani"] = {
        [_R] = { speed = 1300, delay = 0.200, range = 1175, minionCollisionWidth = 0}
    },
        ["Sivir"] = {
        [_Q] = { speed = 1330, delay = 0.250, range = 1075, minionCollisionWidth = 0}
    },
        ["Skarner"] = {
        [_E] = { speed = 1200, delay = 0.250, range = 760, minionCollisionWidth = 0}
    },
        ["Swain"] = {
        [_Q] = { speed = math.huge, delay = 0.500, range = 900, minionCollisionWidth = 0}
    },
        ["Syndra"] = {
        [_Q] = { speed = math.huge, delay = 0.400, range = 800, minionCollisionWidth = 0}
    },
        ["Thresh"] = {
        [_Q] = { speed = 1900, delay = 0.500, range = 1075, minionCollisionWidth = 80}
    },
        ["Twitch"] = {
        [_W] = {speed = 1750, delay = 0.283, range = 900, minionCollisionWidth = 0}
    },
        ["TwistedFate"] = {
        [_Q] = { speed = 1450, delay = 0.200, range = 1450, minionCollisionWidth = 0}
    },
        ["Urgot"] = {
        [_Q] = { speed = 1600, delay = 0.175, range = 1000, minionCollisionWidth = 100},
        [_E] = { speed = 1750, delay = 0.25, range = 900, minionCollisionWidth = 0}
    },
        ["Varus"] = {
       --[_Q] = { speed = 1850, delay = 0.1, range = 1475, minionCollisionWidth = 0},
        [_E] = { speed = 1500, delay = 0.245, range = 925, minionCollisionWidth = 0},
        [_R] = { speed = 1950, delay = 0.5, range = 1075, minionCollisionWidth = 0}
    },
        ["Veigar"] = {
        [_W] = { speed = 900, delay = 0.25, range = 900, minionCollisionWidth = 0}
    },
        ["Viktor"] = {
                [_W] = { speed = math.huge, delay = 0.25, range = 625, minionCollisionWidth = 0},
                [_E] = { speed = 1200, delay = 0.25, range = 1225, minionCollisionWidth = 0},
                [_R] = { speed = 1000, delay = 0.25, range = 700, minionCollisionWidth = 0},
    },
        ["Velkoz"] = {
                [_Q] = { speed = 1300, delay = 0.066, range = 1100, minionCollisionWidth = 50},
                [_W] = { speed = 1700, delay = 0.064, range = 1050, minionCollisionWidth = 0},
                [_E] = { speed = 1500, delay = 0.333, range = 1100, minionCollisionWidth = 0},
    },    
        ["Xerath"] = {
        [_Q] = { speed = 3000, delay = 0.6, range = 1100, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.25, range = 1100, minionCollisionWidth = 0}
    },
        ["Yasuo"] = {
        --["yasuoq3"] =  { spellDelay = 250, projectileSpeed = 1200, range = 1000, minionCollisionWidth = 0},
        [_Q] =  { speed = 25000, delay = 250, range = 475, minionCollisionWidth = 0},
        --["yasuoq2"] =  { spellDelay = 250, projectileSpeed = 25000, range = 475, minionCollisionWidth = 0},
    },
        ["Zed"] = {
        [_Q] = { speed = 1700, delay = 0.2, range = 925, minionCollisionWidth = 0},
    },
        ["Ziggs"] = {
        [_Q] = { speed = 1722, delay = 0.218, range = 850, minionCollisionWidth = 0},
                [_W] = { speed = 1727, delay = 0.249, range = 1000, minionCollisionWidth = 0},
                [_E] = { speed = 2694, delay = 0.125, range = 900, minionCollisionWidth = 0},
                [_R] = { speed = 1856, delay = 0.1014, range = 2500, minionCollisionWidth = 0},
    },
        ["Zyra"] = {
                 [_Q] = { speed = math.huge, delay = 0.7, range = 800, minionCollisionWidth = 0},
         [_E] = { speed = 1150, delay = 0.16, range = 1100, minionCollisionWidth = 0}
    }
}

if not Champs[myHero.charName] then return end -- not supported :(
local data = Champs[myHero.charName]
local data2 = champions2[myHero.charName].skillshots
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local Target 
local ts2 = TargetSelector(TARGET_LOW_HP, 1500, DAMAGE_MAGIC, true) -- make these local
local str = { [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" }
local ConfigType = SCRIPT_PARAM_ONKEYDOWN
local predictions = {}
local toCast = {false, false, false, false}
function OnLoad()
  Config = scriptConfig("Aimbot v"..version, "Aimbot v"..version)
  Config:addSubMenu("[Prediction]: Settings", "prConfig")
  Config.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
  Config.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction"}) -- ,"DivinePred"
  Config:addSubMenu("[Skills]: Settings", "skConfig")
  --[[ DEPRECATED ]]--[[
  Config.skConfig:addParam("scq", "Cast Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
  Config.skConfig:addParam("scw", "Cast W", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
  Config.skConfig:addParam("sce", "Cast E", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
  Config.skConfig:addParam("scr", "Cast R", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R")) ]]
  --[[ NOW: BEAUTIFUL ]]
  for i, spell in pairs(data) do
    Config.skConfig:addParam(str[i], "Cast " .. str[i], ConfigType, false, string.byte(str[i]))
    predictions[str[i]] = {spell.range, spell.speed, spell.delay, spell.minionCollisionWidth, i}
  end
  Config:addParam("tog", "Aimbot on/off", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("T"))
  Config:addParam("throw", "Throw everything", SCRIPT_PARAM_ONKEYDOWN, false, 32)
  Config:addParam("autocast", "Autocast on 100% hitchance", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("accuracy", "Accuracy Slider", SCRIPT_PARAM_SLICE, 2, 0, 3, 0)
  Config:addParam("rangeoffset", "Range Decrease Offset", SCRIPT_PARAM_SLICE, 0, 0, 200, 0)
  ts2.name = "Target"
  Config:addTS(ts2)
end

function OnTick()
  if Config.tog then
    if Config.prConfig.pro == 1 then
      Target = GetCustomTarget() --Tmrees
      if Target == nil then return end
      for i, spell in pairs(data) do
            local collision = spell.minionCollisionWidth == 0 and false or true
            local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, spell.delay, spell.minionCollisionWidth, spell.range, spell.speed, myHero, collision)
          if (Config.throw or Config[str[i]]) and myHero:CanUseSpell(i) and IsLeeThresh() and IsYasuo() then -- move spell ready check to top
              if CastPosition and HitChance and HitChance >= Config.accuracy and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CCastSpell(i, CastPosition.x, CastPosition.z) end   
          elseif Config.autocast then
                if CastPosition and HitChance and HitChance > 2 and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CCastSpell(i, CastPosition.x, CastPosition.z) end
          elseif toCast[i] == true and myHero:CanUseSpell(i) and IsLeeThresh() and IsYasuo()  then
              if CastPosition and HitChance and HitChance >= Config.accuracy and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CCastSpell(i, CastPosition.x, CastPosition.z) end  
              toCast[i] = false 
          end
      end 
    end
    --[[ WILL BE IMPLEMENTED LATER
    if Config.prConfig.pro == 2 and VIP_USER then
      Target = GetCustomTarget() --Tmrees
      if Target == nil then return end
      local unit = DPTarget(Target)
      for i, spell in pairs(data2) do
        local skill = LineSS(spell.projectileSpeed, spell.range, spell.radius, spell.spellDelay, 0)
        --PrintChat(spell.name)
        local state,hitPos,perc = DP:predict(unit, skill)
        if Config.throw and State == SkillShot.STATUS.SUCCESS_HIT then 
          CCastSpell(i, Position.x, Position.z)
        end
      end
    end]]
    walk()
  end
end

function walk()
  if Config.throw then
    myHero:MoveTo(mousePos.x, mousePos.z)
  end
end

function OnWndMsg(msg, key)
   if msg == KEY_UP and key == GetKey("Q") then
     toCast[0] = false
   elseif msg == KEY_UP and key == GetKey("W") then 
     toCast[1] = false
   elseif msg == KEY_UP and key == GetKey("E") then 
     toCast[2] = false
   elseif msg == KEY_UP and key == GetKey("R") then
     toCast[3] = false
   end
end

function OnSendPacket(p)
  Target = GetCustomTarget() --Tmrees
  if Config.tog then
    if p.header == 0x00E9 then -- Credits to PewPewPew
      p.pos=27
      --print(('0x%02X'):format(p:Decode1()))
      local opc = p:Decode1()
      --PrintChat("Packet send: "..('0x%02X'):format(opc))
      if Target ~= nil then
        if opc == 0x02 and not toCast[0] then 
          p:Block()
          p.skip(p, 1)
          toCast[0] = true
        elseif opc == 0xD8 and not toCast[1] then 
          p:Block()
          p.skip(p, 1)
          toCast[1] = true
        elseif opc == 0xB3 and not toCast[2] then 
          p:Block()
          p.skip(p, 1)
          toCast[2] = true
        elseif opc == 0xE7 and not toCast[3] then
          p:Block()
          p.skip(p, 1)
          toCast[3] = true
        end
      end
    end
  end
end

function IsLeeThresh()
  if myHero.charName == 'LeeSin' then
    if myHero:GetSpellData(_Q).name == 'BlindMonkQOne' then
      return true
    else
      return false
    end
  elseif myHero.charName == 'Thresh' then
    if myHero:GetSpellData(_Q).name == 'ThreshQ' then
      return true
    else
      return false
    end 
  else 
    return true
  end
end

function IsYasuo()
  if myHero.charName == 'LeeSin' then
    if myHero:GetSpellData(_Q).name == 'YasuoQ' then
      return true
    else
      return false
    end 
  else 
    return true
  end
end

--Credit Trees
function GetCustomTarget()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    ts2:update()
    --print('tstarget called')
    return ts2.target
end
--End Credit Trees

--[[ Packet Cast Helper ]]--
function CCastSpell(Spell, xPos, zPos)
  --PrintChat("Cast "..Spell)
  if VIP_USER and Config.prConfig.pc then
    Packet("S_CAST", {spellId = Spell, fromX = xPos, fromY = zPos, toX = xPos, toY = zPos}):send()
  else
    CastSpell(Spell, xPos, zPos)
  end
end