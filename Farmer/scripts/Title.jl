using JulGame 
using JulGame.MainLoop
using JulGame.UI.TextBoxModule

mutable struct Title
    fade
    parent
    steam
    textBox

    function Title()
        this = new()

        this.fade = true
        this.parent = C_NULL
        this.steam = C_NULL 
        if length(MAIN.globals) != 0
            this.steam = MAIN.globals[1]
        end
        this.textBox = C_NULL

        return this
    end
end

function Base.getproperty(this::Title, s::Symbol)
    if s == :initialize
        function()
            this.textBox = MAIN.scene.uiElements[1]
            if this.steam != C_NULL
                this.textBox.text = "Welcome, " * this.steam.name * "!"
            else
                this.textBox.text = "Welcome!"
            end
        end
    elseif s == :update
        function(deltaTime)
            if this.fade 
                this.textBox.alpha -= 1
                JulGame.UI.update_text(this.textBox, this.textBox.text)
                if this.textBox.alpha <= 25
                    this.fade = false
                end
            else
                this.textBox.alpha += 1
                JulGame.UI.update_text(this.textBox, this.textBox.text)
                if this.textBox.alpha >= 250
                    this.fade = true
                end
            end

            if InputModule.get_button_pressed(MAIN.input, "RETURN")
                MainLoop.change_scene("game_scene.json")
            end

        end
    elseif s == :setParent 
        function(parent)
            this.parent = parent
        end
    elseif s == :onShutDown
        function ()
        end
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end