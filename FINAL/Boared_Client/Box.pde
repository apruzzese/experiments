class Box {
  final String LOCAL_SEPARATOR  = "|";
  int x, y, w, h;
  int id;
  float a;

  Box(int id, int px, int py, int pw, int ph) {
    x = px;
    y = py;
    w = pw;
    h = ph;
    //a = pa;
    this.id = id;
  }
  Box(int id) {
    this.id = id;
  }

  String serialize() {
    String str = "";
    str += id + LOCAL_SEPARATOR;
    str += x + LOCAL_SEPARATOR;
    str += y + LOCAL_SEPARATOR;
    str += w + LOCAL_SEPARATOR;
    str += h + LOCAL_SEPARATOR;
    str += a;
    return str;
  }

  void deserialize(String data) {
    String[] chunks = split(data, LOCAL_SEPARATOR);
    if (chunks == null) {
      println("ERROR: data error");
      return;
    } 
    if (chunks.length != 6) {
      println("ERROR: data error, wrong format");
      println(data);
      return;
    } 
    id = parseInt(chunks[0]);
    x  = parseInt(chunks[1]);
    y  = parseInt(chunks[2]);
    w  = parseInt(chunks[3]);
    h  = parseInt(chunks[4]);
  //  a  = parseFloat(chunks[5]);
  }

  void paint() {
    pushMatrix();
    translate (x, y);
    rotate(a);
    rect(0, 0, w, h);
    popMatrix();
  }

  boolean isInside(float px, float py) {

    float dx = px - x;
    float dy = py - y;
    float s = sin(-a);
    float c = cos(-a);
    float rx = x + dx * c - dy * s;
    float ry = y + dx * s + dy * c;

    if (rx < x) return false;
    if (ry < y) return false;
    if (rx >= x + w) return false;
    if (ry >= y + h) return false;
    return true;
  }
}
