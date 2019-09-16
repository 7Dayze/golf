local table_insert = table.insert

local roundCost = 500
local rentCost = 500
local scores = {}

function collapseTable(s)
  local newTable = {}
  for _,v in pairs(s) do
    if (v ~= nil) then
      table_insert(newTable, v)
    end
  end

  return newTable
end

RegisterServerEvent("bms:golf:startRound")
AddEventHandler("bms:golf:startRound", function()
  local src = source

  TriggerEvent("es:getPlayerFromId", src, function(user)
    if (user) then
      local money = user.get("charMoney")

      if (money >= roundCost) then
        exports.characters:takeMoneyFromChar(user, roundCost, string.format("Player %s (%s) has started a round of golf for %s", user.get("activeChar"), user.getIdentifier(), roundCost), function()
          TriggerClientEvent("bms:golf:startRound", src, {success = true, msg = string.format("You have rented clubs for <font color='lightgreen'>$%s</font>. Head to the first hole and begin your game. <font color='aqua'>Good luck!</font>", roundCost)})
        end)
      else
        TriggerClientEvent("bms:golf:startRound", src, {success = false, msg = "You do not have enough money to rent the clubs."})
      end
    end
  end)
end)

RegisterServerEvent("bms:golf:sendShot")
AddEventHandler("bms:golf:sendShot", function(hole, strokes)
  local src = source

  TriggerEvent("es:getPlayerFromId", src, function(user)
    if (user) then
      local char = user.get("activeChar")
      local scoreExists = false

      for _,v in pairs(scores) do
        if (v.name == char) then
          scoreExists = true
          v.score[hole] = strokes
        end
      end

      if (not scoreExists) then
        local scoreCard = {name = char, score = {}}
        if (hole) then
          scoreCard.score[hole] = strokes
        end
        table_insert(scores, scoreCard)
      end

      print(exports.devtools:dump(scores))
    end
  end)
end)

RegisterServerEvent("bms:golf:clearScore")
AddEventHandler("bms:golf:clearScore", function()
  local src = source

  TriggerEvent("es:getPlayerFromId", src, function(user)
    if (user) then
      local char = user.get("activeChar")

      for i,v in pairs(scores) do
        if (v.name == char) then
          scores[i] = nil
        end
      end

      scores = collapseTable(scores)

      --print(exports.devtools:dump(scores))
    end
  end)
end)

RegisterServerEvent("bms:golf:getScores")
AddEventHandler("bms:golf:getScores", function()
  local src = source
  --print(exports.devtools:dump(scores))
  TriggerClientEvent("bms:golf:getScores", source, scores)
end)

RegisterServerEvent("bms:golf:rentGolfCart")
AddEventHandler("bms:golf:rentGolfCart", function()
  local src = source

  TriggerEvent("es:getPlayerFromId", src, function(user)
    if (user) then
      local money = user.get("charMoney")

      if (money >= rentCost) then
        exports.characters:takeMoneyFromChar(user, roundCost, string.format("Player %s (%s) has rented a golf cart for %s", user.get("activeChar"), user.getIdentifier(), rentCost), function()
          TriggerClientEvent("bms:golf:rentGolfCart", src, {success = true, msg = string.format("You have rented a golf cart for <font color='lightgreen'>$%s</font>.", rentCost)})
        end)
      else
        TriggerClientEvent("bms:golf:rentGolfCart", src, {success = false, msg = "You do not have enough money to rent this golf cart."})
      end
    end
  end)
end)

AddEventHandler("es:playerDropped", function(user)
  if (user) then
    local src = user.getSource()
    local char = user.get("activeChar")

    for i,v in pairs(scores) do
      if (v.name == char) then
        scores[i] = nil
      end
    end

    scores = collapseTable(scores)
  end
end)
