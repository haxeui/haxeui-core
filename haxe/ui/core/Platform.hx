package haxe.ui.core;

import haxe.ui.backend.PlatformBase;

class Platform extends PlatformBase {
    public static inline var METRIC_VSCROLL_WIDTH:String = "patform.metrics.vscroll.width";
    public static inline var METRIC_HSCROLL_HEIGHT:String = "patform.metrics.hscroll.height";

    public static var vscrollWidth(get, null):Float;
    private static function get_vscrollWidth():Float {
        return instance.getMetric(METRIC_VSCROLL_WIDTH);
    }

    public static var hscrollHeight(get, null):Float;
    private static function get_hscrollHeight():Float {
        return instance.getMetric(METRIC_HSCROLL_HEIGHT);
    }

    private static var _instance:Platform;
    public static var instance(get, null):Platform;
    private static function get_instance():Platform {
        if (_instance == null) {
            _instance = new Platform();
        }
        return _instance;
    }

    public function new() {

    }

    public override function getMetric(id:String):Float {
        return super.getMetric(id);
    }
}