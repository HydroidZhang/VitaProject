class_name HotUpdateConfig
extends RefCounted

## 热更开关。开发阶段保持 false；上线前改为 true 并填写 MANIFEST_URL。
const ENABLED := false

## 远程清单地址（JSON）。见 Data/hot_update_manifest.example.json。
const MANIFEST_URL := "https://cdn.example.com/vita/manifest.json"

## 渠道标识，用于 manifest 中按平台筛选资源包。
const CHANNEL := "android"

## 内置 APK 版本号，需与 export_presets.cfg 中 version/code 一致。
const APP_VERSION_CODE := 1

const REQUEST_TIMEOUT_SEC := 20.0
const PATCH_DIR := "user://hot_update/"
const STATE_FILE := "user://hot_update/state.json"
