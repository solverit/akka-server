package {

import away3d.containers.*;
import away3d.controllers.*;
import away3d.core.math.MathConsts;
import away3d.debug.*;
import away3d.entities.*;
import away3d.lights.*;
import away3d.materials.*;
import away3d.materials.lightpickers.*;
import away3d.materials.methods.*;
import away3d.primitives.*;
import away3d.utils.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.ui.Keyboard;
import flash.utils.*;

[SWF(backgroundColor="#000000", frameRate="60", width="1280", height="800")]
public class Main extends Sprite {

    public var net: NetService = new NetService();

    //ground texture
    [Embed(source="/../embeds/arid.jpg")]
    public static var SandTexture:Class;

    //engine variables
    private var _view:View3D;
    private var _cameraController:HoverController;

    //light objects
    private var _light:DirectionalLight;
    private var _lightPicker:StaticLightPicker;
    private var _direction:Vector3D;

    //material objects
    private var _groundMaterial:TextureMaterial;

    //scene objects
    private var _ground:Mesh;
    private var _player: Tank;

    //navigation variables
    private var _move:Boolean = false;
    private var _lastPanAngle:Number;
    private var _lastTiltAngle:Number;
    private var _lastMouseX:Number;
    private var _lastMouseY:Number;

    //movement variables
    private var drag:Number = 0.5;
    private var walkIncrement:Number = 2;
    private var strafeIncrement:Number = 2;
    private var walkSpeed:Number = 0;
    private var strafeSpeed:Number = 0;
    private var walkAcceleration:Number = 0;
    private var strafeAcceleration:Number = 0;

    public function Main() {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        //setup the view
        _view = new View3D();
        addChild(_view);

        //setup the camera for optimal shadow rendering
        _view.camera.lens.far = 3000;

        //setup the lights for the scene
        _light = new DirectionalLight(-1, -1, 1);
        _direction = new Vector3D(-1, -1, 1);
        _lightPicker = new StaticLightPicker([_light]);
        _view.scene.addChild(_light);

        //setup ground
        _groundMaterial = new TextureMaterial(Cast.bitmapTexture(SandTexture));
        _groundMaterial.shadowMethod = new FilteredShadowMapMethod(_light);
        _groundMaterial.shadowMethod.epsilon = 0.2;
//        _groundMaterial.lightPicker = _lightPicker;
        _groundMaterial.specular = 0;
        _groundMaterial.repeat = true;
        _ground = new Mesh(new PlaneGeometry(1000, 1000), _groundMaterial);
        _ground.geometry.scaleUV(10, 10);
        _view.scene.addChild(_ground);

        //setup player
        _player = new Tank();
        _player.material.shadowMethod = new FilteredShadowMapMethod(_light);
//        _player.material.shadowMethod.epsilon = 0.2;
//        _player.material.lightPicker = _lightPicker;
        _player.material.specular = 0;
        _player.position = new Vector3D(0 , 0, 100);
        _view.scene.addChild(_player);

        //setup controller to be used on the camera
        _cameraController = new HoverController(_view.camera, _player, 45, 20, 100, 10);

        //add stats panel
        addChild(new AwayStats(_view));

        //add listeners
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        stage.addEventListener(Event.RESIZE, onResize);
        onResize();
    }

    /**
     * Key down listener for camera control
     */
    private function onKeyDown(event:KeyboardEvent):void
    {
        switch (event.keyCode) {
            case Keyboard.UP:
            case Keyboard.W:
                walkAcceleration = walkIncrement;
                break;
            case Keyboard.DOWN:
            case Keyboard.S:
                walkAcceleration = -walkIncrement;
                break;
            case Keyboard.LEFT:
            case Keyboard.A:
                strafeAcceleration = -strafeIncrement;
                break;
            case Keyboard.RIGHT:
            case Keyboard.D:
                strafeAcceleration = strafeIncrement;
                break;
        }
    }

    /**
     * Key up listener for camera control
     */
    private function onKeyUp(event:KeyboardEvent):void
    {
        switch (event.keyCode) {
            case Keyboard.UP:
            case Keyboard.W:
            case Keyboard.DOWN:
            case Keyboard.S:
                walkAcceleration = 0;
                break;
            case Keyboard.LEFT:
            case Keyboard.A:
            case Keyboard.RIGHT:
            case Keyboard.D:
                strafeAcceleration = 0;
                break;
            case Keyboard.L:
                net.connect("Tester1", "test");
                break;
        }
    }

    /**
     * Navigation and render loop
     */
    private function onEnterFrame(event:Event):void
    {
        if (_move) {
            _cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
            _cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
        }

        if (walkSpeed || walkAcceleration) {
            walkSpeed = (walkSpeed + walkAcceleration)*drag;
            if (Math.abs(walkSpeed) < 0.01) {
                walkSpeed = 0;
            }
            _player.z -= walkSpeed; //*Math.cos(_cameraController.panAngle*MathConsts.DEGREES_TO_RADIANS);
        }

        if (strafeSpeed || strafeAcceleration) {
            strafeSpeed = (strafeSpeed + strafeAcceleration)*drag;
            if (Math.abs(strafeSpeed) < 0.01) {
                strafeSpeed = 0;
            }
            _player.x -= strafeSpeed; //*Math.sin(_cameraController.panAngle*MathConsts.DEGREES_TO_RADIANS);
        }

        _view.render();
    }

    /**
     * Mouse down listener for navigation
     */
    private function onMouseDown(event:MouseEvent):void
    {
        _lastPanAngle = _cameraController.panAngle;
        _lastTiltAngle = _cameraController.tiltAngle;
        _lastMouseX = stage.mouseX;
        _lastMouseY = stage.mouseY;
        _move = true;
        stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
    }

    /**
     * Mouse up listener for navigation
     */
    private function onMouseUp(event:MouseEvent):void
    {
        _move = false;
        stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
    }

    /**
     * Mouse stage leave listener for navigation
     */
    private function onStageMouseLeave(event:Event):void
    {
        _move = false;
        stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
    }

    /**
     * stage listener for resize events
     */
    private function onResize(event:Event = null):void
    {
        _view.width = stage.stageWidth;
        _view.height = stage.stageHeight;
    }
}
}
