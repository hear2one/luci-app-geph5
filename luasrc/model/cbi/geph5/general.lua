local m, s, o

-- 页面标题和描述
m = Map("geph5", translate("Geph5 Client"), translate("Geph5 is a modular Internet censorship circumvention system."))

-- 第一部分：运行状态 (我们会引用之后要创建的一个网页模板)
s = m:section(TypedSection, "global", translate("Running Status"))
s.anonymous = true
s.template = "geph5/status"

-- 第二部分：基本设置
s = m:section(TypedSection, "global", translate("Basic Settings"))
s.anonymous = true
s.addremove = false

-- 启用开关
o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

-- 程序路径设置
o = s:option(Value, "binary_path", translate("Binary Path"))
o.default = "/usr/bin/geph5-client"
o.rmempty = false

-- 账号设置
o = s:option(Value, "username", translate("Username"))
o:depends("auth_token", "") -- 如果没填 Token 才显示这个

o = s:option(Value, "password", translate("Password"))
o.password = true
o:depends("auth_token", "") -- 如果没填 Token 才显示这个

-- Token/密钥设置
o = s:option(Value, "auth_token", translate("Or: Auth Token / Key"))
o.description = translate("If you have a direct key instead of user/pass.")

-- 端口设置
o = s:option(Value, "socks5_port", translate("SOCKS5 Port"))
o.datatype = "port"
o.default = 9909

o = s:option(Value, "http_port", translate("HTTP Port"))
o.datatype = "port"
o.default = 9919

-- 第三部分：日志显示 (也会引用之后要创建的一个网页模板)
s = m:section(TypedSection, "global", translate("Log Viewer"))
s.anonymous = true
s.template = "geph5/log"

return m
