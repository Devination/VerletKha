package verlet;

import kha.math.Vector2;
import verlet.Constraint.PinConstraint;
import verlet.collision.Collision;
import kha.Color;
import kha.graphics2.Graphics;
import verlet.Renderer.IRenderable;
using kha.graphics2.GraphicsExtension;

class Verlet {
	public static var Instance(default, null):Verlet;
	private var collision:Collision = Collision.Instance;
	
	// simulation params
	public var gravity = new Vector2(0, 0.2);
	public var friction:Float = .98;
	
	// holds composite entities
	public var composites:Array<Composite> = new Array<Composite>();
	
	// Bounds of the Verlet World. Entities will stop here
	private var width:Int;
	private var height:Int;
	private var ceiling:Bool;
	
	#if !noDragger
	// Handle Dragging
	var dragger:Dragger;
	#end

	public function new(width:Int, height:Int, ?ceiling:Bool = false) {
		this.width = width;
		this.height = height;
		this.ceiling = ceiling;
		Instance = this;
		#if !noDragger
		dragger = Dragger.Instance;
		#end
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
				else if (ceiling && p.pos.y < 0)
					p.pos.y = 0;
				
				if (p.pos.x < 0)
					p.pos.x = 0;
				else if (p.pos.x > this.width)
					p.pos.x = this.width;
				
				collision.checkCollision(c);
			}
			
			// relax constraints
			var stepCoef:Float = 1 / step;
			for (i in 0...step) {
				for (con in c.constraints) {
					con.relax(stepCoef);
				}
			}
		}
		#if !noDragger
		// handle dragging of entities
		if (dragger.draggedEntity != null)
			dragger.draggedEntity.pos = dragger.mouse;
		#end
	}
}

class Composite implements IRenderable{
	public var particles:Array<Particle>;
	public var constraints:Array<Constraint>;
	
	// Rendering vars
	public var particleColor:Color = Color.fromBytes(220, 52, 94);
	public var constraintColor:Color = Color.fromBytes(67, 62, 54);
	public var drawParticles:Bool = true;
	public var drawConstraints:Bool = true;
	public var drawPolygon:Bool = false;
	public var drawOutline:Bool = false;
	public var verts(get, null):Array<Vector2>; //TODO: There's probably a better way to get these values
	public function get_verts() {
		return particles.map(function(p) { return p.pos; });
	}

	public function new() {
		particles = new Array<Particle>();
		constraints = new Array<Constraint>();
		verts = new Array<Vector2>();
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
	
	public function render(graphics : Graphics) {
		// Commented out pending Push to Kha
		// Fill polygons
		// if (drawPolygon) {
		// 	graphics.color = particleColor;
		// 	var verts:Array<Vector2> = composite.verts;
		// 	var centerVert = verts.pop();
		// 	graphics.fillPolygon(centerVert.x, centerVert.y, verts);
		// }
		
		// Draw lines for constraints
		if (drawConstraints) {
			graphics.color = constraintColor;
			for (c in constraints) {
				var points:Array<Vector2> = c.getConstraintPositions();
				//TODO: Deal with Angle Constraints
				graphics.drawLine(points[0].x, points[0].y, points[1].x, points[1].y);
			}
		}
		
		// Draw dots for the particles
		if (drawParticles) {
			graphics.color = particleColor;
			for (p in particles) {
				graphics.fillCircle(p.pos.x, p.pos.y, 2.5);
			}
		}
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
