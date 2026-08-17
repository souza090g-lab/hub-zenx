
-- SERVICES

local Players =
    game:GetService(
        "Players"
    )

local UserInputService =
    game:GetService(
        "UserInputService"
    )

local TweenService =
    game:GetService(
        "TweenService"
    )

local RunService =
    game:GetService(
        "RunService"
    )

local GuiService =
    game:GetService(
        "GuiService"
    )

local LocalPlayer =
    Players.LocalPlayer

if not LocalPlayer then

    return

end

local PlayerGui =
    LocalPlayer:WaitForChild(
        "PlayerGui"
    )

--------------------------------------------------------------------
-- DESTROY PREVIOUS ZENX ENGINE
--
-- From V11.1 onward every execution registers a global cleanup
-- function. Running a newer copy disconnects the previous engine,
-- destroys its UI, and stops its loops before creating this one.
--------------------------------------------------------------------

local GlobalEnvironment

pcall(function()
    GlobalEnvironment =
        getgenv()
end)

GlobalEnvironment =
    GlobalEnvironment
    or
    shared

if
    GlobalEnvironment
    and
    GlobalEnvironment.ZenxBladeBallCleanup
then

    pcall(
        GlobalEnvironment.ZenxBladeBallCleanup
    )

    GlobalEnvironment.ZenxBladeBallCleanup =
        nil
end

print(
    "[ZENX] BOOT 1/3 - services ready"
)

-- REMOVE OLD ZENX PANELS

for _,
    Object
in ipairs(
    PlayerGui:GetChildren()
)
do

    if
        Object:IsA(
            "ScreenGui"
        )
    then

        local Name =
            Object.Name

        if
            string.find(
                Name,
                "ZenxBladeBall",
                1,
                true
            )
            ==
            1
        then

            Object:Destroy()

        end

    end

end

-- BLADE BALL ENGINE SERVICES

local UIS =
    UserInputService

local VIM =
    game:GetService(
        "VirtualInputManager"
    )

local Stats =
    game:GetService(
        "Stats"
    )

local Debris =
    game:GetService(
        "Debris"
    )

local ReplicatedStorage =
    game:GetService(
        "ReplicatedStorage"
    )

local Player =
    LocalPlayer

-- CONFIG

local Config = {

    -- AUTO PARRY - ORIGINAL ENGINE

    AutoParry = false,

    CurveDetection = true,

    PingCompensation = true,

    -- valor original observado
    RangeDivisor = 2.583,

    ExtraRange = 0,

    -- SMART CORE SAFETY

    SlowBallFix = true,
    SlowBallSpeed = 62,
    SlowBallRange = 23,

    CurveEmergency = true,
    CurveEmergencyRange = 12,

    CriticalETAFix = true,
    CriticalETA = 0.115,

    -- precisão / comportamento
    ParryAccuracy = 78,

    -- MODE SELECTORS

    AutoCurveMode = "Custom",

    ------------------------------------------------------------
    -- CURVE FREQUENCY
    ------------------------------------------------------------

    -- "Auto" = escolhe dinamicamente 1..6
    -- "1".."6" = curva a cada N parries confirmados
    CurveEveryMode = "Auto",

    -- limites usados pelo modo automático
    CurveAutoMin = 1,
    CurveAutoMax = 6,

    -- próximo intervalo sorteado/adaptado
    CurveAutoNext = 3,

    -- Predictive Parry
    PredictiveParry = true,
    PredictionTime = 0.16,
    PredictionRadius = 9,
    AccelerationPrediction = true,
    TargetSwitchBoost = true,
    TargetSwitchWindow = 0.12,
    PredictionLead = 0.025,

    ------------------------------------------------------------
    -- SMART PARRY V2
    ------------------------------------------------------------

    SmartParryV2 = true,

    -- confiança mínima para o predictor agir
    MinParryConfidence = 58,

    -- peso de cada sinal na confiança
    ConfidenceDirectionWeight = 34,
    ConfidenceETAWeight = 30,
    ConfidenceTargetWeight = 22,
    ConfidenceCurveWeight = 14,

    ------------------------------------------------------------
    -- CLOSE RANGE MODE
    ------------------------------------------------------------

    CloseRangeMode = true,
    CloseRangeOpponentDistance = 13,
    CloseRangeETABonus = 0.035,
    CloseRangeRangeBonus = 2.5,

    ------------------------------------------------------------
    -- DOUBLE PARRY GUARD V2
    ------------------------------------------------------------

    DoubleParryGuardV2 = true,

    -- mínimo entre dois parries da mesma bola
    DoubleParryMinRearmTime = 0.055,

    -- fallback: nunca deixa o guard travar a bola pra sempre
    DoubleParryHardRearmTime = 0.42,

    ------------------------------------------------------------
    -- DYNAMIC RANGE
    ------------------------------------------------------------

    DynamicRange = true,
    DynamicSlowBonus = 2.0,
    DynamicFastBonus = 4.5,
    DynamicVeryFastSpeed = 220,

    ------------------------------------------------------------
    -- CURVE V2
    ------------------------------------------------------------

    SmartCurveDirection = "Smart",
    CurveConfidenceThreshold = 0.20,

    ------------------------------------------------------------
    -- PROFILES
    ------------------------------------------------------------

    ActiveProfile = "Balanced",

    ------------------------------------------------------------
    -- PERFORMANCE / DEBUG
    ------------------------------------------------------------

    PerformanceMode = false,
    DebugOverlay = true,
    DebugUpdateInterval = 0.08,

    -- INTERCEPT ENGINE V3
    InterceptEngine = true,
    InterceptHistorySize = 8,
    InterceptMaxTime = 0.24,
    InterceptRadius = 8.5,

    -- CURVE DETECTION V2
    CurveDetectionV2 = true,
    CurveDeltaThreshold = 0.075,

    -- ADAPTIVE TIMING
    AdaptiveTiming = true,
    AdaptiveLead = 0.020,
    AdaptiveLeadMin = -0.010,
    AdaptiveLeadMax = 0.085,
    AdaptiveLeadStep = 0.004,

    -- PARRY STATE MACHINE
    ParryStateMachine = true,
    ParryStateHardReset = 0.55,

    FastBallMode = true,
    FastBallSpeed = 210,

    SlowBallModeV2 = true,
    SlowBallModeSpeed = 75,

    ParryType = "Mouse",

    -- opções esperadas na UI:
    -- AutoCurveMode: Custom / Back / Left / Right / Random
    -- ParryType: Mouse / Key / Remote

    RandomAccuracy = false,
    AccuracyMin = 70,
    AccuracyMax = 95,

    -- auto spam inteligente
    AutoSpam = false,
    SpamDistance = 18,

    -- spam manual
    ManualSpamHold = false,

    PreferParryRemote = false,

    -- CURVE DETECTOR

    -- valor original observado
    CurveDotBase = 0.548,

    -- INPUT / COOLDOWN

    -- cooldown real é controlado pelo target da bola.
    -- isso é só fallback caso o atributo não mude.
    CooldownFallback = true,

    -- BACK CURVE

    AutoCurve = false,

    BackCurveEvery = 3,

    BackCurveAngle = 160,

    CurveHold = 0.012,

    AlternateCurve = false,

    FixedCurveSide = 1,

    -- FAST KEY SPAM

    -- tecla que liga/desliga o spam
    SpamToggleKey =
        Enum.KeyCode.X,

    -- tecla que será spamada no jogo
    SpamInputKey =
        Enum.KeyCode.F,

    SpamActive = false,

    -- quantidade de taps completos por fase/frame
    SpamBurstPerFrame = 6,

    -- teto configurável
    SpamMaxBurst = 20,

    -- Turbo usa mais de uma fase do frame sem criar loops infinitos.
    SpamTurbo = true,

    -- Heartbeat + PreSimulation + PostSimulation
    SpamMultiPhase = true,

    -- só spama quando a janela do jogo está ativa
    SpamRequireFocus = true,

    -- VISUAL

    BallESP = false,

    RangeVisualizer = false,

    -- PERFORMANCE

    StatusUpdateInterval = 0.10,

    -- UI

    ToggleKey =
        Enum.KeyCode.RightShift,

    HideKey =
        Enum.KeyCode.Insert,
}

-- RUNTIME

local Runtime = {

    Alive = true,

    Ball = nil,

    ClientBall = nil,

    Target = nil,

    RawTarget = nil,

    From = nil,

    Cooldown = false,

    CooldownUntil = 0,

    Parries = 0,

    SuccessfulParries = 0,

    CurveParryCounter = 0,

    CurveLastInterval = 3,

    PreviousBallVelocity = Vector3.zero,
    PreviousBallSampleTime = 0,
    BallAcceleration = Vector3.zero,
    LastTargetSwitchTime = 0,

    ParryConfidence = 0,

    PredictedETA = math.huge,

    PredictedMissDistance = math.huge,

    LastParriedBall = nil,

    LastParryTimeV2 = 0,

    GuardArmed = false,

    GuardSawBallLeave = false,

    GuardLastTargetName = nil,

    LastBallDirection = Vector3.zero,

    LastBallDirectionDot = 1,

    NearestOpponentDistance = math.huge,

    DebugLastUpdate = 0,

    TrajectoryHistory = {},
    CurveDeltaV2 = 0,
    InterceptETA = math.huge,
    InterceptMiss = math.huge,
    AdaptiveTimingLead = 0.020,
    ParryState = "READY",
    ParryStateSince = 0,
    LastConfirmedParryTime = 0,

    MaximumSpeed = 0,

    OldSpeed = 0,

    LastHit = 0,

    LastPosition =
        Vector3.zero,

    LastBallPosition =
        Vector3.zero,

    LastCurvePosition =
        Vector3.zero,

    LastWarping =
        tick(),

    AeroDynamicTime =
        tick(),

    HellHookCompleted =
        true,

    Position =
        Vector3.zero,

    Velocity =
        Vector3.zero,

    Speed = 0,

    Distance = 0,

    Direction =
        Vector3.zero,

    Dot = 0,

    Radians = 0,

    LerpRadians = 0,

    ParryRange = 0,

    EntityServerPosition =
        Vector3.zero,

    EntityVelocity =
        Vector3.zero,

    EntityDistance = 0,

    EntityMoving = false,

    Ping = 0,

    Status = "IDLE",

    Visible = true,

    CurveSide = 1,

    UseBackCurveThisParry =
        false,

    LastStatusUpdate = 0,

    WaitingForSpamKey = false,

    PositionHistory = {},

    TargetConnection = nil,

    Connections = {},
}

-- CONNECTION MANAGER

local function Connect(
    Signal,
    Callback
)

    local Connection =
        Signal:Connect(Callback)

    table.insert(
        Runtime.Connections,
        Connection
    )

    return Connection
end

local PushTrajectorySample
local CalculateCurveDeltaV2
local GetInterceptPrediction
local IsCurveV2
local GetAdaptiveThreshold
local UpdateParryStateMachine
local AdaptiveTimingOnParry

-- CHARACTER

local function GetCharacter()

    return Player.Character
end

local function GetRoot()

    local Character =
        GetCharacter()

    return Character
        and Character:FindFirstChild(
            "HumanoidRootPart"
        )
end

local function IsAlive()

    local Character =
        GetCharacter()

    local Humanoid =
        Character
        and Character:FindFirstChildOfClass(
            "Humanoid"
        )

    return
        Character
        and Humanoid
        and Humanoid.Health > 0
end

-- GAME REFERENCES

local function GetBallsFolder()

    return workspace:FindFirstChild(
        "Balls"
    )
end

local function GetAliveFolder()

    return workspace:FindFirstChild(
        "Alive"
    )
end

local function GetRuntimeFolder()

    return workspace:FindFirstChild(
        "Runtime"
    )
end

local function IsRealBall(
    Object
)

    return
        Object
        and Object:IsA("BasePart")
        and Object:GetAttribute(
            "realBall"
        )
        ==
        true
end

local function FindBall()

    local Folder =
        GetBallsFolder()

    if not Folder then
        return nil
    end

    for _, Object in ipairs(
        Folder:GetChildren()
    ) do

        if IsRealBall(Object) then
            return Object
        end
    end

    return nil
end

local function FindClientBall()

    local Folder =
        GetBallsFolder()

    if not Folder then
        return nil
    end

    for _, Object in ipairs(
        Folder:GetChildren()
    ) do

        if
            Object:IsA("BasePart")
            and
            not Object:GetAttribute(
                "realBall"
            )
        then

            return Object
        end
    end

    return nil
