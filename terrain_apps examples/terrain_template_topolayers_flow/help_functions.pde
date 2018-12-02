//class with util functions
static class Util {
  //take index from set item
  public static int getIndex(Set<? extends Object> set, Object value) {
    int result = 0;
    for (Object entry:set) {
      if (entry.equals(value)) return result;
      result++;
    }
    return -1;
  }

  public static int ClosestPoint(PVector point, PVector[] pointCloud, int searchRadius) {

    float minDistSeen = 100000000; //minDistSeen remembers the distance of the closest point found so far within the loop. In fact, you need to remember how far it was to compare it to the other points during the scan of the point cloud
    int closest = -1; //if no points are found, the function returns -1


    for (int i = 0; i <pointCloud.length; i++) { //loop through the pointloud and...
      float distance = point.dist(pointCloud[i]); //...check the distance between my lookup point to the i-point in the pointcloud
      if (distance < minDistSeen && distance <= searchRadius && distance > 0) { //questions if the point is the closest I've found so far. Moreover, if your point belong itself to the point cloud, you DO NOT WANT TO find itself (distance > 0)
        closest = i; //if yes, remember the index of the point in the list
        minDistSeen = distance;
      }
    }
    return closest; //the function must return an integer, as declared in the first line ("int ClosestPoint(..arguments..)"
  }
  
  public static int ClosestVertex(PVector point, HE_Vertex[] pointCloud, int searchRadius) {

    float minDistSeen = 100000000; //minDistSeen remembers the distance of the closest point found so far within the loop. In fact, you need to remember how far it was to compare it to the other points during the scan of the point cloud
    int closest = -1; //if no points are found, the function returns -1

    for (int i = 0; i <pointCloud.length; i++) { //loop through the pointloud and...
      float distance = (float)pointCloud[i].getDistance(new HE_Vertex(point.x,point.y,point.z)); 
      if (distance < minDistSeen && distance <= searchRadius && distance > 0) { 
        closest = i; 
        minDistSeen = distance;
      }
    }
    return closest; 
  }
  
   public static int ClosestFace(PVector point, HE_Face[] faces, int searchRadius) {

    float minDistSeen = 100000000; //minDistSeen remembers the distance of the closest point found so far within the loop. In fact, you need to remember how far it was to compare it to the other points during the scan of the point cloud
    int closest = -1; //if no points are found, the function returns -1

    for (int i = 0; i <faces.length; i++) { //loop through the pointloud and...
      float distance = PVector.dist(new PVector( faces[i].getFaceCenter().xf(),faces[i].getFaceCenter().yf(),faces[i].getFaceCenter().zf()),new PVector (point.x,point.y,point.z) ) ;
      if (distance < minDistSeen && distance <= searchRadius && distance > 0) { 
        closest = i; 
        minDistSeen = distance;
      }
    }
    return closest; 
  }
}

//colours
public int[][] palette = {{color(255, 40, 51), color(132, 40, 255)}};




// Function that calculates the coordinates on the floor surface corresponding to the screen coordinates
PVector getUnProjectedPointOnFloor(float screen_x, float screen_y, PVector floorPosition, PVector floorDirection) {

  PVector f = floorPosition.get(); // Position of the floor
  PVector n = floorDirection.get(); // The direction of the floor ( normal vector )
  PVector w = unProject(screen_x, screen_y, -1.0); // 3 -dimensional coordinate corresponding to a point on the screen
  PVector e = getEyePosition(); // Viewpoint position

  // Computing the intersection of  
  f.sub(e);
  w.sub(e);
  w.mult( n.dot(f)/n.dot(w) );
  w.add(e);

  return w;
}

// Function to get the position of the viewpoint in the current coordinate system
PVector getEyePosition() {
  PMatrix3D mat = (PMatrix3D)getMatrix(); //Get the model view matrix
  mat.invert();
  return new PVector( mat.m03, mat.m13, mat.m23 );
}
//Function to perform the conversion to the local coordinate system ( reverse projection ) from the window coordinate system
PVector unProject(float winX, float winY, float winZ) {
  PMatrix3D mat = getMatrixLocalToWindow();  
  mat.invert();

  float[] in = {winX, winY, winZ, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);  // Do not use PMatrix3D.mult(PVector, PVector)

  if (out[3] == 0 ) {
    return null;
  }

  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);  
  return result;
}

//Function to compute the transformation matrix to the window coordinate system from the local coordinate system
PMatrix3D getMatrixLocalToWindow() {
  PMatrix3D projection = ((PGraphics3D)g).projection; 
  PMatrix3D modelview = ((PGraphics3D)g).modelview;   

  // viewport transf matrix
  PMatrix3D viewport = new PMatrix3D();
  viewport.m00 = viewport.m03 = width/2;
  viewport.m11 = -height/2;
  viewport.m13 =  height/2;

  // Calculate the transformation matrix to the window coordinate system from the local coordinate system
  viewport.apply(projection);
  viewport.apply(modelview);
  return viewport;
}
