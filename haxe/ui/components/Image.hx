package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.InvalidatingBehaviour;
import haxe.ui.constants.HorizontalAlign;
import haxe.ui.constants.ScaleMode;
import haxe.ui.constants.VerticalAlign;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.ImageDisplay;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.GUID;
import haxe.ui.util.ImageLoader;
import haxe.ui.util.Variant;

/**
 * Displays an image from either a path, resource id or raw image data.
 */
@:composite(ImageLayout, Builder)
class Image extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * The resource from which the image is loaded. This can be:
     * 
     *  - A path to a file
     *  - A web address
     *  - A resource id
     *  - Raw image data
     */
    @:clonable @:behaviour(ResourceBehaviour)                              public var resource:Variant;

    /**
     * The path to the image file/data. Similar to the resource property.
     * 
     * `value` is a universal way to access the value a component is based on. in this
     * case its the `resource` property, which can appear in "multiple formats". For more information, check out the `resource` property.
     */
    @:clonable @:value(resource)                                           public var value:Dynamic;

    /**
     * The image scaling mode to use, defaults to `ScaleMode.FILL`.
     */
    @:clonable @:behaviour(InvalidatingBehaviour, ScaleMode.FILL)          public var scaleMode:ScaleMode;

    /**
     * The horizontal alignment of the image, defaults to `HorizontalAlign.CENTER`. Used
     * when the width property of the image is larger than the width of the actual graphic.
     */
    @:clonable @:behaviour(InvalidatingBehaviour, HorizontalAlign.CENTER)  public var imageHorizontalAlign:HorizontalAlign;

    /**
     * The vertical alignment of the image, defaults to `VerticalAlign.CENTER`. Used
     * when the height property of the image is larger than the height of the actual graphic.
     */
    @:clonable @:behaviour(InvalidatingBehaviour, VerticalAlign.CENTER)    public var imageVerticalAlign:VerticalAlign;

    /**
     * The original width of the image graphic.
     */
    @:clonable @:behaviour(DefaultBehaviour)                               public var originalWidth:Float;

    /**
     * The original height of the image graphic.
     */
    @:clonable @:behaviour(DefaultBehaviour)                               public var originalHeight:Float;
    
    /**
     * The value to multiply the images size by
     */
    @:clonable @:behaviour(DefaultBehaviour, 1)                            public var imageScale:Float;
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
            if (component.autoWidth == true) {
                maxWidth = -1;
            }

            if (_component.autoHeight == true) {
                maxHeight = -1;
            }

            var scaleW:Float = maxWidth != -1 ? maxWidth / image.originalWidth : 1;
            var scaleH:Float = maxHeight != -1 ? maxHeight / image.originalHeight : 1;

            scaleW *= image.imageScale;
            scaleH *= image.imageScale;
            
            if (imageScaleMode != ScaleMode.FILL) {
                var scale:Float;
                switch (imageScaleMode) {
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

            switch (image.imageHorizontalAlign) {
                case HorizontalAlign.CENTER:
                    imageDisplay.left = (_component.componentWidth - imageDisplay.imageWidth) / 2;  //TODO

                case HorizontalAlign.RIGHT:
                    imageDisplay.left = _component.componentWidth - imageDisplay.imageWidth - paddingRight;

                case HorizontalAlign.LEFT:
                    imageDisplay.left = paddingLeft;
            }

            switch (image.imageVerticalAlign) {
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

    public override function refresh() {
        super.refresh();

        updateClipRect();
    }

    private function updateClipRect() {
        if (component.hasImageDisplay()) {
            var usz:Size = usableSize;
            var imageDisplay:ImageDisplay = component.getImageDisplay();
            var rc:Rectangle = imageDisplay.imageClipRect;

            if (imageDisplay.imageWidth > usz.width
                || imageDisplay.imageHeight > usz.height) {
                if (rc == null) {
                    rc = new Rectangle();
                }

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
}
//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Image)
private class ResourceBehaviour extends DataBehaviour {
    private var _canvasMap:Map<String, Canvas> = null; // we'll want to cache any canvases used so we dont cloneComponent over and ove again
    
    private override function validateData() {
        if (_value == null || _value.isNull) {
            _component.removeImageDisplay();
            _component.invalidateComponent();
            return;
        }

        if (_value.isComponent && ((_value.toComponent() is Canvas))) { // lets support adding canvases as icons, images, etc
            var newCanvas:Canvas = null;
            if (_canvasMap == null) {
                _canvasMap = new Map<String, Canvas>();
            }
            var canvas:Component = _value.toComponent();
            if (canvas.id == null) {
                canvas.id = GUID.uuid();
            }
            
            var existingCanvas = _component.findComponent(Canvas, false);
            if (existingCanvas != null && existingCanvas.id == canvas.id) { // if the current canvas is the same as the new one, lets return
                return;
            }
            
            if (existingCanvas != null) {
                _component.removeComponent(existingCanvas, false);
            }
            
            if (_canvasMap.exists(canvas.id)) { // use cached canvas
                newCanvas = _canvasMap.get(canvas.id);
            } else {
                newCanvas = cast _value.toComponent().cloneComponent(); // not found in cache, lets clone it and add it to the cache
                _canvasMap.set(canvas.id, newCanvas);
            }
            
            _component.addComponent(newCanvas);
        } else {
            var imageLoader = new ImageLoader(_value);
            imageLoader.load(function(imageInfo) {
                if (imageInfo != null) {
                    if (_value == null || _value.isNull) { // its possible that while loading the image (async) its been set to null, lets honour it
                        _component.removeImageDisplay();
                        _component.invalidateComponent();
                        return;
                    }

                    var image:Image = cast(_component, Image);
                    if (image == null) {
                        return;
                    }
                    var display:ImageDisplay = image.getImageDisplay();
                    if (display != null) {
                        display.imageInfo = imageInfo;
                        image.originalWidth = imageInfo.width;
                        image.originalHeight = imageInfo.height;
                        if (image.autoSize() == true && image.parentComponent != null) {
                            image.parentComponent.invalidateComponentLayout();
                        }
                        image.invalidateComponent();
                        display.validateComponent();
                    }
                }
            });
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _image:Image;

    public function new(image:Image) {
        super(image);
        _image = image;
        _image.registerEvent(UIEvent.SHOWN, function(_) {
            if (_image.parentComponent != null) {
                _image.parentComponent.invalidateComponentLayout();
            }
        });
    }

    public override function applyStyle(style:Style) {
        if (style.resource != null) {
            _image.resource = style.resource;
        }
    }
}
