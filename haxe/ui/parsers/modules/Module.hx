package haxe.ui.parsers.modules;

class Module {
    public var id(default, default):String;
    public var rootPath(default, default):String;
    public var priority(default, default):Int = 0;
    public var preloadList(default, default):String;
    public var resourceEntries(default, default):Array<ModuleResourceEntry>;
    public var componentEntries(default, default):Array<ModuleComponentEntry>;
    public var layoutEntries(default, default):Array<ModuleLayoutEntry>;
    public var themeEntries(default, default):Map<String, ModuleThemeEntry>;
    public var properties(default, default):Array<ModulePropertyEntry>;
    public var preload(default, default):Array<ModulePreloadEntry>;
    public var locales(default, default):Array<ModuleLocaleEntry>;
    public var actionInputSources(default, default):Array<ModuleActionInputSourceEntry>;

    public function new() {
        resourceEntries = [];
        componentEntries = [];
        layoutEntries = [];
        themeEntries = new Map<String, ModuleThemeEntry>();
        properties = [];
        preload = [];
        locales = [];
        actionInputSources = [];
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
    public var loadAll(default, default):Bool;

    public function new() {
    }
}

class ModuleComponentEntry extends ModuleClassEntry {
}

class ModuleLayoutEntry extends ModuleClassEntry {
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

class ModuleActionInputSourceEntry {
    public var className(default, default):String;
    
    public function new() {
    }
}
