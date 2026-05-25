package flixel3d;

import flixel3d.math.F3DMatrix4;
import flixel3d.math.F3DVector3;

/**
 * Perspective or orthographic camera.
 * Produces view and projection matrices for the renderer.
 */
class F3DCamera {
    public var position:F3DVector3;
    public var target:F3DVector3;
    public var up:F3DVector3;

    public var fov:Float;
    public var aspect:Float;
    public var near:Float;
    public var far:Float;

    /** If true, uses orthographic projection instead of perspective. */
    public var orthographic:Bool = false;
    public var orthoSize:Float = 5.0;

    public function new(aspect:Float = 1.777, fov:Float = 60) {
        this.aspect = aspect;
        this.fov    = fov * (Math.PI / 180);
        this.near   = 0.1;
        this.far    = 1000;

        position = new F3DVector3(0, 2, 5);
        target   = new F3DVector3(0, 0, 0);
        up       = new F3DVector3(0, 1, 0);
    }

    public function getViewMatrix():F3DMatrix4 {
        return F3DMatrix4.lookAt(position, target, up);
    }

    public function getProjectionMatrix():F3DMatrix4 {
        if (orthographic) {
            return _ortho(-orthoSize * aspect, orthoSize * aspect, -orthoSize, orthoSize, near, far);
        }
        return F3DMatrix4.perspective(fov, aspect, near, far);
    }

    private function _ortho(l:Float, r:Float, b:Float, t:Float, n:Float, f:Float):F3DMatrix4 {
        var mat = new F3DMatrix4();
        mat.m[0]  =  2 / (r - l);
        mat.m[5]  =  2 / (t - b);
        mat.m[10] = -2 / (f - n);
        mat.m[12] = -(r + l) / (r - l);
        mat.m[13] = -(t + b) / (t - b);
        mat.m[14] = -(f + n) / (f - n);
        return mat;
    }

    /** Move camera by delta in world space. */
    public function translate(dx:Float, dy:Float, dz:Float):Void {
        position.x += dx; position.y += dy; position.z += dz;
        target.x   += dx; target.y   += dy; target.z   += dz;
    }

    /** Orbit target point by yaw (Y) and pitch (X) angles in radians. */
    public function orbit(yaw:Float, pitch:Float):Void {
        var offset = position.sub(target);
        var radius = offset.length();
        var theta  = Math.atan2(offset.x, offset.z) + yaw;
        var phi    = Math.acos(Math.max(-0.99, Math.min(0.99, offset.y / radius))) + pitch;
        phi = Math.max(0.05, Math.min(Math.PI - 0.05, phi));
        position.set(
            target.x + radius * Math.sin(phi) * Math.sin(theta),
            target.y + radius * Math.cos(phi),
            target.z + radius * Math.sin(phi) * Math.cos(theta)
        );
    }

    /** Zoom toward/away from target. */
    public function zoom(delta:Float):Void {
        var dir = position.sub(target);
        var len = Math.max(0.5, dir.length() - delta);
        position = target.add(dir.normalize().scale(len));
    }

    /** Update aspect ratio (call after resize). */
    public function resize(width:Float, height:Float):Void {
        aspect = width / height;
    }
}