end

-- PING

local function GetPing()

    local Success,
        Value =
        pcall(function()

            return
                Stats.Network
                    .ServerStatsItem[
                        "Data Ping"
                    ]
                    :GetValue()
        end)

    if Success and Value then
        return Value
    end

    return 0
end

-- ORIGINAL SERVER POSITION SIMULATION
--
-- O script original fazia task.delay(ping/1000) a cada frame.
-- Aqui fazemos a mesma ideia com histórico, sem criar centenas
-- de tasks por segundo.

local function UpdatePositionHistory()

    local Root =
        GetRoot()

    if not Root then
        return
    end

    local Now =
        os.clock()

    local History =
        Runtime.PositionHistory

    table.insert(
        History,
        {
            Time = Now,
            Position = Root.Position,
        }
    )

    local KeepAfter =
        Now - 0.75

    while
        #History > 2
        and
        History[1].Time
        <
        KeepAfter
    do

        table.remove(
            History,
            1
        )
    end

    local Delay =
        Runtime.Ping / 1000

    local Wanted =
        Now - Delay

    local Selected =
        Root.Position

    for Index = #History, 1, -1 do

        local Sample =
            History[Index]

        if Sample.Time <= Wanted then

            Selected =
                Sample.Position

            break
        end
    end

    Runtime.EntityServerPosition =
        Selected
end

-- BALL VELOCITY

local function GetBallVelocity(
    Ball
)

    if not Ball then
        return Vector3.zero
    end

    local Zoomies =
        Ball:FindFirstChild(
            "zoomies"
        )

    if Zoomies then

        local Success,
            Velocity =
            pcall(function()

                return
                    Zoomies.VectorVelocity
            end)

        if
            Success
            and
            typeof(Velocity)
            ==
            "Vector3"
        then

            return Velocity
        end
    end

    return
        Ball.AssemblyLinearVelocity
end

-- TARGET

local function ResolveAliveEntity(
    Value
)

    if Value == nil then
        return nil
    end

    local Alive =
        GetAliveFolder()

    if not Alive then
        return nil
    end

    if typeof(Value) == "string" then

        return
            Alive:FindFirstChild(
                Value
            )
    end

    if typeof(Value) == "Instance" then

        if Value.Parent == Alive then
            return Value
        end

        if Value:IsA("Player") then

            return
                Alive:FindFirstChild(
                    Value.Name
                )
        end
    end

    return nil
end

local function IsTargetingMe()

    local Character =
        GetCharacter()

    if not Character then
        return false
    end

    local Raw =
        Runtime.RawTarget

    if typeof(Raw) == "string" then

        return
            Raw == Player.Name
            or
            Raw == Player.DisplayName
    end

    if typeof(Raw) == "number" then

        return
            Raw == Player.UserId
    end

    if typeof(Raw) == "Instance" then

        return
            Raw == Player
            or
            Raw == Character
            or
            Raw.Name == Player.Name
    end

    local Target =
        Runtime.Target

    return
        Target ~= nil
        and
        (
            Target == Character
            or
            Target.Name == Player.Name
        )
end

-- BALL TARGET EVENT
--
-- Esta parte é importante no original:
-- mudança de target rearma o parry.

local function DisconnectTargetSignal()

    if Runtime.TargetConnection then

        Runtime.TargetConnection:Disconnect()

        Runtime.TargetConnection =
            nil
    end
end

local function AttachTargetSignal(
    Ball
)

    DisconnectTargetSignal()

    if not Ball then
        return
    end

    Runtime.TargetConnection =
        Ball:GetAttributeChangedSignal(
            "target"
        ):Connect(function()

            Runtime.Cooldown =
                false

            Runtime.CooldownUntil =
                0

            Runtime.LastTargetSwitchTime =
                os.clock()

            local NewTarget =
                Ball:GetAttribute(
                    "target"
                )

            Runtime.GuardLastTargetName =
                NewTarget

            if
                Runtime.GuardArmed
                and
                not IsTargetingMe()
            then

                Runtime.GuardSawBallLeave =
                    true
            end

            Runtime.OldSpeed =
                Runtime.Speed

            Runtime.LastPosition =
                Runtime.Position

            Runtime.Parries +=
                1

            task.delay(
                1,
                function()

                    if Runtime.Parries > 0 then

                        Runtime.Parries -=
                            1
                    end
                end
            )
        end)
end

-- BALL CACHE

local function SetBall(
    Ball
)

    if Ball == Runtime.Ball then
        return
    end

    Runtime.Ball =
        Ball

    Runtime.ClientBall =
        FindClientBall()

    Runtime.MaximumSpeed =
        0

    Runtime.OldSpeed =
        0

    Runtime.Cooldown =
        false

    Runtime.CooldownUntil =
        0

    Runtime.Parries =
        0

    Runtime.CurveParryCounter =
        0

    Runtime.PreviousBallVelocity =
        Vector3.zero

    Runtime.PreviousBallSampleTime =
        0

    Runtime.BallAcceleration =
        Vector3.zero

    Runtime.LastTargetSwitchTime =
        0

    table.clear(
        Runtime.TrajectoryHistory
    )

    Runtime.CurveDeltaV2 =
        0

    Runtime.InterceptETA =
        math.huge

    Runtime.InterceptMiss =
        math.huge

    Runtime.ParryState =
        "READY"

    Runtime.ParryStateSince =
        os.clock()

    Runtime.LastParriedBall =
        nil

    Runtime.LastParryTimeV2 =
        0

    Runtime.GuardArmed =
        false

    Runtime.GuardSawBallLeave =
        false

    Runtime.GuardLastTargetName =
        nil

    Runtime.LastCurvePosition =
        Vector3.zero

    Runtime.LastWarping =
        tick()

    Runtime.Target =
        nil

    Runtime.From =
        nil

    AttachTargetSignal(
        Ball
    )
end

-- ENTITY + BALL DATA

local function UpdateEntityData()

    local Character =
        GetCharacter()

    local Root =
        GetRoot()

    if
        not Character
        or not Root
    then

        return
    end

    Runtime.Ping =
        GetPing()

    UpdatePositionHistory()

    local Target =
        Runtime.Target

    if
        Target
        and
        Target ~= Character
    then

        local TargetRoot =
            Target:FindFirstChild(
                "HumanoidRootPart"
            )
            or
            Target.PrimaryPart

        if TargetRoot then

            Runtime.EntityVelocity =
                TargetRoot.AssemblyLinearVelocity

            Runtime.EntityDistance =
                Player:DistanceFromCharacter(
                    TargetRoot.Position
                )

            Runtime.EntityMoving =
                Runtime.EntityVelocity.Magnitude
                >
                0.1
        end
    else

        Runtime.EntityVelocity =
            Root.AssemblyLinearVelocity

        Runtime.EntityDistance =
            0

        Runtime.EntityMoving =
            Runtime.EntityVelocity.Magnitude
            >
            30
    end
end

local function UpdateBallData()

    local Ball =
        Runtime.Ball

    if
        not Ball
        or
        not Ball.Parent
    then

        return false
    end

    local Velocity =
        GetBallVelocity(
            Ball
        )

    Runtime.Position =
        Ball.Position

    Runtime.Velocity =
        Velocity

    Runtime.Speed =
        Velocity.Magnitude

    local PredictionNow =
        os.clock()

    if Runtime.PreviousBallSampleTime > 0 then

        local PredictionDelta =
            PredictionNow
            -
            Runtime.PreviousBallSampleTime

        if PredictionDelta > 0.001 then

            Runtime.BallAcceleration =
                (
                    Velocity
                    -
                    Runtime.PreviousBallVelocity
                )
                /
                PredictionDelta
        end
    end

    if
        Runtime.LastBallDirection.Magnitude > 0
        and
        Velocity.Magnitude > 0
    then

        Runtime.LastBallDirectionDot =
            Runtime.LastBallDirection.Unit:Dot(
                Velocity.Unit
            )
    else

        Runtime.LastBallDirectionDot =
            1
    end

    Runtime.LastBallDirection =
        Velocity

    Runtime.PreviousBallVelocity =
        Velocity

    Runtime.PreviousBallSampleTime =
        PredictionNow

    if PushTrajectorySample then

        local SampleSuccess,
            SampleError =
            pcall(
                PushTrajectorySample
            )

        if not SampleSuccess then

            warn(
                "[ZENX TRAJECTORY ERROR]",
                SampleError
            )
        end
    end

    local Difference =
        Runtime.EntityServerPosition
        -
        Runtime.Position

    Runtime.Distance =
        Difference.Magnitude

    Runtime.Direction =
        Runtime.Distance > 0.001
        and Difference.Unit
        or Vector3.zero

    Runtime.Dot =
        Runtime.Speed > 0.001
        and Runtime.Direction:Dot(
            Runtime.Velocity.Unit
        )
        or 0

    -- exatamente a ideia observada no original

    Runtime.Radians =
        math.rad(
            math.asin(
                math.clamp(
                    Runtime.Dot,
                    -1,
                    1
                )
            )
        )

    Runtime.LerpRadians =
        Runtime.LerpRadians
        +
        (
            Runtime.Radians
            -
            Runtime.LerpRadians
        )
        *
        0.8

    if
        not (
            Runtime.LerpRadians < 0
        )
        and
        not (
            Runtime.LerpRadians > 0
        )
    then

        Runtime.LerpRadians =
            0.027
    end

    Runtime.MaximumSpeed =
        math.max(
            Runtime.Speed,
            Runtime.MaximumSpeed
        )

    local Alive =
        GetAliveFolder()

    local TargetAttribute =
        Ball:GetAttribute(
            "target"
        )

    Runtime.RawTarget =
        TargetAttribute

    local FromAttribute =
        Ball:GetAttribute(
            "from"
        )

    Runtime.Target =
        ResolveAliveEntity(
            TargetAttribute
        )

    Runtime.From =
        ResolveAliveEntity(
            FromAttribute
        )

    -- se o target for local player e a pasta Alive usar outro
    -- tipo de referência, resolve pelo Character.

    if
        not Runtime.Target
        and
        (
            TargetAttribute == Player.Name
            or
            TargetAttribute == Player.DisplayName
        )
    then

        Runtime.Target =
            GetCharacter()
    end

    return true
end

-- ORIGINAL CURVE DETECTOR

