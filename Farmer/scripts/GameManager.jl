using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.RigidbodyModule
using JulGame.SoundSourceModule
using JulGame.TransformModule

mutable struct GameManager
    cameraTarget
    roomBounds::Tuple
    isAdjusted::Bool
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

        this.isAdjusted = false
        this.roomBounds = (-2, 6, -7, 7) # up down left right
        # Usage example
        this.totalCols = 5
        this.totalRows = 5

        total_rooms = 9
        (this.rooms, this.startRow, this.startCol) = generate_rooms(this.totalRows, this.totalCols, total_rooms)
        # println(this.rooms)
        # println(this.startRow, " ", this.startCol)
        # println(this.rooms[this.startRow, this.startCol])
        # println(length(this.rooms))
        # println("updating rooms")
        update_random_room(this.rooms, 2, this.startRow, this.startCol)
        update_random_room(this.rooms, 3, this.startRow, this.startCol)
        update_rooms_based_on_number(this.rooms, this.startRow, this.startCol)
        
        println(this.rooms)
        this.currentCol = this.startCol
        this.currentRow = this.startRow

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            this.player = MAIN.scene.getEntityByName("Player")
            this.cameraTarget = this.player.scripts[1].cameraTarget
            update_entered_room(this, 0, 0)
        end
    elseif s == :update
        function(deltaTime)
            
            checkToMoveCamera(this)
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

function checkToMoveCamera(this::GameManager)
    offsetX = 0
    offsetY = 0

    if this.cameraTarget.position.y > this.roomBounds[1] && this.player.transform.position.y < this.roomBounds[1] - 1
        println("rowToCheck")
        offsetY = -10
        rowToCheck = this.currentRow - 1
        if rowToCheck >= 1 && this.rooms[rowToCheck, this.currentCol] != 0
            println("valid room above: ", rowToCheck, " ", this.currentCol)
        end
        this.currentRow = rowToCheck
    elseif this.cameraTarget.position.y < this.roomBounds[2] && this.player.transform.position.y > this.roomBounds[2] + 1
        offsetY = 10
        rowToCheck = this.currentRow + 1
        if rowToCheck <= this.totalRows && this.rooms[rowToCheck, this.currentCol] != 0
            println("valid room below: ", rowToCheck, " ", this.currentCol)
        end
        this.currentRow = rowToCheck
    elseif this.cameraTarget.position.x > this.roomBounds[3] && this.player.transform.position.x < this.roomBounds[3] - 1
        offsetX = -15
        colToCheck = this.currentCol - 1
        if colToCheck >= 1 && this.rooms[this.currentRow, colToCheck] != 0
            println("valid room left: ", this.currentRow, " ", colToCheck)
        end
        this.currentCol = colToCheck
    elseif this.cameraTarget.position.x < this.roomBounds[4] && this.player.transform.position.x > this.roomBounds[4] + 1
        offsetX = 15
        colToCheck = this.currentCol + 1
        
        if colToCheck <= this.totalCols && this.rooms[this.currentRow, colToCheck] != 0
            println("valid room right: ", this.currentRow, " ", colToCheck)
        end
        this.currentCol = colToCheck
    end

    if (offsetX != 0 || offsetY != 0)
        update_entered_room(this, offsetX, offsetY)
    end
end

function update_entered_room(this::GameManager, offsetX, offsetY)
    this.isAdjusted = true
    openings = check_openings(this.rooms, this.currentRow, this.currentCol)
    println("openings: ", openings)
    for entity in MAIN.scene.entities
        if contains(entity.name, "Tile")
            entity.transform.position = Vector2f(entity.transform.position.x + offsetX, entity.transform.position.y + offsetY)
        end
        if openings[1] && entity.name == "TileTopClosed"
            entity.isActive = false
        elseif !openings[1] && entity.name == "TileTopClosed"
            entity.isActive = true
        elseif openings[2] && entity.name == "TileBottomClosed"
            entity.isActive = false
        elseif !openings[2] && entity.name == "TileBottomClosed"  
            entity.isActive = true
        elseif openings[3] && entity.name == "TileLeftClosed"
            entity.isActive = false
        elseif !openings[3] && entity.name == "TileLeftClosed"
            entity.isActive = true
        elseif openings[4] && entity.name == "TileRightClosed"
            entity.isActive = false
        elseif !openings[4] && entity.name == "TileRightClosed"
            entity.isActive = true
        end
    end
    this.roomBounds = (this.roomBounds[1] + offsetY, this.roomBounds[2] + offsetY, this.roomBounds[3] + offsetX, this.roomBounds[4] + offsetX)
    this.cameraTarget.position = Vector2f(this.cameraTarget.position.x + offsetX, this.cameraTarget.position.y + offsetY)
