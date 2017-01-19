package verlet;

import kha.math.Vector2;
import verlet.Constraint.PinConstraint;
import verlet.collision.Collision;
import kha.Color;
import kha.graphics2.Graphics;
import verlet.Renderer.IRenderable;
using kha.graphics2.GraphicsExtension;

class Verlet {
	/**
	 * Reference the _instance directly whenever possible.
	 * Assigning it to another variable can cause issues when swapping out instances.
	 */
	public static var _instance(default, null):Verlet;
	
	// simulation params
	public var gravity = new Vector2(0, 0.2);
	public var friction:Float = .98;
	
	// holds composite entities
	public var composites:Array<Composite> = new Array<Composite>();
	
	// Bounds of the Verlet World. Entities will stop here
	// Bounds will extend from pos right by width and down by height
	private var pos:Vector2;
	private var width:Float;
	private var height:Float;
	private var ceiling:Bool;
	
	public function new(width:Float, height:Float, ?ceiling:Bool=false, ?x:Float=0, ?y:Float=0) {
		pos = new Vector2(x, y);
		this.width = width;
		this.height = height;
		this.ceiling = ceiling;
		_instance = this;
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
				if (p.pos.y > this.height + this.pos.y)
					p.pos.y = this.height + this.pos.y;
				else if (ceiling && p.pos.y < this.pos.y)
					p.pos.y = this.pos.y;
				
				if (p.pos.x < this.pos.x)
					p.pos.x = this.pos.x;
				else if (p.pos.x > this.width + this.pos.x)
					p.pos.x = this.width + this.pos.x;
				
				Collision._instance.checkCollision(c);
			}
			
			// relax constraints
			var stepCoef:Float = 1 / step;
			for (i in 0...step) {
				for (con in c.constraints) {
					if (con.active) {
						con.relax(stepCoef);
					}
				}
			}
		}
		#if !noDragger
		// handle dragging of entities
		if (Dragger._instance.draggedEntity != null)
			Dragger._instance.draggedEntity.pos = Dragger._instance.mouse;
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
				if (c.active) {
					var points:Array<Vector2> = c.getConstraintPositions();
					//TODO: Deal with Angle Constraints
					graphics.drawLine(points[0].x, points[0].y, points[1].x, points[1].y);
				}
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
