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
numOfBullets = 0

-- enemies
createEnemyTimerMax = 0.6
createEnemyTimer = createEnemyTimerMax

--Image storage
bulletImg = nil
enemyImg = nil
goldImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {}
golds = {}

-- these three functions are called by the Love engine
-- update and draw will be called every frame, taking dt(deltaTime)
function love.load(arg)
	player = {x=200, y=710, speed=200, 
			  health=5, maxBullets = 5, 
			  gold = 0, img=nil}
	player.img = love.graphics.newImage('assets/plane.png')
	bulletImg = love.graphics.newImage('assets/blue_bullet.png')
	enemyImg = love.graphics.newImage('assets/enemy_1.png')
	goldImg = love.graphics.newImage('assets/gold_1.png')
	-- have an asset ready to be used inside Love
end

function love.update(dt)

	-- a way to exit game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	-- shooting -----------------------------------
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 and numOfBullets <= player.maxBullets then
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
		newBullet = { x = player.x + (player.img:getWidth()/2)-3, y = player.y, img = bulletImg}
		table.insert(bullets, newBullet)
		numOfBullets = numOfBullets+1
		canShoot = false
		canShootTimer = canShootTimerMax
	end
	
	--- gold------
	for i, gp in ipairs(golds) do
		gp.y = gp.y + (100*dt)
		if gp.y > love.graphics.getHeight() then
			table.remove(golds, i)
		end
	end
	
	
	-- bullets --------
	for i, bullet in ipairs(bullets)do
	-- speed for bullets
		bullet.y = bullet.y - (300 * dt)
		if bullet.y < 0 then -- remove bullets off screen
			table.remove(bullets,i)
			numOfBullets = numOfBullets-1
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
	-- speed of enemies
		enemy.y = enemy.y + (150*dt)
		
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
				
				----------- Gold 
				randX = math.random(enemy.x, enemy.x+enemy.img:getWidth()) 
				randY = math.random(enemy.y, enemy.y + enemy.img:getHeight())
				newGold = {x = randX, y = randY, value = 2, img = goldImg}
				table.insert(golds, newGold)
				
				
				table.remove(bullets, j)
				table.remove(enemies, i)
				score  = score + 1
				numOfBullets = numOfBullets-1
				
				------ drop gold ------
				
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
	
	for i, gp in ipairs(golds) do
		if CheckCollision(gp.x, gp.y, gp.img:getWidth(), gp.img:getHeight(),
			player.x, player.y, player.img:getWidth(), player.img:getHeight()) then
			player.gold = player.gold + gp.value
			table.remove(golds, i)
		end
	end
	
	
	-- resetting the game
	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}
		golds = {}

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
	
	---- draw gold
	for i, gp in ipairs(golds) do
		love.graphics.draw(gp.img, gp.x, gp.y)
	end
	
end