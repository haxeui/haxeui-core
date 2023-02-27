package haxe.ui.loaders.image;

import haxe.ui.util.Variant;
import haxe.ui.assets.ImageInfo;

class AssetImageLoader extends ImageLoaderBase {
    public override function load(resource:Variant, callback:ImageInfo->Void) {
        Toolkit.assets.getImage(resource, callback);
    }
}