local function IsCurved()

    if not Config.CurveDetection then
        return false
    end

    local Target =
        Runtime.Target

    local Ball =
        Runtime.Ball

    if
        not Target
        or
        not Ball
    then

        return false
    end

    local TargetName =
        Target.Name

    local Character =
        GetCharacter()

    -- special cases observados no original

    local TargetRoot =
        Target:FindFirstChild(
            "HumanoidRootPart"
        )
        or
        Target.PrimaryPart

    if
        TargetRoot
        and
        TargetRoot:FindFirstChild(
            "MaxShield"
        )
        and
        Target ~= Character
        and
        Runtime.Distance < 50
    then

        return false
    end

    if
        Ball:FindFirstChild(
            "TimeHole1"
        )
        and
        Target ~= Character
        and
        Runtime.Distance < 100
    then

        return false
    end

    if
        Ball:FindFirstChild(
            "WEMAZOOKIEGO"
        )
        and
        Target ~= Character
        and
        Runtime.Distance < 100
    then

        return false
    end

    if
        Ball:FindFirstChild(
            "At2"
        )
        and
        Runtime.Speed <= 0
    then

        return true
    end

    local Aero =
        Ball:FindFirstChild(
            "AeroDynamicSlashVFX"
        )

    if Aero then

        pcall(function()

            Debris:AddItem(
                Aero,
                0
            )
        end)

        Runtime.AeroDynamicTime =
            tick()
    end

    local RuntimeFolder =
        GetRuntimeFolder()

    local Tornado =
        RuntimeFolder
        and
        RuntimeFolder:FindFirstChild(
            "Tornado"
        )

    if Tornado then

        local TornadoTime =
            Tornado:GetAttribute(
                "TornadoTime"
            )
            or 1

        if
            Runtime.Distance > 5
            and
            (
                tick()
                -
                Runtime.AeroDynamicTime
            )
            <
            (
                TornadoTime
                +
                0.314159
            )
        then

            return true
        end
    end

    if
        not Runtime.HellHookCompleted
        and
        Target == Character
        and
        Runtime.Distance
        >
        (
            5
            -
            math.random()
        )
    then

        return true
    end

    -- mathematical curve detector

    local MaximumSpeed =
        math.max(
            Runtime.MaximumSpeed,
            0.01
        )

    local Predicted =
        Runtime.Position
        +
        (
            Runtime.Velocity
            *
            (
                Runtime.Distance
                /
                MaximumSpeed
            )
        )

    local LastCurvePosition =
        Runtime.LastCurvePosition

    if
        LastCurvePosition
        ==
        Vector3.zero
    then

        LastCurvePosition =
            Runtime.Position
    end

    local PredictionDelta =
        Predicted
        -
        LastCurvePosition

    local CurveDirection =
        PredictionDelta.Magnitude > 0.001
        and PredictionDelta.Unit
        or Runtime.Velocity.Unit

    local VelocityDirection =
        Runtime.Speed > 0.001
        and Runtime.Velocity.Unit
        or Vector3.zero

    local VelocityDot =
        VelocityDirection:Dot(
            CurveDirection
        )

    local Angle =
        math.acos(
            math.clamp(
                VelocityDot,
                -1,
                1
            )
        )

    local SpeedFactor =
        math.min(
            Runtime.Speed / 100,
            40
        )

    local DotFactor =
        40.046
        *
        math.max(
            Runtime.Dot,
            0
        )

    local Ping =
        Runtime.Ping

    local DotThreshold =
        Config.CurveDotBase
        -
        (
            Ping / 950
        )

    local TimeToImpact =
        (
            Runtime.Distance
            /
            (
                Runtime.Velocity.Magnitude
                +
                0.01
            )
        )
        -
        (
            Ping / 1000
        )

    local HighMaximumSpeed =
        Runtime.MaximumSpeed
        >
        100

    local CurveRange =
        (
            15
            -
            math.min(
                Runtime.Distance / 1000,
                15
            )
        )
        +
        DotFactor
        +
        SpeedFactor

    if
        HighMaximumSpeed
        and
        TimeToImpact
        >
        (
            Ping / 10
        )
    then

        CurveRange =
            math.max(
                CurveRange - 15,
                15
            )
    end

    if Runtime.Distance < CurveRange then

        return false
    end

    if
        Angle
        >
        (
            0.5
            +
            (
                Runtime.Speed / 310
            )
        )
    then

        return true
    end

    if Runtime.LerpRadians < 0.018 then

        Runtime.LastCurvePosition =
            Runtime.Position

        Runtime.LastWarping =
            tick()
    end

    if
        (
            tick()
            -
            Runtime.LastWarping
        )
        <
        (
            TimeToImpact / 1.5
        )
    then

        return true
    end

    Runtime.LastCurvePosition =
        Runtime.Position

    return
        Runtime.Dot
        <
        DotThreshold
end


local function GetNearestOpponentDistance()

    local Root =
        GetRoot()

    local Character =
        GetCharacter()

    if
        not Root
        or
        not Character
    then

        Runtime.NearestOpponentDistance =
            math.huge

        return math.huge
    end

    local Best =
        math.huge

    local Alive =
        GetAliveFolder()

    if Alive then

        for _, Entity in ipairs(
            Alive:GetChildren()
        ) do

            if
                Entity ~= Character
                and
                Entity.Name ~= Player.Name
            then

                local EntityRoot =
                    Entity:FindFirstChild(
                        "HumanoidRootPart"
                    )
                    or
                    Entity.PrimaryPart

                if EntityRoot then

                    local Distance =
                        (
                            EntityRoot.Position
                            -
                            Root.Position
                        ).Magnitude

                    if Distance < Best then

                        Best =
                            Distance
                    end
                end
            end
        end
    end

    Runtime.NearestOpponentDistance =
        Best

    return Best
end


local function ApplyProfile(
    Name
)

    Config.ActiveProfile =
        Name

    if Name == "Legit" then

        Config.MinParryConfidence = 72
        Config.PredictionTime = 0.13
        Config.PredictionRadius = 7
        Config.ExtraRange = -1
        Config.DynamicSlowBonus = 1
        Config.DynamicFastBonus = 2.5
        Config.CloseRangeETABonus = 0.020

    elseif Name == "Balanced" then

        Config.MinParryConfidence = 58
        Config.PredictionTime = 0.16
        Config.PredictionRadius = 9
        Config.ExtraRange = 0
        Config.DynamicSlowBonus = 2
        Config.DynamicFastBonus = 4.5
        Config.CloseRangeETABonus = 0.035

    elseif Name == "Fast" then

        Config.MinParryConfidence = 48
        Config.PredictionTime = 0.19
        Config.PredictionRadius = 10
        Config.ExtraRange = 2
        Config.DynamicSlowBonus = 2.5
        Config.DynamicFastBonus = 6
        Config.CloseRangeETABonus = 0.045

    elseif Name == "Aggressive" then

        Config.MinParryConfidence = 38
        Config.PredictionTime = 0.22
        Config.PredictionRadius = 12
        Config.ExtraRange = 4
        Config.DynamicSlowBonus = 3
        Config.DynamicFastBonus = 8
        Config.CloseRangeETABonus = 0.060
    end
end


local function CalculateParryConfidence(
    TimeToClosest,
    MissDistance,
    Curved
)

    local Root =
        GetRoot()

    if not Root then

        Runtime.ParryConfidence =
            0

        return 0
    end

    local DirectionScore =
        0

    local ToPlayer =
        Root.Position
        -
        Runtime.Position

    if
        Runtime.Speed > 0
        and
        ToPlayer.Magnitude > 0
    then

        local Dot =
            Runtime.Velocity.Unit:Dot(
                ToPlayer.Unit
            )

        DirectionScore =
            math.clamp(
                (
                    Dot
                    +
                    1
                )
                /
                2,
                0,
                1
            )
    end

    local ETAScore =
        0

    if
        TimeToClosest
        <
        math.huge
    then

        ETAScore =
            1
            -
            math.clamp(
                TimeToClosest
                /
                math.max(
                    Config.PredictionTime
                    +
                    0.10,
                    0.01
                ),
                0,
                1
            )
    end

    local TargetScore =
        IsTargetingMe()
        and
        1
        or
        0

    local CurveScore =
        Curved
        and
        0.35
        or
        1

    if
        MissDistance
        <=
        Config.PredictionRadius
    then

        CurveScore =
            math.max(
                CurveScore,
                0.65
            )
    end

    local TotalWeight =
        Config.ConfidenceDirectionWeight
        +
        Config.ConfidenceETAWeight
        +
        Config.ConfidenceTargetWeight
        +
        Config.ConfidenceCurveWeight

    local Score =
        (
            DirectionScore
            *
            Config.ConfidenceDirectionWeight
            +
            ETAScore
            *
            Config.ConfidenceETAWeight
            +
            TargetScore
            *
            Config.ConfidenceTargetWeight
            +
            CurveScore
            *
            Config.ConfidenceCurveWeight
        )
        /
        math.max(
            TotalWeight,
            1
        )

    Score =
        math.clamp(
            Score
            *
            100,
            0,
            100
        )

    Runtime.ParryConfidence =
        Score

    return Score
end


local function ShouldAllowDoubleParry()

    if
        not Config.DoubleParryGuardV2
    then

        return true
    end

    local Ball =
        Runtime.Ball

    if
        Ball ~= Runtime.LastParriedBall
        or
        not Runtime.GuardArmed
    then

        return true
    end

    local Since =
        os.clock()
        -
        Runtime.LastParryTimeV2

    ------------------------------------------------------------
    -- HARD REARM
    --
    -- V11 could get stuck here forever because it waited for a
    -- frame-to-frame direction dot to become negative. In normal
    -- rallies that dot is usually ~1 even after the ball returns.
    ------------------------------------------------------------

    if
        Since
        >=
        Config.DoubleParryHardRearmTime
    then

        Runtime.GuardArmed =
            false

        Runtime.GuardSawBallLeave =
            false

        return true
    end

    ------------------------------------------------------------
    -- NORMAL REARM
    --
    -- After our parry the ball must leave us / change target.
    -- Once it has left and later targets us again, another parry
    -- is permitted.
    ------------------------------------------------------------

    if
        Runtime.GuardSawBallLeave
        and
        IsTargetingMe()
        and
        Since
        >=
        Config.DoubleParryMinRearmTime
    then

        Runtime.GuardArmed =
            false

        Runtime.GuardSawBallLeave =
            false

        return true
    end

    return false
end



PushTrajectorySample = function()

    local History =
        Runtime.TrajectoryHistory

    table.insert(
        History,
        1,
        {
            T = os.clock(),
            P = Runtime.Position,
            V = Runtime.Velocity,
        }
    )

    while
        #History > Config.InterceptHistorySize
    do

        table.remove(
            History
        )
    end
end


CalculateCurveDeltaV2 = function()

    local History =
        Runtime.TrajectoryHistory

    if #History < 4 then

        Runtime.CurveDeltaV2 =
            0

        return 0
    end

    local Sum =
        0

    local Count =
        0

    for Index = 1, #History - 2 do

        local A =
            History[Index].V

        local B =
            History[Index + 1].V

        if
            A.Magnitude > 0
            and
            B.Magnitude > 0
        then

            local Dot =
                math.clamp(
                    A.Unit:Dot(
                        B.Unit
                    ),
                    -1,
                    1
                )

            Sum +=
                math.acos(
                    Dot
                )

            Count +=
                1
        end
    end

    local Average =
        Count > 0
        and Sum / Count
        or 0

    Runtime.CurveDeltaV2 =
        Average

    return Average
end


GetInterceptPrediction = function()

    local Root =
        GetRoot()

    if not Root then

        Runtime.InterceptETA =
            math.huge

        Runtime.InterceptMiss =
            math.huge

        return math.huge,
            math.huge
    end

    local Relative =
        Runtime.Position
        -
        Root.Position

    local Velocity =
        Runtime.Velocity

    if Config.AccelerationPrediction then

        Velocity =
            Velocity
            +
            Runtime.BallAcceleration
            *
            0.5
            *
            Config.InterceptMaxTime
    end

    local SpeedSquared =
        Velocity:Dot(
            Velocity
        )

    if SpeedSquared <= 0.001 then

        Runtime.InterceptETA =
            math.huge

        Runtime.InterceptMiss =
            Relative.Magnitude

        return Runtime.InterceptETA,
            Runtime.InterceptMiss
    end

    local ETA =
        -Relative:Dot(
            Velocity
        )
        /
        SpeedSquared

    if
        ETA < 0
        or
        ETA > Config.InterceptMaxTime
    then

        ETA =
            math.huge
    end

    local Miss =
        Relative.Magnitude

    if ETA < math.huge then

        local Closest =
            Relative
            +
            Velocity
            *
            ETA

        Miss =
            Closest.Magnitude
    end

    Runtime.InterceptETA =
        ETA

    Runtime.InterceptMiss =
        Miss

    return ETA,
        Miss
end


IsCurveV2 = function()

    if not Config.CurveDetectionV2 then
        return false
    end

    return
        CalculateCurveDeltaV2()
        >=
        Config.CurveDeltaThreshold
end


GetAdaptiveThreshold = function()

    local Threshold =
        Config.PredictionTime
        +
        Config.PredictionLead
        +
        Runtime.AdaptiveTimingLead
        +
        (
            Runtime.Ping / 1000
        )
        *
        0.5

    if
        Config.FastBallMode
        and
        Runtime.Speed >= Config.FastBallSpeed
    then

        Threshold +=
            0.035
    end

    if
        Config.SlowBallModeV2
        and
        Runtime.Speed <= Config.SlowBallModeSpeed
    then

        Threshold +=
            0.020
    end

    return Threshold
end


UpdateParryStateMachine = function()

    if not Config.ParryStateMachine then

        Runtime.ParryState =
            "READY"

        return
    end

    local Now =
        os.clock()

    if
        Runtime.ParryState ~= "READY"
        and
        Now - Runtime.ParryStateSince
        >=
        Config.ParryStateHardReset
    then

        Runtime.ParryState =
            "READY"

        Runtime.ParryStateSince =
            Now
    end

    if Runtime.ParryState == "PARRY_SENT" then

        if not IsTargetingMe() then

            Runtime.ParryState =
                "BALL_LEFT"

            Runtime.ParryStateSince =
                Now
        end

    elseif Runtime.ParryState == "BALL_LEFT" then

        if IsTargetingMe() then

            Runtime.ParryState =
                "READY"

            Runtime.ParryStateSince =
                Now
        end
    end
