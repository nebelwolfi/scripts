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
        [_Q] =  { speed = math.huge, delay = 250, range = 475, minionCollisionWidth = 0},
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
--[[ Skillshot list end ]]--

load(Base64Decode("LS1bWyBBdXRvIHVwZGF0ZXIgc3RhcnQgYW5kIEVuY3J5cHRpb24gc3RhcnQgXV0tLQ0KbG9jYWwgdmVyc2lvbiA9IDAuMjkNCmxvY2FsIEFVVE9fVVBEQVRFID0gdHJ1ZQ0KbG9jYWwgVVBEQVRFX0hPU1QgPSAicmF3LmdpdGh1Yi5jb20iDQpsb2NhbCBVUERBVEVfUEFUSCA9ICIvbmViZWx3b2xmaS9zY3JpcHRzL21hc3Rlci9BaW1ib3QubHVhIi4uIj9yYW5kPSIuLm1hdGgucmFuZG9tKDEsMTAwMDApDQpsb2NhbCBVUERBVEVfRklMRV9QQVRIID0gU0NSSVBUX1BBVEguLiJBaW1ib3QubHVhIg0KbG9jYWwgVVBEQVRFX1VSTCA9ICJodHRwczovLyIuLlVQREFURV9IT1NULi5VUERBVEVfUEFUSA0KbG9jYWwgZnVuY3Rpb24gQXV0b3VwZGF0ZXJNc2cobXNnKSBwcmludCgiPGZvbnQgY29sb3I9XCIjNjY5OWZmXCI+PGI+QWltYm90OjwvYj48L2ZvbnQ+IDxmb250IGNvbG9yPVwiI0ZGRkZGRlwiPiIuLm1zZy4uIi48L2ZvbnQ+IikgZW5kDQppZiBBVVRPX1VQREFURSB0aGVuDQogIGxvY2FsIFNlcnZlckRhdGEgPSBHZXRXZWJSZXN1bHQoVVBEQVRFX0hPU1QsICIvbmViZWx3b2xmaS9zY3JpcHRzL21hc3Rlci9BaW1ib3QudmVyc2lvbiIpDQogIGlmIFNlcnZlckRhdGEgdGhlbg0KICAgIFNlcnZlclZlcnNpb24gPSB0eXBlKHRvbnVtYmVyKFNlcnZlckRhdGEpKSA9PSAibnVtYmVyIiBhbmQgdG9udW1iZXIoU2VydmVyRGF0YSkgb3IgbmlsDQogICAgaWYgU2VydmVyVmVyc2lvbiB0aGVuDQogICAgICBpZiB0b251bWJlcih2ZXJzaW9uKSA8IFNlcnZlclZlcnNpb24gdGhlbg0KICAgICAgICBBdXRvdXBkYXRlck1zZygiTmV3IHZlcnNpb24gYXZhaWxhYmxlIHYiLi5TZXJ2ZXJWZXJzaW9uKQ0KICAgICAgICBBdXRvdXBkYXRlck1zZygiVXBkYXRpbmcsIHBsZWFzZSBkb24ndCBwcmVzcyBGOSIpDQogICAgICAgIERlbGF5QWN0aW9uKGZ1bmN0aW9uKCkgRG93bmxvYWRGaWxlKFVQREFURV9VUkwsIFVQREFURV9GSUxFX1BBVEgsIGZ1bmN0aW9uICgpIEF1dG91cGRhdGVyTXNnKCJTdWNjZXNzZnVsbHkgdXBkYXRlZC4gKCIuLnZlcnNpb24uLiIgPT4gIi4uU2VydmVyVmVyc2lvbi4uIiksIHByZXNzIEY5IHR3aWNlIHRvIGxvYWQgdGhlIHVwZGF0ZWQgdmVyc2lvbi4iKSBlbmQpIGVuZCwgMykNCiAgICAgIGVsc2UNCiAgICAgICAgQXV0b3VwZGF0ZXJNc2coIkxvYWRlZCB0aGUgbGF0ZXN0IHZlcnNpb24gKHYiLi5TZXJ2ZXJWZXJzaW9uLi4iKSIpDQogICAgICBlbmQNCiAgICBlbmQNCiAgZWxzZQ0KICAgIEF1dG91cGRhdGVyTXNnKCJFcnJvciBkb3dubG9hZGluZyB2ZXJzaW9uIGluZm8iKQ0KICBlbmQNCmVuZA0KLS1bWyBBdXRvIHVwZGF0ZXIgZW5kIF1dLS0NCg0KLS1bWyBMaWJyYXJpZXMgc3RhcnQgXV0tLQ0KaWYgRmlsZUV4aXN0KExJQl9QQVRIIC4uICIvVlByZWRpY3Rpb24ubHVhIikgdGhlbg0KICByZXF1aXJlKCJWUHJlZGljdGlvbiIpDQogIFZQID0gVlByZWRpY3Rpb24oKQ0KZW5kDQotLVtbIFNVUFBPUlRFRCBMQVRFUg0KaWYgVklQX1VTRVIgYW5kIEZpbGVFeGlzdChMSUJfUEFUSCAuLiAiL0RpdmluZVByZWQubHVhIikgdGhlbiANCiAgcmVxdWlyZSAiRGl2aW5lUHJlZCIgDQogIERQID0gRGl2aW5lUHJlZCgpDQplbmQgXV0NCi0tW1sgTGlicmFyaWVzIGVuZCBdXS0tDQoNCg0KaWYgbm90IENoYW1wc1tteUhlcm8uY2hhck5hbWVdIHRoZW4gcmV0dXJuIGVuZCAtLSBub3Qgc3VwcG9ydGVkIDooDQpIb29rUGFja2V0cygpIC0tIENyZWRpdHMgdG8gaUNyZWF0aXZlDQpsb2NhbCBkYXRhID0gQ2hhbXBzW215SGVyby5jaGFyTmFtZV0NCmxvY2FsIFFSZWFkeSwgV1JlYWR5LCBFUmVhZHksIFJSZWFkeSA9IG5pbCwgbmlsLCBuaWwsIG5pbA0KbG9jYWwgVGFyZ2V0IA0KbG9jYWwgdHMyID0gVGFyZ2V0U2VsZWN0b3IoVEFSR0VUX05FQVJfTU9VU0UsIDE1MDAsIERBTUFHRV9NQUdJQywgdHJ1ZSkgLS0gbWFrZSB0aGVzZSBsb2NhbA0KbG9jYWwgc3RyID0geyBbX1FdID0gIlEiLCBbX1ddID0gIlciLCBbX0VdID0gIkUiLCBbX1JdID0gIlIiIH0NCmxvY2FsIENvbmZpZ1R5cGUgPSBTQ1JJUFRfUEFSQU1fT05LRVlET1dODQpsb2NhbCBwcmVkaWN0aW9ucyA9IHt9DQpsb2NhbCB0b0Nhc3QgPSB7ZmFsc2UsIGZhbHNlLCBmYWxzZSwgZmFsc2V9DQpsb2NhbCB0b0FpbSA9IHtmYWxzZSwgZmFsc2UsIGZhbHNlLCBmYWxzZX0NCmZ1bmN0aW9uIE9uTG9hZCgpDQogIENvbmZpZyA9IHNjcmlwdENvbmZpZygiQWltYm90IHYiLi52ZXJzaW9uLCAiQWltYm90IHYiLi52ZXJzaW9uKQ0KICBDb25maWc6YWRkU3ViTWVudSgiW1ByZWRpY3Rpb25dOiBTZXR0aW5ncyIsICJwckNvbmZpZyIpDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicGMiLCAiVXNlIFBhY2tldHMgVG8gQ2FzdCBTcGVsbHMiLCBTQ1JJUFRfUEFSQU1fT05PRkYsIGZhbHNlKQ0KICBDb25maWcucHJDb25maWc6YWRkUGFyYW0oInFxcSIsICItLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSIsIFNDUklQVF9QQVJBTV9JTkZPLCIiKQ0KICBDb25maWcucHJDb25maWc6YWRkUGFyYW0oImhpdGNoYW5jZSIsICJBY2N1cmFjeSIsIFNDUklQVF9QQVJBTV9TTElDRSwgMiwgMCwgMywgMCkNCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJxcXEiLCAiLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0iLCBTQ1JJUFRfUEFSQU1fSU5GTywiIikNCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJwcm8iLCAiUHJvZGljdGlvbiBUbyBVc2U6IiwgU0NSSVBUX1BBUkFNX0xJU1QsIDEsIHsiVlByZWRpY3Rpb24ifSkgLS0gLCJEaXZpbmVQcmVkIg0KICBDb25maWc6YWRkU3ViTWVudSgiU3VwcG9ydGVkIHNraWxscyIsICJza0NvbmZpZyIpDQogIGZvciBpLCBzcGVsbCBpbiBwYWlycyhkYXRhKSBkbw0KICAgIENvbmZpZy5za0NvbmZpZzphZGRQYXJhbShzdHJbaV0sICIiLCBDb25maWdUeXBlLCBmYWxzZSwgc3RyaW5nLmJ5dGUoc3RyW2ldKSkNCiAgICBwcmVkaWN0aW9uc1tzdHJbaV1dID0ge3NwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgc3BlbGwuZGVsYXksIHNwZWxsLm1pbmlvbkNvbGxpc2lvbldpZHRoLCBpfQ0KICAgIHRvQWltW2ldID0gdHJ1ZQ0KICBlbmQNCiAgQ29uZmlnOmFkZFBhcmFtKCJ0b2ciLCAiQWltYm90IG9uL29mZiIsIFNDUklQVF9QQVJBTV9PTktFWVRPR0dMRSwgdHJ1ZSwgc3RyaW5nLmJ5dGUoIlQiKSkNCiAgQ29uZmlnOmFkZFBhcmFtKCJyYW5nZW9mZnNldCIsICJSYW5nZSBEZWNyZWFzZSBPZmZzZXQiLCBTQ1JJUFRfUEFSQU1fU0xJQ0UsIDAsIDAsIDIwMCwgMCkNCiAgQ29uZmlnOnBlcm1hU2hvdygidG9nIikNCiAgdHMyLm5hbWUgPSAiVGFyZ2V0Ig0KICAtLUNvbmZpZzphZGRUUyh0czIpDQplbmQNCg0KZnVuY3Rpb24gT25UaWNrKCkNCiAgaWYgQ29uZmlnLnRvZyB0aGVuDQogICAgaWYgQ29uZmlnLnByQ29uZmlnLnBybyA9PSAxIHRoZW4NCiAgICAgIFRhcmdldCA9IEdldEN1c3RvbVRhcmdldCgpIC0tVG1yZWVzDQogICAgICBpZiBUYXJnZXQgPT0gbmlsIHRoZW4gcmV0dXJuIGVuZA0KICAgICAgZm9yIGksIHNwZWxsIGluIHBhaXJzKGRhdGEpIGRvDQogICAgICAgICAgICBsb2NhbCBjb2xsaXNpb24gPSBzcGVsbC5taW5pb25Db2xsaXNpb25XaWR0aCA9PSAwIGFuZCBmYWxzZSBvciB0cnVlDQogICAgICAgICAgICBsb2NhbCBDYXN0UG9zaXRpb24sIEhpdENoYW5jZSwgUG9zaXRpb24gPSBWUDpHZXRMaW5lQ2FzdFBvc2l0aW9uKFRhcmdldCwgc3BlbGwuZGVsYXksIHNwZWxsLm1pbmlvbkNvbGxpc2lvbldpZHRoLCBzcGVsbC5yYW5nZSwgc3BlbGwuc3BlZWQsIG15SGVybywgY29sbGlzaW9uKQ0KICAgICAgICAgIGlmIChDb25maWcudGhyb3cgb3IgQ29uZmlnW3N0cltpXV0pIGFuZCBteUhlcm86Q2FuVXNlU3BlbGwoaSkgYW5kIElzTGVlVGhyZXNoKCkgdGhlbiAtLSBtb3ZlIHNwZWxsIHJlYWR5IGNoZWNrIHRvIHRvcA0KICAgICAgICAgICAgICBpZiBDYXN0UG9zaXRpb24gYW5kIEhpdENoYW5jZSBhbmQgSGl0Q2hhbmNlID49IENvbmZpZy5wckNvbmZpZy5oaXRjaGFuY2UgYW5kIEdldERpc3RhbmNlKENhc3RQb3NpdGlvbiwgbXlIZXJvKSA8IHNwZWxsLnJhbmdlIC0gQ29uZmlnLnJhbmdlb2Zmc2V0IHRoZW4gQ0Nhc3RTcGVsbChpLCBDYXN0UG9zaXRpb24ueCwgQ2FzdFBvc2l0aW9uLnopIGVuZCAgIA0KICAgICAgICAgIGVsc2VpZiB0b0Nhc3RbaV0gPT0gdHJ1ZSBhbmQgbXlIZXJvOkNhblVzZVNwZWxsKGkpIGFuZCBJc0xlZVRocmVzaCgpIHRoZW4NCiAgICAgICAgICAgICAgaWYgQ2FzdFBvc2l0aW9uIGFuZCBIaXRDaGFuY2UgYW5kIEhpdENoYW5jZSA+PSBDb25maWcucHJDb25maWcuaGl0Y2hhbmNlIGFuZCBHZXREaXN0YW5jZShDYXN0UG9zaXRpb24sIG15SGVybykgPCBzcGVsbC5yYW5nZSAtIENvbmZpZy5yYW5nZW9mZnNldCB0aGVuIENDYXN0U3BlbGwoaSwgQ2FzdFBvc2l0aW9uLngsIENhc3RQb3NpdGlvbi56KSBlbmQgIA0KICAgICAgICAgICAgICB0b0Nhc3RbaV0gPSBmYWxzZSANCiAgICAgICAgICBlbmQNCiAgICAgIGVuZCANCiAgICBlbmQNCiAgICAtLVtbIFdJTEwgQkUgSU1QTEVNRU5URUQgTEFURVINCiAgICBpZiBDb25maWcucHJDb25maWcucHJvID09IDIgYW5kIFZJUF9VU0VSIHRoZW4NCiAgICAgIFRhcmdldCA9IEdldEN1c3RvbVRhcmdldCgpIC0tVG1yZWVzDQogICAgICBpZiBUYXJnZXQgPT0gbmlsIHRoZW4gcmV0dXJuIGVuZA0KICAgICAgbG9jYWwgdW5pdCA9IERQVGFyZ2V0KFRhcmdldCkNCiAgICAgIGZvciBpLCBzcGVsbCBpbiBwYWlycyhkYXRhMikgZG8NCiAgICAgICAgbG9jYWwgc2tpbGwgPSBMaW5lU1Moc3BlbGwucHJvamVjdGlsZVNwZWVkLCBzcGVsbC5yYW5nZSwgc3BlbGwucmFkaXVzLCBzcGVsbC5zcGVsbERlbGF5LCAwKQ0KICAgICAgICAtLVByaW50Q2hhdChzcGVsbC5uYW1lKQ0KICAgICAgICBsb2NhbCBzdGF0ZSxoaXRQb3MscGVyYyA9IERQOnByZWRpY3QodW5pdCwgc2tpbGwpDQogICAgICAgIGlmIENvbmZpZy50aHJvdyBhbmQgU3RhdGUgPT0gU2tpbGxTaG90LlNUQVRVUy5TVUNDRVNTX0hJVCB0aGVuIA0KICAgICAgICAgIENDYXN0U3BlbGwoaSwgUG9zaXRpb24ueCwgUG9zaXRpb24ueikNCiAgICAgICAgZW5kDQogICAgICBlbmQNCiAgICBlbmRdXQ0KICBlbmQNCmVuZA0KDQpmdW5jdGlvbiBPblduZE1zZyhtc2csIGtleSkNCiAgIGlmIG1zZyA9PSBLRVlfVVAgYW5kIGtleSA9PSBHZXRLZXkoIlEiKSBhbmQgdG9BaW1bMF0gdGhlbg0KICAgICB0b0Nhc3RbMF0gPSBmYWxzZQ0KICAgZWxzZWlmIG1zZyA9PSBLRVlfVVAgYW5kIGtleSA9PSBHZXRLZXkoIlciKSBhbmQgdG9BaW1bMV0gdGhlbiANCiAgICAgdG9DYXN0WzFdID0gZmFsc2UNCiAgIGVsc2VpZiBtc2cgPT0gS0VZX1VQIGFuZCBrZXkgPT0gR2V0S2V5KCJFIikgYW5kIHRvQWltWzJdIHRoZW4gDQogICAgIHRvQ2FzdFsyXSA9IGZhbHNlDQogICBlbHNlaWYgbXNnID09IEtFWV9VUCBhbmQga2V5ID09IEdldEtleSgiUiIpIGFuZCB0b0FpbVszXSB0aGVuDQogICAgIHRvQ2FzdFszXSA9IGZhbHNlDQogICBlbmQNCmVuZA0KDQpmdW5jdGlvbiBPblNlbmRQYWNrZXQocCkNCiAgVGFyZ2V0ID0gR2V0Q3VzdG9tVGFyZ2V0KCkNCiAgaWYgQ29uZmlnLnRvZyB0aGVuDQogICAgaWYgcC5oZWFkZXIgPT0gMHgwMEU5IHRoZW4gLS0gQ3JlZGl0cyB0byBQZXdQZXdQZXcNCiAgICAgIHAucG9zPTI3DQogICAgICBsb2NhbCBvcGMgPSBwOkRlY29kZTEoKQ0KICAgICAgaWYgVGFyZ2V0IH49IG5pbCB0aGVuDQogICAgICAgIGlmIG9wYyA9PSAweDAyIGFuZCBub3QgdG9DYXN0WzBdIGFuZCB0b0FpbVswXSB0aGVuIA0KICAgICAgICAgIHA6QmxvY2soKQ0KICAgICAgICAgIHAuc2tpcChwLCAxKQ0KICAgICAgICAgIHRvQ2FzdFswXSA9IHRydWUNCiAgICAgICAgZWxzZWlmIG9wYyA9PSAweEQ4IGFuZCBub3QgdG9DYXN0WzFdIGFuZCB0b0FpbVsxXSB0aGVuIA0KICAgICAgICAgIHA6QmxvY2soKQ0KICAgICAgICAgIHAuc2tpcChwLCAxKQ0KICAgICAgICAgIHRvQ2FzdFsxXSA9IHRydWUNCiAgICAgICAgZWxzZWlmIG9wYyA9PSAweEIzIGFuZCBub3QgdG9DYXN0WzJdIGFuZCB0b0FpbVsyXSB0aGVuIA0KICAgICAgICAgIHA6QmxvY2soKQ0KICAgICAgICAgIHAuc2tpcChwLCAxKQ0KICAgICAgICAgIHRvQ2FzdFsyXSA9IHRydWUNCiAgICAgICAgZWxzZWlmIG9wYyA9PSAweEU3IGFuZCBub3QgdG9DYXN0WzNdIGFuZCB0b0FpbVszXSB0aGVuDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzNdID0gdHJ1ZQ0KICAgICAgICBlbmQNCiAgICAgIGVuZA0KICAgIGVuZA0KICBlbmQNCmVuZA0KDQpmdW5jdGlvbiBJc0xlZVRocmVzaCgpDQogIGlmIG15SGVyby5jaGFyTmFtZSA9PSAnTGVlU2luJyB0aGVuDQogICAgaWYgbXlIZXJvOkdldFNwZWxsRGF0YShfUSkubmFtZSA9PSAnQmxpbmRNb25rUU9uZScgdGhlbg0KICAgICAgcmV0dXJuIHRydWUNCiAgICBlbHNlDQogICAgICByZXR1cm4gZmFsc2UNCiAgICBlbmQNCiAgZWxzZWlmIG15SGVyby5jaGFyTmFtZSA9PSAnVGhyZXNoJyB0aGVuDQogICAgaWYgbXlIZXJvOkdldFNwZWxsRGF0YShfUSkubmFtZSA9PSAnVGhyZXNoUScgdGhlbg0KICAgICAgcmV0dXJuIHRydWUNCiAgICBlbHNlDQogICAgICByZXR1cm4gZmFsc2UNCiAgICBlbmQgDQogIGVsc2VpZiBteUhlcm8uY2hhck5hbWUgPT0gJ1lhc3VvJyB0aGVuDQogICAgaWYgbXlIZXJvOkdldFNwZWxsRGF0YShfUSkubmFtZSA9PSAnWWFzdW9RJyB0aGVuDQogICAgICByZXR1cm4gdHJ1ZQ0KICAgIGVsc2UNCiAgICAgIHJldHVybiBmYWxzZQ0KICAgIGVuZCANCiAgZWxzZSANCiAgICByZXR1cm4gdHJ1ZQ0KICBlbmQNCmVuZA0KDQotLUNyZWRpdCBUcmVlcw0KZnVuY3Rpb24gR2V0Q3VzdG9tVGFyZ2V0KCkNCiAgICBpZiBfRy5NTUFfVGFyZ2V0IGFuZCBfRy5NTUFfVGFyZ2V0LnR5cGUgPT0gbXlIZXJvLnR5cGUgdGhlbiByZXR1cm4gX0cuTU1BX1RhcmdldCBlbmQNCiAgICBpZiBfRy5BdXRvQ2FycnkgYW5kIF9HLkF1dG9DYXJyeS5Dcm9zc2hhaXIgYW5kIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyIGFuZCBfRy5BdXRvQ2FycnkuQXR0YWNrX0Nyb3NzaGFpci50YXJnZXQgYW5kIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyLnRhcmdldC50eXBlID09IG15SGVyby50eXBlIHRoZW4gcmV0dXJuIF9HLkF1dG9DYXJyeS5BdHRhY2tfQ3Jvc3NoYWlyLnRhcmdldCBlbmQNCiAgICB0czI6dXBkYXRlKCkNCiAgICAtLXByaW50KCd0c3RhcmdldCBjYWxsZWQnKQ0KICAgIHJldHVybiB0czIudGFyZ2V0DQplbmQNCi0tRW5kIENyZWRpdCBUcmVlcw0KDQotLVtbIFBhY2tldCBDYXN0IEhlbHBlciBdXS0tDQpmdW5jdGlvbiBDQ2FzdFNwZWxsKFNwZWxsLCB4UG9zLCB6UG9zKQ0KICBpZiBWSVBfVVNFUiBhbmQgQ29uZmlnLnByQ29uZmlnLnBjIHRoZW4NCiAgICBQYWNrZXQoIlNfQ0FTVCIsIHtzcGVsbElkID0gU3BlbGwsIGZyb21YID0geFBvcywgZnJvbVkgPSB6UG9zLCB0b1ggPSB4UG9zLCB0b1kgPSB6UG9zfSk6c2VuZCgpDQogIGVsc2UNCiAgICBDYXN0U3BlbGwoU3BlbGwsIHhQb3MsIHpQb3MpDQogIGVuZA0KZW5k"),nil,"bt",_ENV)()