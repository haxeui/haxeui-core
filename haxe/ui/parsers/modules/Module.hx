package haxe.ui.parsers.modules;

class Module {
	public var id(default, default):String;
	public var resourceEntries(default, default):Array<ModuleResourceEntry> = new Array<ModuleResourceEntry>();
	public var componentEntries(default, default):Array<ModuleComponentEntry> = new Array<ModuleComponentEntry>();
	public var scriptletEntries(default, default):Array<ModuleScriptletEntry> = new Array<ModuleScriptletEntry>();
	public var themeEntries(default, default):Map<String, ModuleThemeEntry> = new Map<String, ModuleThemeEntry>();
	public var plugins(default, default):Array<ModulePluginEntry> = new Array<ModulePluginEntry>();
	public var properties(default, default):Array<ModulePropertyEntry> = new Array<ModulePropertyEntry>();
	public var animations(default, default):Array<ModuleAnimationEntry> = new Array<ModuleAnimationEntry>();
	
	public function new() {
	}
	
	public function validate() {
		
	}
	
	public function toString():String {
		var s:String = "";
		s += 'id: ${id}\n';
		
		s += 'resources:\n';
		for (resourceEntry in resourceEntries) {
			s += '  path: ${resourceEntry.path}, prefix: ${resourceEntry.prefix}\n';
		}
		
		s += 'components:\n';
		for (componentEntry in componentEntries) {
			if (componentEntry.classPackage != null) {
				s += '  package: ${componentEntry.classPackage}\n';
			}
			if (componentEntry.className != null) {
				s += '  class: ${componentEntry.className}';
				if (componentEntry.classAlias != null) {
					s += ', alias: ${componentEntry.classAlias}';
				}
				s += '\n';
			}
		}
		
		s += 'themes:\n';
		for (themeId in themeEntries.keys()) {
			var themeEntry:ModuleThemeEntry =  themeEntries.get(themeId);
			s += '  ${themeId}:\n';
			if (themeEntry.parent != null) {
				s += '    parent: ${themeEntry.parent}\n';
			}
			s += '    styles:\n';
			for (styleEntry in themeEntry.styles) {
				s += '      * ${styleEntry}\n';
			}
		}
		return s;
	}
}

class ModuleResourceEntry {
	public function new() {
	}
	
	public var path(default, default):String;
	public var prefix(default, default):String;
    public var condition(default, default):String;
}

class ModuleComponentEntry {
	public function new() {
	}
	
	public var classPackage(default, default):String;
	public var className(default, default):String;
	public var classAlias(default, default):String;
}

class ModuleScriptletEntry {
	public function new() {
	}
	
	public var classPackage(default, default):String;
	public var className(default, default):String;
	public var classAlias(default, default):String;
	public var keep(default, default):Bool;
	public var staticClass(default, default):Bool;
}

class ModuleThemeEntry {
	public function new() {
	}
	
	public var name(default, default):String;
	public var parent(default, default):String;
	public var styles(default, default):Array<String> = new Array<String>();
}

class ModulePluginEntry {
	public function new() {
	}
	
	public var type(default, default):String;
	public var className(default, default):String;
	public var config(default, default):Map<String, String> = new Map<String, String>();
    public var condition(default, default):String;
}

class ModulePropertyEntry {
	public function new() {
	}
	
	public var name(default, default):String;
	public var value(default, default):String;
}

class ModuleAnimationEntry {
	public function new() {
	}
	
	public var id(default, default):String;
	public var ease(default, default):String;
	public var keyFrames(default, default):Array<ModuleAnimationKeyFrameEntry> = new Array<ModuleAnimationKeyFrameEntry>();
}

class ModuleAnimationKeyFrameEntry {
	public function new() {
	}
	
	public var time(default, default):Int = 0;
	public var componentRefs(default, default):Map<String, ModuleAnimationComponentRefEntry> = new Map<String, ModuleAnimationComponentRefEntry>();
}

class ModuleAnimationComponentRefEntry {
	public function new() {
	}
	
	public var id(default, default):String;
	public var properties(default, default):Map<String, Float> = new Map<String, Float>();
	public var vars(default, default):Map<String, String> = new Map<String, String>();
}