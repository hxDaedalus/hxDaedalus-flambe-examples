
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.System;

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
		super();
		
        // Add a solid color background, and ourself so we can override onUpdate()
        var background = System.root.addChild(new Entity()
			.add(new FillSprite(0xffffff, System.stage.width, System.stage.height).setXY(0, 0))
			.add(this));
		
		
        // build a rectangular 2 polygons mesh of 600x400
        _mesh = RectMesh.buildRectangle(600, 400);
        
		
        // create a viewport
		var g = new GraphicsComponent();
		_view = new SimpleView(g);
		background.addChild(new Entity().add(g));
        
        
        // SINGLE VERTEX INSERTION / DELETION
        // insert a vertex in mesh at coordinates (550, 50)
        var vertex : Vertex = _mesh.insertVertex(550, 50);
        // if you want to delete that vertex :
        //_mesh.deleteVertex(vertex);
        
        
        // SINGLE CONSTRAINT SEGMENT INSERTION / DELETION
        // insert a segment in mesh with end points (70, 300) and (530, 320)
        var segment : ConstraintSegment = _mesh.insertConstraintSegment(70, 300, 530, 320);
        // if you want to delete that edge
        //_mesh.deleteConstraintSegment(segment);
        
        
        // CONSTRAINT SHAPE INSERTION / DELETION
        // insert a shape in mesh (a crossed square)
        var shape = _mesh.insertConstraintShape( [   
                        50., 50., 100., 50.,        /* 1st segment with end points (50, 50) and (100, 50)       */
                        100., 50., 100., 100.,      /* 2nd segment with end points (100, 50) and (100, 100)     */
                        100., 100., 50., 100.,      /* 3rd segment with end points (100, 100) and (50, 100)     */
                        50., 100., 50., 50.,        /* 4rd segment with end points (50, 100) and (50, 50)       */
                        20., 50., 130., 100.        /* 5rd segment with end points (20, 50) and (130, 100)      */
                                                ] );      
        // if you want to delete that shape
        //_mesh.deleteConstraintShape(shape);
        
        
        // OBJECT INSERTION / TRANSFORMATION / DELETION
        // insert an object in mesh (a cross)
        var objectCoords : Array<Float> = new Array<Float>();

        _object = new Object();
        _object.coordinates = [ -50.,   0.,  50., 0.,
                                  0., -50.,   0., 50.,
                                -30., -30.,  30., 30.,
                                 30., -30., -30., 30.
                                ];
        _mesh.insertObject( _object );  // insert after coordinates are setted  
        // you can transform objects with x, y, rotation, scaleX, scaleY, pivotX, pivotY
        _object.x = 400;
        _object.y = 200;
        _object.scaleX = 2;
        _object.scaleY = 2;
        // if you want to delete that object
        //_mesh.deleteObject(_object);
		
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		// objects can be transformed at any time
		_object.rotation += 0.05;

		_mesh.updateObjects();  // don't forget to update  

		// render mesh
		_view.drawMesh(_mesh, true);
	}
}