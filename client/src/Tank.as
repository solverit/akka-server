package
{
import away3d.containers.ObjectContainer3D;
import away3d.entities.Mesh;
import away3d.materials.ColorMaterial;
import away3d.materials.TextureMaterial;
import away3d.primitives.CubeGeometry;
import away3d.utils.Cast;

import flash.geom.Vector3D;

public class Tank extends ObjectContainer3D
{
    [Embed(source="/../embeds/metall.jpg")]
    public static var textureGun: Class;

    public var material : TextureMaterial;

    public var pid: Number;

    public function Tank()
    {
        material = new TextureMaterial(Cast.bitmapTexture(textureGun));
        var body: Mesh = new Mesh(new CubeGeometry(10, 4, 15), material);
        var head: Mesh = new Mesh(new CubeGeometry(8, 3, 8), material);
        var gun: Mesh = new Mesh(new CubeGeometry(2, 2, 10), material);
        body.position = new Vector3D(0, 2, 0);
        head.position = new Vector3D(0, 6, 2);
        gun.position = new Vector3D(0, 0.5, -8);
        head.addChild(gun);

        addChild(body);
        addChild(head);
    }
}
}
