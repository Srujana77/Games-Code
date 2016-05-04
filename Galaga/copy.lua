vector = require 'vector'

-------------------------
-- LOVE callbacks
--
function love.load()
   bullets = {}
   targets = {}
   targetImage = love.graphics.newImage("target.png")
   bulletImage = love.graphics.newImage("bullet.png")
   COLLISION_DISTANCE = targetImage:getWidth()/2
   uniquifier = 0
   -- setup targets
   spawnTargets ( 10 )
   lastSpawnTime = love.timer.getTime()
   spawnDelay = 5
end

--[[function love.mousepressed( x, y, button )
   local start = vector.new(love.window.getWidth()/2, love.window.getHeight())
   local speed = 1000
   local dir = vector.new(x,y) - start
   dir:normalize_inplace()
   createNewBullet ( start, dir * speed )
end]]--

function love.keypressed(key)   
 local start = vector.new(love.window.getWidth()/2, love.window.getHeight())
   local speed = 1000
	if key == " " then	
	createNewBullet ( start, speed )
	end	
   
end

function love.draw()
   for id,ent in pairs(targets) do
	  ent:draw()
   end
   for id,ent in pairs(bullets) do
     ent:draw()
   end
end

function love.update(dt)

   time = love.timer.getTime()
   if time  > lastSpawnTime + spawnDelay then
      lastSpawnTime = time
      spawnTargets ( 10 )
   end


   for id,ent in pairs(targets) do
     ent:update(dt)
   end
   for id,ent in pairs(bullets) do
     ent:update(dt)
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
	     bullets[self.id] = nil
	     targets[hit] = nil
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
   end

   function target:draw ()
      love.graphics.draw ( targetImage, self.pos.x, self.pos.y , math.rad(90) , 0.3 , 0.3 )
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