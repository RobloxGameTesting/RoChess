local ReplicatedStorage = game:GetService("ReplicatedStorage")

local App = require(ReplicatedStorage:WaitForChild("ChessClient"):WaitForChild("App"))
App.start()