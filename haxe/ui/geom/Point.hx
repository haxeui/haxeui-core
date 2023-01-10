package haxe.ui.geom;

class Point {
    public var x:Float;
    public var y:Float;
    
    /**
        Adds the coordinates of another point to the coordinates of `this` point. 

        This operation modifies `this` point in place.

		@param addend The point to be added.
	**/
    public function add(addend:Point) {
        this.x += addend.x;
        this.y += addend.y;
    }
    
    /**
        Subtracts the coordinates of another point from the coordinates of `this` point. 
        
        This operation modifies `this` point in place.

		@param addend The point to be added.
	**/
    public function subtract(subtrahend:Point) {
        this.x -= subtrahend.x;
        this.y -= subtrahend.y;
    }
    
    /**
        Adds the specified coordinates to the coordinates of `this` point. 
        
        This operation modifies `this` point in place.

		@param addendX The value to be added to the x coordinate of `this` point.
		@param addendY The value to be added to the y coordinate of `this` point.
	**/
    public function addCoords(addendX:Float, addendY:Float) {
        this.x += addendX;
        this.y += addendY;
    }
    
    /**
        Subtracts the specified coordinates from the coordinates of `this` point. 
        
        This operation modifies `this` point in place.

		@param subtrahendX The value to be subtracted from the x coordinate of `this` point.
		@param subtrahendY The value to be subtracted from the y coordinate of `this` point.
	**/
    public function subtractCoords(subtrahendX:Float, subtrahendY:Float) {
        this.x -= subtrahendX;
        this.y -= subtrahendY;
    }
    
    /**
		Adds the coordinates of another point to the coordinates of `this` point to
		create a new point.

		@param addend The point to be added.
		@return The new point.
	**/
    public function sum(addend:Point):Point {
        return new Point(this.x + addend.x, this.y + addend.y);
    }
    
    /**
		Subtracts the coordinates of another point from the coordinates of `this` point to
		create a new point.

		@param subtrahend The point to be subtracted.
		@return The new point.
	**/
    public function diff(subtrahend:Point):Point {
        return new Point(this.x - subtrahend.x, this.y - subtrahend.y);
    }

    /**
		Creates a point obtained by rotating `this` point clockwise by 90 degrees about the origin.

		@return Rotated point.
	**/
    public function orthogonalCW():Point {
        return new Point(y, -x);
    }

    /**
		Creates a point obtained by rotating `this` point counter-clockwise by 90 degrees about the origin.

		@return Rotated point.
	**/
    public function orthogonalCCW():Point {
        return new Point(-y, x);
    }

    /**
        Creates a point with radius vector opposite to `this` point's radius vector. Equivalent to creating the
        point with coordinates equal to ones of `this` point by absolute value, but with opposite sign.

		@return Point with opposite radius vector.
	**/
    public function opposite():Point {
        return new Point(-x, -y);
    }

    /**
        Rotates `this` point by 180 degrees about the origin. Equivalent to changing the sign of both of `this` point's
        coordinates.

		This operation modifies `this` point in place.
	**/
    public function revert() {
        this.x = -x;
        this.y = -y;
    }

    /**
        Rotates `this` point counter-clockwise by a specified angle. 
        
        This operation modifies `this` point in place.

		@param radians Angle of rotation (in radians).
	**/
    public function rotate(radians:Float) {
        var cos = Math.cos(radians);
        var sin = Math.sin(radians);

        var newX = cos * x - sin * y;
        var newY = sin * x + cos * y;

        this.x = newX;
        this.y = newY;
    }

    /**
        Creates a new point obtained by rotating `this` point counter-clockwise by a specified angle. 

        @param radians Angle of rotation (in radians).
        
        @return Rotated point.
	**/
    public function rotated(radians:Float):Point {
        var cos = Math.cos(radians);
        var sin = Math.sin(radians);

        var newX = cos * x - sin * y;
        var newY = sin * x + cos * y;

        return new Point(newX, newY);
    }

    /**
        Returns the length of `this` point's radius vector, or the distance between the origin and `this` point.
        
        @return The length of the radius vector.
	**/
    public function length():Float {
        return Math.sqrt(x * x + y * y);
    }

    /**
        Scales the line segment between the origin and `this` point by a specified factor. 
        Equivalent to multiplying each coordinate of `this` point by `factor`.

        This operation modifies `this` point in place.

        @param factor Value by which the coordinates of `this` point are multiplied.
	**/
    public function multiply(factor:Float) {
        x *= factor;
		y *= factor;
    }

    /**
        Returns the point obtained by scaling the line segment between the origin and `this` point by 
        a specified factor. Equivalent to creating a new point with each coordinate being `factor` times 
        greater than the corresponding coordinate of `this` point.

        @param factor Value by which the coordinates of `this` point are multiplied.
        
        @return The resulting point.
	**/
    public function product(factor:Float):Point {
        return new Point(x * factor, y * factor);
    }

    /**
        Scales the line segment between the origin and `this` point to a set length.

        This operation modifies `this` point in place.

        @param targetLength The scaling value. For example, if the current point is
						    (0,5), and you normalize it to 2, the point returned is
						    at (0,2).
	**/
    public function normalize(targetLength:Float) {
        if (x == 0 && y == 0)
			return;
		
		var norm = targetLength / length();
		multiply(norm);
    }

    /**
        Creates a new point by scaling the line segment between the origin and `this`
        point to a set length.

        @param targetLength The scaling value. For example, if the current point is
						    (0,5), and you normalize it to 2, the point returned is
                            at (0,2).
        
        @return The normalized point.
	**/
    public function normalized(targetLength:Float):Point {
        if (x == 0 && y == 0)
            return new Point();
		
		var norm = targetLength / length();
		return product(norm);
    }

    /**
        Creates a new point by scaling the line segment between the origin and `this`
        point to a length of 1. Equivalent to `this.normalized(1)`.
        
        @return The orth of `this` point.
	**/
    public function orth():Point {
        return normalized(1);
    }

    /**
        Creates a new point by with coordinates equal to the coordinates of `this` point.
        
        @return The new point.
	**/
    public function copy():Point {
        return new Point(x, y);
    }

    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
	}
}
