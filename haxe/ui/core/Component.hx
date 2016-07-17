package haxe.ui.core;

import haxe.ui.core.Component.DeferredBindingInfo;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.DelegateLayout;
import haxe.ui.layouts.Layout;
import haxe.ui.scripting.ScriptInterp;
import haxe.ui.styles.Parser;
import haxe.ui.styles.Style;
import haxe.ui.util.CallStackHelper;
import haxe.ui.util.EventMap;
import haxe.ui.util.GenericConfig;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;
import haxe.ui.util.StringUtil;
import haxe.ui.util.Variant;

@:dox(hide)
class BindingInfo {
    public function new() {
    }
    public var target:Component;
    public var targetProperty:String;
    public var sourceProperty:String;
    public var transform:String;
}

@:dox(hide)
class DeferredBindingInfo {
    public function new() {
    }
    public var targetId:String;
    public var sourceId:String;
    public var targetProperty:String;
    public var sourceProperty:String;
    public var transform:String;
}

/**
 Base class of all HaxeUI controls
**/
@:build(haxe.ui.macros.Macros.buildStyles())
@:autoBuild(haxe.ui.macros.Macros.buildStyles())
@:autoBuild(haxe.ui.macros.Macros.buildBindings())
@:build(haxe.ui.macros.Macros.addClonable())
@:autoBuild(haxe.ui.macros.Macros.addClonable())
class Component extends ComponentBase implements IComponentBase implements IClonable<Component> {
    public function new() {
        super();
        //_children = new Array<Component>();
        //_style = new Style();

        #if flash
        addClass("flash");
        #end
        #if html5
        addClass("html5");
        #end

        //addClass("component");
        var parts:Array<String> = Type.getClassName(Type.getClass(this)).split(".");
        var className:String = parts[parts.length - 1].toLowerCase();
        addClass(className, false);

        layout = new DefaultLayout();

        createDefaults();

        // we dont want to actually apply the classes, just find out if native is there or not
        var s = Toolkit.styleSheet.applyClasses(this, false);
        if (s.native != null) {
            native = s.native;
        } else {
            create();
        }
    }

    //***********************************************************************************************************
    // Construction
    //***********************************************************************************************************
    private function create():Void {
        handleCreate(native);
        destroyChildren();

        layout = createLayout();
        if (native == false || native == null) {
            createChildren();
        }
    }

    private function createDefaults():Void {

    }

    private function createChildren():Void {

    }

    private function destroyChildren():Void {

    }

    private var hasNativeEntry(get, null):Bool;
    private function get_hasNativeEntry():Bool {
        var h = false;
        var nativeConfig:GenericConfig = Toolkit.backendConfig.findBy("native");
        if (nativeConfig != null) {
            var className = Type.getClassName(Type.getClass(this));
            var componentConfig:GenericConfig = nativeConfig.findBy("component", "id", className);
            if (componentConfig != null) {
                h = true;
            }
        }
        return h;
    }

    private var _defaultLayout:Layout;
    private function createLayout():Layout {
        var l:Layout = null;
        if (native == true) {
            var nativeConfig:GenericConfig = Toolkit.backendConfig.findBy("native");
            if (nativeConfig != null) {
                var className = Type.getClassName(Type.getClass(this));
                var componentConfig:GenericConfig = nativeConfig.findBy("component", "id", className);
                if (componentConfig != null) {
                    var sizeConfig:GenericConfig = componentConfig.findBy("size");
                    if (sizeConfig != null) {
                        var sizeClass:String = sizeConfig.values.get("class");
                        var size:DelegateLayoutSize = Type.createInstance(Type.resolveClass(sizeClass), []);
                        size.config = sizeConfig.values;
                        l = new DelegateLayout(size);
                    }
                    var layoutConfig:GenericConfig = componentConfig.findBy("layout");
                    if (layoutConfig != null) {
                        var layoutClass:String = layoutConfig.values.get("class");
                        l = Type.createInstance(Type.resolveClass(layoutClass), []);
                    }
                }
            }
        }

        if (l == null) {
            l = _defaultLayout;
        }
        if (l == null) {
            return layout;
        }
        return l;
    }

    private var _defaultBehaviours:Map<String, Behaviour> = new Map<String, Behaviour>();
    private var _behaviours:Map<String, Behaviour> = new Map<String, Behaviour>();
    private function getBehaviour(id:String):Behaviour {
        var b:Behaviour = _behaviours.get(id);
        if (b != null) {
            return b;
        }

        if (native == true) {
            var nativeConfig:GenericConfig = Toolkit.backendConfig.findBy("native");
            if (nativeConfig != null) {
                var className = Type.getClassName(Type.getClass(this));
                var componentConfig:GenericConfig = nativeConfig.findBy("component", "id", className);
                if (componentConfig != null) {
                    var behaviourConfig:GenericConfig = componentConfig.findBy("behaviour", "id", id);
                    if (behaviourConfig != null) {
                        var behaviourClass:String = behaviourConfig.values.get("class");
                        b = Type.createInstance(Type.resolveClass(behaviourClass), [this]);
                        b.config = behaviourConfig.values;
                    }
                }
            }
        }

        if (b == null) {
            b = _defaultBehaviours.get(id);
        }
        _behaviours.set(id, b);
        return b;
    }

