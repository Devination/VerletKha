package verlet.collision;

import verlet.Verlet.Composite;
import verlet.collision.Colliders.Collider;

class Collision {	
	public var colliders:Array<Collider> = new Array<Collider>();
	
	public static var _instance(get, null):Collision = null;
	private static function get__instance():Collision {
		if (_instance == null) {
			new Collision();
		}
		return _instance;
	}
	
	public function new() {
		_instance = this;
	}
	
	public function checkCollision(c:Composite) {
		for (s in colliders) {
			s.checkParticleCollision(c.particles);
		}
	}
}