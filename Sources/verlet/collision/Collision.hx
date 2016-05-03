package verlet.collision;

import verlet.Verlet.Particle;
//TODO: Make it easy to plug in other frameworks (Kha, OpenFL, etc)
import kha.math.Vector2;
import verlet.Verlet.IPlaceable;
import verlet.Verlet.Composite;
import verlet.collision.Shapes.Shape;

class Collision {
	var world:Verlet = Verlet.Instance;
	
	public var shapes:Array<Shape> = new Array<Shape>();
	
	public static var Instance(get, null):Collision = null;
	private static function get_Instance():Collision {
		if (Instance == null) {
			new Collision();
		}
		return Instance;
	}
	
	public function new() {
		Instance = this;
	}
	
	public function checkCollision(c:Composite) {
		for (s in shapes) {
			s.checkParticleCollision(c.particles);
		}
	}
}