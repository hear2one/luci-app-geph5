# luci-app-geph5

适用于 ImmortalWrt 25.12.0+ 的 Geph5 客户端管理界面，主要支持 `x86/64`。界面默认使用简体中文，基于现代 LuCI JavaScript/ucode 架构，不依赖旧版 Lua CBI。

## 功能

- 通过 LuCI 上传并安装 Linux x86_64 `geph5-client` 可执行文件。
- 上传文件大小、ELF 架构及运行兼容性检查。
- 原子替换 `/usr/bin/geph5-client`，自动设置 `0755` 权限。
- 使用 UCI 管理认证密钥、监听地址、代理端口及过滤选项。
- 自动生成权限为 `0600` 的 `/var/etc/geph5.yaml`。
- 使用 procd 管理启动、停止、重启、开机自启及异常重启。
- 显示运行状态、客户端大小、SHA-256 和系统日志。
- 默认仅监听回环地址：SOCKS5 `127.0.0.1:9909`，HTTP `127.0.0.1:9910`。

项目不包含 Geph5 客户端二进制文件。安装 LuCI 应用后，请在“服务 → Geph5 代理”中上传官方发布或自行编译的 Linux x86_64 客户端。

## GitHub Actions 自动编译

推送代码、创建 Pull Request 或手动运行工作流时，`.github/workflows/build.yml` 会：

1. 下载并校验官方 ImmortalWrt 25.12.0 x86/64 SDK；
2. 安装所需 LuCI feeds；
3. 编译 `luci-app-geph5`；
4. 上传生成的 `.apk` 到该次 Actions 运行的 Artifacts。

进入仓库的 **Actions → Build ImmortalWrt package**，打开成功的运行记录即可下载 APK。

## 本地编译

先在官方 ImmortalWrt 25.12.0 x86/64 SDK 中准备 feeds：

```sh
./scripts/feeds update -a
./scripts/feeds install luci-base
./scripts/feeds install ca-certificates
```

然后把本仓库放入 SDK 的 `package/luci-app-geph5`，执行：

```sh
echo 'CONFIG_PACKAGE_luci-app-geph5=m' > .config
make defconfig
make package/luci-app-geph5/compile V=s -j"$(nproc)"
```

ImmortalWrt 25.12 使用 APK 包格式，产物位于 SDK 的 `bin/packages/x86_64/base/`。

## 安装与升级

```sh
apk add --allow-untrusted --upgrade luci-app-geph5-*.apk
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

安装后，浏览器如仍显示旧页面，请执行强制刷新。

## 运行文件

- UCI 配置：`/etc/config/geph5`
- 运行配置：`/var/etc/geph5.yaml`
- 客户端：`/usr/bin/geph5-client`
- 临时上传文件：`/tmp/geph5-client.upload`
- 服务脚本：`/etc/init.d/geph5`

## 上游兼容性

配置格式依据 [geph-official/geph5](https://github.com/geph-official/geph5) 的公开 `Config` 类型和 `-c/--config` 参数生成，已核对的提交记录在 `UPSTREAM_VERSION`。

每周 Actions 会运行一次兼容性检查。也可手动执行：

```sh
./scripts/check-upstream-compat.sh
```

或者指定已有的上游源码目录：

```sh
./scripts/check-upstream-compat.sh /path/to/geph5
```

## 安全说明

- 认证密钥不会通过 rpcd 文件读取接口暴露。
- 运行配置使用 `0600` 权限保存。
- 上传文件限制为 128 MiB，并必须通过 x86_64 ELF 与运行兼容性检查。
- 除非已经配置防火墙和访问控制，否则不要把监听地址改为 `0.0.0.0` 或其他局域网地址。
