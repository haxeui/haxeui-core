package haxe.ui.components;

import haxe.ui.util.Rectangle;
import haxe.ui.constants.VerticalAlign;
import haxe.ui.constants.HorizontalAlign;
import haxe.ui.constants.ScaleMode;
import haxe.ui.Toolkit;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;

/**
 A general purpose component to display images
**/
@:dox(icon = "/icons/image-sunset.png")
class Image extends Component {
    private var _originalSize:Size = new Size();

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "resource" => new ImageDefaultResourceBehaviour(this)
        ]);
        _defaultLayout = new ImageLayout();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_value():Variant {
        return Variant.fromDynamic(resource);
    }

    private override function set_value(value:Variant):Variant {
        if (value == null) {
            return null;
        }
        resource = value.toString();
        return value;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _resource:String = null;
    /**
     The resource to use for this image, currently only assets are supported, later versions will also support things like HTTP, files, etc
    **/
    @:clonable @:bindable public var resource(get, set):String;
    private function get_resource():String {
        return _resource;
    }
    private function set_resource(value:String):String {
        if (_resource == value) {
            return value;
        }

        _resource = value;
        invalidateComponentData();
        return value;
    }

    private var _scaleMode:ScaleMode = ScaleMode.FILL;
    @:clonable public var scaleMode(get, set):ScaleMode;
    private function get_scaleMode():ScaleMode {
        return _scaleMode;
    }
    private function set_scaleMode(value:ScaleMode):ScaleMode {
        if (value == _scaleMode) {
            return value;
        }
        _scaleMode = value;
        invalidateComponentLayout();
        return value;
    }

    private var _imageHorizontalAlign:HorizontalAlign = HorizontalAlign.CENTER;
    @:clonable public var imageHorizontalAlign(get, set):HorizontalAlign;
    private function get_imageHorizontalAlign():HorizontalAlign {
        return _imageHorizontalAlign;
    }
    private function set_imageHorizontalAlign(value:HorizontalAlign):HorizontalAlign {
        if (value == _imageHorizontalAlign) {
            return value;
        }
        _imageHorizontalAlign = value;
        invalidateComponentLayout();
        return value;
    }

    private var _imageVerticalAlign:VerticalAlign = VerticalAlign.CENTER;
    @:clonable public var imageVerticalAlign(get, set):VerticalAlign;
    private function get_imageVerticalAlign():VerticalAlign {
        return _imageVerticalAlign;
    }
    private function set_imageVerticalAlign(value:VerticalAlign):VerticalAlign {
        if (value == _imageVerticalAlign) {
            return value;
        }
        _imageVerticalAlign = value;
        invalidateComponentLayout();
        return value;
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        var resourceValue:Dynamic = behaviourGetDynamic("resource");
        if (resourceValue != _resource) {
            behaviourSet("resource", _resource);
        }
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Image)
class ImageLayout extends DefaultLayout {
    private var imageScaleMode(get, never):ScaleMode;
    private function get_imageScaleMode():ScaleMode {
        return cast(_component, Image).scaleMode;
    }

    private var imageHorizontalAlign(get, never):HorizontalAlign;
    private function get_imageHorizontalAlign():HorizontalAlign {
        return cast(_component, Image).imageHorizontalAlign;
    }

    private var imageVerticalAlign(get, never):VerticalAlign;
    private function get_imageVerticalAlign():VerticalAlign {
        return cast(_component, Image).imageVerticalAlign;
    }

    private override function resizeChildren() {
        if (component.hasImageDisplay()) {
            var usz = usableSize;
            var image:Image = cast _component;
            var imageDisplay = image.getImageDisplay();
            var maxWidth:Float = usableSize.width;
            var maxHeight:Float = usableSize.height;
            if(component.autoWidth == true) {
                maxWidth = -1;
            }

            if(_component.autoHeight == true) {
                maxHeight = -1;
            }

            var scaleW:Float = maxWidth != -1 ? maxWidth / image._originalSize.width : 1;
            var scaleH:Float = maxHeight != -1 ? maxHeight / image._originalSize.height : 1;

            if(imageScaleMode != ScaleMode.FILL) {
                var scale:Float;
                switch(imageScaleMode) {
                    case ScaleMode.FIT_INSIDE:
                        scale = (scaleW < scaleH) ? scaleW : scaleH;
                    case ScaleMode.FIT_OUTSIDE:
                        scale = (scaleW > scaleH) ? scaleW : scaleH;
                    case ScaleMode.FIT_WIDTH:
                        scale = scaleW;
                    case ScaleMode.FIT_HEIGHT:
                        scale = scaleH;
                    default:    //ScaleMode.NONE
                        scale = 1;
                }

                imageDisplay.imageWidth = image._originalSize.width * scale;
                imageDisplay.imageHeight = image._originalSize.height * scale;
            } else {
                imageDisplay.imageWidth = image._originalSize.width * scaleW;
                imageDisplay.imageHeight = image._originalSize.height * scaleH;
            }

            updateClipRect(usz);
        }
    }

    private override function repositionChildren() {
        if (component.hasImageDisplay()) {
            var image:Image = cast _component;
            var imageDisplay:ImageDisplay = _component.getImageDisplay();

            switch(image.imageHorizontalAlign) {
                case HorizontalAlign.CENTER:
                    imageDisplay.left = (_component.componentWidth - imageDisplay.imageWidth) / 2;  //TODO

                case HorizontalAlign.RIGHT:
                    imageDisplay.left = _component.componentWidth - imageDisplay.imageWidth - paddingRight;

                case HorizontalAlign.LEFT:
                    imageDisplay.left = paddingLeft;
            }

            switch(image.imageVerticalAlign) {
                case VerticalAlign.CENTER:
                    imageDisplay.top = (_component.componentHeight - imageDisplay.imageHeight) / 2;  //TODO

                case VerticalAlign.BOTTOM:
                    imageDisplay.top = _component.componentHeight - imageDisplay.imageHeight - paddingBottom;

                case VerticalAlign.TOP:
                    imageDisplay.top = paddingTop;
            }

            updateClipRect(usableSize);
        }
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size:Size = super.calcAutoSize(exclusions);
        if (component.hasImageDisplay()) {
            size.width += component.getImageDisplay().imageWidth;
            size.height += component.getImageDisplay().imageHeight;
        }
        return size;
    }

    private function updateClipRect(usz:Size) {
        var imageDisplay:ImageDisplay = _component.getImageDisplay();
        var rc:Rectangle = imageDisplay.imageClipRect;
        if(rc == null)
            rc = new Rectangle();

        if(imageDisplay.imageWidth > usz.width
           || imageDisplay.imageHeight > usz.height) {
            rc.top = paddingLeft;
            rc.left = paddingTop;
            rc.width = usz.width;
            rc.height = usz.height;
        } else {
            rc = null;
        }

        imageDisplay.imageClipRect = rc;
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Image)
class ImageDefaultResourceBehaviour extends Behaviour {
    private var _value:Dynamic;

    public override function set(value:Variant) {
        if (_value == value) {
            return;
        }

        _value = value;

        var image:Image = cast _component;

        if (value == null || value.isNull || value == "null") { // TODO: hack
            image.removeImageDisplay();
            return;
        }

        if (value.isString) {
            var resource:String = value.toString();
            if (StringTools.startsWith(resource, "http://")) {
                // load remote placeholder
            } else { // assume asset
                Toolkit.assets.getImage(resource, function(imageInfo:ImageInfo) {
                    if (imageInfo != null) {
                        var display:ImageDisplay = image.getImageDisplay();
                        if (display != null) {
                            display.imageInfo = imageInfo;
                            image._originalSize = new Size(imageInfo.width, imageInfo.height);
                            if (image.autoSize() == true && image.parentComponent != null) {
                                image.parentComponent.invalidateComponentLayout();
                            }
                            image.validateLayout();
                            display.validate();
                        }
                    }
                });
            }

        }
    }

    public override function getDynamic():Dynamic {
        return _value;
    }
}