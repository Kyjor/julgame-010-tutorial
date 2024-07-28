function Orbit(center::Vector2f, radius::Float64, angle::Float64) :: Vector2f
    x = center.x + radius * cos(angle)
    y = center.y + radius * sin(angle)
    return Vector2f(x, y)
end

function EaseOutElastic(x::Float64) :: Float64
    c4 = (2 * π) / 3
    
    return x == 0 ? 0 : x == 1 ? 1 : 2 ^ (-10 * x) * sin((x * 10 - 0.75) * c4) + 1
end

