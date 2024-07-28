using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule
include("Utils.jl")

mutable struct Enemy
    health::Int
    isKnockedBack::Bool
    knockBackCurrent::Vector2f
    knockBackStart::Vector2f
    knockBackEnd::Vector2f
    knockBackTime::Float64
    knockBackTimeElapsed::Float64
    movementScript
    parent 

    function Enemy()
        this = new()

        this.health = 3
        this.knockBackTime = 0.25
        this.knockBackTimeElapsed = this.knockBackTime
        # precompile(Base.getproperty, (Enemy, Symbol))
        # precompile(EaseOutElastic, (Float64,))
        return this
    end
end

function Base.getproperty(this::Enemy, s::Symbol)
    if s == :initialize
        function()

            if length(this.parent.scripts) > 1
                this.movementScript = this.parent.scripts[2]
            end
        end
    elseif s == :update
        function(deltaTime)
            if this.knockBackTimeElapsed < this.knockBackTime
                this.knockBackCurrent = Vector2f(clamp(this.knockBackCurrent.x + deltaTime, 0, 1), clamp(this.knockBackCurrent.y + deltaTime, 0, 1))
                posX = EaseOutElastic(this.knockBackCurrent.x)
                posY = EaseOutElastic(this.knockBackCurrent.y)
                this.parent.transform.position = Vector2f(Math.overflow_lerp(this.knockBackStart.x, this.knockBackEnd.x, posX), Math.overflow_lerp(this.knockBackStart.y, this.knockBackEnd.y, posY))

                this.knockBackTimeElapsed += deltaTime
                if this.knockBackCurrent.x >= 1 && this.knockBackCurrent.y >= 1
                    this.knockBackTimeElapsed = this.knockBackTime
                end
                return
            end

        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
        end
    elseif s == :handleCollisions
        function(otherCollider)
        end
    elseif s == :takeDamage
        function(hitPosition = nothing)
            if this.knockBackTimeElapsed < this.knockBackTime || hitPosition === nothing
                return
            end
            
            this.health -= 1
            if this.health <= 0
                DestroyEntity(this.parent)
            end
            this.movementScript.currentState = this.movementScript.states[:stunned]
            this.knockBackTimeElapsed = 0
            this.knockBackStart = this.parent.transform.position
            this.knockBackCurrent = Vector2f(0, 0)
            direction = normalize(this.parent.transform.position - hitPosition)
            # knockbackDistance = pos * direction
            # println("Knockback")
            # println("hit pos: ", hitPosition)
            # println("parent pos: ", this.parent.transform.position)
            # println("dir: ", direction)
            # println("dist ", knockbackDistance)

            this.knockBackEnd = this.knockBackStart + direction
            # println("startx + dirx: ", this.knockBackStart.x + direction.x)
            # println("starty + diry: ", this.knockBackStart.y + direction.y)
            # println("end: ", this.knockBackEnd)
        end
    else
        getfield(this, s)
    end
end