local anim8 = require 'anim8'
camera = require 'camera'
vector = require 'vector'
config = require 'config'
power = {}
	power.image = love.graphics.newImage("pu.jpg")
	power.speed = 10
	
	enemies = {}
	enemies.image = love.graphics.newImage("npc.jpg")
	enemies.speed = 10;
	
	level = 1

	destY = -1000
	
--************************************Explosion part************************************************************************

local explodeSpriteSheet,explodeAnimation
function explosionDone(self,loops)
   self:pauseAtEnd()
   exploding = false
end

--************************************Explosion part************************************************************************
function love.load()

hit = 0
dis = 1
timer = 50
count = 0
collis = false

gameStatus = "Racing"


--************************************Explosion part************************************************************************

explodeSpriteSheet = love.graphics.newImage(config.explodeSheetFilename)
   local g = anim8.newGrid(64,64, 
			   explodeSpriteSheet:getWidth(), 
			   explodeSpriteSheet:getHeight())
   explodeAnimation = anim8.newAnimation( g('1-5','1-5'), 0.05,
					  explosionDone )
   explodeAnimation:pauseAtStart()
   
   exploding = false

--************************************Explosion part************************************************************************

	
	love.window.setMode(350,400)
	player = {}
	player.speed = 0
	player.x = 25
	player.y = 500
	player.image = love.graphics.newImage("Player.jpg")	
	cf = love.graphics.newImage("cf.jpg")
	--expl= love.graphics.newImage("exp.png")	
	
	addEnemy()
	addPower()
	
	   
   manstart = vector.new( player.x, player.y)
   manpos = manstart:clone()
	
	
	cam = camera.new()

	bgcam = camera.new()
	--bgcam.zoom = config.bgzoom
	bgcam2 = camera.new()
	--bgcam2.zoom = 0.9 * config.bgzoom
	
end


function love.draw(x,y)
      
   -- draw the background with a zoomed camera
	bgcam2:draw(function () drawBackground(57) end)
	bgcam:draw(function () drawBackground(99) end)

	-- draw the scene using the camera
	cam:draw(draw)
	
	--love.graphics.print("Hit:"..hit, 200, 10)
	love.graphics.print("Time:"..timer, 150, 10)
	love.graphics.print("GameStatus:"..gameStatus, 150, 30)
end

function love.update(dt)

	if (player.y >= destY and collis == false and timer ~= 0) then 
     player.y = player.y + (dt*player.speed)*((destY-player.y)/math.abs(destY-player.y))
	 manpos = manpos + vector.new(0,-1)
	 count = count + 1	
		if count == 5 and timer ~= 0 and player.y > destY then 
		timer = timer - 1
		count = 0
		end
		
	for i,enemy in ipairs(enemies) do
--if enemy.y >= destY then
		enemy.y = enemy.y - 2
		--[[else
		enemy.y = enemy.y ]]--
		--end
	end
	
	
	for i,power in ipairs(power) do
--if power.y >= destY then
		power.y = power.y - 2	
		--[[else
		power.y = power.y ]]--
		--end
	end	
		
		
	else
		player.y = player.y + (dt*player.speed)*0	
			if (collis == true and timer ~= 0) then 
			gameStatus = "You Collided\n You Lost \n\t Game Over"
			elseif (collis == false and timer == 0) then
			gameStatus = "Time up \n You Lost \n\t Game Over"
			else
			gameStatus = "You Win \n\n\t Game Over"
			--level = level + 1
			--destY = destY - 1000
			--love.timer.sleep(5)
			--love.load()
			end
	end
   
   -- follow player with camera
	cam.pos.y = player.y-100
	

	collision(dt)
	
	if exploding then
      explodeAnimation:update(dt)
   end
	
	-- background too
	--bgcam.pos.x = player.x
	--bgcam2.pos.x = player.x
end

function love.keypressed(key,isrpt)
	if key == "up" then
		player.speed = player.speed + 300
	end
end

function love.keyreleased(key)
   if key == "up" then
      player.speed = player.speed - 300
   end
   
   if key == "right" then
	if player.x < 150 then
	   player.x= player.x + 25
	   love.draw()
	end
   end
   
   if key == "left" then
	if player.x > 0 then
	   player.x= player.x-25
	   love.draw()
	end
   end 
end



function drawBackground()
	love.graphics.rectangle("fill", 0, 500, 150, destY )	
end

function draw()


love.graphics.draw(cf, 0, destY ,0,0.05,0.05)
love.graphics.draw(cf, 0, 500 ,0,0.05,0.05)


for i,enemy in ipairs(enemies) do	
love.graphics.draw(enemies.image, enemy.x, enemy.y ,0,0.1,0.1)

end

for i,po in ipairs(power) do	
love.graphics.draw(power.image, po.x, po.y ,0,0.15,0.15)
end


love.graphics.draw(player.image, player.x, player.y,0,0.1,0.1)	
if exploding then
      explodeAnimation:draw (explodeSpriteSheet, manpos:unpack())
   end


end

function addEnemy()
local n = love.math.random(1,10)

love.math.setRandomSeed ( n )

for i=1,3 do
   enemies[#enemies+1] = {x=love.math.random(0,125), y=love.math.random(destY + 100,300)}
end
end


function addPower()
local n = love.math.random(1,10)

love.math.setRandomSeed ( n )

for i=1,1 do
   power[#power+1] = {x=love.math.random(0,125), y=love.math.random(destY + 100,200)}
end
end

function collision(dt)
for t,enemy in ipairs(enemies) do
	local dx = enemy.x+1- player.x
	 local dy = enemy.y+30 - player.y
	 if math.sqrt(dx*dx+dy*dy) < 30 then
	 hit = hit + 1
	 if not exploding then
	 exploding = true
	 explodeAnimation:resume()
      end
	 --table.remove(enemies,t)
	 collis = true
	 --enemy.x = enemy.x + love.math.random(-25,25)
	    break
		--[[if (player.y<COLLISION_DISTANCE) then
		table.remove(enemies,enemy)]]--
	 end
      end
	  
	  for t,po in ipairs(power) do
	 local dx = po.x - player.x
	 local dy = po.y - player.y
	 if math.sqrt(dx*dx+dy*dy) < 49 then
	   	   table.remove(power,t)
		   timer = timer  +10
	    break
	 end
      end
end

