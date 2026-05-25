package flixel3d;

import flixel3d.math.F3DVector3;

class F3DMaterial {
    /** Diffuse color (RGB, 0–1 range). */
    public var color:F3DVector3;

    /** Ambient factor (0–1). Controls minimum brightness. */
    public var ambient:Float;

    /** Specular intensity (0–1). */
    public var specular:Float;

    /** Specular exponent (shininess). Higher = sharper highlight. */
    public var shininess:Float;

    public function new(r:Float = 1, g:Float = 1, b:Float = 1) {
        color     = new F3DVector3(r, g, b);
        ambient   = 0.15;
        specular  = 0.5;
        shininess = 64.0;
    }

    // --- Static presets ---

    public static function white():F3DMaterial   return new F3DMaterial(1, 1, 1);
    public static function red():F3DMaterial     return new F3DMaterial(0.9, 0.2, 0.2);
    public static function green():F3DMaterial   return new F3DMaterial(0.2, 0.8, 0.3);
    public static function blue():F3DMaterial    return new F3DMaterial(0.2, 0.4, 0.9);
    public static function yellow():F3DMaterial  return new F3DMaterial(0.95, 0.85, 0.1);
    public static function gray():F3DMaterial    return new F3DMaterial(0.5, 0.5, 0.5);

    public static function fromHex(hex:Int):F3DMaterial {
        return new F3DMaterial(
            ((hex >> 16) & 0xFF) / 255.0,
            ((hex >> 8)  & 0xFF) / 255.0,
            (hex & 0xFF) / 255.0
        );
    }

    public function clone():F3DMaterial {
        var m = new F3DMaterial(color.x, color.y, color.z);
        m.ambient   = ambient;
        m.specular  = specular;
        m.shininess = shininess;
        return m;
    }
}
