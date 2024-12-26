#!/bin/bash

# ----------------------------------------------------------------
# 脚本描述：
#   自动生成适配 AdGuard Home 的规则文件。
# ----------------------------------------------------------------

set -e  # 遇到错误立即退出
set -o pipefail  # 管道中的任意命令失败则脚本退出

# 主下载链接
main_url="https://raw.githubusercontent.com/Loyalsoldier/surge-rules/release/direct.txt"

# 备用下载链接
backup_url="https://raw.githubusercontent.com/Loyalsoldier/surge-rules/release/direct.txt"

# 下载后的文件保存名称
downloaded_file="china_list.txt"

# 输出文件名称
output_file="adguard_home_rules.txt"

# 固定文本
fixed_text="https://dns64.dns.google/dns-query
https://208.67.222.222/dns-query
https://101.101.101.101/dns-query
tls://1.0.0.1
tls://1.1.1.1
https://doh.applied-privacy.net/query
https://1.0.0.1/dns-query
https://149.112.112.112/dns-query
https://208.67.220.220/dns-query

[/xoyo.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/calatopia.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/kurogames.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/myqcloud.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/wegame.com.cn/]202.100.96.68 218.203.123.116 223.5.5.5
[/xoyocdn.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/cbjq.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/kurogame.xyz/]202.100.96.68 218.203.123.116 223.5.5.5
[/aki-game.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/pcdownload-wangsu.aki-game.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/ali-sh-datareceiver.kurogame.xyz/]202.100.96.68 218.203.123.116 223.5.5.5
[/juequling.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/autopatchcn.juequling.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/epdg.epc.mnc011.mcc460.pub.3gppnetwork.org/]202.100.96.68 218.203.123.116 223.5.5.5
[/ugreengroup.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/sinilink.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/ug.link/]202.100.96.68 218.203.123.116 223.5.5.5
[/fnnas.com/]202.100.96.68 218.203.123.116 223.5.5.5
[/fnos.net/]202.100.96.68 218.203.123.116 223.5.5.5"

# IP 地址数组
ips=("202.100.96.68" "218.203.123.116" "223.5.5.5")

# 下载文件函数
download_file() {
  local url="$1"
  local output="$2"

  echo "正在尝试下载文件: $url ..."
  if curl -L --connect-timeout 30 -o "$output" "$url"; then
    echo -e "\n下载完成！"
    return 0
  else
    echo -e "\n下载失败！"
    return 1
  fi
}

# 处理文件格式化
process_file() {
  local input_file="$1"
  local output_file="$2"
  local ips_arr=("${ips[@]}")

  if [[ ! -f "$input_file" ]]; then
    echo "错误：输入文件 $input_file 不存在。"
    exit 1
  fi

  local total_lines=$(wc -l < "$input_file")
  echo "总行数: $total_lines"

  echo "$fixed_text" > "$output_file"
  echo -e "\n\n" >> "$output_file"

  awk -v ips_str="${ips_arr[*]}" -v total_lines="$total_lines" '
  BEGIN {
      split(ips_str, ips, " ");
  }
  {
      if (substr($0, 1, 1) == ".") $0 = substr($0, 2);
      printf "[/%s/]", $0;
      for (i in ips) printf " %s", ips[i];
      printf "\n";
  }
  END {
      print "\n文件处理完成。" > "/dev/stderr";
  }
  ' "$input_file" >> "$output_file"

  echo "格式化完成，输出保存到 $output_file"
}

# 主流程
# 尝试使用主链接下载文件
if download_file "$main_url" "$downloaded_file"; then
    # 下载成功，开始处理文件
    process_file "$downloaded_file" "$output_file"
else
  # 主链接下载失败，尝试备用链接
  echo "主链接下载失败，正在尝试备用链接..."
  if download_file "$backup_url" "$downloaded_file"; then
    # 备用链接下载成功，开始处理文件
    process_file "$downloaded_file" "$output_file"
  else
    # 备用链接也失败，报错并退出
    echo "备用链接下载也失败，请检查网络连接或 URL。"
    exit 1
  fi
fi

exit 0
