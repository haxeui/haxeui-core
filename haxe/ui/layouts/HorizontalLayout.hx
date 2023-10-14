package haxe.ui.layouts;

import haxe.ui.geom.Size;

class HorizontalLayout extends DefaultLayout {
    public function new() {
        super();
        _calcFullWidths = true;
        _roundFullWidths = true;
    }

    private override function repositionChildren() {
        var xpos = paddingLeft;
        var items = getLayoutItems();
        var visibleChildren = items.children.length;
        
        var evenlySpace  = false;
        var aroundSpace  = false;
        var betweenSpace = false;
        if (component.style != null) {
            if (component.style.justifyContent == "space-between" ) betweenSpace = true;
            // The empty space before the first and after the last item equals half of the spacing between the items
            if (component.style.justifyContent == "space-evenly" )  evenlySpace  = true;
            //  The empty space before the first and after the last item equals the spacing between the items
            if (component.style.justifyContent == "space-around")   aroundSpace  = true;
        }

        var spacing:Float = horizontalSpacing;
        
        if (betweenSpace) {
            spacing = items.usableSize.width / (visibleChildren - 1) + horizontalSpacing;
        } else if (aroundSpace){
            spacing = items.usableSize.width / (visibleChildren - 1) + horizontalSpacing;
        }  else if (evenlySpace){
            spacing = (items.usableSize.width + horizontalSpacing * (visibleChildren - 1))  / (visibleChildren + 1);
        }

        for (child in items.children) {
            var ypos:Float = 0;

            switch (child.verticalAlign) {
                case "center":
                    ypos = ((items.usableSize.height - child.height) / 2) + paddingTop + child.marginTop - child.marginBottom;
                case "bottom":
                    if (child.height < component.height) {
                        ypos = component.height - (child.height + paddingBottom + child.marginTop);
                    }
                default:
                    ypos = paddingTop + child.marginTop;
            }

            if (aroundSpace) {
                child.moveComponent(xpos + spacing / 2 + child.marginLeft, ypos);
            } else if (evenlySpace) {
                child.moveComponent(xpos + spacing + child.marginLeft, ypos);
            } else {
                child.moveComponent(xpos + child.marginLeft, ypos);
            }
            xpos += child.width + spacing;
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();

        var items = getLayoutItems();
        var visibleChildren = items.children.length;
        for (child in items.children) {
            if (child.width > 0 && child.percentWidth == null) { // means its a fixed width, ie, not a % sized control
                size.width -= child.width + child.marginLeft + child.marginRight;
            }
        }

        if (visibleChildren > 1) {
            size.width -= horizontalSpacing * (visibleChildren - 1);
        }

        if (size.width < 0) {
            size.width = 0;
        }

        return size;
    }
}