#!/usr/bin/env bash
# am start com.phicomm.speaker.device/.ui.MainActivity
#
# am force-stop com.phicomm.speaker.device

adb connect 192.168.2.8

stop_pkg() {
  local pkgs=(
    com.phicomm.speaker.launcher
    com.phicomm.speaker.productiontest
    com.phicomm.speaker.bugreport
    com.phicomm.speaker.otaservice
    com.phicomm.speaker.player
    com.phicomm.speaker.device
  )

  for pkg in "${pkgs[@]}"; do
    adb shell am force-stop hide "$pkg"
  done

  adb shell /system/bin/pm hide com.phicomm.speaker.device # 隐藏开机音；无法通过顶部按钮打开蓝牙
  # adb shell /system/bin/pm unhide com.phicomm.speaker.device
  # adb shell am start com.phicomm.speaker.device/.ui.MainActivity
}

disable_all() {
  local pkgs=(
    com.phicomm.speaker.airskill
    com.phicomm.speaker.player
    com.phicomm.speaker.exceptionreporter
    com.phicomm.speaker.ijetty
    com.android.keychain
    com.phicomm.speaker.netctl
    com.phicomm.speaker.otaservice
    com.phicomm.speaker.systemtool
    com.phicomm.speaker.device
    com.android.providers.downloads
    com.android.location.fused
    com.android.inputdevices
    com.android.server.telecom
    com.android.providers.telephony
    com.android.vpndialogs
    com.phicomm.speaker.productiontest
    com.phicomm.speaker.bugreport
    com.droidlogic.mediacenter
  )

  for pkg in "${pkgs[@]}"; do
    adb shell /system/bin/pm hide "$pkg"
  done
  # adb shell /system/bin/pm uninstally com.droidlogic.mediacenter
}

install_apk() {
  adb shell settings put secure install_non_market_apps 1
  adb push dlna.apk /mnt/internal_sd/
  adb shell /system/bin/pm install -r /mnt/internal_sd/dlna.apk
  adb shell rm /mnt/internal_sd/dlna.apk
  adb shell am start -n com.droidlogic.mediacenter/.MediaCenterActivity
}

configure_wifi() {
  curl 'http://192.168.43.1:8989/api/configwifi' --data-raw '{"ssid":"asdasd","secure":"WPA","password":"asdasdasdasdasdasd"}'
}

get_device_info() {
  adb shell getprop
}

# stop_pkg
disable_all
