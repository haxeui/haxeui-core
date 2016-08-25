package haxe.ui.core;

import haxe.ui.data.DataSource;

interface IDataComponent {
    public var dataSource(get, set):DataSource<Dynamic>;
}