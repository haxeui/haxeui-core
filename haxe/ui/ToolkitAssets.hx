package haxe.ui;

import haxe.Resource;
import haxe.io.Bytes;
import haxe.ui.Preloader.PreloadItem;
import haxe.ui.assets.AssetPlugin;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.AssetsBase;
import haxe.ui.backend.ToolkitOptions;
import haxe.ui.util.CallbackMap;

class ToolkitAssets extends AssetsBase {
    private static var _instance:ToolkitAssets;
    public static var instance(get, never):ToolkitAssets;
    private static function get_instance():ToolkitAssets {
        if (_instance == null) {
            _instance = new ToolkitAssets();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    public var preloadList:Array<PreloadItem> = [];
    
    public var options:ToolkitOptions = null;

    private var _fontCache:Map<String, FontInfo>;
    private var _fontCallbacks:CallbackMap<FontInfo>;

    private var _imageCache:Map<String, ImageInfo>;
    private var _imageCallbacks:CallbackMap<ImageInfo>;

    public function new() {
        super();
    }

    public function getFont(resourceId:String, callback:FontInfo->Void, useCache:Bool = true) {
        if (_fontCache != null && _fontCache.get(resourceId) != null && useCache == true) {
            callback(_fontCache.get(resourceId));
        } else {
            if (_fontCallbacks == null) {
                _fontCallbacks = new CallbackMap<FontInfo>();
            }

            _fontCallbacks.add(resourceId, callback);

            if (_fontCallbacks.count(resourceId) == 1) {
                getFontInternal(resourceId, function(font:FontInfo) {
                    if (font != null) {
                        _onFontLoaded(resourceId, font);
                    } else if (Resource.listNames().indexOf(resourceId) != -1) {
                        getFontFromHaxeResource(resourceId, _onFontLoaded);
                    } else {
                        _fontCallbacks.remove(resourceId, callback);
                        callback(null);
                    }
                });
            }
        }
    }

    private function _onFontLoaded(resourceId:String, font:FontInfo) {
        if (_fontCache == null) {
            _fontCache = new Map<String, FontInfo>();
        }
        _fontCache.set(resourceId, font);
        _fontCallbacks.invokeAndRemove(resourceId, font);
    }

    public function getImage(resourceId:String, callback:ImageInfo->Void, useCache:Bool = true) {
        var orginalResourceId = resourceId;
        resourceId = runPlugins(resourceId);
        if (_imageCache != null && _imageCache.get(resourceId) != null && useCache == true) {
            callback(_imageCache.get(resourceId));
        } else {
            if (_imageCallbacks == null) {
                _imageCallbacks = new CallbackMap<ImageInfo>();
            }

            _imageCallbacks.add(resourceId, callback);

            if (_imageCallbacks.count(resourceId) == 1) {
                getImageInternal(resourceId, function(imageInfo:ImageInfo) {
                    if (imageInfo != null) {
                        _onImageLoaded(resourceId, imageInfo);
                    } else if (Resource.listNames().indexOf(orginalResourceId) != -1) {
                        _imageCallbacks.remove(resourceId, callback);
                        _imageCallbacks.add(orginalResourceId, callback);
                        getImageFromHaxeResource(orginalResourceId, _onImageLoaded);
                    } else if (Resource.listNames().indexOf(resourceId) != -1) {
                        getImageFromHaxeResource(resourceId, _onImageLoaded);
                    } else {
                        _imageCallbacks.remove(resourceId, callback);
                        callback(null);
                    }
                });
            }
        }
    }

    private function _onImageLoaded(resourceId:String, imageInfo:ImageInfo) {
        if (imageInfo != null && (imageInfo.width == -1 || imageInfo.width == -1)) {
            trace("WARNING: imageData.originalWidth == -1 || imageData.originalHeight == -1");
        }

        if (_imageCache == null) {
            _imageCache = new Map<String, ImageInfo>();
        }
        _imageCache.set(resourceId, imageInfo);
        _imageCallbacks.invokeAndRemove(resourceId, imageInfo);
    }

    public function getText(resourceId:String):String {
        var s = getTextDelegate(resourceId);
        if (s == null) {
            s = Resource.getString(resourceId);
        }
        return s;
    }

    public function getBytes(resourceId):Bytes {
        return null;
    }

    //***********************************************************************************************************
    // Plugins
    //***********************************************************************************************************
    private var _plugins:Array<AssetPlugin>;
    public function addPlugin(plugin:AssetPlugin) {
        if (_plugins == null) {
            _plugins = [];
        }
        _plugins.push(plugin);
    }

    private function runPlugins(asset:Dynamic):Dynamic {
        if (_plugins == null) {
            return asset;
        }

        for (p in _plugins) {
            asset = p.invoke(asset);
        }

        return asset;
    }
}