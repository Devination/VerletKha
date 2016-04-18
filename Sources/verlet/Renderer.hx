package verlet;

import verlet.Verlet.Particle;
//TODO: Make it easy to plug in other frameworks (Kha, OpenFL, etc)
import kha.math.Vector2;
import kha.Color;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;

class Renderer {
	var world:Verlet = Verlet.Instance;
	var dragger:Dragger = Dragger.Instance;
	
	public var particleColor:Color = Color.fromBytes(220, 52, 94);
	public var constraintColor:Color = Color.fromBytes(67, 62, 54);
	
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
	
	public function render(graphics : Graphics) {
		for (composite in world.composites) {
			// Draw lines for constraints
			graphics.color = constraintColor;
			for (c in composite.constraints) {
				var points:Array<Vector2> = c.getConstraintPositions();
				//TODO: Deal with Angle Constraints
				graphics.drawLine(points[0].x, points[0].y, points[1].x, points[1].y);
			}
			
			// Draw dots for the particles
			graphics.color = particleColor;
			for (p in composite.particles) {
				graphics.fillCircle(p.pos.x, p.pos.y, 2.5);
			}
		}
		
		// Reset color back to default white
		graphics.color = Color.White;
		
		// Highlight the nearest entity within the selection radius
		var entity:Particle = dragger.nearestEntity();
		if(entity != null) {
			graphics.drawCircle(entity.pos.x, entity.pos.y, 8);
		}
	}
}