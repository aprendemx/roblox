local NPC = script.Parent
local Humanoid = NPC.Humanoid

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		local UserId = Player.UserId
		script.Parent.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(UserId))
		
	end)
end)

