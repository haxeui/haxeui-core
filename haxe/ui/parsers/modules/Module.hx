package haxe.ui.parsers.modules;

class Module {
    public var id(default, default):String;
    public var rootPath(default, default):String;
    public var priority(default, default):Int = 0;
    public var preloadList(default, default):String;
    public var resourceEntries(default, default):Array<ModuleResourceEntry>;
    public var componentEntries(default, default):Array<ModuleComponentEntry>;
    public var layoutEntries(default, default):Array<ModuleLayoutEntry>;
    public var scriptletEntries(default, default):Array<ModuleScriptletEntry>;
    public var themeEntries(default, default):Map<String, ModuleThemeEntry>;
    public var plugins(default, default):Array<ModulePluginEntry>;
    public var properties(default, default):Array<ModulePropertyEntry>;
    public var preload(default, default):Array<ModulePreloadEntry>;
    public var locales(default, default):Array<ModuleLocaleEntry>;

    public function new() {
        resourceEntries = [];
        componentEntries = [];
        layoutEntries = [];
        scriptletEntries = [];
        themeEntries = new Map<String, ModuleThemeEntry>();
        plugins = [];
        properties = [];
        preload = [];
        locales = [];
    }

    public function validate() {
    }
}

class ModuleResourceEntry {
    public var path(default, default):String;
    public var prefix(default, default):String;

    public function new() {
    }
}

class ModuleClassEntry {
    public var classPackage(default, default):String;
    public var className(default, default):String;
    public var classFolder(default, default):String;
    public var classFile(default, default):String;
    public var classAlias(default, default):String;

    public function new() {
    }
}

class ModuleComponentEntry extends ModuleClassEntry {
}

class ModuleLayoutEntry extends ModuleClassEntry {
}

class ModuleScriptletEntry extends ModuleClassEntry {
    public var keep(default, default):Bool;
    public var staticClass(default, default):Bool;
}

class ModuleThemeEntry {
    public var name(default, default):String;
    public var parent(default, default):String;
    public var styles(default, default):Array<ModuleThemeStyleEntry>;
    public var images(default, default):Array<ModuleThemeImageEntry>;

    public function new() {
        styles = [];
        images = [];
    }
}

class ModuleThemeStyleEntry {
    public var resource:String;
    public var priority:Float = 0;

    public function new() {
    }
}

class ModuleThemeImageEntry {
    public var id:String;
    public var resource:String;
    public var priority:Float = 0;

    public function new() {
    }
}

class ModulePluginEntry {
    public var type(default, default):String;
    public var className(default, default):String;
    public var config(default, default):Map<String, String>;

    public function new() {
        config = new Map<String, String>();
    }
}

class ModulePropertyEntry {
    public var name(default, default):String;
    public var value(default, default):String;

    public function new() {
    }
}

class ModulePreloadEntry {
    public var type(default, default):String;
    public var id(default, default):String;

    public function new() {
    }
}

class ModuleLocaleEntry {
    public var id(default, default):String;
    public var resources(default, default):Array<String> = [];
    
    public function new() {
    }
}

class ModuleLocaleResourceEntry {
    public var path(default, default):String;
    
    public function new() {
    }
}
