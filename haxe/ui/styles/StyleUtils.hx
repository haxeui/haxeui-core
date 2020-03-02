package haxe.ui.styles;

import haxe.ui.core.Component;
import haxe.ui.styles.Style2.Optional;
import haxe.ui.styles.Style2.StyleBorderPart;
import haxe.ui.styles.Style2.StyleBounds;
import haxe.ui.styles.Style2.StyleColorBlock;
import haxe.ui.styles.Style2.StyleDimension;
import haxe.ui.styles.Style2.StyleDimensionType;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.Style2.Option;
import haxe.ui.util.Color;

class StyleUtils {
    public static function mergeStyle(existingStyle:Style2, newStyle:Style2) {
        // background
        if (newStyle.backgroundColors != null) {
            existingStyle.backgroundColors = mergeArray(newStyle.backgroundColors, existingStyle.backgroundColors);
        }
        if (newStyle.backgroundStyle != null) {
            existingStyle.backgroundStyle = mergeOptionalValue(newStyle.backgroundStyle, existingStyle.backgroundStyle);
        }
        if (newStyle.backgroundOpacity != null) {
            existingStyle.backgroundOpacity = mergeOptionalValue(newStyle.backgroundOpacity, existingStyle.backgroundOpacity);
        }
        if (newStyle.backgroundImage != null) {
            if (newStyle.backgroundImage.resource != null) {
                existingStyle.backgroundImage.resource = mergeOptionalValue(newStyle.backgroundImage.resource, existingStyle.backgroundImage.resource);
            }
            if (newStyle.backgroundImage.repeat != null) {
                existingStyle.backgroundImage.repeat = mergeOptionalValue(newStyle.backgroundImage.repeat, existingStyle.backgroundImage.repeat);
            }
            if (newStyle.backgroundImage.clip.isNull == false) {
                existingStyle.backgroundImage.clip = mergeBounds(newStyle.backgroundImage.clip, existingStyle.backgroundImage.clip);
            }
            if (newStyle.backgroundImage.slice.isNull == false) {
                existingStyle.backgroundImage.slice = mergeBounds(newStyle.backgroundImage.slice, existingStyle.backgroundImage.slice);
            }
        }
        
        // padding / margin
        if (newStyle.padding.isNull == false) {
            existingStyle.padding = mergeBounds(newStyle.padding, existingStyle.padding);
        }
        if (newStyle.margin.isNull == false) {
            existingStyle.margin = mergeBounds(newStyle.margin, existingStyle.margin);
        }
        
        // width
        if (newStyle.width != null) {
            existingStyle.width = mergeValue(newStyle.width, existingStyle.width);
        }
        if (newStyle.initialWidth != null) {
            existingStyle.initialWidth = mergeValue(newStyle.initialWidth, existingStyle.initialWidth);
        }
        if (newStyle.minWidth != null) {
            existingStyle.minWidth = mergeValue(newStyle.minWidth, existingStyle.minWidth);
        }
        if (newStyle.maxWidth != null) {
            existingStyle.maxWidth = mergeValue(newStyle.maxWidth, existingStyle.maxWidth);
        }
        
        // height
        if (newStyle.height != null) {
            existingStyle.height = mergeValue(newStyle.height, existingStyle.height);
        }
        if (newStyle.initialHeight != null) {
            existingStyle.initialHeight = mergeValue(newStyle.initialHeight, existingStyle.initialHeight);
        }
        if (newStyle.minHeight != null) {
            existingStyle.minHeight = mergeValue(newStyle.minHeight, existingStyle.minHeight);
        }
        if (newStyle.maxHeight != null) {
            existingStyle.maxHeight = mergeValue(newStyle.maxHeight, existingStyle.maxHeight);
        }

        // border
        if (newStyle.border != null && newStyle.border.isNull == false) {
            existingStyle.border.top = mergeBorderPart(newStyle.border.top, existingStyle.border.top);
            existingStyle.border.right = mergeBorderPart(newStyle.border.right, existingStyle.border.right);
            existingStyle.border.bottom = mergeBorderPart(newStyle.border.bottom, existingStyle.border.bottom);
            existingStyle.border.left = mergeBorderPart(newStyle.border.left, existingStyle.border.left);
            existingStyle.border.opacity = mergeOptionalValue(newStyle.border.opacity, existingStyle.border.opacity);
            existingStyle.border.radius = mergeOptionalValue(newStyle.border.radius, existingStyle.border.radius);
        }
        
        // position
        if (newStyle.top != null) {
            existingStyle.top = mergeOptionalValue(newStyle.top, existingStyle.top);
        }
        if (newStyle.left != null) {
            existingStyle.left = mergeOptionalValue(newStyle.left, existingStyle.left);
        }
        
        // spacing
        if (newStyle.spacing != null) {
            existingStyle.spacing.horizontal = mergeOptionalValue(newStyle.spacing.horizontal, existingStyle.spacing.horizontal);
            existingStyle.spacing.vertical = mergeOptionalValue(newStyle.spacing.vertical, existingStyle.spacing.vertical);
        }
        
        // other
        if (newStyle.display != null) {
            existingStyle.display = mergeOptionalValue(newStyle.display, existingStyle.display, false);
        }
        if (newStyle.cursor != null) {
            existingStyle.cursor = mergeValue(newStyle.cursor, existingStyle.cursor);
        }
        if (newStyle.color != null) {
            if (newStyle.color == none) {
                existingStyle.color = null;
            } else if (newStyle.color == inherit) {
                existingStyle.color = inherit;
            } else {
                existingStyle.color = mergeValue(newStyle.color, existingStyle.color);
            }
        }
        if (newStyle.opacity != null) {
            existingStyle.opacity = mergeOptionalValue(newStyle.opacity, existingStyle.opacity);
        }
        
        
        if (newStyle.font != null) {
            if (newStyle.font.style != null) {
                existingStyle.font.style = mergeOptionalValue(newStyle.font.style, existingStyle.font.style);
            }
            if (newStyle.font.weight != null) {
                existingStyle.font.weight = mergeOptionalValue(newStyle.font.weight, existingStyle.font.weight);
            }
            if (newStyle.font.size != null) {
                existingStyle.font.size = mergeOptionalValue(newStyle.font.size, existingStyle.font.size);
            }
            if (newStyle.font.family != null) {
                existingStyle.font.family = mergeOptionalValue(newStyle.font.family, existingStyle.font.family);
            }
        }
        
        // alignment
        if (newStyle.horizontalAlign != null) {
            existingStyle.horizontalAlign = mergeValue(newStyle.horizontalAlign, existingStyle.horizontalAlign);
        }
        if (newStyle.verticalAlign != null) {
            existingStyle.verticalAlign = mergeValue(newStyle.verticalAlign, existingStyle.verticalAlign);
        }
        if (newStyle.textAlign != null) {
            existingStyle.textAlign = mergeValue(newStyle.textAlign, existingStyle.textAlign);
        }
        
        // animation
        if (newStyle.animation != null && newStyle.animation.isNull == false) {
            trace("MERGE ANIMATION!");
            if (newStyle.animation.name != null) {
                existingStyle.animation.name = mergeValue(newStyle.animation.name, existingStyle.animation.name);
            }
            if (newStyle.animation.duration != null) {
                existingStyle.animation.duration = mergeValue(newStyle.animation.duration, existingStyle.animation.duration);
            }
            if (newStyle.animation.delay != null) {
                existingStyle.animation.delay = mergeValue(newStyle.animation.delay, existingStyle.animation.delay);
            }
            if (newStyle.animation.iterationCount != null) {
                existingStyle.animation.iterationCount = mergeValue(newStyle.animation.iterationCount, existingStyle.animation.iterationCount);
            }
            if (newStyle.animation.easingFunction != null) {
                existingStyle.animation.easingFunction = mergeValue(newStyle.animation.easingFunction, existingStyle.animation.easingFunction);
            }
            if (newStyle.animation.direction != null) {
                existingStyle.animation.direction = mergeValue(newStyle.animation.direction, existingStyle.animation.direction);
            }
            if (newStyle.animation.fillMode != null) {
                existingStyle.animation.fillMode = mergeValue(newStyle.animation.fillMode, existingStyle.animation.fillMode);
            }
        }
    }
    
