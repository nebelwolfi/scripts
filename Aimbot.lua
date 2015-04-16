--[[

             _               _               _   
     /\     (_)             | |             | |  
    /  \     _   _ __ ___   | |__     ___   | |_ 
   / /\ \   | | | '_ ` _ \  | '_ \   / _ \  | __|
  / ____ \  | | | | | | | | | |_) | | (_) | | |_ 
 /_/    \_\ |_| |_| |_| |_| |_.__/   \___/   \__|
                                                 
                                                  

]]--

if not VIP_USER then return end -- VIP only since we use packets everywhere

--[[ Skillshot list start ]]--
_G.Champs = {
    ["Aatrox"] = {
        [_Q] = { speed = 450, delay = 0.25, range = 650, width = 145, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1200, delay = 0.25, range = 1075, width = 75, collision = false, aoe = false, type = "linear"}
    },
        ["Ahri"] = {
        [_Q] = { speed = 2500, delay = 0.25, range = 900, width = 100, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 1000, delay = 0.25, range = 1000, width = 60, collision = true, aoe = false, type = "linear"}
    },
        ["Amumu"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1100, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Anivia"] = {
        [_Q] = { speed = 850, delay = 0.250, range = 1100, width = 110, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = math.huge, delay = 0.100, range = 615, width = 350, collision = false, aoe = true, type = "circular"}
    },
        ["Annie"] = {
        [_W] = { speed = math.huge, delay = 0.25, range = 625, width = 0, collision = false, aoe = true, type = "cone"},
        [_R] = { speed = math.huge, delay = 0.1, range = 600, width = 300, collision = false, aoe = true, type = "circular"}
    },
        ["Ashe"] = {
        [_W] = { speed = 2000, delay = 0.120, range = 1200, width = 85, collision = true, aoe = false, type = "cone"},
        [_R] = { speed = 1600, delay = 0.25, range = 25000, width = 120, collision = false, aoe = false, type = "linear"}
    },
        ["Blitzcrank"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 900, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Brand"] = {
        [_Q] = { speed = 1600, delay = 0.625, range = 1100, width = 90, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = 900, delay = 0.25, range = 1100, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["Braum"] = {
        [_Q] = { speed = 1600, delay = 225, range = 1000, width = 100, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1250, delay = 500, range = 1250, width = 0, collision = false, aoe = false, type = "linear"}
    },    
        ["Caitlyn"] = {
        [_Q] = { speed = 2200, delay = 0.625, range = 1300, width = 0, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 2000, delay = 0.400, range = 1000, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Cassiopeia"] = {
        [_Q] = { speed = math.huge, delay = 0.535, range = 850, width = 0, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = math.huge, delay = 0.350, range = 850, width = 80, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = math.huge, delay = 0.535, range = 850, width = 350, collision = false, aoe = false, type = "linear"}
    },
        ["Chogath"] = {
        [_Q] = { speed = 950, delay = 0, range = 950, width = 0, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = math.huge, delay = 0.25, range = 700, width = 0, collision = false, aoe = false, type = "linear"},
        },
        ["Corki"] = {
        [_Q] = { speed = 1500, delay = 0.350, range = 840, width = 0, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 2000, delay = 0.200, range = 1225, width = 60, collision = false, aoe = false, type = "linear"},
    },
        ["Darius"] = {
        [_E] = { speed = 1500, delay = 0.550, range = 530, width = 0, collision = false, aoe = true, type = "cone"}
    },
        ["Diana"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 830, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["DrMundo"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1050, width = 75, collision = true, aoe = false, type = "linear"}
    },
        ["Draven"] = {
        [_E] = { speed = 1400, delay = 0.250, range = 1100, width = 130, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 2000, delay = 0.5, range = 25000, width = 160, collision = false, aoe = false, type = "linear"}
    },
        ["Elise"] = {
        [_E] = { speed = 1450, delay = 0.250, range = 975, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Ezreal"] = {
        [_Q] = { speed = 2000, delay = 0.25, range = 1200, width = 80, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 1500, delay = 0.25, range = 1050, width = 80, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 2000, delay = 1, range = 20000, width = 160, collision = false, aoe = false, type = "linear"}
    },
        ["Fizz"] = {
        [_R] = { speed = 1350, delay = 0.250, range = 1275, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Galio"] = {
        [_Q] = { speed = 1300, delay = 0.25, range = 900, width = 175, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 2000, delay = 0.400, range = 1000, width = 40, collision = false, aoe = false, type = "linear"}
    },
        ["Gragas"] = {
        [_Q] = { speed = 1000, delay = 0.250, range = 1100, width = 180, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1000, delay = 0.250, range = 1050, width = 400, collision = false, aoe = true, type = "circular"}
    },
        ["Graves"] = {
        [_Q] = { speed = 1950, delay = 0.265, range = 750, width = 85, collision = false, aoe = false, type = "cone"},
        [_W] = { speed = 1650, delay = 0.300, range = 700, width = 250, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 2100, delay = 0.219, range = 1000, width = 30, collision = false, aoe = false, type = "linear"}
    },
        ["Heimerdinger"] = {
        [_W] = { speed = 900, delay = 0.500, range = 1325, width = 100, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 2500, delay = 0.250, range = 970, width = 180, collision = false, aoe = true, type = "circular"}
    },
        ["Irelia"] = {
        [_R] = { speed = 1700, delay = 0.250, range = 1200, width = 10, collision = false, aoe = false, type = "linear"}
    },
        ["JarvanIV"] = {
        [_Q] = { speed = 1400, delay = 0.2, range = 770, width = 0, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 200, delay = 0.2, range = 850, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["Jinx"] = {
        [_W] = { speed = 3300, delay = 0.600, range = 1450, width = 70, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 887, delay = 0.500, range = 830, width = 0, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1700, delay = 0.600, range = 20000, width = 120, collision = false, aoe = true, type = "circular"}
    },
        ["Karma"] = {
        [_Q] = { speed = 1700, delay = 0.250, range = 1050, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Karthus"] = {
        [_Q] = { speed = 1750, delay = 0.25, range = 875, width = 140, collision = false, aoe = true, type = "circular"}
    },
        ["Kennen"] = {
        [_Q] = { speed = 1700, delay = 0.180, range = 1050, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Khazix"] = {
        [_W] = { speed = 1700, delay = 0.25, range = 1025, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["KogMaw"] = {
        [_Q] = { speed = 1050, delay = 0.250, range = 1000, width = 10, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 500, delay = 0.250, range = 1000, width = 180, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1050, delay = 0.250, range = 2200, width = 225, collision = false, aoe = true, type = "circular"}
    },
        ["Leblanc"] = {
        [_E] = { speed = 1600, delay = 0.250, range = 960, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["LeeSin"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 1100, width = 100, collision = true, aoe = false, type = "linear"}
    },
        ["Leona"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 950, width = 110, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1500, delay = 0.250, range = 1200, width = 300, collision = false, aoe = true, type = "circular"}
    },
        ["Lissandra"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 725, width = 20, collision = true, aoe = false, type = "linear"}
    },
        ["Lucian"] = {
        [_W] = { speed = 1600, delay = 0.300, range = 1000, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Lulu"] = {
        [_Q] = { speed = 1450, delay = 0.250, range = 1000, width = 50, collision = false, aoe = false, type = "linear"}
    },
        ["Lux"] = {
        [_Q] = { speed = 1200, delay = 0.245, range = 1300, width = 50, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 1400, delay = 0.245, range = 1100, width = 0, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = math.huge, delay = 0.245, range = 3500, width = 0, collision = false, aoe = false, type = "linear"},
    },
        ["Malphite"] = {
        [_R] = { speed = 550, delay = 0.0, range = 1000, width = 300, collision = false, aoe = true, type = "circular"}
    },
        ["Malzahar"] = {
        [_Q] = { speed = 1170, delay = 0.600, range = 900, width = 50, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = math.huge, delay = 0.125, range = 800, width = 250, collision = false, aoe = true, type = "circular"}
    },
        ["Mordekaiser"] = {
        [_E] = { speed = math.huge, delay = 0.25, range = 700, width = 0, collision = false, aoe = true, type = "cone"},
    },
        ["Morgana"] = {
        [_Q] = { speed = 1200, delay = 0.250, range = 1300, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Nami"] = {
        [_Q] = { speed = math.huge, delay = 0.8, range = 850, width = 0, collision = false, aoe = true, type = "circular"}
    },
        ["Nautilus"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1080, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Nidalee"] = {
        [_Q] = { speed = 1300, delay = 0.125, range = 1500, width = 60, collision = true, aoe = false, type = "linear"},
    },
        ["Nocturne"] = {
        [_Q] = { speed = 1400, delay = 0.250, range = 1125, width = 60, collision = false, aoe = false, type = "linear"}
    },
        ["Olaf"] = {
        [_Q] = { speed = 1600, delay = 0.25, range = 1000, width = 90, collision = false, aoe = false, type = "linear"}
    },
        ["Quinn"] = {
        [_Q] = { speed = 1550, delay = 0.25, range = 1050, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Rengar"] = {
        [_E] = { speed = 1500, delay = 0.50, range = 1000, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Riven"] = {
        [_R] = { speed = 2200, delay = 0.5, range = 1100, width = 200, collision = false, aoe = false, type = "cone"}
    },
        ["Rumble"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 950, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Sejuani"] = {
        [_R] = { speed = 1600, delay = 0.250, range = 1200, width = 110, collision = false, aoe = false, type = "linear"}
    },
        ["Shyvana"] = {
        [_E] = { speed = 1500, delay = 0.250, range = 925, width = 60, collision = false, aoe = false, type = "linear"}
    },
        ["Sivir"] = {
        [_Q] = { speed = 1330, delay = 0.250, range = 1075, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["Skarner"] = {
        [_E] = { speed = 1200, delay = 0.600, range = 350, width = 60, collision = false, aoe = false, type = "linear"}
    },
        ["Sona"] = {
        [_R] = { speed = 2400, delay = 0.240, range = 1000, width = 160, collision = true, aoe = false, type = "linear"}
    },
        ["Swain"] = {
        [_W] = { speed = math.huge, delay = 0.850, range = 900, width = 125, collision = false, aoe = true, type = "circular"}
    },
        ["Syndra"] = {
        [_Q] = { speed = math.huge, delay = 0.600, range = 790, width = 125, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 2500, delay = 0.250, range = 700, width = 45, collision = false, aoe = true, type = "cone"}
    },
        ["Thresh"] = {
        [_Q] = { speed = 1900, delay = 0.500, range = 1100, width = 65, collision = true, aoe = false, type = "linear"}
    },
        ["Twitch"] = {
        [_W] = {speed = 1750, delay = 0.250, range = 950, width = 275, collision = false, aoe = true, type = "circular"}
    },
        ["TwistedFate"] = {
        [_Q] = { speed = 1500, delay = 0.250, range = 1200, width = 80, collision = false, aoe = false, type = "cone"}
    },
        ["Urgot"] = {
        [_Q] = { speed = 1600, delay = 0.175, range = 1400, width = 80, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 1600, delay = 0.25, range = 920, width = 100, collision = false, aoe = true, type = "circular"}
    },
        ["Varus"] = {
       --[_Q] = { speed = 1850, delay = 0.1, range = 1475, width = 0},
        [_E] = { speed = 1500, delay = 0.25, range = 925, width = 240, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1950, delay = 0.5, range = 800, width = 100, collision = false, aoe = false, type = "linear"}
    },
        ["Veigar"] = {
        [_Q] = { speed = 1200, delay = 0.25, range = 875, width = 75, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 900, delay = 1.25, range = 900, width = 110, collision = false, aoe = true, type = "circular"}
    },
        ["Viktor"] = {
        [_W] = { speed = 750, delay = 0.6, range = 700, width = 125, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1200, delay = 0.25, range = 1200, width = 0, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1000, delay = 0.25, range = 700, width = 0, collision = false, aoe = true, type = "circular"},
    },
        ["Velkoz"] = {
        [_Q] = { speed = 1300, delay = 0.066, range = 1050, width = 50, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 1700, delay = 0.064, range = 1050, width = 80, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 1500, delay = 0.333, range = 850, width = 120, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = math.huge, delay = 0.333, range = 1550, width = 50, collision = false, aoe = false, type = "linear"}
    },    
        ["Xerath"] = {
        [_W] = { speed = math.huge, delay = 0.5, range = 1100, width = 325, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1600, delay = 0.25, range = 1050, width = 125, collision = true, aoe = false, type = "linear"},
        [_R] = { speed = 300, delay = 0.25, range = 5600, width = 265, collision = false, aoe = true, type = "circular"}
    },
        ["Yasuo"] = {
        [_Q] =  { speed = math.huge, delay = 250, range = 475, width = 40, collision = false, aoe = false, type = "linear"},
    },
        ["Zac"] = {
        [_Q] = { speed = 2500, delay = 0.110, range = 500, width = 110, collision = false, aoe = false, type = "linear"},
    },
        ["Zed"] = {
        [_Q] = { speed = 1700, delay = 0.25, range = 925, width = 50, collision = false, aoe = false, type = "linear"},
    },
        ["Ziggs"] = {
        [_Q] = { speed = 1750, delay = 0.5, range = 1400, width = 80, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 1800, delay = 0.25, range = 970, width = 275, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 2700, delay = 0.8, range = 900, width = 235, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1750, delay = 0.1014, range = 5300, width = 525, collision = false, aoe = true, type = "circular"},
    },
        ["Zilean"] = {
        [_Q] = { speed = math.huge, delay = 0.5, range = 900, width = 150, collision = false, aoe = true, type = "circular"},
    },
        ["Zyra"] = {
        [_Q] = { speed = math.huge, delay = 0.7, range = 800, width = 85, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1150, delay = 0.25, range = 1100, width = 70, collision = false, aoe = false, type = "linear"}
    }
}
--[[ Skillshot list end ]]--

assert(load(Base64Decode("LS1bWyBBdXRvIHVwZGF0ZXIgc3RhcnQgYW5kIEVuY3J5cHRpb24gc3RhcnQgXV0tLQ0KbG9jYWwgQVVUT19VUERBVEUgPSB0cnVlDQpsb2NhbCBVUERBVEVfSE9TVCA9ICJyYXcuZ2l0aHViLmNvbSINCmxvY2FsIFVQREFURV9QQVRIID0gIi9uZWJlbHdvbGZpL3NjcmlwdHMvbWFzdGVyL0FpbWJvdC5sdWEiLi4iP3JhbmQ9Ii4ubWF0aC5yYW5kb20oMSwxMDAwMCkNCmxvY2FsIFVQREFURV9GSUxFX1BBVEggPSBTQ1JJUFRfUEFUSC4uIkFpbWJvdC5sdWEiDQpsb2NhbCBVUERBVEVfVVJMID0gImh0dHBzOi8vIi4uVVBEQVRFX0hPU1QuLlVQREFURV9QQVRIDQpsb2NhbCBmdW5jdGlvbiBBdXRvdXBkYXRlck1zZyhtc2cpIHByaW50KCI8Zm9udCBjb2xvcj1cIiM2Njk5ZmZcIj48Yj5BaW1ib3Q6PC9iPjwvZm9udD4gPGZvbnQgY29sb3I9XCIjRkZGRkZGXCI+Ii4ubXNnLi4iLjwvZm9udD4iKSBlbmQNCmlmIEFVVE9fVVBEQVRFIHRoZW4NCiAgbG9jYWwgU2VydmVyRGF0YSA9IEdldFdlYlJlc3VsdChVUERBVEVfSE9TVCwgIi9uZWJlbHdvbGZpL3NjcmlwdHMvbWFzdGVyL0FpbWJvdC52ZXJzaW9uIikNCiAgaWYgU2VydmVyRGF0YSB0aGVuDQogICAgU2VydmVyVmVyc2lvbiA9IHR5cGUodG9udW1iZXIoU2VydmVyRGF0YSkpID09ICJudW1iZXIiIGFuZCB0b251bWJlcihTZXJ2ZXJEYXRhKSBvciBuaWwNCiAgICBpZiBTZXJ2ZXJWZXJzaW9uIHRoZW4NCiAgICAgIGlmIHRvbnVtYmVyKHZlcnNpb24pIDwgU2VydmVyVmVyc2lvbiB0aGVuDQogICAgICAgIEF1dG91cGRhdGVyTXNnKCJOZXcgdmVyc2lvbiBhdmFpbGFibGUgdiIuLlNlcnZlclZlcnNpb24pDQogICAgICAgIEF1dG91cGRhdGVyTXNnKCJVcGRhdGluZywgcGxlYXNlIGRvbid0IHByZXNzIEY5IikNCiAgICAgICAgRGVsYXlBY3Rpb24oZnVuY3Rpb24oKSBEb3dubG9hZEZpbGUoVVBEQVRFX1VSTCwgVVBEQVRFX0ZJTEVfUEFUSCwgZnVuY3Rpb24gKCkgQXV0b3VwZGF0ZXJNc2coIlN1Y2Nlc3NmdWxseSB1cGRhdGVkLiAoIi4udmVyc2lvbi4uIiA9PiAiLi5TZXJ2ZXJWZXJzaW9uLi4iKSwgcHJlc3MgRjkgdHdpY2UgdG8gbG9hZCB0aGUgdXBkYXRlZCB2ZXJzaW9uLiIpIGVuZCkgZW5kLCAzKQ0KICAgICAgZWxzZQ0KICAgICAgICBBdXRvdXBkYXRlck1zZygiTG9hZGVkIHRoZSBsYXRlc3QgdmVyc2lvbiAodiIuLlNlcnZlclZlcnNpb24uLiIpIikNCiAgICAgIGVuZA0KICAgIGVuZA0KICBlbHNlDQogICAgQXV0b3VwZGF0ZXJNc2coIkVycm9yIGRvd25sb2FkaW5nIHZlcnNpb24gaW5mbyIpDQogIGVuZA0KZW5kDQotLVtbIEF1dG8gdXBkYXRlciBlbmQgXV0tLQ0KDQotLVtbIExpYnJhcmllcyBzdGFydCBdXS0tDQppZiBGaWxlRXhpc3QoTElCX1BBVEggLi4gIi9WUHJlZGljdGlvbi5sdWEiKSB0aGVuDQogIHJlcXVpcmUoIlZQcmVkaWN0aW9uIikNCiAgVlAgPSBWUHJlZGljdGlvbigpDQplbmQNCmlmIFZJUF9VU0VSIGFuZCBGaWxlRXhpc3QoTElCX1BBVEggLi4gIi9Qcm9kaWN0aW9uLmx1YSIpIHRoZW4NCiAgcmVxdWlyZSgiUHJvZGljdGlvbiIpDQogIHByb2RzdGF0dXMgPSB0cnVlDQplbmQNCmlmIFZJUF9VU0VSIGFuZCBGaWxlRXhpc3QoTElCX1BBVEguLiJEaXZpbmVQcmVkLmx1YSIpIGFuZCBGaWxlRXhpc3QoTElCX1BBVEguLiJEaXZpbmVQcmVkLmx1YWMiKSB0aGVuDQogIHJlcXVpcmUgIkRpdmluZVByZWQiDQogIERQID0gRGl2aW5lUHJlZCgpIA0KZW5kDQotLVtbIExpYnJhcmllcyBlbmQgXV0tLQ0KDQoNCmlmIG5vdCBDaGFtcHNbbXlIZXJvLmNoYXJOYW1lXSB0aGVuIHJldHVybiBlbmQgLS0gbm90IHN1cHBvcnRlZCA6KA0KSG9va1BhY2tldHMoKSAtLSBDcmVkaXRzIHRvIGlDcmVhdGl2ZQ0KbG9jYWwgZGF0YSA9IENoYW1wc1tteUhlcm8uY2hhck5hbWVdDQpsb2NhbCBRUmVhZHksIFdSZWFkeSwgRVJlYWR5LCBSUmVhZHkgPSBuaWwsIG5pbCwgbmlsLCBuaWwNCmxvY2FsIFRhcmdldCANCmxvY2FsIHRzMiA9IFRhcmdldFNlbGVjdG9yKFRBUkdFVF9ORUFSX01PVVNFLCAxNTAwLCBEQU1BR0VfTUFHSUMsIHRydWUpIC0tIG1ha2UgdGhlc2UgbG9jYWwNCmxvY2FsIHN0ciA9IHsgW19RXSA9ICJRIiwgW19XXSA9ICJXIiwgW19FXSA9ICJFIiwgW19SXSA9ICJSIiB9DQotLWxvY2FsIGtleSA9IHsgW19RXSA9ICJZIiwgW19XXSA9ICJYIiwgW19FXSA9ICJDIiwgW19SXSA9ICJWIiB9IHNvb24NCmxvY2FsIENvbmZpZ1R5cGUgPSBTQ1JJUFRfUEFSQU1fT05LRVlET1dODQpsb2NhbCBwcmVkaWN0aW9ucyA9IHt9DQpsb2NhbCB0b0Nhc3QgPSB7ZmFsc2UsIGZhbHNlLCBmYWxzZSwgZmFsc2V9DQpsb2NhbCB0b0FpbSA9IHtmYWxzZSwgZmFsc2UsIGZhbHNlLCBmYWxzZX0NCg0KZnVuY3Rpb24gT25Mb2FkKCkNCg0KICBDb25maWcgPSBzY3JpcHRDb25maWcoIkFpbWJvdCB2Ii4udmVyc2lvbiwgIkFpbWJvdCB2Ii4udmVyc2lvbikNCiAgDQogIA0KICBDb25maWc6YWRkU3ViTWVudSgiW1ByZWRpY3Rpb25dOiBTZXR0aW5ncyIsICJwckNvbmZpZyIpDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicGMiLCAiVXNlIFBhY2tldHMgVG8gQ2FzdCBTcGVsbHMiLCBTQ1JJUFRfUEFSQU1fT05PRkYsIGZhbHNlKQ0KICBDb25maWcucHJDb25maWc6YWRkUGFyYW0oInFxcSIsICItLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSIsIFNDUklQVF9QQVJBTV9JTkZPLCIiKQ0KICBDb25maWcucHJDb25maWc6YWRkUGFyYW0oImhpdGNoYW5jZSIsICJBY2N1cmFjeSIsIFNDUklQVF9QQVJBTV9TTElDRSwgMiwgMCwgMywgMCkNCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJxcXEiLCAiLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0iLCBTQ1JJUFRfUEFSQU1fSU5GTywiIikNCiAgbG9jYWwgcHJlZFRvVXNlID0geyIiLCAiIiwgIiJ9DQogIGlmIEZpbGVFeGlzdChMSUJfUEFUSC4uIlZQcmVkaWN0aW9uLmx1YSIpIHRoZW4gcHJlZFRvVXNlWzFdID0gIlZQcmVkaWN0aW9uIiBlbmQNCiAgaWYgVklQX1VTRVIgdGhlbg0KICAgIGlmIEZpbGVFeGlzdChMSUJfUEFUSC4uIkRpdmluZVByZWQubHVhIikgYW5kIEZpbGVFeGlzdChMSUJfUEFUSC4uIkRpdmluZVByZWQubHVhYyIpIHRoZW4gcHJlZFRvVXNlWzNdID0gIkRpdmluZVByZWQiIGVuZA0KICAgIGlmIHByb2RzdGF0dXMgdGhlbiBwcmVkVG9Vc2VbMl0gPSAiUHJvZGljdGlvbiIgZW5kDQogIGVuZA0KICBpZiBwcmVkVG9Vc2UgPT0geyIiLCAiIiwgIiJ9IHRoZW4gUHJpbnRDaGF0KCJQTEVBU0UgRE9XTkxPQUQgQSBQUkVESUNUSU9OISIpIHJldHVybiBlbmQNCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJwcm8iLCAgIlR5cGUgb2YgcHJlZGljdGlvbiIsIFNDUklQVF9QQVJBTV9MSVNULCAxLCBwcmVkVG9Vc2UpDQoNCg0KICBDb25maWc6YWRkU3ViTWVudSgiU3VwcG9ydGVkIHNraWxscyIsICJza0NvbmZpZyIpDQogIGZvciBpLCBzcGVsbCBpbiBwYWlycyhkYXRhKSBkbw0KICAgIENvbmZpZy5za0NvbmZpZzphZGRQYXJhbShzdHJbaV0sICIiLCBDb25maWdUeXBlLCBmYWxzZSwgc3RyaW5nLmJ5dGUoc3RyW2ldKSkNCiAgICBwcmVkaWN0aW9uc1tzdHJbaV1dID0ge3NwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBpfQ0KICAgIHRvQWltW2ldID0gdHJ1ZQ0KICBlbmQNCiAgDQogIC0tQ29uZmlnOmFkZFN1Yk1lbnUoIkFkZGl0aW9uYWwga2V5cyIsICJrQ29uZmlnIikNCiAgLS1mb3IgaSwgc3BlbGwgaW4gcGFpcnMoZGF0YSkgZG8NCiAgLS0gIENvbmZpZy5rQ29uZmlnOmFkZFBhcmFtKGtleVtpXSwgIkFpbSAiLi5zdHJbaV0sIENvbmZpZ1R5cGUsIGZhbHNlLCBzdHJpbmcuYnl0ZShrZXlbaV0pKQ0KICAtLWVuZCBzb29uDQogIA0KICANCiAgQ29uZmlnOmFkZFRTKHRzMikNCiAgQ29uZmlnOmFkZFBhcmFtKCJ0b2ciLCAiQWltYm90IG9uL29mZiIsIFNDUklQVF9QQVJBTV9PTktFWVRPR0dMRSwgdHJ1ZSwgc3RyaW5nLmJ5dGUoIlQiKSkNCiAgQ29uZmlnOmFkZFBhcmFtKCJyYW5nZW9mZnNldCIsICJSYW5nZSBEZWNyZWFzZSBPZmZzZXQiLCBTQ1JJUFRfUEFSQU1fU0xJQ0UsIDAsIDAsIDIwMCwgMCkNCiAgDQogIENvbmZpZzpwZXJtYVNob3coInRvZyIpDQogIHRzMi5uYW1lID0gIlRhcmdldCINCmVuZA0KDQpmdW5jdGlvbiBPblRpY2soKQ0KICBpZiBDb25maWcudG9nIHRoZW4NCiAgICAgIFRhcmdldCA9IEdldEN1c3RvbVRhcmdldCgpDQogICAgICBpZiBUYXJnZXQgPT0gbmlsIHRoZW4gcmV0dXJuIGVuZA0KICAgICAgZm9yIGksIHNwZWxsIGluIHBhaXJzKGRhdGEpIGRvDQogICAgICAgICAgaWYgdG9DYXN0W2ldID09IHRydWUgYW5kIG15SGVybzpDYW5Vc2VTcGVsbChpKSB0aGVuDQogICAgICAgICAgICBpZiBDb25maWcucHJDb25maWcucHJvID09IDEgdGhlbiAtLSBWUHJlZGljdGlvbg0KICAgICAgICAgICAgICBpZiBzcGVsbC50eXBlID09ICJsaW5lYXIiIHRoZW4NCiAgICAgICAgICAgICAgICBpZiBzcGVsbC5hb2UgdGhlbg0KICAgICAgICAgICAgICAgICAgICBsb2NhbCBDYXN0UG9zaXRpb24sIEhpdENoYW5jZSwgUG9zaXRpb24gPSBWUDpHZXRMaW5lQU9FQ2FzdFBvc2l0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybykNCiAgICAgICAgICAgICAgICBlbHNlDQogICAgICAgICAgICAgICAgICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IFZQOkdldExpbmVDYXN0UG9zaXRpb24oVGFyZ2V0LCBzcGVsbC5kZWxheSwgc3BlbGwud2lkdGgsIHNwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgbXlIZXJvLCBzcGVsbC5jb2xsaXNpb24pDQogICAgICAgICAgICAgICAgZW5kDQogICAgICAgICAgICAgIGVsc2VpZiBzcGVsbC50eXBlID09ICJjaXJjdWxhciIgdGhlbg0KICAgICAgICAgICAgICAgIGlmIHNwZWxsLmFvZSB0aGVuDQogICAgICAgICAgICAgICAgICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IFZQOkdldENpcmN1bGFyQU9FQ2FzdFBvc2l0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybykNCiAgICAgICAgICAgICAgICBlbHNlDQogICAgICAgICAgICAgICAgICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IFZQOkdldENpcmN1bGFyQ2FzdFBvc2l0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybywgc3BlbGwuY29sbGlzaW9uKQ0KICAgICAgICAgICAgICAgIGVuZA0KICAgICAgICAgICAgICBlbHNlaWYgc3BlbGwudHlwZSA9PSAiY29uZSIgdGhlbg0KICAgICAgICAgICAgICAgIGlmIHNwZWxsLmFvZSB0aGVuDQogICAgICAgICAgICAgICAgICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IFZQOkdldENvbmVBT0VDYXN0UG9zaXRpb24oVGFyZ2V0LCBzcGVsbC5kZWxheSwgc3BlbGwud2lkdGgsIHNwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgbXlIZXJvKQ0KICAgICAgICAgICAgICAgIGVsc2UNCiAgICAgICAgICAgICAgICAgICAgbG9jYWwgQ2FzdFBvc2l0aW9uLCBIaXRDaGFuY2UsIFBvc2l0aW9uID0gVlA6R2V0TGluZUNhc3RQb3NpdGlvbihUYXJnZXQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgc3BlbGwucmFuZ2UsIHNwZWxsLnNwZWVkLCBteUhlcm8sIHNwZWxsLmNvbGxpc2lvbikNCiAgICAgICAgICAgICAgICBlbmQNCiAgICAgICAgICAgICAgZW5kDQogICAgICAgICAgICAgIGlmIEhpdENoYW5jZSA+PSBDb25maWcucHJDb25maWcuaGl0Y2hhbmNlIHRoZW4NCiAgICAgICAgICAgICAgICAgIENDYXN0U3BlbGwoaSwgQ2FzdFBvc2l0aW9uLngsIENhc3RQb3NpdGlvbi56KQ0KICAgICAgICAgICAgICBlbHNlaWYgSGl0Q2hhbmNlID49IENvbmZpZy5wckNvbmZpZy5oaXRjaGFuY2UtMSB0aGVuDQogICAgICAgICAgICAgICAgICBDQ2FzdFNwZWxsKGksIENhc3RQb3NpdGlvbi54LCBDYXN0UG9zaXRpb24ueikNCiAgICAgICAgICAgICAgZWxzZQ0KICAgICAgICAgICAgICAgICAgQ0Nhc3RTcGVsbChpLCBtb3VzZVBvcy54LCBtb3VzZVBvcy56KQ0KICAgICAgICAgICAgICBlbmQgdG9DYXN0W2ldID0gZmFsc2UNCiAgICAgICAgICAgIGVsc2VpZiBDb25maWcucHJDb25maWcucHJvID09IDIgYW5kIFZJUF9VU0VSIGFuZCBwcm9kc3RhdHVzIHRoZW4gLS0gUHJvZGljdGlvbg0KICAgICAgICAgICAgICBsb2NhbCBQb3NpdGlvbiwgaW5mbyA9IFByb2RpY3Rpb24uR2V0UHJlZGljdGlvbihUYXJnZXQsIHNwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBteUhlcm8pDQogICAgICAgICAgICAgIGlmIFBvc2l0aW9uIH49IG5pbCBhbmQgbm90IGluZm8ubUNvbGxpc2lvbigpIHRoZW4NCiAgICAgICAgICAgICAgICAgIENDYXN0U3BlbGwoaSwgUG9zaXRpb24ueCwgUG9zaXRpb24ueikNCiAgICAgICAgICAgICAgZWxzZQ0KICAgICAgICAgICAgICAgICAgQ0Nhc3RTcGVsbChpLCBtb3VzZVBvcy54LCBtb3VzZVBvcy56KQ0KICAgICAgICAgICAgICBlbmQgdG9DYXN0W2ldID0gZmFsc2UNCiAgICAgICAgICAgIGVsc2VpZiBDb25maWcucHJDb25maWcucHJvID09IDMgYW5kIFZJUF9VU0VSIHRoZW4gLS0gRGl2aW5lUHJlZGljdGlvbg0KICAgICAgICAgICAgICBsb2NhbCB1bml0ID0gRFBUYXJnZXQoVGFyZ2V0KQ0KICAgICAgICAgICAgICBsb2NhbCBjb2wgPSBzcGVsbC5jb2xsaXNpb24gYW5kIDAgb3IgbWF0aC5odWdlDQogICAgICAgICAgICAgIGlmIElzVmVpZ2FyTHV4KGkpIHRoZW4gY29sID0gMSBlbmQNCiAgICAgICAgICAgICAgaWYgc3BlbGwudHlwZSA9PSAibGluZWFyIiB0aGVuDQogICAgICAgICAgICAgICAgU3BlbGwgPSBMaW5lU1Moc3BlbGwuc3BlZWQsIHNwZWxsLnJhbmdlLCBzcGVsbC53aWR0aCwgc3BlbGwuZGVsYXkgKiAxMDAwLCBjb2wpDQogICAgICAgICAgICAgIGVsc2VpZiBzcGVsbC50eXBlID09ICJjaXJjdWxhciIgdGhlbg0KICAgICAgICAgICAgICAgIFNwZWxsID0gQ2lyY2xlU1Moc3BlbGwuc3BlZWQsIHNwZWxsLnJhbmdlLCBzcGVsbC53aWR0aCwgc3BlbGwuZGVsYXkgKiAxMDAwLCBjb2wpDQogICAgICAgICAgICAgIGVsc2VpZiBzcGVsbC50eXBlID09ICJjb25lIiB0aGVuDQogICAgICAgICAgICAgICAgU3BlbGwgPSBDb25lU1Moc3BlbGwuc3BlZWQsIHNwZWxsLnJhbmdlLCBzcGVsbC53aWR0aCwgc3BlbGwuZGVsYXkgKiAxMDAwLCBjb2wpDQogICAgICAgICAgICAgIGVuZA0KICAgICAgICAgICAgICBsb2NhbCBTdGF0ZSwgUG9zaXRpb24sIHBlcmMgPSBEUDpwcmVkaWN0KHVuaXQsIFNwZWxsLCAyKQ0KICAgICAgICAgICAgICBpZiBTdGF0ZSA9PSBTa2lsbFNob3QuU1RBVFVTLlNVQ0NFU1NfSElUIHRoZW4gDQogICAgICAgICAgICAgICAgICBDQ2FzdFNwZWxsKGksIFBvc2l0aW9uLngsIFBvc2l0aW9uLnopDQogICAgICAgICAgICAgIGVsc2UNCiAgICAgICAgICAgICAgICAgIENDYXN0U3BlbGwoaSwgbW91c2VQb3MueCwgbW91c2VQb3MueikNCiAgICAgICAgICAgICAgZW5kIHRvQ2FzdFtpXSA9IGZhbHNlDQogICAgICAgICAgICBlbmQNCiAgICAgICAgICBlbmQNCiAgICAgIGVuZCANCiAgZW5kDQplbmQgICANCiAgICAgICAgICAtLSBOT1cgREVQUkVDQVRFRCEgVE9ETzogcmVtb3ZlLi4NCiAgICAgICAgICAtLWlmIChDb25maWcudGhyb3cgb3IgQ29uZmlnW3N0cltpXV0gb3IgQ29uZmlnW2tleVtpXV0pIGFuZCBteUhlcm86Q2FuVXNlU3BlbGwoaSkgYW5kIElzTGVlVGhyZXNoKCkgdGhlbiAtLSBtb3ZlIHNwZWxsIHJlYWR5IGNoZWNrIHRvIHRvcA0KICAgICAgICAgIC0tICAgIHRvQ2FzdFtpXSA9IHRydWUNCiAgICAgICAgICAtLSAgICBpZiBIaXRDaGFuY2UgPj0gQ29uZmlnLnByQ29uZmlnLmhpdGNoYW5jZSBhbmQgR2V0RGlzdGFuY2UoQ2FzdFBvc2l0aW9uLCBteUhlcm8pIDwgc3BlbGwucmFuZ2UgLSBDb25maWcucmFuZ2VvZmZzZXQgdGhlbiBDQ2FzdFNwZWxsKGksIENhc3RQb3NpdGlvbi54LCBDYXN0UG9zaXRpb24ueikgDQogICAgICAgICAgLS0gICAgdG9DYXN0W2ldID0gZmFsc2UgZW5kICAgDQogICAgICAgICAgLS1lbHNlDQogICAgICAgICAgLS0gICAgbG9jYWwgQ2FzdFBvc2l0aW9uLCBIaXRDaGFuY2UsIFBvc2l0aW9uID0gcHJlZGljdGlvbjpHZXRQcmVkaWN0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybywgc3BlbGwudHlwZSwgc3BlbGwuY29sbGlzaW9uLCBzcGVsbC5hb2UpDQogICAgICAgICAgLS0gICAgaWYgSGl0Q2hhbmNlID49IENvbmZpZy5wckNvbmZpZy5oaXRjaGFuY2UgYW5kIEdldERpc3RhbmNlKENhc3RQb3NpdGlvbiwgbXlIZXJvKSA8IHNwZWxsLnJhbmdlIC0gQ29uZmlnLnJhbmdlb2Zmc2V0IHRoZW4gQ0Nhc3RTcGVsbChpLCBDYXN0UG9zaXRpb24ueCwgQ2FzdFBvc2l0aW9uLnopDQogICAgICAgICAgLS0gICAgZWxzZWlmIEhpdENoYW5jZSA+PSBDb25maWcucHJDb25maWcuaGl0Y2hhbmNlLTEgYW5kIEdldERpc3RhbmNlKENhc3RQb3NpdGlvbiwgbXlIZXJvKSA8IHNwZWxsLnJhbmdlIC0gQ29uZmlnLnJhbmdlb2Zmc2V0IHRoZW4gQ0Nhc3RTcGVsbChpLCBDYXN0UG9zaXRpb24ueCwgQ2FzdFBvc2l0aW9uLnopIA0KICAgICAgICAgIC0tICAgIGVsc2UgQ0Nhc3RTcGVsbChpLCBtb3VzZVBvcy54LCBtb3VzZVBvcy56KSBlbmQNCiAgICAgICAgICAgICAgLS10b0Nhc3RbaV0gPSBmYWxzZSANCg0KZnVuY3Rpb24gT25XbmRNc2cobXNnLCBrZXkpDQogICBpZiBtc2cgPT0gS0VZX1VQIGFuZCBrZXkgPT0gR2V0S2V5KCJRIikgYW5kIHRvQWltWzBdIHRoZW4NCiAgICAgdG9DYXN0WzBdID0gZmFsc2UNCiAgIGVsc2VpZiBtc2cgPT0gS0VZX1VQIGFuZCBrZXkgPT0gR2V0S2V5KCJXIikgYW5kIHRvQWltWzFdIHRoZW4gDQogICAgIHRvQ2FzdFsxXSA9IGZhbHNlDQogICBlbHNlaWYgbXNnID09IEtFWV9VUCBhbmQga2V5ID09IEdldEtleSgiRSIpIGFuZCB0b0FpbVsyXSB0aGVuIA0KICAgICB0b0Nhc3RbMl0gPSBmYWxzZQ0KICAgZWxzZWlmIG1zZyA9PSBLRVlfVVAgYW5kIGtleSA9PSBHZXRLZXkoIlIiKSBhbmQgdG9BaW1bM10gdGhlbg0KICAgICB0b0Nhc3RbM10gPSBmYWxzZQ0KICAgZW5kDQplbmQNCg0KZnVuY3Rpb24gSXNWZWlnYXJMdXgoaSkNCiAgaWYgbXlIZXJvLmNoYXJOYW1lID09ICdMdXgnIHRoZW4NCiAgICBpZiBpID09IDEgdGhlbg0KICAgICAgcmV0dXJuIHRydWUNCiAgICBlbHNlDQogICAgICByZXR1cm4gZmFsc2UNCiAgICBlbmQNCiAgZWxzZWlmIG15SGVyby5jaGFyTmFtZSA9PSAnVmVpZ2FyJyB0aGVuDQogICAgaWYgaSA9PSAxIHRoZW4NCiAgICAgIHJldHVybiB0cnVlDQogICAgZWxzZQ0KICAgICAgcmV0dXJuIGZhbHNlDQogICAgZW5kIA0KICBlbHNlDQogICAgcmV0dXJuIGZhbHNlDQogIGVuZA0KZW5kDQoNCmZ1bmN0aW9uIE9uU2VuZFBhY2tldChwKQ0KICBUYXJnZXQgPSBHZXRDdXN0b21UYXJnZXQoKQ0KICBpZiBDb25maWcudG9nIHRoZW4NCiAgICBpZiBwLmhlYWRlciA9PSAweDAwRTkgdGhlbiAtLSBDcmVkaXRzIHRvIFBld1Bld1Bldw0KICAgICAgcC5wb3M9MjcNCiAgICAgIGxvY2FsIG9wYyA9IHA6RGVjb2RlMSgpDQogICAgICBpZiBUYXJnZXQgfj0gbmlsIHRoZW4NCiAgICAgICAgaWYgb3BjID09IDB4MDIgYW5kIG5vdCB0b0Nhc3RbMF0gYW5kIHRvQWltWzBdIHRoZW4gDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzBdID0gdHJ1ZQ0KICAgICAgICBlbHNlaWYgb3BjID09IDB4RDggYW5kIG5vdCB0b0Nhc3RbMV0gYW5kIHRvQWltWzFdIHRoZW4gDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzFdID0gdHJ1ZQ0KICAgICAgICBlbHNlaWYgb3BjID09IDB4QjMgYW5kIG5vdCB0b0Nhc3RbMl0gYW5kIHRvQWltWzJdIHRoZW4gDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzJdID0gdHJ1ZQ0KICAgICAgICBlbHNlaWYgb3BjID09IDB4RTcgYW5kIG5vdCB0b0Nhc3RbM10gYW5kIHRvQWltWzNdIHRoZW4NCiAgICAgICAgICBwOkJsb2NrKCkNCiAgICAgICAgICBwLnNraXAocCwgMSkNCiAgICAgICAgICB0b0Nhc3RbM10gPSB0cnVlDQogICAgICAgIGVuZA0KICAgICAgZW5kDQogICAgZW5kDQogIGVuZA0KZW5kDQoNCi0tQ3JlZGl0IFRyZWVzDQpmdW5jdGlvbiBHZXRDdXN0b21UYXJnZXQoKQ0KICAgIHRzMjp1cGRhdGUoKQ0KICAgIGlmIF9HLk1NQV9UYXJnZXQgYW5kIF9HLk1NQV9UYXJnZXQudHlwZSA9PSBteUhlcm8udHlwZSB0aGVuIHJldHVybiBfRy5NTUFfVGFyZ2V0IGVuZA0KICAgIGlmIF9HLkF1dG9DYXJyeSBhbmQgX0cuQXV0b0NhcnJ5LkNyb3NzaGFpciBhbmQgX0cuQXV0b0NhcnJ5LkF0dGFja19Dcm9zc2hhaXIgYW5kIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyLnRhcmdldCBhbmQgX0cuQXV0b0NhcnJ5LkF0dGFja19Dcm9zc2hhaXIudGFyZ2V0LnR5cGUgPT0gbXlIZXJvLnR5cGUgdGhlbiByZXR1cm4gX0cuQXV0b0NhcnJ5LkF0dGFja19Dcm9zc2hhaXIudGFyZ2V0IGVuZA0KICAgIC0tcHJpbnQoJ3RzdGFyZ2V0IGNhbGxlZCcpDQogICAgcmV0dXJuIHRzMi50YXJnZXQNCmVuZA0KLS1FbmQgQ3JlZGl0IFRyZWVzDQoNCi0tW1sgUGFja2V0IENhc3QgSGVscGVyIF1dLS0NCmZ1bmN0aW9uIENDYXN0U3BlbGwoU3BlbGwsIHhQb3MsIHpQb3MpDQogIGlmIFZJUF9VU0VSIGFuZCBDb25maWcucHJDb25maWcucGMgdGhlbg0KICAgIFBhY2tldCgiU19DQVNUIiwge3NwZWxsSWQgPSBTcGVsbCwgZnJvbVggPSB4UG9zLCBmcm9tWSA9IHpQb3MsIHRvWCA9IHhQb3MsIHRvWSA9IHpQb3N9KTpzZW5kKCkNCiAgZWxzZQ0KICAgIENhc3RTcGVsbChTcGVsbCwgeFBvcywgelBvcykNCiAgZW5kDQplbmQ="), nil, "bt", _ENV))()