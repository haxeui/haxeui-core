package haxe.ui.backend;

import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Component;
import haxe.ui.geom.Rectangle;

@:dox(hide) @:noCompletion
class ImageBase extends ImageSurface {
    public var parentComponent:Component;
    public var aspectRatio:Float = 1; // width x height

    private var _left:Float = 0;
    private var _top:Float = 0;
    private var _imageWidth:Float = 0;
    private var _imageHeight:Float = 0;
    private var _imageInfo:ImageInfo;
    private var _imageClipRect:Rectangle;

    public function dispose() {
    }

    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private function validateData() {
    }

    private function validatePosition() {
    }

    private function validateDisplay() {

    }
}