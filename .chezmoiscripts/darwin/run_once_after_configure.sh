#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to adjust Mac OS configuration" && exit 0

# https://github.com/mathiasbynens/dotfiles/blob/main/.macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# 隐藏顶部bar
osascript -e '
tell application "System Events"
		set autohide menu bar of dock preferences to true
end tell
'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# 打开减少动画
defaults write com.apple.universalaccess reduceMotion -int 1

# 输入法自动调整
defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput 1

# 短按大写锁定切换输入法
defaults write com.apple.HIToolbox AppleCapsLockPressAndHoldToggleOff -int 0

# 小鹤双拼方案
defaults write com.apple.inputmethod.CoreChineseEngineFramework shuangpinLayout -int 4

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Adjust toolbar title rollover delay
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable Notification Center and remove the menu bar icon
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code 自动破折号
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code 自动句号
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code 自动引号
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom right corner to right-click
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Disable “natural” (Lion-style) scrolling
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 10

###############################################################################
# Energy saving                                                               #
###############################################################################

# pmset -a：调整任何条件下的睡眠计划
# pmset -c：调整外部供电的睡眠计划
# pmset -b：调整电池供电的睡眠计划
# pmset -g：查看计划

sudo pmset -a displaysleep 10 disksleep 15 sleep 30 womp 1

if sysctl -n hw.model | grep Book; then
  echo 'Detected mac laptop'
else
  echo 'Detected mac desktop'
  sudo pmset -a tcpkeepalive 1 autopoweroff 0 standby 0 hibernatemode 0
fi

# pmset repeat cancel
# sudo pmset repeat <type> <week> 10:00:00
# type: sleep wake poweron shutdown wakepoweron
# week: MTWRFSU

# Restart automatically if the computer freezes
# sudo systemsetup -setrestartfreeze on

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable subpixel font rendering on non-Apple LCDs
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Minimize windows into their application’s icon
# defaults write com.apple.dock minimize-to-application -bool true

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use
# the Dock to launch apps.
# defaults write com.apple.dock persistent-apps -array

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Add iOS & Watch Simulator to Launchpad
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

# 屏幕边角快捷方式
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# modifier:
# shift: 131072 Control: 262144 option: 524288 cmd: 1048576
# Top left screen corner
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 1048576
# Top right screen corner
defaults write com.apple.dock wvous-tr-corner -int 10
defaults write com.apple.dock wvous-tr-modifier -int 1048576
# Bottom left screen corner
defaults write com.apple.dock wvous-bl-corner -int 11
defaults write com.apple.dock wvous-bl-modifier -int 1048576
# Bottom right screen corner
defaults write com.apple.dock wvous-br-corner -int 14 # 默认值：快速备忘录

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Auto-play videos when opened with QuickTime Player
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Disable the all too sensitive backswipe on trackpads
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# Disable the all too sensitive backswipe on Magic Mouse
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

# Use the system-native print preview dialog
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

# -------------------------------------------------------------------

# https://macos-defaults.com/

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

# 截图
defaults write com.apple.screencapture "disable-shadow" -bool "false"  # 禁用阴影
defaults write com.apple.screencapture "include-date" -bool "true"     # 文件名是否包含日期
defaults write com.apple.screencapture "location" -string "~/Pictures" # 保存文件夹
defaults write com.apple.screencapture "show-thumbnail" -bool "true"   # 截图后显示缩略图
defaults write com.apple.screencapture "type" -string "png"            # 文件格式

# 访达
defaults write com.apple.finder "QuitMenuItem" -bool "true"                     # 向 Finder 添加退出选项
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"             # 显示扩展名
defaults write com.apple.finder "AppleShowAllFiles" -bool "false"               # 显示隐藏文件
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

# 反馈
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false" # 提交报告时不要自动收集大文件

# 活动监视器
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "5" # 活动监视器更新其数据的频率（以秒为单位）
defaults write com.apple.ActivityMonitor "IconType" -int "0"     # Dock 只需显示应用程序的常规图标即可

# 各种各样的
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "true" # 长时间按住某个键时的行为: 重复该键
defaults delete -g ApplePressAndHoldEnabled

defaults write com.apple.LaunchServices "LSQuarantine" -bool "false" # 关闭“从互联网下载的应用程序”隔离警告

echo "Done. Note that some of these changes require a logout/restart to take effect."

! confirm "Confirm to kill affected applications(including chrome...)" && exit 0

for app in "Activity Monitor" \
  "Address Book" \
  "Calendar" \
  "cfprefsd" \
  "Contacts" \
  "Dock" \
  "Finder" \
  "Google Chrome Canary" \
  "Google Chrome" \
  "Mail" \
  "Messages" \
  "Opera" \
  "Photos" \
  "Safari" \
  "SizeUp" \
  "Spectacle" \
  "SystemUIServer" \
  "Terminal" \
  "Transmission" \
  "Tweetbot" \
  "Twitter" \
  "iCal"; do
  killall "${app}" &>/dev/null
done

exit 0