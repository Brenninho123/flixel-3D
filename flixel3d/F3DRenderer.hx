package flixel3d;

#if (openfl && !flash)
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import flixel3d.math.F3DMatrix4;
import flixel3d.math.F3DVector3;
#end

/**
 * OpenGL renderer. Compiles the Phong shader once and draws all visible F3DObjects.
 * Supports up to F3DRenderer.MAX_LIGHTS point/directional lights per draw call.
 */
class F3DRenderer {
    public static inline var MAX_LIGHTS:Int = 4;

    #if (openfl && !flash)
    var _program:GLProgram;
    var _posLoc:Int;
    var _normalLoc:Int;
    var _uvLoc:Int;

    var _uMVP:GLUniformLocation;
    var _uModel:GLUniformLocation;
    var _uNormalMat:GLUniformLocation;
    var _uColor:GLUniformLocation;
    var _uCamPos:GLUniformLocation;
    var _uAmbient:GLUniformLocation;
    var _uSpecular:GLUniformLocation;
    var _uShininess:GLUniformLocation;
    var _uLightPos:Array<GLUniformLocation>;
    var _uLightColor:Array<GLUniformLocation>;
    var _uLightIntensity:Array<GLUniformLocation>;
    var _uNumLights:GLUniformLocation;

    static final VERT_SRC = '
        attribute vec3 aPosition;
        attribute vec3 aNormal;
        attribute vec2 aUV;

        uniform mat4 uMVP;
        uniform mat4 uModel;
        uniform mat3 uNormalMat;

        varying vec3 vNormal;
        varying vec3 vFragPos;
        varying vec2 vUV;

        void main() {
            vec4 worldPos = uModel * vec4(aPosition, 1.0);
            vFragPos  = worldPos.xyz;
            vNormal   = uNormalMat * aNormal;
            vUV       = aUV;
            gl_Position = uMVP * vec4(aPosition, 1.0);
        }
    ';

    static final FRAG_SRC = '
        #ifdef GL_ES
        precision mediump float;
        #endif

        varying vec3 vNormal;
        varying vec3 vFragPos;
        varying vec2 vUV;

        uniform vec3 uColor;
        uniform vec3 uCamPos;
        uniform float uAmbient;
        uniform float uSpecular;
        uniform float uShininess;

        uniform int uNumLights;
        uniform vec3 uLightPos[' + MAX_LIGHTS + '];
        uniform vec3 uLightColor[' + MAX_LIGHTS + '];
        uniform float uLightIntensity[' + MAX_LIGHTS + '];

        void main() {
            vec3 norm    = normalize(vNormal);
            vec3 viewDir = normalize(uCamPos - vFragPos);
            vec3 result  = uAmbient * uColor;

            for (int i = 0; i < ' + MAX_LIGHTS + '; i++) {
                if (i >= uNumLights) break;
                vec3 lightDir = normalize(uLightPos[i] - vFragPos);
                float diff    = max(dot(norm, lightDir), 0.0);
                vec3 halfDir  = normalize(lightDir + viewDir);
                float spec    = pow(max(dot(norm, halfDir), 0.0), uShininess);
                result += (diff * uColor + spec * uSpecular * uLightColor[i])
                          * uLightColor[i] * uLightIntensity[i];
            }

            gl_FragColor = vec4(clamp(result, 0.0, 1.0), 1.0);
        }
    ';
    #end

    public function new() {
        #if (openfl && !flash)
        _program = _compileProgram(VERT_SRC, FRAG_SRC);

        _posLoc    = GL.getAttribLocation(_program, "aPosition");
        _normalLoc = GL.getAttribLocation(_program, "aNormal");
        _uvLoc     = GL.getAttribLocation(_program, "aUV");

        _uMVP       = GL.getUniformLocation(_program, "uMVP");
        _uModel     = GL.getUniformLocation(_program, "uModel");
        _uNormalMat = GL.getUniformLocation(_program, "uNormalMat");
        _uColor     = GL.getUniformLocation(_program, "uColor");
        _uCamPos    = GL.getUniformLocation(_program, "uCamPos");
        _uAmbient   = GL.getUniformLocation(_program, "uAmbient");
        _uSpecular  = GL.getUniformLocation(_program, "uSpecular");
        _uShininess = GL.getUniformLocation(_program, "uShininess");
        _uNumLights = GL.getUniformLocation(_program, "uNumLights");

        _uLightPos       = [for (i in 0...MAX_LIGHTS) GL.getUniformLocation(_program, 'uLightPos[$i]')];
        _uLightColor     = [for (i in 0...MAX_LIGHTS) GL.getUniformLocation(_program, 'uLightColor[$i]')];
        _uLightIntensity = [for (i in 0...MAX_LIGHTS) GL.getUniformLocation(_program, 'uLightIntensity[$i]')];
        #end
    }