    private function behaviourGet(id:String):Variant {
        var b:Behaviour = getBehaviour(id);
        if (b != null) {
            return b.get();
        }
        return null;
    }

    private function behaviourSet(id:String, value:Variant):Void {
        var b:Behaviour = getBehaviour(id);
        if (b != null) {
            b.set(value);
        }
    }

    private function behavioursUpdate():Void {
        for (b in _behaviours) {
            if (b != null) {
                b.update();
            }
        }
    }

    private var _native:Null<Bool> = null;
    /**
     Whether to try to use a native version of this component
    **/
    public var native(get, set):Null<Bool>;
    private function get_native():Null<Bool> {
        if (hasNativeEntry == false) {
            return false;
        }
        return _native;
    }
    private function set_native(value:Null<Bool>):Null<Bool> {
        if (_native == value) {
            return value;
        }

        if (_ready == false) {
            //return value;
        }

        _native = value;
        _behaviours  = new Map<String, Behaviour>();
        create();
        return value;
    }

    private var _animatable = true;
    /**
     Whether this component is allowed to animate
    **/
    public var animatable(get, set):Bool;
    private function get_animatable():Bool {
        #if !actuate
            return false;
        #end
        return _animatable;
    }
    private function set_animatable(value:Bool):Bool {
        _animatable = value;
        return value;
    }

    /**
     User specific data stored against this component instance
    **/
    public var userData(default, default):Dynamic = null;

    //***********************************************************************************************************
    // General
    //***********************************************************************************************************
    @clonable private var _id:String = null;
    /**
     The identifier of this component
    **/
    @clonable public var id(get, set):String;
    private function get_id():String {
        return _id;
    }
    private function set_id(value:String):String {
        if (_id != value) {
            _id = value;
            //invalidate(InvalidationFlags.STYLE);
            //invalidateDisplay();
        }
        return _id;
    }

    private var _text:String = null;
    /**
     The text of this component (not used in all sub classes)
    **/
    @clonable public var text(get, set):String;
    private function get_text():String {
        return _text;
    }
    private function set_text(value:String):String {
        if (_text != value) {
            _text = value;
        }
        return _text;
    }

    /**
     The value of this component. This can mean different things depending on the component.

     For example a buttons value is its text, and sliders value is its slider position.
    **/
    @clonable public var value(get, set):Variant;
    private function get_value():Variant {
        return text;
    }
    private function set_value(value:Variant):Variant {
        text = value;
        return value;
    }

    /**
     Reference to the `Screen` object this component is displayed on
    **/
    public var screen(get, null):Screen;
    private function get_screen():Screen {
        return Toolkit.screen;
    }

    //***********************************************************************************************************
    //{Binding related}
    //***********************************************************************************************************
    private var _bindings:Map<String, Array<BindingInfo>>;
    /**
     Binds a property of this component to the property of another
    **/
    @:dox(group="Binding related properties and methods")
    public function addBinding(target:Component, transform:String = null, targetProperty:String = "value", sourceProperty:String = "value") {
        if (_bindings == null) {
            _bindings = new Map<String, Array<BindingInfo>>();
        }

        var array:Array<BindingInfo> = _bindings.get(sourceProperty);
        if (array == null) {
            array = new Array<BindingInfo>();
            _bindings.set(sourceProperty, array);
        }

        var info:BindingInfo = new BindingInfo();
        info.target = target;
        info.targetProperty = targetProperty;
        info.sourceProperty = sourceProperty;
        info.transform = transform;
        array.push(info);
    }

    private var _deferredBindings:Array<DeferredBindingInfo>;
    /**
     Binds a property of this component to the property of another that may or may not current exist in the component tree
    **/
    @:dox(group="Binding related properties and methods")
    public function addDeferredBinding(targetId:String, sourceId:String, transform:String = null, targetProperty:String = "value", sourceProperty:String = "value") {
        if (_deferredBindings == null) {
            _deferredBindings = new Array<DeferredBindingInfo>();
        }

        var deferredBinding:DeferredBindingInfo = new DeferredBindingInfo();
        deferredBinding.targetId = targetId;
        deferredBinding.sourceId = sourceId;
        deferredBinding.transform = transform;
        deferredBinding.targetProperty = targetProperty;
        deferredBinding.sourceProperty = sourceProperty;

        _deferredBindings.push(deferredBinding);
    }

    private function getDefferedBindings():Array<DeferredBindingInfo> {
        var b = null;
        var c = this;
        while (b == null && c != null) {
            if (c._deferredBindings != null) {
                b = c._deferredBindings;
                break;
            }
            c = c.parentComponent;
        }
        return b;
    }

