g_Root = getRootElement()
g_Res = getThisResource()
g_ResRoot = getResourceRootElement()

function createVote(info, opts)
	local vote = Vote.create(info, opts)
	return vote.el
end

addCommandHandler("testvote", function()
	local info = {
		title = "Test?",
		visibleTo = g_Root,
		timeout = 7}
	local opts = {
		{"Opcja1"},
		{"Opcja2"}}
	local vote = Vote.create(info, opts)
end)