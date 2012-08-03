-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- ****************************************************************
-- Notes
-- ****************************************************************

-- ----------------------------------------------------------------
-- Todo:
-- ----------------------------------------------------------------

-- Game Title
-- Make @2x art for all images.
-- Resize tile artwork
-- Make Button Art
-- Implement widget lib for buttons
-- Slow down tile combo animation
-- Style score -- Add custom font
-- Style points -- add font, shadow or outline
-- Show combo progression 
-- ----------------------------------------------------------------


-- ----------------------------------------------------------------
-- List of Assest
-- ----------------------------------------------------------------
-- Background images
-- Main background - sushimatch-back.png
-- Options screen background - options-back.png

-- Buttons, each of these has two images default and over
-- Cancel button default - cancel-default.png
-- Cancel button over - cancel-over.png
-- Reset button default - reset-button.png
-- Reset button over - reset-over.png
-- Settings Button default - settings-default.png
-- Settings Button over - settings-over.png

-- Game sprites. These are all in one file. Each image needs to 
-- be fit into the grid. My grid is 32x32 pixels. 
-- Sushi-32.png
-- ----------------------------------------------------------------




-- ****************************************************************
-- Set up Environment 
-- ****************************************************************

-------------------------------------------------------------------
-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )
-------------------------------------------------------------------
-- Import the Sprite API
local sprite = require( "sprite" )

-- Import widget lib
local widget = require( "widget" )
-------------------------------------------------------------------









---****************************************************************
-- These variables run the game
---****************************************************************

-------------------------------------------
-- This table defines the animation for points displayed 
-------------------------------------------
local score_animation_table = { y=-200, 	-- Vertical distance					
								time=500, 	-- time
								delay=500, 	-- delay before moving
								alpha=0, 	-- fade to 0 alpha
								transition=easing.inQuad }	

local score_points_font_size = 22			-- Font size for points

-- make a sprite sheet
local tile_sheet = sprite.newSpriteSheet( "images/Sushi-32.png", 32, 32 )
local tile_set = sprite.newSpriteSet( tile_sheet, 1, 12 )


--------------------------------------------------------------------
-- Define the grid  
--------------------------------------------------------------------
local TILE_ROWS = 6		-- Number of rows
local TILE_COLS = 6		-- Number of columns
local TILE_SIZE = 50	-- Width and Height of tiles
local TILE_MARGIN = 1	-- Space between tiles

local offset_y = 116 	-- Moves the whole grid up or down

local match_color_index = 0
local score = 0 		-- Add a variable to hold the score
local set_score			-- forward declaration

local tile_array = {}		-- Holds an array of tile rows
local color_array = {} 		-- Array of colors to match
local matched_array = {}	-- Used for finding matching tiles

local current_tile_index = 1 	-- The current tile index to place
local random_tile_index = 1 	-- The maximum index tile to choose



-------------------------------------------------------------------
-- Background image 
-------------------------------------------------------------------
local background = display.newImageRect( "images/sushimatch-back.png", 320, 480 )
background.x = display.contentCenterX
background.y = display.contentCenterY
-------------------------------------------------------------------


-- This display group holds all game objects
local game_group = display.newGroup()
local options_group = display.newGroup()

-- This function defines and returns Color objects
local function Color( red, green, blue )
	return {r=red, g=green, b=blue}
end 


-------------------------------------------------------------------
-- Define the colors used in the game 
-------------------------------------------------------------------
table.insert( color_array, Color( 255, 0, 0 ) )	-- Red
table.insert( color_array, Color( 0, 255, 0 ) )	-- Green
table.insert( color_array, Color( 0, 0, 255 ) )	-- Blue

table.insert( color_array, Color( 255, 255, 0 ) )	-- Yellow
table.insert( color_array, Color( 255, 0, 255 ) )	-- Fucsia 
table.insert( color_array, Color( 0, 255, 255 ) )	-- Cyan

-- Set the default tile 
local default_tile_color = Color( 255, 255, 255 ) -- White 
local default_tile_alpha = 200
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Add a text object to display the score
-------------------------------------------------------------------
local score_text = display.newText( score, 0, 0, native.systemFont, 16 )
game_group:insert( score_text )
-------------------------------------------------------------------














-- **************************************************************************************
-- These functions run the game
-- **************************************************************************************



-- --------------------------------------------------------------------------------------
-- A function to update the score 
-- --------------------------------------------------------------------------------------
local function set_score( points ) 
	score = score + points 	-- Add points to score
	score_text.text = score	-- Display the new score 
	-- These next three lines position the score based on the top left reference point
	score_text:setReferencePoint( display.TopLeftReferencePoint )
	score_text.x = 10
	score_text.y = 5
end 
set_score( 0 ) -- Call set score once to position the score text correctly





