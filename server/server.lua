ESX = exports["es_extended"]:getSharedObject()

Markets = {
    -- ['market_1'] = {
    --     label = 'LTD BALLAS',
    --     pos = vec3(-48.306820, -1757.828613, 29.521013),
    --     interactDistance = 2,
    --     blip = {
    --         coords = vec3(-50.992729, -1756.042236, 29.421019),
    --         id = 59,
    --         display = 4,
    --         scale = 0.7,
    --         colour = 25,
    --         blipTitle = "LTD",
    --     },
    --     marker = {
    --         type = 23,
    --         scale = {0.7, 0.7, 0.7},
    --         rgba = {0, 255, 0, 255},
    --         distance = 7.0
    --     },
    --     items = {
    --         {label = "Pain", name = "bread", price = 10, emoji = "🥖"},
    --         {label = "Eau", name = "water", price = 15, emoji = "🧋"},
    --         {label = "Radio", name = "radio", price = 150},
    --     }
        
    -- }, 
    -- ['market_2'] = {
    --     label = 'LTD 2',
    --     pos = vec3(25.709530, -1346.787109, 29.597032),
    --     interactDistance = 2,
    --     blip = {
    --         coords = vec3(25.709530, -1346.787109, 28.597032),
    --         id = 59,
    --         display = 4,
    --         scale = 0.7,
    --         colour = 25,
    --         blipTitle = "LTD 2",
    --     },
    --     marker = {
    --         type = 23,
    --         scale = {0.7, 0.7, 0.7},
    --         rgba = {0, 255, 0, 255},
    --         distance = 7.0
    --     },
    --     items = {
    --         {label = "Pain", name = "bread", price = 10, emoji = "🥖"},
    --         {label = "Eau", name = "water", price = 15, emoji = "🧋"},
    --     }
        
    -- }
}
RegisterNetEvent('market:server:buyitem')
AddEventHandler('market:server:buyitem', function(item, quantity, name)
    if Markets[name] then
        local player = ESX.GetPlayerFromId(source)
        local price = item.price * quantity
        local pos = GetEntityCoords(GetPlayerPed(source))
        local dist = #(pos - Markets[name].pos)
        if dist < 5 then
            if player.getAccount("money").money >= price then
                if exports.inventory:CanCarryItem(player.source, item.name,quantity) then
                    player.removeAccountMoney("money", price)
                    exports.inventory:AddItem(player.source, item.name, quantity)
                    player.showNotification("~g~Vous avez reçu ~s~x"..quantity.." "..item.label.." ~g~, vous avez payé ~s~$"..price)
                else
                    player.showNotification("~g~Vous n'avez pas asse de place dans votre inventaire pour acheter ~s~x"..quantity.." "..item.label)
                end
            else
                player.showNotification("Vous ne pouvez pas payer, il vous manque $~g~"..(price-player.getAccount("money").money).."~s~")
            end
        else
            player.showNotification("Achat annulé, vous êtes trop loin du vendeur !")
        end
    else
        DropPlayer(source, "Eh bah non sale batar")
    end
end)


RegisterNetEvent('market:server:canOpenGest')
AddEventHandler('market:server:canOpenGest', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getGroup() == "admin" then
        TriggerClientEvent('market:client:openMenu', source)
    end
end)

RegisterNetEvent('market:server:createShop')
AddEventHandler('market:server:createShop', function(market)
    print('Received data '..json.encode(market))
    Markets[market.name] = {
        label = market.label,
        pos = market.pos,
        interactDistance = market.interact,
        blip = {
            coords = market.pos,
            id = market.blip.type,
            display = market.blip.display,
            scale = market.blip.scale,
            colour = market.blip.colour,
            blipTitle = market.blip.title,
        },
        marker = {
            type = market.marker.type,
            scale = {market.marker.scale[1], market.marker.scale[2], market.marker.scale[3]},
            rgba = {market.marker.rgba[1], market.marker.rgba[2], market.marker.rgba[3], market.marker.rgba[4]},
            distance = market.marker.distance
        },
        items = market.items
    }
    MySQL.Async.execute('INSERT INTO markets (name, data) VALUES (@name, @data)', {
        ['@name'] = market.name,
        ['@data'] = json.encode(Markets[market.name])
    })
    TriggerClientEvent('updateMarkets', -1, Markets)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerClientEvent('updateMarkets', -1, Markets)
end)

MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM markets', {}, function(results)
        print('^0[^2!^0] ^2av_marketbuilder ^0=> La base de données a chargé ^3' .. #results .. ' ^0LTD enregistrés')
        for k, v in pairs(results) do
            market = json.decode(v.data)
            Markets[v.name] = {
                label = market.label,
                pos = vector3(market.blip.coords.x, market.blip.coords.y, market.blip.coords.z),
                interactDistance = market.interactDistance,
                blip = {
                    coords = vector3(market.blip.coords.x, market.blip.coords.y, market.blip.coords.z),
                    id = market.blip.id,
                    display = market.blip.display,
                    scale = market.blip.scale,
                    colour = market.blip.colour,
                    blipTitle = market.blip.title,
                },
                marker = {
                    type = market.marker.type,
                    scale = {market.marker.scale[1], market.marker.scale[2], market.marker.scale[3]},
                    rgba = {market.marker.rgba[1], market.marker.rgba[2], market.marker.rgba[3], market.marker.rgba[4]},
                    distance = market.marker.distance
                },
                items = market.items
            }
        end
    end)
    TriggerClientEvent('updateMarkets', -1, Markets)
end)

Citizen.CreateThread(function()
    while true do
        TriggerClientEvent('updateMarkets', -1, Markets)
        Citizen.Wait(15000)
    end
end)


RegisterNetEvent("market:server:deletemarket", function(name)
    Markets[name] = nil
    MySQL.Async.execute('DELETE FROM markets WHERE name=@name', {
        ['@name'] = name,
    }, function(rowAffected)
        print('^0[^2!^0] ^2av_marketbuilder ^0=> La base de données a supprimé le LTD: ^3'..name.." ^7")
        TriggerClientEvent('updateMarkets', -1, Markets)
    end)
end)