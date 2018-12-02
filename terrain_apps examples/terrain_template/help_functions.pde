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
