name: Generate AdGuard Home Rules

on:
  schedule:
    - cron: "0 2 * * *" # 每天凌晨 2 点运行
  workflow_dispatch: # 手动触发工作流

jobs:
  generate-rules:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up Bash shell
      run: sudo apt-get update && sudo apt-get install -y curl

    - name: Run the script
      run: |
        chmod +x generate_adguard_rules.sh
        ./generate_adguard_rules.sh

    - name: Commit and push changes
      run: |
        git config --global user.name "GitHub Actions Bot"
        git config --global user.email "actions@github.com"
        git add adguard_home_rules.txt
        git commit -m "Update AdGuard Home rules"
        git push
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
