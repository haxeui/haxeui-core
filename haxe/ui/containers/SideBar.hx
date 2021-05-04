package haxe.ui.containers;

import haxe.ui.Toolkit;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.styles.Dimension;
import haxe.ui.styles.Value;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.Directive;

class SideBar extends Box {
    public var method:String = "shift";
    public var modal:Bool = false;
    
    public static var activeSideBar:SideBar = null;
    
    private var _lastMethod:String = null;
    private static var _modalOverlay:Component = null;
    
    public function new() {
        super();
        super.hide();
        this.position = "left";
        animatable = false;
        Screen.instance.registerEvent(UIEvent.RESIZE, function(_) {
            if (activeSideBar == this) {
                setEndPos();
            }
        });
    }
    
    private var _position:String = null;
    public var position(get, set):String;
    private function get_position():String {
        return _position;
    }
    private function set_position(value:String):String {
        if (_position == value) {
            return value;
        }
        
        if (_position != null) {
            this.removeClass(":" + _position);
        }
        
        _position = value;
        this.addClass(":" + _position);
        return value;
    }
    
    public override function onReady() {
        super.onReady();
        
        animatable = true;
        var closeButton = findComponent("closeSideBar", Component);
        if (closeButton != null) {
            closeButton.registerEvent(MouseEvent.CLICK, function(_) {
                hide();
            });
        }
    }
    
    private function showModalOverlay() {
        if (_modalOverlay == null) {
            _modalOverlay = new Component();
            _modalOverlay.id = "sidebar-modal-background";
            _modalOverlay.addClass("sidebar-modal-background");
            _modalOverlay.percentWidth = _modalOverlay.percentHeight = 100;
            Screen.instance.addComponent(_modalOverlay);
            _modalOverlay.onClick = function(_) {
                if (activeSideBar != null) {
                    activeSideBar.hide();
                }
            }
        }

        var i = Screen.instance.rootComponents.indexOf(this);
        if (i != -1) {
            Screen.instance.setComponentIndex(_modalOverlay, i - 1);
        }
        _modalOverlay.show();
    }
    
    private function hideModalOverlay() {
        if (_modalOverlay == null) {
            return;
        }
        
        _modalOverlay.hide();
    }
    
    private function setStartPos() {
        if (position == "left") {
            this.left = -this.actualComponentWidth;
        } else if (position == "right") {
            this.left = Screen.instance.actualWidth;
        } else if (position == "top") {
            this.top = -this.actualComponentHeight;
        } else if (position == "bottom") {
            this.top = Screen.instance.actualHeight;
        }
    }
    
    private function setEndPos() {
        if (position == "left") {
            this.left = 0;
        } else if (position == "right") {
            this.left = Screen.instance.actualWidth - this.actualComponentWidth;
        } else if (position == "top") {
            this.top = 0;
        } else if (position == "bottom") {
            this.top = Screen.instance.actualHeight - this.actualComponentHeight;
        }
    }
    
