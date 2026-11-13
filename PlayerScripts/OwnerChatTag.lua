local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer

local v = {
	[8839297805] = "<font color=\"#FF4B4B\"><b>[RoChess Creator]</b></font> ",
	[573649346] = "<font color=\"#1E9446\"><b>[RoChess Developer]</b></font> "
}

local v2 = {
	donated = "#FF80C4",
	bullet = "#FFC45C",
	blitz = "#78BAFF",
	rapid = "#96D668",
	puzzle = "#FFAA60",
	wins = "#68D6B4",
	playtime = "#BA9CFF"
}

local v3 = nil
task.spawn(function()
	local success, result = pcall(function()
		return require(ReplicatedStorage:WaitForChild("ChessClient"):WaitForChild("App"))
	end)

	if success then
		v3 = result
	end
end)

local function lbTagFor(userId)
	local v4 = nil
	local v5 = nil

	if userId == LocalPlayer.UserId then
		local lbTag = v3 and v3.profile and v3.profile.lbTag

		if type(lbTag) == "table" then
			v4 = lbTag.text
			v5 = lbTag.board
		end
	else
		local playerByUserId = Players:GetPlayerByUserId(userId)

		if playerByUserId then
			v4 = playerByUserId:GetAttribute("LbTag")
			v5 = playerByUserId:GetAttribute("LbTagBoard")
		end
	end

	if type(v4) ~= "string" or v4 == "" then
		return nil
	end

	local v6 = v2[v5] or "#FFFFFF"
	return string.format("<font color=\"%s\"><b>[%s]</b></font> ", v6, v4)
end

TextChatService.OnIncomingMessage = function(p)
	local textChatMessageProperties = Instance.new("TextChatMessageProperties")
	local textSource = p.TextSource

	if not textSource then
		return textChatMessageProperties
	end

	local v4 = (v[textSource.UserId] or "") .. (lbTagFor(textSource.UserId) or "")

	if v4 ~= "" then
		textChatMessageProperties.PrefixText = v4 .. p.PrefixText
	end

	return textChatMessageProperties
end