    private function handleBindings(sourceProperties:Array<String>) {
        if (_bindings == null) {
            return;
        }

        for (sourceProperty in sourceProperties) {
            var v:Variant = getProperty(sourceProperty);
            if (v == null) {
                continue;
            }

            var array:Array<BindingInfo> = _bindings.get(sourceProperty);
            if (array == null) {
                continue;
            }

            for (info in array) {

                if (info.target == null) {
                    continue;
                }

                if (info.transform == null) {
                    info.target.setProperty(info.targetProperty, v);
                } else if (info.transform.indexOf("${value}") != -1) {
                    v = StringTools.replace(info.transform, "${value}", v);
                    info.target.setProperty(info.targetProperty, v);
                } else if (info.transform.indexOf("${") != -1) {
                    var s:String = info.transform.substr(2, info.transform.length - 3);

                    // probably not the most effecient method
                    var scriptResult:Variant = null;
                    try {
                        var parser = new hscript.Parser();
                        var program = parser.parseString(s);
                        var interp = findScriptInterp();
                        interp.variables.set("Math", Math);
                        interp.variables.set("value", Variant.toDynamic(v));
                        scriptResult = Variant.fromDynamic(interp.expr(program));
                    } catch (e:Dynamic) {
                        trace("Problem executing binding script: " + e);
                    }

                    if (scriptResult != null) {
                        info.target.setProperty(info.targetProperty, scriptResult);
                    }

                } else {

                }
            }
        }
    }
    //}
    //***********************************************************************************************************

    //***********************************************************************************************************
    // Clip rect
    //***********************************************************************************************************
    private var _clipRect:Rectangle = null;
    /**
     Whether to clip the display of this component
    **/
    public var clipRect(get, set):Rectangle;
    private function get_clipRect():Rectangle {
        return _clipRect;
    }
    private function set_clipRect(value:Rectangle):Rectangle {
        _clipRect = value;
        handleClipRect(value);
        return value;
    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    /**
     The top level component of this component instance
    **/
    @:dox(group="Display tree related properties and methods")
    public var rootComponent(get, never):Component;
    private function get_rootComponent():Component {
        var r = this;
        while (r.parentComponent != null) {
            r = r.parentComponent;
        }
        return r;
    }


    private var _children:Array<Component>;
    /**
     The parent component of this component instance
    **/
    @:dox(group="Display tree related properties and methods")
    public var parentComponent:Component = null;

    /**
     Adds a child component to this component instance
    **/
    @:dox(group="Display tree related properties and methods")
    public function addComponent(child:Component):Component {
        if (this.native == true) {
            var className:String = Type.getClassName(Type.getClass(this));
            var allowChildren:Bool = Toolkit.backendConfig.queryBool('native.component[id=${className}].@allowChildren', true);
            if (allowChildren == false) {
                return child;
            }
        }

        child.parentComponent = this;

        if (_children == null) {
            _children = new Array<Component>();
        }
        _children.push(child);

        var deferredBindings:Array<DeferredBindingInfo> = getDefferedBindings();
        if (deferredBindings != null) {
            var itemsToRemove:Array<DeferredBindingInfo> = new Array<DeferredBindingInfo>();
            for (binding in deferredBindings) {
                var source = findComponent(binding.sourceId, null, true);
                var target = findComponent(binding.targetId, null, true);
                if (source != null && target != null) {
                    source.addBinding(target, binding.transform, binding.targetProperty,  binding.sourceProperty);
                    itemsToRemove.push(binding);
                }
            }

            // remove found bindings
            for (item in itemsToRemove) {
                deferredBindings.remove(item);
            }
        }

        handleAddComponent(child);
        if (_ready) {
            child.ready();
        }

        invalidateLayout();
        return child;
    }

    /**
     Removes the specified child component from this component instance
    **/
    @:dox(group="Display tree related properties and methods")
    public function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        handleRemoveComponent(child, dispose);
        if (_children != null) {
            _children.remove(child);
            invalidateLayout();
        }

        return child;
    }

    /**
     Removes all child components from this component instance
    **/
    @:dox(group="Display tree related properties and methods")
    public function removeAllComponents(dispose:Bool = true) {
        if (_children != null) {
            while (_children.length > 0) {
                _children[0].removeAllComponents(dispose);
                removeComponent(_children[0], dispose, false);
            }
            invalidateLayout();
        }
    }

    /**
     A list of this components children

     _Note_: This function will return an empty array if the component has no children
    **/
    @:dox(group="Display tree related properties and methods")
    public var childComponents(get, null):Array<Component>;
    private function get_childComponents():Array<Component> {
        if (_children == null) {
            return new Array<Component>();
        }
        return _children;
    }

    /**
     Finds a specific child in this components display tree (recusively if desired) and can optionally cast the result

     - `critera` - The criteria by which to search, the interpretation of this is defined using `searchType` (the default search type is _id_)

     - `type` - The component class you wish to cast the result to (defaults to _null_)

     - `recursive` - Whether to search this components children and all its childrens children till it finds a match (defaults to _false_)

     - `searchType` - Allows you specify how to consider a child a match (defaults to _id_), can be either:

            - `id` - The first component that has the id specified in `criteria` will be considered a match

            - `css` - The first component that contains a style name specified by `criteria` will be considered a match
    **/
    @:dox(group="Display tree related properties and methods")
    public function findComponent<T>(critera:String, type:Class<T> = null, recursive:Bool = false, searchType:String = "id"):Null<T> {
        var match:Component = null;
        for (child in childComponents) {
            if (critera != null) {
                if (searchType == "id" && child.id == critera) {
                    match = cast child;
                    break;
                } else if (searchType == "css" && child.hasClass(critera) == true) {
                    match = cast child;
                    break;
                }
            } else if (type != null) {
                if (Std.is(child, type) == true) {
                    match = cast child;
                    break;
                }
            }
        }
        if (match == null && recursive == true) {
            for (child in childComponents) {
                var temp:Component = cast child.findComponent(critera, type, recursive, searchType);
                if (temp != null) {
                    match = temp;
                    break;
                }
            }
        }

        return cast match;
    }

