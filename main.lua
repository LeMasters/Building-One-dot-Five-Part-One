--[[ 

Poetics of Mobile
Project 1.5
22 February 2014

Sample code with comments: Drawing a building, grass, shadow, sky; adding simple animation at 10fps.  Note that the odd height of the grass adds a kind of unintentionally post-apocalyptic feel, a la Alan Weisman's terrific book, The World Without Us (2007).

Please take this code apart and play with it in order to discover what makes it tick.  I've tried to accomplish the same thing in a variety of ways, for the sake of comparison.

Garrison LeMasters
CCT, Georgetown University

--]]


-- QUICK guide to drawing a building

-- I've written a version of this guide 3 times
-- by now.  The first one was too long, the
-- second one way too long, and I didn't even
-- finish the third version, because it
-- was clear where it was headed, too.  
-- THIS VERSION WILL BE SHORT, SO HELP ME GOD.

-- Our first iteration will not include
-- any windows at all.  You don't have to 
-- do it this way:  You could start
-- by creating a facade with windows,
-- and then add the extras (sky, grass, etc.).
-- I just wanted to start by demonstrating
-- how to draw shapes and use fills.

-------

-- Begin by establishing the metes and
-- bounds of the world.  Later, I'll show
-- you how we can put this stuff in a separate
-- file and re-use it with every program.
-- For now, though, let's put it right here.

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

local screenCenterX = display.contentCenterX
local screenCenterY = display.contentCenterY

-- Note that I'm going to create a building that
-- I do not size absolutely ("width = 300 pixels"),
-- but instead size relative to the screen: e.g.,
-- "building width = 25% of screenwidth."
-- This is a vital technique to learn, because
-- mobile screens can vary from 320px to 1920px.

-- We need to make it clear to the builders:  
-- Just how big is this building going to be?
-- As I noted above, I'm going to express it in
-- relative terms:  In this case, the building's
-- height is relative to the screen height, and
-- its width is then relative to the building's
-- height.

local bldgHeight = screenHeight * 0.525
local bldgWidth = bldgHeight * 0.425

local bldgCenterX = bldgWidth  * 0.5
local bldgCenterY = bldgHeight * 0.5

-- Obviously,
-- bldgHeight * 0.5
-- is the same thing as
-- bldgHeight / 2.
-- Both find the center of the building,
-- which is the point from which Corona
-- will anchor it to the screen.

-- But it is worth remembering that
-- a computer can typically multiply
-- much faster than it can divide.
-- It doesn't really matter here, of course:
-- the time it takes to perform these operations
-- is trivial.  But when you're repeating 
-- the same operation several hundred times 
-- a second, multiplication is
-- usually preferable to division.

-- Let's dump our data to the terminal
-- for the sake of scrutiny:

print( "Bldg: " .. bldgWidth .. " x " .. bldgHeight )

---------

-- Now:  Let's gather our consumables.

-- A Paint object, in Cool Grey (as a table):

local paintCoolGrey = { 145/256, 150/256, 147/256 }

-- In a table, colors are typically organized 
-- as { Red (0-1), Green (0-1), Blue (0-1) }.
-- Here, as I'm using a color I found that I liked
-- via a Pantone chart, I've had to convert their
-- range (0-255) into the range I needed (0-1.0).
-- For the sake of future code, I should probably
-- do the calculations myself and enter the decimal
-- equivalents.  But for now, this is fine.


-- More about Paint objects:
-- Note that when we create a rectangle,
-- we call the Corona library's newRect()
-- function, pass it a few arguments,
-- and receive a ShapeObject on the screen 
-- in exchange for our troubles.
-- A ShapeObject is a specific type of 
-- Display Object.  A ShapeObject always contains
-- several properties which are accessed using
-- the dot.  .fill, .strokeWidth, .stroke, etc.
-- To the .fill property, we can assign many
-- things, including a "Paint object" -- which
-- is essentially just a blob of color or image,
-- often stored in a table.


-- A can of darker Warm Grey Paint
-- (again, stored as a table):

local paintWarmGrey = { 0.5, 0.4, 0.45, 0.5 }

-- Note that here, I've added a 4th argument, which 
-- Corona interprets as an alpha mask.  
-- 0 = fully transparent, 1 = fully opaque.
-- I've set mine to 0.5


-- Some Grassy-Fields-in-a-Can(TM).
-- Grass image from publicdomainpictures.net
-- I have altered the original JPEG
-- by making the top of the image
-- transparent with Pixelmator for OSX.

local paintGrassInACan = 
{ 
	type = "image",
	filename = "greenGrassWithAlpha.png"
}

-- Similarly, some Sky-in-a-Box(TM).
-- I'm leaving it as a JPEG because I
-- don't need an alpha (transparent) layer.
-- Image via jodepot.com

local paintSkyInABox =
{
	type = "image",
	filename = "cleanSkyWide.jpg"
}

-- Last thing:  Pick a random spot
-- for our building on the x axis.
-- We'll put this into a function
-- for convenience sake.

