package haxe.ui.data;

@:autoBuild(haxe.ui.macros.Macros.buildData())
interface IDataItem {
    var onDataSourceChanged:Void->Void;
}
