#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to adjust Mac OS configuration" && exit 0

# dock
defaults write com.apple.dock "orientation" -string "bottom"      # 位置
defaults write com.apple.dock "tilesize" -int "36"                # 大小
defaults write com.apple.dock "autohide" -bool "true"             # 是否自动隐藏
defaults write com.apple.dock "autohide-time-modifier" -float "0" # 自动隐藏动画时间
defaults write com.apple.dock "autohide-delay" -float "0"         # 自动隐藏后打开时间
defaults write com.apple.dock "show-recents" -bool "false"        # 显示最近内容
defaults write com.apple.dock "mineffect" -string "scale"         # 最小化动画效果: genie(default) scale suck
defaults write com.apple.dock "static-only" -bool "true"          # 只显示活动的应用程序
defaults write com.apple.dock "mru-spaces" -bool "false"          # 根据最近使用自动重新排列空间
killall Dock

# 截图
defaults write com.apple.screencapture "disable-shadow" -bool "false"  # 禁用阴影
defaults write com.apple.screencapture "include-date" -bool "true"     # 文件名是否包含日期
defaults write com.apple.screencapture "location" -string "~/Pictures" # 保存文件夹
defaults write com.apple.screencapture "show-thumbnail" -bool "true"   # 截图后显示缩略图
defaults write com.apple.screencapture "type" -string "png"            # 文件格式
killall SystemUIServer

# 访达
defaults write com.apple.finder "QuitMenuItem" -bool "true"                     # 向 Finder 添加退出选项
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"             # 显示扩展名
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"                # 显示隐藏文件
defaults write com.apple.finder "ShowPathbar" -bool "true"                      # 在 Finder 窗口底部显示路径栏
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"           # 默认视图样式: clmv Nlsv glyv icnv
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"              # 将文件夹保留在顶部
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"           # 默认搜索范围 SCcf(当前文件夹)
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"            # 30天后清空垃圾箱
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"  # 更改文件扩展名警告
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false" # 默认保存到磁盘或 iCloud

# 桌面
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"    # 排序时将文件夹保留在顶部
defaults write com.apple.finder "CreateDesktop" -bool "false"                  # 隐藏桌面上的所有图标
defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false"        # 在桌面上显示硬盘
defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "true" # 在桌面上显示外部磁盘
defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "true"     # 显示可移动媒体
defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "false"    # 在桌面上显示连接的服务器
killall Finder

# 反馈
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false" # 提交报告时不要自动收集大文件

# 活动监视器
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "5" # 活动监视器更新其数据的频率（以秒为单位）
defaults write com.apple.ActivityMonitor "IconType" -int "0"     # Dock 只需显示应用程序的常规图标即可
killall 'Activity Monitor' 2>/dev/null

# 各种各样的
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false" # 长时间按住某个键时的行为: 重复该键
defaults write com.apple.LaunchServices "LSQuarantine" -bool "false"   # 关闭“从互联网下载的应用程序”隔离警告