end


AdaptiveTimingOnParry = function()

    if not Config.AdaptiveTiming then
        return
    end

    local ETA =
        Runtime.InterceptETA

    if ETA == math.huge then
        return
    end

    if ETA > 0.11 then

        Runtime.AdaptiveTimingLead =
            math.max(
                Config.AdaptiveLeadMin,
                Runtime.AdaptiveTimingLead
                -
                Config.AdaptiveLeadStep
            )

    elseif ETA < 0.045 then

        Runtime.AdaptiveTimingLead =
            math.min(
                Config.AdaptiveLeadMax,
                Runtime.AdaptiveTimingLead
                +
                Config.AdaptiveLeadStep
            )
    end
end


-- PREDICTIVE PARRY

local function GetPredictiveImpact()

    local Root =
        GetRoot()

    if not Root then
        return math.huge, math.huge
    end

    local RelativePosition =
        Runtime.Position
        -
        Root.Position

    local PredictVelocity =
        Runtime.Velocity

    if Config.AccelerationPrediction then

        PredictVelocity =
            PredictVelocity
            +
            Runtime.BallAcceleration
            *
            Config.PredictionTime
            *
            0.5
    end

    local SpeedSquared =
        PredictVelocity:Dot(
            PredictVelocity
        )

    if SpeedSquared <= 0.001 then
        return math.huge, RelativePosition.Magnitude
    end

    local TimeToClosest =
        -RelativePosition:Dot(
            PredictVelocity
        )
        /
        SpeedSquared

    if TimeToClosest < 0 then
        return math.huge, RelativePosition.Magnitude
    end

    local Closest =
        RelativePosition
        +
        PredictVelocity
        *
        TimeToClosest

    return TimeToClosest, Closest.Magnitude
end


local function ShouldPredictiveParry()

    if
        not Config.PredictiveParry
        or
        not IsTargetingMe()
    then

        return false
    end

    local TimeToClosest,
        MissDistance

    if
        Config.InterceptEngine
        and
        GetInterceptPrediction
    then

        local PredictSuccess,
            PredictedA,
            PredictedB =
            pcall(
                GetInterceptPrediction
            )

        if PredictSuccess then

            TimeToClosest =
                PredictedA

            MissDistance =
                PredictedB

        else

            warn(
                "[ZENX INTERCEPT ERROR]",
                PredictedA
            )

            TimeToClosest,
                MissDistance =
                GetPredictiveImpact()
        end

    else

        TimeToClosest,
            MissDistance =
            GetPredictiveImpact()
    end

    Runtime.PredictedETA =
        TimeToClosest

    Runtime.PredictedMissDistance =
        MissDistance

    local Curved =
        IsCurved()

    if
        IsCurveV2
        and
        Config.CurveDetectionV2
    then

        local CurveSuccess,
            CurveResult =
            pcall(
                IsCurveV2
            )

        if CurveSuccess then

            Curved =
                Curved
                or
                CurveResult

        else

            warn(
                "[ZENX CURVE V2 ERROR]",
                CurveResult
            )
        end
    end

    local Confidence =
        CalculateParryConfidence(
            TimeToClosest,
            MissDistance,
            Curved
        )

    if
        Config.SmartParryV2
        and
        Confidence
        <
        Config.MinParryConfidence
    then

        return false
    end

    local Threshold =
        GetAdaptiveThreshold()

    if Config.CloseRangeMode then

        local OpponentDistance =
            GetNearestOpponentDistance()

        if
            OpponentDistance
            <=
            Config.CloseRangeOpponentDistance
        then

            Threshold +=
                Config.CloseRangeETABonus
        end
    end

    if
        Config.TargetSwitchBoost
        and
        os.clock()
        -
        Runtime.LastTargetSwitchTime
        <=
        Config.TargetSwitchWindow
    then

        Threshold += 0.04
    end

    local Radius =
        Config.PredictionRadius

    if Runtime.Speed >= 180 then
        Radius += 2
    elseif Runtime.Speed <= 70 then
        Radius += 1
    end

    return
        TimeToClosest <= Threshold
        and
        MissDistance <= Radius
end


-- ORIGINAL PARRY RANGE

local function CalculateParryRange()

    local PingRange =
        math.clamp(
            Runtime.Ping / 10,
            10,
            16
        )

    local MaximumSpeedRange =
        (
            Runtime.MaximumSpeed
            /
            11.7
        )
        +
        PingRange

    -- original: movimento do próprio player reduz esse termo

    local Root =
        GetRoot()

    local PlayerMoving =
        Root
        and
        Root.AssemblyLinearVelocity.Magnitude
        >
        30

    if PlayerMoving then

        MaximumSpeedRange *=
            0.8
    end

    if Runtime.Ping >= 190 then

        MaximumSpeedRange *=
            (
                1
                +
                (
                    Runtime.Ping / 1000
                )
            )
    end

    local Range =
        (
            (
                MaximumSpeedRange
                *
                1.16
            )
            +
            PingRange
            +
            Runtime.Speed
        )
        /
        Config.RangeDivisor

    local Character =
        GetCharacter()

    if
        Character
        and
        Character:GetAttribute(
            "CurrentlyEquippedSword"
        )
        ==
        "Titan Blade"
    then

        Range +=
            11
    end

    local DynamicBonus =
        0

    if Config.DynamicRange then

        if Runtime.Speed <= 75 then

            DynamicBonus +=
                Config.DynamicSlowBonus

        elseif
            Runtime.Speed
            >=
            Config.DynamicVeryFastSpeed
        then

            DynamicBonus +=
                Config.DynamicFastBonus
        end
    end

    if Config.CloseRangeMode then

        local OpponentDistance =
            Runtime.NearestOpponentDistance

        if
            OpponentDistance
            <=
            Config.CloseRangeOpponentDistance
        then

            DynamicBonus +=
                Config.CloseRangeRangeBonus
        end
    end

    Runtime.ParryRange =
        Range
        +
        Config.ExtraRange
        +
        DynamicBonus

    return Runtime.ParryRange,
        MaximumSpeedRange,
        PingRange
end

-- BACK CURVE

local function CurveCameraBeforeParry()

    if
        not Config.AutoCurve
        or
        not Runtime.UseBackCurveThisParry
    then

        return nil
    end

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local Original =
        Camera.CFrame

    local Mode =
        Config.AutoCurveMode

    if
        Config.SmartCurveDirection == "Smart"
        and
        Mode == "Custom"
    then

        local Root =
            GetRoot()

        local NearestSide =
            Config.FixedCurveSide

        if Root then

            local Alive =
                GetAliveFolder()

            local BestDistance =
                math.huge

            if Alive then

                for _, Entity in ipairs(
                    Alive:GetChildren()
                ) do

                    if
                        Entity ~= GetCharacter()
                    then

                        local ER =
                            Entity:FindFirstChild(
                                "HumanoidRootPart"
                            )

                        if ER then

                            local Offset =
                                ER.Position
                                -
                                Root.Position

                            local Dist =
                                Offset.Magnitude

                            if
                                Dist < BestDistance
                                and
                                Dist > 0
                            then

                                BestDistance =
                                    Dist

                                local RightDot =
                                    Root.CFrame.RightVector:Dot(
                                        Offset.Unit
                                    )

                                NearestSide =
                                    RightDot >= 0
                                    and -1
                                    or 1
                            end
                        end
                    end
                end
            end
        end

        Config.FixedCurveSide =
            NearestSide
    end

    local Side =
        Config.FixedCurveSide

    local Angle =
        Config.BackCurveAngle

    if Mode == "Back" then

        Side =
            Config.FixedCurveSide

        Angle =
            math.max(
                Config.BackCurveAngle,
                150
            )

    elseif Mode == "Left" then

        Side = -1
        Angle = 90

    elseif Mode == "Right" then

        Side = 1
        Angle = 90

    elseif Mode == "Random" then

        Side =
            math.random(
                0,
                1
            )
            ==
            0
            and -1
            or 1

        Angle =
            math.random(
                110,
                175
            )

    else
        -- Custom
        if Config.AlternateCurve then

            Side =
                Runtime.CurveSide

            Runtime.CurveSide =
                -Runtime.CurveSide
        end
    end

    Camera.CFrame =
        Original
        *
        CFrame.Angles(
            0,
            math.rad(
                Angle
                *
                Side
            ),
            0
        )

    return Original
end


local function ChooseAdaptiveCurveInterval()

    local Min =
        math.max(
            1,
            math.floor(
                Config.CurveAutoMin
            )
        )

    local Max =
        math.max(
            Min,
            math.floor(
                Config.CurveAutoMax
            )
        )

    ------------------------------------------------------------
    -- ADAPTIVE AUTO:
    -- rally rápido / bola muito rápida -> tende a curvar mais cedo
    -- rally normal -> faixa intermediária
    -- rally lento -> segura por mais parries
    ------------------------------------------------------------

    local Speed =
        Runtime.Speed
        or
        0

    local Ping =
        Runtime.Ping
        or
        0

    local Low =
        Min

    local High =
        Max

    if Speed >= 220 then

        High =
            math.min(
                Max,
                3
            )

    elseif Speed >= 140 then

        High =
            math.min(
                Max,
                4
            )

    elseif Speed <= 70 then

        Low =
            math.max(
                Min,
                2
            )
    end

    ------------------------------------------------------------
    -- ping alto: evita trocar curva cedo demais toda hora
    ------------------------------------------------------------

    if Ping >= 140 then

        Low =
            math.max(
                Low,
                2
            )
    end

    if Low > High then

        Low =
            High
    end

    local Next =
        math.random(
            Low,
            High
        )

    ------------------------------------------------------------
    -- evita repetir o mesmo intervalo muitas vezes seguidas
    ------------------------------------------------------------

    if
        Max > Min
        and
        Next == Runtime.CurveLastInterval
    then

        local Retry =
            math.random(
                Low,
                High
            )

        if Retry ~= Next then

            Next =
                Retry
        end
    end

    Runtime.CurveLastInterval =
        Next

    Config.CurveAutoNext =
        Next

    return Next
end


local function GetCurveInterval()

    if
        Config.CurveEveryMode
        ==
        "Auto"
    then

        local Current =
            tonumber(
                Config.CurveAutoNext
            )

        if
            not Current
            or
            Current < 1
        then

            Current =
                ChooseAdaptiveCurveInterval()
        end

        return Current
    end

    local Fixed =
        tonumber(
            Config.CurveEveryMode
        )

    if not Fixed then

        Fixed =
            3
    end

    return
        math.clamp(
            math.floor(
                Fixed
            ),
            1,
            6
        )
end


-- PARRY INPUT

local function SendParryInput()

    local OriginalCamera =
        CurveCameraBeforeParry()

    local Sent =
        false

    -- PARRY TYPE

    if Config.ParryType == "Key" then

        pcall(function()

            VIM:SendKeyEvent(
                true,
                Enum.KeyCode.F,
                false,
                game
            )

            VIM:SendKeyEvent(
                false,
                Enum.KeyCode.F,
                false,
                game
            )
        end)

        Sent = true

    elseif Config.ParryType == "Remote" then

        -- Remote fica opcional/fallback-safe.
        -- Se o remote real não estiver disponível, cai pro mouse.

        if
            Runtime.ParryRemote
            and
            Runtime.ParryRemote.Parent
        then

            local Success =
                pcall(function()

                    Runtime.ParryRemote:FireServer()
                end)

            Sent = Success
        end
    end

    if not Sent then

        pcall(function()

            VIM:SendMouseButtonEvent(
                0,
                0,
                0,
                true,
                game,
                0.001
            )

            VIM:SendMouseButtonEvent(
                0,
                0,
                0,
                false,
                game,
                0.001
            )
        end)
    end

    if OriginalCamera then

        task.delay(
            Config.CurveHold,
            function()

                local Camera =
                    workspace.CurrentCamera

                if Camera then
                    Camera.CFrame =
                        OriginalCamera
                end
            end
        )
    end
end

-- PERFORM PARRY
--
-- O cooldown é igual ao conceito do original:
-- 1 parry por ciclo de target.

