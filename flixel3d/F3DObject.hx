package flixel3d;

import flixel3d.math.F3DMatrix4;
import flixel3d.math.F3DVector3;
import flixel3d.math.F3DQuaternion;

/**
 * Base 3D object. Has a transform (position/rotation/scale), a mesh, and a material.
 * Subclass this or use it directly with custom meshes.
 */
class F3DObject {
    public var position:F3DVector3;
    public var rotation:F3DQuaternion;
    public var scale:F3DVector3;

    public var mesh:F3DMesh;
    public var material:F3DMaterial;
    public var visible:Bool = true;

    /** Optional tag for scene lookups. */
    public var name:String = "";

    public function new(?mesh:F3DMesh, ?material:F3DMaterial) {
        position = new F3DVector3(0, 0, 0);
        rotation = new F3DQuaternion();
        scale    = new F3DVector3(1, 1, 1);

        this.mesh     = mesh;
        this.material = (material != null) ? material : new F3DMaterial();
    }

    // --- Euler helpers (radians) ---

    public function setEuler(pitch:Float, yaw:Float, roll:Float):Void {
        rotation = F3DQuaternion.fromEuler(pitch, yaw, roll);
    }

    public function rotateX(angle:Float):Void
        rotation = rotation.multiply(F3DQuaternion.fromAxisAngle(new F3DVector3(1, 0, 0), angle));

    public function rotateY(angle:Float):Void
        rotation = rotation.multiply(F3DQuaternion.fromAxisAngle(new F3DVector3(0, 1, 0), angle));

    public function rotateZ(angle:Float):Void
        rotation = rotation.multiply(F3DQuaternion.fromAxisAngle(new F3DVector3(0, 0, 1), angle));

    // --- Transform ---

    public function getModelMatrix():F3DMatrix4 {
        var t = F3DMatrix4.translation(position.x, position.y, position.z);
        var r = rotation.normalize().toMatrix4();
        var s = F3DMatrix4.scaling(scale.x, scale.y, scale.z);
        return t.multiply(r).multiply(s);
    }

    public function lookAt(target:F3DVector3):Void {
        var dir = target.sub(position).normalize();
        if (dir.lengthSq() < 1e-10) return;
        var up = new F3DVector3(0, 1, 0);
        if (Math.abs(dir.dot(up)) > 0.999) up = new F3DVector3(0, 0, 1);

        var right   = dir.cross(up).normalize();
        var realUp  = right.cross(dir);

        var m = new F3DMatrix4();
        m.m[0]  = right.x;  m.m[4]  = right.y;  m.m[8]  = right.z;
        m.m[1]  = realUp.x; m.m[5]  = realUp.y; m.m[9]  = realUp.z;
        m.m[2]  = -dir.x;   m.m[6]  = -dir.y;   m.m[10] = -dir.z;

        // Convert matrix to quaternion
        var tr = m.m[0] + m.m[5] + m.m[10];
        if (tr > 0) {
            var s = 0.5 / Math.sqrt(tr + 1);
            rotation = new F3DQuaternion(0.25 / s,
                (m.m[6] - m.m[9]) * s, (m.m[8] - m.m[2]) * s, (m.m[1] - m.m[4]) * s);
        } else if (m.m[0] > m.m[5] && m.m[0] > m.m[10]) {
            var s = 2 * Math.sqrt(1 + m.m[0] - m.m[5] - m.m[10]);
            rotation = new F3DQuaternion((m.m[6] - m.m[9]) / s,
                0.25 * s, (m.m[4] + m.m[1]) / s, (m.m[8] + m.m[2]) / s);
        } else if (m.m[5] > m.m[10]) {
            var s = 2 * Math.sqrt(1 + m.m[5] - m.m[0] - m.m[10]);
            rotation = new F3DQuaternion((m.m[8] - m.m[2]) / s,
                (m.m[4] + m.m[1]) / s, 0.25 * s, (m.m[9] + m.m[6]) / s);
        } else {
            var s = 2 * Math.sqrt(1 + m.m[10] - m.m[0] - m.m[5]);
            rotation = new F3DQuaternion((m.m[1] - m.m[4]) / s,
                (m.m[8] + m.m[2]) / s, (m.m[9] + m.m[6]) / s, 0.25 * s);
        }
    }

    /** Called each frame. Override in subclasses for per-object behavior. */
    public function update(elapsed:Float):Void {}

    public function destroy():Void {
        if (mesh != null) mesh.destroy();
    }
}
