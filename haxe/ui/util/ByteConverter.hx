package haxe.ui.util;

#if (openfl || flash || nme)

import haxe.io.Bytes;

#if (openfl)
import openfl.utils.ByteArray;
#elseif (flash)
import flash.utils.ByteArray;
#elseif (nme)
import nme.utils.ByteArray;
#end

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
