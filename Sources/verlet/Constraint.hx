package verlet;
import verlet.Verlet.Particle;
import verlet.Verlet.IPlaceable;
import kha.math.Vector2;
using verlet.Vector2Extensions;

class Constraint {
	public var active:Bool = true;

	public function new() {}
	
	// different Constraints have different relax algorithms
	public function relax(stepCoef:Float) {}
	
	public function getConstraintPositions():Array<Vector2> {
		var zero = new Vector2(0,0);
		return [zero, zero];
	}
}

class DistanceConstraint extends Constraint {
    public var a:Particle;
    public var b:Particle;
    public var stiffness:Float;
    public var distance:Float = 0;

    public function new(a:Particle, b:Particle, stiffness:Float, ?distance:Float) { super();
		if (a == b){
            trace("Can't constrain a particle to itself!");
            return;
        }

        this.a = a;
        this.b = b;
        this.stiffness = stiffness;
		if (distance != null)
			this.distance = distance;
		else
			this.distance = a.pos.sub(b.pos).length;
    }
	
	public override function relax(stepCoef:Float) {
		var normal = a.pos.sub(b.pos);
        var m = normal.length2();
        normal = normal.mult(((distance * distance - m) / m) * stiffness * stepCoef);
        a.pos = a.pos.add(normal);
        b.pos = b.pos.sub(normal);
	}
	
	public override function getConstraintPositions():Array<Vector2> {
		return [a.pos, b.pos];
	}
}

class PinConstraint extends Constraint implements IPlaceable {
	public var a:Particle;
	public var pos:Vector2;
	
	public function new(a:Particle, ?pos:Vector2) { super();
		this.a = a;
		if (pos == null)
			this.pos = pos;
		else{
			this.pos = pos;
			a.pos = pos;
		}
	}
	
	public override function relax(stepCoef:Float) {
		a.pos = pos;
	}
	
	public override function getConstraintPositions():Array<Vector2> {
		return [a.pos, pos];
	}
}

class AngleConstraint extends Constraint {
	public var a:Vector2;
	public var b:Vector2;
	public var c:Vector2;
    public var angle:Float;
    public var stiffness:Float;
	
	public function new(a:Vector2, b:Vector2, c:Vector2, stiffness:Float) { super();
		this.a = a;
        this.b = b;
        this.c = c;
        this.stiffness = stiffness;
		angle = b.angle2(a, c);
	}
	
	public override function relax(stepCoef:Float) {
		var angleBetween = b.angle2(a, c);
		var diff = angleBetween - angle;
		
		if (diff <= -Math.PI)
			diff += 2 * Math.PI;
		else if (diff >= Math.PI)
			diff -= 2 * Math.PI;
		
		diff *= stepCoef * stiffness;
		
		a = a.rotate(b, diff);
		c = c.rotate(b, -diff);
		b = b.rotate(a, diff);
		b = b.rotate(c, -diff);
	}
	
	public override function getConstraintPositions():Array<Vector2> {
		return [a, b, c];
	}
}