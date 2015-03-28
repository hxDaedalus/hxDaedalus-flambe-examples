
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
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
import hxDaedalus.graphics.flambe.GraphicsComponent;
import hxDaedalus.graphics.SimpleDrawingContext;
import hxDaedalus.view.SimpleView;


class Main extends Component
{
	var inited:Bool = false;

    var mesh : Mesh;

	var pathView:SimpleView;
	var meshView:SimpleView;
    
    var entityAI : EntityAI;
    var pathfinder : PathFinder;
    var path : Array<Float>;
    var pathSampler : LinearPathSampler;
    
    var newPath:Bool = false;
	
	var rows:Int = 20;
	var cols:Int = 20;
    
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
        
		// Add a solid color background
		var background = System.root.addChild(new Entity()
			.add(new FillSprite(0xffffff, System.stage.width, System.stage.height).setXY(0, 0)));
		
		// add viewports
		var meshGraphics = new GraphicsComponent();
		meshView = new SimpleView(meshGraphics);
		System.root.addChild(new Entity().add(meshGraphics));

		var pathGraphics = new GraphicsComponent();
		pathView = new SimpleView(pathGraphics);
		System.root.addChild(new Entity().add(pathGraphics));
		
		meshView.constraintsWidth = 4;

        entityAI = new EntityAI();
        pathfinder = new PathFinder();
        pathSampler = new LinearPathSampler();
		
		// generate random maze
		resetMaze(true);
		
		inited = true;
	}
	
	override public function onAdded() {
		super.onAdded();
		
		// add event listeners
		System.pointer.down.connect(onPointerDown);
		System.pointer.up.connect(onPointerUp);
		System.keyboard.down.connect(onKeyDown);
	}
	
	public function onPointerDown(e:PointerEvent):Void {
		newPath = true;
	}
	
	public function onPointerUp(e:PointerEvent):Void {
		newPath = false;
	}
	
	public function onKeyDown(e:KeyboardEvent):Void {
		if (e.key == Key.Space) {	// new maze
			resetMaze(true);
		} else if (e.key == Key.Enter) {	// reset entity pos
			resetMaze(false);
		}
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
 		if (!inited) return;
		
        if (newPath) {
			pathView.graphics.clear();
			
            // find path !
            pathfinder.findPath(System.pointer.x, System.pointer.y, path);
            
			// show path on screen
            pathView.drawPath(path);
            
			// reset the path sampler to manage new generated path
            pathSampler.reset();
			
			// show entity position on screen
			pathView.drawEntity(entityAI);
        }
        
        // animate !
        if (pathSampler.hasNext) {
            // move entity
            pathSampler.next();      
			
			// show entity position on screen
			pathView.drawEntity(entityAI);
        }
	}
	
	function resetMaze(newMaze:Bool = false):Void {
		var seed = Std.int(Math.random() * 10000 + 1000);
		
		if (newMaze) {
			// build a rectangular 2 polygons mesh of 600x600
			mesh = RectMesh.buildRectangle(600, 600);
			
			// generate maze
			var tw = Math.ceil(600 / cols);
			var th = Math.ceil(600 / rows);
			GridMaze.generate(600 - tw * 2, 600 - th * 2, cols - 2, rows - 2, seed);
			GridMaze.object.x = GridMaze.tileWidth;
			GridMaze.object.y = GridMaze.tileHeight;
			mesh.insertObject(GridMaze.object);
			
			// show mesh
			meshView.drawMesh(mesh, true);
		}
		
        // reset entity's props
        entityAI.radius = GridMaze.tileWidth * .27;
		entityAI.x = GridMaze.tileWidth / 2;
        entityAI.y = GridMaze.tileHeight / 2;
		
		// configure pathfinder and pathsampler
		pathfinder.entity = entityAI;
		pathfinder.mesh = mesh;
		path = [];
		pathSampler.path = path;
        pathSampler.entity = entityAI;
        pathSampler.samplingDistance = GridMaze.tileWidth * .7;
		
		// show entity on screen
		pathView.drawEntity(entityAI, true);
	}
}