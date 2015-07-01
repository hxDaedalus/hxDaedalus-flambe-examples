
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.System;

import hxDaedalus.factories.BitmapObject;
import hxDaedalus.data.ConstraintSegment;
import hxDaedalus.data.ConstraintShape;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.Vertex;
import hxDaedalus.factories.RectMesh;
import wings.core.TargetCanvas;
import wings.core.SimpleDrawingContext;
import hxDaedalus.view.SimpleView;


class Main extends Component
{
    
    var _mesh : Mesh;
    var _view : SimpleView;
    var _object : Object;
    
    public static function main():Void 
    {
        // Wind up all platform-specific stuff
        System.init();

		new Main();
    }
    
    public function new()
    {
		
		var loader = System.loadAssetPack(Manifest.fromAssets("images"));
		loader.get(onLoaded);
	}
	
	public function onLoaded(pack:AssetPack):Void
	{
        // Add a solid color background
        var background = System.root.addChild(new Entity()
			.add(new FillSprite(0xffffff, System.stage.width, System.stage.height).setXY(0, 0)));
		
        // build a rectangular 2 polygons mesh of 600x600
        _mesh = RectMesh.buildRectangle( 600, 600 );
        
        // show the source bmp
		var texture = pack.getTexture("FromBitmap");
		var image = new ImageSprite(texture).setXY(110, 220);
		background.addChild(new Entity().add(image));
        
        // create a viewport
		var g = new TargetCanvas();
		_view = new SimpleView(g);
		background.addChild(new Entity().add(g));
        
        // create an object from bitmap
        _object = BitmapObject.buildFromBmpData(texture);
        _object.x = 110;
        _object.y = 220;
        _mesh.insertObject( _object );
        
        // display result mesh
        _view.drawMesh( _mesh );
    }
}