package verlet;

import kha.math.Vector2;
import verlet.Constraint.PinConstraint;

class Verlet {
	public static var Instance(get, null):Verlet;
	private static function get_Instance(): Verlet { return Instance; }
	
	// simulation params
	public var gravity = new Vector2(0, 0.2);
	public var friction:Float = .98;
	
	// holds composite entities
	public var composites:Array<Composite> = new Array<Composite>();
	
	// Bounds of the Verlet World. Entities will stop here
	private var width:Float;
	private var height:Float;
	
	// Handle Dragging
	var dragger:Dragger;

	public function new(width:Float, height:Float) {
		this.width = width;
		this.height = height;
		Instance = this;
		dragger = Dragger.Instance;
	}
	
	public function update(step:Int) {
		
		for (c in composites) {
			// particles
			for (p in c.particles) {
				// calculate velocity
				var vel:Vector2 = p.pos.sub(p.lastPos).mult(friction);
				p.lastPos = p.pos;
				p.pos = p.pos.add(gravity).add(vel);
				
				// stop at bounds
				if (p.pos.y > this.height)
					p.pos.y = this.height;
				
				if (p.pos.x < 0)
					p.pos.x = 0;

				if (p.pos.x > this.width)
					p.pos.x = this.width;
			}
			
			// relax constraints
			var stepCoef:Float = 1 / step;
			for (i in 0...step) {
				for (con in c.constraints) {
					con.relax(stepCoef);
				}
			}
		}
		// handle dragging of entities
		if (dragger.draggedEntity != null)
			dragger.draggedEntity.pos = dragger.mouse;
	}
}

class Composite {
	public var particles:Array<Particle>;
	public var constraints:Array<Constraint>;

	public function new() {
		particles = new Array<Particle>();
		constraints = new Array<Constraint>();
	}

	public function Pin(particle:Particle, pos:Vector2):Constraint	{
		var pc = new PinConstraint(particle, pos);
		constraints.push(pc);
		return pc;
	}
	
	@:extern public inline function add(c1:Composite, c2:Composite): Composite	{
		var combined = new Composite();
		combined.particles.concat(c1.particles);
		combined.particles.concat(c2.particles);
		combined.constraints.concat(c1.constraints);
		combined.constraints.concat(c2.constraints);
		return combined;
	}
}

interface IPlaceable {
	public var pos:Vector2;
}

class Particle implements IPlaceable {
	public var pos:Vector2;
	public var lastPos:Vector2;

	public function new(pos:Vector2) {
		this.pos = pos;
		this.lastPos = pos;
	}
}