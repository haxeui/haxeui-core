package haxe.ui.components;

import haxe.ui.Toolkit;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.ImageDisplay;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;

/**
 A general purpose component to display images
**/
@:dox(icon = "/icons/image-sunset.png")
class Image extends Component implements IClonable<Image> {
    private var _originalSize:Size = new Size();

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        _defaultBehaviours = [
            "resource" => new ImageDefaultResourceBehaviour(this)
        ];
        _defaultLayout = new ImageLayout();
    }

    private override function create() {
        super.create();
        behaviourSet("resource", _resource);
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
    private var _resource:String;
    /**
     The resource to use for this image, currently only assets are supported, later versions will also support things like HTTP, files, etc
    **/
    @:clonable @:bindable public var resource(get, set):Dynamic;
    private function get_resource():Dynamic {
        return _resource;
    }
    private function set_resource(value:Dynamic):Dynamic {
        if (_resource == value) {
            return value;
        }

        if (value == null) {
            _resource = null;
            removeImageDisplay();
            return value;
        }

        _resource = "" + value;
        behaviourSet("resource", _resource);
        _resource = value;
        return value;
    }

    private var _maintainAspectRatio:Bool = true;
    @:clonable public var maintainAspectRatio(get, set):Bool;
    private function get_maintainAspectRatio():Bool {
        return _maintainAspectRatio;
    }
    private function set_maintainAspectRatio(value:Bool):Bool {
        if (value == _maintainAspectRatio) {
            return value;
        }
        _maintainAspectRatio = value;
        return value;
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Image)
class ImageLayout extends DefaultLayout {
    private var maintainAspectRatio(get, null):Bool;
    private function get_maintainAspectRatio():Bool {
        return cast(_component, Image)._maintainAspectRatio;
    }

    private override function resizeChildren() {
        if (component.hasImageDisplay()) {
            // this feels like it might be the wrong place to do this, ie, setting the component size here - its a special case though
            if (component.autoWidth == false) {
                var usz = usableSize;
                component.getImageDisplay().imageWidth = usz.width;
                if (maintainAspectRatio == true) {
                    var image:Image = cast _component;
                    var r:Float = usz.width / image._originalSize.width;
                    component.getImageDisplay().imageHeight = image._originalSize.height * r;
                    component.componentHeight = component.getImageDisplay().imageHeight + (paddingTop + paddingBottom);
                }
            }

            if (component.autoHeight == false) {
                var usz = usableSize;
                component.getImageDisplay().imageHeight = usz.height;
                if (maintainAspectRatio == true) {
                    var image:Image = cast _component;
                    var r:Float = usz.height / image._originalSize.height;
                    component.getImageDisplay().imageWidth = image._originalSize.width * r;
                    component.componentWidth = component.getImageDisplay().imageWidth + (paddingLeft + paddingRight);
                }
            }
        }
    }

    private override function repositionChildren() {
        if (component.hasImageDisplay()) {
            component.getImageDisplay().left = paddingLeft;
            component.getImageDisplay().top = paddingTop;
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
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Image)
class ImageDefaultResourceBehaviour extends Behaviour {
    public override function set(value:Variant) {
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
                                image.parentComponent.invalidateLayout();
                            }
                        }
                        image.invalidateLayout();
                    }
                });
            }

        }
    }
}