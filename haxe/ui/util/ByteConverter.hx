package haxe.ui.util;

#if (openfl || flash)

import haxe.io.Bytes;
import openfl.utils.ByteArray;

class ByteConverter {
    public static function fromHaxeBytes(bytes:Bytes):ByteArray {
        var ba:ByteArray = new ByteArray();
        for (a in 0...bytes.length) {
            ba.writeByte(Bytes.fastGet(bytes.getData(), a));
        }
        return ba;
    }

    public static function toHaxeBytes(ba:ByteArray):Bytes {
        var bytes:Bytes = Bytes.alloc(ba.length);
        for (a in 0...ba.length) {
            bytes.set(a, ba.readByte());
        }
        return bytes;
    }
}

#end
