---@enum eLogLevel
eLogLevel = {
	info = 0,
	warning = 1,
	trace = 2,
	error = 3,
	debug = 4,
	fatal = 5
};

---@enum eLogColor
eLogColor = {
	Reset = "\27[0m",
    Bold = "\27[1m",
    Dim = "\27[2m",
    Underline = "\27[4m",
    Reverse = "\27[7m",
    Hidden = "\27[8m",
    FgBlack = "\27[30m",
    FgRed = "\27[31m",
    FgGreen = "\27[32m",
    FgYellow = "\27[33m",
    FgBlue = "\27[34m",
    FgMagenta = "\27[35m",
    FgCyan = "\27[36m",
    FgWhite = "\27[37m",
};