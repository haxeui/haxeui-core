package haxe.ui.loaders.image;

import haxe.ui.components.Image;
import haxe.ui.assets.ImageInfo;
import haxe.ui.util.Variant;

class ImageLoaderBase {
    public function new() {
    }

    public function load(resource:Variant, callback:ImageInfo->Void) {

    }

    public function postProcess(resource:Variant, image:Image) {
        
    }
}