local function PerformParry(
    PingRange
)

    if Runtime.Cooldown then
        return false
    end

    Runtime.Parries +=
        1

    Runtime.SuccessfulParries +=
        1

    Runtime.LastHit =
        tick()

    Runtime.Cooldown =
        true

    ------------------------------------------------------------
    -- CURVE EVERY / AUTO
    ------------------------------------------------------------

    Runtime.CurveParryCounter +=
        1

    local CurveInterval =
        GetCurveInterval()

    Runtime.UseBackCurveThisParry =
        Config.AutoCurve
        and
        Runtime.CurveParryCounter
        >=
        CurveInterval

    if Runtime.UseBackCurveThisParry then

        Runtime.CurveParryCounter =
            0

        if
            Config.CurveEveryMode
            ==
            "Auto"
        then

            ChooseAdaptiveCurveInterval()
        end
    end

    SendParryInput()

    Runtime.Status =
        Runtime.UseBackCurveThisParry
        and
        "PARRY + BACK CURVE"
        or
        "PARRY"

    -- original fallback:
    -- > (1 - pingRange/100)

    if Config.CooldownFallback then

        Runtime.CooldownUntil =
            tick()
            +
            math.max(
                0.25,
                1
                -
                (
                    PingRange / 100
                )
            )
    end

    task.delay(
        0.8,
        function()

            if Runtime.Parries > 0 then
                Runtime.Parries -= 1
            end
        end
    )

    return true
end

-- MAIN ORIGINAL AUTO PARRY

local function UpdateAutoParry()

    if UpdateParryStateMachine then

        local StateSuccess,
            StateError =
            pcall(
                UpdateParryStateMachine
            )

        if not StateSuccess then

            warn(
                "[ZENX STATE ERROR]",
                StateError
            )

            Runtime.ParryState =
                "READY"
        end
    end

    if not Config.AutoParry then

        Runtime.Status =
            "IDLE"

        return
    end

    if not IsAlive() then

        Runtime.Status =
            "DEAD"

        return
    end

    local Ball =
        Runtime.Ball

    if
        not Ball
        or
        not Ball.Parent
        or
        not IsRealBall(Ball)
    then

        Ball =
            FindBall()

        SetBall(
            Ball
        )
    end

    if not Ball then

        Runtime.Status =
            "NO BALL"

        return
    end

    UpdateEntityData()

    if not UpdateBallData() then
        return
    end

    -- fallback unlock

    if
        Runtime.Cooldown
        and
        Runtime.CooldownUntil > 0
        and
        tick()
        >=
        Runtime.CooldownUntil
    then

        Runtime.Cooldown =
            false

        Runtime.CooldownUntil =
            0
    end

    local Curved =
        IsCurved()

    local ParryRange,
        MaximumSpeedRange,
        PingRange =
        CalculateParryRange()

    -- SMART CORE SAFETY

    local EffectiveRange =
        ParryRange

    -- PARRY ACCURACY
    -- 100 = range calculado inteiro.
    -- valores menores seguram um pouco mais o parry.

    local Accuracy =
        Config.ParryAccuracy

    if Config.RandomAccuracy then

        local Low =
            math.min(
                Config.AccuracyMin,
                Config.AccuracyMax
            )

        local High =
            math.max(
                Config.AccuracyMin,
                Config.AccuracyMax
            )

        Accuracy =
            math.random(
                Low,
                High
            )
    end

    EffectiveRange *=
        math.clamp(
            Accuracy / 100,
            0.40,
            1.20
        )

    if
        Config.SlowBallFix
        and
        Runtime.Speed
        <=
        Config.SlowBallSpeed
    then

        EffectiveRange =
            math.max(
                EffectiveRange,
                Config.SlowBallRange
            )
    end

    local ClosingSpeed =
        math.max(
            0,
            Runtime.Velocity:Dot(
                Runtime.Direction
            )
        )

    local ETA =
        math.huge

    if ClosingSpeed > 0.001 then

        ETA =
            Runtime.Distance
            /
            ClosingSpeed
    end

    local CriticalHit =
        Config.CriticalETAFix
        and
        ETA
        <=
        (
            Config.CriticalETA
            +
            (
                Runtime.Ping / 1000
            )
            *
            0.5
        )

    local CurveEmergencyHit =
        Config.CurveEmergency
        and
        Curved
        and
        Runtime.Distance
        <=
        Config.CurveEmergencyRange

    local PredictiveHit =
        ShouldPredictiveParry()

    -- ORIGINAL curve block, with predictive bypass

    if
        Curved
        and
        not CurveEmergencyHit
        and
        not CriticalHit
        and
        not PredictiveHit
    then

        Runtime.Status =
            "CURVED BALL"

        return
    end

    -- ORIGINAL 4-WAY RANGE CHECK

    local PingMultiplier =
        1
        +
        (
            Runtime.Ping / 1000
        )

    if
        not PredictiveHit
        and
        Runtime.Distance
        >
        EffectiveRange
        and
        Runtime.Distance
        >
        MaximumSpeedRange
        and
        Runtime.Distance
        >
        (
            EffectiveRange
            *
            PingMultiplier
        )
        and
        Runtime.Distance
        >
        (
            MaximumSpeedRange
            *
            PingMultiplier
        )
    then

        Runtime.Status =
            "TRACKING"

        return
    end

    -- ORIGINAL TARGET CHECK

    if
        Runtime.Target
        and
        not IsTargetingMe()
    then

        Runtime.Status =
            "NOT TARGET"

        return
    end

    if
        Config.ParryStateMachine
        and
        Runtime.ParryState ~= "READY"
    then

        Runtime.Status =
            Runtime.ParryState

        return
    end

    if
        not ShouldAllowDoubleParry()
    then

        Runtime.Status =
            "DOUBLE GUARD"

        return
    end

    if PredictiveHit then

        Runtime.Status =
            "PREDICTED PARRY"
    end

    PerformParry(
        PingRange
    )

    Runtime.ParryState =
        "PARRY_SENT"

    Runtime.ParryStateSince =
        os.clock()

    Runtime.LastConfirmedParryTime =
        os.clock()

    if AdaptiveTimingOnParry then

        pcall(
            AdaptiveTimingOnParry
        )
    end

    Runtime.LastParriedBall =
        Runtime.Ball

    Runtime.LastParryTimeV2 =
        os.clock()

    Runtime.GuardArmed =
        true

    Runtime.GuardSawBallLeave =
        false

    Runtime.GuardLastTargetName =
        Runtime.Ball
        and
        Runtime.Ball:GetAttribute(
            "target"
        )
        or
        nil
end

-- REMOTE EVENTS USED BY ORIGINAL FOR REARM

local Remotes =
    ReplicatedStorage:FindFirstChild(
        "Remotes"
    )

if Remotes then

    local ParrySuccessAll =
        Remotes:FindFirstChild(
            "ParrySuccessAll"
        )

    if
        ParrySuccessAll
        and
        ParrySuccessAll:IsA("RemoteEvent")
    then

        Connect(
            ParrySuccessAll.OnClientEvent,
            function(
                _,
                Hit
            )

                if
                    Hit
                    and Hit.Parent
                    and
                    Hit.Parent
                    ~=
                    GetCharacter()
                then

                    Runtime.Cooldown =
                        false

                    Runtime.CooldownUntil =
                        0

                    if Runtime.GuardArmed then

                        Runtime.GuardSawBallLeave =
                            true
                    end
                end
            end
        )
    end

    local HellHooked =
        Remotes:FindFirstChild(
            "PlrHellHooked"
        )

    if
        HellHooked
        and
        HellHooked:IsA("RemoteEvent")
    then

        Connect(
            HellHooked.OnClientEvent,
            function(Entity)

                if
                    Entity
                    and
                    Entity.Name
                    ==
                    Player.Name
                then

                    Runtime.HellHookCompleted =
                        true
                else

                    Runtime.HellHookCompleted =
                        false
                end
            end
        )
    end

    local HellDone =
        Remotes:FindFirstChild(
            "PlrHellHookCompleted"
        )

    if
        HellDone
        and
        HellDone:IsA("RemoteEvent")
    then

        Connect(
            HellDone.OnClientEvent,
            function()

                Runtime.HellHookCompleted =
                    true
            end
        )
    end
end

-- BALL EVENTS

local BallsFolder =
    GetBallsFolder()

if
    BallsFolder
    and
    (
        BallsFolder:IsA("Folder")
        or
        BallsFolder:IsA("Model")
    )
then

    Connect(
        BallsFolder.ChildAdded,
        function(Object)

            task.defer(function()

                if IsRealBall(Object) then

                    SetBall(
                        Object
                    )

                    Runtime.Status =
                        "BALL FOUND"
                end
            end)
        end
    )

    Connect(
        BallsFolder.ChildRemoved,
        function(Object)

            if Runtime.Ball == Object then

                SetBall(
                    nil
                )

                Runtime.Status =
                    "NO BALL"
            end
        end
    )
end

-- FAST KEY SPAM ENGINE
--
-- Não usa task.wait(1/CPS), porque o scheduler do Roblox não
-- respeita intervalos minúsculos com precisão.
--
-- Em vez disso, envia poucos taps completos por Heartbeat.
-- Isso fica muito rápido sem criar centenas de tasks/loops.

local function SpamKeyTap()

    local Key =
        Config.SpamInputKey

    VIM:SendKeyEvent(
        true,
        Key,
        false,
        game
    )

    VIM:SendKeyEvent(
        false,
        Key,
        false,
        game
    )
end

local function ShouldFastSpam()

    local AutoSpamNow =
        Config.AutoSpam
        and
        Runtime.Distance > 0
        and
        Runtime.Distance
        <=
        Config.SpamDistance
        and
        IsTargetingMe()

    if
        not Config.SpamActive
        and
        not AutoSpamNow
    then

        return false
    end

    if
        Config.SpamRequireFocus
        and
        UIS:GetFocusedTextBox()
    then

        return false
    end

    return true
end


local function UpdateFastSpam()

    if not ShouldFastSpam() then
        return
    end

    local Burst =
        math.clamp(
            math.floor(
                Config.SpamBurstPerFrame
            ),
            1,
            Config.SpamMaxBurst
        )

    ------------------------------------------------------------
    -- No task.wait here. Each phase sends complete key taps.
    -- This avoids hundreds of spawned loops accumulating.
    ------------------------------------------------------------

    for _ = 1, Burst do

        SpamKeyTap()
    end
end


Connect(
    RunService.Heartbeat,
    function()

        if not Runtime.Alive then
            return
        end

        if not Runtime.Alive then
            return
        end

        local Success,
            ErrorMessage =
            pcall(
                UpdateFastSpam
            )

        if not Success then

            Runtime.Status =
                "SPAM ERROR: "
                ..
                tostring(
                    ErrorMessage
                )

            warn(
                "[ZENX SPAM ERROR]",
                ErrorMessage
            )
        end
    end
)

Connect(
    RunService.PreSimulation,
    function()

        if
            not Runtime.Alive
            or
            not Config.SpamTurbo
            or
            not Config.SpamMultiPhase
        then

            return
        end

        pcall(
            UpdateFastSpam
        )
    end
)

Connect(
    RunService.PostSimulation,
    function()

        if
            not Runtime.Alive
            or
            not Config.SpamTurbo
            or
            not Config.SpamMultiPhase
        then

            return
        end

        pcall(
            UpdateFastSpam
        )
    end
)


-- MAIN LOOP

Connect(
    RunService.PreSimulation,
    function()

        if not Runtime.Alive then
            return
        end

        if not Runtime.Alive then
            return
        end

        local Success,
            ErrorMessage =
            pcall(
                UpdateAutoParry
            )

        if not Success then

            Runtime.Status =
                "PARRY ERROR: "
                ..
                tostring(
                    ErrorMessage
                )

            warn(
                "[ZENX PARRY ERROR]",
                ErrorMessage
            )
        end
    end
)

-- THEME

local Theme =
{

    Background =
        Color3.fromRGB(
            7,
            8,
            14
        ),

    Sidebar =
        Color3.fromRGB(
            10,
            11,
            20
        ),

    Surface =
        Color3.fromRGB(
            13,
            14,
            23
        ),

    Surface2 =
        Color3.fromRGB(
            17,
            18,
            29
        ),

    Card =
        Color3.fromRGB(
            19,
            20,
            32
        ),

    CardHover =
        Color3.fromRGB(
            24,
            25,
            39
        ),

    Border =
        Color3.fromRGB(
            54,
            58,
            80
        ),

    BorderBright =
        Color3.fromRGB(
            92,
            76,
            255
        ),

    Accent =
        Color3.fromRGB(
            86,
            69,
            255
        ),

    Accent2 =
        Color3.fromRGB(
            125,
            74,
            255
        ),

    Accent3 =
        Color3.fromRGB(
            58,
            168,
            255
        ),

    AccentSoft =
        Color3.fromRGB(
            29,
            26,
            72
        ),

    Text =
        Color3.fromRGB(
            247,
            248,
            252
        ),

    Muted =
        Color3.fromRGB(
            143,
            147,
            166
        ),

    Muted2 =
        Color3.fromRGB(
            105,
            109,
            130
        ),

    Success =
        Color3.fromRGB(
            93,
            232,
            113
        ),

    Warning =
        Color3.fromRGB(
            255,
            194,
            72
        ),

    Danger =
        Color3.fromRGB(
            255,
            81,
            98
        ),

}

