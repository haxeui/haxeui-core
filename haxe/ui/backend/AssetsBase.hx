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

    public function imageFromFile(filename:String, callback:ImageInfo->Void) {
        #if sys

        if (sys.FileSystem.exists(filename) == false) {
            callback(null);
        }

        try {
            Toolkit.assets.imageFromBytes(sys.io.File.getBytes(filename), callback);
        } catch (e:Dynamic) {
            trace("Problem loading image file: " + e);
            callback(null);
        }

        #else

        trace('WARNING: cant load from file system on non-sys targets [${filename}]');
        callback(null);

        #end
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