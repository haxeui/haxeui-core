package haxe.ui.assets;

import haxe.ui.backend.ImageData;

typedef ImageInfo = {
    #if svg
    @:optional public var data:ImageData;
    @:optional public var svg:format.SVG;
    #else
    public var data:ImageData;
    #end
    public var width:Int;
    public var height:Int;

}
