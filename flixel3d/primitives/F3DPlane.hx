package flixel3d.primitives;

import flixel3d.F3DMesh;
import flixel3d.F3DObject;
import flixel3d.F3DMaterial;

/**
 * Flat horizontal plane (XZ) facing up (+Y).
 * @param size   Width and depth of the plane.
 * @param segs   Number of subdivisions per axis (1 = single quad).
 */
class F3DPlane extends F3DObject {
    public function new(size:Float = 1, segs:Int = 1, ?material:F3DMaterial) {
        super(_buildMesh(size, segs), material != null ? material : new F3DMaterial());
    }

    static function _buildMesh(size:Float, segs:Int):F3DMesh {
        if (segs < 1) segs = 1;
        var half = size * 0.5;
        var step = size / segs;

        var verts:Array<Float> = [];
        var idx:Array<Int> = [];

        for (row in 0...(segs + 1)) {
            for (col in 0...(segs + 1)) {
                var x = -half + col * step;
                var z = -half + row * step;
                var u = col / segs;
                var v = row / segs;
                verts = verts.concat([x, 0, z,  0, 1, 0,  u, v]);
            }
        }

        var w = segs + 1;
        for (row in 0...segs) {
            for (col in 0...segs) {
                var a = row * w + col;
                var b = a + 1;
                var c = a + w;
                var d = c + 1;
                idx = idx.concat([a, c, b,  b, c, d]);
            }
        }

        return new F3DMesh(verts, idx);
    }
}
