wait(0.2)
local cam=workspace.CurrentCamera
local player=game.Players.LocalPlayer
local Cam = script.Parent

game:GetService("RunService").RenderStepped:connect(function()
		cam.CameraSubject=Cam.Value
		cam.CameraType=("Scriptable")
		cam.CoordinateFrame = Cam.Value:GetRenderCFrame()
	 	player.CameraMaxZoomDistance=0
		cam.FieldOfView = 90
end)

script.Parent.Parent.MouseButton1Click:connect(function()
cam.CameraType = ("Custom")
cam.CameraSubject=player.Character.Humanoid
player.CameraMaxZoomDistance=300
cam.FieldOfView = 70
script.Parent.Parent.Parent:Destroy()
end)

while wait() do
	if player.Character.Humanoid.Health == 0 then
		cam.CameraType = ("Custom")
cam.CameraSubject=player.Character.Humanoid
player.CameraMaxZoomDistance=300
cam.FieldOfView = 70
script.Parent.Parent.Parent:Destroy()
	end
end