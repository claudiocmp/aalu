//class with utility functions that can be called statically
static class Util {

  public static int getIndex(  Set<? extends Object> set, Object value  ) {

    int result = 0;

    for (Object entry : set) {
      if (entry.equals(value)) {
        return result;
      }
      result++;
    }

    return -1;
  }

  public static int closestPoint(PVector point, PVector[] point_cloud, int search_radius) {
    float minDistSeen = 10000000;
    int closest = -1;

    for (int i = 0; i < point_cloud.length; i++) {
      float distance = point.dist(point_cloud[i]);
      if (distance < minDistSeen && distance <= search_radius && distance>0) {
        closest = i;
        minDistSeen = distance;
      }
    }
    return closest;
  }

  public static float distance(float x1, float y1, float x2, float y2) {
    return sqrt(abs(y2-y1)+abs(x2-x1));
  }

  public static int[] closestNode(PVector point, int[][] nmap, int searchRadius, Terrain t) {
    float minDistSeen = 100000000;//minDistSeen remembers the distance of the closest point found so far within the loop. In fact, you need to remember how far it was to compare it to the other points during the scan of the point cloud
    int[] closest = {-1, -1}; //if no points are found, the function returns -1

    for (int i = 0; i < nmap.length; i++) {
      for (int j = 0; j < nmap[i].length; j++) {
        if (nmap[i][j] >= 0) {
          Node n = t.nodes.get(nmap[i][j]);


          float dis = distance(point.x, point.y, n.x, n.y);


          if (dis < minDistSeen && dis <= searchRadius && dis > 0) { //questions if the point is the closest I've found so far. Moreover, if your point belong itself to the point cloud, you DO NOT WANT TO find itself (distance > 0)
            closest[0] = i;
            closest[1] = j;
            minDistSeen = dis;
          }
        }
      }
    }
    return closest;//the function must return an integer, as declared in the first line ("int ClosestPoint(..arguments..)"
  }

  public static int closestFace(PVector point, HE_Face[] faces) {
    float minDistSeen = 1000000;
    int closest = -1;

    for (int i=0; i<faces.length; i++) {
      float distance = PVector.dist(point, new PVector( faces[i].getFaceCenter().xf(), faces[i].getFaceCenter().yf(), faces[i].getFaceCenter().zf()));
      if (distance < minDistSeen) {
        closest = i;
        minDistSeen = distance;
      }
    }
    return closest;
  }
}
