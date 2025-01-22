-- deepseek.lua

local M = {}

-- Configuración por defecto
local config = {
	api_key = "",                                       -- Aquí deberías poner tu API key de DeepSeek Coder
	api_url = "https://api.deepseek.com/v1/suggestions", -- URL de la API de DeepSeek
}

-- Función para configurar el plugin
function M.setup(user_config)
	config = vim.tbl_extend("force", config, user_config or {})
end

-- Función para hacer una solicitud a la API de DeepSeek
local function get_suggestion(code)
	local json_body = vim.fn.json_encode({
		model = "deepseek-coder",     -- Nombre del modelo (verifica en la documentación de DeepSeek)
		prompt = code,                -- El código o la entrada del usuario
		max_tokens = 50,              -- Número máximo de tokens en la sugerencia
	})

	local command = string.format(
		'curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %s" -d \'%s\' %s',
		config.api_key, json_body, config.api_url
	)

	local handle = io.popen(command)
	if not handle then
		return nil, "Failed to execute curl command"
	end
	local result = handle:read("*a")
	handle:close()

	-- Mostrar la respuesta completa para depuración
	print("API Response:", result)

	-- Verificar si la respuesta es un JSON válido
	local ok, json = pcall(vim.fn.json_decode, result)
	if not ok then
		return nil, "Invalid JSON response from API. Response: " .. result
	end

	-- Verificar si hay un error en la respuesta
	if json.error then
		return nil, json.error.message or "API returned an error: " .. vim.inspect(json)
	end

	-- Extraer la sugerencia de texto
	if json.choices and json.choices[1] and json.choices[1].text then
		return json.choices[1].text, nil
	else
		return nil, "No suggestions found in API response"
	end
end

-- Función para mostrar una ventana flotante con la sugerencia
local function show_floating_window(suggestion)
	local width = math.floor(vim.o.columns * 0.8) -- 80% del ancho de la ventana
	local height = math.floor(vim.o.lines * 0.8) -- 80% del alto de la ventana

	-- Crear un buffer flotante
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	})

	-- Insertar la sugerencia en el buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(suggestion, "\n"))

	-- Mapear una tecla para cerrar la ventana flotante
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
end

-- Función principal para obtener sugerencias
function M.suggest()
	local code = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local code_str = table.concat(code, "\n")
	local suggestion, err = get_suggestion(code_str)

	if err then
		vim.api.nvim_echo({ { "Error: " .. err, "ErrorMsg" } }, true, {})
	else
		show_floating_window(suggestion)
	end
end

-- Función para integrar con nvim-cmp
function M.cmp_source()
	return {
		complete = function(_, callback)
			local code = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local code_str = table.concat(code, "\n")
			local suggestion, err = get_suggestion(code_str)

			if err then
				vim.api.nvim_echo({ { "Error: " .. err, "ErrorMsg" } }, true, {})
				callback({})
			else
				callback({
					{
						word = suggestion,
						label = suggestion,
						kind = "Text",
					},
				})
			end
		end,
	}
end

return M
