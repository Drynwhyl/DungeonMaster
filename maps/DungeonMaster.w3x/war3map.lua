gg_rct_Region_000 = nil
gg_rct_Region_001 = nil
gg_rct_Dungeon = nil
gg_rct_BossRoom_001 = nil
gg_rct_StartRoom_001 = nil
gg_rct_Base = nil
gg_rct_HeroPick = nil
gg_rct_Room000 = nil
gg_rct_Room001 = nil
gg_rct_Room002 = nil
gg_rct_Room003 = nil
gg_cam_Camera_001 = nil
gg_trg_InitTrigger = nil
function InitGlobals()
end

function CreateAllItems()
    local itemID
    BlzCreateItemWithSkin(FourCC("ratf"), 5526.7, 6784.2, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5498.2, 6645.9, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5490.3, 6499.6, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5485.1, 6379.2, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5494.1, 6250.7, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5497.3, 6143.8, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5500.2, 6092.5, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5564.3, 6737.9, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5590.5, 6853.2, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5616.9, 6895.1, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5653.6, 6725.3, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5634.9, 6469.2, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5594.5, 6235.3, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5580.4, 6145.0, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5706.6, 6552.0, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5818.3, 6742.3, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5850.5, 6766.0, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5872.5, 6575.4, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5868.5, 6393.4, FourCC("ratf"))
    BlzCreateItemWithSkin(FourCC("ratf"), 5867.1, 6327.1, FourCC("ratf"))
end

function CreateUnitsForPlayer0()
    local p = Player(0)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("H   "), -6312.9, 6499.3, 157.530, FourCC("H   "))
    UnitAddItemToSlotById(u, FourCC("ratf"), 0)
    UnitAddItemToSlotById(u, FourCC("phlt"), 1)
    UnitAddItemToSlotById(u, FourCC("k3m3"), 5)
end

function CreateUnitsForPlayer1()
    local p = Player(1)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("Edem"), -6391.2, 6017.3, 191.000, FourCC("Edem"))
end

function CreateNeutralPassiveBuildings()
    local p = Player(PLAYER_NEUTRAL_PASSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("nwgt"), -5630.6, 6801.0, 270.000, FourCC("nwgt"))
    SetUnitColor(u, ConvertPlayerColor(3))
    u = BlzCreateUnitWithSkin(p, FourCC("nwgt"), -6782.6, 6801.0, 270.000, FourCC("nwgt"))
    SetUnitColor(u, ConvertPlayerColor(2))
    u = BlzCreateUnitWithSkin(p, FourCC("nwgt"), -6206.6, 6801.0, 270.000, FourCC("nwgt"))
    SetUnitColor(u, ConvertPlayerColor(12))
    u = BlzCreateUnitWithSkin(p, FourCC("nmrk"), -7040.0, 5504.0, 270.000, FourCC("nmrk"))
    SetUnitColor(u, ConvertPlayerColor(0))
    u = BlzCreateUnitWithSkin(p, FourCC("n  !"), -6421.1, 6344.9, 270.000, FourCC("n  !"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
    CreateUnitsForPlayer0()
    CreateUnitsForPlayer1()
end

function CreateAllUnits()
    CreateNeutralPassiveBuildings()
    CreatePlayerBuildings()
    CreatePlayerUnits()
end

function CreateRegions()
    local we
    gg_rct_Region_000 = Rect(-512.0, 1664.0, 512.0, 2688.0)
    gg_rct_Region_001 = Rect(-2304.0, 1408.0, -1024.0, 2688.0)
    gg_rct_Dungeon = Rect(-7168.0, -5728.0, 3072.0, 4640.0)
    gg_rct_BossRoom_001 = Rect(1792.0, 2816.0, 3584.0, 4480.0)
    gg_rct_StartRoom_001 = Rect(5504.0, 2688.0, 7296.0, 4480.0)
    gg_rct_Base = Rect(-6400.0, 6144.0, -6016.0, 6528.0)
    we = AddWeatherEffect(gg_rct_Base, FourCC("FDbh"))
    EnableWeatherEffect(we, true)
    gg_rct_HeroPick = Rect(6336.0, 6272.0, 6816.0, 6720.0)
    gg_rct_Room000 = Rect(-2176.0, -1280.0, -128.0, 768.0)
    gg_rct_Room001 = Rect(256.0, -1280.0, 2304.0, 768.0)
    gg_rct_Room002 = Rect(2688.0, -1280.0, 5760.0, 768.0)
    gg_rct_Room003 = Rect(-1024.0, -3840.0, 0.0, -2048.0)
end

function CreateCameras()
    gg_cam_Camera_001 = CreateCameraSetup()
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_ZOFFSET, 0.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_ROTATION, 90.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_ANGLE_OF_ATTACK, 270.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_TARGET_DISTANCE, 9261.7, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_ROLL, 0.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_FIELD_OF_VIEW, 70.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_FARZ, 10000.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_NEARZ, 16.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_LOCAL_PITCH, 0.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_LOCAL_YAW, 0.0, 0.0)
    CameraSetupSetField(gg_cam_Camera_001, CAMERA_FIELD_LOCAL_ROLL, 0.0, 0.0)
    CameraSetupSetDestPosition(gg_cam_Camera_001, 0.0, -256.0, 0.0)
end

function Trig_InitTrigger_Actions()
        InitModules()
end

function InitTrig_InitTrigger()
    gg_trg_InitTrigger = CreateTrigger()
    TriggerAddAction(gg_trg_InitTrigger, Trig_InitTrigger_Actions)
end

function InitCustomTriggers()
    InitTrig_InitTrigger()
end

function RunInitializationTriggers()
    ConditionalTriggerExecute(gg_trg_InitTrigger)
end

function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    ForcePlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_UNDEAD)
    SetPlayerRaceSelectable(Player(0), false)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    ForcePlayerStartLocation(Player(1), 1)
    SetPlayerColor(Player(1), ConvertPlayerColor(1))
    SetPlayerRacePreference(Player(1), RACE_PREF_UNDEAD)
    SetPlayerRaceSelectable(Player(1), false)
    SetPlayerController(Player(1), MAP_CONTROL_USER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerState(Player(0), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerTeam(Player(1), 0)
    SetPlayerState(Player(1), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
    SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
    SetPlayerAllianceStateVisionBJ(Player(0), Player(1), true)
    SetPlayerAllianceStateVisionBJ(Player(1), Player(0), true)
end

function InitAllyPriorities()
    SetStartLocPrioCount(0, 1)
    SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(1, 1)
    SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
end

function main()
    SetCameraBounds(-7424.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7680.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 7424.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 7168.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -7424.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 7168.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 7424.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -7680.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    SetTerrainFogEx(0, 100000.0, 100000.0, 0.000, 1.000, 0.000, 0.000)
    NewSoundEnvironment("Default")
    SetAmbientDaySound("IceCrownDay")
    SetAmbientNightSound("IceCrownNight")
    SetMapMusic("Music", true, 0)
    CreateRegions()
    CreateCameras()
    CreateAllItems()
    CreateAllUnits()
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
    RunInitializationTriggers()
end

function config()
    SetMapName("TRIGSTR_001")
    SetMapDescription("TRIGSTR_003")
    SetPlayers(2)
    SetTeams(2)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    DefineStartLocation(0, 6592.0, 6464.0)
    DefineStartLocation(1, 4480.0, 1920.0)
    InitCustomPlayerSlots()
    InitCustomTeams()
    InitAllyPriorities()
end

