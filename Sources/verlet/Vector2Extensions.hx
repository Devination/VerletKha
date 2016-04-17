package verlet;
import kha.math.Vector2;
using Vector2Extensions.Vector2Extensions;

class Vector2Extensions {
	public static var radToDeg(get, null):Float;
	static function get_radToDeg(){return 180/Math.PI;}
	
	//Returns the angle between from and to vectors.
	public static inline function angle(from:Vector2, to:Vector2, ?inDegrees:Bool = true) {
		from.normalize();
		to.normalize();
		return Math.acos(from.dot(to)) * (inDegrees ? radToDeg : 1);
	}
	
	public static inline function angle2(v:Vector2, vLeft:Vector2, vRight:Vector2, ?inDegrees:Bool = true) {
		return vLeft.sub(v).angle(vRight.sub(v), inDegrees);
	}
	
	public static inline function length2(v:Vector2) {
		return v.x * v.x + v.y * v.y;
	}
	
	public static inline function distanceTo(v1:Vector2, v2:Vector2) {
		return Math.abs(v1.sub(v2).length);
	}
	
	public static inline function rotate(v:Vector2, origin:Vector2, amount:Float) {
		var x = v.x - origin.x;
		var y = v.y - origin.y;
		
		return new Vector2(
			x * Math.cos(amount) - y * Math.sin(amount) + origin.x,
			x * Math.sin(amount) - y * Math.cos(amount) + origin.y);
	}
}