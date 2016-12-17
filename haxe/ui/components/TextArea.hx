package haxe.ui.components;

class TextArea /* extends InteractiveComponent implements IFocusable implements IClonable<TextArea> */ {
    public function new() {
        /*
        super();
        addClass("textfield");
        */
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    /*
    private override function createDefaults() {
        _defaultBehaviours = [
            "text" => new TextAreaDefaultTextBehaviour(this)
        ];
        _defaultLayout = new TextAreaLayout();
    }

    private override function create() {
        super.create();
        if (_text == null) {
            behaviourSet("text", "");
        }

        getTextInput().element.onscroll = function(e) {
            checkScrolls();
            //trace("scrolltop: " + getTextInput().element.scrollTop);
            var input:TextInput = getTextInput();
            if (_hscroll != null) {
                //_vscroll.pos = input.element.scrollTop + input.element.offsetHeight;
                _hscroll.pos = input.element.scrollLeft;
            }
            if (_vscroll != null) {
                //_vscroll.pos = input.element.scrollTop + input.element.offsetHeight;
                _vscroll.pos = input.element.scrollTop;
            }
        }
        getTextInput().element.onkeydown = function(e) {
            checkScrolls();
        }
        getTextInput().element.onkeyup = function(e) {
            checkScrolls();
        }
        getTextInput().element.onkeypress = function(e) {
            checkScrolls();
        }
        checkScrolls();
    }

    private override function onResized() {
        super.onResized();
        checkScrolls();
    }

    private override function onReady() {
        super.onReady();
        checkScrolls();
    }

    private var _vscroll:VScroll;
    private var _hscroll:HScroll;
    private function checkScrolls() {
        var input:TextInput = getTextInput();

        if (input.element.scrollWidth > layout.usableWidth) {
            if (_hscroll == null) {
                _hscroll = new HScroll();
                _hscroll.includeInLayout = false;
                _hscroll.percentWidth = 100;
                _hscroll.registerEvent(UIEvent.CHANGE, _onScroll);
                addComponent(_hscroll);
                checkScrolls();
                return;
            }

            _hscroll.max = input.element.scrollWidth - input.element.offsetWidth;
            //_vscroll.max = input.element.scrollHeight;
            //trace("_vscroll.max  = " + _vscroll.max);
            _hscroll.pageSize = (input.element.offsetWidth / input.element.scrollWidth) * _hscroll.max;

            _hscroll.show();
        } else {
            if (_hscroll != null) {
                _hscroll.hide();
            }
        }


        if (input.element.scrollHeight > layout.usableHeight) {
            if (_vscroll == null) {
                _vscroll = new VScroll();
                _vscroll.includeInLayout = false;
                _vscroll.percentHeight = 100;
                _vscroll.registerEvent(UIEvent.CHANGE, _onScroll);
                addComponent(_vscroll);
                checkScrolls();
                return;
            }

            _vscroll.max = input.element.scrollHeight - input.element.offsetHeight;
            //_vscroll.max = input.element.scrollHeight;
            //trace("_vscroll.max  = " + _vscroll.max);
            _vscroll.pageSize = (input.element.offsetHeight / input.element.scrollHeight) * _vscroll.max;

            _vscroll.show();
        } else {
            if (_vscroll != null) {
                _vscroll.hide();
            }
        }

        invalidateLayout();
    }

    private override function createChildren() {
        if (componentWidth == 0) {
            componentWidth = 150;
        }

        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        registerEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        unregisterEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private function _onScroll(event:UIEvent) {
        var input:TextInput = getTextInput();
        input.element.scrollLeft = Std.int(_hscroll.pos);
        input.element.scrollTop = Std.int(_vscroll.pos);
    }
    */

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    /*
    private function _onTextChanged(event:UIEvent) {
        handleBindings(["text", "value"]);
    }

    private function _onMouseDown(event:MouseEvent) {
        FocusManager.instance.focus = this;
    }
    */

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    /*
    private override function get_text():String {
        return behaviourGet("text");
    }

    private override function set_text(value:String):String {
        if (value == _text) {
            return value;
        }

        value = super.set_text(value);
        behaviourSet("text", value);
        return value;
    }
    */
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
/*
@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value.isNull) {
            return;
        }

        var textArea:TextArea = cast _component;
        textArea.getTextInput().multiline = true;
        //textArea.getTextInput().wordWrap = true;
        textArea.getTextInput().text = value;
        textArea.checkScrolls();
        //textArea.invalidateDisplay();
    }

    public override function get():Variant {
        var textArea:TextArea = cast _component;
        return textArea.getTextInput().text;
    }
}
*/

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
/*
@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaLayout extends DefaultLayout {
    private override function repositionChildren() {
        var xpos:Float = paddingLeft;
        var ypos:Float = paddingTop;
        if (component.hasTextInput() == true) {
            component.getTextInput().left = xpos;
            component.getTextInput().top = ypos;
        }

        var vscroll = component.findComponent(VScroll);
        var hscroll = component.findComponent(HScroll);

        var ucx = innerWidth;
        var ucy = innerHeight;

        if (hscroll != null && hidden(hscroll) == false) {
            hscroll.left = 1;
            hscroll.top = ucy - hscroll.componentHeight + paddingTop + paddingBottom - 1;
        }

        if (vscroll != null && hidden(vscroll) == false) {
            vscroll.left = ucx - vscroll.componentWidth + paddingLeft + paddingRight - 1;
            vscroll.top = 1;
        }
    }

    private override function resizeChildren() {
        super.resizeChildren();

        var size:Size = usableSize;
        if (component.hasTextInput() == true) {
            component.getTextInput().width = size.width;
            component.getTextInput().height = size.height;
        }

        var hscroll = component.findComponent(HScroll);
        if (hscroll != null) {
            hscroll.componentWidth = size.width + paddingLeft + paddingRight - 2;
        }

        var vscroll = component.findComponent(VScroll);
        if (vscroll != null) {
            vscroll.componentHeight = size.height + paddingTop + paddingBottom - 2;
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var hscroll = component.findComponent(HScroll);
        var vscroll = component.findComponent(VScroll);
        if (hscroll != null && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight;
        }
        if (vscroll != null && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth;
        }

        return size;
    }

    public override function calcAutoSize():Size {
        var size:Size = super.calcAutoSize();
        if (component.hasTextInput() == true) {
            if (component.getTextInput().textWidth + paddingLeft + paddingRight > size.width) {
                size.width = component.getTextInput().textWidth + paddingLeft + paddingRight;
            }
            if (component.getTextInput().textHeight + paddingTop + paddingBottom > size.height) {
                size.height = component.getTextInput().textHeight + paddingTop + paddingBottom;
            }
        }

        return size;
    }
}
*/