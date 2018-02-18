package projects;
import haxe.Resource;
import haxe.Template;

class ProjectFactory {
    public static function get(name:String):Project {
        var p:Project = null;
        
        var jsonString = Resource.getString('projects/${name}/project.json');
        if (jsonString == null) {
            throw 'Could not read: projects/${name}/project.json';
        }
        
        var tempParser = new json2object.JsonParser<Project>();
        tempParser.fromJson(jsonString, 'projects/${name}/project.json');
        var temp:Project = tempParser.value;
        switch (temp.type) {
            case "template":
                var templateParser = new json2object.JsonParser<TemplateProject>();
                templateParser.fromJson(jsonString, 'projects/${name}/project.json');
                p = templateParser.value;
            case _:    
        }
        
        //trace(json2object.ErrorUtils.convertErrorArray(parser2.errors));
        
        return p;
    }
}