----------------------------------------------------------------------------------------
-- Make options panel 
----------------------------------------------------------------------------------------
-- Handle option buttons events
local function show_options()
	transition.to( options_group, {y=0, time=300, transition=easing.outQuad} ) -- Animate the options panel onto screen
end

local function hide_options()
	-- Animate options panel off screen
	transition.to( options_group, {y=display.contentHeight, time=300, transition=easing.outQuad} )
end

local function tap_cancel( event )
	hide_options()
end

-----------------------------------------------------------------------------------------
-- This function clears all tiles and reset the game 
-----------------------------------------------------------------------------------------
local function reset_tiles()
	for row = 1, TILE_ROWS, 1 do 
		for col = 1, TILE_COLS, 1 do 
			local tile = tile_array[row][col]
			tile.is_empty = true -- set this tile to empty
			tile.color_index = 0
			tile.back:setFillColor( 255, 255, 255, 100 )
			tile.sprite.currentFrame = tile.color_index + 1
		end
	end 
end

local function tap_reset( event )
	score = 0
	set_score( 0 ) 
	reset_tiles()
	hide_options()
end

local function tap_options( event )
	show_options()
end 

-- --------------------------------------------------------------------------------------
-- Create the options panel 
-- --------------------------------------------------------------------------------------
local function make_options_panel()
	-- Make a background for panel
	local back = display.newImageRect( "images/options-back.png", 320, 480 )
	back.x = display.contentCenterX
	back.y = display.contentCenterY
	options_group:insert( back )
	
	-- Make a reset button
	local reset_button = widget.newButton( {default="images/reset-default.png",
											over="images/reset-over.png",
											width=185,
											height=55,
											onRelease=tap_reset})
	reset_button.x = display.contentCenterX
	reset_button.y = 160
	options_group:insert( reset_button.view )
	
	-- Make a cancel button 
	local cancel_button = widget.newButton( {default="images/cancel-default.png",
											over="images/cancel-over.png",
											width=185,
											height=55,
											onRelease=tap_cancel})
	cancel_button.x = display.contentCenterX
	cancel_button.y = 240
	options_group:insert( cancel_button.view )
	
	-- Position the panel 
	options_group.y = display.contentHeight
	
	-- Add event listener to panel objects
	options_group:addEventListener( "touch", function() return true end )
	
end 

make_options_panel()

-- Make the show panel button 
local function make_show_options_button()
	local options_button = widget.newButton( {default="images/settings-default.png",
												over="images/settings-over.png",
												width=50,
												height=50,
												onRelease=tap_options} )
	options_button.x = 295
	options_button.y = 66
	game_group:insert( options_button.view )
end

make_show_options_button()














-- --------------------------------------------------------------------------------------
-- Add a function to create score field objects
-- --------------------------------------------------------------------------------------
local function Score_Field( points )
	local score_text = display.newText( points, 0, 0, native.systemFont, score_points_font_size )
	return score_text
end 






-----------------------------------------------------------------------
-- This function defines a Tile object
-----------------------------------------------------------------------
local function Tile()
	local tile = display.newGroup()
	local back = display.newRect( 0, 0, TILE_SIZE, TILE_SIZE )
	back:setFillColor( 255, 255, 255, 100 )
	
	local tile_sprite = sprite.newSprite( tile_set )
	tile_sprite.x = TILE_SIZE / 2
	tile_sprite.y = TILE_SIZE / 2
	
	function tile:reset()
		self.color_index = 0
		self.is_empty = true
		self.back:setFillColor( 255, 255, 255, 100 )
		self.sprite.currentFrame = tile.color_index + 1
	end 
	
	function tile:set_color( color_index )
		self.is_empty = false
		self.color_index = color_index
		
		local r = color_array[ self.color_index ].r
		local g = color_array[ self.color_index ].g
		local b = color_array[ self.color_index ].b
	
		self.back:setFillColor( r, g, b )
		self.sprite.currentFrame = self.color_index + 1
	end 
	
	tile.back = back
	tile.sprite = tile_sprite
	
	tile:insert( back )
	tile:insert( tile_sprite )
	
	return tile
end 









-- -------------------------
-- Next tile 
-- -------------------------
local function get_next_tile()

end

