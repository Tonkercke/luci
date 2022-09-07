module("luci.controller.torui", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/torui") then
		return
	end
	local page
	page = entry({"admin", "services", "torui"}, cbi("torui"), _("Tor UI"))
	page.dependent = true
end