-- STATE

local State =
{

    Visible =
        true,

    Minimized =
        false,

    ActiveTab =
        "Main",

    OpenDropdown =
        nil,

    HideKey =
        Enum.KeyCode.Insert,

    AltHideKey =
        Enum.KeyCode.RightShift,

    SearchText =
        "",

    UIAnimation =
        true,

    PerformanceMode =
        false,

}

-- TWEEN PRESETS

local TweenFast =
    TweenInfo.new(
        0.14,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

local TweenNormal =
    TweenInfo.new(
        0.22,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

local TweenSmooth =
    TweenInfo.new(
        0.30,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

local TweenBack =
    TweenInfo.new(
        0.32,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )

-- HELPERS

local function PlayTween(
    Object,
    Properties,
    Info
)

    if
        State.PerformanceMode
        or
        not State.UIAnimation
    then

        for Property,
            Value
        in pairs(
            Properties
        )
        do

            Object[
                Property
            ]
            =
            Value

        end

        return nil

    end

    local Tween =
        TweenService:Create(
            Object,
            Info
            or
            TweenNormal,
            Properties
        )

    Tween:Play()

    return Tween

end

local function AddCorner(
    Object,
    Radius
)

    local Corner =
        Instance.new(
            "UICorner"
        )

    Corner.CornerRadius =
        UDim.new(
            0,
            Radius
            or
            8
        )

    Corner.Parent =
        Object

    return Corner

end

local function AddStroke(
    Object,
    Color,
    Transparency,
    Thickness
)

    local Stroke =
        Instance.new(
            "UIStroke"
        )

    Stroke.Color =
        Color
        or
        Theme.Border

    Stroke.Transparency =
        Transparency
        or
        0

    Stroke.Thickness =
        Thickness
        or
        1

    Stroke.Parent =
        Object

    return Stroke

end

local function AddGradient(
    Object,
    ColorA,
    ColorB,
    Rotation
)

    local Gradient =
        Instance.new(
            "UIGradient"
        )

    Gradient.Color =
        ColorSequence.new(
            ColorA,
            ColorB
        )

    Gradient.Rotation =
        Rotation
        or
        0

    Gradient.Parent =
        Object

    return Gradient

end

local function CreateTextLabel(
    Parent,
    Text,
    Position,
    Size,
    Font,
    TextSize,
    TextColor,
    Alignment
)

    local Label =
        Instance.new(
            "TextLabel"
        )

    Label.BackgroundTransparency =
        1

    Label.Position =
        Position

    Label.Size =
        Size

    Label.Text =
        Text

    Label.Font =
        Font
        or
        Enum.Font.Gotham

    Label.TextSize =
        TextSize
        or
        12

    Label.TextColor3 =
        TextColor
        or
        Theme.Text

    Label.TextXAlignment =
        Alignment
        or
        Enum.TextXAlignment.Left

    Label.TextYAlignment =
        Enum.TextYAlignment.Center

    Label.Parent =
        Parent

    return Label

end

local function CreateIconButton(
    Parent,
    Text,
    Position
)

    local Button =
        Instance.new(
            "TextButton"
        )

    Button.Size =
        UDim2.fromOffset(
            42,
            42
        )

    Button.Position =
        Position

    Button.BackgroundColor3 =
        Theme.Surface2

    Button.BorderSizePixel =
        0

    Button.AutoButtonColor =
        false

    Button.Text =
        Text

    Button.TextColor3 =
        Theme.Text

    Button.Font =
        Enum.Font.GothamBold

    Button.TextSize =
        16

    Button.Parent =
        Parent

    AddCorner(
        Button,
        9
    )

    AddStroke(
        Button,
        Theme.Border,
        0.35,
        1
    )

    Button.MouseEnter:Connect(
        function()

            PlayTween(
                Button,
                {
                    BackgroundColor3 =
                        Theme.CardHover,
                },
                TweenFast
            )

        end
    )

    Button.MouseLeave:Connect(
        function()

            PlayTween(
                Button,
                {
                    BackgroundColor3 =
                        Theme.Surface2,
                },
                TweenFast
            )

        end
    )

    return Button

end

-- ROOT GUI
--==============================================================
-- ZENX BLADE BALL V13 - CLEAN SIDEBAR UI
--==============================================================

print("[ZENX] BOOT 2/3 - creating clean UI")

local ScreenGui =
    Instance.new(
        "ScreenGui"
    )

ScreenGui.Name =
    "ZenxBladeBallV13CleanUI"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.IgnoreGuiInset =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
    PlayerGui

--==============================================================
-- CLEANUP / SINGLE INSTANCE
--==============================================================

local ThisEngineAlive =
    true

local function CleanupZenxBladeBall()

    if not ThisEngineAlive then
        return
    end

    ThisEngineAlive =
        false

    Runtime.Alive =
        false

    if Runtime.TargetConnection then
        pcall(function()
            Runtime.TargetConnection:Disconnect()
        end)
        Runtime.TargetConnection = nil
    end

    for _, Connection in ipairs(Runtime.Connections) do
        pcall(function()
            Connection:Disconnect()
        end)
    end

    table.clear(Runtime.Connections)

    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

if GlobalEnvironment then
    GlobalEnvironment.ZenxBladeBallCleanup =
        CleanupZenxBladeBall
end

--==============================================================
-- UI THEME V13
--==============================================================

local UI = {
    Bg = Color3.fromRGB(12, 13, 18),
    Side = Color3.fromRGB(15, 16, 22),
    Surface = Color3.fromRGB(18, 19, 26),
    Surface2 = Color3.fromRGB(22, 23, 31),
    Line = Color3.fromRGB(38, 40, 51),
    Accent = Color3.fromRGB(226, 34, 184),
    Accent2 = Color3.fromRGB(132, 63, 255),
    Text = Color3.fromRGB(242, 243, 248),
    Muted = Color3.fromRGB(137, 141, 157),
    Green = Color3.fromRGB(72, 224, 137),
    Danger = Color3.fromRGB(245, 74, 95),
}

local function UICorner(Object, Radius)
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, Radius or 8)
    C.Parent = Object
    return C
end

local function UIStroke(Object, Color, Transparency)
    local S = Instance.new("UIStroke")
    S.Color = Color or UI.Line
    S.Transparency = Transparency or 0
    S.Thickness = 1
    S.Parent = Object
    return S
end

local function Tween(Object, Props, Time)
    local T = TweenService:Create(
        Object,
        TweenInfo.new(
            Time or 0.16,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        Props
    )
    T:Play()
    return T
end

local function Label(Parent, Text, Size, Position, Font, TextSize, Color)
    local L = Instance.new("TextLabel")
    L.BackgroundTransparency = 1
    L.Size = Size
    L.Position = Position
    L.Text = Text
    L.Font = Font or Enum.Font.Gotham
    L.TextSize = TextSize or 11
    L.TextColor3 = Color or UI.Text
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextYAlignment = Enum.TextYAlignment.Center
    L.Parent = Parent
    return L
end

--==============================================================
-- MAIN
--==============================================================

local Main =
    Instance.new(
        "Frame"
    )

Main.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

Main.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

Main.Size =
    UDim2.fromOffset(
        780,
        510
    )

Main.BackgroundColor3 =
    UI.Bg

Main.BorderSizePixel =
    0

Main.ClipsDescendants =
    true

Main.Parent =
    ScreenGui

UICorner(Main, 10)
UIStroke(Main, UI.Line, 0.15)

local AccentLine =
    Instance.new(
        "Frame"
    )

AccentLine.Size =
    UDim2.new(
        1,
        0,
        0,
        2
    )

AccentLine.BackgroundColor3 =
    UI.Accent

AccentLine.BorderSizePixel =
    0

AccentLine.Parent =
    Main

local AccentGradient =
    Instance.new(
        "UIGradient"
    )

AccentGradient.Color =
    ColorSequence.new(
        UI.Accent2,
        UI.Accent
    )

AccentGradient.Parent =
    AccentLine

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar =
    Instance.new(
        "Frame"
    )

Sidebar.Size =
    UDim2.fromOffset(
        150,
        510
    )

Sidebar.BackgroundColor3 =
    UI.Side

Sidebar.BorderSizePixel =
    0

Sidebar.Parent =
    Main

local Divider =
    Instance.new(
        "Frame"
    )

Divider.Size =
    UDim2.new(
        0,
        1,
        1,
        -20
    )

Divider.Position =
    UDim2.new(
        1,
        -1,
        0,
        10
    )

Divider.BackgroundColor3 =
    UI.Line

Divider.BorderSizePixel =
    0

Divider.Parent =
    Sidebar

local Brand =
    Label(
        Sidebar,
        "ZENX",
        UDim2.fromOffset(120, 22),
        UDim2.fromOffset(16, 16),
        Enum.Font.GothamBold,
        14,
        UI.Text
    )

local BrandSub =
    Label(
        Sidebar,
        "Blade Ball",
        UDim2.fromOffset(120, 18),
        UDim2.fromOffset(16, 37),
        Enum.Font.Gotham,
        9,
        UI.Muted
    )

local Version =
    Label(
        Sidebar,
        "v13 clean",
        UDim2.fromOffset(120, 16),
        UDim2.fromOffset(16, 54),
        Enum.Font.Code,
        8,
        UI.Accent
    )

local NavHolder =
    Instance.new(
        "Frame"
    )

NavHolder.Size =
    UDim2.new(
        1,
        -16,
        0,
        260
    )

NavHolder.Position =
    UDim2.fromOffset(
        8,
        92
    )

NavHolder.BackgroundTransparency =
    1

NavHolder.Parent =
    Sidebar

local NavLayout =
    Instance.new(
        "UIListLayout"
    )

NavLayout.Padding =
    UDim.new(
        0,
        5
    )

NavLayout.Parent =
    NavHolder

local Pages = {}
local NavButtons = {}
local CurrentTab = "Combat"

local function NewNav(Name, Symbol)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 36)
    B.BackgroundColor3 = UI.Side
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Text = "   " .. Symbol .. "   " .. Name
    B.TextColor3 = UI.Muted
    B.Font = Enum.Font.GothamMedium
    B.TextSize = 10
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.Parent = NavHolder
    UICorner(B, 7)

    local Active = Instance.new("Frame")
    Active.Name = "Active"
    Active.Size = UDim2.fromOffset(3, 0)
    Active.AnchorPoint = Vector2.new(0, 0.5)
    Active.Position = UDim2.new(0, 0, 0.5, 0)
    Active.BackgroundColor3 = UI.Accent
    Active.BorderSizePixel = 0
    Active.Parent = B
    UICorner(Active, 10)

    NavButtons[Name] = B
    return B
end

local StatusBox =
    Instance.new(
        "Frame"
    )

StatusBox.Size =
    UDim2.new(
        1,
        -16,
        0,
        78
    )

StatusBox.Position =
    UDim2.new(
        0,
        8,
        1,
        -90
    )

StatusBox.BackgroundColor3 =
    UI.Surface

StatusBox.BorderSizePixel =
    0

StatusBox.Parent =
    Sidebar

UICorner(StatusBox, 8)
UIStroke(StatusBox, UI.Line, 0.35)

local StatusTitle =
    Label(
        StatusBox,
        "ENGINE STATUS",
        UDim2.new(1, -20, 0, 18),
        UDim2.fromOffset(10, 8),
        Enum.Font.GothamBold,
        8,
        UI.Muted
    )

local StatusValue =
    Label(
        StatusBox,
        "READY",
        UDim2.new(1, -20, 0, 22),
        UDim2.fromOffset(10, 28),
        Enum.Font.GothamBold,
        10,
        UI.Green
    )

local StatusHint =
    Label(
        StatusBox,
        "Insert / RShift",
        UDim2.new(1, -20, 0, 16),
        UDim2.fromOffset(10, 52),
        Enum.Font.Code,
        8,
        UI.Muted
    )

--==============================================================
-- RIGHT SIDE / HEADER
--==============================================================

local Content =
    Instance.new(
        "Frame"
    )

Content.Size =
    UDim2.new(
        1,
        -150,
        1,
        0
    )

Content.Position =
    UDim2.fromOffset(
        150,
        0
    )

Content.BackgroundTransparency =
    1

Content.Parent =
    Main

local Header =
    Instance.new(
        "Frame"
    )

Header.Size =
    UDim2.new(
        1,
        0,
        0,
        58
    )

Header.BackgroundColor3 =
    UI.Bg

Header.BorderSizePixel =
    0

Header.Parent =
    Content

local HeaderTitle =
    Label(
        Header,
        "Combat",
        UDim2.fromOffset(250, 22),
        UDim2.fromOffset(18, 10),
        Enum.Font.GothamBold,
        14,
        UI.Text
    )

local HeaderSub =
    Label(
        Header,
        "Smart parry controls",
        UDim2.fromOffset(300, 18),
        UDim2.fromOffset(18, 31),
        Enum.Font.Gotham,
        8,
        UI.Muted
    )

local function TopButton(Text, X, Danger)
    local B = Instance.new("TextButton")
    B.Size = UDim2.fromOffset(30, 30)
    B.Position = UDim2.new(1, X, 0, 14)
    B.BackgroundColor3 = UI.Surface
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Text = Text
    B.TextColor3 = Danger and UI.Danger or UI.Muted
    B.Font = Enum.Font.GothamBold
    B.TextSize = 11
    B.Parent = Header
    UICorner(B, 7)
    UIStroke(B, UI.Line, 0.4)

    B.MouseEnter:Connect(function()
        Tween(B, {BackgroundColor3 = UI.Surface2})
    end)

    B.MouseLeave:Connect(function()
        Tween(B, {BackgroundColor3 = UI.Surface})
    end)

    return B
end

local MinButton = TopButton("—", -72, false)
local CloseButton = TopButton("×", -38, true)

--==============================================================
-- PAGE AREA
--==============================================================

local PageArea =
    Instance.new(
        "Frame"
    )

PageArea.Size =
    UDim2.new(
        1,
        -24,
        1,
        -72
    )

PageArea.Position =
    UDim2.fromOffset(
        12,
        62
    )

PageArea.BackgroundTransparency =
    1

PageArea.Parent =
    Content

local function NewPage(Name)
    local P = Instance.new("ScrollingFrame")
    P.Name = Name
    P.Size = UDim2.fromScale(1, 1)
    P.BackgroundTransparency = 1
    P.BorderSizePixel = 0
    P.ScrollBarThickness = 2
    P.ScrollBarImageColor3 = UI.Accent
    P.ScrollBarImageTransparency = 0.25
    P.ScrollingDirection = Enum.ScrollingDirection.Y
    P.CanvasSize = UDim2.fromOffset(0, 0)
    P.AutomaticCanvasSize = Enum.AutomaticSize.Y
    P.Visible = false
    P.Active = true
    P.Parent = PageArea

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 4)
    Pad.PaddingBottom = UDim.new(0, 12)
    Pad.PaddingLeft = UDim.new(0, 4)
    Pad.PaddingRight = UDim.new(0, 8)
    Pad.Parent = P

    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 6)
    L.Parent = P

    Pages[Name] = P
    return P
