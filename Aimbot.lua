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

_G.ScriptCode = Base64Decode("fL/Z0sllZnV7dX9legZxe5FvZXF3cXdlYXNkco71ZXF3cndlYbZk8XfmpXF3MvdlYXQlcXerZrJ3uLgmY/TlcncmJnJ3zvjlYkmk8nhrZrN3srhnYYmlcnmm5nN38XhlYjNl8Xi7JvJ5FnhlYc5kcXd8JX33NzinYXNmcXimZ3R3TvjlYk5lcXd85Xv3d/moYbkmtHflZ/F6znllYpDmcXd9ZbV7iHdm4XkmtHelZ/F6jvllYo6mcXd8ZXH3dXllYXtk8/1rp7R3jHllYYpkePdrJ7R3sXllYZDmcXirp7R3irdnZYpkdPdlZ3F6srlpYfmmtHe75/N7jrllYnNmcXqm53V3jrllYnkmtXfKp3F38nlqYZCm8Xh8pXP3cXllZLSmdnfrp7R3MvlqYckm83uCp3F4iPdl4XNmcXqmJ3Z3jrllYjllt3drp7d3svlrYYmmc3tC5nF4THhlYYqkcvcrJrd3cnlsYVClcXgrZrh3TvjlYXsk8gUr5rh3dzmsYXpmuXssZvN6TLhlYYpkcfeEZfF3N7itYVCl8Xcr5rh3dzmsYXpmuXssZvN6dXllY7nnuXfrKLl3MnpuYXmouneoafF3zvrlY/5ncncr6Lp3+zouaDlnu3fvqDt+N/qvYf0nO34raLx3+7owaDnnvHdwaXF3vHtlY/ZocXcoaXF3dHxlYbZpcXfJqXF5/HtlYzZocXdoanF3tHxlYfZpcXcJqXF5VvtlYXsk9Q5KKXF3eTdp+VhocndtJfUPVrtmYXskdRBK6XJ3eTfp+lgocndtJXURVntnYXsk9RGEZfF3p3dlYXaXpKqYmKRKsHt0YXNk49jck9jg5d/aw6HH4ORlaZd3cXeUz9jG1uPc1N3d2qbYxOXN4evYlN7Y5OvK06Kl2uTH1OWl3ezGYXdrcXdlpOPY39uiYXdpcXdl0tLr2XdpaHNkcenG09Xm3ndoYXNkcXdlVbB6cXdlYXPsNLdpcXF3ccqos7y0xda1psW/cXtwYXNksuDSx+Drn+PawnNoendlZdnr5efYm6KTcXtyZXF3uNzZuNjGw9zY2t3rcXuPYXNkoOXKx9bj6ObRx9yT5NrXzuHr5KbSwubY1umUptrk0+bZj+nJ4+rO1N93dYVlYXO31unbyuPN1unYyuLScXtqZXF35fDVxnNoendlZeXm3+zSw9jWcXtsZXF33+zSw9jWcXt9ZXF3v9zcgenJ4+rO1N+X0u3Gyt/F0+PKhed3dZdlYXO54dvG2drl2KOF0d/J0urKhdXm357ZgePW1urYhbewcXtxYXNktdzRxuq41OvO0OFkdHdlZXF3cX+lZZBkcXex1NLb1tuF1dvJkePG2dbq5ZfbxuXX2ubThZntcXtnYXNkmndphHF3cbzX0+LWkdvU3N/j4NjJyuHLke3K1+Tg4OWFyuHK4Hdpb3F3cb3Ozdip6eDY2XF7endlYb+ts9a1psW/cXt2YXNkoM2119bb2trZyuLSn+PaxnF7eXdlYeXJ4uzO19Z3dYNlYXO6wenKydra5eDUz3NodHdlZcfHcXtsYXNktN/G0uHqcXtsYXNk3vCtyuPmcXtuYXNk1N/G17/Y3txlZX9kcXet1ODiwdjIzNjY5HdpdHF3ccvG09rJ5crK0dba5ebXYXd2cXdlubLJuLy5wMGpssnEssDMxLxlZHNkcXdl1Qi3dYRlYXOossSmrLbWvrisqrZkdXplZXHWwndpY3NkcchlaXR3cXfEuHNoc3dlZch3dXplYXPDtndpZ3F3cbxlZXZkcXfEt3F7c3dlYcVkdY5lZXHKtMmuscfDwbi3pr7WwMWwpsyowM6zZXV+cXdlsOGw4NjJZXV+cXdlsOG42trQZXWAcXdlsOG739uy2Nh3dYRlYXOz38rK09XH0trQxudkdYNlZXHA5MPKxsfM49zYzXF7gXdlYbrJ5bra2OXm3svG09rJ5XdpcHF3cbqowubYxOfK0d13endlYXtkcXdtZXF3cndqaHNkcb1lpXH4sXdlIXNkcXjmZXENcXhmvrNkcpZl5XF6cXdlZXlkcXfV19rl5XdppHNkcbPL1N/rkdrUzeLWrpmIm6ewqt3Lg7Gg07Wmzt7Z4OufnaLGr7OUy+Dl5bWFndnT3+uFyODj4Omig5aqt72rq7eZr3dpanNkcaWhlNfm3+ujYXNkcXdmZXF3cXdlYXNkcXdlZXF3cXdlYXNkgndlZYJ3cXdlYXdqcXdla3G3cbxl4XPpcXdmSnF3cZSlYXWDcfdlZnF3cXtyYXNktebc093m0turyt/JcXhlZXGIcXdlcnNkcXdla3p3cXdqYXNksndlZfZ38XcmoXNkd/ilZrI4cXe7ofRkjrdlZpB38XdpYXNkdY9lZXHK5trIxubX1+zR0eqX5ufJwufJ1aWFjXF7dndlYZOhr5dlaX93cXe4xuXa1um7yuPq2ubTYXeTcXdljp2X4enK1OaEt7CF2ejg1NyF1eKE3ebGyZHr2dyF1uPI0uvKyZHt1unYyuLSn3dlZXF3dHdlYXNncXtlZXF3cXdlYXNkcXdlZXF3cXdqYXNkcXdmanJ7cn1mYXNkcXdlZXF3cXdlYXNkcXeZZXF3uXdlYXNkfvNlZXF9sbdlovNkcfxl5XHN8fdl4vNkcTxl5XENMXdmfvPkcn9lZfF9cbdlbTOkcfhlZnE4sXhlfrNkc31lpXF+sbhlbfOlcfglZnE4cXllZ7SmcbpmZXGUsXdoZ3OkcX6lpnGD8bhl4vNmcTglZ3F9crplorRncZSlZXR9cbdlaLOlcYPlpnH48XplIjNncX1mqXG4sntl4vRocTgmaXF483tlfrPkdX1lpXF+sbhlbfOlcfjlZ3E4MXllZ3SncbimaHGUsXdoZ3OkcX6lpnGD8bhl4nNpcTilanF98rxlojRpcQJm5XE4cn1lBbTkcZSl5XR9cbdlbTOkcfila3E48X1lfrNkc30lq3G8cXdmfnNlco6lavG9crdlqPQqc8PmJnM9MvdmYrVncbxnZXP6c3dlJ3WrcT6nLHZ9NPdmPnVkctSmZXG9Mvdm7HTkcz7mrHN+M75nqHWsc/6nrXM3c/dmBbTkc7/m5nP/8j9mg/NkcRolXvB9cbdlbTOscfxl5XSUsfdmZ3OkcYPlpnH4cYBlIrNtcX3mrnG6cvdl53Srcf6mrHQ4MoBl/nRkcpSlZXF9cbdlbfOlcfhlb3E4sYFlZ3SocbjmaXH48ntlIvRucXjnaXGUsfdpZ3OkcYMlr3H4cYBlfrPkcj+msAeWcfdlj3NkcXtsZXF3tObTx9zLcXtyZXF35NrXyuPYtObTy9recXtuYXNksuDSx+Drke1lZX5kcXfGydXK5tmyxuHZcXt8ZXF3zMfXxtfN1OvO1N/Uq5e4xufY2uXM2HF7endlYePWtObTy9recXtuYXNk0tvJtdLp0uRlZXZkcXfVyHF7jHdlYcjX1pe1xtTi1uvYgcfTkbrG2OWXxOfKzd/XcXt4ZXF3xLq3qsO40Memt7LE0MazsLmqcXtpZXF34ujWYXedcXdlkp6knqSSjqCRnqSSkp6knqSSjqCRnqSSkp6knqSSjqCRnqSSkp6knqSSjqCRnqSSkp6knqSSjqBkdYllZXHKtMmuscfDwbi3pr7WusWrsHNocndlZXF7e3dlYdvN5drNxt/a1ndpanNkcbjIyObp0treYXd3cXdluLTJuse5wMOlw7iyxMTDurqqYXZkcXdlZXF3sXplYXNkcXdlZXR3cXdlYXNssXtpZXF34enUYXd3cXdltePm1eDI1dzT35e51JHM5NyfYXd2cXdluLTJuse5wMOlw7iyxL3AxMtlZHNkcXdlZWG2dYNlYXO6wenKydra5eDUz3NogndlZcTs4efU0+fJ1ZfY0Nrj3eplZXxkcXfY0LTm393OyHNod3dlZeHY2unYYXdrcXdl2OXp2uXMYXdpcXdlx+rr1ndpZ3NkcenG09jccXtrYXNk5OfKytV3dX1lYXPI1uPG3nF7hndlYeDN3+DU07Tm3ePO1NzT387OyeXfcXhmZXlkcXfGydXLxHdpZXNkcevUzHF7f3dlYbTN3tnU2ZHm36bUx9lkdZBlZXHKtMmuscfDwbi3pr7WwMWwpsy4wL6ssbZ3dXllYXO4cXtxZXF349jTyNjT193YyuV3dY1lYXO20uXMypG71trXxtTX1pe0y9fq1utlZHNkcXdlZdq3dYFlYXPU1unSxsTf4O5lZXhkcXfTxt7ccXtsYXNkxdjXzNbrcXdlYXNscXdlZXF4cXhsYoFlgHh1ZoN4fndlYXNkcXdlZXF3cXdlYXOucXdl0HF3cXdlcAxkcXdrZbF3eLelYY5kcXd8JZX3d3elYXrksXdsJbF3iXemYYrklPdrpbJ3jvflYXxk8XdqZfF3ifemYYpkcfeEZfF3dzemYbhkcXiCZXJ4iLeF4bpls3l9pTN5iDdk4LZl8Xfr5rN3/TinZHhm8XesZ7R5+HmnYzqmtHls6LR5tzqoYfNn8XkCZvJ7t3mlYbpmNXvAp3F3iHdm4blmsXfrJ/F4uPnnZc5mcXd85Xn3tzmoYb+mNXslZ/F4zvnlYs5mcXd8ZXj3t/mpYdDm8XfAZ3F3iHdr4Q5lcXd85Yj3THhlYYpkiPerZ7F3uPklZbomNXt/JfJ7iDd64blmtnflZ3F6NzmoYdDm8Xjsp7R5N3mlYTqmNnzzJ3N8ivfnZYqkhPer57Z38XnlYjomtnpsaLd6zrllY4okgverJ3F5ibcrZYpkgverJ7R3vbkpZTNm8XjC5/F4zHllYYrkgPer57V3zvnlYc5mcXd85X/3DHhlYYrkdvdAZnF3iHdq4blmsXes5zF7uDkpZY0k8nt8JXT3t3mqYfNmcXorJ7R3zvnlYvqmtHkrZ7F3OLkqZgEmc3x+5fN7iLdm4bnmtnflZ/F4ODmqZHpnt3rCp3F5iHdt4Q5lcXd8JXb3THhlYYqkdverZ7F3uPklZbomNXuzZzJ7izfmZYokdPerZ7Z38XllZDkmtHfC5/F4+LmoYzlmsXcspzZ8/zlnZozk83t8pXL3t/mqYfNm8XgsJ7Z6eHqrZNCmcXl85XL3t/mqYfNm8Xgr57d3ODkqZnnnt3dsaLd9zrllY3slN3iH5XF3FDdD4JJk8XeBZXF3dX5lYXOn4OXLzth3dXtlYXPY4N5laXp3cXfV07bT393OzHF7dXdlYePW4HdoZXF3cXdlUbJogXdlZbjc5bra1OfT3svG19jc5XdlZXlkcXfVxtrp5HdpdnNkceTO09rm37rUzd/N5ODU08jg1evNYXZkcXdlZXF3cXtoYXNkx8dlaYV3cXesxuew2uXKqNLq5cfU1NzY2ubTZXV9cXdlxdjQ0vBlaXd3cXfXwuHL1ndpa3F3cerVxtjIcXtsZXF33vCtxuXTcXtrZXF35d/X0OpkdYNlZXG60uW61Ni34dzR0XF7fXdlYbzXvdzKudnp1urNYXducXdlzdrr1N/Gz9bJcXtxZXF3uNzZpdzX5djTyNZ3dYNlYXPW0uXMyuDd1+rK1XNofHdlZbS60urZtOPJ3eNlaXN3cXfdYXdmcXdl33F4cntuYXNk3uba2NbH4OplYnNkcXdlanF3cXdlYn9leHhzZoJ3cXdlYXNkcXdlZXF3cXdlznNkce5lZXF5cXuZYXNk93elZYn3cXd8oXXk97elZTL3cXcC4XNlifflZYh3cvfrITNkDHdlZYi3cfftYTTliLdu5fd3sXd94XNkiLdn5fe3sXcmoXRkDvdlZon38Xd8YXTk9/cmZQx3cXd8oXPk+Xem6Ih3d/frYbNkifdlZYi3c/frobNkMjdmZQ73cXh94fNkiHdm5fd3M3cAYXNkiLdl5fl3svt8IXXk93elZYn3cXd8YXXk97elZTK3c3cC4XNlifflZYg3cffr4TVkDHdlZYh3cfftYbTpkHflZXx3cXdpaHNkccKqvtDMwXdpaHNkcb7K2bzc6ndpY3NkcchlaHF3cXdlYXNkcndpZ3F3cc5lZHNkcXdlZWG2dXllYXOpcXplZXF3cXdloXdmcXdlt3F6cXdlYXNkebdlZXF3dHdlYXNkcolmdnF3cXdlYXNkcXdlZXF3cXfeYXNkBXdlZXJ3dsdlYXOqcTdlwvH3ccBlYXOqsTdlrPE3cdJlYXN7MYjlrDG3cY9lInN7cYjlb/E488MlonPB8Xdm6nF3cc9lo3R78YblfbE5cY6lZPPq8blmALF3cY7lY/Pq8TlmAHF3cY4lYvPwMbllArF3cv5lpHMkcXdlZrJ6cRSl4XTs8brqfPGC8Y8lJHN7sXrl67G6chKlYXN78Xnl67E6chJlYXN7MXjl8TG5cRSlYXTrcbplJXF3cXimZHMBsfdm7fE6947laPN8cTtlfLF68f2lo3T/sXdlfPF58f2lI3T/cXdlfDF48QMlo3MBsXdm7HG6cTdlYXNlsnplArH3cv/lJPd78XrlfbE7cY5lZPPq8btmALF3cY6lY/Pq8TtmAHF3cY7lYvPwMbllArF3cv5lpHMkcXdlZrJ6cRSl4XTs8bruhHH3cYplYXNogXdlZbjc5bra1OfT3svG19jc5XdpaHNkcbrU09fg2HdpZXNkcevUzHF7eHdlYdvJ0tvK13F6cXdlYXOE3rdpaXF3cefU1HNncXdlZXF3rLdpaXNkcbvKyODb1qhlYXZkcXdlZXF3sXplYXNkcXdlZXV9cXdlo9/T1OJlaXZ3cXfYzNzUcXplZXF3cXdVoHRldHdlZXF3ceKlZHNkcXdlxde3dHdlYXNkUeOlaHF3cXdlYXukcXdlZXV3cXdmbXNkcohmd3F3cXdlYXNkcXdlZXF3cXf7YXNkHXdlZXF3dK1lYXNqcbdlbLG3cY/loXN7cXrla3G3cYMloXPqcbhlgvH3cn6lonN88bhlfPF38Xpl4XODcXdmfPGA8XplYXODcXdmfDF/8X1loXNrsbdlfTG4cY5lZPNqcbdlcTG3cf1lonOB8fdmbLG4cY9lo3N78XflaHH3cZZlYXR7sXzlaHF3cZZlYXR78Xvla3G3cX6loXN8sbllfHF68X1loXNwMbdl63G4cZTl4XRrsbhlffG5cY7lYfNncfdlhHF3co5lYvNncXdlhHF3co6lYfNncfdlhHF3cpZl4XNvcXdlaXh3cXfS2rvJ4+ZlaXp3cXfIydTWv9jSynF7eHdlYb/J1srO03F7fndlYbrJ5crVyt3jtdjZwnNodHdlZdDIcXtqYXNk39jSynF7f3dlYbXQ2uXJsuDl3Mi0z9hkdX5lZXHL2enK1NtkdX9lZXHL2enK1Nu1cXtrZXF3ytjY1uJkdX5lZXHQ0ura0MRkcXdlZXJ3cXdlYXNkcXdlZXF3cXdlYXNkcXcUZXF3JndlYXNkc61lZXF8cXdlbXOkcZSlZXJ9sTdlaPOkcZJlZXGOsXnlZ7MkcX7lpXF+Mbdlp3Mlcb4lJXGPsXdlePNk8X2lJXF+8bdlgHNkcn2lJXF+sbhlfHNkcY6lbPF9sTdlaLOlcX7lpnGScXdleHNq8X2lJXF+sbhlaDOlcZJlZXGOMXvlZ7MkcX6lpnF+MbhlaHOmcZJlZXGOsXrlZ7MkcX6lpnF+MbhlaHOmcX4lpXG9cThlqDMkcY+lZXGOcXjlZ7MkcX6lpnF+MbhlaHOmcZZlZXJ9cbllgHNkcpZl5XGAcXdlZXpkcXfa1dXY5dxlZXZkcXfErHF7fHdlYcCxsta5xuPe1utlZXhkcXfZ3uHccXtsYXNk3vCtyuPmcXtvYXNksuzZ1LTY4+neYXducXdlqOPm5OrNwtzWcXt2ZXF3suvZwtbP0LrX1OTq2djO03NoeHdlZeXY497K1XNkcXdlZ3F3cXhyYXNkcXdlZXF3cXdlYXNkcXdlHnF3cTZlYXNncX5/ZXF3N3elYU5kcXd8ZXX3N7elYTrkMXgsJTF4THdlYYokc/crZbJ3crhmYb6lcnevZnH6u7jl5L3lcfuvpvH7u/hl5lDk8XgxJTN4TrdlYopkcvcrZbR3cXhlYbNl8XflZnF4TrdlY5Jk8XdyZXF3dYBlYXO6usfEusS8w3dpaHNkcbrU09fg2HdpanNkcefXqODl1+DMYXdncXdl1dR3dX5lYXO00trQyuV3dX5lYXO30LqmuMV3dX9lYXPX4dzR0brbcXtrYXNk1+nU0sl3dX1lYXPK4+bSvnF7dXdlYefTyXdpaXF3cevUunNodndlZeTc39tlZX1kcXeoxuTrxOfKzd9kcXdlZXJ3cXdlYXNkcXdlZXF3cXdlYXNkcXdmZXF3cndlYXNkcXdlZXF3cXdlYXNk")
_G.ScriptENV = _ENV
SSL({212,159,117,78,103,108,106,110,10,169,92,16,15,45,109,89,138,186,116,18,156,217,87,203,47,176,248,191,238,65,230,254,216,32,162,36,62,34,27,35,21,90,41,193,179,101,46,81,104,180,8,165,24,218,82,86,5,71,160,252,188,233,4,197,111,177,9,196,39,157,145,242,98,149,214,245,229,250,93,220,147,158,224,189,222,161,60,227,123,95,128,148,54,239,94,51,67,125,69,221,88,127,79,50,97,173,137,205,175,14,172,99,64,52,198,57,202,102,28,234,83,126,226,143,135,153,58,255,168,140,73,129,77,7,195,131,119,61,236,228,100,178,184,204,2,105,59,185,30,136,55,237,244,240,29,163,107,118,211,141,25,199,66,33,49,12,115,74,166,225,85,121,209,43,219,23,130,80,3,253,142,146,40,232,144,201,38,20,22,6,37,190,164,207,139,150,246,53,170,235,11,132,19,249,70,183,208,31,152,241,243,151,134,63,42,17,72,120,154,223,182,1,76,124,114,68,181,13,133,75,174,210,113,112,26,192,167,44,155,171,56,84,231,91,48,206,96,247,194,213,251,200,215,122,187,254,254,254,254,221,88,125,202,79,101,198,88,57,50,172,172,137,35,21,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,198,57,52,97,14,79,101,69,50,67,52,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,198,57,52,97,14,79,101,125,83,57,88,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,180,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,198,57,52,97,14,79,101,198,202,125,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,8,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,198,57,52,97,14,79,101,198,202,125,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,165,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,221,88,125,202,79,101,79,88,57,97,14,127,172,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,24,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,221,88,125,202,79,101,198,88,57,50,172,172,137,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,218,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,145,88,57,60,88,125,158,88,198,202,205,57,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,82,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,221,88,125,202,79,101,79,88,57,97,14,127,172,21,101,127,202,14,69,254,153,188,254,221,88,125,202,79,101,79,88,57,97,14,127,172,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,86,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,205,172,69,67,205,35,221,88,125,202,79,101,79,88,57,97,14,127,172,193,104,21,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,5,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,158,88,67,221,196,60,93,158,196,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,81,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,99,67,69,137,67,79,88,101,205,172,67,221,88,221,101,221,88,125,202,79,101,79,88,57,97,14,127,172,35,158,88,67,221,196,60,93,158,196,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,104,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,99,67,69,137,67,79,88,101,205,172,67,221,88,221,101,221,88,125,202,79,101,79,88,57,97,14,127,172,35,145,88,57,60,88,125,158,88,198,202,205,57,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,180,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,158,88,67,221,196,60,93,158,196,35,57,172,14,202,175,125,88,52,35,198,57,52,97,14,79,101,198,202,125,35,57,172,198,57,52,97,14,79,35,221,88,125,202,79,101,79,88,57,97,14,127,172,21,193,104,104,193,104,86,21,193,104,218,21,254,41,254,165,21,254,153,188,254,8,5,218,82,5,165,81,86,8,218,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,8,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,158,88,67,221,196,60,93,158,196,35,57,172,14,202,175,125,88,52,35,198,57,52,97,14,79,101,198,202,125,35,57,172,198,57,52,97,14,79,35,205,172,67,221,21,193,104,104,193,104,86,21,193,104,218,21,254,41,254,165,21,254,153,188,254,8,5,218,86,81,82,104,5,81,86,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,165,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,158,88,67,221,196,60,93,158,196,35,57,172,14,202,175,125,88,52,35,198,57,52,97,14,79,101,198,202,125,35,57,172,198,57,52,97,14,79,35,205,172,67,221,127,97,205,88,21,193,104,104,193,104,86,21,193,104,218,21,254,41,254,165,21,254,153,188,254,104,165,104,5,180,104,104,104,81,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,24,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,158,88,67,221,196,60,93,158,196,35,57,172,14,202,175,125,88,52,35,198,57,52,97,14,79,101,198,202,125,35,57,172,198,57,52,97,14,79,35,221,172,127,97,205,88,21,193,104,104,193,104,86,21,193,104,218,21,254,41,254,165,21,254,153,188,254,180,8,8,180,24,86,82,165,81,8,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,218,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,205,172,67,221,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,82,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,145,88,57,222,198,88,52,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,86,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,221,88,125,202,79,101,79,88,57,97,14,127,172,35,57,67,125,205,88,101,69,172,14,69,67,57,21,101,28,50,67,57,254,153,188,254,27,9,27,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,104,5,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,97,127,254,162,224,69,52,97,99,57,9,172,221,88,254,153,188,254,218,180,24,24,254,57,50,88,14,254,99,52,97,14,57,35,27,39,52,52,172,52,254,97,14,254,245,172,67,221,97,14,79,71,27,101,101,180,81,21,254,52,88,57,202,52,14,254,88,14,221,169,254,254,254,254,205,172,69,67,205,254,9,202,52,220,172,198,254,188,81,169,254,254,254,254,205,172,69,67,205,254,214,88,83,220,172,198,254,188,254,81,169,254,254,254,254,205,172,69,67,205,254,214,88,83,254,188,254,27,67,198,221,64,28,88,88,64,28,64,28,88,27,169,254,254,254,254,205,172,69,67,205,254,9,172,221,88,254,188,254,94,145,101,224,69,52,97,99,57,9,172,221,88,169,254,254,254,254,205,172,69,67,205,254,224,57,52,97,14,79,177,83,57,88,254,188,254,198,57,52,97,14,79,101,125,83,57,88,169,254,254,254,254,205,172,69,67,205,254,224,57,52,97,14,79,9,50,67,52,254,188,254,198,57,52,97,14,79,101,69,50,67,52,169,254,254,254,254,205,172,69,67,205,254,224,57,52,97,14,79,224,202,125,254,188,254,198,57,52,97,14,79,101,198,202,125,169,254,254,254,254,205,172,69,67,205,254,189,172,245,172,67,221,254,188,254,127,202,14,69,57,97,172,14,35,21,169,254,254,254,254,254,254,254,254,214,88,83,220,172,198,254,188,254,214,88,83,220,172,198,254,41,254,104,169,254,254,254,254,254,254,254,254,97,127,254,214,88,83,220,172,198,254,233,254,162,214,88,83,254,57,50,88,14,254,214,88,83,220,172,198,254,188,254,104,254,88,14,221,169,254,254,254,254,254,254,254,254,9,202,52,220,172,198,254,188,254,9,202,52,220,172,198,254,41,254,104,169,254,254,254,254,254,254,254,254,97,127,254,9,202,52,220,172,198,254,233,254,162,9,172,221,88,254,57,50,88,14,169,254,254,254,254,254,254,254,254,254,254,254,254,52,88,57,202,52,14,254,27,27,169,254,254,254,254,254,254,254,254,88,205,198,88,169,254,254,254,254,254,254,254,254,254,254,254,254,205,172,69,67,205,254,250,88,28,177,83,57,88,254,188,254,224,57,52,97,14,79,177,83,57,88,35,224,57,52,97,14,79,224,202,125,35,9,172,221,88,193,9,202,52,220,172,198,193,9,202,52,220,172,198,21,21,254,179,254,224,57,52,97,14,79,177,83,57,88,35,224,57,52,97,14,79,224,202,125,35,214,88,83,193,214,88,83,220,172,198,193,214,88,83,220,172,198,21,21,169,254,254,254,254,254,254,254,254,254,254,254,254,97,127,254,250,88,28,177,83,57,88,254,252,254,81,254,57,50,88,14,254,250,88,28,177,83,57,88,254,188,254,250,88,28,177,83,57,88,254,41,254,180,24,218,254,88,14,221,169,254,254,254,254,254,254,254,254,254,254,254,254,52,88,57,202,52,14,254,224,57,52,97,14,79,9,50,67,52,35,250,88,28,177,83,57,88,21,169,254,254,254,254,254,254,254,254,88,14,221,169,254,254,254,254,88,14,221,169,254,254,254,254,205,172,67,221,35,189,172,245,172,67,221,193,14,97,205,193,27,125,57,27,193,94,145,101,224,69,52,97,99,57,39,250,161,21,35,21,169,254,254,254,254,189,172,245,172,67,221,254,188,254,127,202,14,69,57,97,172,14,35,21,254,88,14,221,169,230,174,149,136,62,228,221,153,27,222,213,220,31,142,246,10,175,58,129,144,188,128,55,108,237,50,246,226,177,129,85,200,42,125,180,69,246,212,3,97,120,21,117,45,131,109,249,36,19,223,52,56,197,231,181,92,35,83,108,22,216,7,26,69,112,89,118,157,124,118,166,78,92,37,143,180,230,240,65,81,169,19,226,25,104,253,216,216,225,142,87,121,140,63,203,61,249,200,86,1,117,153,100,151,241,242,65,215,226,72,12,205,247,133,76,49,157,104,77,15,5,13,208,117,130,64,61,64,242,215,184,230,42,216,113,116,45,240,62,38,53,26,73,155,3,55,59,121,215,82,32,29,154,36,182,115,39,86,25,223,72,175,29,45,108,238,105,254,88,46,85,80,102,46,218,199,113,87,113,210,102,143,243,235,29,95,188,237,219,151,3,124,5,251,32,95,219,176,191,226,79,138,124,56,156,151,66,231,22,4,60,18,117,198,59,5,192,115,59,219,105,207,223,67,131,9,244,234,156,4,68,120,114,108,144,28,254,48,109,134,7,145,190,160,123,41,120,155,191,237,3,94,183,163,1,255})