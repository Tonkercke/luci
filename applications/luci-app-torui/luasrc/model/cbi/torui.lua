-- This is free software, licensed under the GNU General Public License v3.

-- [GLOBAL VARS] --------------------------------------------------------------
local torrc = "/etc/tor/torrc"
local makeTorConfigButtonPressed = false
local torrcSampleConfig = 'User tor\n' ..
						  'Log notice syslog\n' ..
						  'HttpsProxy 127.0.0.1:3090\n' ..
						  'SocksPort 0.0.0.0:9150\n' ..
						  'DataDirectory /var/lib/tor\n' ..
						  'GeoIPFile /usr/share/tor/geoip\n' ..
						  'GeoIPv6File /usr/share/tor/geoip6\n' ..
						  'GeoIPExcludeUnknown 1\n' ..
						  'ExcludeNodes {cn},{hk},{mo},{sg},{th},{pk},{by},{ru},{ir},{vn},{ph},{my},{cu},{cl},{ci},{cr},{ee},{es},{gr},{il},{kz},{kw},{lk},{lt},{lv},{kp},{sy},{cu},{tw},{st},{ve},{eg},{kh},{la},{mm},{tr},{ua},{ye},{tk},{br},{pa},{lu},{do},{bf},{in},{id},{sv},{va},{??}\n' ..
						  'ExcludeExitNodes  {cn},{hk},{mo},{sg},{th},{pk},{by},{ru},{ir},{vn},{ph},{my},{cu},{cl},{ci},{cr},{ee},{es},{gr},{il},{kz},{kw},{lk},{lt},{lv},{kp},{sy},{cu},{tw},{st},{ve},{eg},{kh},{la},{mm},{tr},{ua},{ye},{tk},{br},{pa},{lu},{do},{bf},{in},{id},{sv},{va},{??}\n' ..
						  'StrictNodes 1\n' ..
						  'EntryNodes {us},{de},{gb},{nl},{ca},{se},{au}\n' ..
						  'MiddleNodes {us},{de},{gb},{nl},{ca},{se}\n' ..
						  'ExitNodes {us},{de},{nl},{ca},{gb},{se}\n' ..
						  'StrictExitNodes 1'

local fontred = "<font color=\"red\">"
local fontgreen = "<font color=\"green\">"
local endfont = "</font>"
local bold = "<strong>"
local endbold = "</strong>"
local brtag ="<br />"
-------------------------------------------------------------------------------

-- [VARS INITIALIZATION] ------------------------------------------------------
-- Detect TOR
local torui = luci.util.exec("/usr/bin/which tor")

if torui ~= "" then
	local torPid = luci.util.exec("ps | grep '[t]orrc'")
	torServiceStatus = luci.util.exec("/bin/ls /etc/rc.d/S??tor 2>/dev/null")
	if torPid ~= "" then
		torPid = torPid:match("(%d+)")
		torStatus = bold .. fontgreen .. translate("Tor is Running") .. endfont..
		" " .. translate("show PID") .. " " .. torPid .. endbold
	else
		torStatus = bold .. fontred .. translate("Tor not Running") .. endfont .. endbold
	end
	else
		torStatus = bold .. fontred .. translate("Tor not Installed") .. endfont .. endbold
	end
-- Detect TOR END
-------------------------------------------------------------------------------

-- [SECTION INIT] -------------------------------------------------------------
m = Map("torui")
m.pageaction = false
m.title	= translate("Tor UI")
m.description = translate("More convenient management and setup of Tor.")
s = m:section(TypedSection, "torui")
s.anonymous = true
s.addremove = false
-------------------------------------------------------------------------------

-- [TOR CONFIGURATION TAB] ----------------------------------------------------
s:tab("torConfig", translate("Tor configuration"))

torrcStatus = s:taboption("torConfig",DummyValue, "torrcStatus", " ")
torrcStatus.rawhtml = true
function torrcStatus.cfgvalue(self, section)
	return torStatus
end

if torui ~= "" then
	if torServiceStatus ~= "" then
		torrcButtonDisable = s:taboption("torConfig",Button,"Stop"," ")
		torrcButtonDisable.inputtitle=translate("Stop")
		torrcButtonDisable.inputstyle="remove"
		function torrcButtonDisable.write()
			luci.sys.exec("/etc/init.d/tor stop")
			luci.sys.exec("sleep 1")
			luci.sys.exec("/etc/init.d/tor disable")
			luci.sys.exec("sleep 1")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torui"))
		end
	else
		torrcButtonEnable = s:taboption("torConfig",Button,translate("Start")," ")
		torrcButtonEnable.inputtitle=translate("Start")
		torrcButtonEnable.inputstyle="apply"
		function torrcButtonEnable.write()
			luci.sys.exec("/etc/init.d/tor start")
			luci.sys.exec("sleep 1")
			luci.sys.exec("/etc/init.d/tor enable")
			luci.sys.exec("sleep 1")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torui"))
		end
	end

	if nixio.fs.access(torrc) then
		torrcButtonConfig = s:taboption("torConfig",Button,translate("restore default configuration")," ",translate("Modify torrc file to default configuration"))
		torrcButtonConfig.inputtitle=translate("restore default configuration")
		function torrcButtonConfig.write()
			makeTorConfigButtonPressed = true
			nixio.fs.writefile(torrc, torrcSampleConfig)
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torui"))
		end
	end
end

if nixio.fs.access(torrc) then
	torrcConfig = s:taboption("torConfig",TextValue,"torrcConfig",translate("Edit torrc file"))
	torrcConfig.optional = true
	torrcConfig.rmempty=true
	torrcConfig.rows=19
	torrcConfig.wrap = "off"

	function torrcConfig.cfgvalue(self, section)
		if nixio.fs.access(torrc) then
			return nixio.fs.readfile(torrc)
		else
			return "No torrc file."
		end
	end

	function torrcConfig.write(self, section, value)
		if value == nil or value == '' then
		elseif nixio.fs.access(torrc) then
			value = value:gsub("\r\n?", "\n")
			local old_value = nixio.fs.readfile(torrc)
			if value ~= old_value and not makeTorConfigButtonPressed then
				nixio.fs.writefile(torrc, value)
			end
		end
	end

	torrcButtonRestart = s:taboption("torConfig",Button,"Apply & Restart Tor"," ")
	torrcButtonRestart.inputtitle=translate("Apply & Restart Tor")
	torrcButtonRestart.inputstyle="apply"
	function torrcButtonRestart.write()
		luci.sys.exec("/etc/init.d/tor restart")
		luci.sys.exec("sleep 1")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torui"))
	end
end
-------------------------------------------------------------------------------

-- [ LOG TAB] ----------------------------------------------------------------
s:tab("log",translate("Log"))

logsTor = s:taboption("log",TextValue,"logsTor",translate("Tor log"))
logsTor.readonly = "readonly"
logsTor.rmempty=true
logsTor.rows=30
logsTor.wrap = "on"

function logsTor.cfgvalue(self, section)
	return luci.util.exec("/sbin/logread -e Bootstrapped")
end

function logsTor.write(self, section, value)
end
-------------------------------------------------------------------------------

return m
