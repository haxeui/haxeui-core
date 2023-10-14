package haxe.ui.layouts;

import haxe.ui.geom.Size;

class VerticalLayout extends DefaultLayout {
    public function new() {
        super();
        _calcFullHeights = true;
    }

    private override function repositionChildren() {
        var ypos = paddingTop;
        var items = getLayoutItems();

        for (child in items.children) {
            var xpos:Float = 0;

            switch (child.horizontalAlign) {
                case "center":
                    xpos = ((items.usableSize.width - child.width) / 2) + paddingLeft + child.marginLeft - child.marginRight;
                case "right":
                    if (child.width < component.width) {
                        xpos = component.width - (child.width + paddingRight + child.marginLeft);
                    }
                default:
                    xpos = paddingLeft + child.marginLeft;
            }

            child.moveComponent(xpos, ypos + child.marginTop);
            ypos += child.height + verticalSpacing;
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var items = getLayoutItems();

        var visibleChildren = items.children.length;
        for (child in items.children) {
            if (child.height > 0 && child.percentHeight == null) { // means its a fixed height, ie, not a % sized control
                size.height -= child.height + child.marginTop + child.marginBottom;
            }
        }

        if (visibleChildren > 1) {
            size.height -= verticalSpacing * (visibleChildren - 1);
        }

        if (size.height < 0) {
            size.height = 0;
        }
        return size;
    }
}