local MARK_NS = vim.api.nvim_create_namespace("DYSLEXIA-VT")
local HL = "DYSLEXIA-HL"
local HL_GROUP = vim.api.nvim_set_hl(0, HL, {
	-- bg = "#ff00ff",
})

local M = {
	threshold = 0,
}

---@param chars string[]
---@return string
function M._join_chars(chars)
	local out = ""
	for _, char in pairs(chars) do
		out = string.format("%s%s", out, char)
	end

	return out
end

---@param str string
---@return string[]
function M._split_chars(str)
	local out = {} ---@type string[]
	for i = 1, #str do
		table.insert(out, string.sub(str, i, i))
	end
	return out
end

---@param word string
---@return string
function M._shuffle_word(word)
	if #word <= 3 or (math.random() < M.threshold) then
		return word
	end
	local middle = M._split_chars(string.sub(word, 2, -2))
	for i = 1, #middle - 1 do
		local j = math.random(0, i + 1)
		local tmp = middle[i]
		middle[i] = middle[j]
		middle[j] = tmp
	end
	local out = string.format("%s%s%s", word:sub(1, 1), M._join_chars(middle), word:sub(-1, -1))
	return out
end

function M._get_word(row, col, word)
	local mouse_pos = vim.api.nvim_win_get_cursor(0)
	local is_hovered = row + 1 == mouse_pos[1] and col <= mouse_pos[2] and mouse_pos[2] < (col + #word)
	if is_hovered then
		return word
	end
	return M._shuffle_word(word)
end

function M._scramble_line(line, lineIdx, bufIdx)
	local last_word = ""
	local last_col_start = 0
	for i = 1, #line do
		local current_char = string.sub(line, i, i)
		if current_char == " " then
			vim.api.nvim_buf_set_extmark(bufIdx, MARK_NS, lineIdx, last_col_start, {
				virt_text = { { M._get_word(lineIdx, last_col_start, last_word), HL } },
				virt_text_pos = "overlay",
			})
			last_word = ""
		elseif last_word == "" then
			last_col_start = i - 1 -- set start of new word
			last_word = last_word .. current_char -- append current char
		else
			last_word = last_word .. current_char -- append current char
		end
	end
	if last_word ~= "" then
		vim.api.nvim_buf_set_extmark(bufIdx, MARK_NS, lineIdx, last_col_start, {
			virt_text = { { M._get_word(lineIdx, last_col_start, last_word), HL } },
			virt_text_pos = "overlay",
		})
	end
end

function M.scramble_buffer()
	print("A")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, MARK_NS, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i, line in pairs(lines) do
		M._scramble_line(line, i - 1, buf)
	end
end

---@param opts table<string,any>
function M.setup(opts)
	-- on any of these, update the highlights
	opts = opts or {}
	M.threshold = opts.threshold or 1

	vim.api.nvim_create_user_command("ScrambleBuffer", M.scramble_buffer, {})
	vim.api.nvim_create_autocmd({ "InsertLeave", "CursorMoved" }, {
		pattern = "*.md",
		callback = M.scramble_buffer,
	})
end

return M
