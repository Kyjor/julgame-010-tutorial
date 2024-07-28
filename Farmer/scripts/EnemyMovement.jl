using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule
include("Utils.jl")

mutable struct EnemyMovement
    attackTargetPosition
    attackTimer
    currentState
    enemy
    lungeSpeed
    moveSpeed
    originalPosition
    parent 
    player
    states
    stunLimit
    stunTimer

    function EnemyMovement()
        this = new()

        this.attackTimer = 0
        this.stunLimit = .5
        this.stunTimer = 0
        this.lungeSpeed = 5
        this.moveSpeed = 2 
        this.states = Dict(:idle => 0, :moveTowardsPlayer => 1, :attack => 2, :stunned => 3)
        this.currentState = this.states[:idle]

        return this
    end
end

function Base.getproperty(this::EnemyMovement, s::Symbol)
    if s == :initialize
        function()
            this.enemy = this.parent.scripts[1]
            this.player = MAIN.scene.getEntityByName("Player")
        end
    elseif s == :update
        function(deltaTime)
            # move towards player
            this.moveTowardsPlayer(deltaTime)
        end
    elseif s == :moveTowardsPlayer
        function(deltaTime)
            if this.enemy.knockBackTimeElapsed < this.enemy.knockBackTime 
                return
            end

            if this.currentState == this.states[:stunned]
                this.stunTimer += deltaTime
                if this.stunTimer >= this.stunLimit
                    this.currentState = this.states[:idle]
                    this.stunTimer = 0
                end
            elseif this.currentState == this.states[:idle]
                if Math.distance(this.parent.transform.position, this.player.transform.position) < 5
                    this.currentState = this.states[:moveTowardsPlayer]
                end
            elseif this.currentState == this.states[:moveTowardsPlayer]
                distanceToPlayer = Math.distance(this.parent.transform.position, this.player.transform.position)
                if distanceToPlayer > 5
                    this.currentState = this.states[:idle]
                elseif distanceToPlayer > 2
                    direction = Vector2f(this.player.transform.position.x - this.parent.transform.position.x, this.player.transform.position.y - this.parent.transform.position.y)
                    direction = Math.normalize(direction)
                    this.parent.transform.position += Vector2f(direction.x * this.moveSpeed * deltaTime, direction.y * this.moveSpeed * deltaTime)
                elseif distanceToPlayer <= 2
                    this.currentState = this.states[:attack]
                    this.attackTimer = 0
                    this.originalPosition = this.parent.transform.position
                    this.attackTargetPosition = this.player.transform.position
                end
            elseif this.currentState == this.states[:attack]
                if this.attackTimer < 1 && Math.distance(this.parent.transform.position, this.attackTargetPosition) > 0.1
                    # Lunge towards the player
                    direction = Vector2f(this.attackTargetPosition.x - this.parent.transform.position.x, this.attackTargetPosition.y - this.parent.transform.position.y)
                    direction = Math.normalize(direction)
                    this.parent.transform.position += Vector2f(direction.x * this.lungeSpeed * deltaTime, direction.y * this.lungeSpeed * deltaTime)
                elseif Math.distance(this.parent.transform.position, this.originalPosition) > 0.1 && this.attackTimer >= 1
                    # Move back to original position
                    direction = Vector2f(this.originalPosition.x - this.parent.transform.position.x, this.originalPosition.y - this.parent.transform.position.y)
                    direction = Math.normalize(direction)
                    this.parent.transform.position += Vector2f(direction.x * this.lungeSpeed * deltaTime, direction.y * this.lungeSpeed * deltaTime)
                end
                
                this.attackTimer += deltaTime
                if this.attackTimer >= 2
                    this.currentState = this.states[:idle]
                end
            end
          
        end
   elseif s == :setParent
        function(parent)
            this.parent = parent
        end
    else
        getfield(this, s)
    end
end