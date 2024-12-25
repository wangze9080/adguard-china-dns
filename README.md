# AdGuard Home 规则自动生成脚本

此仓库提供一个自动生成适配 **AdGuard Home** 的规则文件的脚本。脚本会根据下载的域名列表生成适合的规则，并将其格式化输出。规则根据域名的类型将使用不同的 DNS 服务器配置。

## 功能描述

- **大陆域名**使用国内 DNS，默认使用四川电信 DNS 和阿里 DNS。
- **其他域名**使用境外 DNS。
- 下载域名列表并根据域名后缀生成规则文件。
- 生成的规则文件可直接应用于 **AdGuard Home**。

## 域名规则来源

域名规则来自 [Loyalsoldier/surge-rules](https://github.com/Loyalsoldier/surge-rules) 仓库中的直连域名列表 `direct.txt`。该文件包含了常见的需要直连的域名，将根据这些域名生成适配的 **AdGuard Home** 规则。

## 默认 DNS 配置

- **大陆域名**默认使用以下 DNS 服务器：
  - 四川电信 DNS：`61.139.2.69`, `218.6.200.139`
  - 阿里 DNS：`223.5.5.5`

- **其他域名**使用以下境外 DNS：
  - Google DNS：`https://dns64.dns.google/dns-query`
  - OpenDNS：`https://208.67.222.222/dns-query`
  - Quad101（TWNIC 提供）：`https://101.101.101.101/dns-query`
  - Cloudflare DNS：`tls://1.0.0.1`, `tls://1.1.1.1`
  - Applied Privacy DNS：`https://doh.applied-privacy.net/query`
  - Quad9 DNS：`https://149.112.112.112/dns-query`
  - OpenDNS 备用：`https://208.67.220.220/dns-query`

## 注意事项

- 确保脚本所需的网络环境正常，能够成功下载域名列表。
- 国内 DNS 和境外 DNS 的配置可以根据需要进行修改，脚本默认使用四川电信 DNS 和阿里 DNS。
- 规则生成后会保存为 `adguard_home_rules.txt` 文件，在AdGuard Home 配置文件里配置好txt文件路径，AdGuard Home会自动识别并应用这些规则。

## 许可协议

本项目采用 [GPLv3 许可证](LICENSE)。
