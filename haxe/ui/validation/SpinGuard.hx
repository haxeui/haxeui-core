package haxe.ui.validation;

import haxe.ds.ObjectMap;

/**
 * Tells a validation pass that is merely large from one that will never end (JoeClash fork).
 *
 * ValidationManager.process drains a queue that validation itself refills. Components that keep
 * invalidating each other hold it non-empty forever: no frame is drawn and nothing says why. But a
 * screen that is just big - an outline of 800 rows is ~10,000 components and ~92,000 validations
 * on its first layout - is long too, and must finish. What tells them apart is not the length of
 * the pass but the same component coming back again and again: in that big layout no component
 * was validated more than 26 times.
 *
 * So nothing is tallied until a pass has run QUIET validations (the common case costs one int);
 * from then on each component is counted, and one validated LIMIT times since is spinning.
 * One SpinGuard per pass.
 */
class SpinGuard {
    /** Validations in one pass before components are counted one by one. */
    public static inline var QUIET = 20000;
    /** Validations of one component, once counting, that mean it will never settle. */
    public static inline var LIMIT = 500;

    /** Validations counted in this pass. */
    public var total(default, null):Int = 0;

    var counts:Null<ObjectMap<{}, Int>> = null;

    public function new() {}

    /** Counts one validation of `item`; true once it has been validated LIMIT times since counting began. */
    public function count(item:{}):Bool {
        total++;
        if (total <= QUIET) return false;
        if (counts == null) counts = new ObjectMap<{}, Int>();
        var n = (counts.exists(item) ? counts.get(item) : 0) + 1;
        counts.set(item, n);
        return n >= LIMIT;
    }

    /** The `n` components validated most often since counting began, most first. */
    public function busiest(n:Int):Array<{item:{}, count:Int}> {
        if (counts == null) return [];
        var all = [for (k in counts.keys()) {item: k, count: counts.get(k)}];
        all.sort((a, b) -> b.count - a.count);
        return all.slice(0, n);
    }
}