end

function generate_rooms(rows, cols, total_rooms)
    # Create a 2D array to represent the rooms
    rooms = fill(0, (rows, cols))
    
    # Randomly select a start position
    start_row = rand(1:rows)
    start_col = rand(1:cols)
    
    # Mark the start position as visited
    rooms[start_row, start_col] = 1
    
    # Define possible movement directions
    directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    
    # Custom shuffle function
    function shuffle!(arr)
        n = length(arr)
        for i in n:-1:2
            j = rand(1:i)
            arr[i], arr[j] = arr[j], arr[i]
        end
        return arr
    end
    
    # Define a recursive function to generate connected rooms
    function generate_connected_rooms(row, col, generated_rooms)
        # Randomly shuffle the directions (create a local copy)
        local_directions = copy(directions)
        shuffle!(local_directions)
        
        # Loop through each direction
        for (dx, dy) in local_directions
            new_row = row + dx
            new_col = col + dy
            
            # Check if the new position is within the array bounds
            if 1 <= new_row <= rows && 1 <= new_col <= cols
                # Check if the new position is unvisited
                if rooms[new_row, new_col] == 0
                    # Mark the new position as visited
                    rooms[new_row, new_col] = 1
                    
                    if generated_rooms == total_rooms
                        return
                    end
                    # Recursively generate connected rooms from the new position
                    generate_connected_rooms(new_row, new_col, generated_rooms + 1)
                    break
                end
            end
        end
    end
    
    # Generate connected rooms starting from the random start position
    generate_connected_rooms(start_row, start_col, 1)
    
    return (rooms, start_row, start_col)
end

function check_openings(rooms, row, col)
    rows, cols = size(rooms)
    openings = [false, false, false, false]
    
    # Check the up direction
    if row > 1 && rooms[row-1, col] != 0
        openings[1] = true
    end
    
    # Check the down direction
    if row < rows && rooms[row+1, col] != 0
        openings[2] = true
    end
    
    # Check the left direction
    if col > 1 && rooms[row, col-1] != 0
        openings[3] = true
    end
    
    # Check the right direction
    if col < cols && rooms[row, col+1] != 0
        openings[4] = true
    end
    
    return openings
end

function update_random_room(rooms, new_number, startingRow, startingCol)
    rows, cols = size(rooms)
    
    # Find all the indices where the room is 1
    indices = findall(x -> x == 1, rooms)
    # Randomly select an index
    random_index = rand(indices)
    
    while random_index[1] == startingRow && random_index[2] == startingCol
        random_index = rand(indices)
    end
   
    # Update the room at the selected index with the new number
    rooms[random_index] = new_number

    return rooms
end

# 
function update_rooms_based_on_number(rooms, startingRow, startingCol)
    println("starting row: ", startingRow)
    println("starting col: ", startingCol)

    # 2 is the room with the key. Spawn the key in this room
    rows, cols = size(rooms)
    indices = findall(x -> x == 2, rooms)
    # Rooms are offset from each other by 15 x and 10 y. Find position of the room with the key based on the index and the starting row and column. The starting row and column are (0,0) in the world space
    for index in indices
        row = index[1]
        col = index[2]
        x = (startingCol - col) * 15
        y = (startingRow - row) * 10
        println("key position: ", x, " ", y)
    end

end

function fill_rooms(this, key, exit)
    indices = findall(x -> x >= 2, this.rooms)
    for index in indices
        row = index[1]
        col = index[2]
    end
end