    public function render(scene:F3DScene, camera:F3DCamera, viewportW:Int, viewportH:Int):Void {
        #if (openfl && !flash)
        GL.viewport(0, 0, viewportW, viewportH);
        GL.clearColor(scene.bgR, scene.bgG, scene.bgB, scene.bgA);
        GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
        GL.enable(GL.DEPTH_TEST);
        GL.depthFunc(GL.LEQUAL);
        GL.enable(GL.CULL_FACE);
        GL.cullFace(GL.BACK);

        GL.useProgram(_program);

        var view = camera.getViewMatrix();
        var proj = camera.getProjectionMatrix();

        // Upload lights
        var activeLights = 0;
        for (light in scene.lights) {
            if (!light.enabled || activeLights >= MAX_LIGHTS) continue;
            GL.uniform3f(_uLightPos[activeLights],       light.position.x, light.position.y, light.position.z);
            GL.uniform3f(_uLightColor[activeLights],     light.color.x,    light.color.y,    light.color.z);
            GL.uniform1f(_uLightIntensity[activeLights], light.intensity);
            activeLights++;
        }
        GL.uniform1i(_uNumLights, activeLights);
        GL.uniform3f(_uCamPos, camera.position.x, camera.position.y, camera.position.z);

        for (obj in scene.objects) {
            if (!obj.visible || obj.mesh == null) continue;

            var model = obj.getModelMatrix();
            var mvp   = proj.multiply(view).multiply(model);
            var mat   = obj.material;

            GL.uniformMatrix4fv(_uMVP,       false, new Float32Array(mvp.m));
            GL.uniformMatrix4fv(_uModel,     false, new Float32Array(model.m));
            GL.uniformMatrix3fv(_uNormalMat, false, new Float32Array(model.normalMatrix()));

            GL.uniform3f(_uColor,    mat.color.x,  mat.color.y,  mat.color.z);
            GL.uniform1f(_uAmbient,  mat.ambient);
            GL.uniform1f(_uSpecular, mat.specular);
            GL.uniform1f(_uShininess, mat.shininess);

            obj.mesh.bind(_posLoc, _normalLoc, _uvLoc);
            GL.drawElements(GL.TRIANGLES, obj.mesh.indexCount, GL.UNSIGNED_SHORT, 0);
            obj.mesh.unbind(_posLoc, _normalLoc, _uvLoc);
        }

        GL.useProgram(null);
        #end
    }

    public function destroy():Void {
        #if (openfl && !flash)
        if (_program != null) GL.deleteProgram(_program);
        _program = null;
        #end
    }

    #if (openfl && !flash)
    private function _compileProgram(vertSrc:String, fragSrc:String):GLProgram {
        var vert = _compileShader(GL.VERTEX_SHADER, vertSrc);
        var frag = _compileShader(GL.FRAGMENT_SHADER, fragSrc);

        var prog = GL.createProgram();
        GL.attachShader(prog, vert);
        GL.attachShader(prog, frag);
        GL.linkProgram(prog);

        GL.deleteShader(vert);
        GL.deleteShader(frag);

        if (GL.getProgramParameter(prog, GL.LINK_STATUS) == 0)
            throw 'flixel-3d: Shader link failed — ' + GL.getProgramInfoLog(prog);

        return prog;
    }

    private function _compileShader(type:Int, src:String):GLShader {
        var shader = GL.createShader(type);
        GL.shaderSource(shader, src);
        GL.compileShader(shader);

        if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
            throw 'flixel-3d: Shader compile failed — ' + GL.getShaderInfoLog(shader);

        return shader;
    }
    #end
}
