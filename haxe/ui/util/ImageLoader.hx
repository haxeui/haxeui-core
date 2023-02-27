package haxe.ui.util;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;
import haxe.ui.loaders.image.AssetImageLoader;
import haxe.ui.loaders.image.FileImageLoader;
import haxe.ui.loaders.image.HttpImageLoader;

class ImageLoader {
    private var _resource:Variant;

    public function new(resource:Variant) {
        _resource = resource;
    }

    public function load(callback:ImageInfo->Void, useCache:Bool = true) {
        if (_resource.isString) {
            var stringResource:String = _resource;
            if (useCache == true) {
                var cachedImage = ToolkitAssets.instance.getCachedImage(stringResource);
                if (cachedImage != null) {
                    callback(cachedImage);
                    return;
                }
            }
            stringResource = StringTools.trim(stringResource);
            if (StringTools.startsWith(stringResource, "http://") || StringTools.startsWith(stringResource, "https://")) {
                new HttpImageLoader().load(_resource, callback);
            } else if (StringTools.startsWith(stringResource, "file://")) {
                new FileImageLoader().load(_resource, callback);
            } else { // assume asset
                //Toolkit.assets.getImage(stringResource, callback);
                new AssetImageLoader().load(_resource, callback);
            }
            
        } else if (_resource.isImageData) {
            var imageData:ImageData = _resource;
            if (callback != null) {
                callback(ToolkitAssets.instance.imageInfoFromImageData(imageData));
            }
        }
    }
}