using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule

mutable struct GameManager
    parent
    player

    currentCol 
    currentRow
    rooms
    startRow
    startCol
    totalCols
    totalRows

    function GameManager()
        this = new()    

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            this.player = JulGame.SceneModule.get_entity_by_name(MAIN.scene, "Player")
            MAIN.scene.camera.target = this.player.transform
            MAIN.cameraBackgroundColor = (155, 212, 195)
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