end

local function Section(Parent, Title)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 34)
    S.BackgroundTransparency = 1
    S.Parent = Parent

    local T = Label(
        S,
        Title,
        UDim2.new(1, -20, 1, 0),
        UDim2.fromOffset(2, 0),
        Enum.Font.GothamBold,
        9,
        UI.Muted
    )

    return S
end

local function Row(Parent, Name, Desc, Height)
    local R = Instance.new("Frame")
    R.Size = UDim2.new(1, 0, 0, Height or 52)
    R.BackgroundColor3 = UI.Surface
    R.BorderSizePixel = 0
    R.Parent = Parent
    UICorner(R, 7)

    local Title = Label(
        R,
        Name,
        UDim2.new(1, -170, 0, 20),
        UDim2.fromOffset(12, 7),
        Enum.Font.GothamMedium,
        10,
        UI.Text
    )

    local D = Label(
        R,
        Desc or "",
        UDim2.new(1, -170, 0, 16),
        UDim2.fromOffset(12, 27),
        Enum.Font.Gotham,
        7,
        UI.Muted
    )

    return R
end

local function Toggle(Parent, Name, Desc, Initial, Callback)
    local On = Initial
    local R = Row(Parent, Name, Desc, 52)

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.fromOffset(38, 20)
    Track.Position = UDim2.new(1, -50, 0.5, -10)
    Track.BackgroundColor3 = On and UI.Accent or UI.Line
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = R
    UICorner(Track, 10)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = On and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
    Knob.BackgroundColor3 = UI.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    UICorner(Knob, 10)

    Track.MouseButton1Click:Connect(function()
        On = not On

        Tween(
            Track,
            {
                BackgroundColor3 = On and UI.Accent or UI.Line
            }
        )

        Tween(
            Knob,
            {
                Position = On and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
            }
        )

        if Callback then
            Callback(On)
        end
    end)

    return R
end

