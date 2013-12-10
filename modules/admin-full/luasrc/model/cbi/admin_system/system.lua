--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.sys.zoneinfo")
require("luci.tools.webadmin")
require("luci.fs")
require("luci.config")

local m, s, o
local has_ntpd = luci.fs.access("/usr/sbin/ntpd")

m = Map("system", translate("System"), translate("Here you can configure the basic aspects of your device like its hostname or the timezone."))
m:chain("luci")


s = m:section(TypedSection, "system", translate("System Properties"))
s.anonymous = true
s.addremove = false

s:tab("general",  translate("General Settings"))
s:tab("language", translate("Language"))


--
-- System Properties
--

o = s:taboption("general", DummyValue, "_systime", translate("Local Time"))
o.template = "admin_system/clock_status"


o = s:taboption("general", Value, "hostname", translate("Hostname"))
o.datatype = "hostname"

function o.write(self, section, value)
	Value.write(self, section, value)
	luci.sys.hostname(value)
end


o = s:taboption("general", ListValue, "zonename", translate("Timezone"))
o:value("UTC")

for i, zone in ipairs(luci.sys.zoneinfo.TZ) do
	o:value(zone[1])
end

function o.write(self, section, value)
	local function lookup_zone(title)
		for _, zone in ipairs(luci.sys.zoneinfo.TZ) do
			if zone[1] == title then return zone[2] end
		end
	end

	AbstractValue.write(self, section, value)
	local timezone = lookup_zone(value) or "GMT0"
	self.map.uci:set("system", section, "timezone", timezone)
	luci.fs.writefile("/etc/TZ", timezone .. "\n")
end


--
-- Langauge & Style
--

o = s:taboption("language", ListValue, "_lang", translate("Language"))
o:value("auto")

local i18ndir = luci.i18n.i18ndir .. "base."
for k, v in luci.util.kspairs(luci.config.languages) do
	local file = i18ndir .. k:gsub("_", "-")
	if k:sub(1, 1) ~= "." and luci.fs.access(file .. ".lmo") then
		o:value(k, v)
	end
end

function o.cfgvalue(...)
	return m.uci:get("luci", "main", "lang")
end

function o.write(self, section, value)
	m.uci:set("luci", "main", "lang", value)
end

--[[
o = s:taboption("language", ListValue, "_mediaurlbase", translate("Design"))
for k, v in pairs(luci.config.themes) do
	if k:sub(1, 1) ~= "." then
		o:value(v, k)
	end
end

function o.cfgvalue(...)
	return m.uci:get("luci", "main", "mediaurlbase")
end

function o.write(self, section, value)
	m.uci:set("luci", "main", "mediaurlbase", value)
end
]]--

return m
