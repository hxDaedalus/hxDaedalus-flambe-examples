
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.System;
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.graphics.Pixels;

import hxDaedalus.factories.BitmapObject;
import hxDaedalus.data.ConstraintSegment;
import hxDaedalus.data.ConstraintShape;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.Vertex;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.graphics.flambe.GraphicsComponent;
import hxDaedalus.graphics.SimpleDrawingContext;
import hxDaedalus.view.SimpleView;


class Main extends Component
{
	var _inited:Bool = false;
    
	var _mesh:Mesh;
	var _meshView:SimpleView;
	var _pathView:SimpleView;
	var _entityAI:EntityAI;
	var _pathfinder:PathFinder;
	var _path:Array<Float>;
	var _pathSampler:LinearPathSampler;
	var _object:Object;

    var _newPath:Bool = false;
    
    public static function main():Void 
    {
        // Wind up all platform-specific stuff
        System.init();
		
		// Add ourselves so we can listen to update events
		System.root.addChild(new Entity().add(new Main()));
    }
    
    public function new()
    {
		super();
		
		var loader = System.loadAssetPack(Manifest.fromAssets("images"));
		loader.get(onLoaded);
	}
	
	public function onLoaded(pack:AssetPack):Void
	{
		
		// build a rectangular 2 polygons mesh
		_mesh = RectMesh.buildRectangle(1024, 780);
		
		// show the image
		var textureColor = pack.getTexture("galapagosColor");
		var image = new ImageSprite(textureColor);
		System.root.addChild(new Entity().add(image));
		
		// add viewports
		var meshGraphics = new GraphicsComponent();
		_meshView = new SimpleView(meshGraphics);
		System.root.addChild(new Entity().add(meshGraphics));

		var pathGraphics = new GraphicsComponent();
		_pathView = new SimpleView(pathGraphics);
		System.root.addChild(new Entity().add(pathGraphics));

		// create an object from bitmap
		var textureBW = pack.getTexture("galapagosBW");
		_object = BitmapObject.buildFromBmpData(textureBW, 1.8);
		_object.x = 0;
		_object.y = 0;

		_mesh.insertObject(_object);
		
		// display result mesh
		
		// draw the mesh
		_meshView.drawMesh(_mesh);
		
		// we need an entity
		_entityAI = new EntityAI();
		
		// set radius size for your entity
		_entityAI.radius = 4;
		
		// set a position
		_entityAI.x = 50;
		_entityAI.y = 50;
		
		// show entity on screen
		_pathView.drawEntity(_entityAI, false);
		
		// now configure the pathfinder
		_pathfinder = new PathFinder();
		_pathfinder.entity = _entityAI; // set the entity
		_pathfinder.mesh = _mesh; // set the mesh
		
		// we need a vector to store the path
		_path = new Array<Float>();
		
		// then configure the path sampler
		_pathSampler = new LinearPathSampler();
		_pathSampler.entity = _entityAI;
		_pathSampler.samplingDistance = 10;
		_pathSampler.path = _path;
		
		_inited = true;
    }

	override public function onAdded() {
		super.onAdded();
		
		System.pointer.down.connect(onPointerDown);
		System.pointer.up.connect(onPointerUp);
	}
	
	public function onPointerDown(e:PointerEvent):Void {
		_newPath = true;
	}
	
	public function onPointerUp(e:PointerEvent):Void {
		_newPath = false;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (!_inited) return;
		
        if (_newPath) {
			_pathView.graphics.clear();
			
            // find path !
            _pathfinder.findPath(System.pointer.x, System.pointer.y, _path);
            
			// show path on screen
            _pathView.drawPath(_path);
            
			// reset the path sampler to manage new generated path
            _pathSampler.reset();
			
			// show entity position on screen
			_pathView.drawEntity(_entityAI);
        }
        
        // animate !
        if (_pathSampler.hasNext) {
            // move entity
            _pathSampler.next();      
			
			// show entity position on screen
			_pathView.drawEntity(_entityAI);
        }
	}
}
	