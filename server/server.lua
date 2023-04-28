
local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


VorpInv = exports.vorp_inventory:vorp_inventoryApi()


for _, item in pairs(Config.AnimalItems) do
    VorpInv.RegisterUsableItem(item, function(data)
        VorpInv.subItem(data.source, item, 1)
        TriggerClientEvent("vorpmetabolism:setValue", data.source, "Hunger", 999)
        TriggerClientEvent("vorpmetabolism:setValue", data.source, "Thirst", 999)
        VorpInv.CloseInv(data.source)   -- Cerrar inventario.
        TriggerClientEvent("xakra_peyote:set_animal", data.source)
    end)
end