    private static function mergeBorderPart(newPart:StyleBorderPart, existingPart:StyleBorderPart):StyleBorderPart {
        if (newPart == null || (newPart.color == null && newPart.style != null && newPart.width == null)) {
            return existingPart;
        }
        
        if (newPart.color.isNone == true && newPart.style == none && newPart.width == none) {
            return null;
        }
        
        if (newPart.color != null) {
            if (newPart.color.isNone == true) {
                existingPart.color = null;
            } else {
                existingPart.color = newPart.color;
            }
        }

        if (newPart.style != null) {
            if (newPart.style == none) {
                existingPart.style = null;
            } else {
                existingPart.style = newPart.style;
            }
        }
        

        if (newPart.width != null) {
            if (newPart.width == none) {
                existingPart.width = null;
            } else {
                existingPart.width = newPart.width;
            }
        }
        
        if (existingPart.color == null && existingPart.style != null && existingPart.width == null) {
            return null;
        }
        
        return existingPart;
    }
    
    private static inline function mergeValue<T>(newValue:T, existingValue:T):T {
        if (newValue == null) {
            return existingValue;
        }
        
        return newValue;
    }
    
    private static inline function mergeOptionalValue<T>(newValue:Optional<T>, existingValue:Optional<T>, noneAsNull:Bool = true):Optional<T> {
        if (newValue == null) {
            return existingValue;
        }
        
        if (newValue == none) {
            if (noneAsNull == true) {
                return null;
            } else {
                return none;
            }
        }
        
        return newValue;
    }
    
