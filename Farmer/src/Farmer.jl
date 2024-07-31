module Farmer 
    using JulGame
    using JulGame.Math
    using JulGame.SceneBuilderModule

    function run()
        globals = []
        JulGame.MAIN = JulGame.Main(Float64(1.0))
        JulGame.PIXELS_PER_UNIT = 16
        scene = Scene("title_scene.json")
        return scene.init("Farmer", false, Vector2(960, 640),Vector2(960, 640), true, 1.0, true, 60, globals)
        return main
    end

    julia_main() = run()
end
# Uncommented to allow for direct execution of this file. If you want to build this project with PackageCompiler, comment the line below
Farmer.run()