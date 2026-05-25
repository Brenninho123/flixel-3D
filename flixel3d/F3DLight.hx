package flixel3d;

import flixel3d.math.F3DVector3;

enum F3DLightType {
    Point;
    Directional;
}

class F3DLight {
    public var type:F3DLightType;

    /** Position (Point) or direction (Directional, should be normalized). */
    public var position:F3DVector3;

    public var color:F3DVector3;
    public var intensity:Float;
    public var enabled:Bool;

    public function new(type:F3DLightType = Point) {
        this.type      = type;
        this.position  = new F3DVector3(5, 10, 5);
        this.color     = new F3DVector3(1, 1, 1);
        this.intensity = 1.0;
        this.enabled   = true;
    }

    public static function point(x:Float, y:Float, z:Float, intensity:Float = 1.0):F3DLight {
        var l = new F3DLight(Point);
        l.position.set(x, y, z);
        l.intensity = intensity;
        return l;
    }

    public static function directional(dx:Float, dy:Float, dz:Float, intensity:Float = 1.0):F3DLight {
        var l = new F3DLight(Directional);
        l.position = new F3DVector3(dx, dy, dz).normalize();
        l.intensity = intensity;
        return l;
    }
}
