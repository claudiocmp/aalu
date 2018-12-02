class Particle { //<>//

  PVector pos;
  PVector p_pos; //precedent position
  PVector vel;
  PVector acc;
  private float max_vel;
  private float max_force;

  WB_Coord meshPt; 

  Particle(PVector pos) {
    this.pos = pos;
    this.p_pos = pos.copy();
    this.vel = new PVector(0, 0, 0);
    this.acc = new PVector(0, 0, 0);
    this.max_force = 5;
    this.max_vel = 5;
  }

  void flow(PVector force, TERRAIN t) {
    this.acc = PVector.add(acc.mult(.1), force.mult(.9));
    this.acc.limit(max_force);
    this.vel.add(acc);
    this.vel.limit(max_vel);
    this.p_pos = pos.copy();
    this.pos.add(vel);
    //snap back to terrain
    meshPt = t.mesh.getClosestPoint(new WB_Point(pos.x, pos.y, pos.z), t.vertex_tree);
    this.pos = new PVector(meshPt.xf(), meshPt.yf(), meshPt.zf());
  }

  void display() {
    pushMatrix();
    translate(this.pos.x, this.pos.y, this.pos.z+1);
    ellipseMode(CENTER);
    ellipse(0, 0, 10, 10);
    popMatrix();
  }
}

class ParticleSystem {
  Particle[] particles;
  TERRAIN t;
  //WB_KDTree tree = t.mesh.getVertexTree();

  ParticleSystem(int no_p, TERRAIN t) {
    this.t = t;
    this.particles = new Particle[no_p];
    for (int i=0; i < no_p; i++) {
      int v_i = (int)random(0, t.t_len);
      WB_Coord c = t.mesh.getVertex(v_i);
      PVector v = new PVector(c.xf(), c.yf(), c.zf());
      particles[i] = new Particle(v);
    }
  }

  void update() {
    //t.mesh.getClosestPoint(,tree)
    for (Particle p : this.particles) {
      //get closest face to particle
      int v_i = Util.ClosestFace(p.pos, t.mesh.getFacesAsArray(), 100);
      //if the particle gets out of the terrain, or it gets to the sea, cull and recreate
      if (v_i < 0 || p.pos.z < 1. || PVector.dist(p.pos,p.p_pos)<0.1) {
        v_i = (int)random(0, t.t_len);
        p.pos = new PVector(t.mesh.getVertex(v_i).xf(), t.mesh.getVertex(v_i).yf(), t.mesh.getVertex(v_i).zf());
      }
      WB_Coord nc = t.mesh.getFaceNormal(v_i);
      PVector n = new PVector(nc.xf(), nc.yf(), nc.zf());
      PVector f = n.cross(new PVector(0, 0, -1)).cross(n);
      p.flow(f, t);
    }
  }

  void display() {
    for (Particle p : this.particles) {
      p.display();
    }
  }
}
