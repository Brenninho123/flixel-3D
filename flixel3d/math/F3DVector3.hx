package flixel3d.math;

/**
 * Immutable-style 3D vector. Operations return new instances.
 * Use addSelf / scaleSelf for in-place mutation when performance matters.
 */
class F3DVector3 {
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public static final ZERO:F3DVector3    = new F3DVector3(0, 0, 0);
    public static final UP:F3DVector3      = new F3DVector3(0, 1, 0);
    public static final FORWARD:F3DVector3 = new F3DVector3(0, 0, -1);
    public static final RIGHT:F3DVector3   = new F3DVector3(1, 0, 0);

    public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public inline function set(x:Float, y:Float, z:Float):F3DVector3 {
        this.x = x; this.y = y; this.z = z;
        return this;
    }

    public inline function copyFrom(v:F3DVector3):F3DVector3 {
        x = v.x; y = v.y; z = v.z;
        return this;
    }

    public inline function add(v:F3DVector3):F3DVector3
        return new F3DVector3(x + v.x, y + v.y, z + v.z);

    public inline function sub(v:F3DVector3):F3DVector3
        return new F3DVector3(x - v.x, y - v.y, z - v.z);

    public inline function scale(s:Float):F3DVector3
        return new F3DVector3(x * s, y * s, z * s);

    public inline function negate():F3DVector3
        return new F3DVector3(-x, -y, -z);

    public inline function dot(v:F3DVector3):Float
        return x * v.x + y * v.y + z * v.z;

    public inline function cross(v:F3DVector3):F3DVector3 {
        return new F3DVector3(
            y * v.z - z * v.y,
            z * v.x - x * v.z,
            x * v.y - y * v.x
        );
    }

    public inline function lengthSq():Float return x * x + y * y + z * z;
    public inline function length():Float    return Math.sqrt(lengthSq());

    public inline function normalize():F3DVector3 {
        var len = length();
        return (len > 1e-10) ? scale(1.0 / len) : clone();
    }

    public inline function distanceTo(v:F3DVector3):Float return sub(v).length();

    public inline function lerp(v:F3DVector3, t:Float):F3DVector3
        return new F3DVector3(x + (v.x - x) * t, y + (v.y - y) * t, z + (v.z - z) * t);

    // --- In-place variants ---
    public inline function addSelf(v:F3DVector3):Void  { x += v.x; y += v.y; z += v.z; }
    public inline function scaleSelf(s:Float):Void      { x *= s;   y *= s;   z *= s;   }

    public inline function clone():F3DVector3 return new F3DVector3(x, y, z);

    public function toString():String return 'F3DVector3($x, $y, $z)';
}
