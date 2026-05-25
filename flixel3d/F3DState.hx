package flixel3d;

import flixel.FlxG;
import flixel.FlxState;

#if (openfl && !flash)
import openfl.display.OpenGLView;
import openfl.geom.Rectangle;
#end

/**
 * Drop-in replacement for FlxState that adds a 3D layer.
 *
 * Usage:
 *   class MyState extends F3DState {
 *     override function create() {
 *       super.create();
 *       var cube = scene.add(new F3DCube());
 *       camera3D.position.set(0, 2, 5);
 *     }
 *     override function update(elapsed:Float) {
 *       super.update(elapsed); // runs scene.update() + FlxState.update()
 *     }
 *   }
 *
 * The 3D layer renders first (behind all FlxSprites/FlxUI).
 * Set FlxG.cameras.bgColor = FlxColor.TRANSPARENT to see through to 3D.
 */
class F3DState extends FlxState {
    public var scene:F3DScene;
    public var camera3D:F3DCamera;

    #if (openfl && !flash)
    var _glView:OpenGLView;
    var _renderer:F3DRenderer;
    #end

    override function create():Void {
        super.create();

        scene     = new F3DScene();
        camera3D  = new F3DCamera(FlxG.width / FlxG.height);

        #if (openfl && !flash)
        _renderer = new F3DRenderer();
        _glView   = new OpenGLView();
        _glView.render = _onRender;

        // Insert behind FlxGame so 2D HaxeFlixel content renders on top
        FlxG.stage.addChildAt(_glView, 0);

        // Make the Flixel camera transparent so 3D is visible underneath
        FlxG.cameras.bgColor = 0x00000000;
        #end
    }

    override function update(elapsed:Float):Void {
        scene.update(elapsed);
        super.update(elapsed);
    }

    override function destroy():Void {
        #if (openfl && !flash)
        if (_glView != null && FlxG.stage.contains(_glView))
            FlxG.stage.removeChild(_glView);
        _glView = null;

        if (_renderer != null) {
            _renderer.destroy();
            _renderer = null;
        }
        #end

        if (scene != null) {
            scene.destroy();
            scene = null;
        }

        super.destroy();
    }

    #if (openfl && !flash)
    private function _onRender(rect:Rectangle):Void {
        _renderer.render(scene, camera3D, Std.int(rect.width), Std.int(rect.height));
    }
    #end
}