    public override function show() {
        if (activeSideBar == this) {
            return;
        }
        
        if (Screen.instance.rootComponents.indexOf(this) == -1) {
            if (modal == true) {
                showModalOverlay();
            }
            Screen.instance.addComponent(this);
            this.validateNow();
            Toolkit.callLater(function() {
                setStartPos();
                show();
            });
            return;
        } else {
            
            if (modal == true) {
                showModalOverlay();
            }
            this.validateNow();
            setStartPos();
        }
        
        var animation = Toolkit.styleSheet.findAnimation("sideBarModifyContent");

        var first:AnimationKeyFrame = animation.keyFrames[0];
        var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
        var rootComponent = Screen.instance.rootComponents[0];
        
        first.set(new Directive("left", Value.VDimension(Dimension.PX(rootComponent.left))));
        first.set(new Directive("top", Value.VDimension(Dimension.PX(rootComponent.top))));
        first.set(new Directive("width", Value.VDimension(Dimension.PX(rootComponent.width))));
        first.set(new Directive("height", Value.VDimension(Dimension.PX(rootComponent.height))));

        last.set(new Directive("left", Value.VDimension(Dimension.PX(rootComponent.left))));
        last.set(new Directive("top", Value.VDimension(Dimension.PX(rootComponent.top))));
        last.set(new Directive("width", Value.VDimension(Dimension.PX(rootComponent.width))));
        last.set(new Directive("height", Value.VDimension(Dimension.PX(rootComponent.height))));
        
        _lastMethod = method;
        
        if (activeSideBar != null && activeSideBar != this) {
            activeSideBar.buildHideContentAnimation(animation);
        }
        buildContentAnimation(animation);
        
        var showSideBarClass = null;
        var hideSideBarClass = null;
        if (position == "left") {
            showSideBarClass = "showSideBarLeft";
            hideSideBarClass = "hideSideBarLeft";
            var animation = Toolkit.styleSheet.findAnimation("showSideBarLeft");
            var first:AnimationKeyFrame = animation.keyFrames[0];
            var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
            first.set(new Directive("left", Value.VDimension(Dimension.PX(-this.actualComponentWidth - getAppropriateMargin()))));
            last.set(new Directive("left", Value.VDimension(Dimension.PX(0))));
        } else if (position == "right") {
            showSideBarClass = "showSideBarRight";
            hideSideBarClass = "hideSideBarRight";
            var animation = Toolkit.styleSheet.findAnimation("showSideBarRight");
            var first:AnimationKeyFrame = animation.keyFrames[0];
            var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
            first.set(new Directive("left", Value.VDimension(Dimension.PX(Screen.instance.actualWidth + getAppropriateMargin()))));
            last.set(new Directive("left", Value.VDimension(Dimension.PX(Screen.instance.actualWidth - this.actualComponentWidth))));
        } else if (position == "top") {
            showSideBarClass = "showSideBarTop";
            hideSideBarClass = "hideSideBarTop";
            var animation = Toolkit.styleSheet.findAnimation("showSideBarTop");
            var first:AnimationKeyFrame = animation.keyFrames[0];
            var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
            first.set(new Directive("top", Value.VDimension(Dimension.PX(-this.actualComponentHeight - getAppropriateMargin()))));
            last.set(new Directive("top", Value.VDimension(Dimension.PX(0))));
        } else if (position == "bottom") {
            showSideBarClass = "showSideBarBottom";
            hideSideBarClass = "hideSideBarBottom";
            var animation = Toolkit.styleSheet.findAnimation("showSideBarBottom");
            var first:AnimationKeyFrame = animation.keyFrames[0];
            var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
            first.set(new Directive("top", Value.VDimension(Dimension.PX(Screen.instance.actualHeight + getAppropriateMargin()))));
            last.set(new Directive("top", Value.VDimension(Dimension.PX(Screen.instance.actualHeight - this.actualComponentHeight))));
        }
        
        
        this.onAnimationEnd = function(_) {
            this.removeClass(showSideBarClass);
        }
        
        if (activeSideBar != null && activeSideBar != this) {
            activeSideBar.hideSideBar();
        }
        
        for (r in Screen.instance.rootComponents) {
            if (r.classes.indexOf("sidebar") == -1) {
                r.cachePercentSizes();
                r.swapClass("sideBarModifyContent", "sideBarRestoreContent");
                r.onAnimationEnd = function(_) {
                    r.onAnimationEnd = null;
                    rootComponent.removeClass("sideBarModifyContent");
                }
            }
        }

        this.swapClass(showSideBarClass, hideSideBarClass);
        activeSideBar = this;
        
        super.show();
    }
    
    private function getAppropriateMargin():Float {
        return 0;
        var m = null;
        
        if (position == "left") {
            m = style.marginLeft;
        } else if (position == "top") {
            m = style.marginTop;
        } else if (position == "right") {
            m = style.marginRight;
        } else if (position == "bottom") {
            m = style.marginBottom;
        }
        
        if (m == null) {
            return 0;
        }
        
        return m * Toolkit.scale;
    }
    
    private function buildHideContentAnimation(animation:AnimationKeyFrames) {
        var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
        
        if (_lastMethod == "shift") {
            if (position == "left") {
                last.set(new Directive("left", Value.VDimension(Dimension.PX(0))));
            } else if (position == "right") {
                last.set(new Directive("left", Value.VDimension(Dimension.PX(0))));
            }
            
            if (position == "top") {
                last.set(new Directive("top", Value.VDimension(Dimension.PX(0))));
            } else if (position == "bottom") {
                last.set(new Directive("top", Value.VDimension(Dimension.PX(0))));
            }
        } else if (_lastMethod == "squash") {
            if (position == "left") {
                last.set(new Directive("left", Value.VDimension(Dimension.PX(0))));
                last.set(new Directive("width", Value.VDimension(Dimension.PX(Screen.instance.width))));
            } else if (position == "right") {
                last.set(new Directive("width", Value.VDimension(Dimension.PX(Screen.instance.width))));
            }
            
            if (position == "top") {
                last.set(new Directive("top", Value.VDimension(Dimension.PX(0))));
                last.set(new Directive("height", Value.VDimension(Dimension.PX(Screen.instance.height))));
            } else if (position == "bottom") {
                last.set(new Directive("height", Value.VDimension(Dimension.PX(Screen.instance.height))));
            }
        }
    }
    
