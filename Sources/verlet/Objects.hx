package verlet;
import verlet.Constraint.DistanceConstraint;
import verlet.Verlet;
import kha.math.Vector2;

class Point {
	public var composite(default, null):Composite;
	
	public function new(pos:Vector2) {
		composite = new Composite();
		composite.particles.push(new Particle(pos));
		Verlet._instance.composites.push(composite);
	}
}

class LineSegments {
	public var composite(default, null):Composite;

	public function new(vertices:Array<Vector2>, stiffness:Float, pinSegments:Array<Int>) {
		composite = new Composite();
		for (i in 0...vertices.length) {
			var p = new Particle(vertices[i]);
			composite.particles.push(p);
			if (i > 0) {
				composite.constraints.push(new DistanceConstraint(composite.particles[i], composite.particles[i - 1], stiffness));
			}
			if (pinSegments.indexOf(i) != -1) {
				composite.Pin(p, vertices[i]);
			}
		}
	}
}

class Cloth {
	public var composite(default, null):Composite;

	public function new(origin:Vector2, width:Float, height:Float, segments:Int, pinMod:Int, stiffness:Float) {
		composite = new Composite();
		var xStride = width / segments;
		var yStride = height / segments;
		
		for (y in 0...segments) {
			for (x in 0...segments) {
				var px = origin.x + x * xStride - width / 2 + xStride / 2;
				var py = origin.y + y * yStride - height / 2 + yStride / 2;
				composite.particles.push(new Particle(new Vector2(px, py)));
				
				if (x > 0)
					composite.constraints.push(new DistanceConstraint(composite.particles[y * segments + x], composite.particles[y * segments + x - 1], stiffness));
				
				if (y > 0)
					composite.constraints.push(new DistanceConstraint(composite.particles[y * segments + x], composite.particles[(y - 1) * segments + x], stiffness));
			}
		}
		
		for (x in 0...segments) {
			if (x % pinMod == 0)
				composite.Pin(composite.particles[x], composite.particles[x].pos);
		}
	}
}

class Tire {
	public var composite(default, null):Composite;
	
	public function new(origin:Vector2, radius:Float, segments:Int, ?spokeStiffness:Float = 1, ?treadStiffness:Float = 1) {
		composite = new Composite();
		var stride = 2 * Math.PI / segments;
		
		// particles
		for (i in 0...segments) {
			var theta = i * stride;
			composite.particles.push(new Particle(new Vector2(origin.x + Math.cos(theta) * radius, origin.y + Math.sin(theta) * radius)));
		}
		
		var center = new Particle(origin);
		composite.particles.push(center);
		
		// constraints
		for (i in 0...segments) {
			composite.constraints.push(new DistanceConstraint(composite.particles[i], composite.particles[(i + 1) % segments], treadStiffness));
			composite.constraints.push(new DistanceConstraint(composite.particles[i], center, spokeStiffness));
			composite.constraints.push(new DistanceConstraint(composite.particles[i], composite.particles[(i + 5) % segments], treadStiffness));
		}
	}
}