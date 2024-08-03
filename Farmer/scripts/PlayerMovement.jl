using JulGame.Component
using JulGame.InputModule
using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule
include("Utils.jl")

mutable struct PlayerMovement
    animator
    cameraTarget
    canMove::Bool
    currentDirectionFacing
    elapsedTime
    directions
    isFacingRight::Bool
    isMoving::Bool
    parent
    startingY

    left::Bool
    soundManager
    stepTime

    xDir
    yDir

    function PlayerMovement()
        this = new()

        this.canMove = false
        this.elapsedTime = 0.0
        this.isFacingRight = true
        this.directions = ["down", "up", "left", "right"]
        this.currentDirectionFacing = 1
        this.xDir = 0
        this.yDir = 0

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()
            this.cameraTarget = Transform(Vector2f(0, 1.5))
            MAIN.scene.camera.target = this.cameraTarget
            this.startingY = this.parent.sprite.offset.y
            this.soundManager = JulGame.SceneModule.get_entity_by_name(MAIN.scene, "Sound Manager").scripts[1]

            this.left = true
            this.stepTime = 0.0
            this.isMoving = false
            this.animator = this.parent.animator
        end
    elseif s == :update
        function(deltaTime)
            this.isMoving = false
            this.canMove = true
            x = 0
            speed = 4
            input = MAIN.input

            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            if !this.isMoving && this.animator.currentAnimation != this.animator.animations[this.currentDirectionFacing]
                this.animator.currentAnimation = this.animator.animations[this.currentDirectionFacing]
            end
            if (InputModule.get_button_held_down(input, "A") || input.xDir == -1) && this.canMove
                if this.currentDirectionFacing != 3
                    this.currentDirectionFacing = 3
                end
                if this.animator.currentAnimation != this.animator.animations[3]
                    this.animator.currentAnimation = this.animator.animations[3]
                end

                this.isMoving = true
                x = -speed
                this.parent.transform.position = Vector2f(this.parent.transform.position.x + x * deltaTime, this.parent.transform.position.y)
                this.bob()
            elseif (InputModule.get_button_held_down(input, "D")  || input.xDir == 1) && this.canMove
                if InputModule.get_button_pressed(input, "D") && this.currentDirectionFacing != 4
                    this.currentDirectionFacing = 4
                    this.animator.currentAnimation = this.animator.animations[4]
                end

                this.isMoving = true
                x = speed
                this.parent.transform.position = Vector2f(this.parent.transform.position.x + x * deltaTime, this.parent.transform.position.y)
                this.bob()
            elseif (InputModule.get_button_held_down(input, "W") || input.yDir == -1) && this.canMove
                if this.currentDirectionFacing != 2
                    this.currentDirectionFacing = 2
                    this.animator.currentAnimation = this.animator.animations[2]
                end

                this.isMoving = true
                y = -speed
               
                this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.parent.transform.position.y + y * deltaTime)
                this.bob()

            elseif (InputModule.get_button_held_down(input, "S")  || input.yDir == 1) && this.canMove
                if this.currentDirectionFacing != 1
                    this.currentDirectionFacing = 1
                    this.animator.currentAnimation = this.animator.animations[1]
                end
                this.isMoving = true
                y = speed
               
                this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.parent.transform.position.y + y * deltaTime)
                this.bob()
            end

            if this.isMoving
                if this.left && this.stepTime > .2
                    Component.toggle_sound(this.soundManager.stepSound_0)
                    this.left = false
                    this.stepTime = 0.0
                elseif this.stepTime > .2
                    Component.toggle_sound(this.soundManager.stepSound_1)
                    this.left = true
                    this.stepTime = 0.0
                end
                this.stepTime += deltaTime
            end

            this.elapsedTime += deltaTime
            x = 0

            this.elapsedTime += deltaTime
        end
    elseif s == :bob
        function()
            # Define bobbing parameters
            bobHeight = -0.15  # The maximum height the item will bob
            bobSpeed = 20.0   # The speed at which the item bobs up and down
            minBobHeight = -0.10

            # Calculate a sine wave for bobbing motion
            bobOffset = minBobHeight + bobHeight * (1.0 - cos(bobSpeed * this.elapsedTime)) / 2.0
        
            # Update the item's Y-coordinate
            this.parent.sprite.offset = Vector2f(this.parent.sprite.offset.x, this.startingY + bobOffset)
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