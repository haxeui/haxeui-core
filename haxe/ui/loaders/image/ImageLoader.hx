package haxe.ui.loaders.image;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;
import haxe.ui.util.Variant;

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

            var loader = get(prefix);
            if (loader == null) {
                trace("WARNING: no image loader could be found for '" + prefix + "'");
                callback(null);
                return;
            }

            loader.load(resource, callback);
        } else if (resource.isImageData) {
            var imageData:ImageData = resource;
            if (callback != null) {
                callback(ToolkitAssets.instance.imageInfoFromImageData(imageData));
            }
        }
    }

    public function register(prefix:String, ctor:Void->ImageLoaderBase, isDefault:Bool = false, singleInstance:Bool = false) {
        var info:ImageLoaderInfo = {
            prefix: prefix,
            ctor: ctor,
            isDefault: isDefault,
            singleInstance: singleInstance
        }
        _registeredLoaders.set(prefix, info);
        if (isDefault) {
            _defaultLoader = info;
        }
    }

    public function get(prefix:String):ImageLoaderBase {
        var info:ImageLoaderInfo = _defaultLoader;
        if (_registeredLoaders.exists(prefix)) {
            info = _registeredLoaders.get(prefix);
        }
        if (info == null) {
            return null;
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
}

private typedef ImageLoaderInfo = {
    var prefix:String;
    var ctor:Void->ImageLoaderBase;
    @:optional var instance:ImageLoaderBase;
    @:optional var isDefault:Bool;
    @:optional var singleInstance:Bool;
}