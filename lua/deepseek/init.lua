-- init.lua
local M = {}

-- Cargar el módulo principal
M.setup = function(user_config)
	require('deepseek.deepseek').setup(user_config)
end

-- Exportar la función `suggest`
M.suggest = function()
	require('deepseek.deepseek').suggest()
end

return M

