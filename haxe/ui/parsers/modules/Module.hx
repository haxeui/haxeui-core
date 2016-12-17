package haxe.ui.parsers.modules;

class Module {
    public var id(default, default):String;
    public var resourceEntries(default, default):Array<ModuleResourceEntry>;
    public var componentEntries(default, default):Array<ModuleComponentEntry>;
    public var scriptletEntries(default, default):Array<ModuleScriptletEntry>;
    public var themeEntries(default, default):Map<String, ModuleThemeEntry>;
    public var plugins(default, default):Array<ModulePluginEntry>;
    public var properties(default, default):Array<ModulePropertyEntry>;
    public var animations(default, default):Array<ModuleAnimationEntry>;

    public function new() {
        resourceEntries = [];
        componentEntries = [];
        scriptletEntries = [];
        themeEntries = new Map<String, ModuleThemeEntry>();
        plugins = [];
        properties = [];
        animations = [];
    }

    public function validate() {
    }
}

class ModuleResourceEntry {
    public var path(default, default):String;
    public var prefix(default, default):String;
    public var condition(default, default):String;

    public function new() {
    }
}

class ModuleComponentEntry {
    public var classPackage(default, default):String;
    public var className(default, default):String;
    public var classAlias(default, default):String;

    public function new() {
    }
}

class ModuleScriptletEntry {
    public var classPackage(default, default):String;
    public var className(default, default):String;
    public var classAlias(default, default):String;
    public var keep(default, default):Bool;
    public var staticClass(default, default):Bool;

    public function new() {
    }
}

class ModuleThemeEntry {
    public var name(default, default):String;
    public var parent(default, default):String;
    public var styles(default, default):Array<String>;

    public function new() {
        styles = [];
    }
}

class ModulePluginEntry {
    public var type(default, default):String;
    public var className(default, default):String;
    public var config(default, default):Map<String, String>;
    public var condition(default, default):String;

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

class ModuleAnimationEntry {
    public var id(default, default):String;
    public var ease(default, default):String;
    public var keyFrames(default, default):Array<ModuleAnimationKeyFrameEntry>;

    public function new() {
        keyFrames = [];
    }
}

class ModuleAnimationKeyFrameEntry {
    public var time(default, default):Int = 0;
    public var componentRefs(default, default):Map<String, ModuleAnimationComponentRefEntry>;

    public function new() {
        componentRefs = new Map<String, ModuleAnimationComponentRefEntry>();
    }
}

class ModuleAnimationComponentRefEntry {
    public var id(default, default):String;
    public var properties(default, default):Map<String, Float>;
    public var vars(default, default):Map<String, String>;

    public function new() {
        properties = new Map<String, Float>();
        vars  = new Map<String, String>();
    }
}
