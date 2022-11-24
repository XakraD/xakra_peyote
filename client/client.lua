Citizen.CreateThread(function()

    Citizen.Wait(2000)

    local lista_items = {}  -- Array para guardar items.

    for i, item in pairs(Config.AnimalItems) do -- Bucle para guardar cada elemento del Config.AnimalItems.
        lista_items[i] = item   --   Guardar variable en su posición.
	end
    TriggerServerEvent("xakra_peyote:use_items", lista_items)   -- Llamada al server para registrar el uso de la lista de items.
end)

-- ############# Funcion animaciones iniciales al tomar peyote. #############
RegisterNetEvent("xakra_peyote:set_animal")
AddEventHandler("xakra_peyote:set_animal", function()
    -- Paramos todas las animaciones Screen.
    Citizen.InvokeNative(0xB4FD7446BAB2F394,"PlayerDrunk01")    -- Parar screen borracho.
    Citizen.InvokeNative(0xB4FD7446BAB2F394,"DeathFailMP01")    -- Parar pantalla gris.

    TriggerEvent("vorp:TipRight", Config.MensajeTrans, 6000) -- Mostrar mensaje de la transformación.

    local animDict = "mech_inventory@eating@multi_bite@wedge_a4-2_b0-75_w8_h9-4_eat_cheese"
    local animName = "quick_right_hand"
    local speed = 8.0 
    local speedX = 3.0 
    local duration = 3000
    local flags = 2
    loadAnimDict(animDict) -- Función para cargar animación.
    TaskPlayAnim(PlayerPedId(), animDict, animName, speed, speedX, duration, flags, 0, 0, 0, 0 )
    Citizen.Wait(3000) -- Espera para animaciones.

    Citizen.InvokeNative(0x4102732DF6B4005F,"PlayerDrunk01")    -- Iniciar screen borracho.

    -- Animación vomitar.
    local animDict1 = "amb_misc@world_human_vomit_kneel@male_a@idle_c"
    local animName1 = "idle_h"
    local speed1 = 2.0 
    local speedX1 = 1.0 
    local duration1 = 11000
    local flags1 = 2
    loadAnimDict(animDict1) -- Función para cargar animación.
    TaskPlayAnim(PlayerPedId(), animDict1, animName1, speed1, speedX1, duration1, flags1, 0, 0, 0, 0 )
    Citizen.Wait(11000) -- Espera para pasar a la siguiente animación.

    local morir = math.random(Config.AnimalPos)  -- Posibilidades de morir
    
    if morir ~= 1 then -- Si la posbilidad no es 1, se tranfromará
        if IsPedMale(PlayerPedId()) then -- Verificamos animacions según el genero.
        
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR"), 0, true, false, false, false) -- Animación tirarse al suelo. 
            Citizen.Wait(22000) -- Espera para iniciar screen borarcho y salir de la función para seguir.
            Citizen.InvokeNative(0xB4FD7446BAB2F394,"PlayerDrunk01")    -- Parar screen borracho.
            AnimalTrans()
        else
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_SLEEP_GROUND_PILLOW_NO_PILLOW"), 0, true, false, false, false)
            Citizen.Wait(30000) -- Espera para pasar a la siguiente animación.
            Citizen.InvokeNative(0xB4FD7446BAB2F394,"PlayerDrunk01")    -- Parar screen borracho.
            AnimalTrans()
        end
    else
        Citizen.InvokeNative(0x697157CED63F18D4, PlayerPedId(), 500000, false, true, true)
        Citizen.InvokeNative(0xB4FD7446BAB2F394,"PlayerDrunk01")    -- Parar screen borracho.
    end

end)

function AnimalTrans()
    Citizen.InvokeNative(0x4102732DF6B4005F,"PlayerWakeUpDrunk") -- Iniciar screen despertarse borracho.
    
    SetMonModel(Config.AnimalList[math.random(#Config.AnimalList)]) -- Cambio de modelo según la lista de animales de forma aleatoria.

    Wait(Config.TimeTrans)  -- Espera para la transformación.
    ExecuteCommand("rc")    -- Recarga del personaje para quitar la PED.

    Citizen.Wait(500)
    Citizen.InvokeNative(0x4102732DF6B4005F,"CamTransitionBlinkSlow")   -- Pestañear camara.
    Citizen.InvokeNative(0x4102732DF6B4005F,"DeathFailMP01") -- Iniciar pantalla gris.

    if IsPedMale(PlayerPedId()) then
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR"), 0, true, false, false, false) -- Animación tirarse al suelo.
    else
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_PLAYER_SLEEP_GROUND"), 0, true, false, false, false)
    end
    
    Citizen.Wait(25000) -- Esperamos tumbados en el suelo y cancelamos animación.
    ClearPedTasks(PlayerPedId())
    ClearPedSecondaryTask(PlayerPedId())

    -- ########### Andar herido después de la tomo del peyote. ###########
    Citizen.InvokeNative(0x406CCF555B04FAD3,PlayerPedId(),true,1.0) -- Iniciar andar borracho.
    
    Citizen.Wait(40000) -- Espera de efectos secundarios.
    
    Citizen.InvokeNative(0xB4FD7446BAB2F394,"DeathFailMP01")    -- Parar pantalla gris.
    Citizen.InvokeNative(0x4102732DF6B4005F,"PlayerWakeUpDrunk") -- Iniciar screen despertarse borracho.

    Citizen.Wait(8000)
    Citizen.InvokeNative(0x406CCF555B04FAD3,PlayerPedId(),true,0) -- Parar animación de andar borracho.
end


function SetMonModel(name)
    local model = GetHashKey(name)
    local player = PlayerId()
        
    if not IsModelValid(model) then return end
    PerformRequest(model)
        
    if HasModelLoaded(model) then
        Citizen.InvokeNative(0xED40380076A31506, player, model, false)
        Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true)
        SetModelAsNoLongerNeeded(model)
    end
 end

function PerformRequest(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        RequestModel(modelHash)
        Citizen.Wait(100)
    end
end

-- ############# Función para cargar animación. #############
function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end