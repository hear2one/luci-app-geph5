'use strict';
'require view';
'require form';
'require fs';
'require ui';
'require poll';

const ACTION = '/usr/libexec/geph5-action';

return view.extend({
	runAction: function(action) {
		return fs.exec(ACTION, [ action ]).then(function(res) {
			if (res.code !== 0)
				throw new Error((res.stderr || res.stdout || _('未知错误')).trim());
			return res.stdout || '';
		});
	},

	getStatus: function() {
		return this.runAction('status').then(function(output) {
			try {
				return JSON.parse(output);
			}
			catch (e) {
				return { installed: false, running: false, path: '/usr/bin/geph5-client' };
			}
		});
	},

	getLog: function() {
		return this.runAction('log').catch(function() { return ''; });
	},

	load: function() {
		return Promise.all([ this.getStatus(), this.getLog() ]);
	},

	updateStatusNodes: function(status) {
		const state = document.getElementById('geph5-service-state');
		const binary = document.getElementById('geph5-binary-state');
		const hash = document.getElementById('geph5-binary-hash');

		if (state) {
			state.textContent = status.running ? _('运行中') : _('已停止');
			state.style.color = status.running ? 'green' : 'red';
		}
		if (binary) {
			binary.textContent = status.installed
				? _('已安装：%s（%s 字节）').format(status.path, status.size || 0)
				: _('未安装');
			binary.style.color = status.installed ? 'green' : 'red';
		}
		if (hash)
			hash.textContent = status.sha256 || '-';
	},

	handleService: function(action) {
		return this.runAction(action).then(L.bind(function(output) {
			this.updateStatusNodes(JSON.parse(output));
			ui.addNotification(null, E('p', [ _('服务操作已完成。') ]), 'info');
		}, this)).catch(function(err) {
			ui.addNotification(null, E('p', [ err.message ]), 'error');
		});
	},

	handleUpload: function() {
		return ui.uploadFile('/tmp/geph5-client.upload').then(L.bind(function() {
			return this.runAction('install-upload');
		}, this)).then(L.bind(function(output) {
			this.updateStatusNodes(JSON.parse(output));
			ui.addNotification(null, E('p', [ _('geph5-client 安装成功。') ]), 'info');
		}, this)).catch(function(err) {
			ui.addNotification(null, E('p', [ _('上传失败：%s').format(err.message) ]), 'error');
		});
	},

	handleLogRefresh: function() {
		return this.getLog().then(function(output) {
			const area = document.getElementById('geph5-log');
			if (area) {
				area.value = output || _('没有找到 Geph5 日志。');
				area.scrollTop = area.scrollHeight;
			}
		});
	},

	renderStatus: function(status) {
		return E('div', { 'class': 'cbi-section' }, [
			E('h3', {}, [ _('运行状态') ]),
			E('p', {}, [ E('strong', {}, [ _('服务状态：') ]), E('span', {
				'id': 'geph5-service-state',
				'style': 'color:%s'.format(status.running ? 'green' : 'red')
			}, [ status.running ? _('运行中') : _('已停止') ]) ]),
			E('p', {}, [ E('strong', {}, [ _('客户端程序：') ]), E('span', {
				'id': 'geph5-binary-state',
				'style': 'color:%s'.format(status.installed ? 'green' : 'red')
			}, [ status.installed ? _('已安装：%s（%s 字节）').format(status.path, status.size || 0) : _('未安装') ]) ]),
			E('p', {}, [ E('strong', {}, [ _('SHA-256：') ]), E('code', { 'id': 'geph5-binary-hash' }, [ status.sha256 || '-' ]) ]),
			E('div', { 'class': 'right' }, [
				E('button', { 'class': 'cbi-button cbi-button-action', 'click': ui.createHandlerFn(this, 'handleService', 'start') }, [ _('启动') ]),
				' ',
				E('button', { 'class': 'cbi-button cbi-button-action', 'click': ui.createHandlerFn(this, 'handleService', 'stop') }, [ _('停止') ]),
				' ',
				E('button', { 'class': 'cbi-button cbi-button-reload', 'click': ui.createHandlerFn(this, 'handleService', 'restart') }, [ _('重启') ])
			])
		]);
	},

	renderUpload: function() {
		return E('div', { 'class': 'cbi-section' }, [
			E('h3', {}, [ _('安装 geph5-client') ]),
			E('p', {}, [
				_('请上传官方发布或自行编译的 Linux x86_64 geph5-client ELF 可执行文件。系统会校验文件，并将其安装到 /usr/bin/geph5-client，权限设为 0755。')
			]),
			E('button', {
				'class': 'cbi-button cbi-button-positive important',
				'click': ui.createHandlerFn(this, 'handleUpload')
			}, [ _('上传并安装…') ])
		]);
	},

	renderLog: function(log) {
		return E('div', { 'class': 'cbi-section' }, [
			E('h3', {}, [ _('系统日志') ]),
			E('div', { 'class': 'right', 'style': 'margin-bottom:8px' }, [
				E('button', { 'class': 'cbi-button', 'click': ui.createHandlerFn(this, 'handleLogRefresh') }, [ _('刷新') ])
			]),
			E('textarea', {
				'id': 'geph5-log',
				'readonly': 'readonly',
				'wrap': 'off',
				'style': 'width:100%;height:300px;font-family:monospace'
			}, [ log || _('没有找到 Geph5 日志。') ])
		]);
	},

	render: function(data) {
		const status = data[0];
		const log = data[1];
		let m, s, o;

		m = new form.Map('geph5', _('Geph5 客户端'),
			_('适用于 ImmortalWrt/OpenWrt 的 Geph5 本地代理服务。系统会根据以下设置自动生成运行配置。'));

		s = m.section(form.NamedSection, 'geph5', 'geph5', _('基本设置'));
		s.addremove = false;

		o = s.option(form.Flag, 'enabled', _('启用服务'));
		o.rmempty = false;

		o = s.option(form.Value, 'binary_path', _('客户端路径'));
		o.default = '/usr/bin/geph5-client';
		o.rmempty = false;

		o = s.option(form.Value, 'auth_token', _('认证令牌／密钥'));
		o.password = true;
		o.rmempty = true;
		o.validate = function(sectionId, value) {
			return (!value || /^\d{24}$/.test(value)) ? true : _('密钥必须恰好包含 24 位数字。');
		};

		o = s.option(form.Value, 'bind_address', _('监听地址'));
		o.datatype = 'ipaddr';
		o.default = '127.0.0.1';
		o.rmempty = false;
		o.description = _('除非需要让局域网设备直接连接，否则请保持 127.0.0.1。将未认证的代理暴露到局域网存在安全风险。');

		o = s.option(form.Value, 'socks5_port', _('SOCKS5 端口'));
		o.datatype = 'port';
		o.default = '9909';
		o.rmempty = false;

		o = s.option(form.Value, 'http_port', _('HTTP 代理端口'));
		o.datatype = 'port';
		o.default = '9910';
		o.rmempty = false;

		s = m.section(form.NamedSection, 'geph5', 'geph5', _('高级设置'));
		s.addremove = false;

		o = s.option(form.Flag, 'allow_direct', _('允许直连路由'));
		o.default = '0';

		o = s.option(form.Flag, 'passthrough_china', _('中国大陆流量直连'));
		o.default = '0';

		o = s.option(form.Flag, 'spoof_dns', _('启用 DNS 伪装'));
		o.default = '0';

		o = s.option(form.Flag, 'filter_ads', _('过滤广告'));
		o.default = '1';

		o = s.option(form.Flag, 'filter_nsfw', _('过滤成人内容'));
		o.default = '0';

		o = s.option(form.Value, 'task_limit', _('任务数量限制'));
		o.datatype = 'uinteger';
		o.rmempty = true;
		o.placeholder = _('自动');

		poll.add(L.bind(function() {
			return this.getStatus().then(L.bind(this.updateStatusNodes, this));
		}, this), 5);

		return m.render().then(L.bind(function(formNode) {
			return E([], [
				E('h2', {}, [ _('Geph5 客户端') ]),
				this.renderStatus(status),
				this.renderUpload(),
				formNode,
				this.renderLog(log),
				E('p', { 'class': 'alert-message notice' }, [
					_('配置格式已与上游 geph-official/geph5 同步。项目地址：'),
					E('a', { 'href': 'https://github.com/geph-official/geph5', 'target': '_blank', 'rel': 'noreferrer' }, [ 'GitHub' ])
				])
			]);
		}, this));
	}
});
