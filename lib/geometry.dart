part of 'camera.dart';

class Point {
    double x;
    double y;

    Point(this.x, this.y);
    Point.zero() : this(0, 0);
    Point.fromNative(Map<dynamic, dynamic> data) : this(data['x'], data['y']);

    Map<String, double> get toNative {
        return {'x': x, 'y': y};
    }
}

class Size {
    double width;
    double height;

    Size(this.width, this.height);
    Size.zero() : this(0, 0);
    Size.fromNative(Map<dynamic, dynamic> data) : this(data['width'], data['height']);

    Map<String, double> get toNative {
        return {'width': width, 'height': height};
    }
}

class Rect {
    Point origin;
    Size size;

    Rect(this.origin, this.size);
    Rect.zero() : this(Point.zero(), Size.zero());
    Rect.fromNative(Map<dynamic, dynamic> data)
            : this(Point.fromNative(data['origin']), Size.fromNative(data['size']));

    Map<String, dynamic> get toNative {
        return {'origin': origin.toNative, 'size': size.toNative};
    }
}
