local plr = game.Players.LocalPlayer
local spinning = false


--Config
local colors = 
	{
		common = Color3.new(0.517647, 0.596078, 0.682353),
		uncommon = Color3.new(0.105882, 0.584314, 0.568627),
		rare = Color3.new(0.0980392, 0.313725, 0.572549),
		epic = Color3.new(1, 0.8, 0),
		legendary = Color3.new(0.701961, 0.0627451, 0)
	}

local rarities = {"common", "uncommon", "rare", "epic", "legendary"}
local rarityTiers = 
	{
		["common"] = 50,
		["uncommon"] = 25,
		["rare"] = 15,
		["epic"] = 8,
		["legendary"] = 2
	}

local endNumber = 18
local totalOptions = 35
local rollSpeed = 3.5
local snapToFinalPositionSpeed = .5


































local optionsFolder = game.ReplicatedStorage.options
local TweenService = game:GetService("TweenService")
local rollTweenInfo = TweenInfo.new(rollSpeed, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local rollFinishTweenInfo = TweenInfo.new(snapToFinalPositionSpeed, Enum.EasingStyle.Exponential)

local crateEvent = game.ReplicatedStorage.events.crate
local getCratePrice = game.ReplicatedStorage.events.getPrice
local RunService = game:GetService("RunService")
local spinHolder = nil
local ticking = false
local startPos = nil
local index = 5

function rollRarity()
	local number = math.random(0,100)
	if number <= rarityTiers["common"] then
		return "common"
	elseif number > rarityTiers["common"] and number <= rarityTiers["common"] + rarityTiers["uncommon"] then
		return "uncommon"
	elseif number > (rarityTiers["common"] + rarityTiers["uncommon"]) and number <= (rarityTiers["common"] + rarityTiers["uncommon"] + rarityTiers["rare"]) then
		return "rare"
	elseif number > (rarityTiers["common"] + rarityTiers["uncommon"] + rarityTiers["rare"]) and number <= (rarityTiers["common"] + rarityTiers["uncommon"] + rarityTiers["rare"] + rarityTiers["epic"]) then
		return "epic"
	else
		return "legendary"
	end
end

function calcFinalPosition(f, h)
	local holder = 	h
	local frame = f

	local frameAbsPos = frame.AbsolutePosition.X
	local holderAbsPos = holder.AbsolutePosition.X
	local frameAbsSize = frame.AbsoluteSize.X
	local holderAbsSize = holder.AbsoluteSize.X

	local paddingAbsSize = holder:FindFirstChild("UIPadding").PaddingLeft.Scale * holderAbsSize

	local pos1 = frameAbsPos - (holderAbsPos - frameAbsSize/2) - frameAbsSize/2 - (holderAbsSize / (holder.Size.X.Scale * 2)) + paddingAbsSize/2
	local pos2 = frameAbsPos - (holderAbsPos - frameAbsSize) - frameAbsSize/2 - (holderAbsSize / (holder.Size.X.Scale * 2)) + paddingAbsSize/2
	local offset = math.random(5,math.floor((frameAbsSize) - 5))

	return {(pos1 * -1) -offset, (pos2 * -1)}
end

function sortByDescending(list)
	table.sort(list, function(a,b)
		return a.Name > b.Name
	end)
end

function sortByAscending(list)
	table.sort(list, function(a,b)
		return a.Name < b.Name
	end)
end

function generateCrateUiOptions(typeOfCrate)
	local crateGui = plr.PlayerGui:WaitForChild("crateGui")
	local crateFrame = crateGui.displayFrame.crateFrame
	local spinHolder = crateFrame.spinFrame.innerFrame.spinHolder
	
	for _, rarityName in ipairs(rarities) do
		crateFrame.purchaseFrame[rarityName.."Rarity"].Text = string.upper(rarityName).. " - ".. rarityTiers[rarityName] .."%"
	end

	for i = 1, totalOptions do
		local rarity = rollRarity()
		local rarityOptions = optionsFolder[rarity]:GetChildren()
		local index = math.random(1, #rarityOptions)
		local item = rarityOptions[index]

		local frame = spinHolder[i]
		frame.UIStroke.Color = colors[rarity]
		if game.ReplicatedStorage.icons:FindFirstChild(item.Name) then
			frame.icon.Image = game.ReplicatedStorage.icons[item.Name].Texture
		else
			frame.icon.Image = game.ReplicatedStorage.icons.Error.Texture
		end
	end
end

function generateCrateDrops(typeOfCrate)
	local crateGui = plr.PlayerGui:WaitForChild("crateGui")
	local crateFrame = crateGui.displayFrame.crateFrame
	local dropsFrame = crateFrame.dropsFrame
	local dropsHolder = dropsFrame.dropsHolder

		for i = #rarities, 1, -1 do
			local rarity = rarities[i]
			local listToSort = optionsFolder[rarity]:GetChildren()
			sortByAscending(listToSort)
			for j = 1, #optionsFolder[rarity]:GetChildren() do
			local dropDisplayFrame = game.ReplicatedStorage.dropDisplayFrame:Clone()

				local item = listToSort[j]
				dropDisplayFrame.itemName.Text = item.Name
				if game.ReplicatedStorage.icons:FindFirstChild(item.Name) then
					dropDisplayFrame.itemFrame.icon.Image = game.ReplicatedStorage.icons[item.Name].Texture
				else
					dropDisplayFrame.itemFrame.icon.Image = game.ReplicatedStorage.icons.Error.Texture
				end
				dropDisplayFrame.itemFrame.UIStroke.Color = colors[rarity]
				dropDisplayFrame.Parent = dropsHolder
			end
		end
		local cellSize = dropsHolder.AbsoluteSize.X/8
		local UIGridLayout = dropsHolder.UIGridLayout
			UIGridLayout.CellSize = UDim2.new(0,cellSize,0, cellSize)
		if dropsHolder.UIGridLayout.AbsoluteContentSize.Y > dropsHolder.AbsoluteSize.Y then
			dropsHolder.CanvasSize = UDim2.new(1,0,0,dropsHolder.UIGridLayout.AbsoluteContentSize.Y)
		end
end




--Crate result
crateEvent.OnClientEvent:Connect(function(item, rarity)
		spinning = true

		local crateGui = plr.PlayerGui:WaitForChild("crateGui")
		local crateFrame = crateGui.displayFrame.crateFrame
		spinHolder = crateFrame.spinFrame.innerFrame.spinHolder
		spinHolder.Position = UDim2.new(0,0,0,0)
		index = 1

		local endFrame = spinHolder[tostring(math.random(20,32))]
		endFrame.UIStroke.Color = colors[rarity]
		endFrame.icon.Image = game.ReplicatedStorage.icons[item.Name].Texture

		local endPosition = calcFinalPosition(endFrame, spinHolder)

		local rollTween = TweenService:Create(spinHolder, rollTweenInfo, {Position = UDim2.new(0,endPosition[1],0,0)})
		local finishTween = TweenService:Create(spinHolder, rollFinishTweenInfo, {Position = UDim2.new(0,endPosition[2],0,0)})

		game.ReplicatedStorage.soundEffectAssets.splash:Play()
		rollTween:Play()
		startPos = spinHolder.AbsolutePosition.X
		ticking = true

		rollTween.Completed:Connect(function()
			finishTween:Play()
		end)
		finishTween.Completed:Connect(function()
			game.ReplicatedStorage.soundEffectAssets[rarity]:Play()
			ticking = false
		end)
		local item = item:Clone()
		local frame = spinHolder[endNumber]
end)

generateCrateUiOptions()
generateCrateDrops()


local crateGui = plr.PlayerGui:WaitForChild("crateGui")
local crateFrame = crateGui.displayFrame.crateFrame
crateFrame.purchaseFrame.buyCrateButton.Activated:Connect(function()
	crateEvent:FireServer()
end)

RunService.RenderStepped:Connect(function()
	if ticking then
		if math.ceil(spinHolder.Parent.marker.AbsolutePosition.X) >= spinHolder[index].AbsolutePosition.X then
			game.ReplicatedStorage.soundEffectAssets.tick:Play()
			index+=1
		end
	end
end)