local function whereTheX( xRange, bldgModifier )
	-- Returns an xPosition for the building.

	-- Here, I'm going to take the width of
	-- the bldg into account, in order to keep
	-- from positioning the bldg too close
	-- to the right edge.  I'll set xRange
	-- to the screen width, and I'll
	-- set bldgModifier to half the width of
	-- the bldg (because the bldg is always
	-- placed with reference to its center, or
	-- half-width, point.
	-- If the screen is 100 px wide, and the
	-- bldg is 50 pixels wide, then our "safety
	-- zone" is from 25 to 75:  If we put the building
	-- at 25, then its left side will actually extend
	-- all the way over to 0.  Same with 75:  Its
	-- right side would extend all the way to 100.

	local maxX = xRange - bldgModifier
	local xPosition = math.random(bldgModifier, maxX)

	-- That's it.  Return that value
	-- and we're Audi 5000.

	return xPosition
end

-- 
-- For now, we need to draw from
-- the back to the front, otherwise
-- we'll hide our building, etc., with
-- our backdrop.

-- Lots of ways to do this.  Here's one.
-- Note that I'm going to use backgroundWidth, which
-- is 3 x the width of the screen.  I'll have lots of
-- sky sticking out (invisibly) from either side of
-- the screen.  This will be handy later for simple
-- animation.

local backgroundWidth = screenWidth * 3.0
local theSky = display.newRect( 0, 0, backgroundWidth, screenHeight )
theSky.fill = paintSkyInABox
theSky.x = screenCenterX
theSky.y = screenCenterY

-- We'll do two layers of grass for a nice
-- bit of depth.  First layer has to go
-- down before the building goes up.
-- I'm going to use the :setFillColor()
-- method here instead of just assigning
-- the .fill property of the object.
-- We can discuss why I do this if you like.

local myGroundcoverBack = display.newImageRect("greenGrassWithAlpha.png", screenWidth, screenHeight * 0.3)
myGroundcoverBack:setFillColor( 0.525, 0.6125, 0.575, 1 )
myGroundcoverBack.x = screenCenterX * 0.925
myGroundcoverBack.y = screenHeight
myGroundcoverBack.yScale = 1
myGroundcoverBack.xScale = 1.25

-- Drop in our simple building

local myBuilding = display.newRect( 0, 0, bldgWidth, bldgHeight)
myBuilding.x = whereTheX( screenWidth, bldgCenterX )
myBuilding.y = screenHeight - bldgCenterY

-- Briefly:
-- I could put those last two assignment statements in that first
-- line, in place of the "0, 0,".  I tend to do them
-- separately because it makes it easier to read and adjust
-- later.
--
-- Also:
-- I calculate myBuilding.x with a custom function; I calculate
-- myBuilding.y with a simple expression.  Except for the fact
-- that I'm partly randomizing the value of .x, these two
-- approaches are essentially the same and could be used
-- interchangeably.

myBuilding.fill = paintCoolGrey

-- Bonus Extra.  3D effects are usually costly,
-- in terms of processing power.  Sometimes,
-- though, we can do them for next to nothing.
-- In this case, let's just paste a partly
-- transparent shadow over the right half of
-- our building.

local myBuildingShadow = display.newRect( 0, 0, bldgWidth * 0.425, bldgHeight)
myBuildingShadow.x = myBuilding.x + ( bldgWidth * 0.25 )
myBuildingShadow.y = myBuilding.y * 1.0125
myBuildingShadow.fill = paintWarmGrey


-- and now:  Some groundcover.  Two things:
-- First, note that my grass image is way too big
-- (1920 x 756).  I could fix the size before
-- adding it to my program (that would save
-- me a lot of memory, as it is 442k as-is, and
-- that is probably much bigger than necessary).
-- But I want to keep my options open in case
-- I use it in a different way later.  So for
-- now, I'll just scale the rectangle to which
-- I apply the paint.

-- Second, it looks kinda bland.  So I've
-- added a second layer behind the first,
-- scaled it a bit differently and off-set it
-- along the x-axis so that it doesn't remain
-- hidden, and then used a filter to 
-- tint it, making that version of the
-- image just a bit darker.

local myGroundcoverFront = display.newRect( 0, 0, screenWidth, screenHeight * 0.2125 )
myGroundcoverFront.x = screenCenterX * 1.1
myGroundcoverFront.y = screenHeight * 1.025
myGroundcoverFront.xScale = 1.5
myGroundcoverFront.fill = paintGrassInACan


-- All done.  Let's celebrate by animating
-- the background a bit.  This technique is very much
-- a seat-of-your-pants stopgap measure, so don't
-- look too closely...  There are far more
-- elegant ways of building this kind of thing.
-- 
-- I'm going to leave this part mostly
-- uncommented, as it isn't our intended focus
-- at this point.  If you'd like me to explain
-- what's happening, though, let me know.

-- animation element

local function aeolianHarp(event)
	-- this function actually just slides the background to the right.
	-- when it goes too far, it resets it.  Very jarring.
	theSky.x = theSky.x + 1.125
	if ( theSky.x + screenWidth ) > ( theSky.width - ( screenWidth * 0.5 )) then
		theSky.x = screenWidth * 0.5
	end
end

-- This timer activates the aeolianHarp function 10 times
-- a second.  Again, not the best way to do this,
-- but it works in this case.

local myWind = timer.performWithDelay(100, aeolianHarp, 0)
