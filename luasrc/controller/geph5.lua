module("luci.controller.geph5", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/geph5") then
        return
    end

    -- 创建菜单：在“服务”下添加“Geph5 Proxy”
    entry({"admin", "services", "geph5"}, cbi("geph5/general"), _("Geph5 Proxy"), 10).dependent = true
    
    -- 创建两个隐藏的接口，用来获取状态和日志
    entry({"admin", "services", "geph5", "status"}, call("act_status")).leaf = true
    entry({"admin", "services", "geph5", "log"}, call("act_log")).leaf = true
end

function act_status()
    local e = {}
    -- 检查是否有 geph5-client 进程在运行
    e.running = luci.sys.call("pgrep -f geph5-client >/dev/null") == 0
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function act_log()
    local log_data = ""
    -- 读取系统日志中包含 geph5 的最后 100 行
    log_data = luci.sys.exec("logread -e 'geph5' -l 100")
    
    luci.http.prepare_content("text/plain")
    luci.http.write(log_data)
end
