#!/bin/bash

# ----------------------------------------------------------------
# 脚本描述：
#   自动生成适配 AdGuard Home 的规则文件。
# ----------------------------------------------------------------

# 主下载链接
main_url="https://gh.acg2.icu/https://raw.githubusercontent.com/Loyalsoldier/surge-rules/release/direct.txt"

# 备用下载链接
backup_url="https://raw.githubusercontent.com/Loyalsoldier/surge-rules/release/direct.txt"

# 下载后的文件保存名称
downloaded_file="china_list.txt"

# 输出文件名称（位于 GitHub 仓库的根目录）
output_file="./adguard_home_rules.txt"

# 固定文本：DNS 服务器和一些域名映射
fixed_text="tls://AdGuard-6f2fc3.dns.nextdns.io
https://dns64.dns.google/dns-query
https://208.67.222.222/dns-query
https://101.101.101.101/dns-query
tls://1.0.0.1
tls://1.1.1.1
https://doh.applied-privacy.net/query
https://1.0.0.1/dns-query
https://149.112.112.112/dns-query
https://208.67.220.220/dns-query

[/xoyo.com/]61.139.2.69
[/calatopia.com/]61.139.2.69
[/kurogames.com/]61.139.2.69
[/myqcloud.com/]61.139.2.69
[/wegame.com.cn/]61.139.2.69
[/xoyocdn.com/]61.139.2.69"

# 定义 IP 地址数组
ips=("61.139.2.69" "218.6.200.139" "223.5.5.5")

# ----------------------------------------------------------------
# 函数定义：下载文件
# ----------------------------------------------------------------
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

# ----------------------------------------------------------------
# 函数定义：处理文件格式化
# ----------------------------------------------------------------
process_file() {
  local input_file="$1"
  local output_file="$2"
  local ips_arr=("${ips[@]}")

  # 确保输入文件存在
  if [[ ! -f "$input_file" ]]; then
    echo "错误：输入文件 $input_file 不存在。"
    exit 1
  fi

  # 获取总行数
  local total_lines=$(wc -l < "$input_file")
  echo "总行数: $total_lines"

  # 将固定文本写入输出文件
  echo "$fixed_text" > "$output_file"
  echo -e "\n\n" >> "$output_file" # 追加两个换行符

  # 使用 awk 处理文件
  awk -v ips_str="${ips_arr[*]}" -v total_lines="$total_lines" '
  BEGIN {
      processed_lines = 0;
      split(ips_str,ips," ");
  }
  {
      if (substr($0, 1, 1) == ".") {
          $0 = substr($0, 2);
      }
      printf "[/%s/]", $0;
      for (i = 1; i <= length(ips); i++) {
        printf " %s", ips[i];
      }
      printf "\n";

      processed_lines++;
      progress = int(processed_lines / total_lines * 100);
      if (processed_lines % 100 == 0) {
          printf "文件处理进度: %d%% (%d/%d)\r", progress, processed_lines, total_lines > "/dev/stderr";
      }
  }
  END {
     print "\n文件处理完成。" > "/dev/stderr";
  }
  ' "$input_file" >> "$output_file"

  echo "格式化完成，输出保存到 $output_file"
}

# ----------------------------------------------------------------
# 主流程
# ----------------------------------------------------------------

# 尝试使用主链接下载文件
if download_file "$main_url" "$downloaded_file"; then
    process_file "$downloaded_file" "$output_file"
else
    echo "主链接下载失败，正在尝试备用链接..."
    if download_file "$backup_url" "$downloaded_file"; then
        process_file "$downloaded_file" "$output_file"
    else
        echo "备用链接下载也失败，请检查网络连接或 URL。"
        exit 1
    fi
fi

# 检查输出文件是否存在
if [[ ! -f "$output_file" ]]; then
  echo "错误：生成的规则文件 $output_file 不存在。"
  exit 1
fi

exit 0
