extends Node

## 热更管理器：启动时挂载本地 PCK，检查远程清单并下载增量资源包。
## 挂载后 res:// 路径会自动优先读取 PCK 内资源，现有 load() / FileAccess 无需改动。

signal check_started
signal download_progress(pack_id: String, received_bytes: int, total_bytes: int)
signal update_ready(installed_version: int)
signal update_failed(message: String)
signal update_skipped(reason: String)

enum Status {
	IDLE,
	CHECKING,
	DOWNLOADING,
	READY,
	FAILED,
}

var status: Status = Status.IDLE
var last_error: String = ""
var installed_content_version: int = 0

var _ready_future: bool = false
var _http: HTTPRequest
var _state: Dictionary = {}


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = HotUpdateConfig.REQUEST_TIMEOUT_SEC
	add_child(_http)


func ensure_ready() -> void:
	if _ready_future:
		return
	await _run_update_pipeline()
	_ready_future = true


func get_status_text() -> String:
	match status:
		Status.CHECKING:
			return "正在检查更新…"
		Status.DOWNLOADING:
			return "正在下载资源 %d…" % installed_content_version
		Status.FAILED:
			return last_error if not last_error.is_empty() else "更新失败"
		Status.READY:
			return "资源已就绪"
		_:
			return ""


func _run_update_pipeline() -> void:
	_ensure_patch_dir()
	_load_state()
	_mount_saved_packs()

	if not HotUpdateConfig.ENABLED or HotUpdateConfig.MANIFEST_URL.is_empty():
		status = Status.READY
		update_skipped.emit("disabled")
		return

	status = Status.CHECKING
	check_started.emit()

	var manifest := await _fetch_manifest()
	if manifest.is_empty():
		status = Status.READY if last_error.is_empty() else Status.FAILED
		if status == Status.FAILED:
			update_failed.emit(last_error)
		else:
			update_skipped.emit("manifest_unavailable")
		return

	if not _manifest_supports_app(manifest):
		status = Status.READY
		update_skipped.emit("app_too_old")
		return

	var pack_info := _select_pack(manifest)
	if pack_info.is_empty():
		status = Status.READY
		update_skipped.emit("no_pack")
		return

	var remote_version := int(pack_info.get("version", 0))
	if remote_version <= installed_content_version:
		status = Status.READY
		update_skipped.emit("already_latest")
		return

	var downloaded := await _download_pack(pack_info)
	if not downloaded:
		status = Status.FAILED
		update_failed.emit(last_error)
		return

	if not _mount_pack(downloaded.path, bool(pack_info.get("replace", true))):
		status = Status.FAILED
		update_failed.emit(last_error)
		return

	installed_content_version = remote_version
	_save_pack_state(str(pack_info.get("id", "content")), remote_version, downloaded.path)
	_reload_runtime_caches()

	status = Status.READY
	update_ready.emit(installed_content_version)


func _ensure_patch_dir() -> void:
	DirAccess.make_dir_recursive_absolute(HotUpdateConfig.PATCH_DIR)


