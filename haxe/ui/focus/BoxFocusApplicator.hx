package haxe.ui.focus;

import haxe.ui.Toolkit;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.focus.FocusManager;
import haxe.ui.styles.StyleSheet;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.Directive;

class BoxFocusApplicator extends FocusApplicator {
    private var _box:Box = null;
    
    private static inline var STYLE_NAME:String = "boxfocusstyle";
    
    public override function apply(target:Component):Void {
        createBox();

        Screen.instance.setComponentIndex(_box, Screen.instance.rootComponents.length - 1);
        
        Toolkit.callLater(function() {
            var animation = Toolkit.styleSheet.findAnimation(STYLE_NAME);
            if (animation == null) {
                Toolkit.styleSheet.parse('
                    .$STYLE_NAME {
                        animation: $STYLE_NAME 0.3s ease 0s 1;
                    }

                    @keyframes $STYLE_NAME {
                        0% {
                        }
                        100% {
                        }
                    }
                ', false);
                animation = Toolkit.styleSheet.findAnimation(STYLE_NAME);
            }
            var first:AnimationKeyFrame = animation.keyFrames[0];
            var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
            
            first.set(new Directive("left", Value.VDimension(Dimension.PX(_box.screenLeft))));
            first.set(new Directive("top", Value.VDimension(Dimension.PX(_box.screenTop))));
            first.set(new Directive("width", Value.VDimension(Dimension.PX(_box.width))));
            first.set(new Directive("height", Value.VDimension(Dimension.PX(_box.height))));
            
            var x = target.screenLeft;
            var y = target.screenTop;
            var w = target.width;
            var h = target.height;
            
            last.set(new Directive("left", Value.VDimension(Dimension.PX(x))));
            last.set(new Directive("top", Value.VDimension(Dimension.PX(y))));
            last.set(new Directive("width", Value.VDimension(Dimension.PX(w))));
            last.set(new Directive("height", Value.VDimension(Dimension.PX(h))));
            
            _box.onAnimationEnd = function(_) {
                _box.onAnimationEnd = null;
                _box.removeClass(STYLE_NAME);
            }
            
            _box.addClass(STYLE_NAME);
        });
    }
    
    public override function unapply(target:Component):Void {
        //_box.hidden = true;
    }
    
    private function createBox() {
        if (_box != null) {
            return;
        }
        
        _box = new Box();
        _box.styleString = "border: 1px solid $accent-color;pointer-events:none;background-color: $accent-color;background-opacity: .2;border-radius: 2px;";
        Screen.instance.addComponent(_box);
        FocusManager.instance.popView();
    }
}