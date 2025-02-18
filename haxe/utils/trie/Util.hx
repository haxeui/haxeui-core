package haxe.utils.trie;

import haxe.utils.enumExtractor.EnumExtractor;
import haxe.utils.trie.NodeType;

class NodeTypeUtil implements EnumExtractor {
    public static function getTerminalValue<K, V>(node:NodeType<K, V>) : V {
        switch(node) {
            case null:
                return null;
            case Terminal(v):
                return v;
            case Node(_, children) | Root(children):
                for(child in children) {
                    @as(child => Terminal(v)) {
                        return v;
                    }
                }
                return null;
        }
    }

    public static function updateTerminalValue<K, V>(node:NodeType<K, V>, value:V) {
        switch(node) {
            case Node(_, children) | Root(children):
                var hasChanged:Bool = false;
                for(i in 0...children.length) {
                    @as(children[i] => Terminal(_)) {
                        children[i] = Terminal(value);
                        hasChanged = true;
                    }
                }
                if(!hasChanged) {
                    children.push(Terminal(value));
                }
            default:
        }
    }

    public static function appendChild<K, V>(node:NodeType<K, V>, child:NodeType<K, V>) : Void {
        @as(node => Node(_, children) | Root(children)) {
            children.push(child);
        }
    }
}