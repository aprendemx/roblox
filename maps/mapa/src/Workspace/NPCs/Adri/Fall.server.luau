--[[Originally made by EpicDragonBall but edited by spyro328--]]
char = script.Parent
active = false

function onfall()
active = true
curr = 0
while active == true do
vel = char.Torso.Velocity.y
wait()
if vel > curr then
active = false
if curr < -80 then
char.Humanoid:TakeDamage((curr*curr)*0.004)
char.Torso.Velocity = char.Torso.Velocity * 0
end
else
curr = vel
end
end
end

char.Humanoid.FreeFalling:connect(function()
if active == false then
onfall()
end
end)