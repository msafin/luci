m = Map("scan",translate(""),translate(""))
s = m:section(TypedSection,"setting",translate("Scan Configuration"))
s.anonymous=true
s:option(Value,"deviceID",translate("Device ID"))
s:option(Value,"server",translate("Server Url"))
s:option(Value,"updateInterval",translate("Update Interval"))
s:option(Value,"sendInterval",translate("Send Interval"))
s:option(Value,"scanRange",translate("Scan Range"))

m:section(SimpleSection).template = "admin_network/scan"

return m


