package commands;

class HelpCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        if (params.additional.length == 0) {
            displayHelp();
        } else {
            var command = CommandFactory.get(params.additional[0]);
            if (command == null) {
                Util.log('command "${params.additional[0]}" not found');
                return;
            }
            command.displayHelp();
        }
    }
    
    public override function displayHelp() {
        Util.log('Usage : haxeui <create | install | update | build | run | test | custom-component> [${Util.backendString(" | ")}] [options]\n');
        Util.log('Options :');
        Util.log('  create           : creates project files for given backend');
        Util.log('  install          : install required libraries for given backend');
        Util.log('  update           : updates required libraries for given backend');
        Util.log('  build            : builds project for given backend');
        Util.log('  run              : runs resulting project from build (assumes project has already been built)');
        Util.log('  test             : builds and runs project for backend');
        Util.log('  custom-component : creates files for a custom component');
        Util.log('  options          : depends on command / backend\n');
        Util.log('use "haxeui help <command>" for information about command');
    }
}