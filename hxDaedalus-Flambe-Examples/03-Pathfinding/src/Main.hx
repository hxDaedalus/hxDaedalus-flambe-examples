
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.MouseEvent;
import flambe.input.PointerEvent;
import flambe.System;

import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.math.RandGenerator;
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
    
	var _entityAI : EntityAI;
    var _pathfinder : PathFinder;
    var _path : Array<Float>;
    var _pathSampler : LinearPathSampler;
    
    var _newPath:Bool = false;

    
	public static function main():Void 
    {
        // Wind up all platform-specific stuff
        System.init();
		
		System.root.addChild(new Entity().add(new Main()));
    }
    
    
	public function new()
    {
        
		// Add a solid color background
		var background = System.root.addChild(new Entity()
			.add(new FillSprite(0xffffff, System.stage.width, System.stage.height).setXY(0, 0)));
		
        // build a rectangular 2 polygons mesh of 600x600
        _mesh = RectMesh.buildRectangle(600, 600);
        
        // create a viewport
		var g = new TargetCanvas();
		_view = new SimpleView(g);
		System.root.addChild(new Entity().add(g));
        
		var meshGraphics = new TargetCanvas();
		var meshView = new SimpleView(meshGraphics);
		var meshEntity = new Entity().add(meshGraphics);
		System.root.addChild(meshEntity);
		
        // pseudo random generator
        var randGen : RandGenerator;
        randGen = new RandGenerator();
        randGen.seed = 7259;  // put a 4 digits number here  
        
        // populate mesh with many square objects
        var object : Object;
        var shapeCoords : Array<Float>;
        for (i in 0...50){
            object = new Object();
            shapeCoords = new Array<Float>();
            shapeCoords = [ -1, -1, 1, -1,
                             1, -1, 1, 1,
                            1, 1, -1, 1,
                            -1, 1, -1, -1];
            object.coordinates = shapeCoords;
            randGen.rangeMin = 10;
            randGen.rangeMax = 40;
            object.scaleX = randGen.next();
            object.scaleY = randGen.next();
            randGen.rangeMin = 0;
            randGen.rangeMax = 1000;
            object.rotation = (randGen.next() / 1000) * Math.PI / 2;
            randGen.rangeMin = 50;
            randGen.rangeMax = 600;
            object.x = randGen.next();
            object.y = randGen.next();
            _mesh.insertObject(object);
        }  
		
		// show result mesh on screen  
		meshView.drawMesh(_mesh);
		
        // we need an entity
        _entityAI = new EntityAI();
        // set radius as size for your entity
        _entityAI.radius = 4;
        // set a position
        _entityAI.x = 20;
        _entityAI.y = 20;
        
        // show entity on screen
        _view.drawEntity(_entityAI);
        
        // now configure the pathfinder
        _pathfinder = new PathFinder();
        _pathfinder.entity = _entityAI;  // set the entity  
        _pathfinder.mesh = _mesh;  // set the mesh  
        
        // we need a vector to store the path
        _path = new Array<Float>();
        
        // then configure the path sampler
        _pathSampler = new LinearPathSampler();
        _pathSampler.entity = _entityAI;
        _pathSampler.samplingDistance = 10;
        _pathSampler.path = _path;
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
		
        if ( _newPath ) {
			_view.graphics.clear();
			
            // find path !
            _pathfinder.findPath( System.pointer.x, System.pointer.y, _path );
            
			// show path on screen
            _view.drawPath( _path );
            
			// reset the path sampler to manage new generated path
            _pathSampler.reset();
			
			// show entity position on screen
			_view.drawEntity(_entityAI);
        }
        
        // animate !
        if ( _pathSampler.hasNext ) {
            // move entity
            _pathSampler.next();      
			
			// show entity position on screen
			_view.drawEntity(_entityAI);
        }
	}
}