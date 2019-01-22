class Point {
    double x;
    double y;

    Point(double x, double y) {
        this.x = x;
        this.x = y;
    }

    Point.init() {
        this.x = 0;
        this.y = 0;
    }

    Point.fromNative(Map<dynamic, dynamic> data) {
        x = data['x'];
        y = data['y'];
    }

    Map<String, double> get toNative {
        return {'x': x, 'y': y};
    }
}

class Size {
    double width;
    double height;

    Size(double width, double height) {
        this.width = width;
        this.height = height;
    }

    Size.init() {
        this.width = 0;
        this.height = 0;
    }

    Size.fromNative(Map<dynamic, dynamic> data) {
        width = data['width'];
        height = data['height'];
    }

    Map<String, double> get toNative {
        return {'width': width, 'height': height};
    }
}

class Rect {
    Point origin;
    Size size;

    Rect(Point origin, Size size) {
        this.origin = origin;
        this.size = size;
    }

    Rect.init() {
        this.origin = Point.init();
        this.size = Size.init();
    }

    Rect.fromNative(Map<dynamic, dynamic> data) {
        origin = Point.fromMap(data['origin']);
        size = Size.fromMap(data['size']);
    }

    Map<String, dynamic> get toNative {
        return {'origin': origin.toNative, 'size': size.toNative};
    }
}
