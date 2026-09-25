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

function M._scramble_line(line)
	local total_line = ""
	local last_word = ""
	for i = 1, #line do
		local current_char = string.sub(line, i, i)
		if current_char == " " then
			total_line = string.format("%s%s ", total_line, M._shuffle_word(last_word))
			last_word = ""
		else
			last_word = string.format("%s%s", last_word, current_char)
		end
	end
	total_line = string.format("%s%s", total_line, M._shuffle_word(last_word))
	last_word = ""
	return total_line
end

function M.scramble_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local edited_lines = {}
	for _, line in pairs(lines) do
		local result = M._scramble_line(line)
		table.insert(edited_lines, result)
	end
	vim.api.nvim_buf_set_lines(buf, 0, #lines, true, edited_lines)
end

---@param opts table<string,any>
function M.setup(opts)
	-- on any of these, update the highlights
	opts = opts or {}
	M.threshold = opts.threshold or 1

	vim.api.nvim_create_user_command("ScrambleBuffer", M.scramble_buffer, {})
end

return M
