package {

import away3d.containers.*;
import away3d.controllers.*;
import away3d.debug.*;
import away3d.entities.*;
import away3d.events.*;
import away3d.library.assets.*;
import away3d.lights.*;
import away3d.loaders.*;
import away3d.loaders.misc.*;
import away3d.loaders.parsers.*;
import away3d.materials.*;
import away3d.materials.lightpickers.*;
import away3d.materials.methods.*;
import away3d.primitives.*;
import away3d.utils.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;

[SWF(backgroundColor="#000000", frameRate="30", quality="LOW")]

public class Main extends Sprite {

    //solider ant texture
    [Embed(source="/../embeds/soldier_ant.jpg")]
    public static var AntTexture:Class;

    //solider ant model
    [Embed(source="/../embeds/soldier_ant.3ds",mimeType="application/octet-stream")]
    public static var AntModel:Class;

    //ground texture
    [Embed(source="/../embeds/arid.jpg")]
    public static var SandTexture:Class;

    //engine variables
    private var _view:View3D;
    private var _cameraController:HoverController;

    //signature variables
    private var _signature:Sprite;
    private var _signatureBitmap:Bitmap;

    //light objects
    private var _light:DirectionalLight;
    private var _lightPicker:StaticLightPicker;
    private var _direction:Vector3D;

    //material objects
    private var _groundMaterial:TextureMaterial;

    //scene objects
    private var _loader:Loader3D;
    private var _ground:Mesh;

    //navigation variables
    private var _move:Boolean = false;
    private var _lastPanAngle:Number;
    private var _lastTiltAngle:Number;
    private var _lastMouseX:Number;
    private var _lastMouseY:Number;

    public function Main() {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        //setup the view
        _view = new View3D();
        _view.addSourceURL("srcview/index.html");
        addChild(_view);

        //setup the camera for optimal shadow rendering
        _view.camera.lens.far = 2100;

        //setup controller to be used on the camera
        _cameraController = new HoverController(_view.camera, null, 45, 20, 1000, 10);

        //setup the lights for the scene
        _light = new DirectionalLight(-1, -1, 1);
        _direction = new Vector3D(-1, -1, 1);
        _lightPicker = new StaticLightPicker([_light]);
        _view.scene.addChild(_light);

        //setup the url map for textures in the 3ds file
        var assetLoaderContext:AssetLoaderContext = new AssetLoaderContext();
        assetLoaderContext.mapUrlToData("texture.jpg", new AntTexture());

        //setup materials
        _groundMaterial = new TextureMaterial(Cast.bitmapTexture(SandTexture));
        _groundMaterial.shadowMethod = new FilteredShadowMapMethod(_light);
        _groundMaterial.shadowMethod.epsilon = 0.2;
        _groundMaterial.lightPicker = _lightPicker;
        _groundMaterial.specular = 0;
        _ground = new Mesh(new PlaneGeometry(1000, 1000), _groundMaterial);
        _view.scene.addChild(_ground);

        //setup the scene
        _loader = new Loader3D();
        _loader.scale(300);
        _loader.z = -200;
        _loader.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
        _loader.loadData(new AntModel(), assetLoaderContext, null, new Max3DSParser(false));
        _view.scene.addChild(_loader);

        //add stats panel
        addChild(new AwayStats(_view));

        //add listeners
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(Event.RESIZE, onResize);
        onResize();
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

        _direction.x = -Math.sin(getTimer()/4000);
        _direction.z = -Math.cos(getTimer()/4000);
        _light.direction = _direction;

        _view.render();
    }

    /**
     * Listener function for asset complete event on loader
     */
    private function onAssetComplete(event:AssetEvent):void
    {
        if (event.asset.assetType == AssetType.MESH) {
            var mesh:Mesh = event.asset as Mesh;
            mesh.castsShadows = true;
        } else if (event.asset.assetType == AssetType.MATERIAL) {
            var material:TextureMaterial = event.asset as TextureMaterial;
            material.shadowMethod = new FilteredShadowMapMethod(_light);
            material.lightPicker = _lightPicker;
            material.gloss = 30;
            material.specular = 1;
            material.ambientColor = 0x303040;
            material.ambient = 1;
        }
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
        _signatureBitmap.y = stage.stageHeight - _signature.height;
    }
}
}
