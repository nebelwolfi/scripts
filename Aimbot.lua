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

assert(load(Base64Decode("LS1bWyBMaWJyYXJpZXMgc3RhcnQgYW5kIEVuY3J5cHRpb24gc3RhcnQgXV0tLQ0KaWYgRmlsZUV4aXN0KExJQl9QQVRIIC4uICIvVlByZWRpY3Rpb24ubHVhIikgdGhlbg0KICByZXF1aXJlKCJWUHJlZGljdGlvbiIpDQogIFZQID0gVlByZWRpY3Rpb24oKQ0KZW5kDQppZiBWSVBfVVNFUiBhbmQgRmlsZUV4aXN0KExJQl9QQVRIIC4uICIvUHJvZGljdGlvbi5sdWEiKSB0aGVuDQogIHJlcXVpcmUoIlByb2RpY3Rpb24iKQ0KICBwcm9kc3RhdHVzID0gdHJ1ZQ0KZW5kDQppZiBWSVBfVVNFUiBhbmQgRmlsZUV4aXN0KExJQl9QQVRILi4iRGl2aW5lUHJlZC5sdWEiKSBhbmQgRmlsZUV4aXN0KExJQl9QQVRILi4iRGl2aW5lUHJlZC5sdWFjIikgdGhlbg0KICByZXF1aXJlICJEaXZpbmVQcmVkIg0KICBEUCA9IERpdmluZVByZWQoKSANCmVuZA0KLS1bWyBMaWJyYXJpZXMgZW5kIF1dLS0NCg0KaWYgbm90IENoYW1wc1tteUhlcm8uY2hhck5hbWVdIHRoZW4gcmV0dXJuIGVuZCAtLSBub3Qgc3VwcG9ydGVkIDooDQpIb29rUGFja2V0cygpIC0tIENyZWRpdHMgdG8gaUNyZWF0aXZlDQpsb2NhbCBkYXRhID0gQ2hhbXBzW215SGVyby5jaGFyTmFtZV0NCmxvY2FsIFFSZWFkeSwgV1JlYWR5LCBFUmVhZHksIFJSZWFkeSA9IG5pbCwgbmlsLCBuaWwsIG5pbA0KbG9jYWwgVGFyZ2V0IA0KbG9jYWwgdHMyID0gVGFyZ2V0U2VsZWN0b3IoVEFSR0VUX05FQVJfTU9VU0UsIDE1MDAsIERBTUFHRV9NQUdJQywgdHJ1ZSkgLS0gbWFrZSB0aGVzZSBsb2NhbA0KbG9jYWwgc3RyID0geyBbX1FdID0gIlEiLCBbX1ddID0gIlciLCBbX0VdID0gIkUiLCBbX1JdID0gIlIiIH0NCi0tbG9jYWwga2V5ID0geyBbX1FdID0gIlkiLCBbX1ddID0gIlgiLCBbX0VdID0gIkMiLCBbX1JdID0gIlYiIH0gc29vbg0KbG9jYWwgQ29uZmlnVHlwZSA9IFNDUklQVF9QQVJBTV9PTktFWURPV04NCmxvY2FsIHByZWRpY3Rpb25zID0ge30NCmxvY2FsIHRvQ2FzdCA9IHtmYWxzZSwgZmFsc2UsIGZhbHNlLCBmYWxzZX0NCmxvY2FsIHRvQWltID0ge2ZhbHNlLCBmYWxzZSwgZmFsc2UsIGZhbHNlfQ0KDQpmdW5jdGlvbiBPbkxvYWQoKQ0KDQogIENvbmZpZyA9IHNjcmlwdENvbmZpZygiQWltYm90IiwgIkFpbWJvdCIpDQogIA0KICANCiAgQ29uZmlnOmFkZFN1Yk1lbnUoIltQcmVkaWN0aW9uXTogU2V0dGluZ3MiLCAicHJDb25maWciKQ0KICBDb25maWcucHJDb25maWc6YWRkUGFyYW0oInBjIiwgIlVzZSBQYWNrZXRzIFRvIENhc3QgU3BlbGxzIiwgU0NSSVBUX1BBUkFNX09OT0ZGLCBmYWxzZSkNCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJxcXEiLCAiLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0iLCBTQ1JJUFRfUEFSQU1fSU5GTywiIikNCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJoaXRjaGFuY2UiLCAiQWNjdXJhY3kiLCBTQ1JJUFRfUEFSQU1fU0xJQ0UsIDIsIDAsIDMsIDApDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicXFxIiwgIi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tIiwgU0NSSVBUX1BBUkFNX0lORk8sIiIpDQogIGxvY2FsIHByZWRUb1VzZSA9IHsiIiwgIiIsICIifQ0KICBpZiBGaWxlRXhpc3QoTElCX1BBVEguLiJWUHJlZGljdGlvbi5sdWEiKSB0aGVuIHByZWRUb1VzZVsxXSA9ICJWUHJlZGljdGlvbiIgZW5kDQogIGlmIFZJUF9VU0VSIHRoZW4NCiAgICBpZiBGaWxlRXhpc3QoTElCX1BBVEguLiJEaXZpbmVQcmVkLmx1YSIpIGFuZCBGaWxlRXhpc3QoTElCX1BBVEguLiJEaXZpbmVQcmVkLmx1YWMiKSB0aGVuIHByZWRUb1VzZVszXSA9ICJEaXZpbmVQcmVkIiBlbmQNCiAgICBpZiBwcm9kc3RhdHVzIHRoZW4gcHJlZFRvVXNlWzJdID0gIlByb2RpY3Rpb24iIGVuZA0KICBlbmQNCiAgaWYgcHJlZFRvVXNlID09IHsiIiwgIiIsICIifSB0aGVuIFByaW50Q2hhdCgiUExFQVNFIERPV05MT0FEIEEgUFJFRElDVElPTiEiKSByZXR1cm4gZW5kDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicHJvIiwgICJUeXBlIG9mIHByZWRpY3Rpb24iLCBTQ1JJUFRfUEFSQU1fTElTVCwgMSwgcHJlZFRvVXNlKQ0KDQoNCiAgQ29uZmlnOmFkZFN1Yk1lbnUoIlN1cHBvcnRlZCBza2lsbHMiLCAic2tDb25maWciKQ0KICBmb3IgaSwgc3BlbGwgaW4gcGFpcnMoZGF0YSkgZG8NCiAgICBDb25maWcuc2tDb25maWc6YWRkUGFyYW0oc3RyW2ldLCAiIiwgQ29uZmlnVHlwZSwgZmFsc2UsIHN0cmluZy5ieXRlKHN0cltpXSkpDQogICAgcHJlZGljdGlvbnNbc3RyW2ldXSA9IHtzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgaX0NCiAgICB0b0FpbVtpXSA9IHRydWUNCiAgZW5kDQogIA0KICAtLUNvbmZpZzphZGRTdWJNZW51KCJBZGRpdGlvbmFsIGtleXMiLCAia0NvbmZpZyIpDQogIC0tZm9yIGksIHNwZWxsIGluIHBhaXJzKGRhdGEpIGRvDQogIC0tICBDb25maWcua0NvbmZpZzphZGRQYXJhbShrZXlbaV0sICJBaW0gIi4uc3RyW2ldLCBDb25maWdUeXBlLCBmYWxzZSwgc3RyaW5nLmJ5dGUoa2V5W2ldKSkNCiAgLS1lbmQgc29vbg0KICANCiAgDQogIENvbmZpZzphZGRUUyh0czIpDQogIENvbmZpZzphZGRQYXJhbSgidG9nIiwgIkFpbWJvdCBvbi9vZmYiLCBTQ1JJUFRfUEFSQU1fT05LRVlUT0dHTEUsIHRydWUsIHN0cmluZy5ieXRlKCJUIikpDQogIENvbmZpZzphZGRQYXJhbSgicmFuZ2VvZmZzZXQiLCAiUmFuZ2UgRGVjcmVhc2UgT2Zmc2V0IiwgU0NSSVBUX1BBUkFNX1NMSUNFLCAwLCAwLCAyMDAsIDApDQogIA0KICBDb25maWc6cGVybWFTaG93KCJ0b2ciKQ0KICB0czIubmFtZSA9ICJUYXJnZXQiDQplbmQNCg0KZnVuY3Rpb24gT25UaWNrKCkNCiAgaWYgQ29uZmlnLnRvZyB0aGVuDQogICAgICBUYXJnZXQgPSBHZXRDdXN0b21UYXJnZXQoKQ0KICAgICAgaWYgVGFyZ2V0ID09IG5pbCB0aGVuIHJldHVybiBlbmQNCiAgICAgIGZvciBpLCBzcGVsbCBpbiBwYWlycyhkYXRhKSBkbw0KICAgICAgICAgIGlmIHRvQ2FzdFtpXSA9PSB0cnVlIGFuZCBteUhlcm86Q2FuVXNlU3BlbGwoaSkgdGhlbg0KICAgICAgICAgICAgaWYgQ29uZmlnLnByQ29uZmlnLnBybyA9PSAxIHRoZW4gLS0gVlByZWRpY3Rpb24NCiAgICAgICAgICAgICAgaWYgc3BlbGwudHlwZSA9PSAibGluZWFyIiB0aGVuDQogICAgICAgICAgICAgICAgaWYgc3BlbGwuYW9lIHRoZW4NCiAgICAgICAgICAgICAgICAgICAgbG9jYWwgQ2FzdFBvc2l0aW9uLCBIaXRDaGFuY2UsIFBvc2l0aW9uID0gVlA6R2V0TGluZUFPRUNhc3RQb3NpdGlvbihUYXJnZXQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgc3BlbGwucmFuZ2UsIHNwZWxsLnNwZWVkLCBteUhlcm8pDQogICAgICAgICAgICAgICAgZWxzZQ0KICAgICAgICAgICAgICAgICAgICBsb2NhbCBDYXN0UG9zaXRpb24sIEhpdENoYW5jZSwgUG9zaXRpb24gPSBWUDpHZXRMaW5lQ2FzdFBvc2l0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybywgc3BlbGwuY29sbGlzaW9uKQ0KICAgICAgICAgICAgICAgIGVuZA0KICAgICAgICAgICAgICBlbHNlaWYgc3BlbGwudHlwZSA9PSAiY2lyY3VsYXIiIHRoZW4NCiAgICAgICAgICAgICAgICBpZiBzcGVsbC5hb2UgdGhlbg0KICAgICAgICAgICAgICAgICAgICBsb2NhbCBDYXN0UG9zaXRpb24sIEhpdENoYW5jZSwgUG9zaXRpb24gPSBWUDpHZXRDaXJjdWxhckFPRUNhc3RQb3NpdGlvbihUYXJnZXQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgc3BlbGwucmFuZ2UsIHNwZWxsLnNwZWVkLCBteUhlcm8pDQogICAgICAgICAgICAgICAgZWxzZQ0KICAgICAgICAgICAgICAgICAgICBsb2NhbCBDYXN0UG9zaXRpb24sIEhpdENoYW5jZSwgUG9zaXRpb24gPSBWUDpHZXRDaXJjdWxhckNhc3RQb3NpdGlvbihUYXJnZXQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgc3BlbGwucmFuZ2UsIHNwZWxsLnNwZWVkLCBteUhlcm8sIHNwZWxsLmNvbGxpc2lvbikNCiAgICAgICAgICAgICAgICBlbmQNCiAgICAgICAgICAgICAgZWxzZWlmIHNwZWxsLnR5cGUgPT0gImNvbmUiIHRoZW4NCiAgICAgICAgICAgICAgICBpZiBzcGVsbC5hb2UgdGhlbg0KICAgICAgICAgICAgICAgICAgICBsb2NhbCBDYXN0UG9zaXRpb24sIEhpdENoYW5jZSwgUG9zaXRpb24gPSBWUDpHZXRDb25lQU9FQ2FzdFBvc2l0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLndpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybykNCiAgICAgICAgICAgICAgICBlbHNlDQogICAgICAgICAgICAgICAgICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IFZQOkdldExpbmVDYXN0UG9zaXRpb24oVGFyZ2V0LCBzcGVsbC5kZWxheSwgc3BlbGwud2lkdGgsIHNwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgbXlIZXJvLCBzcGVsbC5jb2xsaXNpb24pDQogICAgICAgICAgICAgICAgZW5kDQogICAgICAgICAgICAgIGVuZA0KICAgICAgICAgICAgICBpZiBIaXRDaGFuY2UgPj0gQ29uZmlnLnByQ29uZmlnLmhpdGNoYW5jZSB0aGVuDQogICAgICAgICAgICAgICAgICBDQ2FzdFNwZWxsKGksIENhc3RQb3NpdGlvbi54LCBDYXN0UG9zaXRpb24ueikNCiAgICAgICAgICAgICAgZWxzZWlmIEhpdENoYW5jZSA+PSBDb25maWcucHJDb25maWcuaGl0Y2hhbmNlLTEgdGhlbg0KICAgICAgICAgICAgICAgICAgQ0Nhc3RTcGVsbChpLCBDYXN0UG9zaXRpb24ueCwgQ2FzdFBvc2l0aW9uLnopDQogICAgICAgICAgICAgIGVsc2UNCiAgICAgICAgICAgICAgICAgIENDYXN0U3BlbGwoaSwgbW91c2VQb3MueCwgbW91c2VQb3MueikNCiAgICAgICAgICAgICAgZW5kIHRvQ2FzdFtpXSA9IGZhbHNlDQogICAgICAgICAgICBlbHNlaWYgQ29uZmlnLnByQ29uZmlnLnBybyA9PSAyIGFuZCBWSVBfVVNFUiBhbmQgcHJvZHN0YXR1cyB0aGVuIC0tIFByb2RpY3Rpb24NCiAgICAgICAgICAgICAgbG9jYWwgUG9zaXRpb24sIGluZm8gPSBQcm9kaWN0aW9uLkdldFByZWRpY3Rpb24oVGFyZ2V0LCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgbXlIZXJvKQ0KICAgICAgICAgICAgICBpZiBQb3NpdGlvbiB+PSBuaWwgYW5kIG5vdCBpbmZvLm1Db2xsaXNpb24oKSB0aGVuDQogICAgICAgICAgICAgICAgICBDQ2FzdFNwZWxsKGksIFBvc2l0aW9uLngsIFBvc2l0aW9uLnopDQogICAgICAgICAgICAgIGVsc2UNCiAgICAgICAgICAgICAgICAgIENDYXN0U3BlbGwoaSwgbW91c2VQb3MueCwgbW91c2VQb3MueikNCiAgICAgICAgICAgICAgZW5kIHRvQ2FzdFtpXSA9IGZhbHNlDQogICAgICAgICAgICBlbHNlaWYgQ29uZmlnLnByQ29uZmlnLnBybyA9PSAzIGFuZCBWSVBfVVNFUiB0aGVuIC0tIERpdmluZVByZWRpY3Rpb24NCiAgICAgICAgICAgICAgbG9jYWwgdW5pdCA9IERQVGFyZ2V0KFRhcmdldCkNCiAgICAgICAgICAgICAgbG9jYWwgY29sID0gc3BlbGwuY29sbGlzaW9uIGFuZCAwIG9yIG1hdGguaHVnZQ0KICAgICAgICAgICAgICBpZiBJc1ZlaWdhckx1eChpKSB0aGVuIGNvbCA9IDEgZW5kDQogICAgICAgICAgICAgIGlmIHNwZWxsLnR5cGUgPT0gImxpbmVhciIgdGhlbg0KICAgICAgICAgICAgICAgIFNwZWxsID0gTGluZVNTKHNwZWxsLnNwZWVkLCBzcGVsbC5yYW5nZSwgc3BlbGwud2lkdGgsIHNwZWxsLmRlbGF5ICogMTAwMCwgY29sKQ0KICAgICAgICAgICAgICBlbHNlaWYgc3BlbGwudHlwZSA9PSAiY2lyY3VsYXIiIHRoZW4NCiAgICAgICAgICAgICAgICBTcGVsbCA9IENpcmNsZVNTKHNwZWxsLnNwZWVkLCBzcGVsbC5yYW5nZSwgc3BlbGwud2lkdGgsIHNwZWxsLmRlbGF5ICogMTAwMCwgY29sKQ0KICAgICAgICAgICAgICBlbHNlaWYgc3BlbGwudHlwZSA9PSAiY29uZSIgdGhlbg0KICAgICAgICAgICAgICAgIFNwZWxsID0gQ29uZVNTKHNwZWxsLnNwZWVkLCBzcGVsbC5yYW5nZSwgc3BlbGwud2lkdGgsIHNwZWxsLmRlbGF5ICogMTAwMCwgY29sKQ0KICAgICAgICAgICAgICBlbmQNCiAgICAgICAgICAgICAgbG9jYWwgU3RhdGUsIFBvc2l0aW9uLCBwZXJjID0gRFA6cHJlZGljdCh1bml0LCBTcGVsbCwgMikNCiAgICAgICAgICAgICAgaWYgU3RhdGUgPT0gU2tpbGxTaG90LlNUQVRVUy5TVUNDRVNTX0hJVCB0aGVuIA0KICAgICAgICAgICAgICAgICAgQ0Nhc3RTcGVsbChpLCBQb3NpdGlvbi54LCBQb3NpdGlvbi56KQ0KICAgICAgICAgICAgICBlbHNlDQogICAgICAgICAgICAgICAgICBDQ2FzdFNwZWxsKGksIG1vdXNlUG9zLngsIG1vdXNlUG9zLnopDQogICAgICAgICAgICAgIGVuZCB0b0Nhc3RbaV0gPSBmYWxzZQ0KICAgICAgICAgICAgZW5kDQogICAgICAgICAgZW5kDQogICAgICBlbmQgDQogIGVuZA0KZW5kICAgDQogICAgICAgICAgLS0gTk9XIERFUFJFQ0FURUQhIFRPRE86IHJlbW92ZS4uDQogICAgICAgICAgLS1pZiAoQ29uZmlnLnRocm93IG9yIENvbmZpZ1tzdHJbaV1dIG9yIENvbmZpZ1trZXlbaV1dKSBhbmQgbXlIZXJvOkNhblVzZVNwZWxsKGkpIGFuZCBJc0xlZVRocmVzaCgpIHRoZW4gLS0gbW92ZSBzcGVsbCByZWFkeSBjaGVjayB0byB0b3ANCiAgICAgICAgICAtLSAgICB0b0Nhc3RbaV0gPSB0cnVlDQogICAgICAgICAgLS0gICAgaWYgSGl0Q2hhbmNlID49IENvbmZpZy5wckNvbmZpZy5oaXRjaGFuY2UgYW5kIEdldERpc3RhbmNlKENhc3RQb3NpdGlvbiwgbXlIZXJvKSA8IHNwZWxsLnJhbmdlIC0gQ29uZmlnLnJhbmdlb2Zmc2V0IHRoZW4gQ0Nhc3RTcGVsbChpLCBDYXN0UG9zaXRpb24ueCwgQ2FzdFBvc2l0aW9uLnopIA0KICAgICAgICAgIC0tICAgIHRvQ2FzdFtpXSA9IGZhbHNlIGVuZCAgIA0KICAgICAgICAgIC0tZWxzZQ0KICAgICAgICAgIC0tICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IHByZWRpY3Rpb246R2V0UHJlZGljdGlvbihUYXJnZXQsIHNwZWxsLmRlbGF5LCBzcGVsbC53aWR0aCwgc3BlbGwucmFuZ2UsIHNwZWxsLnNwZWVkLCBteUhlcm8sIHNwZWxsLnR5cGUsIHNwZWxsLmNvbGxpc2lvbiwgc3BlbGwuYW9lKQ0KICAgICAgICAgIC0tICAgIGlmIEhpdENoYW5jZSA+PSBDb25maWcucHJDb25maWcuaGl0Y2hhbmNlIGFuZCBHZXREaXN0YW5jZShDYXN0UG9zaXRpb24sIG15SGVybykgPCBzcGVsbC5yYW5nZSAtIENvbmZpZy5yYW5nZW9mZnNldCB0aGVuIENDYXN0U3BlbGwoaSwgQ2FzdFBvc2l0aW9uLngsIENhc3RQb3NpdGlvbi56KQ0KICAgICAgICAgIC0tICAgIGVsc2VpZiBIaXRDaGFuY2UgPj0gQ29uZmlnLnByQ29uZmlnLmhpdGNoYW5jZS0xIGFuZCBHZXREaXN0YW5jZShDYXN0UG9zaXRpb24sIG15SGVybykgPCBzcGVsbC5yYW5nZSAtIENvbmZpZy5yYW5nZW9mZnNldCB0aGVuIENDYXN0U3BlbGwoaSwgQ2FzdFBvc2l0aW9uLngsIENhc3RQb3NpdGlvbi56KSANCiAgICAgICAgICAtLSAgICBlbHNlIENDYXN0U3BlbGwoaSwgbW91c2VQb3MueCwgbW91c2VQb3MueikgZW5kDQogICAgICAgICAgICAgIC0tdG9DYXN0W2ldID0gZmFsc2UgDQoNCmZ1bmN0aW9uIE9uV25kTXNnKG1zZywga2V5KQ0KICAgaWYgbXNnID09IEtFWV9VUCBhbmQga2V5ID09IEdldEtleSgiUSIpIGFuZCB0b0FpbVswXSB0aGVuDQogICAgIHRvQ2FzdFswXSA9IGZhbHNlDQogICBlbHNlaWYgbXNnID09IEtFWV9VUCBhbmQga2V5ID09IEdldEtleSgiVyIpIGFuZCB0b0FpbVsxXSB0aGVuIA0KICAgICB0b0Nhc3RbMV0gPSBmYWxzZQ0KICAgZWxzZWlmIG1zZyA9PSBLRVlfVVAgYW5kIGtleSA9PSBHZXRLZXkoIkUiKSBhbmQgdG9BaW1bMl0gdGhlbiANCiAgICAgdG9DYXN0WzJdID0gZmFsc2UNCiAgIGVsc2VpZiBtc2cgPT0gS0VZX1VQIGFuZCBrZXkgPT0gR2V0S2V5KCJSIikgYW5kIHRvQWltWzNdIHRoZW4NCiAgICAgdG9DYXN0WzNdID0gZmFsc2UNCiAgIGVuZA0KZW5kDQoNCmZ1bmN0aW9uIElzVmVpZ2FyTHV4KGkpDQogIGlmIG15SGVyby5jaGFyTmFtZSA9PSAnTHV4JyB0aGVuDQogICAgaWYgaSA9PSAxIHRoZW4NCiAgICAgIHJldHVybiB0cnVlDQogICAgZWxzZQ0KICAgICAgcmV0dXJuIGZhbHNlDQogICAgZW5kDQogIGVsc2VpZiBteUhlcm8uY2hhck5hbWUgPT0gJ1ZlaWdhcicgdGhlbg0KICAgIGlmIGkgPT0gMSB0aGVuDQogICAgICByZXR1cm4gdHJ1ZQ0KICAgIGVsc2UNCiAgICAgIHJldHVybiBmYWxzZQ0KICAgIGVuZCANCiAgZWxzZQ0KICAgIHJldHVybiBmYWxzZQ0KICBlbmQNCmVuZA0KDQpmdW5jdGlvbiBPblNlbmRQYWNrZXQocCkNCiAgVGFyZ2V0ID0gR2V0Q3VzdG9tVGFyZ2V0KCkNCiAgaWYgQ29uZmlnLnRvZyB0aGVuDQogICAgaWYgcC5oZWFkZXIgPT0gMHgwMEU5IHRoZW4gLS0gQ3JlZGl0cyB0byBQZXdQZXdQZXcNCiAgICAgIHAucG9zPTI3DQogICAgICBsb2NhbCBvcGMgPSBwOkRlY29kZTEoKQ0KICAgICAgaWYgVGFyZ2V0IH49IG5pbCB0aGVuDQogICAgICAgIGlmIG9wYyA9PSAweDAyIGFuZCBub3QgdG9DYXN0WzBdIGFuZCB0b0FpbVswXSB0aGVuIA0KICAgICAgICAgIHA6QmxvY2soKQ0KICAgICAgICAgIHAuc2tpcChwLCAxKQ0KICAgICAgICAgIHRvQ2FzdFswXSA9IHRydWUNCiAgICAgICAgZWxzZWlmIG9wYyA9PSAweEQ4IGFuZCBub3QgdG9DYXN0WzFdIGFuZCB0b0FpbVsxXSB0aGVuIA0KICAgICAgICAgIHA6QmxvY2soKQ0KICAgICAgICAgIHAuc2tpcChwLCAxKQ0KICAgICAgICAgIHRvQ2FzdFsxXSA9IHRydWUNCiAgICAgICAgZWxzZWlmIG9wYyA9PSAweEIzIGFuZCBub3QgdG9DYXN0WzJdIGFuZCB0b0FpbVsyXSB0aGVuIA0KICAgICAgICAgIHA6QmxvY2soKQ0KICAgICAgICAgIHAuc2tpcChwLCAxKQ0KICAgICAgICAgIHRvQ2FzdFsyXSA9IHRydWUNCiAgICAgICAgZWxzZWlmIG9wYyA9PSAweEU3IGFuZCBub3QgdG9DYXN0WzNdIGFuZCB0b0FpbVszXSB0aGVuDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzNdID0gdHJ1ZQ0KICAgICAgICBlbmQNCiAgICAgIGVuZA0KICAgIGVuZA0KICBlbmQNCmVuZA0KDQotLUNyZWRpdCBUcmVlcw0KZnVuY3Rpb24gR2V0Q3VzdG9tVGFyZ2V0KCkNCiAgICB0czI6dXBkYXRlKCkNCiAgICBpZiBfRy5NTUFfVGFyZ2V0IGFuZCBfRy5NTUFfVGFyZ2V0LnR5cGUgPT0gbXlIZXJvLnR5cGUgdGhlbiByZXR1cm4gX0cuTU1BX1RhcmdldCBlbmQNCiAgICBpZiBfRy5BdXRvQ2FycnkgYW5kIF9HLkF1dG9DYXJyeS5Dcm9zc2hhaXIgYW5kIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyIGFuZCBfRy5BdXRvQ2FycnkuQXR0YWNrX0Nyb3NzaGFpci50YXJnZXQgYW5kIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyLnRhcmdldC50eXBlID09IG15SGVyby50eXBlIHRoZW4gcmV0dXJuIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyLnRhcmdldCBlbmQNCiAgICAtLXByaW50KCd0c3RhcmdldCBjYWxsZWQnKQ0KICAgIHJldHVybiB0czIudGFyZ2V0DQplbmQNCi0tRW5kIENyZWRpdCBUcmVlcw0KDQotLVtbIFBhY2tldCBDYXN0IEhlbHBlciBdXS0tDQpmdW5jdGlvbiBDQ2FzdFNwZWxsKFNwZWxsLCB4UG9zLCB6UG9zKQ0KICBpZiBWSVBfVVNFUiBhbmQgQ29uZmlnLnByQ29uZmlnLnBjIHRoZW4NCiAgICBQYWNrZXQoIlNfQ0FTVCIsIHtzcGVsbElkID0gU3BlbGwsIGZyb21YID0geFBvcywgZnJvbVkgPSB6UG9zLCB0b1ggPSB4UG9zLCB0b1kgPSB6UG9zfSk6c2VuZCgpDQogIGVsc2UNCiAgICBDYXN0U3BlbGwoU3BlbGwsIHhQb3MsIHpQb3MpDQogIGVuZA0KZW5k"), nil, "bt", _ENV))()