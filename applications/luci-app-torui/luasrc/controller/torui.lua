module("luci.controller.torui", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/torui") then return end

	entry({"admin", "services", "torui"}, cbi("torui"), _("Tor UI"))
	entry({"admin", "services", "torui", "status"}, call("torui"), nil).leaf = true
end
