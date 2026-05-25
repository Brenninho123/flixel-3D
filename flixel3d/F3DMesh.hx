package flixel3d;

#if (openfl && !flash)
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
#end

/**
 * Holds geometry data and uploads it to the GPU.
 *
 * Vertex layout (8 floats per vertex):
 *   [x, y, z,  nx, ny, nz,  u, v]
 *   Stride = 32 bytes
 */
class F3DMesh {
    public static inline var STRIDE:Int    = 32; // bytes per vertex
    public static inline var POS_OFFSET:Int    = 0;
    public static inline var NORMAL_OFFSET:Int = 12;
    public static inline var UV_OFFSET:Int     = 24;

    /** Raw vertex data: [x,y,z, nx,ny,nz, u,v, ...] */
    public var vertices:Array<Float>;

    /** Triangle indices (must be < 65535 per batch). */
    public var indices:Array<Int>;

    public var indexCount(get, never):Int;
    inline function get_indexCount() return indices.length;

    #if (openfl && !flash)
    var _vbo:GLBuffer;
    var _ibo:GLBuffer;
    var _uploaded:Bool = false;
    #end

    public function new(vertices:Array<Float>, indices:Array<Int>) {
        this.vertices = vertices;
        this.indices  = indices;
    }

    /** Upload vertex/index data to the GPU. Call once after creation or after modifying geometry. */
    public function upload():Void {
        #if (openfl && !flash)
        if (_uploaded) destroy();

        _vbo = GL.createBuffer();
        GL.bindBuffer(GL.ARRAY_BUFFER, _vbo);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertices), GL.STATIC_DRAW);

        _ibo = GL.createBuffer();
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _ibo);
        GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new UInt16Array(indices), GL.STATIC_DRAW);

        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
        _uploaded = true;
        #end
    }

    /** Bind buffers and set up vertex attribute pointers for the current shader. */
    public function bind(posLoc:Int, normalLoc:Int, uvLoc:Int):Void {
        #if (openfl && !flash)
        if (!_uploaded) upload();

        GL.bindBuffer(GL.ARRAY_BUFFER, _vbo);
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _ibo);

        if (posLoc >= 0) {
            GL.enableVertexAttribArray(posLoc);
            GL.vertexAttribPointer(posLoc, 3, GL.FLOAT, false, STRIDE, POS_OFFSET);
        }
        if (normalLoc >= 0) {
            GL.enableVertexAttribArray(normalLoc);
            GL.vertexAttribPointer(normalLoc, 3, GL.FLOAT, false, STRIDE, NORMAL_OFFSET);
        }
        if (uvLoc >= 0) {
            GL.enableVertexAttribArray(uvLoc);
            GL.vertexAttribPointer(uvLoc, 2, GL.FLOAT, false, STRIDE, UV_OFFSET);
        }
        #end
    }

    public function unbind(posLoc:Int, normalLoc:Int, uvLoc:Int):Void {
        #if (openfl && !flash)
        if (posLoc >= 0)    GL.disableVertexAttribArray(posLoc);
        if (normalLoc >= 0) GL.disableVertexAttribArray(normalLoc);
        if (uvLoc >= 0)     GL.disableVertexAttribArray(uvLoc);
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
        #end
    }

    public function destroy():Void {
        #if (openfl && !flash)
        if (_uploaded) {
            GL.deleteBuffer(_vbo);
            GL.deleteBuffer(_ibo);
            _uploaded = false;
        }
        #end
    }
}
