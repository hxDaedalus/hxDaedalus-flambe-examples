package;
import Layer;
import hxDaedalus.data.math.Point2D;

typedef Portal = {
	p1: Point2D,
	p2: Point2D
}
class Interconnect{
	
	private var portals: Array<Portal>;
	private var layer1: Layer;
	private var layer2: Layer;
	
	public var choosenPortal: Portal;
	public var portalIndex: Int;
	public var firstLayer: Layer;
	public var secondLayer: Layer;
	
	public function new( layer1_: Layer, layer2_: Layer, portals_: Array<Portal> ){
		layer1 = layer1_;
		layer2 = layer2_;
		portals = portals_;
	}
	
	public function clear(){
		layer1.clear();
		layer2.clear();
	}
	
	public function findPaths( start: Point2D, end: Point2D, first: Layer ):Void {
		var second: Layer;
		var forward: Bool;
		if( first == layer1 ){
			second = layer2;
			forward = true;
		} else if( first == layer2 ){
			second = layer1;
			forward = false;
		} else { 
			return;
		}
		
		onFirst = true;
		firstLayer = first;
		secondLayer = second;
		var firstTemp = [];
		var secondTemp = [];
		var portal: Portal;
		var choosenI: Int = 0;
		
		var p1: Point2D;
		var p2: Point2D;
		
		for ( i in 0...portals.length )
		{			
			
			portal = portals[ i ];
				
			if( forward ){
				p1 = portal.p1;
				p2 = portal.p2;
			} else {
				p1 = portal.p2;
				p2 = portal.p1;
 			}
			
		
			firstTemp = [];
			secondTemp = [];
			
			// reset the path sampler to manage new generated path
			first.samplerReset();
			second.samplerReset();
			
			first.entityPosition( start.x, start.y );
			
			// check path for each portal
			first.findPath( p1.x, p1.y, firstTemp );
			second.entityPosition( p2.x, p2.y );
			second.findPath( end.x, end.y, secondTemp );			
			if ( i == 0 )
			{
				choosenI = 0;
				first.path = firstTemp.slice( 0 );
				second.path = secondTemp.slice( 0 );
			}
			else if( (firstTemp.length + secondTemp.length) < ( first.path.length + second.path.length) )
			{
				// select shortest overall portal
				choosenI = i;
				first.path = firstTemp.slice( 0 );
				second.path = secondTemp.slice( 0 );
			}
		}
		
		choosenPortal = portals[choosenI];
		if( forward ){
			p1 = choosenPortal.p1;
			p2 = choosenPortal.p2;
		} else {
			p1 = choosenPortal.p2;
			p2 = choosenPortal.p1;
		}
		portalIndex = choosenI;	
		first.samplerReset();
		second.samplerReset();
		trace( start.x+','+start.y+' | '+p1.x+','+p1.y+' | '+p2.x+','+p2.y+' | '+end.x+','+end.y );
		first.sampledPathReInit();
		second.sampledPathReInit();
		first.entityPosition( start.x, start.y );
		first.drawEntityFalse();
		first.entitySecondPosition( p1.x, p1.y );
		first.findPath( p1.x, p1.y, first.path );
		second.entityPosition( p2.x, p2.y );
		second.drawEntityFalse();
		second.entitySecondPosition( end.x, end.y );
		second.findPath( end.x, end.y, second.path );	
	}
	
	public var onFirst: Bool = true;
	
	public function hasNext():Bool {
		if( firstLayer == null ) return false;
		var l = firstLayer.hasNext();
		var u = secondLayer.hasNext();
		onFirst = l; 
		return ( l || u );
	}
	
	public function resetSamplePath():Void {
		firstLayer.sampledPathReInit();
		secondLayer.sampledPathReInit();
		firstLayer.path = null;
		secondLayer.path = null;	
	}
	
	public function hasFirstNext():Bool {
		return firstLayer.hasNext();
	}
	
	public function hasSecondNext():Bool {
		return secondLayer.hasNext();
	}
	
	public function next(){
		if( firstLayer.hasNext() ){
			firstLayer.next();
		}
		else
		{
			secondLayer.next();
		}
	}
	
}