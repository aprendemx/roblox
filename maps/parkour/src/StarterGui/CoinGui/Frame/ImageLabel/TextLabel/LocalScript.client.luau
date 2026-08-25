local player = game.Players.LocalPlayer
local fruits = player:WaitForChild("leaderstats").Fruits

while true do 
	wait(0.01)
	script.Parent.Text = fruits.Value
end