    /**
     Gets the index of a child component
    **/
    @:dox(group="Display tree related properties and methods")
    public function getComponentIndex(child:Component):Int {
        var index:Int = -1;
        if (_children != null && child != null) {
            index = _children.indexOf(child);
        }
        return index;
    }

    /**
     Gets a child component at a specified index
    **/
    @:dox(group="Display tree related properties and methods")
    public function getComponentAt(index:Int):Component {
        if (_children == null) {
            return null;
        }
        return _children[index];
    }


    /**
     Hides this component and all its children
    **/
    @:dox(group="Display tree related properties and methods")
    public function hide():Void {
        handleVisibility(false);
        _hidden = true;
    }

    /**
     Shows this component and all its children
    **/
    @:dox(group="Display tree related properties and methods")
    public function show():Void {
        handleVisibility(true);
        _hidden = false;
    }

    private var _hidden:Bool = false;
    /**
     Whether this component is hidden or not
    **/
    @:dox(group="Display tree related properties and methods")
    public var hidden(get, set):Bool;
    private function get_hidden():Bool {
        if (_hidden == true) {
            return true;
        }
        if (parentComponent != null) {
            return parentComponent.hidden;
        }
        return false;
    }
    private function set_hidden(value:Bool):Bool {
        if (value == true) {
            hide();
        } else {
            show();
        }
        return value;
    }

    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    /**
     A custom style object that will appled to this component after any css rules have been matched and applied
    **/
    @:dox(group="Style related properties and methods")
    public var customStyle:Style = new Style();
    @:dox(group = "Style related properties and methods")
    @:allow(haxe.ui.styles.Engine)
    private var classes:Array<String> = new Array<String>();

    /**
     Adds a css style name to this component
    **/
    @:dox(group="Style related properties and methods")
    public function addClass(name:String, invalidate:Bool = true) {
        if (classes.indexOf(name) == -1) {
            classes.push(name);
            if (invalidate == true) {
                invalidateStyle();
            }
        }
    }

    /**
     Removes a css style name from this component
    **/
    @:dox(group="Style related properties and methods")
    public function removeClass(name:String, invalidate:Bool = true) {
        if (classes.indexOf(name) != -1) {
            classes.remove(name);
            if (invalidate == true) {
                invalidateStyle();
            }
        }

    }

    /**
     Whether or not this component has a css class associated with it
    **/
    @:dox(group="Style related properties and methods")
    public function hasClass(name:String):Bool {
        return (classes.indexOf(name) != -1);
    }

    /**
     A string representation of the css classes associated with this component
    **/
    @:dox(group="Style related properties and methods")
    public var styleNames(get, set):String;
    private function get_styleNames():String {
        return classes.join(" ");
    }
    private function set_styleNames(value:String):String {
        if (value == null) {
            return value;
        }

        for (x in value.split(" ")) {
            addClass(x);
        }
        return value;
    }

    private var _styleString:String;
    /**
     An inline css string that will be parsed and applied as a custom style
    **/
    @:dox(group="Style related properties and methods")
    public var styleString(null, set):String;
    private function set_styleString(value:String):String {
        if (value == null) {
            return value;
        }
        var cssString = StringTools.trim(value);
        if (cssString.length == 0) {
            return value;
        }
        if (StringTools.endsWith(cssString, ";") == false) {
            cssString += ";";
        }
        cssString = "_ { " + cssString + "}";
        var s = new Parser().parseRules(cssString)[0].s;
        customStyle.apply(s);
        _styleString = value;
        return value;
    }

    private var _style:Style;
    /**
     The calculated style of this component
    **/
    @:dox(group="Style related properties and methods")
    public var style(get, set):Style;
    private function get_style():Style {
        return _style;
    }

    private function set_style(value):Style {
        _style = value;
        return value;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var __events:EventMap;

    /**
     Register a listener for a certain `UIEvent`
    **/
    @:dox(group="Event related properties and methods")
    public function registerEvent(type:String, listener:Dynamic->Void) {
        if (__events == null) {
            __events = new EventMap();
        }
        if (__events.add(type, listener) == true) {
            mapEvent(type, _onMappedEvent);
        }
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group="Event related properties and methods")
    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (__events != null) {
            if (__events.remove(type, listener) == true) {
                unmapEvent(type, _onMappedEvent);
            }
        }
    }

    /**
     Dispatch a certain `UIEvent`
    **/
    @:dox(group="Event related properties and methods")
    public function dispatch(event:UIEvent) {
        if (__events != null) {
            __events.invoke(event.type, event, this);
        }
    }

