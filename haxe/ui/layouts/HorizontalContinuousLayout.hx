package haxe.ui.layouts;
import haxe.ui.util.Size;

class HorizontalContinuousLayout extends HorizontalLayout {
    public function new() {
        super();
    }
    
    private override function repositionChildren() {
        if (component.autoWidth == true) {
            super.repositionChildren();
            return;
        }
        
        var ucx:Float = usableWidth;
        if (ucx <= 0) {
            return;
        }
        
        // lets build the row heights first
        var xpos = paddingLeft;
        var yoffset:Float = 0;
        var rowCY:Float = 0;
        var rowHeights:Array<Float> = new Array<Float>();
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.componentHeight > rowCY) {
                rowCY = child.componentHeight;
            }
            
            if (xpos + child.componentWidth > ucx) {
                rowHeights.push(rowCY);
                xpos = paddingLeft;
                yoffset += rowCY;
                rowCY = 0;
            }
            
            xpos += child.componentWidth + horizontalSpacing;
        }
        if (rowCY > 0) {
            rowHeights.push(rowCY);
        }
        
        var xpos = paddingLeft;
        var yoffset:Float = 0;
        var n:Int = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            var ypos:Float = 0;
            
            if (xpos + child.componentWidth > ucx) {
                xpos = paddingLeft;
                yoffset += rowHeights[n] + verticalSpacing;
                n++;
            }
            
            switch (verticalAlign(child)) {
                case "center":
                    ypos = (((rowHeights[n] + verticalSpacing + paddingTop) / 2) - (child.componentHeight / 2)) + marginTop(child) - marginBottom(child);
                case "bottom":
                    ypos = rowHeights[n] - child.componentHeight + paddingTop + marginTop(child) - marginBottom(child);
                default:
                    ypos = paddingTop + marginTop(child) - marginBottom(child);
            }
            
            child.moveComponent(xpos + marginLeft(child) - marginRight(child), ypos + yoffset);
            xpos += child.componentWidth + horizontalSpacing;
        }
    }

    private override function get_usableSize():Size {
        var ucx:Float = 0;
        if (_component.componentWidth != null) {
            ucx = _component.componentWidth;
            ucx -= paddingLeft + paddingRight;
        }

        var ucy:Float = 0;
        if (_component.componentHeight != null) {
            ucy = _component.componentHeight;
            ucy -= paddingTop + paddingBottom;
        }

        return new Size(ucx, ucy);
    }
}