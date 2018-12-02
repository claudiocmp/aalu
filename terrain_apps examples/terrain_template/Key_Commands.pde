void keyPressed() {
  if (key=='c') {
    t.colourTerrain();
    println(t.getIJ(0));
    println(t.getIJ(150));
    println(t.getIndex(15,20));
  }
}
