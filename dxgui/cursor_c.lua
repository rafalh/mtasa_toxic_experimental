local g_Counter = 0

function UiShowCursor()
	g_Counter = g_Counter + 1
	guiSetInputEnabled(g_Counter > 0)
end

function UiHideCursor()
	g_Counter = g_Counter - 1
	guiSetInputEnabled(g_Counter > 0)
end

function UiIsInputEnabled()
	return g_Counter > 0
end
