package verlet.collision;

import kha.graphics2.Graphics;
import verlet.Renderer.IRenderable;
import kha.Color;
using kha.graphics2.GraphicsExtension;

import verlet.Verlet.Particle;
import verlet.Verlet.IPlaceable;
import kha.math.Vector2;
using verlet.Vector2Extensions;

class Collider implements IPlaceable implements IRenderable {
	public var colliderColor:Color = Color.fromBytes(67, 62, 54);
	public var pos:Vector2;
	var coll = Collision.Instance;
	
	public function new() {
		coll.colliders.push(this);
	}
	
	public function checkParticleCollision(particles:Array<Particle>):Void {}
	public function render(graphics : Graphics):Void {}
}

class Circle extends Collider {
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
	
	public override function render(graphics : Graphics):Void {
		graphics.color = colliderColor;
		graphics.drawCircle(pos.x, pos.y, radius);
	}
}

class Box extends Collider {
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
	
	public override function render(graphics : Graphics):Void {
		graphics.color = colliderColor;
		graphics.drawRect(pos.x, pos.y, width, height);
	}
}