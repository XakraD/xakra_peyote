
local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


VorpInv = exports.vorp_inventory:vorp_inventoryApi()

Citizen.CreateThread(function()

    Citizen.Wait(2000)

    -- ################ USO DE PEYOTE ################
    TriggerEvent("xakra_peyote:animal_items", source)   -- Llamada a función para guardar items del config.lua.
         
    RegisterServerEvent("xakra_peyote:use_items")
    AddEventHandler("xakra_peyote:use_items", function(animal_items)
        local _source = source

        for _, animal_item in pairs(animal_items) do
            
            VorpInv.RegisterUsableItem(animal_item, function(data) -- Cuando usemos el peyote iniciaremos la función.
                VorpInv.subItem(data.source, animal_item, 1)   -- Eliminar el peyote usado.
                TriggerClientEvent("vorpmetabolism:setValue", data.source, "Hunger", 999)   -- Establecer el hambre.
                TriggerClientEvent("vorpmetabolism:setValue", data.source, "Thirst", 999)   -- Establecer la sed.
                VorpInv.CloseInv(data.source)   -- Cerrar inventario.
                TriggerClientEvent("xakra_peyote:set_animal", data.source)  -- Llamar a la función para la transforamción en el cliente.
            end)
        end
    end)

end)
