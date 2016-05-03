package verlet;

import verlet.Verlet.Particle;
//TODO: Make it easy to plug in other frameworks (Kha, OpenFL, etc)
import kha.math.Vector2;
import kha.Color;
import kha.graphics2.Graphics;
import verlet.Verlet.IPlaceable;
import verlet.collision.Collision;
import verlet.collision.Shapes;
import Type.getClass;
using kha.graphics2.GraphicsExtension;

class Renderer {
	var world:Verlet = Verlet.Instance;
	var collision:Collision = Collision.Instance;
	var dragger:Dragger = Dragger.Instance;
	
	public var particleColor:Color = Color.fromBytes(220, 52, 94);
	public var constraintColor:Color = Color.fromBytes(67, 62, 54);
	public var shapeColor:Color = Color.fromBytes(67, 62, 54);
	public var highlightNearest:Bool = true;
	
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
		
		graphics.color = shapeColor;
		for (s in collision.shapes) {
			switch (getClass(s)) {
				case Circle:
				var circle = cast(s, Circle);
				graphics.drawCircle(circle.pos.x, circle.pos.y, circle.radius);
				continue;
				case Box:
				var box = cast(s, Box);
				graphics.drawRect(box.pos.x, box.pos.y, box.width, box.height);
				continue;
			}
		}
		
		// Reset color back to default white
		graphics.color = Color.White;
		
		if (highlightNearest) {
			// Highlight the nearest entity within the selection radius
			var entity:IPlaceable = dragger.nearestEntity();
			if(entity != null) {
				graphics.drawCircle(entity.pos.x, entity.pos.y, 8);
			}
		}
	}
}