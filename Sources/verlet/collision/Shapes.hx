package verlet.collision;

import verlet.Verlet.Particle;
import verlet.Verlet.IPlaceable;
import kha.math.Vector2;
using verlet.Vector2Extensions;

class Shape implements IPlaceable {
	public var pos:Vector2;
	var coll = Collision.Instance;
	
	public function new() {
		coll.shapes.push(this);
	}
	
	public function checkParticleCollision(particles:Array<Particle>):Void {}
}

class Circle extends Shape {
	public var radius:Float;
	public function new(pos:Vector2, radius:Float) { super();
		this.pos = pos;
		this.radius = radius;
	}
	
	public override function checkParticleCollision(particles:Array<Particle>):Void {
		for (p in particles) {
			var distance = p.pos.distanceTo(pos);
			if (distance < radius) {
				var overlap:Float = radius - distance;
				var normal:Vector2 = p.pos.vectorTo(pos);
				normal.normalize();
				p.pos = p.pos.add(normal.mult(overlap));
			}
		}
	}
}