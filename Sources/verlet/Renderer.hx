package verlet;

//TODO: Make it easy to plug in other frameworks (Kha, OpenFL, etc)
import kha.Color;
import kha.graphics2.Graphics;
import verlet.collision.Collision;

#if !noDragger
import verlet.Verlet.IPlaceable;
#end

class Renderer {
	var world:Verlet = Verlet.Instance;
	var collision:Collision = Collision.Instance;
	#if !noDragger
	var dragger:Dragger = Dragger.Instance;
	#end

	public static var Instance(get, null):Renderer = null;
	private static function get_Instance():Renderer {
		if (Instance == null) {
			new Renderer();
		}
		return Instance;
	}
	
	public function new() {
		Instance = this;
	}
	
	public function renderAll(graphics : Graphics) {
		for (composite in world.composites) {
			composite.render(graphics);
		}
		
		for (collider in collision.colliders) {
			collider.render(graphics);
		}
		
		// Reset color back to default white
		graphics.color = Color.White;
		
		#if !noDragger
		// Highlight the nearest entity within the selection radius
		var entity:IPlaceable = dragger.nearestEntity();
		if(entity != null) {
			graphics.drawCircle(entity.pos.x, entity.pos.y, 8);
		}
		#end
	}
}

interface IRenderable {
	public function render(graphics : Graphics):Void;
}