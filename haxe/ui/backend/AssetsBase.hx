package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;

class AssetsBase {
    public function new() {

    }

    private function getTextDelegate(resourceId:String):String {
        return null;
    }
    
    private function getImageInternal(resourceId:String, callback:ImageInfo->Void) {
        callback(null);
    }
    
    private function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
        callback(resourceId, null);
    }
    
    public function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void) {
        callback(null);
    }
    
    private function getFontInternal(resourceId:String, callback:FontInfo->Void) {
        callback(null);
    }
    
    private function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
        callback(resourceId, null);
    }
    
    public function imageInfoFromImageData(imageData:ImageData):ImageInfo {
        return {
            data: imageData,
            width: 0,
            height: 0
        }
    }
}