local function Slider(Parent, Name, Desc, Min, Max, Initial, Suffix, Callback)
    local Value = Initial
    local R = Row(Parent, Name, Desc, 66)

    local ValueLabel = Label(
        R,
        tostring(Value) .. (Suffix or ""),
        UDim2.fromOffset(70, 20),
        UDim2.new(1, -82, 0, 6),
        Enum.Font.Code,
        9,
        UI.Accent
    )
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 4)
    Bar.Position = UDim2.fromOffset(12, 51)
    Bar.BackgroundColor3 = UI.Line
    Bar.BorderSizePixel = 0
    Bar.Parent = R
    UICorner(Bar, 10)

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = UI.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    UICorner(Fill, 10)

    local Knob = Instance.new("Frame")
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Size = UDim2.fromOffset(10, 10)
    Knob.BackgroundColor3 = UI.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Bar
    UICorner(Knob, 10)

    local Hit = Instance.new("TextButton")
    Hit.Size = UDim2.new(1, 0, 1, 18)
    Hit.Position = UDim2.fromOffset(0, -9)
    Hit.BackgroundTransparency = 1
    Hit.Text = ""
    Hit.Parent = Bar

    local Dragging = false

    local function SetFromX(X)
        local A = math.clamp(
            (X - Bar.AbsolutePosition.X) /
            math.max(Bar.AbsoluteSize.X, 1),
            0,
            1
        )

        Value = Min + (Max - Min) * A
        Value = math.floor(Value * 10 + 0.5) / 10

        Fill.Size = UDim2.new(A, 0, 1, 0)
        Knob.Position = UDim2.new(A, 0, 0.5, 0)
        ValueLabel.Text = tostring(Value) .. (Suffix or "")

        if Callback then
            Callback(Value)
        end
    end

    Hit.MouseButton1Down:Connect(function()
        Dragging = true
        SetFromX(UIS:GetMouseLocation().X)
    end)

    UIS.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            SetFromX(Input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    task.defer(function()
        local A = (Initial - Min) / (Max - Min)
        Fill.Size = UDim2.new(A, 0, 1, 0)
        Knob.Position = UDim2.new(A, 0, 0.5, 0)
    end)

    return R
end

local OpenDropdown = nil

local function Dropdown(Parent, Name, Desc, Options, Initial, Callback)
    local Selected = Initial
    local R = Row(Parent, Name, Desc, 52)
    R.ClipsDescendants = false

    local Box = Instance.new("TextButton")
    Box.Size = UDim2.fromOffset(140, 30)
    Box.Position = UDim2.new(1, -152, 0.5, -15)
    Box.BackgroundColor3 = UI.Surface2
    Box.BorderSizePixel = 0
    Box.Text = "  " .. tostring(Selected) .. "     ▾"
    Box.TextColor3 = UI.Text
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 9
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.AutoButtonColor = false
    Box.Parent = R
    UICorner(Box, 6)
    UIStroke(Box, UI.Line, 0.35)

    local Menu = Instance.new("Frame")
    Menu.Size = UDim2.fromOffset(140, #Options * 29 + 6)
    Menu.BackgroundColor3 = UI.Surface2
    Menu.BorderSizePixel = 0
    Menu.Visible = false
    Menu.ZIndex = 50
    Menu.Parent = ScreenGui
    UICorner(Menu, 6)
    UIStroke(Menu, UI.Line, 0.15)

    local ML = Instance.new("UIListLayout")
    ML.Padding = UDim.new(0, 2)
    ML.Parent = Menu

    local MP = Instance.new("UIPadding")
    MP.PaddingTop = UDim.new(0, 3)
    MP.PaddingBottom = UDim.new(0, 3)
    MP.PaddingLeft = UDim.new(0, 3)
    MP.PaddingRight = UDim.new(0, 3)
    MP.Parent = Menu

    local function Close()
        Menu.Visible = false
        if OpenDropdown == Close then
            OpenDropdown = nil
        end
    end

    local function PositionMenu()
        local H = Menu.AbsoluteSize.Y
        local Y = Box.AbsolutePosition.Y + Box.AbsoluteSize.Y + 4

        if workspace.CurrentCamera and Y + H > workspace.CurrentCamera.ViewportSize.Y - 10 then
            Y = Box.AbsolutePosition.Y - H - 4
        end

        Menu.Position = UDim2.fromOffset(Box.AbsolutePosition.X, Y)
    end

    Box.MouseButton1Click:Connect(function()
        if Menu.Visible then
            Close()
            return
        end

        if OpenDropdown then
            OpenDropdown()
        end

        PositionMenu()
        Menu.Visible = true
        OpenDropdown = Close
    end)

    for _, Option in ipairs(Options) do
        local O = Instance.new("TextButton")
        O.Size = UDim2.new(1, 0, 0, 27)
        O.BackgroundColor3 = UI.Surface2
        O.BorderSizePixel = 0
        O.Text = "  " .. tostring(Option)
        O.TextColor3 = UI.Muted
        O.Font = Enum.Font.Gotham
        O.TextSize = 9
        O.TextXAlignment = Enum.TextXAlignment.Left
        O.ZIndex = 51
        O.Parent = Menu
        UICorner(O, 5)

        O.MouseEnter:Connect(function()
            Tween(O, {
                BackgroundColor3 = Color3.fromRGB(42, 28, 48),
                TextColor3 = UI.Text
            })
        end)

        O.MouseLeave:Connect(function()
            Tween(O, {
                BackgroundColor3 = UI.Surface2,
                TextColor3 = UI.Muted
            })
        end)

        O.MouseButton1Click:Connect(function()
            Selected = Option
            Box.Text = "  " .. tostring(Option) .. "     ▾"
            Close()

            if Callback then
                Callback(Option)
            end
        end)
    end

    return R
end

--==============================================================
-- PAGES
--==============================================================

local Combat = NewPage("Combat")
local Curve = NewPage("Curve")
local Spam = NewPage("Spam")
local Visuals = NewPage("Visuals")
local Settings = NewPage("Settings")

-- COMBAT
Section(Combat, "PARRY ENGINE")

Toggle(
    Combat,
    "Auto Parry",
    "Main automatic defense engine.",
    Config.AutoParry,
    function(V)
        Config.AutoParry = V
    end
)

Dropdown(
    Combat,
    "Profile",
    "Quick engine preset.",
    {"Legit", "Balanced", "Fast", "Aggressive", "Custom"},
    Config.ActiveProfile,
    function(V)
        ApplyProfile(V)
    end
)

Toggle(
    Combat,
    "Intercept Engine",
    "Predict closest trajectory crossing.",
    Config.InterceptEngine,
    function(V)
        Config.InterceptEngine = V
    end
)

Toggle(
    Combat,
    "Smart Parry V2",
    "Use confidence + ETA + trajectory.",
    Config.SmartParryV2,
    function(V)
        Config.SmartParryV2 = V
    end
)

Slider(
    Combat,
    "Parry Confidence",
    "Minimum predictive confidence.",
    20,
    95,
    Config.MinParryConfidence,
    "%",
    function(V)
        Config.MinParryConfidence = V
        Config.ActiveProfile = "Custom"
    end
)

Slider(
    Combat,
    "Extra Range",
    "Additional automatic range.",
    -10,
    30,
    Config.ExtraRange,
    "",
    function(V)
        Config.ExtraRange = V
    end
)

Section(Combat, "SAFETY")

Toggle(
    Combat,
    "Parry State Machine",
    "READY / PARRY SENT / BALL LEFT.",
    Config.ParryStateMachine,
    function(V)
        Config.ParryStateMachine = V
    end
)

Toggle(
    Combat,
    "Double Parry Guard",
    "Prevents duplicate defense input.",
    Config.DoubleParryGuardV2,
    function(V)
        Config.DoubleParryGuardV2 = V
    end
)

Toggle(
    Combat,
    "Dynamic Range",
    "Range changes with ball speed.",
    Config.DynamicRange,
    function(V)
        Config.DynamicRange = V
    end
)

Toggle(
    Combat,
    "Close Range Mode",
    "Small adjustment for close rallies.",
    Config.CloseRangeMode,
    function(V)
        Config.CloseRangeMode = V
    end
)

Toggle(
    Combat,
    "Adaptive Timing",
    "Automatically tune prediction lead.",
    Config.AdaptiveTiming,
    function(V)
        Config.AdaptiveTiming = V
    end
)

-- CURVE
Section(Curve, "AUTO CURVE")

Toggle(
    Curve,
    "Auto Curve",
    "Apply selected curve during parry.",
    Config.AutoCurve,
    function(V)
        Config.AutoCurve = V
    end
)

Dropdown(
    Curve,
    "Curve Preset",
    "Direction preset.",
    {"Custom", "Back", "Left", "Right", "Random"},
    Config.AutoCurveMode,
    function(V)
        Config.AutoCurveMode = V
    end
)

Dropdown(
    Curve,
    "Curve Every",
    "Parries before the next curve.",
    {"Auto", "1", "2", "3", "4", "5", "6"},
    Config.CurveEveryMode,
    function(V)
        Config.CurveEveryMode = V
        Runtime.CurveParryCounter = 0

        if V == "Auto" then
            Config.CurveAutoNext = math.random(
                Config.CurveAutoMin,
                Config.CurveAutoMax
            )
        end
    end
)

Dropdown(
    Curve,
    "Curve Direction",
    "Smart or fixed direction.",
    {"Smart", "Back", "Left", "Right", "Random"},
    Config.SmartCurveDirection,
    function(V)
        Config.SmartCurveDirection = V

        if V == "Back" then
            Config.AutoCurveMode = "Back"
        elseif V == "Left" then
            Config.AutoCurveMode = "Left"
        elseif V == "Right" then
            Config.AutoCurveMode = "Right"
        elseif V == "Random" then
            Config.AutoCurveMode = "Random"
        else
            Config.AutoCurveMode = "Custom"
        end
    end
)

Slider(
    Curve,
    "Curve Angle",
    "Strength of custom/back curve.",
    90,
    179,
    Config.BackCurveAngle,
    "°",
    function(V)
        Config.BackCurveAngle = V
    end
)

Toggle(
    Curve,
    "Curve Detection V2",
    "Use trajectory history to detect curve.",
    Config.CurveDetectionV2,
    function(V)
        Config.CurveDetectionV2 = V
    end
)

-- SPAM
Section(Spam, "MANUAL SPAM")

Toggle(
    Spam,
    "Manual Spam",
    "Enable manual spam engine.",
    Config.SpamActive,
    function(V)
        Config.SpamActive = V
    end
)

Toggle(
    Spam,
    "Turbo Spam",
    "Run spam across multiple phases.",
    Config.SpamTurbo,
    function(V)
        Config.SpamTurbo = V
    end
)

Slider(
    Spam,
    "Spam Burst / Phase",
    "Fast taps sent per engine phase.",
    1,
    20,
    Config.SpamBurstPerFrame,
    "",
    function(V)
        Config.SpamBurstPerFrame = math.floor(V)
    end
)

Dropdown(
    Spam,
    "Activation Mode",
    "Toggle or hold hotkey.",
    {"Toggle", "Hold"},
    Config.ManualSpamHold and "Hold" or "Toggle",
    function(V)
        Config.ManualSpamHold = V == "Hold"
    end
)

Section(Spam, "AUTO SPAM")

Toggle(
    Spam,
    "Auto Spam",
    "Automatically spam inside range.",
    Config.AutoSpam,
    function(V)
        Config.AutoSpam = V
    end
)

Slider(
    Spam,
    "Spam Distance",
    "Distance where Auto Spam starts.",
    6,
    35,
    Config.SpamDistance,
    " st",
    function(V)
        Config.SpamDistance = V
    end
)

Dropdown(
    Spam,
    "Spam Input",
    "Input key sent by spam engine.",
    {"F", "E", "Q", "R"},
    Config.SpamInputKey.Name,
    function(V)
        local K = Enum.KeyCode[V]
        if K then
            Config.SpamInputKey = K
        end
    end
)

-- VISUALS
Section(Visuals, "ENGINE MONITOR")

local Monitor =
    Instance.new(
        "Frame"
    )

Monitor.Size =
    UDim2.new(
        1,
        0,
        0,
        210
    )

Monitor.BackgroundColor3 =
    UI.Surface

Monitor.BorderSizePixel =
    0

Monitor.Parent =
    Visuals

UICorner(Monitor, 7)

local MonitorText =
    Label(
        Monitor,
        "WAITING FOR BALL",
        UDim2.new(1, -24, 1, -24),
        UDim2.fromOffset(12, 12),
        Enum.Font.Code,
        10,
        UI.Text
    )

MonitorText.TextYAlignment =
    Enum.TextYAlignment.Top

MonitorText.TextWrapped =
    false

Toggle(
    Visuals,
    "Range Visualizer",
    "Show automatic parry range.",
    Config.RangeVisualizer,
    function(V)
        Config.RangeVisualizer = V
    end
)

Toggle(
    Visuals,
    "Debug Overlay",
    "Update live engine information.",
    Config.DebugOverlay,
    function(V)
        Config.DebugOverlay = V
    end
)

-- SETTINGS
Section(Settings, "INTERFACE")

Toggle(
    Settings,
    "Performance Mode",
    "Reduce visual update workload.",
    Config.PerformanceMode,
    function(V)
        Config.PerformanceMode = V
        Config.DebugUpdateInterval = V and 0.20 or 0.08
    end
)

Dropdown(
    Settings,
    "Parry Type",
    "Input method used by parry engine.",
    {"Mouse", "Key", "Remote"},
    Config.ParryType,
    function(V)
        Config.ParryType = V
    end
)

Toggle(
    Settings,
    "Ping Compensation",
    "Use live ping in timing.",
    Config.PingCompensation,
    function(V)
        Config.PingCompensation = V
    end
)

Toggle(
    Settings,
    "Slow Ball Fix",
    "Extra protection for slow balls.",
    Config.SlowBallFix,
    function(V)
        Config.SlowBallFix = V
    end
)

Toggle(
    Settings,
    "Critical ETA Fix",
    "Emergency fallback near impact.",
    Config.CriticalETAFix,
    function(V)
        Config.CriticalETAFix = V
    end
)

--==============================================================
-- NAVIGATION
--==============================================================

local Descriptions = {
    Combat = "Smart parry controls",
    Curve = "Curve timing and direction",
    Spam = "Manual and automatic spam",
    Visuals = "Live engine information",
    Settings = "Engine and interface options",
}

local function SetTab(Name)
    CurrentTab = Name

    for PageName, Page in pairs(Pages) do
        Page.Visible = PageName == Name
    end

    for ButtonName, Button in pairs(NavButtons) do
        local Selected = ButtonName == Name

        Tween(
            Button,
            {
                BackgroundColor3 = Selected
                    and Color3.fromRGB(45, 23, 56)
                    or UI.Side,
                TextColor3 = Selected
                    and UI.Text
                    or UI.Muted,
            }
        )

        local Active = Button:FindFirstChild("Active")

        if Active then
            Tween(
                Active,
                {
                    Size = Selected
                        and UDim2.fromOffset(3, 20)
                        or UDim2.fromOffset(3, 0)
                }
            )
        end
    end

    HeaderTitle.Text = Name
    HeaderSub.Text = Descriptions[Name] or ""
end

local CombatNav = NewNav("Combat", "◈")
local CurveNav = NewNav("Curve", "↶")
local SpamNav = NewNav("Spam", "ϟ")
local VisualsNav = NewNav("Visuals", "◉")
local SettingsNav = NewNav("Settings", "⚙")

CombatNav.MouseButton1Click:Connect(function()
    SetTab("Combat")
end)

CurveNav.MouseButton1Click:Connect(function()
    SetTab("Curve")
end)

SpamNav.MouseButton1Click:Connect(function()
    SetTab("Spam")
end)

VisualsNav.MouseButton1Click:Connect(function()
    SetTab("Visuals")
end)

SettingsNav.MouseButton1Click:Connect(function()
    SetTab("Settings")
end)

--==============================================================
-- DRAG
--==============================================================

local Dragging = false
local DragStart
local StartPos

Header.Active = true
Sidebar.Active = true

local function BeginDrag(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPos = Main.Position
    end
end

Header.InputBegan:Connect(BeginDrag)
Sidebar.InputBegan:Connect(BeginDrag)

UIS.InputChanged:Connect(function(Input)
    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

--==============================================================
-- HIDE / MINIMIZE / CLOSE
--==============================================================

local Visible = true
local Minimized = false
local FullSize = UDim2.fromOffset(780, 510)

local function ToggleVisible()
    Visible = not Visible
    Main.Visible = Visible
end

MinButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    if Minimized then
        Tween(Main, {Size = UDim2.fromOffset(780, 58)})
        task.delay(0.12, function()
            Sidebar.Visible = false
            PageArea.Visible = false
        end)
    else
        Sidebar.Visible = true
        PageArea.Visible = true
        Tween(Main, {Size = FullSize})
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    CleanupZenxBladeBall()
end)

UIS.InputBegan:Connect(function(Input, Processed)
    if Processed then
        return
    end

    if
        Input.KeyCode == Enum.KeyCode.Insert
        or
        Input.KeyCode == Enum.KeyCode.RightShift
    then
        ToggleVisible()
    end
end)

--==============================================================
-- LIVE MONITOR
--==============================================================

Connect(
    RunService.Heartbeat,
    function()

        if not Runtime.Alive then
            return
        end

        StatusValue.Text =
            Runtime.Status
            or
            "READY"

        if
            string.find(
                StatusValue.Text,
                "ERROR",
                1,
                true
            )
        then
            StatusValue.TextColor3 = UI.Danger
        else
            StatusValue.TextColor3 = UI.Green
        end

        if
            not Config.DebugOverlay
            or
            not MonitorText
            or
            not MonitorText.Parent
        then
            return
        end

        local ETA =
            Runtime.PredictedETA

        local ETAText =
            ETA < math.huge
            and string.format("%.3fs", ETA)
            or "--"

        local Miss =
            Runtime.PredictedMissDistance

        local MissText =
            Miss < math.huge
            and string.format("%.1f", Miss)
            or "--"

        MonitorText.Text =
            string.format(
                "BALL SPEED        %.1f\nDISTANCE          %.1f\nETA               %s\nMISS DISTANCE     %s\nCONFIDENCE        %.0f%%\nPING              %.0fms\nCURVE DELTA       %.3f\nADAPTIVE LEAD     %.3f\nPARRY STATE       %s\nSTATUS            %s",
                Runtime.Speed or 0,
                Runtime.Distance or 0,
                ETAText,
                MissText,
                Runtime.ParryConfidence or 0,
                Runtime.Ping or 0,
                Runtime.CurveDeltaV2 or 0,
                Runtime.AdaptiveTimingLead or 0,
                Runtime.ParryState or "READY",
                Runtime.Status or "READY"
            )
    end
)

--==============================================================
-- START
--==============================================================

ApplyProfile(
    Config.ActiveProfile
)

SetTab(
    "Combat"
)

Main.Size =
    UDim2.fromOffset(
        750,
        485
    )

Main.BackgroundTransparency =
    0.12

Tween(
    Main,
    {
        Size = FullSize,
        BackgroundTransparency = 0
    },
    0.24
)

print("[ZENX] BOOT 3/3 - clean UI loaded")
print("[ZENX] Blade Ball V13 Clean UI loaded.")