    private function _onMappedEvent(event:UIEvent) {
        dispatch(event);
    }

    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    private var _includeInLayout:Bool = true;
    /**
     Whether to use this component as part of its part layout

     _Note_: Invisible components are not included in parent layouts
    **/
    @:dox(group="Layout related properties and methods")
    public var includeInLayout(get, set):Bool;
    private function get_includeInLayout():Bool {
        return _includeInLayout && !_hidden;
    }
    private function set_includeInLayout(value:Bool):Bool {
        _includeInLayout = value;
        return value;
    }

    private var _layout:Layout;
    /**
     The layout of this component
    **/
    @:dox(group="Layout related properties and methods")
    public var layout(get, set):Layout;
    private function get_layout():Layout {
        return _layout;
    }
    private function set_layout(value:Layout):Layout {
        if (value == null) {
            //_layout = null;
            return value;
        }
        _layout = value;
        _layout.component = this;
        return value;
    }

    //***********************************************************************************************************
    // Event handlers
    //***********************************************************************************************************
    private var _ready:Bool = false;
    /**
     Whether the framework considers this component ready or not
    **/
    public var isReady(get, null):Bool;
    private function get_isReady():Bool {
        return _ready;
    }

    /**
     Tells the framework this component is ready

     _Note_: this is called internally by the framework
    **/
    public function ready() {
        if (_ready == false) {
            invalidateStyle(false);

            _ready = true;
            handleReady();

            if (childComponents != null) {
                for (child in childComponents) {
                    child.ready();
                }
            }

            if (autoWidth == true || autoHeight == true) {
                var s:Size = layout.calcAutoSize();
                var calculatedWidth:Null<Float> = null;
                var calculatedHeight:Null<Float> = null;
                if (autoWidth == true) {
                    calculatedWidth = s.width;
                }
                if (autoHeight == true) {
                    calculatedHeight = s.height;
                }
                resizeComponent(calculatedWidth, calculatedHeight);
            } else {
                invalidateDisplay();
            }
            invalidateLayout();

            onReady();
        }
    }

    private function onReady() {
        behavioursUpdate();

        handleBindings(["text", "value", "width", "height"]);
        initScript();
    }

    private function onResized() {

    }

    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    @style      public var backgroundColor:Int;
    @style      public var borderColor:Int;
    @style      public var borderSize:Float;
    @style      public var borderRadius:Float;

    @style      public var paddingLeft:Float;
    @style      public var paddingRight:Float;
    @style      public var paddingTop:Float;
    @style      public var paddingBottom:Float;

    @style      public var marginLeft:Float;
    @style      public var marginRight:Float;
    @style      public var marginTop:Float;
    @style      public var marginBottom:Float;
    @style      public var clip:Bool;

    @style      public var opacity:Float;

    //***********************************************************************************************************
    // Size related
    //***********************************************************************************************************
    /**
     Whether this component will automatically resize itself based on it childrens calculated width
    **/
    @:dox(group="Size related properties and methods")
    public var autoWidth(get, null):Bool;
    private function get_autoWidth():Bool {
        if (_percentWidth != null || _width != null || style == null) {
            return false;
        }
        if (style.autoWidth == null) {
            return false;
        }
        return style.autoWidth;
    }

    /**
     Whether this component will automatically resize itself based on it childrens calculated height
    **/
    @:dox(group="Size related properties and methods")
    public var autoHeight(get, null):Bool;
    private function get_autoHeight():Bool {
        if (_percentHeight != null || _height  != null || style == null) {
            return false;
        }
        if (style.autoHeight == null) {
            return false;
        }
        return style.autoHeight;
    }

    /**
     Resize this components width and height in one call
    **/
    @:dox(group="Size related properties and methods")
    public function resizeComponent(width:Null<Float>, height:Null<Float>) {
        if (_ready == false) {
            //return;
        }

        var invalidate:Bool = false;
        if (width != null && _componentWidth != width) {
            _componentWidth = width;

            invalidate = true;
        }

        if (height != null && _componentHeight != height) {
            _componentHeight = height;

            invalidate = true;
        }

        if (invalidate == true) {
            invalidateDisplay();
            invalidateLayout();

            onResized();
            dispatch(new UIEvent(UIEvent.RESIZE));

            if (parentComponent != null) {
                parentComponent.invalidateLayout();
            }
        }
    }

    /**
     Autosize this component based on its children
    **/
    @:dox(group="Size related properties and methods")
    private function autoSize():Bool {
        if (_ready == false || _layout == null) {
           return false;
        }
        return layout.autoSize();
    }

    @clonable private var _percentWidth:Null<Float>;
    /**
     What percentage of this components parent to use to calculate its width
    **/
    @:dox(group="Size related properties and methods")
    @clonable @bindable public var percentWidth(get, set):Null<Float>;
    private function get_percentWidth():Null<Float> {
        return _percentWidth;
    }
    private function set_percentWidth(value:Null<Float>):Null<Float> {
        if (_percentWidth == value) {
            return value;
        }

        _percentWidth = value;

        if (parentComponent != null) {
            parentComponent.invalidateLayout();
        }
        return value;
    }

