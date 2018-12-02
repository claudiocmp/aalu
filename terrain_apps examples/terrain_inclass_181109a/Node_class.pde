class Node {
  //coordinate
  float x, y;
  //costs (got and hestimated)
  float g, h;
  //
  int p;
  ArrayList nbors; //array of node objects, not indecies
  ArrayList nCost; //cost multiplier for each corresponding
  Node(float _x, float _y) {
    x = _x;
    y = _y;
    g = 0;
    h = 0;
    p = -1;
    nbors = new ArrayList();
    nCost = new ArrayList();
  }
  void addNbor(Node _node, float cm) {
    nbors.add(_node);
    nCost.add(new Float(cm));
  }
}
