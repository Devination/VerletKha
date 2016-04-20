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

class Box extends Shape {
	public var width:Float;
	public var height:Float;
	public function new(pos:Vector2, width:Float, height:Float) { super();
		this.pos = pos;
		this.width = width;
		this.height = height;
	}
	
	public override function checkParticleCollision(particles:Array<Particle>):Void {
		for (p in particles) {
			
			// check if inside box
			if (p.pos.x > pos.x && p.pos.x < pos.x + width && // overlap x
				p.pos.y > pos.y && p.pos.y < pos.y + height) { // overlap y
				
				// find shortest distance to edge
				var distances:Array<Float> = [
					pos.x - p.pos.x, // to left
					pos.x - p.pos.x + width, // to right
					pos.y - p.pos.y, // to top
					pos.y - p.pos.y + height// to bottom
				];
				var shortest:Int = 0;
				for (i in 0...4) {
					if (Math.abs(distances[i]) < Math.abs(distances[shortest]))
						shortest = i;
				}
				// push towards that edge
				if(shortest < 2)
					p.pos.x += distances[shortest];
				else
					p.pos.y += distances[shortest];
			}
		}
	}
}