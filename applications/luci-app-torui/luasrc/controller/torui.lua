module("luci.controller.torui", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/torui") then
		return
	end
	
	entry({"admin", "services"}, firstchild(), _("services")).dependent = true
	entry({"admin", "services", "torui"}, cbi("torui"), _("Tor UI")).dependent = true
end