func _load_state() -> void:
	_state = {"packs": {}}
	if not FileAccess.file_exists(HotUpdateConfig.STATE_FILE):
		return

	var file := FileAccess.open(HotUpdateConfig.STATE_FILE, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		_state = parsed


func _save_state() -> void:
	var file := FileAccess.open(HotUpdateConfig.STATE_FILE, FileAccess.WRITE)
	if file == null:
		push_warning("HotUpdateManager: cannot write state file")
		return
	file.store_string(JSON.stringify(_state, "\t"))


func _save_pack_state(pack_id: String, version: int, path: String) -> void:
	if not _state.has("packs"):
		_state["packs"] = {}
	_state["packs"][pack_id] = {
		"version": version,
		"path": path,
	}
	_save_state()


func _mount_saved_packs() -> void:
	var packs: Variant = _state.get("packs", {})
	if typeof(packs) != TYPE_DICTIONARY:
		return

	for pack_id in packs.keys():
		var entry: Variant = packs[pack_id]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var path := str(entry.get("path", ""))
		var version := int(entry.get("version", 0))
		if path.is_empty() or not FileAccess.file_exists(path):
			continue
		if _mount_pack(path, true):
			installed_content_version = max(installed_content_version, version)


func _fetch_manifest() -> Dictionary:
	last_error = ""
	var result: Array = await _http_request(HotUpdateConfig.MANIFEST_URL, "")
	var response_code: int = result[0]
	var body_text: String = result[2]

	if response_code != 200:
		last_error = "清单请求失败 (%d)" % response_code
		return {}

	var parsed: Variant = JSON.parse_string(body_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "清单格式错误"
		return {}

	return parsed


func _manifest_supports_app(manifest: Dictionary) -> bool:
	var min_version := int(manifest.get("min_app_version", 0))
	return HotUpdateConfig.APP_VERSION_CODE >= min_version


func _select_pack(manifest: Dictionary) -> Dictionary:
	var packs: Variant = manifest.get("packs", [])
	if typeof(packs) != TYPE_ARRAY:
		return {}

	var channel := HotUpdateConfig.CHANNEL
	var best: Dictionary = {}
	var best_version := installed_content_version

	for entry in packs:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pack: Dictionary = entry
		var pack_channel := str(pack.get("channel", ""))
		if not pack_channel.is_empty() and pack_channel != channel:
			continue
		var version := int(pack.get("version", 0))
		if version > best_version:
			best = pack
			best_version = version

	return best


func _download_pack(pack_info: Dictionary) -> Dictionary:
	status = Status.DOWNLOADING
	last_error = ""

	var pack_id := str(pack_info.get("id", "content"))
	var version := int(pack_info.get("version", 0))
	var url := str(pack_info.get("url", ""))
	var expected_sha256 := str(pack_info.get("sha256", "")).to_lower()
	var expected_size := int(pack_info.get("size", 0))

	if url.is_empty():
		last_error = "资源包 URL 为空"
		return {}

	var target_path := "%s%s_v%d.pck" % [HotUpdateConfig.PATCH_DIR, pack_id, version]
	if FileAccess.file_exists(target_path):
		DirAccess.remove_absolute(target_path)

	_http.download_file = target_path
	var progress_handler := Callable(self, "_on_download_progress").bind(pack_id, expected_size)
	if not _http.body_downloaded.is_connected(progress_handler):
		_http.body_downloaded.connect(progress_handler)

	var result: Array = await _http_request(url, "")
	_http.download_file = ""

	if _http.body_downloaded.is_connected(progress_handler):
		_http.body_downloaded.disconnect(progress_handler)

	var response_code: int = result[0]
	if response_code != 200:
		last_error = "资源包下载失败 (%d)" % response_code
		if FileAccess.file_exists(target_path):
			DirAccess.remove_absolute(target_path)
		return {}

	if expected_size > 0:
		var size_file := FileAccess.open(target_path, FileAccess.READ)
		if size_file == null or size_file.get_length() != expected_size:
			last_error = "资源包大小校验失败"
			DirAccess.remove_absolute(target_path)
			return {}

	if not expected_sha256.is_empty():
		var actual_sha256 := _file_sha256(target_path)
		if actual_sha256 != expected_sha256:
			last_error = "资源包校验失败"
			DirAccess.remove_absolute(target_path)
			return {}

	return {"path": target_path, "version": version}


func _on_download_progress(
	pack_id: String,
	total_bytes: int,
	received_bytes: int,
) -> void:
	download_progress.emit(pack_id, received_bytes, total_bytes)


func _mount_pack(path: String, replace_files: bool) -> bool:
	if not FileAccess.file_exists(path):
		last_error = "PCK 文件不存在: %s" % path
		return false

	var loaded := ProjectSettings.load_resource_pack(path, replace_files)
	if not loaded:
		last_error = "挂载 PCK 失败: %s" % path
		return false
	return true


func _http_request(url: String, body: String) -> Array:
	var headers: PackedStringArray = PackedStringArray()
	if not body.is_empty():
		headers.append("Content-Type: application/json")

	var method := HTTPClient.METHOD_POST if not body.is_empty() else HTTPClient.METHOD_GET
	var err := _http.request(url, headers, method, body)
	if err != OK:
		return [0, [], "request error %d" % err]

	var args: Array = await _http.request_completed
	return args


func _file_sha256(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""

	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)

	while file.get_position() < file.get_length():
		var chunk := file.get_buffer(65536)
		if chunk.is_empty():
			break
		ctx.update(chunk)

	return ctx.finish().hex_encode()


func _reload_runtime_caches() -> void:
	TileTextureAtlas.clear_cache()