    @clonable private var _percentHeight:Null<Float>;
    /**
     What percentage of this components parent to use to calculate its height
    **/
    @:dox(group="Size related properties and methods")
    @clonable @bindable public var percentHeight(get, set):Null<Float>;
    private function get_percentHeight():Null<Float> {
        return _percentHeight;
    }
    private function set_percentHeight(value:Null<Float>):Null<Float> {
        if (_percentHeight == value) {
            return value;
        }
        _percentHeight = value;

        if (parentComponent != null) {
            parentComponent.invalidateLayout();
        }
        return value;
    }

    /**
     Whether or not a point is inside this components bounds

     _Note_: `left` and `top` must be stage (screen) co-ords
    **/
    @:dox(group="Size related properties and methods")
    public function hitTest(left:Float, top:Float):Bool { // co-ords must be stage
        var b:Bool = false;
        var sx:Float = screenLeft;
        var sy:Float = screenTop;
        var cx:Float = 0;
        if (componentWidth != null) {
            cx = componentWidth;
        }
        var cy:Float = 0;
        if (componentHeight != null) {
            cy = componentHeight;
        }

        if (cx <= 0 || cy <= 0) {
            return false;
        }

        if (left > sx && left < sx + cx && top > sy && top < sy + cy) {
            b = true;
        }

        return b;
    }

    private var _componentWidth:Null<Float>;
    @:allow(haxe.ui.layouts.Layout)
    @:allow(haxe.ui.core.Screen)
    /**
     The calculated width of this component
    **/
    @:dox(group="Size related properties and methods")
    private var componentWidth(get, set):Null<Float>;
    private function get_componentWidth():Null<Float> {
        if (_componentWidth == null) {
            return 0;
        }
        return _componentWidth;
    }
    private function set_componentWidth(value:Null<Float>):Null<Float> {
        resizeComponent(value, null);
        return value;
    }


    private var _componentHeight:Null<Float>;
    @:allow(haxe.ui.layouts.Layout)
    @:allow(haxe.ui.core.Screen)
    /**
     The calculated height of this component
    **/
    @:dox(group="Size related properties and methods")
    private var componentHeight(get, set):Null<Float>;
    private function get_componentHeight():Null<Float> {
        if (_componentHeight == null) {
            return 0;
        }
        return _componentHeight;
    }
    private function set_componentHeight(value:Null<Float>):Null<Float> {
        resizeComponent(null, value);
        return value;
    }

    #if haxeui_openfl

