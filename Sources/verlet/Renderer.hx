package verlet;

//TODO: Make it easy to plug in other frameworks (Kha, OpenFL, etc)
import kha.Color;
import kha.graphics2.Graphics;
import verlet.collision.Collision;

#if !noDragger
using kha.graphics2.GraphicsExtension;
import verlet.Verlet.IPlaceable;
#end

class Renderer {
	public static var _instance(get, null):Renderer = null;
	private static function get__instance():Renderer {
		if (_instance == null) {
			new Renderer();
		}
		return _instance;
	}
	
	public function new() {
		_instance = this;
	}
	
	public function renderAll(graphics : Graphics) {
		for (composite in Verlet._instance.composites) {
			composite.render(graphics);
		}
		
		for (collider in Collision._instance.colliders) {
			collider.render(graphics);
		}
		
		// Reset color back to default white
		graphics.color = Color.White;
		
		#if !noDragger
		// Highlight the nearest entity within the selection radius
		var entity:IPlaceable = Dragger._instance.nearestEntity();
		if(entity != null) {
			graphics.drawCircle(entity.pos.x, entity.pos.y, 8);
		}
		#end
	}
}

interface IRenderable {
	public function render(graphics : Graphics):Void;
}