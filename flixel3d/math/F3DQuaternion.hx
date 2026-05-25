package flixel3d.math;

/**
 * Unit quaternion for 3D rotation.
 * Avoids gimbal lock and enables smooth slerp interpolation.
 */
class F3DQuaternion {
    public var w:Float;
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public function new(w:Float = 1, x:Float = 0, y:Float = 0, z:Float = 0) {
        this.w = w; this.x = x; this.y = y; this.z = z;
    }

    /** Create from Euler angles (radians). Applied as Yaw * Pitch * Roll (Y * X * Z). */
    public static function fromEuler(pitch:Float, yaw:Float, roll:Float):F3DQuaternion {
        var hp = pitch * 0.5; var hy = yaw * 0.5; var hr = roll * 0.5;
        var cp = Math.cos(hp); var sp = Math.sin(hp);
        var cy = Math.cos(hy); var sy = Math.sin(hy);
        var cr = Math.cos(hr); var sr = Math.sin(hr);

        return new F3DQuaternion(
            cp * cy * cr + sp * sy * sr,
            sp * cy * cr - cp * sy * sr,
            cp * sy * cr + sp * cy * sr,
            cp * cy * sr - sp * sy * cr
        );
    }

    /** Create from axis-angle (axis must be normalized). */
    public static function fromAxisAngle(axis:F3DVector3, angle:Float):F3DQuaternion {
        var half = angle * 0.5;
        var s = Math.sin(half);
        return new F3DQuaternion(Math.cos(half), axis.x * s, axis.y * s, axis.z * s);
    }

    public function multiply(q:F3DQuaternion):F3DQuaternion {
        return new F3DQuaternion(
            w * q.w - x * q.x - y * q.y - z * q.z,
            w * q.x + x * q.w + y * q.z - z * q.y,
            w * q.y - x * q.z + y * q.w + z * q.x,
            w * q.z + x * q.y - y * q.x + z * q.w
        );
    }

    public function normalize():F3DQuaternion {
        var len = Math.sqrt(w * w + x * x + y * y + z * z);
        if (len < 1e-10) return new F3DQuaternion();
        var inv = 1.0 / len;
        return new F3DQuaternion(w * inv, x * inv, y * inv, z * inv);
    }

    public function conjugate():F3DQuaternion return new F3DQuaternion(w, -x, -y, -z);

    /** Spherical linear interpolation. */
    public function slerp(to:F3DQuaternion, t:Float):F3DQuaternion {
        var dot = w * to.w + x * to.x + y * to.y + z * to.z;
        if (dot < 0) { to = new F3DQuaternion(-to.w, -to.x, -to.y, -to.z); dot = -dot; }
        if (dot > 0.9995) {
            return new F3DQuaternion(
                w + t * (to.w - w), x + t * (to.x - x),
                y + t * (to.y - y), z + t * (to.z - z)
            ).normalize();
        }
        var theta0 = Math.acos(dot);
        var theta = theta0 * t;
        var sinTheta = Math.sin(theta);
        var sinTheta0 = Math.sin(theta0);
        var s0 = Math.cos(theta) - dot * sinTheta / sinTheta0;
        var s1 = sinTheta / sinTheta0;
        return new F3DQuaternion(
            s0 * w + s1 * to.w, s0 * x + s1 * to.x,
            s0 * y + s1 * to.y, s0 * z + s1 * to.z
        );
    }

    /** Convert to a rotation-only 4x4 column-major matrix. */
    public function toMatrix4():F3DMatrix4 {
        var r = new F3DMatrix4();
        var x2 = x + x; var y2 = y + y; var z2 = z + z;
        var xx = x * x2; var xy = x * y2; var xz = x * z2;
        var yy = y * y2; var yz = y * z2; var zz = z * z2;
        var wx = w * x2; var wy = w * y2; var wz = w * z2;

        r.m[0]  = 1 - (yy + zz); r.m[4]  = xy - wz;      r.m[8]  = xz + wy;
        r.m[1]  = xy + wz;       r.m[5]  = 1 - (xx + zz); r.m[9]  = yz - wx;
        r.m[2]  = xz - wy;       r.m[6]  = yz + wx;       r.m[10] = 1 - (xx + yy);
        return r;
    }

    public function clone():F3DQuaternion return new F3DQuaternion(w, x, y, z);
    public function toString():String return 'F3DQuaternion($w, $x, $y, $z)';
}
