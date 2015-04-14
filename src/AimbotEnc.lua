--[[

Credits to Dienofail, Klokje for old I'mAiming

]]--
if not VIP_USER then return end -- VIP only since we use 420 packets
--[[ Auto updater start ]]--
local version = 0.28
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
--[[ Auto updater end ]]--

--[[ Libraries start ]]--
if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
--[[ SUPPORTED LATER
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
  require "DivinePred" 
  DP = DivinePred()
end ]]
--[[ Libraries end ]]--

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

if not Champs[myHero.charName] then return end -- not supported :(
HookPackets() -- Credits to iCreative

--Credit Trees
function GetCustomTarget()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    ts2:update()
    --print('tstarget called')
    return ts2.target
end
--End Credit Trees

assert(load(Base64Decode("DQpsb2NhbCBkYXRhID0gQ2hhbXBzW215SGVyby5jaGFyTmFtZV0NCmxvY2FsIFFSZWFkeSwgV1JlYWR5LCBFUmVhZHksIFJSZWFkeSA9IG5pbCwgbmlsLCBuaWwsIG5pbA0KbG9jYWwgVGFyZ2V0IA0KbG9jYWwgdHMyID0gVGFyZ2V0U2VsZWN0b3IoVEFSR0VUX05FQVJfTU9VU0UsIDE1MDAsIERBTUFHRV9NQUdJQywgdHJ1ZSkgLS0gbWFrZSB0aGVzZSBsb2NhbA0KbG9jYWwgc3RyID0geyBbX1FdID0gIlEiLCBbX1ddID0gIlciLCBbX0VdID0gIkUiLCBbX1JdID0gIlIiIH0NCmxvY2FsIENvbmZpZ1R5cGUgPSBTQ1JJUFRfUEFSQU1fT05LRVlET1dODQpsb2NhbCBwcmVkaWN0aW9ucyA9IHt9DQpsb2NhbCB0b0Nhc3QgPSB7ZmFsc2UsIGZhbHNlLCBmYWxzZSwgZmFsc2V9DQpsb2NhbCB0b0FpbSA9IHtmYWxzZSwgZmFsc2UsIGZhbHNlLCBmYWxzZX0NCmZ1bmN0aW9uIE9uTG9hZCgpDQogIENvbmZpZyA9IHNjcmlwdENvbmZpZygiQWltYm90IHYiLi52ZXJzaW9uLCAiQWltYm90IHYiLi52ZXJzaW9uKQ0KICBDb25maWc6YWRkU3ViTWVudSgiW1ByZWRpY3Rpb25dOiBTZXR0aW5ncyIsICJwckNvbmZpZyIpDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicGMiLCAiVXNlIFBhY2tldHMgVG8gQ2FzdCBTcGVsbHMoVklQKSIsIFNDUklQVF9QQVJBTV9PTk9GRiwgZmFsc2UpDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicXFxIiwgIi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tIiwgU0NSSVBUX1BBUkFNX0lORk8sIiIpDQogIENvbmZpZy5wckNvbmZpZzphZGRQYXJhbSgicHJvIiwgIlByb2RpY3Rpb24gVG8gVXNlOiIsIFNDUklQVF9QQVJBTV9MSVNULCAxLCB7IlZQcmVkaWN0aW9uIn0pIC0tICwiRGl2aW5lUHJlZCINCiAgQ29uZmlnLnByQ29uZmlnOmFkZFBhcmFtKCJoaXRjaGFuY2UiLCAiQWNjdXJhY3kiLCBTQ1JJUFRfUEFSQU1fU0xJQ0UsIDIsIDAsIDMsIDApDQogIENvbmZpZzphZGRTdWJNZW51KCJTdXBwb3J0ZWQgc2tpbGxzIiwgInNrQ29uZmlnIikNCiAgZm9yIGksIHNwZWxsIGluIHBhaXJzKGRhdGEpIGRvDQogICAgQ29uZmlnLnNrQ29uZmlnOmFkZFBhcmFtKHN0cltpXSwgIiIsIENvbmZpZ1R5cGUsIGZhbHNlLCBzdHJpbmcuYnl0ZShzdHJbaV0pKQ0KICAgIHByZWRpY3Rpb25zW3N0cltpXV0gPSB7c3BlbGwucmFuZ2UsIHNwZWxsLnNwZWVkLCBzcGVsbC5kZWxheSwgc3BlbGwubWluaW9uQ29sbGlzaW9uV2lkdGgsIGl9DQogICAgdG9BaW1baV0gPSB0cnVlDQogIGVuZA0KICBDb25maWc6YWRkUGFyYW0oInRvZyIsICJBaW1ib3Qgb24vb2ZmIiwgU0NSSVBUX1BBUkFNX09OS0VZVE9HR0xFLCB0cnVlLCBzdHJpbmcuYnl0ZSgiVCIpKQ0KICBDb25maWc6YWRkUGFyYW0oInJhbmdlb2Zmc2V0IiwgIlJhbmdlIERlY3JlYXNlIE9mZnNldCIsIFNDUklQVF9QQVJBTV9TTElDRSwgMCwgMCwgMjAwLCAwKQ0KICB0czIubmFtZSA9ICJUYXJnZXQiDQogIC0tQ29uZmlnOmFkZFRTKHRzMikNCmVuZA0KDQpmdW5jdGlvbiBPblRpY2soKQ0KICBpZiBDb25maWcudG9nIHRoZW4NCiAgICBpZiBDb25maWcucHJDb25maWcucHJvID09IDEgdGhlbg0KICAgICAgVGFyZ2V0ID0gR2V0Q3VzdG9tVGFyZ2V0KCkgLS1UbXJlZXMNCiAgICAgIGlmIFRhcmdldCA9PSBuaWwgdGhlbiByZXR1cm4gZW5kDQogICAgICBmb3IgaSwgc3BlbGwgaW4gcGFpcnMoZGF0YSkgZG8NCiAgICAgICAgICAgIGxvY2FsIGNvbGxpc2lvbiA9IHNwZWxsLm1pbmlvbkNvbGxpc2lvbldpZHRoID09IDAgYW5kIGZhbHNlIG9yIHRydWUNCiAgICAgICAgICAgIGxvY2FsIENhc3RQb3NpdGlvbiwgSGl0Q2hhbmNlLCBQb3NpdGlvbiA9IFZQOkdldExpbmVDYXN0UG9zaXRpb24oVGFyZ2V0LCBzcGVsbC5kZWxheSwgc3BlbGwubWluaW9uQ29sbGlzaW9uV2lkdGgsIHNwZWxsLnJhbmdlLCBzcGVsbC5zcGVlZCwgbXlIZXJvLCBjb2xsaXNpb24pDQogICAgICAgICAgaWYgKENvbmZpZy50aHJvdyBvciBDb25maWdbc3RyW2ldXSkgYW5kIG15SGVybzpDYW5Vc2VTcGVsbChpKSBhbmQgSXNMZWVUaHJlc2goKSB0aGVuIC0tIG1vdmUgc3BlbGwgcmVhZHkgY2hlY2sgdG8gdG9wDQogICAgICAgICAgICAgIGlmIENhc3RQb3NpdGlvbiBhbmQgSGl0Q2hhbmNlIGFuZCBIaXRDaGFuY2UgPj0gQ29uZmlnLnByQ29uZmlnLmhpdGNoYW5jZSBhbmQgR2V0RGlzdGFuY2UoQ2FzdFBvc2l0aW9uLCBteUhlcm8pIDwgc3BlbGwucmFuZ2UgLSBDb25maWcucmFuZ2VvZmZzZXQgdGhlbiBDQ2FzdFNwZWxsKGksIENhc3RQb3NpdGlvbi54LCBDYXN0UG9zaXRpb24ueikgZW5kICAgDQogICAgICAgICAgZWxzZWlmIHRvQ2FzdFtpXSA9PSB0cnVlIGFuZCBteUhlcm86Q2FuVXNlU3BlbGwoaSkgYW5kIElzTGVlVGhyZXNoKCkgdGhlbg0KICAgICAgICAgICAgICBpZiBDYXN0UG9zaXRpb24gYW5kIEhpdENoYW5jZSBhbmQgSGl0Q2hhbmNlID49IENvbmZpZy5wckNvbmZpZy5oaXRjaGFuY2UgYW5kIEdldERpc3RhbmNlKENhc3RQb3NpdGlvbiwgbXlIZXJvKSA8IHNwZWxsLnJhbmdlIC0gQ29uZmlnLnJhbmdlb2Zmc2V0IHRoZW4gQ0Nhc3RTcGVsbChpLCBDYXN0UG9zaXRpb24ueCwgQ2FzdFBvc2l0aW9uLnopIGVuZCAgDQogICAgICAgICAgICAgIHRvQ2FzdFtpXSA9IGZhbHNlIA0KICAgICAgICAgIGVuZA0KICAgICAgZW5kIA0KICAgIGVuZA0KICAgIC0tW1sgV0lMTCBCRSBJTVBMRU1FTlRFRCBMQVRFUg0KICAgIGlmIENvbmZpZy5wckNvbmZpZy5wcm8gPT0gMiBhbmQgVklQX1VTRVIgdGhlbg0KICAgICAgVGFyZ2V0ID0gR2V0Q3VzdG9tVGFyZ2V0KCkgLS1UbXJlZXMNCiAgICAgIGlmIFRhcmdldCA9PSBuaWwgdGhlbiByZXR1cm4gZW5kDQogICAgICBsb2NhbCB1bml0ID0gRFBUYXJnZXQoVGFyZ2V0KQ0KICAgICAgZm9yIGksIHNwZWxsIGluIHBhaXJzKGRhdGEyKSBkbw0KICAgICAgICBsb2NhbCBza2lsbCA9IExpbmVTUyhzcGVsbC5wcm9qZWN0aWxlU3BlZWQsIHNwZWxsLnJhbmdlLCBzcGVsbC5yYWRpdXMsIHNwZWxsLnNwZWxsRGVsYXksIDApDQogICAgICAgIC0tUHJpbnRDaGF0KHNwZWxsLm5hbWUpDQogICAgICAgIGxvY2FsIHN0YXRlLGhpdFBvcyxwZXJjID0gRFA6cHJlZGljdCh1bml0LCBza2lsbCkNCiAgICAgICAgaWYgQ29uZmlnLnRocm93IGFuZCBTdGF0ZSA9PSBTa2lsbFNob3QuU1RBVFVTLlNVQ0NFU1NfSElUIHRoZW4gDQogICAgICAgICAgQ0Nhc3RTcGVsbChpLCBQb3NpdGlvbi54LCBQb3NpdGlvbi56KQ0KICAgICAgICBlbmQNCiAgICAgIGVuZA0KICAgIGVuZF1dDQogIGVuZA0KZW5kDQoNCmZ1bmN0aW9uIE9uV25kTXNnKG1zZywga2V5KQ0KICAgaWYgbXNnID09IEtFWV9VUCBhbmQga2V5ID09IEdldEtleSgiUSIpIGFuZCB0b0FpbVswXSB0aGVuDQogICAgIHRvQ2FzdFswXSA9IGZhbHNlDQogICBlbHNlaWYgbXNnID09IEtFWV9VUCBhbmQga2V5ID09IEdldEtleSgiVyIpIGFuZCB0b0FpbVsxXSB0aGVuIA0KICAgICB0b0Nhc3RbMV0gPSBmYWxzZQ0KICAgZWxzZWlmIG1zZyA9PSBLRVlfVVAgYW5kIGtleSA9PSBHZXRLZXkoIkUiKSBhbmQgdG9BaW1bMl0gdGhlbiANCiAgICAgdG9DYXN0WzJdID0gZmFsc2UNCiAgIGVsc2VpZiBtc2cgPT0gS0VZX1VQIGFuZCBrZXkgPT0gR2V0S2V5KCJSIikgYW5kIHRvQWltWzNdIHRoZW4NCiAgICAgdG9DYXN0WzNdID0gZmFsc2UNCiAgIGVuZA0KZW5kDQoNCmZ1bmN0aW9uIE9uU2VuZFBhY2tldChwKQ0KICBUYXJnZXQgPSBHZXRDdXN0b21UYXJnZXQoKQ0KICBpZiBDb25maWcudG9nIHRoZW4NCiAgICBpZiBwLmhlYWRlciA9PSAweDAwRTkgdGhlbiAtLSBDcmVkaXRzIHRvIFBld1Bld1Bldw0KICAgICAgcC5wb3M9MjcNCiAgICAgIGxvY2FsIG9wYyA9IHA6RGVjb2RlMSgpDQogICAgICBpZiBUYXJnZXQgfj0gbmlsIHRoZW4NCiAgICAgICAgaWYgb3BjID09IDB4MDIgYW5kIG5vdCB0b0Nhc3RbMF0gYW5kIHRvQWltWzBdIHRoZW4gDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzBdID0gdHJ1ZQ0KICAgICAgICBlbHNlaWYgb3BjID09IDB4RDggYW5kIG5vdCB0b0Nhc3RbMV0gYW5kIHRvQWltWzFdIHRoZW4gDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzFdID0gdHJ1ZQ0KICAgICAgICBlbHNlaWYgb3BjID09IDB4QjMgYW5kIG5vdCB0b0Nhc3RbMl0gYW5kIHRvQWltWzJdIHRoZW4gDQogICAgICAgICAgcDpCbG9jaygpDQogICAgICAgICAgcC5za2lwKHAsIDEpDQogICAgICAgICAgdG9DYXN0WzJdID0gdHJ1ZQ0KICAgICAgICBlbHNlaWYgb3BjID09IDB4RTcgYW5kIG5vdCB0b0Nhc3RbM10gYW5kIHRvQWltWzNdIHRoZW4NCiAgICAgICAgICBwOkJsb2NrKCkNCiAgICAgICAgICBwLnNraXAocCwgMSkNCiAgICAgICAgICB0b0Nhc3RbM10gPSB0cnVlDQogICAgICAgIGVuZA0KICAgICAgZW5kDQogICAgZW5kDQogIGVuZA0KZW5kDQoNCmZ1bmN0aW9uIElzTGVlVGhyZXNoKCkNCiAgaWYgbXlIZXJvLmNoYXJOYW1lID09ICdMZWVTaW4nIHRoZW4NCiAgICBpZiBteUhlcm86R2V0U3BlbGxEYXRhKF9RKS5uYW1lID09ICdCbGluZE1vbmtRT25lJyB0aGVuDQogICAgICByZXR1cm4gdHJ1ZQ0KICAgIGVsc2UNCiAgICAgIHJldHVybiBmYWxzZQ0KICAgIGVuZA0KICBlbHNlaWYgbXlIZXJvLmNoYXJOYW1lID09ICdUaHJlc2gnIHRoZW4NCiAgICBpZiBteUhlcm86R2V0U3BlbGxEYXRhKF9RKS5uYW1lID09ICdUaHJlc2hRJyB0aGVuDQogICAgICByZXR1cm4gdHJ1ZQ0KICAgIGVsc2UNCiAgICAgIHJldHVybiBmYWxzZQ0KICAgIGVuZCANCiAgZWxzZWlmIG15SGVyby5jaGFyTmFtZSA9PSAnWWFzdW8nIHRoZW4NCiAgICBpZiBteUhlcm86R2V0U3BlbGxEYXRhKF9RKS5uYW1lID09ICdZYXN1b1EnIHRoZW4NCiAgICAgIHJldHVybiB0cnVlDQogICAgZWxzZQ0KICAgICAgcmV0dXJuIGZhbHNlDQogICAgZW5kIA0KICBlbHNlIA0KICAgIHJldHVybiB0cnVlDQogIGVuZA0KZW5kDQoNCg0KLS1bWyBQYWNrZXQgQ2FzdCBIZWxwZXIgXV0tLQ0KZnVuY3Rpb24gQ0Nhc3RTcGVsbChTcGVsbCwgeFBvcywgelBvcykNCiAgaWYgVklQX1VTRVIgYW5kIENvbmZpZy5wckNvbmZpZy5wYyB0aGVuDQogICAgUGFja2V0KCJTX0NBU1QiLCB7c3BlbGxJZCA9IFNwZWxsLCBmcm9tWCA9IHhQb3MsIGZyb21ZID0gelBvcywgdG9YID0geFBvcywgdG9ZID0gelBvc30pOnNlbmQoKQ0KICBlbHNlDQogICAgQ2FzdFNwZWxsKFNwZWxsLCB4UG9zLCB6UG9zKQ0KICBlbmQNCmVuZA=="), nil, "bt", _ENV))