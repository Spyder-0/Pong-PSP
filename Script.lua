---------------------------------------------------

-- Controls:
-- D-Pad Up/Down to control the left paddle
-- Triangle and Cross to control the right paddle
-- START to reset the game when a player wins

---------------------------------------------------

-- Colours
clear_col = Color.create(30, 30, 46, 1)
green_v = Color.create(92, 244, 78, 1)
purple_v = Color.create(154, 80, 244, 1)
white = Color.create(255, 255, 255, 255)
green = Color.create(166, 227, 161, 255)
purple = Color.create(203, 166, 247, 255)
yellow = Color.create(250, 179, 135, 255)

-- Background Colour
Graphics.set_clear_color(clear_col)

-- Variables
lLives = 5
rLives = 5
paddleL = 136
paddleR = 136
ballX = 240
ballY = 136

-- Ball Variables
math.randomseed(os.time())
ballVX = (math.random(0, 1) - 0.5) * 300
ballVY = math.random(-10, 10) * 30

-- Transform Variables
paddleTransformL = Transform.create()
paddleTransformR = Transform.create()
ball = Transform.create()
ballCheck = Transform.create()

-- Scale Variables
paddleTransformL:set_scale(8, 64)
paddleTransformR:set_scale(8, 64)
ball:set_scale(8, 8)
ballCheck:set_scale(8, 8)


-- Reset each time Ball enters a goal
function reset_partial()
    ballX = 240
    ballY = 136

    ballVX = (math.random(0, 1) - 0.5) * 300
    ballVY = math.random(-10, 10) * 30

    paddleL = 136
    paddleR = 136

    paddleTransformL:set_position(24, paddleL)
    paddleTransformR:set_position(456, paddleR)
end


-- Reset everything when a player wins, and START is pressed
function reset_full()
    reset_partial()
    
    lLives = 5
    rLives = 5

    Graphics.set_clear_color(clear_col)
end


-- Update Function
function update(dt)
    if lLives > 0 and rLives > 0 then

        -- Move Left Paddle
        if Input.button_held(PSP_UP) then
            paddleL = paddleL + dt * 272.0
        end

        if Input.button_held(PSP_DOWN) then
            paddleL = paddleL - dt * 272.0
        end

        -- Make sure the Left Paddle does not move outside the screen
        if paddleL > 240 then
            paddleL = 240
        end

        if paddleL < 32 then
            paddleL = 32
        end

        -- Move Right Paddle
        if Input.button_held(PSP_TRIANGLE) then
            paddleR = paddleR + dt * 272.0
        end

        if Input.button_held(PSP_CROSS) then
            paddleR = paddleR - dt * 272.0
        end

        -- Make sure the Right Paddle does not move outside the screen
        if paddleR > 240 then
            paddleR = 240
        end

        if paddleR < 32 then
            paddleR = 32
        end

        paddleTransformL:set_position(24, paddleL)
        paddleTransformR:set_position(456, paddleR)

        potX = ballX + ballVX * dt
        potY = ballY + ballVY * dt
        ballCheck:set_position(potX, potY)

        -- If the Ball hits the top or bottom of the screen
        if potY < 4 or potY > 268 then
            ballVY = -ballVY
        end

        -- If Ball enters the left goal
        if potX < -100 then
            lLives = lLives - 1
            reset_partial()
        end

        -- If Ball enters the right goal
        if potX > 580 then
            rLives = rLives - 1
            reset_partial()
        end

        -- Check if Ball touches the Left Paddle
        if ballCheck:intersects(paddleTransformL) then
            ballVX = 200
            ballVY = ballVY - (paddleL - potY) * 10
        end

        -- Check if Ball touches the Right Paddle
        if ballCheck:intersects(paddleTransformR) then
            ballVX = -200
            ballVY = ballVY - (paddleR - potY) * 10
        end

        ballX = ballX + ballVX * dt
        ballY = ballY + ballVY * dt
        ball:set_position(ballX, ballY)

    else
        if lLives == 0 then
            Graphics.set_clear_color(purple_v)
        else
            Graphics.set_clear_color(green_v)
        end

        if Input.button_held(PSP_START) then
            reset_full()
        end
    end
end


-- Draw essential elements on the screen
function draw()
    -- Number of lives for the left player
    for i = 1, lLives, 1 do
        Primitive.draw_rectangle(48 + 32 * i, 263, 12, 12, green, 50)
    end

    -- Number of lives for the right player
    for i = 1, rLives, 1 do
        Primitive.draw_rectangle(432 - 32 * i, 263, 12, 12, purple, 50)
    end

    -- Draw left and right paddles
    Primitive.draw_rectangle(paddleTransformL, green)
    Primitive.draw_rectangle(paddleTransformR, purple)

    -- Draw middle line
    for i = 0, 17, 1 do
        Primitive.draw_rectangle(240, 0 + i * 16, 8, 8, white, 0)
    end

    -- Draw ball
    Primitive.draw_circle(ball, yellow)
end


-- Main loop
timer = Timer.create()
while QuickGame.running() do
    Input.update()

    update(timer:delta())

    Graphics.start_frame()
    Graphics.clear()

    draw()

    Graphics.end_frame(true)
end