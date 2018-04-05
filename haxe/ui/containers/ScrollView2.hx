package haxe.ui.containers;

import haxe.ui.components.HorizontalScroll2;
import haxe.ui.components.VerticalScroll2;
import haxe.ui.core.Component;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Rectangle;
import haxe.ui.validation.InvalidationFlags;

class ScrollView2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() {
        super.createChildren();
        createContentContainer();
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private inline function invalidateScroll() {
        invalidate(InvalidationFlags.SCROLL);
    }

    private override function validateInternal() {
        var scrollInvalid = isInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isInvalid(InvalidationFlags.LAYOUT);

        super.validateInternal();

        if (scrollInvalid || layoutInvalid) {
            validateScroll();
        }
    }

    private function validateScroll() {
        /*
        if(behaviourGet("hscrollPos") != _hscrollPos)
        {
            behaviourSet("hscrollPos", _hscrollPos);
            handleBindings(["hscrollPos"]);
        }

        if(behaviourGet("vscrollPos") != _vscrollPos)
        {
            behaviourSet("vscrollPos", _vscrollPos);
            handleBindings(["vscrollPos"]);
        }
        */

        //checkScrolls();
        updateScrollRect();
    }
    
    private function updateScrollRect() {
        if (_contents == null) {
            return;
        }

        var usableSize = layout.usableSize;

        var clipCX = usableSize.width;
        if (clipCX > _contents.width) {
            clipCX = _contents.width;
        }
        var clipCY = usableSize.height;
        if (clipCY > _contents.height) {
            clipCY = _contents.height;
        }

        var xpos:Float = 0;
        /*
        if (_hscroll != null) {
            xpos = _hscroll.pos;
        }
        */
        var ypos:Float = 0;
        /*
        if (_vscroll != null) {
            ypos = _vscroll.pos;
        }
        */
        

        var rc:Rectangle = new Rectangle(Std.int(xpos), Std.int(ypos), clipCX, clipCY);
        _contents.componentClipRect = rc;
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private var _contents:Box;
    private function createContentContainer() {
        if (_contents == null) {
            _contents = new Box();
            _contents.addClass("scrollview-contents");
            _contents.id = "temp";
            //_contents.registerEvent(UIEvent.RESIZE, _onContentsResized);
            _contents.layout = LayoutFactory.createFromName("vertical"); // TODO: temp
            addComponent(_contents);
        }
    }
    
    public override function addComponent(child:Component):Component {
        var v = null;
        if (Std.is(child, HorizontalScroll2) || Std.is(child, VerticalScroll2) || child == _contents) {
            v = super.addComponent(child);
        } else {
            createContentContainer();
            v = _contents.addComponent(child);
        }
        return v;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

//***********************************************************************************************************
// Events
//***********************************************************************************************************

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