local next_tile = Tile()
game_group:insert( next_tile )
next_tile.x = 8
next_tile.y = 110
next_tile:set_color( current_tile_index )
-- next_tile:set_color( math.random( #color_array ) )
----------------------------







------------------------------------------------------------------
-- this function shows points in a score field on the game board. 
------------------------------------------------------------------
-- This function removes score fields
local function remove_score_text( score_text )
	display.remove( score_text )
end

local function show_points( points, x, y )
	local score_text = Score_Field( points )
	score_text.x = x + TILE_SIZE * 0.5
	score_text.y = y + TILE_SIZE * 0.5
	
	score_animation_table.onComplete=remove_score_text
	score_animation_table.delta = true
	transition.to( score_text, score_animation_table )
end 
-------------------------------------------------------------------










-- Remove tiles 
local function remove_tile( tile ) 
	-- print( "removing tile", tile )
	display.remove( tile )
end 

-- Animates a matched set of tiles. 
local function animated_match()
	local color = color_array[match_color_index] 
	local t = {time=500, x=matched_array[1].x, y=matched_array[1].y, alpha=0, onComplete=remove_tile, transition=easing.outExpo}
	
	for i = 1, #matched_array, 1 do 
		local tile = Tile()
		
		tile:set_color( match_color_index )
		
		tile.x = matched_array[i].x
		tile.y = matched_array[i].y
		transition.to( tile, t )
	end 
end 


local check_neighbors
local check_tile_match

local function get_tile_frame_at_col_row( col, row )
	if col >= 1 and col <= TILE_COLS and row >= 1 and row <= TILE_ROWS then 
		return tile_array[row][col]
	else 
		return false
	end  
end 

function check_neighbors( tile )
	-- Get the row and col of this tile
	local row = tile.row
	local col = tile.col
	
	-- Define the coords of Left, Top, Right, and Bottom 
	local ltrb_array = { {row=0,  col=-1}, 
						{ row=-1, col=0 }, 
						{ row=0,  col=1 }, 
						{ row=1,  col=0 } }
						
	-- print("Check from tile:".. tile.row .. tile.col .. " " .. tile.alien.currentFrame  )
	
	-- Loop through left, top, right and bottom
	for i = 1, #ltrb_array, 1 do 
		local check_row = row + ltrb_array[i].row
		local check_col = col + ltrb_array[i].col
		-- Check that the row and col are on the board 
		local n_tile = get_tile_frame_at_col_row( check_col, check_row )
		
		if n_tile then -- on board
			if n_tile.color_index == match_color_index then -- matches
				-- Check that this tile doesn't exist in matched_array
				local index = table.indexOf( matched_array, n_tile )
				
				if index == nil then -- tile hasn't been found yet!
					print( "match at:" .. n_tile.row .. n_tile.col )
					table.insert( matched_array, n_tile ) -- add to array
					check_neighbors( n_tile )	-- recur this function with new tile
				end 
			end
		end
	end 
end 

function check_tile_match( tile )
	matched_array = {tile}					-- Add the first tile to the array
	match_color_index = tile.color_index	-- Get the index to match
	
	check_neighbors( tile ) -- Start looking for matching tiles
	
	-- Time to clear the tiles, if there are more than 2 matches
	if #matched_array > 2 then 				-- If more than two tiles match
		for i = 2, #matched_array, 1 do 	-- Loop through all but the first tile
			local tile = matched_array[i]	-- Clear all these tiles
			tile:reset()
		end 
		
		local tile = matched_array[1]				-- Get the first tile and 
		
		tile:set_color( match_color_index + 1 )
		
		animated_match()
		
		-- Calculate points 
		local points = match_color_index * 100 * #matched_array
		set_score( points ) -- Call set_score to add these points to the score 
		show_points( points, tile.x, tile.y ) -- Display the points at the location of the scoring tile
		
		-- Wait for the animation to complete then check for another match set
		timer.performWithDelay( 500, function() check_tile_match( tile ) end, 1 )
		
	end 
end 
----------------------------------------------------------------------------------------





----------------------------------------------------------------------------
-- Handle Touch events on tiles
----------------------------------------------------------------------------
local function touch_tile( event )
	local phase = event.phase
	
	if phase == "ended" then 
		local tile = event.target
		if tile.is_empty then 
			tile:set_color( current_tile_index )
			-- Matching logic logic starts here. 
			check_tile_match( tile )
			
			-- get a new random tile index 
			current_tile_index = math.random(1, 3)
			next_tile:set_color( current_tile_index )
		end 
		
	end 
end



local function make_grid()
	local tile_spacing = TILE_SIZE + TILE_MARGIN
	local offset_x = ( display.contentWidth - ( tile_spacing * TILE_COLS ) ) / 2
	offset_x = TILE_SIZE - offset_x
	
	for row = 1, TILE_ROWS, 1 do 
		local row_array = {}
		for col = 1, TILE_COLS, 1 do 
			local tile = Tile()
			game_group:insert( tile )
			tile.x = ( col * tile_spacing ) - offset_x
			tile.y = ( row * tile_spacing ) + offset_y
			tile.row = row
			tile.col = col 
			
			tile.is_empty = true -- set this tile to empty
			tile.color_index = 0
			
			tile:addEventListener( "touch", touch_tile )
			table.insert( row_array, tile )
		end 
		table.insert( tile_array, row_array )
	end 
end 

make_grid()

