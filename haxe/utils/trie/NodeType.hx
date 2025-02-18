package haxe.utils.trie;

enum NodeType<K, V> {
    Terminal(value:V);
    Node(key:K, children:Array<NodeType<K, V>>);
    Root(children:Array<NodeType<K, V>>);
}