    private static inline function mergeArray<T>(newValue:Optional<Array<T>>, existingValue:Optional<Array<T>>):Optional<Array<T>> {
        if (newValue == null) {
            return existingValue;
        }
        
        if (newValue == none) {
            return null;
        }
        
        return newValue;
    }

    private static inline function mergeBounds(newValue:StyleBounds, existingValue:StyleBounds):StyleBounds {
        if (newValue == null || newValue.isNull == true) {
            return existingValue;
        }
        
        
        if (newValue == none) {
            return null;
        }

        if (existingValue == null) {
            return newValue;
        }

        newValue.top = mergeOptionalValue(newValue.top, existingValue.top);
        newValue.right = mergeOptionalValue(newValue.right, existingValue.right);
        newValue.bottom = mergeOptionalValue(newValue.bottom, existingValue.bottom);
        newValue.left = mergeOptionalValue(newValue.left, existingValue.left);
        
        return newValue;
    }

    public static function processDirective(style:Style2, directive:Directive) {
        switch (directive.directive) {
            case "background" | "background-colors" | "background-color":
                processBackground(style, directive);
            case "padding":
                StyleUtils.applyDirective(style, directive);
            case "padding-top":    
                StyleUtils.applyDirective(style, new Directive("padding", VComposite([directive.value, null, null, null])));
            case "padding-right":    
                StyleUtils.applyDirective(style, new Directive("padding", VComposite([null, directive.value, null, null])));
            case "padding-bottom":    
                StyleUtils.applyDirective(style, new Directive("padding", VComposite([null, null, directive.value, null])));
            case "padding-left":    
                StyleUtils.applyDirective(style, new Directive("padding", VComposite([null, null, null, directive.value])));
            case "margin":    
                StyleUtils.applyDirective(style, directive);
            case "margin-top":    
                StyleUtils.applyDirective(style, new Directive("margin", VComposite([directive.value, null, null, null])));
            case "margin-right":    
                StyleUtils.applyDirective(style, new Directive("margin", VComposite([null, directive.value, null, null])));
            case "margin-bottom":    
                StyleUtils.applyDirective(style, new Directive("margin", VComposite([null, null, directive.value, null])));
            case "margin-left":    
                StyleUtils.applyDirective(style, new Directive("margin", VComposite([null, null, null, directive.value])));
            case "border": // top, right, bottom, left
                switch (directive.value) {
                    case VComposite(vl):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            VComposite([vl[0], vl[1], vl[2]]),
                            VComposite([vl[0], vl[1], vl[2]]),
                            VComposite([vl[0], vl[1], vl[2]]),
                            VComposite([vl[0], vl[1], vl[2]])
                        ])));
                    case VDimension(PX(v)) | VNumber(v):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            VComposite([VDimension(PX(v)), null, null]),
                            VComposite([VDimension(PX(v)), null, null]),
                            VComposite([VDimension(PX(v)), null, null]),
                            VComposite([VDimension(PX(v)), null, null])
                        ])));
                    case VNone:    
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            VNone, VNone, VNone, VNone
                        ])));
                    default:
                }
            case "border-top":
                switch (directive.value) {
                    case VComposite(vl):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            VComposite([vl[0], vl[1], vl[2]]), null, null, null
                        ])));
                    case VDimension(PX(v)) | VNumber(v):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            VComposite([VDimension(PX(v)), null, null]), null, null, null
                        ])));
                    case VNone:    
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            VNone, null, null, null
                        ])));
                    default:    
                }
            case "border-right":
                switch (directive.value) {
                    case VComposite(vl):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, VComposite([vl[0], vl[1], vl[2]]), null, null
                        ])));
                    case VDimension(PX(v)) | VNumber(v):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, VComposite([VDimension(PX(v)), null, null]), null, null
                        ])));
                    case VNone:    
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, VNone, null, null
                        ])));
                    default:    
                }
            case "border-bottom":
                switch (directive.value) {
                    case VComposite(vl):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, null, VComposite([vl[0], vl[1], vl[2]]), null
                        ])));
                    case VDimension(PX(v)) | VNumber(v):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, null, VComposite([VDimension(PX(v)), null, null]), null
                        ])));
                    case VNone:    
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, null, VNone, null
                        ])));
                    default:    
                }
            case "border-left":
                switch (directive.value) {
                    case VComposite(vl):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, null, null, VComposite([vl[0], vl[1], vl[2]])
                        ])));
                    case VDimension(PX(v)) | VNumber(v):
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, null, null, VComposite([VDimension(PX(v)), null, null])
                        ])));
                    case VNone:    
                        StyleUtils.applyDirective(style, new Directive("border", VComposite([
                            null, null, null, VNone
                        ])));
                    default:    
                }
            case "spacing":
                StyleUtils.applyDirective(style, directive);
            case "horizontal-spacing": 
                StyleUtils.applyDirective(style, new Directive("spacing", VComposite([directive.value, null])));
            case "vertical-spacing": 
                StyleUtils.applyDirective(style, new Directive("spacing", VComposite([null, directive.value])));
            case "font": // style(italic) weight(bold) size family
                switch (directive.value) {
                    case VComposite(vl):
                        if (vl.length == 2) {
                            StyleUtils.applyDirective(style, new Directive("font", VComposite([null, null, vl[0], vl[1]])));
                        } else if (vl.length == 3) {
                            StyleUtils.applyDirective(style, new Directive("font", VComposite([null, vl[0], vl[1], vl[2]])));
                        } else if (vl.length == 4) {
                            StyleUtils.applyDirective(style, new Directive("font", VComposite([vl[0], vl[1], vl[2], vl[3]])));
                        }
                    case VDimension(PX(v)) | VNumber(v):    
                        StyleUtils.applyDirective(style, new Directive("font", VComposite([null, null, directive.value, null])));
                    case VString(v) | VConstant(v):
                        StyleUtils.applyDirective(style, new Directive("font", VComposite([null, null, null, directive.value])));
                    case VNone:
                        StyleUtils.applyDirective(style, new Directive("font", VNone));
                    case VInherit:
                        StyleUtils.applyDirective(style, new Directive("font", VInherit));
                    default:    
                }
            case "font-family" | "font-name":
                StyleUtils.applyDirective(style, new Directive("font", VComposite([null, null, null, directive.value])));
            case "font-size":
                StyleUtils.applyDirective(style, new Directive("font", VComposite([null, null, directive.value, null])));
            case "font-weight":
                StyleUtils.applyDirective(style, new Directive("font", VComposite([null, directive.value, null, null])));
            case "font-style":
                StyleUtils.applyDirective(style, new Directive("font", VComposite([directive.value, null, null, null])));
            case "background-image":    
                StyleUtils.applyDirective(style, new Directive("background-image", directive.value));
            case "background-image-repeat":    
                StyleUtils.applyDirective(style, new Directive("background-image", VComposite([null, directive.value])));
            case "background-image-clip": // top, right, bottom, left
                StyleUtils.applyDirective(style, directive);
            case "background-image-clip-top":    
                StyleUtils.applyDirective(style, new Directive("background-image-clip", VComposite([directive.value, null, null, null])));
            case "background-image-clip-right":    
                StyleUtils.applyDirective(style, new Directive("background-image-clip", VComposite([null, directive.value, null, null])));
            case "background-image-clip-bottom":    
                StyleUtils.applyDirective(style, new Directive("background-image-clip", VComposite([null, null, directive.value, null])));
            case "background-image-clip-left":    
                StyleUtils.applyDirective(style, new Directive("background-image-clip", VComposite([null, null, null, directive.value])));
            case "background-image-slice": // top, right, bottom, left
                StyleUtils.applyDirective(style, directive);
            case "background-image-slice-top":    
                StyleUtils.applyDirective(style, new Directive("background-image-slice", VComposite([directive.value, null, null, null])));
            case "background-image-slice-right":    
                StyleUtils.applyDirective(style, new Directive("background-image-slice", VComposite([null, directive.value, null, null])));
            case "background-image-slice-bottom":    
                StyleUtils.applyDirective(style, new Directive("background-image-slice", VComposite([null, null, directive.value, null])));
            case "background-image-slice-left":    
                StyleUtils.applyDirective(style, new Directive("background-image-slice", VComposite([null, null, null, directive.value])));
            case "animation2":  // name, duration, delay, iteration, direction, easing, fill 
                trace("ANIMATION DIRECTIVE");
                trace(directive.value);
                StyleUtils.applyDirective(style, new Directive("animation2", directive.value));
            case "animation2-name":    
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([directive.value, null, null, null, null, null, null])));
            case "animation2-duration":    
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([null, directive.value, null, null, null, null, null])));
            case "animation2-delay":    
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([null, null, directive.value, null, null, null, null])));
            case "animation2-iteration-count":    
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([null, null, null, directive.value, null, null, null])));
            case "animation2-direction":    
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([null, null, null, null, directive.value, null, null])));
            case "animation2-timing-function" | "animation2-easing-function":    
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([null, null, null, null, null, directive.value, null])));
            case "animation2-fill-mode":
                StyleUtils.applyDirective(style, new Directive("animation2", VComposite([null, null, null, null, null, null, directive.value])));
            default:
                StyleUtils.applyDirective(style, directive);
        }
    }
    
    private static function processBackground(style:Style2, directive:Directive) {
        switch (directive.value) {
            case VComposite(vl):
                var colorCount:Int = 0;
                var blockCount:Int = 0;
                var colDif:Bool = false;
                var lastCol:Null<Int> = null;
                for (item in vl) {
                    switch(item) {
                        case VColor(v):
                            colorCount++;
                            if (lastCol != null && lastCol != v) {
                                colDif = true;
                            }
                            lastCol = v;
                        case VDimension(Dimension.PERCENT(v)):
                            blockCount++;
                        default:    
                    }
                }
                
                if (colDif == true) {
                    var copy:Array<Value> = [];
                    var p:Float = 0;
                    for (item in vl) {
                        switch (item) {
                            case VColor(v):
                                copy.push(item);
                                if (colorCount != blockCount) {
                                    copy.push(VDimension(Dimension.PERCENT(p)));
                                    p += 100 / (colorCount - 1);
                                    blockCount++;
                                }
                            case VDimension(v):
                                copy.push(item);
                            case VConstant(v):
                                if (v == "horizontal" || v == "vertical") {
                                    StyleUtils.applyDirective(style, new Directive("background-style", VConstant(v)));
                                }
                            default:
                        }
                    }
                    StyleUtils.applyDirective(style, new Directive("background-colors", VComposite(copy)));
                } else {
                    for (item in vl) {
                        switch (item) {
                            case VColor(v):
                                StyleUtils.applyDirective(style, new Directive("background-colors", item));
                                break;
                            default:
                        }
                    }
                }
            default:
                StyleUtils.applyDirective(style, new Directive("background-colors", directive.value));
        }
    }
    
    public static function applyDirective(style:Style2, directive:Directive) {
        switch (directive.directive) {
            case "background-colors":
                if (directive.value == null) {
                    style.backgroundColors = null;
                } else {
                    switch (directive.value) {
                        case VComposite(vl):
                            var arr:Array<StyleColorBlock> = [];
                            var i = 0;
                            while (i < vl.length) {
                                var col = vl[i];
                                var block = vl[i + 1];
                                arr.push({
                                    color: ValueTools.int(col),
                                    block: ValueTools.percent(block)
                                });
                                i += 2;
                            }
                            style.backgroundColors = arr;
                        case VNone:
                            style.backgroundColors = none;
                        case VInherit:
                            style.backgroundColors = inherit;
                        default:
                            var arr:Array<StyleColorBlock> = [];
                            arr.push({
                                color: ValueTools.int(directive.value),
                                block: null
                            });
                            style.backgroundColors = arr;
                    }
                }
            case "background-style":
                style.backgroundStyle = ValueTools.optionalString(directive.value);
            case "background-opacity":
                style.backgroundOpacity = ValueTools.optionalFloat(directive.value);
            case "padding":
                style.padding = applyBounds(directive, style.padding);
            case "margin":
                style.margin = applyBounds(directive, style.margin);
            case "width":
                style.width = applyDimension(directive);
            case "initial-width":
                style.initialWidth = applyDimension(directive);
            case "min-width":
                style.minWidth = applyDimension(directive);
            case "max-width":
                style.maxWidth = applyDimension(directive);
            case "height":
                style.height = applyDimension(directive);
            case "initial-height":
                style.initialHeight = applyDimension(directive);
            case "min-height":
                style.minHeight = applyDimension(directive);
            case "max-height":
                style.maxHeight = applyDimension(directive);
            case "border":
                switch (directive.value) {
                    case VComposite([top, right, bottom, left]):   
                        style.border.top = applyBorderPart(top, style.border.top);
                        style.border.right = applyBorderPart(right, style.border.right);
                        style.border.bottom = applyBorderPart(bottom, style.border.bottom);
                        style.border.left = applyBorderPart(left, style.border.left);
                    default:
                }
            case "border-opacity":
                style.border.opacity = ValueTools.optionalFloat(directive.value);
            case "border-radius":
                style.border.radius = ValueTools.optionalFloat(directive.value);
            case "top":
                style.top = ValueTools.optionalFloat(directive.value);
            case "left":
                style.left = ValueTools.optionalFloat(directive.value);
            case "spacing":
                switch (directive.value) {
                    case VComposite(vl):
                        if (vl[0] != null) {
                            style.spacing.horizontal = ValueTools.optionalFloat(vl[0]);
                        }
                        if (vl[1] != null) {
                            style.spacing.vertical = ValueTools.optionalFloat(vl[1]);
                        }
                    case VDimension(PX(v)) | VNumber(v):
                        style.spacing.horizontal = v;
                        style.spacing.vertical = v;
                    case VNone:
                        style.spacing = none;
                    default:
                }
            case "display":
                style.display = ValueTools.optionalString(directive.value);
            case "cursor":
                style.cursor = ValueTools.optionalString(directive.value);
            case "color":
                style.color = ValueTools.color(directive.value);
            case "font":
                switch (directive.value) {
                    case VComposite(vl):
                        if (vl[0] != null) {
                            style.font.style = ValueTools.optionalString(vl[0]);
                        }
                        if (vl[1] != null) {
                            if (ValueTools.constant(vl[1], "bold") == true) {
                                style.font.weight = 700;
                            } else {
                                style.font.weight = ValueTools.optionalFloat(vl[1]);
                            }
                        }
                        if (vl[2] != null) {
                            style.font.size = ValueTools.optionalFloat(vl[2]);
                        }
                        if (vl[3] != null) {
                            style.font.family = ValueTools.optionalString(vl[3]);
                        }
                    case VNone:
                        style.font = none;
                    case VInherit:
                        style.font = inherit;
                    default:    
                }
            case "horizontal-align":
                style.horizontalAlign = ValueTools.optionalString(directive.value);
            case "vertical-align":
                style.verticalAlign = ValueTools.optionalString(directive.value);
            case "text-align":
                style.textAlign = ValueTools.optionalString(directive.value);
            case "opacity":
                style.opacity = ValueTools.optionalFloat(directive.value);
            case "background-image":
                switch (directive.value) {
                    case VComposite(vl):
                        if (vl[0] != null) {
                            style.backgroundImage.resource = ValueTools.optionalString(vl[0]);
                        }
                        if (vl[1] != null) {
                            style.backgroundImage.repeat = ValueTools.optionalString(vl[1]);
                        }
                    case VNone:
                        style.backgroundImage = none;
                    case VInherit:
                        style.backgroundImage = inherit;
                    default:
                        style.backgroundImage.resource = ValueTools.optionalString(directive.value);
                }
            case "background-image-repeat":   
                style.backgroundImage.repeat = ValueTools.optionalString(directive.value);
            case "background-image-clip":
                style.backgroundImage.clip = applyBounds(directive, style.padding);
            case "background-image-slice":
                style.backgroundImage.slice = applyBounds(directive, style.margin);
            case "animation2": // name, duration, delay, iteration, direction, easing, fill 
                trace("PROCESS ANIMATION");
                switch (directive.value) {
                    case VComposite(vl):
                        if (vl[0] != null) {
                            style.animation.name = ValueTools.optionalString(vl[0]);
                        }
                        if (vl[1] != null) {
                            style.animation.duration = ValueTools.optionalFloat(vl[1]);
                        }
                        if (vl[2] != null) {
                            style.animation.delay = ValueTools.optionalFloat(vl[2]);
                        }
                        if (vl[3] != null) {
                            style.animation.iterationCount = ValueTools.optionalInt(vl[3]);
                        }
                        if (vl[4] != null) {
                            style.animation.direction = ValueTools.optionalString(vl[4]);
                        }
                        if (vl[5] != null) {
                            style.animation.easingFunction = ValueTools.optionalString(vl[5]);
                        }
                        if (vl[6] != null) {
                            style.animation.fillMode = ValueTools.optionalString(vl[6]);
                        }
                    case VNone:
                        style.animation = none;
                    case VInherit:
                        style.animation = inherit;
                    default:    
                }
                trace("AFTER ANIMATION: " + style.animation);
            default:    
        }
    }
    
    private static function applyBorderPart(value:Value, currentPart:StyleBorderPart):StyleBorderPart {
        if (value == null) {
            return currentPart;
        }
        
        if (currentPart == null) {
            currentPart = {};
        }
        
        switch (value) {
            case VComposite(vl):
                if (vl.length == 1) {
                    if (vl[0] != null) {
                        currentPart.width = ValueTools.optionalFloat(vl[0]);
                    }
                } else if (vl.length == 2) {
                    if (vl[0] != null) {
                        currentPart.width = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[1] != null) {
                        currentPart.style = ValueTools.optionalString(vl[1]);
                    }
                } else if (vl.length == 3) {
                    if (vl[0] != null) {
                        currentPart.width = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[1] != null) {
                        currentPart.style = ValueTools.optionalString(vl[1]);
                    }
                    if (vl[2] != null) {
                        currentPart.color = ValueTools.optionalInt(vl[2]);
                    }
                }
            case VNone:
                currentPart = none;
            default:    
        }
        
        return currentPart;
    }
    
    private static function applyDimension(directive:Directive):StyleDimension {
        var d = null;
        switch (directive.value) {
            case VDimension(PERCENT(v)):
                d = percent(v);
            case VDimension(PX(v)):
                d = pixels(v);
            case VConstant(v):
                if (v == "auto") {
                    d = auto;
                }
            default:    
        }
        return d;
    }
    
    private static function applyBounds(directive:Directive, currentBounds:StyleBounds):StyleBounds {
        if (directive.value == null) {
            return null;
        }
        
        if (currentBounds == null) {
            currentBounds = {};
        }
        
        switch (directive.value) {
            case VComposite(vl):
                if (vl.length == 4) {
                    if (vl[0] != null) {
                        currentBounds.top = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[1] != null) {
                        currentBounds.right = ValueTools.optionalFloat(vl[1]);
                    }
                    if (vl[2] != null) {
                        currentBounds.bottom = ValueTools.optionalFloat(vl[2]);
                    }
                    if (vl[3] != null) {
                        currentBounds.left = ValueTools.optionalFloat(vl[3]);
                    }
                } else if (vl.length == 3) {
                    if (vl[0] != null) {
                        currentBounds.top = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[1] != null) {
                        currentBounds.right = ValueTools.optionalFloat(vl[1]);
                    }
                    if (vl[2] != null) {
                        currentBounds.bottom = ValueTools.optionalFloat(vl[2]);
                    }
                    if (vl[3] != null) {
                        currentBounds.left = ValueTools.optionalFloat(vl[1]);
                    }
                } else if (vl.length == 2) {
                    if (vl[0] != null) {
                        currentBounds.top = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[1] != null) {
                        currentBounds.right = ValueTools.optionalFloat(vl[1]);
                    }
                    if (vl[0] != null) {
                        currentBounds.bottom = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[1] != null) {
                        currentBounds.left = ValueTools.optionalFloat(vl[1]);
                    }
                } else if (vl.length == 1) {
                    if (vl[0] != null) {
                        currentBounds.top = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[0] != null) {
                        currentBounds.right = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[0] != null) {
                        currentBounds.bottom = ValueTools.optionalFloat(vl[0]);
                    }
                    if (vl[0] != null) {
                        currentBounds.left = ValueTools.optionalFloat(vl[0]);
                    }
                }
            case VDimension(_):
                currentBounds = {
                    top: ValueTools.optionalFloat(directive.value),
                    right: ValueTools.optionalFloat(directive.value),
                    bottom: ValueTools.optionalFloat(directive.value),
                    left: ValueTools.optionalFloat(directive.value) 
                }
            case VNone:
                currentBounds = none;
            default:   
                currentBounds = null;
        }
        
        return currentBounds;
    }
    
    public static function applyInheritence(style:Style2, component:Component) {
        if (style.color != null && style.color.isInherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.color != null && p.computedStyle.color.isInherit == false) {
                    style.color = p.computedStyle.color;
                    return false;
                }
                return true;
            });
        }
        
        if (style.backgroundColors != null && style.backgroundColors == inherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.backgroundColors != null && p.computedStyle.backgroundColors != inherit) {
                    style.backgroundColors = p.computedStyle.backgroundColors;
                    return false;
                }
                return true;
            });
        }
        
        if (style.cursor != null && style.cursor == inherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.cursor != null && p.computedStyle.cursor != inherit) {
                    style.cursor = p.computedStyle.cursor;
                    return false;
                }
                return true;
            });
        }
        
        if (style.font.family != null && style.font.family == inherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.font.family != null && p.computedStyle.font.family != inherit) {
                    style.font.family = p.computedStyle.font.family;
                    return false;
                }
                return true;
            });
        }
        
        if (style.font.size != null && style.font.size == inherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.font.size != null && p.computedStyle.font.size != inherit) {
                    style.font.size = p.computedStyle.font.size;
                    return false;
                }
                return true;
            });
        }
        
        if (style.font.style != null && style.font.style == inherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.font.style != null && p.computedStyle.font.style != inherit) {
                    style.font.style = p.computedStyle.font.style;
                    return false;
                }
                return true;
            });
        }
        
        if (style.font.weight != null && style.font.weight == inherit) {
            traverseParents(component, function(p) {
                if (p.computedStyle.font.weight != null && p.computedStyle.font.weight != inherit) {
                    style.font.weight = p.computedStyle.font.weight;
                    return false;
                }
                return true;
            });
        }
    }
    
    private static function traverseParents(c:Component, cb:Component->Bool) { // cb returns if we should continue traversing (false to stop)
        var p = c;
        while (p != null) {
            if (p.computedStyle != null) {
                if (cb(p) == false) {
                    break;
                }
            }
            p = p.parentComponent;
        }
    }
    
    // a - b
    public static function diffStyle(a:Style2, b:Style2):Style2 {
        var r:Style2 = {};
        if (a == null || b == null) {
            return r;
        }
        
        if (a.backgroundColors != null && b.backgroundColors != null) {
            var backgroundColorsA:Array<StyleColorBlock> = a.backgroundColors;
            var backgroundColorsB:Array<StyleColorBlock> = b.backgroundColors;
            var backgroundColorsC:Array<StyleColorBlock> = [];
            for (i in 0...backgroundColorsA.length) {
                var colorA = backgroundColorsA[i];
                var colorB = backgroundColorsB[i];
                if (colorB == null) {
                    colorB = colorA;
                }
                backgroundColorsC.push({
                    color: colorA.color - colorB.color,
                    block: colorA.block
                });
            }
            r.backgroundColors = backgroundColorsC;
        }
        
        if (a.width != null && b.width != null) {
            switch [a.width, b.width] {
                case [pixels(va), pixels(vb)]:
                    r.width = pixels(va - vb);
                case [percent(va), percent(vb)]:
                    r.width = percent(va - vb);
                case _:    
            }
        }
        
        if (a.height != null && b.height != null) {
            switch [a.height, b.height] {
                case [pixels(va), pixels(vb)]:
                    r.height = pixels(va - vb);
                case [percent(va), percent(vb)]:
                    r.height = percent(va - vb);
                case _:    
            }
        }
        
        if (a.padding != null && b.padding != null && a.padding.isNull == false && b.padding.isNull == false) {
            if (a.padding.left != null && b.padding.left != null) {
                var leftA:Float = a.padding.left;
                var leftB:Float = b.padding.left;
                r.padding.left = leftA - leftB;
            }
            if (a.padding.top != null && b.padding.top != null) {
                var topA:Float = a.padding.top;
                var topB:Float = b.padding.top;
                r.padding.top = topA - topB;
            }
            if (a.padding.right != null && b.padding.right != null) {
                var rightA:Float = a.padding.right;
                var rightB:Float = b.padding.right;
                r.padding.right = rightA - rightB;
            }
            if (a.padding.bottom != null && b.padding.bottom != null) {
                var bottomA:Float = a.padding.bottom;
                var bottomB:Float = b.padding.bottom;
                r.padding.bottom = bottomA - bottomB;
            }
        }
        
        if (a.border != null && b.border != null && a.border.isNull == false && b.border.isNull == false) {
            if (a.border.left != null && b.border.left != null && a.border.left.isNull == false && b.border.left.isNull == false) {
                if (a.border.left.width != null && b.border.left.width != null) {
                    var leftA:Float = a.border.left.width;
                    var leftB:Float = b.border.left.width;
                    r.border.left.width = leftA - leftB;
                }
                if (a.border.left.color != null && b.border.left.color != null) {
                    r.border.left.color = a.border.left.color - b.border.left.color;
                }
            }
            if (a.border.top != null && b.border.top != null && a.border.top.isNull == false && b.border.top.isNull == false) {
                if (a.border.top.width != null && b.border.top.width != null) {
                    var leftA:Float = a.border.top.width;
                    var leftB:Float = b.border.top.width;
                    r.border.top.width = leftA - leftB;
                }
                if (a.border.top.color != null && b.border.top.color != null) {
                    r.border.top.color = a.border.top.color - b.border.top.color;
                }
            }
            if (a.border.bottom != null && b.border.bottom != null && a.border.bottom.isNull == false && b.border.bottom.isNull == false) {
                if (a.border.bottom.width != null && b.border.bottom.width != null) {
                    var leftA:Float = a.border.bottom.width;
                    var leftB:Float = b.border.bottom.width;
                    r.border.bottom.width = leftA - leftB;
                }
                if (a.border.bottom.color != null && b.border.bottom.color != null) {
                    r.border.bottom.color = a.border.bottom.color - b.border.bottom.color;
                }
            }
            if (a.border.right != null && b.border.right != null && a.border.right.isNull == false && b.border.right.isNull == false) {
                if (a.border.right.width != null && b.border.right.width != null) {
                    var leftA:Float = a.border.right.width;
                    var leftB:Float = b.border.right.width;
                    r.border.right.width = leftA - leftB;
                }
                if (a.border.right.color != null && b.border.right.color != null) {
                    r.border.right.color = a.border.right.color - b.border.right.color;
                }
            }
            if (a.border.radius != null && b.border.radius != null) {
                var radiusA:Float = a.border.radius;
                var radiusB:Float = b.border.radius;
                r.border.radius = radiusA - radiusB;
            }
        }
        
        return r;
    }
}