package flixel3d.math;

import lime.utils.Float32Array;

/**
 * Column-major 4x4 matrix, compatible with OpenGL memory layout.
 *
 * Visual layout (m[col*4 + row]):
 *   m[0]  m[4]  m[8]  m[12]
 *   m[1]  m[5]  m[9]  m[13]
 *   m[2]  m[6]  m[10] m[14]
 *   m[3]  m[7]  m[11] m[15]
 */
class F3DMatrix4 {
    public var m:Array<Float>;

    public function new() {
        m = [for (_ in 0...16) 0.0];
        identity();
    }

    public function identity():F3DMatrix4 {
        for (i in 0...16) m[i] = 0;
        m[0] = m[5] = m[10] = m[15] = 1;
        return this;
    }

    /** Matrix multiplication: this * b */
    public function multiply(b:F3DMatrix4):F3DMatrix4 {
        var r = new F3DMatrix4();
        for (col in 0...4)
            for (row in 0...4) {
                var s = 0.0;
                for (k in 0...4) s += m[k * 4 + row] * b.m[col * 4 + k];
                r.m[col * 4 + row] = s;
            }
        return r;
    }

    // --- Static constructors ---

    public static function translation(x:Float, y:Float, z:Float):F3DMatrix4 {
        var r = new F3DMatrix4();
        r.m[12] = x; r.m[13] = y; r.m[14] = z;
        return r;
    }

    public static function scaling(x:Float, y:Float, z:Float):F3DMatrix4 {
        var r = new F3DMatrix4();
        r.m[0] = x; r.m[5] = y; r.m[10] = z;
        return r;
    }

    public static function rotationX(a:Float):F3DMatrix4 {
        var r = new F3DMatrix4();
        var c = Math.cos(a); var s = Math.sin(a);
        r.m[5] = c;  r.m[9]  = -s;
        r.m[6] = s;  r.m[10] =  c;
        return r;
    }

    public static function rotationY(a:Float):F3DMatrix4 {
        var r = new F3DMatrix4();
        var c = Math.cos(a); var s = Math.sin(a);
        r.m[0]  =  c; r.m[8]  = s;
        r.m[2]  = -s; r.m[10] = c;
        return r;
    }

    public static function rotationZ(a:Float):F3DMatrix4 {
        var r = new F3DMatrix4();
        var c = Math.cos(a); var s = Math.sin(a);
        r.m[0] = c;  r.m[4] = -s;
        r.m[1] = s;  r.m[5] =  c;
        return r;
    }

    /**
     * Standard perspective projection matrix.
     * @param fovRad Field of view in radians.
     * @param aspect Width / height.
     * @param near   Near clip plane (> 0).
     * @param far    Far clip plane.
     */
    public static function perspective(fovRad:Float, aspect:Float, near:Float, far:Float):F3DMatrix4 {
        var r = new F3DMatrix4();
        var f = 1.0 / Math.tan(fovRad * 0.5);
        r.m[0]  = f / aspect;
        r.m[5]  = f;
        r.m[10] = (far + near) / (near - far);
        r.m[11] = -1;
        r.m[14] = (2.0 * far * near) / (near - far);
        r.m[15] = 0;
        return r;
    }

    /**
     * View matrix pointing from eye toward center.
     */
    public static function lookAt(eye:F3DVector3, center:F3DVector3, up:F3DVector3):F3DMatrix4 {
        var f = center.sub(eye).normalize();
        var r = f.cross(up).normalize();
        var u = r.cross(f);

        var mat = new F3DMatrix4();
        mat.m[0]  =  r.x; mat.m[4]  =  r.y; mat.m[8]  =  r.z; mat.m[12] = -r.dot(eye);
        mat.m[1]  =  u.x; mat.m[5]  =  u.y; mat.m[9]  =  u.z; mat.m[13] = -u.dot(eye);
        mat.m[2]  = -f.x; mat.m[6]  = -f.y; mat.m[10] = -f.z; mat.m[14] =  f.dot(eye);
        mat.m[3]  =  0;   mat.m[7]  =  0;   mat.m[11] =  0;   mat.m[15] =  1;
        return mat;
    }

    /**
     * Computes the normal matrix (transpose of the inverse of the upper-left 3x3).
     * Required for correct lighting with non-uniform scale.
     * Returns a flat 9-element column-major array (mat3 in GLSL).
     */
    public function normalMatrix():Array<Float> {
        var a = m[0]; var b = m[4]; var c = m[8];
        var d = m[1]; var e = m[5]; var f = m[9];
        var g = m[2]; var h = m[6]; var i = m[10];

        var det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
        if (Math.abs(det) < 1e-10) return [1, 0, 0, 0, 1, 0, 0, 0, 1];

        var inv = 1.0 / det;
        // Cofactor matrix (= normal matrix since it's transpose of inverse for orthogonal scale)
        return [
            (e * i - f * h) * inv,  // col0 row0
            (f * g - d * i) * inv,  // col0 row1
            (d * h - e * g) * inv,  // col0 row2
            (c * h - b * i) * inv,  // col1 row0
            (a * i - c * g) * inv,  // col1 row1
            (b * g - a * h) * inv,  // col1 row2
            (b * f - c * e) * inv,  // col2 row0
            (c * d - a * f) * inv,  // col2 row1
            (a * e - b * d) * inv   // col2 row2
        ];
    }

    public function toFloat32Array():Float32Array return new Float32Array(m);

    public function clone():F3DMatrix4 {
        var r = new F3DMatrix4();
        for (i in 0...16) r.m[i] = m[i];
        return r;
    }
}
