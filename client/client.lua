-- ############# Funcion animaciones iniciales al tomar peyote. #############
RegisterNetEvent("xakra_peyote:set_animal")
AddEventHandler("xakra_peyote:set_animal", function()
    AnimpostfxStop("PlayerDrunk01")    -- Parar screen borracho.
    AnimpostfxStop("DeathFailMP01")    -- Parar pantalla gris.

    TriggerEvent("vorp:TipRight", Config.MensajeTrans, 6000) -- Mostrar mensaje de la transformación.

    local animDict = "mech_inventory@eating@multi_bite@wedge_a4-2_b0-75_w8_h9-4_eat_cheese"
    local animName = "quick_right_hand"
    local speed = 8.0 
    local speedX = 3.0 
    local duration = 3000
    local flags = 2
    loadAnimDict(animDict) -- Función para cargar animación.
    TaskPlayAnim(PlayerPedId(), animDict, animName, speed, speedX, duration, flags, 0, 0, 0, 0 )
    Wait(3000) -- Espera para animaciones.

    AnimpostfxPlay("PlayerDrunk01")    -- Iniciar screen borracho.

    -- Animación vomitar.
    local animDict1 = "amb_misc@world_human_vomit_kneel@male_a@idle_c"
    local animName1 = "idle_h"
    local speed1 = 2.0 
    local speedX1 = 1.0 
    local duration1 = 11000
    local flags1 = 2
    loadAnimDict(animDict1) -- Función para cargar animación.
    TaskPlayAnim(PlayerPedId(), animDict1, animName1, speed1, speedX1, duration1, flags1, 0, 0, 0, 0 )
    Wait(11000) -- Espera para pasar a la siguiente animación.

    local random = math.random(100)
    if random <= Config.AnimalPos then -- Si la posbilidad no es 1, se tranfromará
        if IsPedMale(PlayerPedId()) then -- Verificamos animacions según el genero.
        
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR"), 0, true, false, false, false) -- Animación tirarse al suelo. 
            Wait(22000) -- Espera para iniciar screen borarcho y salir de la función para seguir.
            AnimpostfxStop("PlayerDrunk01")    -- Parar screen borracho.
            AnimalTrans()
        else
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_SLEEP_GROUND_PILLOW_NO_PILLOW"), 0, true, false, false, false)
            Wait(30000) -- Espera para pasar a la siguiente animación.
            AnimpostfxStop("PlayerDrunk01")    -- Parar screen borracho.
            AnimalTrans()
        end
    else
        SetEntityHealth(PlayerPedId(), 0)
        AnimpostfxStop("PlayerDrunk01")    -- Parar screen borracho.
    end

end)

function AnimalTrans()
    AnimpostfxPlay("PlayerWakeUpDrunk") -- Iniciar screen despertarse borracho.
    
    SetMonModel(Config.AnimalList[math.random(#Config.AnimalList)])

    Wait(Config.TimeTrans)  -- Espera para la transformación.
    if IsPedMale(PlayerPedId()) then
        SetMonModel('mp_male')
    else
        SetMonModel('mp_female')
    end
    ExecuteCommand("rc")    -- Recarga del personaje para quitar la PED.

    Wait(500)
    AnimpostfxPlay("CamTransitionBlinkSlow")   -- Pestañear camara.
    AnimpostfxPlay("DeathFailMP01") -- Iniciar pantalla gris.

    if IsPedMale(PlayerPedId()) then
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR"), 0, true, false, false, false) -- Animación tirarse al suelo.
    else
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_PLAYER_SLEEP_GROUND"), 0, true, false, false, false)
    end
    
    Wait(25000) -- Esperamos tumbados en el suelo y cancelamos animación.
    ClearPedTasks(PlayerPedId())
    ClearPedSecondaryTask(PlayerPedId())

    -- ########### Andar herido después de la tomo del peyote. ###########
    Citizen.InvokeNative(0x406CCF555B04FAD3, PlayerPedId(), true, 1.0)  -- SetPedDrunkness
    
    Wait(40000) -- Espera de efectos secundarios.
    
    AnimpostfxStop("DeathFailMP01")    -- Parar pantalla gris.
    AnimpostfxPlay("PlayerWakeUpDrunk") -- Iniciar screen despertarse borracho.

    Wait(8000)
    Citizen.InvokeNative(0x406CCF555B04FAD3, PlayerPedId(), false, 0.0)  -- SetPedDrunkness
end


function SetMonModel(name)
    local model = GetHashKey(name)
    local player = PlayerId()
        
    if not IsModelValid(model) then return end
    PerformRequest(model)
        
    if HasModelLoaded(model) then
        Citizen.InvokeNative(0xED40380076A31506, player, model, false)  -- SetPlayerModel
        Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true)   -- SetRandomOutfitVariation
        SetModelAsNoLongerNeeded(model)
    end
 end

function PerformRequest(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        RequestModel(modelHash)
        Wait(100)
    end
end

-- ############# Función para cargar animación. #############
function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Wait(5)
	end
end

--########################### STOP RESOURCE ###########################
AddEventHandler('onResourceStop', function (resourceName)
    if resourceName == GetCurrentResourceName() then
        AnimpostfxStop("PlayerDrunk01")
        AnimpostfxStop("DeathFailMP01")
        Citizen.InvokeNative(0x406CCF555B04FAD3, PlayerPedId(), false, 0.0)  -- SetPedDrunkness
    end
end)