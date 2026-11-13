local Theme = {}

Theme.bg = Color3.fromRGB(30, 31, 34)
Theme.bgDark = Color3.fromRGB(23, 24, 27)
Theme.panel = Color3.fromRGB(41, 43, 47)
Theme.panelLight = Color3.fromRGB(50, 52, 57)
Theme.paneTop = Color3.fromRGB(57, 60, 67)
Theme.panelHeader = Color3.fromRGB(36, 38, 42)
Theme.row = Color3.fromRGB(41, 43, 47)
Theme.rowAlt = Color3.fromRGB(38, 40, 44)
Theme.rowActive = Color3.fromRGB(60, 63, 69)
Theme.divider = Color3.fromRGB(58, 61, 67)
Theme.nav = Color3.fromRGB(41, 43, 47)
Theme.navHover = Color3.fromRGB(60, 63, 69)
Theme.tabBar = Color3.fromRGB(36, 38, 42)

Theme.text = Color3.fromRGB(243, 244, 246)
Theme.textSoft = Color3.fromRGB(218, 220, 224)
Theme.textDim = Color3.fromRGB(178, 182, 190)
Theme.textMuted = Color3.fromRGB(142, 146, 154)

Theme.green = Color3.fromRGB(74, 127, 214)
Theme.greenHover = Color3.fromRGB(94, 146, 228)
Theme.greenShadow = Color3.fromRGB(42, 78, 140)

Theme.selBg = Color3.fromRGB(74, 78, 87)
Theme.selText = Color3.fromRGB(243, 244, 246)
Theme.selIcon = Color3.fromRGB(110, 160, 236)
Theme.unsel = Color3.fromRGB(48, 50, 55)
Theme.selEdge = Color3.fromRGB(74, 127, 214)
Theme.coral = Theme.green
Theme.accent = Theme.green
Theme.teal = Color3.fromRGB(46, 196, 182)
Theme.button = Color3.fromRGB(58, 61, 68)
Theme.buttonHover = Color3.fromRGB(70, 74, 82)
Theme.buttonShadow = Color3.fromRGB(26, 27, 30)
Theme.radius = 14
Theme.red = Color3.fromRGB(202, 52, 49)
Theme.redHover = Color3.fromRGB(222, 72, 66)
Theme.redShadow = Color3.fromRGB(130, 32, 30)
Theme.win = Color3.fromRGB(46, 196, 182)
Theme.loss = Color3.fromRGB(202, 52, 49)
Theme.draw = Color3.fromRGB(152, 151, 149)
Theme.gold = Color3.fromRGB(242, 190, 66)
Theme.puzzle = Color3.fromRGB(92, 182, 255)
Theme.outline = Color3.fromRGB(64, 68, 76)

Theme.amber = Color3.fromRGB(245, 176, 65)
Theme.blueSoft = Color3.fromRGB(110, 170, 255)
Theme.track = Color3.fromRGB(56, 59, 66)
Theme.glass = 0.25
Theme.edge = Color3.fromRGB(255, 255, 255)
Theme.rush = Color3.fromRGB(245, 166, 35)
Theme.donate = Color3.fromRGB(235, 82, 116)
Theme.token = Color3.fromRGB(255, 186, 58)
Theme.tasks = Color3.fromRGB(46, 196, 182)
Theme.vip = Color3.fromRGB(255, 204, 64)
Theme.vipHover = Color3.fromRGB(255, 220, 110)
Theme.vipShadow = Color3.fromRGB(176, 116, 16)
Theme.vipInk = Color3.fromRGB(64, 38, 4)

Theme.highlight = Color3.fromRGB(168, 146, 255)
Theme.highlightAlpha = 0.5
Theme.premove = Color3.fromRGB(244, 72, 60)
Theme.mark = Color3.fromRGB(235, 97, 80)
Theme.arrow = Color3.fromRGB(255, 170, 0)
Theme.check = Color3.fromRGB(255, 0, 0)

Theme.font = Font.fromEnum(Enum.Font.BuilderSans)
Theme.fontMedium = Font.fromEnum(Enum.Font.BuilderSansMedium)
Theme.fontBold = Font.fromEnum(Enum.Font.BuilderSansBold)

Theme.fontHeavy = Font.fromEnum(Enum.Font.BuilderSansExtraBold)
Theme.fontLogo = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy)
Theme.fontMono = Font.new(Font.fromEnum(Enum.Font.RobotoMono).Family, Enum.FontWeight.Bold)

return Theme