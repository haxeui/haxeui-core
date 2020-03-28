package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;

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
}