package flixel3d.primitives;

import flixel3d.F3DMesh;
import flixel3d.F3DObject;
import flixel3d.F3DMaterial;

/**
 * Axis-aligned box primitive.
 * @param size Side length (default 1).
 */
class F3DCube extends F3DObject {
    public function new(size:Float = 1, ?material:F3DMaterial) {
        super(_buildMesh(size), material != null ? material : new F3DMaterial());
    }

    static function _buildMesh(s:Float):F3DMesh {
        var h = s * 0.5;

        // Vertex layout: [x,y,z, nx,ny,nz, u,v]
        var v:Array<Float> = [
            // Front (+Z)
            -h,-h, h,  0, 0, 1,  0,0,
             h,-h, h,  0, 0, 1,  1,0,
             h, h, h,  0, 0, 1,  1,1,
            -h, h, h,  0, 0, 1,  0,1,
            // Back (-Z)
             h,-h,-h,  0, 0,-1,  0,0,
            -h,-h,-h,  0, 0,-1,  1,0,
            -h, h,-h,  0, 0,-1,  1,1,
             h, h,-h,  0, 0,-1,  0,1,
            // Left (-X)
            -h,-h,-h, -1, 0, 0,  0,0,
            -h,-h, h, -1, 0, 0,  1,0,
            -h, h, h, -1, 0, 0,  1,1,
            -h, h,-h, -1, 0, 0,  0,1,
            // Right (+X)
             h,-h, h,  1, 0, 0,  0,0,
             h,-h,-h,  1, 0, 0,  1,0,
             h, h,-h,  1, 0, 0,  1,1,
             h, h, h,  1, 0, 0,  0,1,
            // Top (+Y)
            -h, h, h,  0, 1, 0,  0,0,
             h, h, h,  0, 1, 0,  1,0,
             h, h,-h,  0, 1, 0,  1,1,
            -h, h,-h,  0, 1, 0,  0,1,
            // Bottom (-Y)
            -h,-h,-h,  0,-1, 0,  0,0,
             h,-h,-h,  0,-1, 0,  1,0,
             h,-h, h,  0,-1, 0,  1,1,
            -h,-h, h,  0,-1, 0,  0,1,
        ];

        var idx:Array<Int> = [];
        for (face in 0...6) {
            var b = face * 4;
            idx.push(b);   idx.push(b+1); idx.push(b+2);
            idx.push(b);   idx.push(b+2); idx.push(b+3);
        }

        return new F3DMesh(v, idx);
    }
}
