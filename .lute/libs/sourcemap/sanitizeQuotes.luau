local function sanitizeQuotes(str: string): string
	str = string.gsub(str, '"', '\\"')
	str = string.gsub(str, "\\", "\\\\")
	return str
end

return sanitizeQuotes
