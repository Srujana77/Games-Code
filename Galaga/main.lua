vector = require 'vector'

-------------------------
-- LOVE callbacks
--

x = 400
y = 0
score = 0
a = 0
tx = 380
ty = 550
powerup = 0

gamestatus = ""

count = 100 

function love.load()
   bullets = {}
   targets = {}
   turret = love.graphics.newImage("turret.jpg")
   wall = love.graphics.newImage("wall.jpg")
   targetImage = love.graphics.newImage("target.png")
   bulletImage = love.graphics.newImage("bullet.png")
   COLLISION_DISTANCE = targetImage:getWidth()/2
   uniquifier = 0
   -- setup targets
   spawnTargets ( 3 )
   lastSpawnTime = love.timer.getTime()
   spawnDelay = 5
   
   data = love.sound.newSoundData("shoot.mp3")
   sound = love.audio.newSource(data)
   data1 = love.sound.newSoundData("Blast.mp3")
   sound1 = love.audio.newSource(data1)
   data2 = love.sound.newSoundData("Jungle.ogg")
   sound2 = love.audio.newSource(data2)
end

function love.keypressed(key)
	if key == "left" and tx >50 then
	tx = tx - 50
	end
	
	if key == "right" and tx < 700 then
	tx = tx + 50
	end
	
   if key == " " and gamestatus ~= "Game Over" then
   love.audio.play(sound)
		local start = vector.new(tx+20, ty)
		local speed = 1000
		local dir = vector.new(tx,y) - start
		dir:normalize_inplace()
		if count ~= 0 then
		createNewBullet ( start, dir * speed )
		end
   end
end

function love.draw()
   for id,ent in pairs(targets) do
	  ent:draw()
   end
   for id,ent in pairs(bullets) do
     ent:draw()
   end
   love.graphics.draw(wall, 0,ty+20,0,1,1)
   love.graphics.draw(turret, tx,ty,0,0.1,0.1)
   
   
   love.graphics.print("Score :" ..score , 650,10)
   love.graphics.print("Hull Health :" ..count.."%" , 650,20)
   love.graphics.print("Game :" ..gamestatus , 650,30)
   love.audio.play(sound2)
end

function love.update(dt)

   time = love.timer.getTime()
   if time  > lastSpawnTime + spawnDelay then
      lastSpawnTime = time
      spawnTargets ( 3 )
   end


   for id,ent in pairs(targets) do
     ent:update(dt)
   end
   for id,ent in pairs(bullets) do
     ent:update(dt)
   end
   if count == 0 then
   gamestatus = "Game Over"
   end
   if powerup > 9 then
		 count = count + 25
		 powerup = 0
   end
   
end

-----------------------------------
-- bullets
--


function createNewBullet ( pos, vel )
   local bullet = {}
   bullet.pos = vector.new(pos.x, pos.y)
   bullet.lastpos = pos
   bullet.vel = vector.new(vel.x,vel.y)
   bullet.id = getUniqueId()
   bullets[bullet.id] = bullet

   function bullet:checkForCollision ()
      -- return id of collided object (first found)
      for id,target in pairs(targets) do
         if (target.pos - self.pos):len() < COLLISION_DISTANCE then
            return id
         end
      end
      return nil
   end

   function bullet:update ( dt ) 
      self.lastpos = self.pos
      self.pos = self.pos + self.vel * dt
      local hit = self:checkForCollision ()
      if hit then 
	  love.audio.play(sound1)
	     bullets[self.id] = nil
	     targets[hit] = nil
		 score = score + 1
		 powerup = powerup + 1
      end
      -- also check if off-screen 
	  
   end

   function bullet:draw ()
      love.graphics.draw ( bulletImage, self.pos.x, self.pos.y, 0 ,
                           0.3, 0.3 )
   end

   return bullet
end


--------------------------
-- target
--

function createNewTarget ( pos, vel )
   local target = {}
   target.pos = vector.new(pos.x, pos.y)
   target.vel = vector.new(vel.x, vel.y)
   target.angle = love.math.random(1,360)
   target.id = getUniqueId()
   targets[target.id] = target

   function target:update (dt)
      self.pos = self.pos + self.vel * dt
      self.angle = self.angle + 0.02    
      -- also check for off-screen...
	  if self.pos.y > 600 then
	  count = count - 25
	  targets[target.id] = nil
	  end
   end

   function target:draw ()
      love.graphics.draw ( targetImage, self.pos.x, self.pos.y , 0 , 0.3 , 0.3 )
   end

   return target
end

-----------------------
-- helpers
-- 

function getUniqueId ()
   uniquifier = uniquifier + 1
   return uniquifier
end

function spawnTargets ( N )
   for i = 1,N do
      local pos = vector.new ( love.math.random( 10, love.window.getWidth()-10), 
                               -love.math.random(10,100) )
      local vel = vector.new ( 0,50 )
      createNewTarget ( pos, vel )
   end
end