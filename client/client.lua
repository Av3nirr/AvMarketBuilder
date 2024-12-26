ESX = exports['es_extended']:getSharedObject()

-- Variables

MarketsBlips = {}
Markets = {}

BuyMenu = zUI.CreateMenu('', "", "ACHETER DES ARTICLES", "https://as1.ftcdn.net/v2/jpg/03/03/46/92/1000_F_303469293_trQsPvECtbAYyKW7JfavMPG7RG7SG1gz.jpg")
GestMenu = zUI.CreateMenu('', "", "Gestionnaire de LTD", "https://as1.ftcdn.net/v2/jpg/03/03/46/92/1000_F_303469293_trQsPvECtbAYyKW7JfavMPG7RG7SG1gz.jpg")
CreateMarket = zUI.CreateSubMenu(GestMenu, "", "", "Créer un LTD", "https://as1.ftcdn.net/v2/jpg/03/03/46/92/1000_F_303469293_trQsPvECtbAYyKW7JfavMPG7RG7SG1gz.jpg")
ListMenu = zUI.CreateSubMenu(GestMenu, "", "", "Liste des LTD", "https://as1.ftcdn.net/v2/jpg/03/03/46/92/1000_F_303469293_trQsPvECtbAYyKW7JfavMPG7RG7SG1gz.jpg")

-------------


