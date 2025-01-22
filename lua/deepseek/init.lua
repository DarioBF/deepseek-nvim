-- init.lua
local M = {}

-- Cargar el módulo principal
M.setup = function(user_config)
	require('deepseek.deepseek').setup(user_config)
end

return M

