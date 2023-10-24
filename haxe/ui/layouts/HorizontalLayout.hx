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
        var usableSize = this.usableSize;

        var visibleChildren = component.childComponents.length;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                visibleChildren--;
                continue;
            }
        }
        
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
            spacing =   usableSize.width / (visibleChildren - 1) + horizontalSpacing;
        }
        else if (aroundSpace){
            spacing = (usableSize.width + horizontalSpacing * (visibleChildren - 1))  / visibleChildren ;
        }
        else if (evenlySpace){
            spacing = (usableSize.width + horizontalSpacing * (visibleChildren - 1))  / (visibleChildren + 1)  ;
        }

        
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var ypos:Float = 0;

            switch (verticalAlign(child)) {
                case "center":
                    ypos = ((usableSize.height - child.componentHeight) / 2) + paddingTop + marginTop(child) - marginBottom(child);
                case "bottom":
                    if (child.componentHeight < component.componentHeight) {
                        ypos = component.componentHeight - (child.componentHeight + paddingBottom + marginTop(child));
                    }
                default:
                    ypos = paddingTop + marginTop(child);
            }

            if (aroundSpace) {
                child.moveComponent(xpos + spacing / 2 + marginLeft(child), ypos);
            }
            else if (evenlySpace) {
                child.moveComponent(xpos + spacing + marginLeft(child), ypos);
            }
            else {
                child.moveComponent(xpos + marginLeft(child), ypos);
            }
            xpos += child.componentWidth + spacing;
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();

        var visibleChildren = component.childComponents.length;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                visibleChildren--;
                continue;
            }

            if (child.componentWidth > 0 && (child.percentWidth == null || fixedMinWidth(child) == true)) { // means its a fixed width, ie, not a % sized control
                size.width -= child.componentWidth + marginLeft(child) + marginRight(child);
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