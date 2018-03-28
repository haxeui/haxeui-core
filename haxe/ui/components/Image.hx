package haxe.ui.components;

import haxe.ui.constants.HorizontalAlign;
import haxe.ui.constants.ScaleMode;
import haxe.ui.constants.VerticalAlign;
import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.InvalidatingBehaviour;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.ImageLoader;
import haxe.ui.util.Size;

class Image extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(ResourceBehaviour)                              public var resource:String;
    @:behaviour(InvalidatingBehaviour, ScaleMode.FILL)          public var scaleMode:ScaleMode;
    @:behaviour(InvalidatingBehaviour, HorizontalAlign.CENTER)  public var imageHorizontalAlign:HorizontalAlign;
    @:behaviour(InvalidatingBehaviour, VerticalAlign.CENTER)    public var imageVerticalAlign:VerticalAlign;
    @:behaviour(DefaultBehaviour)                               public var originalWidth:Float;
    @:behaviour(DefaultBehaviour)                               public var originalHeight:Float;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {  // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new ImageLayout();
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ImageLayout extends DefaultLayout {
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
            var image:Image = cast(_component, Image);
            var imageDisplay = image.getImageDisplay();
            var maxWidth:Float = usableSize.width;
            var maxHeight:Float = usableSize.height;
            if(component.autoWidth == true) {
                maxWidth = -1;
            }

            if(_component.autoHeight == true) {
                maxHeight = -1;
            }

            var scaleW:Float = maxWidth != -1 ? maxWidth / image.originalWidth : 1;
            var scaleH:Float = maxHeight != -1 ? maxHeight / image.originalHeight : 1;

            if (imageScaleMode != ScaleMode.FILL) {
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

                imageDisplay.imageWidth = image.originalWidth * scale;
                imageDisplay.imageHeight = image.originalHeight * scale;
            } else {
                imageDisplay.imageWidth = image.originalWidth * scaleW;
                imageDisplay.imageHeight = image.originalHeight * scaleH;
            }
        }
    }

    private override function repositionChildren() {
        if (component.hasImageDisplay()) {
            var image:Image = cast(_component, Image);
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
}
//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Image)
private class ResourceBehaviour extends DataBehaviour {
    private override function validateData() {
        if (_value == null) {
            _component.removeImageDisplay();
            return;
        }

        var imageLoader = new ImageLoader(_value);
        imageLoader.load(function(imageInfo) {
            if (imageInfo != null) {
                var image:Image = cast(_component, Image);
                var display:ImageDisplay = image.getImageDisplay();
                if (display != null) {
                    display.imageInfo = imageInfo;
                    image.originalWidth = imageInfo.width;
                    image.originalHeight = imageInfo.height;
                    if (image.autoSize() == true && image.parentComponent != null) {
                        image.parentComponent.invalidateLayout();
                    }
                    image.validateLayout();
                    display.validate();
                }
            }
        });
    }
}
