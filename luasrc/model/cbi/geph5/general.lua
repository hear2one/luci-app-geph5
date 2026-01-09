local m, s, o

m = Map("geph5", translate("Geph5 Client"), translate("Geph5 Client - Embedded Mode"))

-- 1. 运行状态
s = m:section(TypedSection, "geph5", translate("Running Status"))
s.anonymous = true
s.template = "geph5/status"

-- 2. 核心设置
s = m:section(TypedSection, "geph5", translate("Core Settings"))
s.anonymous = true
s.addremove = false

-- 启用
o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

-- 二进制路径
o = s:option(Value, "binary_path", translate("Binary Path"))
o.default = "/usr/bin/geph5-client"
o.rmempty = false

-- 密钥输入框
o = s:option(Value, "auth_token", translate("Auth Token / Secret"))
o.password = true
o.description = translate("Enter your 24-digit secret key here.")

-- 端口设置
o = s:option(Value, "socks5_port", translate("SOCKS5 Port"))
o.datatype = "port"
o.default = 9909

o = s:option(Value, "http_port", translate("HTTP Port"))
o.datatype = "port"
o.default = 9919

-- 3. 日志
s = m:section(TypedSection, "geph5", translate("Log Viewer"))
s.anonymous = true
s.template = "geph5/log"

return m