    private function buildContentAnimation(animation:AnimationKeyFrames) {
        var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
        
        if (method == "shift") {
            if (position == "left") {
                last.set(new Directive("left", Value.VDimension(Dimension.PX(this.actualComponentWidth))));
            } else if (position == "right") {
                last.set(new Directive("left", Value.VDimension(Dimension.PX(-this.actualComponentWidth))));
            }
            
            if (position == "top") {
                last.set(new Directive("top", Value.VDimension(Dimension.PX(this.actualComponentHeight))));
            } else if (position == "bottom") {
                last.set(new Directive("top", Value.VDimension(Dimension.PX(-this.actualComponentHeight))));
            }
        } else if (method == "squash") {
            if (position == "left") {
                last.set(new Directive("left", Value.VDimension(Dimension.PX(this.actualComponentWidth))));
                last.set(new Directive("width", Value.VDimension(Dimension.PX(Screen.instance.width - this.width))));
            } else if (position == "right") {
                last.set(new Directive("width", Value.VDimension(Dimension.PX(Screen.instance.width - this.width))));
            }
            
            if (position == "top") {
                last.set(new Directive("top", Value.VDimension(Dimension.PX(this.actualComponentHeight))));
                last.set(new Directive("height", Value.VDimension(Dimension.PX(Screen.instance.height - this.height))));
            } else if (position == "bottom") {
                last.set(new Directive("height", Value.VDimension(Dimension.PX(Screen.instance.height - this.height))));
            }
        }
    }
    
    private function hideSideBar() {
        var showSideBarClass = null;
        var hideSideBarClass = null;
        if (position == "left") {
            showSideBarClass = "showSideBarLeft";
            hideSideBarClass = "hideSideBarLeft";
        } else if (position == "right") {
            showSideBarClass = "showSideBarRight";
            hideSideBarClass = "hideSideBarRight";
        } else if (position == "top") {
            showSideBarClass = "showSideBarTop";
            hideSideBarClass = "hideSideBarTop";
        } else if (position == "bottom") {
            showSideBarClass = "showSideBarBottom";
            hideSideBarClass = "hideSideBarBottom";
        }
        
        this.onAnimationEnd = function(_) {
            this.removeClass(hideSideBarClass);
            onHideAnimationEnd();
        }
        
        this.swapClass(hideSideBarClass, showSideBarClass);
        
        if (modal == true) {
            hideModalOverlay();
        }
    }
    
    private function onHideAnimationEnd() {
        super.hide();
    }
    
    public override function hide() {
        if (activeSideBar != null && activeSideBar != this) {
            activeSideBar.hide();
            return;
        }
        
        var animation = Toolkit.styleSheet.findAnimation("sideBarRestoreContent");
        var first:AnimationKeyFrame = animation.keyFrames[0];
        var last:AnimationKeyFrame = animation.keyFrames[animation.keyFrames.length - 1];
        var rootComponent = Screen.instance.rootComponents[0];
        
        first.set(new Directive("left", Value.VDimension(Dimension.PX(rootComponent.left))));
        first.set(new Directive("top", Value.VDimension(Dimension.PX(rootComponent.top))));
        first.set(new Directive("width", Value.VDimension(Dimension.PX(rootComponent.width))));
        first.set(new Directive("height", Value.VDimension(Dimension.PX(rootComponent.height))));
        
        last.set(new Directive("left", Value.VDimension(Dimension.PX(0))));
        last.set(new Directive("top", Value.VDimension(Dimension.PX(0))));
        last.set(new Directive("width", Value.VDimension(Dimension.PX(Screen.instance.width))));
        last.set(new Directive("height", Value.VDimension(Dimension.PX(Screen.instance.height))));

        for (r in Screen.instance.rootComponents) {
            if (r.classes.indexOf("sidebar") == -1) {
                r.swapClass("sideBarRestoreContent", "sideBarModifyContent");
                r.onAnimationEnd = function(_) {
                    r.restorePercentSizes();
                    r.onAnimationEnd = null;
                    rootComponent.removeClass("sideBarRestoreContent");
                }
            }
        }
        
        hideSideBar();
        
        activeSideBar = null;
    }
}