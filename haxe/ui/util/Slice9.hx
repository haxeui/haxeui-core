package haxe.ui.util;

typedef Slice9Rects = {
    src:Array<Rectangle>,
    dst:Array<Rectangle>
}

class Slice9 {
    public static function buildRects(w:Float, h:Float, bitmapWidth:Float, bitmapHeight:Float, slice:Rectangle):Slice9Rects {
        var srcRects:Array<Rectangle> = buildSrcRects(bitmapWidth, bitmapHeight, slice);
        var dstRects:Array<Rectangle> = buildDstRects(w, h, srcRects);
        return {
            src: srcRects,
            dst: dstRects
        }
    }

    public static function buildSrcRects(bitmapWidth:Float, bitmapHeight:Float, slice:Rectangle):Array<Rectangle> {
        var x1:Float = slice.left;
        var y1:Float = slice.top;
        var x2:Float = slice.right;
        var y2:Float = slice.bottom;

        var srcRects:Array<Rectangle> = [];
        srcRects.push(new Rectangle(0, 0, x1, y1)); // top left
        srcRects.push(new Rectangle(x1, 0, x2 - x1, y1)); // top middle
        srcRects.push(new Rectangle(x2, 0, bitmapWidth - x2, y1)); // top right

        srcRects.push(new Rectangle(0, y1, x1, y2 - y1)); // left middle
        srcRects.push(new Rectangle(x1, y1, x2 - x1, y2 - y1)); // middle
        srcRects.push(new Rectangle(x2, y1, bitmapWidth - x2, y2 - y1)); // left middle

        srcRects.push(new Rectangle(0, y2, x1, bitmapHeight - y2)); // bottom left
        srcRects.push(new Rectangle(x1, y2, x2 - x1, bitmapHeight - y2)); // bottom middle
        srcRects.push(new Rectangle(x2, y2, bitmapWidth - x2, bitmapHeight - y2)); // bottom right

        return srcRects;
    }

    public static function buildDstRects(w:Float, h:Float, srcRects:Array<Rectangle>):Array<Rectangle> {
        var dstRects:Array<Rectangle> = [];

        dstRects.push(new Rectangle(0, 0, srcRects[0].width, srcRects[0].height));
        dstRects.push(new Rectangle(srcRects[0].width, 0, w - srcRects[0].width - srcRects[2].width, srcRects[1].height));
        dstRects.push(new Rectangle(w - srcRects[2].width, 0, srcRects[2].width, srcRects[2].height));

        dstRects.push(new Rectangle(0, srcRects[0].height, srcRects[3].width, h - srcRects[0].height - srcRects[6].height));
        dstRects.push(new Rectangle(srcRects[3].width, srcRects[0].height, w - srcRects[3].width - srcRects[5].width, h - srcRects[1].height - srcRects[7].height));
        dstRects.push(new Rectangle(w - srcRects[5].width, srcRects[2].height, srcRects[5].width, h - srcRects[2].height - srcRects[8].height));

        dstRects.push(new Rectangle(0, h - srcRects[6].height, srcRects[6].width, srcRects[6].height));
        dstRects.push(new Rectangle(srcRects[6].width, h - srcRects[7].height, w - srcRects[6].width - srcRects[8].width, srcRects[7].height));
        dstRects.push(new Rectangle(w - srcRects[8].width, h - srcRects[8].height, srcRects[8].width, srcRects[8].height));

        return dstRects;
    }
}
