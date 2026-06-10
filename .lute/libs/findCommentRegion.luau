local function findCommentRegion(source: string, name: string)
	return string.find(source, `%-%- #region {name}%s.-%-%- #endregion`)
end

return findCommentRegion
