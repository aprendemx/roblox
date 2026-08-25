wait(0.2)
function OnClick(player)
	if player and (not player.PlayerGui:FindFirstChild("GUI")) then
	script.Parent.GUI:Clone().Parent = player.PlayerGui
		end
end
script.Parent.GUI.Button.V.Value = script.Parent
script.Parent.CD.MouseClick:connect(OnClick)
