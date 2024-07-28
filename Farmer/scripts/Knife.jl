using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule
include("Utils.jl")

mutable struct Knife
    knifeOffset::Vector2f
    orbitPos::Union{Vector2f, Nothing}
    parent
    player
    soundManager
    swordSwingTime::Float64
    swordSwingTimeElapsed::Float64
    swingDirection::Int

    function Knife()
        this = new()

        this.swordSwingTime = 0.15
        this.swordSwingTimeElapsed = this.swordSwingTime

        return this
    end
end

function Base.getproperty(this::Knife, s::Symbol)
    if s == :initialize
        function()
            this.player = MAIN.scene.getEntityByName("Player")
            this.knifeOffset = Vector2f(this.parent.transform.position.x - this.player.transform.position.x, this.parent.transform.position.y - this.player.transform.position.y)
            this.parent.sprite.rotation = 30
            this.soundManager = MAIN.scene.getEntityByName("Sound Manager").scripts[1]
        end
    elseif s == :update
        function(deltaTime)

            if this.swordSwingTimeElapsed < this.swordSwingTime
                this.handleSwing(deltaTime)
            end

            this.parent.transform.position = this.orbitPos === nothing ? Vector2f(this.player.transform.position.x + this.knifeOffset.x, this.player.transform.position.y + this.knifeOffset.y) : Vector2f(this.orbitPos.x, this.orbitPos.y)
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @argevent (col) this.handleCollisions(col)
            this.parent.collider.addCollisionEvent(collisionEvent)
        end
    elseif s == :handleCollisions
        function(otherCollider)
            if (otherCollider.tag == "Enemy" || otherCollider.tag == "Dummy") && this.swordSwingTimeElapsed < this.swordSwingTime
                positionForKnockback = otherCollider.tag == "Enemy" ? this.player.transform.position : nothing
                otherCollider.parent.scripts[1].takeDamage(positionForKnockback)
                this.soundManager.meleeHitKnifeSound_0.toggleSound()
            end
        end
    elseif s == :handleSwing
        function(deltaTime)
            this.swordSwingTimeElapsed += deltaTime
            starting = this.swingDirection == 1 ? -1.0 : 2.0
            ending = this.swingDirection == 1 ? 1.0 : 4.0
            swingPos = SmoothLerp(starting, ending, this.swordSwingTimeElapsed / this.swordSwingTime)
            this.orbitPos = Orbit(Vector2f(this.player.transform.position.x, this.player.transform.position.y), 1.0, this.swingDirection == 1 ? swingPos : -swingPos)
        end
    elseif s == :flip
        function()
            this.parent.sprite.flip()
            this.parent.sprite.rotation = -this.parent.sprite.rotation
            this.knifeOffset = Vector2f(-this.knifeOffset.x, this.knifeOffset.y)
        end
    else
        getfield(this, s)
    end
end