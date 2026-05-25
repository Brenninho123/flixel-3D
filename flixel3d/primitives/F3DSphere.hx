package flixel3d.primitives;

import flixel3d.F3DMesh;
import flixel3d.F3DObject;
import flixel3d.F3DMaterial;

/**
 * UV sphere primitive.
 * @param radius  Sphere radius.
 * @param rings   Horizontal ring count (latitude divisions). Min 2.
 * @param segs    Vertical segment count (longitude divisions). Min 3.
 */
class F3DSphere extends F3DObject {
    public function new(radius:Float = 0.5, rings:Int = 16, segs:Int = 24, ?material:F3DMaterial) {
        super(_buildMesh(radius, rings, segs), material != null ? material : new F3DMaterial());
    }

    static function _buildMesh(radius:Float, rings:Int, segs:Int):F3DMesh {
        if (rings < 2) rings = 2;
        if (segs  < 3) segs  = 3;

        var verts:Array<Float> = [];
        var idx:Array<Int>     = [];

        for (ring in 0...(rings + 1)) {
            var phi = ring * Math.PI / rings;
            var sinPhi = Math.sin(phi);
            var cosPhi = Math.cos(phi);

            for (seg in 0...(segs + 1)) {
                var theta    = seg * 2 * Math.PI / segs;
                var sinTheta = Math.sin(theta);
                var cosTheta = Math.cos(theta);

                var nx = sinPhi * cosTheta;
                var ny = cosPhi;
                var nz = sinPhi * sinTheta;

                verts = verts.concat([
                    nx * radius, ny * radius, nz * radius,
                    nx, ny, nz,
                    seg / segs, ring / rings
                ]);
            }
        }

        var w = segs + 1;
        for (ring in 0...rings) {
            for (seg in 0...segs) {
                var a = ring * w + seg;
                var b = a + 1;
                var c = a + w;
                var d = c + 1;
                idx = idx.concat([a, b, c,  b, d, c]);
            }
        }

        return new F3DMesh(verts, idx);
    }
}
