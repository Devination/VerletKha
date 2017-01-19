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
	// Make it a force volume with non-1 strength values.
	// Should be either 1 or super tiny values like 0.0001 
	public var strength:Float = 1; 
	
	public function new() {
		Collision._instance.colliders.push(this);
	}
	
	public function checkParticleCollision(particles:Array<Particle>):Void {}
	public function render(graphics : Graphics):Void {}
	public function isPointInCollider(point:Vector2):Bool {return false;}
}

class Circle extends Collider {
	public var radius:Int;
	public function new(pos:Vector2, radius:Int) { super();
		this.pos = pos;
		this.radius = radius;
	}
	
	public override inline function isPointInCollider(point:Vector2):Bool {
		if (point.distanceTo(pos) < radius) {
			return true;
		}
		else {
			return false;
		}
	}

	public override function checkParticleCollision(particles:Array<Particle>):Void {
		for (p in particles) {
			//Not using isPointInCollider() because we'd have to calculate distance twice if it's a hit
			var distance = p.pos.distanceTo(pos);
			if (distance < radius) {
				var overlap:Float = radius - distance;
				var normal:Vector2 = p.pos.vectorTo(pos);
				normal.normalize();
				p.pos = p.pos.add(normal.mult(overlap * strength));
			}
		}
	}
	
	public override function render(graphics : Graphics):Void {
		graphics.color = colliderColor;
		graphics.drawCircle(pos.x, pos.y, radius);
	}
}

class Box extends Collider {
	public var width:Int;
	public var height:Int;
	public function new(pos:Vector2, width:Int, height:Int) { super();
		this.pos = pos;
		this.width = width;
		this.height = height;
	}
	
	public override inline function isPointInCollider(point:Vector2):Bool {
		if (point.x > pos.x && point.x < pos.x + width && // overlap x
			point.y > pos.y && point.y < pos.y + height) { // overlap y
			return true;
		}
		else {
			return false;
		}
	}

	public override function checkParticleCollision(particles:Array<Particle>):Void {
		for (p in particles) {
			
			// check if inside box
			if (isPointInCollider(p.pos)) { 
				
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
					p.pos.x += distances[shortest] * strength;
				else
					p.pos.y += distances[shortest] * strength;
			}
		}
	}
	
	public override function render(graphics : Graphics):Void {
		graphics.color = colliderColor;
		graphics.drawRect(pos.x, pos.y, width, height);
	}
}

/** Verts must be in local space relative to position.
	Polygon is constructed clockwise with normals facing out
	or counter clockwise for normals facing in */
class Polygon extends Collider {
	public var verts(default, null):Array<Vector2>;
	public var edges(default, null):Array<Edge>;
	public var renderNormals:Bool = false;
	var localBoundsMin:Vector2;
	var localBoundsMax:Vector2;
	
	public function new(pos:Vector2, verts:Array<Vector2>) { super();
		this.pos = pos;
		this.verts = verts;
		this.edges = [];
		
		// Get bounds and create edges from verts
		var minX = verts[0].x;
		var minY = verts[0].y;
		var maxX = verts[0].x;
		var maxY = verts[0].y;
		for (i in 1...verts.length) {
			edges.push(new Edge(verts[i-1], verts[i], this));
			if (verts[i].x < minX) {minX = verts[i].x;}
			if (verts[i].y < minY) {minY = verts[i].y;}
			if (verts[i].x > maxX) {maxX = verts[i].x;}
			if (verts[i].y > maxY) {maxY = verts[i].y;}
		}
		edges.push(new Edge(verts[verts.length-1], verts[0], this));
		this.localBoundsMin = new Vector2(minX, minY);
		this.localBoundsMax = new Vector2(maxX, maxY);
	}
	
	public inline function getVertsWorldSpace():Array<Vector2> {
		return Lambda.array(Lambda.map(verts, function(v) { return v.add(pos); }));
	}

	public override function checkParticleCollision(particles:Array<Particle>):Void {
		for (p in particles) {
			if (isPointInCollider(p.pos)) {
				var closestDist = Math.POSITIVE_INFINITY;
				var closestEdge:Edge = null;
				for (e in edges) {
					// Find which edge is closest and push the particle along it's normal
					var dist:Float = p.pos.distanceTo(e.getClosestPointOnEdgeFromPoint(p.pos));
					if (dist < closestDist) {
						closestDist = dist;
						closestEdge = e;
					}
				}
				// push towards that edge
				p.pos = p.pos.add(closestEdge.normal.mult(strength));
			}
		}
	}
	
	public function isInBounds(p:Vector2):Bool {
		// check if inside box
		if (p.x > this.localBoundsMin.x + pos.x && p.x < this.localBoundsMax.x + pos.x && // overlap x
			p.y > this.localBoundsMin.y + pos.y && p.y < this.localBoundsMax.y + pos.y) { // overlap y
				return true;
		}
		return false;
	}
	
	public override function isPointInCollider(point:Vector2):Bool {
		var vertsWS:Array<Vector2> = getVertsWorldSpace();
		var j:Int = vertsWS.length - 1;
		var inside:Bool = false;
		for (i in 0...vertsWS.length) {
			if (vertsWS[i].y < point.y && vertsWS[j].y >= point.y || vertsWS[j].y < point.y && vertsWS[i].y >= point.y) {
				if (vertsWS[i].x + (point.y - vertsWS[i].y) / (vertsWS[j].y - vertsWS[i].y) * (vertsWS[j].x - vertsWS[i].x) < point.x) {
					inside = !inside;
				}
			}
			j = i;
		}
		return inside;
	}
	
	public override function render(graphics : Graphics):Void {
		graphics.color = colliderColor;
		graphics.drawPolygon(pos.x, pos.y, verts);
		
		if (renderNormals) {
			for (edge in edges) {
				edge.renderNormal(graphics);
			}
		}
	}
}

// Edge should be used only through Polygon for collisions
class Edge {
	public var vert0:Vector2;
	public var vert1:Vector2;
	public var normal(default, null):Vector2;
	var parent:Polygon;
	
	public var normalColor:Color = Color.Red;
	public var normalLength:Int = 32;
	
	public function new(vert0:Vector2, vert1:Vector2, parent:Polygon) {
		this.vert0 = vert0;
		this.vert1 = vert1;
		this.parent = parent;
		this.normal = new Vector2(0,0);
		updateNormal();
	}

	// Need to call if relative vert positions change
	public function updateNormal() {
		var delta = vert1.sub(vert0);
		normal.x = delta.y;
		normal.y = -delta.x;
		normal.normalize();
	}
	
	public function getClosestPointOnEdgeFromPoint(point:Vector2):Vector2 {
		var v0 = vert0.add(parent.pos);
		var v1 = vert1.add(parent.pos);
		var dot = point.sub(v1).dot(v0.sub(v1)) / v0.sub(v1).dot(v0.sub(v1));
		
		// Clamp to line segment
		if (dot < 0)
			dot = 0;
		else if (dot > 1)
			dot = 1;
			
		var intersection:Vector2 = v0.mult(dot).add(v1.mult(1 - dot));
		return intersection;
	}
	
	public function renderNormal(graphics : Graphics) {
		graphics.color = normalColor;
		var midPoint = vert1.add(parent.pos).add(vert0).add(parent.pos).mult(0.5);
		graphics.drawLine(midPoint.x, midPoint.y, midPoint.x + (normal.x * normalLength), midPoint.y + (normal.y * normalLength));
	}
}