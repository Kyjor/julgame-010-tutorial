using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule

mutable struct SoundManager
    parent
    player

    meleeHitKnifeSound_0
    meleeSwingSound_0
    meleeSwingSound_1
    meleeSwingSound_2
    
    stepSound_0
    stepSound_1

    elapsedTime

    function SoundManager()
        this = new()    

        this.elapsedTime = 0

        return this
    end
end

function Base.getproperty(this::SoundManager, s::Symbol)
    if s == :initialize
        function()
            this.player = MAIN.scene.getEntityByName("Player")
            #this.parent.soundSource.toggleSound()
            
            this.meleeHitKnifeSound_0 = this.parent.createSoundSource(SoundSource(Int32(2), false, "sfx/melee/melee_hit_knife_000.flac", Int32(10)))
            this.meleeSwingSound_0 = this.parent.createSoundSource(SoundSource(Int32(2), false, "sfx/melee/melee_swing_000.wav", Int32(10)))
            this.meleeSwingSound_1 = this.parent.createSoundSource(SoundSource(Int32(2), false, "sfx/melee/melee_swing_001.wav", Int32(10)))
            this.meleeSwingSound_2 = this.parent.createSoundSource(SoundSource(Int32(2), false, "sfx/melee/melee_swing_002.wav", Int32(10)))
            
            this.stepSound_0 = this.parent.createSoundSource(SoundSource(Int32(1), false, "sfx/steps/footstep_carpet_000.ogg", Int32(10)))
            this.stepSound_1 = this.parent.createSoundSource(SoundSource(Int32(1), false, "sfx/steps/footstep_carpet_001.ogg", Int32(10)))
        end
    elseif s == :update
        function(deltaTime)

            
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
        end
    elseif s == :handleCollisions
        function()
        end
    else
        getfield(this, s)
    end
end