    private var _width:Null<Float>;
    #if flash @:setter(width) #else override #end
    public function set_width(value:Float): #if flash Void #else Float #end {
        if (_width == value) {
            return #if !flash value #end;
        }
        _width = value;
        componentWidth = value;
        #if !flash return value; #end
    }

    #if flash @:getter(width) #else override #end
    public function get_width():Float {
        var f:Float = _width;
        return f;
    }

    private var _height:Null<Float>;
    #if flash @:setter(height) #else override #end
    public function set_height(value:Float): #if flash Void #else Float #end {
        if (_height == value) {
            return #if !flash value #end;
        }
        _height = value;
        componentHeight = value;
        #if !flash return value; #end
    }

    #if flash @:getter(height) #else override #end
    public function get_height():Float {
        var f:Float = _height;
        return f;
    }

    #else

    /**
     The width of this component
    **/
    @:dox(group="Size related properties and methods")
    @clonable @bindable public var width(get, set):Float;
    private var _width:Null<Float>;
    private function set_width(value:Float):Float {
        if (_width == value) {
            return value;
        }
        _width = value;
        componentWidth = value;
        return value;
    }

    private function get_width():Float {
        var f:Float = _width;
        return f;
    }

    /**
     The height of this component
    **/
    @:dox(group="Size related properties and methods")
    @clonable @bindable public var height(get, set):Float;
    private var _height:Null<Float>;
    private function set_height(value:Float):Float {
        if (_height == value) {
            return value;
        }
        _height = value;
        componentHeight = value;
        return value;
    }

    private function get_height() {
        var f:Float = _height;
        return f;
    }

    #end

    //***********************************************************************************************************
    // Position related
    //***********************************************************************************************************
    /**
     Move this components left and top co-ord in one call
    **/
    @:dox(group="Position related properties and methods")
    public function moveComponent(left:Null<Float>, top:Null<Float>) {
        if (_ready == false) {
            return;
        }

        var invalidate:Bool = false;
        if (left != null && _left != left) {
            _left = left;
            invalidate = true;
        }
        if (top != null && _top != top) {
            _top = top;
            invalidate = true;
        }

        if (invalidate == true) {
            handlePosition(_left, _top, _style);
        }
    }

    private var _left:Null<Float> = 0;
    /**
     The left co-ord of this component relative to its parent
    **/
    @:dox(group="Position related properties and methods")
    public var left(get, set):Null<Float>;
    private function get_left():Null<Float> {
        return _left;
    }
    private function set_left(value:Null<Float>):Null<Float> {
        moveComponent(value, null);
        return value;
    }

    private var _top:Null<Float> = 0;
    /**
     The top co-ord of this component relative to its parent
    **/
    @:dox(group="Position related properties and methods")
    public var top(get, set):Null<Float>;
    private function get_top():Null<Float> {
        return _top;
    }
    private function set_top(value:Null<Float>):Null<Float> {
        moveComponent(null, value);
        return value;
    }

    /**
     The left co-ord of this component relative to the screen
    **/
    @:dox(group="Position related properties and methods")
    public var screenLeft(get, null):Float;
    private function get_screenLeft():Float {
        var c:Component = this;
        var xpos:Float = 0;
        while (c != null) {
            xpos += c.left;
            /*
            if (c.sprite.scrollRect != null) {
                xpos -= c.sprite.scrollRect.left;
            }
            */
            c = c.parentComponent;
        }
        return xpos;
    }

    /**
     The top co-ord of this component relative to the screen
    **/
    @:dox(group="Position related properties and methods")
    public var screenTop(get, null):Float;
    private function get_screenTop():Float {
        var c:Component = this;
        var ypos:Float = 0;
        while (c != null) {
            ypos += c.top;
            /*
            if (c.sprite.scrollRect != null) {
                ypos -= c.sprite.scrollRect.top;
            }
            */
            c = c.parentComponent;
        }
        return ypos;
    }

    //***********************************************************************************************************
    // Script related
    //***********************************************************************************************************
    /**
     Whether or not this component is allowed to be exposed to script interpreters (defaults to _true_)
    **/
    @:dox(group="Script related properties and methods")
    public var scriptAccess:Bool = true;

    private var _interp:ScriptInterp;
    private var _script:String;
    /**
     A script string to associate with this component

     _Note_: Setting this to non-null will cause this component to create and maintain its own script interpreter during initialsation
    **/
    @:dox(group="Script related properties and methods")
    public var script(null, set):String;
    private function set_script(value:String):String {
        _script = value;
        return value;
    }

    /**
     Execute a script call

     _Note_: This component will first attempt to use its own script interpreter if its avialable otherwise it will scan its parents until it finds one
    **/
    @:dox(group="Script related properties and methods")
    public function executeScriptCall(expr:String) {
        #if allow_script_errors
        try {
        #end
            var parser = new hscript.Parser();
            var line = parser.parseString(expr);
            var interp:ScriptInterp = findScriptInterp();
            interp.variables.set("this", this);
            interp.expr(line);
            interp.variables.remove("this");
        #if allow_script_errors
        } catch (e:Dynamic) {
            trace("Problem executing scriptlet: " + e);
            #if debug
                CallStackHelper.traceExceptionStack();
            #end
        }
        #end
    }

    private function findScriptInterp(refreshNamedComponents:Bool = true):ScriptInterp {
        var interp:ScriptInterp = null;
        var c:Component = this;
        while (c != null && interp == null) {
            if (c._interp != null) {
                interp = c._interp;
                break;
            }
            c = c.parentComponent;
        }

        if (interp == null) {
            c = rootComponent;
            c._interp = new ScriptInterp();
            interp = c._interp;
        }

        if (refreshNamedComponents == true && c != null) {
            var comps:Array<Component> = c.namedComponents;
            for (comp in comps) {
                var safeId = StringUtil.capitalizeHyphens(comp.id);
                interp.variables.set(safeId, comp);
            }
        }

        return interp;
    }

    private function initScript():Void {
        if (_script != null) {
            try {
                var parser = new hscript.Parser();
                var program = parser.parseString(_script);
                _interp = new ScriptInterp();

                var comps:Array<Component> = namedComponents;
                for (comp in comps) {
                    if (comp.scriptAccess == true) {
                        var safeId = StringUtil.capitalizeHyphens(comp.id);
                        _interp.variables.set(safeId, comp);
                    }
                }

                _interp.execute(program);
            } catch (e:Dynamic) {
                trace("Problem initializing script: " + e);
                CallStackHelper.traceExceptionStack();
            }
        }
    }

    private var _scriptEvents:Map<String, String>;
    /**
     Registers a piece of hscript to be execute when a certain `UIEvent` is fired
    **/
    @:dox(group="Script related properties and methods")
    public function addScriptEvent(event:String, script:String):Void {
        event = event.toLowerCase();
        if (_scriptEvents == null) {
            _scriptEvents = new Map<String, String>();
        }
        _scriptEvents.set(event, script);
        switch (event) {
            case "onclick":
                registerEvent(MouseEvent.CLICK, _onScriptClick);
            case "onchange":
                registerEvent(UIEvent.CHANGE, _onScriptChange);
        }
    }

    private function _onScriptClick(event:MouseEvent):Void {
        if (_scriptEvents != null) {
            var script:String = _scriptEvents.get("onclick");
            if (script != null) {
                executeScriptCall(script);
            }
        }
    }

    private function _onScriptChange(event:UIEvent):Void {
        if (_scriptEvents != null) {
            var script:String = _scriptEvents.get("onchange");
            if (script != null) {
                executeScriptCall(script);
            }
        }
    }

    /**
     Recursively generates list of all child components that have specified an `id`
    **/
    @:dox(group="Script related properties and methods")
    public var namedComponents(get, null):Array<Component>;
    private function get_namedComponents():Array<Component> {
        var list:Array<Component> = new Array<Component>();
        addNamedComponentsFrom(this, list);
        return list;
    }

    private static function addNamedComponentsFrom(parent:Component, list:Array<Component>):Void {
        if (parent == null) {
            return;
        }

        if (parent.id != null) {
            list.push(parent);
        }

        for (child in parent.childComponents) {
            addNamedComponentsFrom(child, list);
        }
    }

    private var __onClick:UIEvent->Void;
    /**
     Utility property to add a single `UIEvent.CLICK` event
    **/
    @:dox(group="Event related properties and methods")
    public var onClick(null, set):UIEvent->Void;
    private function set_onClick(value:UIEvent->Void):UIEvent->Void {
        if (__onClick != null) {
            unregisterEvent(MouseEvent.CLICK, __onClick);
            __onClick = null;
        }
        registerEvent(MouseEvent.CLICK, value);
        __onClick = value;
        return value;
    }

    /**
     Utility property to add a single `UIEvent.CHANGE` event
    **/
    @:dox(group="Event related properties and methods")
    public var onChange(null, set):UIEvent->Void;
    private function set_onChange(value:UIEvent->Void):UIEvent->Void {
        registerEvent(UIEvent.CHANGE, value);
        return value;
    }


    //***********************************************************************************************************
    // Invalidation
    //***********************************************************************************************************
    private var _layoutInvalidating:Bool = false;
    private var _layoutReinvalidation:Bool = false;
    /**
     Invalidate this components layout, may result in multiple calls to `invalidateDisplay` and `invalidateLayout` of its children
    **/
    @:dox(group="Invalidation related properties and methods")
    public function invalidateLayout() {
        if (_ready == false) {
            return;
        }

        if (_layoutInvalidating == true) {
            // means that if a request to invalidate comes through and were busy
            // (like async resources), we make note to invalidate when were done
            _layoutReinvalidation = true;
            return;
        }

        _layoutInvalidating = true;

        layout.refresh();

        _layoutInvalidating = false;

        if (_layoutReinvalidation == true) {
            _layoutReinvalidation = false;
            invalidateLayout();
        }
    }

    private var _displayingInvalidating:Bool = false;
    /**
     Invalidate the visible aspect of this component
    **/
    @:dox(group="Invalidation related properties and methods")
    public function invalidateDisplay() {
        if (_ready == false) {
            return;
        }

        if (_displayingInvalidating == true) {
            return;
        }

        if (componentWidth == null || componentHeight == null || componentWidth <= 0 || componentHeight <= 0) {
            return;
        }

        _displayingInvalidating = true;

        handleSize(componentWidth, componentHeight, _style);

        _displayingInvalidating = false;
    }

    /**
     Invalidate and recalculate this components style, may result in a call to `invalidateDisplay`
    **/
    @:dox(group="Invalidation related properties and methods")
    public function invalidateStyle(invalidate:Bool = true) {
        var s:Style = Toolkit.styleSheet.applyClasses(this, false);
        if (_ready == false || _style == null || _style.equalTo(s) == false) { // lets not update if nothing has changed
            _style = s;
            applyStyle(_style);
            if (invalidate == true) {
                invalidateDisplay();
            }
        }
    }

    private override function applyStyle(style:Style):Void {
        super.applyStyle(style);

        if (style.percentWidth != null) {
            percentWidth = style.percentWidth;
        }
        if (style.percentHeight != null) {
            percentHeight = style.percentHeight;
        }
        if (style.width != null) {
            width = style.width;
        }
        if (style.height != null) {
            height = style.height;
        }

        if (style.native != null) {
            native = style.native;
        }

        /*
        if (style.clip != null) {
            clipContent = style.clip;
        }

        if (style.native != null) {
            if (style.backgroundImageSliceTop == null
                && style.backgroundImageSliceLeft == null
                && style.backgroundImageSliceBottom == null
                && style.backgroundImageSliceRight == null) {
                native = style.native;
            }
        }

        if (style.backgroundImageSliceTop != null
            && style.backgroundImageSliceLeft != null
            && style.backgroundImageSliceBottom != null
            && style.backgroundImageSliceRight != null) {
            native = false;
        }
        */
    }

    //***********************************************************************************************************
    // Properties
    //***********************************************************************************************************
    private function getProperty(name:String):Variant {
        switch (name) {
            case "value":       return this.value;
            case "width":       return this.width;
            case "height":      return this.height;
        }
        return null;
    }

    private function setProperty(name:String, value:Variant):Variant {
        switch (name) {
            case "value":       return this.value = value;
            case "width":       return this.width = value;
            case "height":      return this.height = value;
        }
        return null;
    }

    /**
     Gets a property that is associated with all classes of this type
    **/
    public function getClassProperty(name:String):String {
        var v = null;
        if (_classProperties != null) {
            v = _classProperties.get(name);
        }
        if (v == null) {
            var c = Type.getClassName(Type.getClass(this)).toLowerCase() + "." + name;
            v = Toolkit.properties.get(c);
        }
        return v;
    }

    private var _classProperties:Map<String, String>;
    /**
     Sets a property that is associated with all classes of this type
    **/
    public function setClassProperty(name:String, value:String) {
        if (_classProperties == null) {
            _classProperties = new Map<String, String>();
        }
        _classProperties.set(name, value);
    }
}