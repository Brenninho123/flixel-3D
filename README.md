# flixel-3d

A 3D rendering extension for HaxeFlixel. Uses OpenGL (via Lime) to render 3D scenes
directly inside any `FlxState`, with 2D HaxeFlixel content composited on top.

## Features
- Phong shading with up to 4 dynamic lights
- Primitives: Cube, Plane, UV Sphere
- Quaternion-based rotation (no gimbal lock)
- Perspective & orthographic cameras with orbit/zoom helpers
- Full normal matrix computation (correct lighting with non-uniform scale)
- Compatible with HaxeFlixel 6.x / Lime 8.x

## Installation

```sh
haxelib dev flixel-3d path/to/flixel-3d
```

Add to your `Project.xml`:
```xml
<haxelib name="flixel-3d" />
```

## Quick Start

```haxe
import flixel3d.F3DState;
import flixel3d.F3DCamera;
import flixel3d.F3DMaterial;
import flixel3d.primitives.F3DCube;
import flixel3d.primitives.F3DPlane;

class PlayState extends F3DState {
    var cube:F3DCube;

    override function create():Void {
        super.create();

        // Camera setup
        camera3D.position.set(0, 3, 6);
        camera3D.target.set(0, 0, 0);

        // Add a red cube
        cube = new F3DCube(1, F3DMaterial.red());
        cube.position.set(0, 0.5, 0);
        scene.add(cube);

        // Add a gray floor
        var floor = new F3DPlane(10, 4, F3DMaterial.gray());
        scene.add(floor);

        // Adjust light
        scene.lights[0].position.set(3, 8, 4);

        // Background color
        scene.setBackground(0.1, 0.1, 0.15);
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        cube.rotateY(elapsed * 1.2);
    }
}
```

## API Reference

### F3DState
| Property/Method | Description |
|---|---|
| `scene:F3DScene` | The 3D scene graph |
| `camera3D:F3DCamera` | Main perspective camera |

### F3DScene
| Method | Description |
|---|---|
| `add(obj)` | Add a F3DObject to the scene |
| `remove(obj)` | Remove an object |
| `addLight(light)` | Add a F3DLight |
| `setBackground(r,g,b)` | Set GL clear color |

### F3DCamera
| Property/Method | Description |
|---|---|
| `position`, `target`, `up` | Camera transform |
| `fov`, `near`, `far`, `aspect` | Projection params |
| `orbit(yaw, pitch)` | Orbit around target |
| `zoom(delta)` | Dolly toward/away from target |

### F3DObject
| Property/Method | Description |
|---|---|
| `position:F3DVector3` | World position |
| `rotation:F3DQuaternion` | Orientation |
| `scale:F3DVector3` | Non-uniform scale |
| `setEuler(pitch, yaw, roll)` | Set rotation from Euler angles (radians) |
| `rotateX/Y/Z(angle)` | Accumulate rotation |
| `lookAt(target)` | Orient toward a point |
| `update(elapsed)` | Override for per-object logic |

### F3DMaterial presets
`white()` 路 `red()` 路 `green()` 路 `blue()` 路 `yellow()` 路 `gray()` 路 `fromHex(0xRRGGBB)`

### Primitives
- `new F3DCube(size, material)`
- `new F3DPlane(size, segments, material)`
- `new F3DSphere(radius, rings, segments, material)`

## Custom Meshes

```haxe
var verts:Array<Float> = [
    // x,y,z,  nx,ny,nz,  u,v
    -0.5, 0, 0.5,  0,1,0,  0,0,
     0.5, 0, 0.5,  0,1,0,  1,0,
     0.5, 0,-0.5,  0,1,0,  1,1,
    -0.5, 0,-0.5,  0,1,0,  0,1,
];
var idx:Array<Int> = [0,1,2, 0,2,3];
var mesh = new F3DMesh(verts, idx);
var obj  = new F3DObject(mesh, F3DMaterial.blue());
scene.add(obj);
```

## Targets

Supports all non-Flash OpenFL targets: **Windows, Linux, macOS, Android, iOS, HTML5**.
Does nothing (compiles safely) on Flash.
