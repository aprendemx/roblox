script.Parent.Teleporter.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Name == "HumanoidRootPart" then
		hit.CFrame = script.Parent.Goal.CFrame + Vector3.new(0, 3.25, 0)
	end
end)