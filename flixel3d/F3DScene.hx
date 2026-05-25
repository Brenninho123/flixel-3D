package flixel3d;

/**
 * Scene graph: holds all F3DObjects and F3DLights to be rendered.
 */
class F3DScene {
    public var objects:Array<F3DObject>;
    public var lights:Array<F3DLight>;

    /** Clear color (RGBA 0–1). Default: dark gray. */
    public var bgR:Float = 0.12;
    public var bgG:Float = 0.12;
    public var bgB:Float = 0.14;
    public var bgA:Float = 1.0;

    public function new() {
        objects = [];
        lights  = [F3DLight.point(5, 10, 5)];
    }

    public function add(obj:F3DObject):F3DObject {
        objects.push(obj);
        return obj;
    }

    public function remove(obj:F3DObject):Void {
        objects.remove(obj);
    }

    public function addLight(light:F3DLight):F3DLight {
        lights.push(light);
        return light;
    }

    /** Find first object with matching name. */
    public function getByName(name:String):F3DObject {
        for (o in objects) if (o.name == name) return o;
        return null;
    }

    public function update(elapsed:Float):Void {
        for (obj in objects) obj.update(elapsed);
    }

    public function setBackground(r:Float, g:Float, b:Float, a:Float = 1.0):Void {
        bgR = r; bgG = g; bgB = b; bgA = a;
    }

    /** Convenience: set background from a HaxeFlixel hex color (0xRRGGBB or 0xAARRGGBB). */
    public function setBgHex(hex:Int):Void {
        bgA = ((hex >> 24) & 0xFF) / 255.0;
        bgR = ((hex >> 16) & 0xFF) / 255.0;
        bgG = ((hex >> 8)  & 0xFF) / 255.0;
        bgB = (hex & 0xFF) / 255.0;
        if (bgA == 0) bgA = 1.0;
    }

    public function destroy():Void {
        for (obj in objects) obj.destroy();
        objects = [];
        lights  = [];
    }
}
