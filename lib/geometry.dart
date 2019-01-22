class Point {
    double x;
    double y;

    Point(double x, double y)
        : this.x = x
        , this.y = y {
    }

    Point.zero() : this(0, 0);

    Point.fromNative(Map<dynamic, dynamic> data) : this(data['x'], data['y']);

    Map<String, double> get toNative {
        return {'x': x, 'y': y};
    }
}

class Size {
    double width;
    double height;

    Size(double width, double height) 
            : this.width = width
            , this.height = height {
    }

    Size.zero() : this(0, 0);

    Size.fromNative(Map<dynamic, dynamic> data) : this(data['width'], data['height']);

    Map<String, double> get toNative {
        return {'width': width, 'height': height};
    }
}

class Rect {
    Point origin;
    Size size;

    Rect(Point origin, Size size) 
            : this.origin = origin
            , this.size = size {
    }

    Rect.zero() : this(Point.zero(), Size.zero());

    Rect.fromNative(Map<dynamic, dynamic> data)
            : this(Point.fromNative(data['origin']), Size.fromNative(data['size']));

    Map<String, dynamic> get toNative {
        return {'origin': origin.toNative, 'size': size.toNative};
    }
}
