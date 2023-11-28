package haxe.ui.loaders.image;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;
import haxe.ui.util.Variant;

using StringTools;

class ImageLoader {
    private static var _instance:ImageLoader;
    public static var instance(get, null):ImageLoader;
    private static function get_instance():ImageLoader {
        if (_instance == null) {
            _instance = new ImageLoader();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private function new() {
    }

    private var _registeredLoaders:Map<String, ImageLoaderInfo> = new Map<String, ImageLoaderInfo>();
    private var _defaultLoader:ImageLoaderInfo = null;
    public function load(resource:Variant, callback:ImageInfo->Void, useCache:Bool = true) {
        if (resource.isString) {
            var stringResource:String = resource;
            if (stringResource == "null") {
                callback(null);
                return;
            }
            if (useCache == true) {
                var cachedImage = ToolkitAssets.instance.getCachedImage(stringResource);
                if (cachedImage != null) {
                    callback(cachedImage);
                    return;
                }
            }

            stringResource = StringTools.trim(stringResource);
            var prefix = "";
            var n = stringResource.indexOf("://");
            if (n != -1) {
                prefix = stringResource.substring(0, n);
            }

            var loader = get(prefix, stringResource);
            if (loader == null) {
                trace("WARNING: no image loader could be found for '" + prefix + "'");
                callback(null);
                return;
            }

            loader.load(resource, function(imageInfo) {
                if (callback != null) {
                    if (imageInfo != null) {
                        imageInfo.loader = loader;
                    }
                    callback(imageInfo);
                }
            });
        } else if (resource.isImageData) {
            var imageData:ImageData = resource;
            if (callback != null) {
                callback(ToolkitAssets.instance.imageInfoFromImageData(imageData));
            }
        }
    }

    public function register(prefix:String, ctor:Void->ImageLoaderBase, pattern:String = null, isDefault:Bool = false, singleInstance:Bool = false) {
        var info:ImageLoaderInfo = {
            prefix: prefix,
            pattern: pattern,
            ctor: ctor,
            isDefault: isDefault,
            singleInstance: singleInstance
        }
        _registeredLoaders.set(prefix, info);
        if (isDefault) {
            _defaultLoader = info;
        }
    }

    public function get(prefix:String, stringResource:String = null):ImageLoaderBase {
        var info:ImageLoaderInfo = null;
        if (_registeredLoaders.exists(prefix)) {
            info = _registeredLoaders.get(prefix);
        } else if (stringResource != null) {
            info = findByPattern(stringResource);
        }
        if (info == null) {
            info = _defaultLoader;
        }

        var instance:ImageLoaderBase = null;
        if (info.singleInstance) {
            instance = info.instance;
        }
        if (instance == null) {
            instance = info.ctor();
            if (instance == null) {
                return null;
            }
            if (info.singleInstance) {
                info.instance = instance;
            }
        }
        return instance;
    }

    private function findByPattern(stringResource:String):ImageLoaderInfo {
        for (prefix in _registeredLoaders.keys()) {
            var info = _registeredLoaders.get(prefix);
            if (info.pattern == null) {
                continue;
            }

            var regexp = new EReg(info.pattern, "gm");
            if (regexp.match(stringResource)) {
                return info;
            }
        }
        return null;
    }
}

private typedef ImageLoaderInfo = {
    var prefix:String;
    var ctor:Void->ImageLoaderBase;
    @:optional var pattern:String;
    @:optional var instance:ImageLoaderBase;
    @:optional var isDefault:Bool;
    @:optional var singleInstance:Bool;
}