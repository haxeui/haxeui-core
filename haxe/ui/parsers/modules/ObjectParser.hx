package haxe.ui.parsers.modules;
import haxe.ui.parsers.modules.Module.ModuleThemeStyleEntry;

class ObjectParser extends ModuleParser {
    private function fromObject(obj:Dynamic):Module {
        var module:Module = new Module();

        module.id = obj.id;
        if (obj.resources != null) {
            var resources:Array<Dynamic> = obj.resources;
            for (r in resources) {
                var resourceEntry:Module.ModuleResourceEntry = new Module.ModuleResourceEntry();
                resourceEntry.path = r.path;
                resourceEntry.prefix = r.prefix;
                module.resourceEntries.push(resourceEntry);
            }
        }

        if (obj.components != null) {
            var components:Array<Dynamic> = obj.components;
            for (c in components) {
                var classEntry:Module.ModuleComponentEntry = new Module.ModuleComponentEntry();
                classEntry.classPackage = Reflect.field(c, "package");
                classEntry.className = Reflect.field(c, "name");
                classEntry.classAlias = Reflect.field(c, "alias");
                module.componentEntries.push(classEntry);
            }
        }

        if (obj.themes != null) {
            var themes:Dynamic = obj.themes;
            for (themeId in Reflect.fields(themes)) {
                var t = Reflect.field(themes, themeId);
                var theme:Module.ModuleThemeEntry = new Module.ModuleThemeEntry();
                theme.name = themeId;
                theme.parent = t.parent;
                if (t.styles != null) {
                    var styles:Array<Dynamic> = t.styles;
                    for (s in styles) {
                        var styleEntry:ModuleThemeStyleEntry = new ModuleThemeStyleEntry();
                        styleEntry.resource = s.resource;
                        styleEntry.condition = s.condition;
                        theme.styles.push(styleEntry);
                    }
                }
                module.themeEntries.set(theme.name, theme);
            }
        }

        return module;
    }
}