import 'package:dio_http_cache/src/core/cache_obj.dart';
import 'package:hive/hive.dart';

import 'store_impl.dart';

class StoreHive extends ICacheStore {
  static final String storeName = "http_cache";

  StoreHive();

  /// control hive box external
  Box<CacheObj>? _getBox() {
    if (Hive.isBoxOpen(storeName)) {
      return Hive.box<CacheObj>(storeName);
    }

    return null;
  }

  @override
  Future<bool> clearAll() async {
    var box = _getBox();
    box?.clear();

    return true;
  }

  @override
  Future<bool> clearExpired() async {
    var box = _getBox();
    if (box == null) {
      return true;
    }

    var now = DateTime.now().millisecondsSinceEpoch;
    for (var i = box.length - 1; i >= 0; i--) {
      var obj = box.getAt(i)!;
      if (obj.maxStaleDate! > 0 && obj.maxStaleDate! < now ||
          obj.maxStaleDate! <= 0 && obj.maxAgeDate! < now) {
        await box.deleteAt(i);
      }
    }

    return true;
  }

  @override
  Future<bool> delete(String key, {String? subKey}) async {
    var box = _getBox();
    if (box == null) {
      return true;
    }

    String objKey = "${key}_$subKey";
    await box.delete(objKey);

    return true;
  }

  @override
  Future<CacheObj?> getCacheObj(String key, {String? subKey = ""}) async {
    var box = _getBox();
    if (box == null) {
      return null;
    }

    String objKey = "${key}_$subKey";
    var cacheObj = box.get(objKey);
    return cacheObj;
  }

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    var box = _getBox();
    if (box == null) {
      return true;
    }

    String objKey = "${obj.key}_${obj.subKey}";
    await box.put(objKey, obj);

    return true;
  }
}
