local m, s, o

m = Map("geph5", translate("Geph5 Client"), translate("Geph5 is a modular Internet censorship circumvention system."))

-- 【修正】这里改成了 geph5
s = m:section(TypedSection, "geph5", translate("Running Status"))
s.anonymous = true
s.template = "geph5/status"

-- 【修正】这里改成了 geph5
s = m:section(TypedSection, "geph5", translate("Basic Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

o = s:option(Value, "binary_path", translate("Binary Path"))
o.default = "/usr/bin/geph5-client"
o.rmempty = false

o = s:option(Value, "username", translate("Username"))
o:depends("auth_token", "") 

o = s:option(Value, "password", translate("Password"))
o.password = true
o:depends("auth_token", "")

o = s:option(Value, "auth_token", translate("Or: Auth Token / Key"))
o.description = translate("If you have a direct key instead of user/pass.")

o = s:option(Value, "socks5_port", translate("SOCKS5 Port"))
o.datatype = "port"
o.default = 9909

o = s:option(Value, "http_port", translate("HTTP Port"))
o.datatype = "port"
o.default = 9919

-- 【修正】这里改成了 geph5
s = m:section(TypedSection, "geph5", translate("Log Viewer"))
s.anonymous = true
s.template = "geph5/log"

return m
