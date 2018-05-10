package haxe.ui.layouts;

import haxe.ui.util.Size;

class VerticalGridLayout extends Layout {
    private var _columns:Int = 1;
    public var columns(get, set):Int;
    private function get_columns():Int {
        return _columns;
    }
    private function set_columns(value:Int):Int {
        if(_columns == value) {
            return value;
        }

        _columns = value;
        if (_component != null) {
            _component.invalidateComponentLayout();
        }
        return value;
    }

    public function new() {
        super();
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var columnWidths:Array<Float> = calcColumnWidths(size, false);
        var rowHeights:Array<Float> = calcRowHeights(size, false);

        for(columnWidth in columnWidths) {
            size.width -= columnWidth;
        }

        for(rowHeight in rowHeights) {
            size.height -= rowHeight;
        }

        if (component.childComponents.length > 1) {
            var rows:Int = Math.ceil(component.childComponents.length / columns);
            size.width -= horizontalSpacing * (columns - 1);
            size.height -= verticalSpacing * (rows - 1);
        }

        if (size.width < 0) {
            size.width = 0;
        }

        if (size.height < 0) {
            size.height = 0;
        }
        return size;
    }

    private override function resizeChildren() {
        var size:Size = usableSize;
        var columnWidths:Array<Float> = calcColumnWidths(size, true);
        var rowHeights:Array<Float> = calcRowHeights(size, true);
        var explicitWidths:Array<Bool> = calcExplicitWidths();
        var explicitHeights:Array<Bool> = calcExplicitHeights();
        var totalWidth:Float = 0;
        var totalHeight:Float = 0;

        var rowIndex:Int = 0;
        var columnIndex:Int = 0;
        for (child in component.childComponents) {

            if (child.includeInLayout == false) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.percentWidth != null) {
                var ucx:Float = columnWidths[columnIndex];
                if (explicitWidths[columnIndex] == false) {
                    cx = ucx;
                }
                else {
                    cx = (ucx * child.percentWidth) / 100;
                }
            }

            if (child.percentHeight != null) {
                var ucy:Float = rowHeights[rowIndex];
                if (explicitHeights[rowIndex] == false) {
                    cy = ucy;
                }
                else {
                    cy = (ucy * child.percentHeight) / 100;
                }
            }

            child.resizeComponent(cx, cy);

            columnIndex++;
            if (columnIndex >= _columns) {
                columnIndex = 0;
                rowIndex++;
            }
        }
    }

    private override function repositionChildren() {
        var size:Size = usableSize;
        var columnWidths:Array<Float> = calcColumnWidths(size, true);
        var rowHeights:Array<Float> = calcRowHeights(size, true);
        var rowIndex:Int = 0;
        var columnIndex:Int = 0;

        var xpos:Float = paddingLeft;
        var ypos:Float = paddingTop;
        for (child in component.childComponents) {

            if (child.includeInLayout == false) {
                continue;
            }

            var halign = horizontalAlign(child);
            var valign = verticalAlign(child);
            var xposChild:Float = 0;
            var yposChild:Float = 0;

            switch (halign) {
                case "center":
                    xposChild = xpos + (columnWidths[columnIndex] - child.componentWidth) * 0.5 + marginLeft(child) - marginRight(child);
                case "right":
                    xposChild = xpos + (columnWidths[columnIndex] - child.componentWidth) + marginLeft(child) - marginRight(child);
                default:
                    xposChild = xpos + marginLeft(child) - marginRight(child);
            }
            switch (valign) {
                case "center":
                    yposChild = ypos + (rowHeights[rowIndex] - child.componentHeight) * 0.5 + marginTop(child) - marginBottom(child);
                case "bottom":
                    yposChild = ypos + (rowHeights[rowIndex] - child.componentHeight) + marginTop(child) - marginBottom(child);
                default:
                    yposChild = ypos + marginTop(child) - marginBottom(child);
            }

            child.moveComponent(xposChild, yposChild);

            xpos += columnWidths[columnIndex] + horizontalSpacing;

            columnIndex++;
            if (columnIndex >= columns) {
                xpos = paddingLeft;
                ypos += rowHeights[rowIndex] + verticalSpacing;
                columnIndex = 0;
                rowIndex++;
            }
        }
    }

    private function calcColumnWidths(usableSize:Size, includePercentage:Bool):Array<Float> {
        var columnWidths:Array<Float> = new Array<Float>();
        for (n in 0..._columns) {
            columnWidths.push(0);
        }
        var rowIndex:Int = 0;
        var columnIndex:Int = 0;
        for (child in component.childComponents) {

            if (child.includeInLayout == false) {
                continue;
            }

            if (child.percentWidth == null) {
                if (child.componentWidth > columnWidths[columnIndex]) {
                    columnWidths[columnIndex] = child.componentWidth;
                }
            }

            columnIndex++;
            if (columnIndex >= _columns) {
                columnIndex = 0;
                rowIndex++;
            }
        }

        if(includePercentage)
        {
            var copy = columnWidths.copy();

            rowIndex = 0;
            columnIndex = 0;
            for (child in component.childComponents) {

                if (child.includeInLayout == false) {
                    continue;
                }
                if (child.percentWidth != null) {
                    var cx:Float = (usableSize.width * child.percentWidth) / 100;
                    if (cx > columnWidths[columnIndex]) {
                        columnWidths[columnIndex] = cx;
                    }
                }

                columnIndex++;
                if (columnIndex >= _columns) {
                    columnIndex = 0;
                    rowIndex++;
                }
            }
        }

        return columnWidths;
    }

    private function calcRowHeights(usableSize:Size, includePercentage:Bool):Array<Float> {
        var visibleChildren = component.childComponents.length;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                --visibleChildren;
            }
        }

        var rowCount:Int = Std.int((visibleChildren / _columns));
        if (visibleChildren % _columns != 0) {
            rowCount++;
        }

        var rowHeights:Array<Float> = new Array<Float>();
        for (n in 0...rowCount) {
            rowHeights.push(0);
        }

        var rowIndex:Int = 0;
        var columnIndex:Int = 0;
        for (child in component.childComponents) {

            if (child.includeInLayout == false) {
                continue;
            }

            if (child.percentHeight == null) {
                if (child.componentHeight > rowHeights[rowIndex]) {
                    rowHeights[rowIndex] = child.componentHeight;
                }
            }
            columnIndex++;
            if (columnIndex >= _columns) {
                columnIndex = 0;
                rowIndex++;
            }
        }

        if(includePercentage)
        {
            var copy = rowHeights.copy();

            rowIndex = 0;
            columnIndex = 0;
            for (child in component.childComponents) {

                if (child.includeInLayout == false) {
                    continue;
                }

                if (child.percentHeight != null) {
                    var cy:Float = (usableSize.height * child.percentHeight) / 100;
                    if (cy > rowHeights[rowIndex] && _columns == 1) {
                        rowHeights[rowIndex] = cy;
                    } else if (usableSize.height > rowHeights[rowIndex]) {
                        rowHeights[rowIndex] = usableSize.height;
                    }
                }

                columnIndex++;
                if (columnIndex >= _columns) {
                    columnIndex = 0;
                    rowIndex++;
                }
            }
        }

        return rowHeights;
    }

    private function calcExplicitWidths():Array<Bool> {
        var explicitWidths:Array<Bool> = new Array<Bool>();
        for (n in 0..._columns) {
            explicitWidths.push(false);
        }

        var rowIndex:Int = 0;
        var columnIndex:Int = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            if (child.percentWidth == null && child.componentWidth > 0) {
                explicitWidths[columnIndex] = true;
            }

            columnIndex++;
            if (columnIndex >= _columns) {
                columnIndex = 0;
                rowIndex++;
            }
        }

        return explicitWidths;
    }

    private function calcExplicitHeights():Array<Bool> {
        var visibleChildren = component.childComponents.length;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                --visibleChildren;
            }
        }

        var rowCount:Int = Std.int((visibleChildren / columns));
        if (visibleChildren % _columns != 0) {
            rowCount++;
        }
        var explicitHeights:Array<Bool> = new Array<Bool>();
        for (n in 0...rowCount) {
            explicitHeights.push(false);
        }

        var rowIndex:Int = 0;
        var columnIndex:Int = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            if (child.percentHeight == null && child.componentHeight > 0) {
                explicitHeights[columnIndex % _columns] = true;
            }

            columnIndex++;
            if (columnIndex >= _columns) {
                columnIndex = 0;
                rowIndex++;
            }
        }

        return explicitHeights;
    }
}