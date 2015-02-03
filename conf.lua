-- Configuration
-- love.conf(t) special function that is executed before any Love modules are loaded
function love.conf(t)
	t.title = "Scrolling Shooter" -- Title of the window the game is in
	t.version = "0.9.1"	-- LOVE version
	t.window.width = 480	-- We want our game to be long and thin
	t.window.height = 800
	
	t.console = true -- so we can see errors
end