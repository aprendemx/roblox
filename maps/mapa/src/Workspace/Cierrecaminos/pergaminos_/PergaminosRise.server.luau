local folder = script.Parent
local RISE_DELAY = 900 -- 15 minutos en segundos
local RISE_HEIGHT = 15 -- 15 unidades en Y

task.wait(RISE_DELAY)

for _, child in folder:GetChildren() do
	if child:IsA("Model") then
		local currentPivot = child:GetPivot()
		local newPivot = currentPivot + Vector3.new(0, RISE_HEIGHT, 0)
		child:PivotTo(newPivot)
	elseif child:IsA("BasePart") then
		child.CFrame = child.CFrame + Vector3.new(0, RISE_HEIGHT, 0)
	end
end