function RefreshBlips()
    print('RefreshBlips '..json.encode(Markets))
    if MarketsBlips ~= {} then
        for name, blip in pairs(MarketsBlips) do
            RemoveBlip(blip)
            Debug('^2Removed blip: ^3'..blip..'^r')
        end
        MarketsBlips = {}
    end
    for name, market in pairs(Markets) do
        MarketsBlips[name] = AddBlipForCoord(market.blip.coords.x, market.blip.coords.y, market.blip.coords.z)
        SetBlipSprite(MarketsBlips[name], market.blip.id)
        SetBlipDisplay(MarketsBlips[name], market.blip.display)
        SetBlipScale(MarketsBlips[name], market.blip.scale)
        SetBlipColour(MarketsBlips[name], market.blip.colour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(market.blip.blipTitle)
        EndTextCommandSetBlipName(MarketsBlips[name])
        Debug('^2Added blip: ^3'..MarketsBlips[name]..'^7')
    end
end

local function getTableLength(tbl)
    local c = 0
    for _ in pairs(tbl) do
        c+=1
    end
    return c
end


CreateThread(function()
    RefreshBlips()
    TriggerServerEvent('market:server:loaded')
    local ped = PlayerPedId()
    while true do
        local spam = false
        local pos = GetEntityCoords(ped)
        for _, market in pairs(Markets) do
            local dist = #(pos - market.pos)
            if dist < market.marker.distance then
                spam = true
                DrawMarker(market.marker.type, market.pos.x, market.pos.y, market.pos.z-1,0, 0, 0, 0.1, 0.1, 0.1, market.marker.scale[1], market.marker.scale[2], market.marker.scale[3], market.marker.rgba[1], market.marker.rgba[2], market.marker.rgba[3], market.marker.rgba[4], false, false, 0, false, 0, 0, 0)
                if dist < market.interactDistance then
                    ShowHelpText("Appuyez sur ~INPUT_PICKUP~ pour accèder au magasin.")
                    if IsControlJustPressed(0, 38) then
                        CreateThread(function()
                            OpenMarket(_, market)
                        end)
                    end
                end
            end
        end
        if spam then
            Wait(1)
        else
            Wait(2000)
            ped = PlayerPedId()
        end
    end
end)

function OpenMarket(name, market)
    BuyMenu:SetItems(function(Items)
        if market.items == {} then
            Items:AddSeparator("~r~Aucun article !")
        else
            for k, item in ipairs(market.items) do
                Items:AddButton(item.label, nil, { RightLabel = "~g~$~s~"..item.price }, function (onSelected, onHovered)
                    if onSelected then
                        local data = zUI.ShowModal("Achat de "..item.label, {
                            { type = "number", name = "Quantitée", description = "Entrez la quantitée souhaitée", isRequired = true },
                        }, {})
                        TriggerServerEvent('market:server:buyitem', item, data['Quantitée'], name)
                    end
                end)
            end
        end
    end)
    BuyMenu:SetVisible(not BuyMenu:IsVisible())
end


function ShowHelpText(msg)
    zUI.ShowHelpNotification(msg, { Color = "#800080" })
end

RegisterCommand('gestMarkets', function()
    print("Gestrmareejof")
    TriggerServerEvent('market:server:canOpenGest')
end, false)

local function isCurrentCreationComplete()
    return CurrentCreation.name and CurrentCreation.label and CurrentCreation.pos and 
           CurrentCreation.interact and CurrentCreation.blip and 
           CurrentCreation.blip.type and CurrentCreation.blip.display and 
           CurrentCreation.blip.scale and CurrentCreation.blip.colour and 
           CurrentCreation.blip.title and CurrentCreation.marker and 
           CurrentCreation.marker.type and CurrentCreation.marker.scale and 
           CurrentCreation.marker.scale[1] and CurrentCreation.marker.scale[2] and 
           CurrentCreation.marker.scale[3] and CurrentCreation.marker.rgba and 
           CurrentCreation.marker.rgba[1] and CurrentCreation.marker.rgba[2] and 
           CurrentCreation.marker.rgba[3] and CurrentCreation.marker.rgba[4] and 
           CurrentCreation.marker.distance and CurrentCreation.items and 
           #CurrentCreation.items > 0
end
RegisterNetEvent('market:client:openMenu')
AddEventHandler('market:client:openMenu', function()
    print("Will open menu")
    CurrentCreation = {
        marker = {
            scale = {},
            rgba = {}
        },
        blip = {},
        items = {}
    }
    GestMenu:SetItems(function(Items)
        Items:AddButton('Créer un LTD', nil, { RightLabel = ">"}, function (onSelected, onHovered)
            if onSelected then
            end
        end, CreateMarket)
        Items:AddButton('Liste des LTD', nil, { RightLabel = "~r~"..getTableLength(Markets) }, function (onSelected, onHovered)
            if onSelected then
            end
        end, ListMenu)
    end)
    GestMenu:SetVisible(not GestMenu:IsVisible())
    CreateMarket:SetItems(function(Items)
        Items:AddButton('Nom', nil, { RightLabel = (CurrentCreation.name or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.name = Input("Nom du LTD", "Nom")
            end
        end)
        Items:AddButton('Label', nil, { RightLabel = (CurrentCreation.label or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.label = Input("Label du LTD", "Label")
            end
        end)
        Items:AddButton('Position', nil, { RightLabel = ""..(CurrentCreation.pos or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.pos = GetEntityCoords(PlayerPedId())
            end
        end)
        Items:AddButton('Distance d\'intercation', nil, { RightLabel = (CurrentCreation.interact or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.interact = tonumber(Input("Distance d'interaction", "Distance"))
            end
        end)
        Items:AddLine({"#00ff00"})
        Items:AddSeparator("Blip")
        Items:AddButton('Type', nil, { RightLabel = (CurrentCreation.blip.type or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.blip.type = tonumber(Input("Type du blip", "Type"))
            end
        end)
        Items:AddButton('Display', nil, { RightLabel = (CurrentCreation.blip.display or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.blip.display = tonumber(Input("Display du blip", "Display"))
            end
        end)
        Items:AddButton('Scale', nil, { RightLabel = (CurrentCreation.blip.scale or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.blip.scale = tonumber(Input("Scale du blip", "Scale"))
            end
        end)
        Items:AddButton('Couleur', nil, { RightLabel = (CurrentCreation.blip.colour or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.blip.colour = tonumber(Input("Couleur du blip", "Couleur"))
            end
        end)
        Items:AddButton('Titre', nil, { RightLabel = (CurrentCreation.blip.title or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.blip.title = Input("Titre du blip", "Titre")
            end
        end)
        Items:AddLine({"#00ff00"})
        Items:AddSeparator("Marker")
        Items:AddButton('Type', nil, { RightLabel = (CurrentCreation.marker.type or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.type = tonumber(Input("Type du marker", "Type"))
            end
        end)
        Items:AddButton('ScaleX', nil, { RightLabel = (CurrentCreation.marker.scale[1] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.scale[1] = tonumber(Input("Scale X du marker", "Scale X"))
            end
        end)
        Items:AddButton('ScaleY', nil, { RightLabel = (CurrentCreation.marker.scale[2] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.scale[2] = tonumber(Input("Scale Y du marker", "Scale Y"))
            end
        end)
        Items:AddButton('ScaleZ', nil, { RightLabel = (CurrentCreation.marker.scale[3] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.scale[3] = tonumber(Input("Scale Z du marker", "Scale Z"))
            end
        end)
        Items:AddButton('Couleur R', nil, { RightLabel = (CurrentCreation.marker.rgba[1] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.rgba[1] = tonumber(Input("Rouge du marker", "Rouge"))
            end
        end)
        Items:AddButton('Couleur G', nil, { RightLabel = (CurrentCreation.marker.rgba[2] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.rgba[2] = tonumber(Input("Vert du marker", "Vert"))
            end
        end)
        Items:AddButton('Couleur B', nil, { RightLabel = (CurrentCreation.marker.rgba[3] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.rgba[3] = tonumber(Input("Bleu du marker", "Bleu"))
            end
        end)
        Items:AddButton('Alpha', nil, { RightLabel = (CurrentCreation.marker.rgba[4] or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.rgba[4] = tonumber(Input("Alpha du marker", "Alpha"))
            end
        end)
        Items:AddButton('Distance', nil, { RightLabel = (CurrentCreation.marker.distance or '~r~Requis')}, function (onSelected, onHovered)
            if onSelected then
                CurrentCreation.marker.distance = tonumber(Input("Distance du marker", "Distance"))
            end
        end)
        Items:AddLine({"#00ff00"})
        Items:AddSeparator("Items")
        if CurrentCreation.items ~= nil and CurrentCreation.items ~= {} then
            for i, item in ipairs(CurrentCreation.items) do
                Items:AddButton(item.label, nil, { RightLabel = "~g~$~s~"..item.price}, function(onSelected, onHovered)
                    if onSelected then
                        table.remove(CurrentCreation.items, i)
                    end
                end)
            end
        else
            Items:AddSeparator("~r~Aucun Item")
        end
        Items:AddLine({"#00ff00"})
        Items:AddButton("Ajouter un item", nil, { RightLabel = ">"}, function(onSelected, onHovered)
            if onSelected then
                local data = zUI.ShowModal("Nouvel Item", {
                    { type = "text", name = "Nom", isRequired = true },
                    { type = "text", name = "Label", isRequired = true },
                    { type = "number", name = "Prix", isRequired = true },
                }, {})
                table.insert(CurrentCreation.items, {label = data["Label"], name = data["Nom"], price =  data["Prix"]})
                print("New data: "..json.encode(CurrentCreation.items))
            end
        end)
        Items:AddButton("~g~Confirmer le LTD", nil, { RightLabel = ">"}, function(onSelected, onHovered)
            if onSelected then
                zUI:CloseAll()
                TriggerServerEvent("market:server:createShop", CurrentCreation)
            end
        end)
    end)
    ListMenu:SetItems(function(Items)
        for key, value in pairs(Markets) do
            Items:AddButton(value.label, nil, {RightLabel = "⮕"}, function (onSelected, onHovered)
                if onSelected then
                    TriggerServerEvent('market:server:deletemarket', key)
                end
            end)
        end
    end)
end)


RegisterNetEvent('updateMarkets')
AddEventHandler('updateMarkets', function(markets)
    Markets = markets
    RefreshBlips()
end)

function Input(title, text)
    local data = zUI.ShowModal(title, {
        { type = "text", name = text, isRequired = true },
    }, {})
    return data[text]
end