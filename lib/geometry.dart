
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

    Point.fromMap(Map<dynamic, dynamic> data) {
        x = data['x'];
        y = data['y'];
    }

    Map<String, double> get toMap {
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

    Size.fromMap(Map<dynamic, dynamic> data) {
        width = data['width'];
        height = data['height'];
    }

    Map<String, double> get toMap {
        return {'width': width, 'height': height};
    }
}
