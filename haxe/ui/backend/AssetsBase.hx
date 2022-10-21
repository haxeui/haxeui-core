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

        if (isAbsolutePath(filename) == false) {
            var parts = haxe.io.Path.normalize(Sys.programPath()).split("/");
            parts.pop();
            filename = parts.join("/") + "/" + filename;
        }
        filename = haxe.io.Path.normalize(filename);
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

    private static function isAbsolutePath(path:String):Bool {
        if (StringTools.startsWith(path, '/')) {
            return true;
        }
        if (path.charAt(1) == ':') {
            return true;
        }
        if (StringTools.startsWith(path, '\\\\')) {
            return true;
        }
        return false;
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