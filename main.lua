debug = true

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- player stats
isAlive = true
score = 0


-- timers
-- bullets
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- enemies
createEnemyTimerMax = 0.6
createEnemyTimer = createEnemyTimerMax

--Image storage
bulletImg = nil
enemyImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {}

-- these three functions are called by the Love engine
-- update and draw will be called every frame, taking dt(deltaTime)
function love.load(arg)
	player = { x=200, y=710, speed=150, health=5, img=nil}
	player.img = love.graphics.newImage('assets/plane.png')
	bulletImg = love.graphics.newImage('assets/blue_bullet.png')
	enemyImg = love.graphics.newImage('assets/enemy_1.png')
	-- have an asset ready to be used inside Love
end

function love.update(dt)




	-- a way to exit game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	-- shooting
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end
	
	if love.keyboard.isDown('left', 'a') then	
		-- collision checking
		if player.x > 0 then
			player.x = player.x-(player.speed*dt)
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	elseif love.keyboard.isDown('up', 'w') then	
		if player.y > (love.graphics.getHeight()/2) then	
			player.y = player.y - (player.speed*dt)
		end
	elseif love.keyboard.isDown('down', 's') then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed * dt)
		end
	-- cheats
	elseif love.keyboard.isDown('g') then
		player.health = player.health + 10
	end
	
	if love.keyboard.isDown(' ') and canShoot then
		-- create new bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end
	
	-- bullets --------
	for i, bullet in ipairs(bullets)do
		bullet.y = bullet.y - (250 * dt)
		if bullet.y < 0 then -- remove bullets off screen
			table.remove(bullets,i)
		end
	end
	------------------
	
	-- enemies ----------------
	createEnemyTimer = createEnemyTimer - (1*dt) -- how fast enemies spawn
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax
		
		-- Create Enemy
		randomNumber = math.random(10, love.graphics.getWidth()-100)
		newEnemy = { x = randomNumber, y = -10, img = enemyImg}
		table.insert(enemies, newEnemy)
	end
	
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200*dt)
		
		if enemy.y > 850 then -- remove the enemy
			table.remove(enemies,i)
		end
	end
	
	------------------------------
	
	--- checking collision ------
	for i, enemy in ipairs(enemies) do	
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
				bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score  = score + 1
			end
		end
		
		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
				player.x, player.y, player.img:getWidth(), player.img:getHeight())
			and isAlive then
			table.remove(enemies, i)
			player.health = player.health - 1
			if player.health == 0 then
				isAlive = false
			end
		end
	end
	
	
	-- resetting the game
	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}

		-- reset timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 710
		player.health=5

		-- reset our game state
		score = 0
		isAlive = true
		playerHealth=5
	end
end


function love.draw(dt)
	-- draw function must be called in here
	--- printing stats
	if isAlive then
		love.graphics.print("Score: " ..score, love.graphics:getWidth()-70, 10)
		love.graphics.print ("Health: "..player.health, 10, 10)
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	
	for i, bullet in ipairs(bullets)do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end
	
	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end
	
	
end