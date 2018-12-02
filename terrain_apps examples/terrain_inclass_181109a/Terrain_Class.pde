class Terrain { //<>// //<>//
  //domain for bbox
  TerrainDomain td;
  //mesh for bbox
  HE_Mesh bbox;
  int t_len;
  int x_ext;
  int y_ext;

  //points and mesh
  PVector[] points;
  HE_Mesh mesh;
  WB_KDTree mesh_topology_tree;

  //topo layers
  String[] landuse;
  int[] river;
  float[] sea;

  //A*
  ////////////A_STAR
  float gran = 250;
  int m = x_ext;
  int n = y_ext;
  int[][] nmap; //indices of nodes
  int start = -1;
  int end = -1;
  boolean is_start = true;
  //
  ArrayList openSet;
  ArrayList closedSet;
  ArrayList<Node> nodes; //nodes collection. it is indexed by nmap
  ArrayList path;
  //
  int from;
  int to;

  //////////////////////////////////////CONSTRUCTOR
  Terrain(String csv_path, String x_header, String y_header, String z_header, TerrainDomain _td) {
    //assign domain
    td = _td;
    //initialise bbox mesh
    HEC_Box creator = new HEC_Box();
    creator.setFromAABB( new WB_AABB(0, 0, 0, _td.delta_x*_td.scale, _td.delta_y*_td.scale, _td.delta_z*_td.scale ) );
    creator.setWidthSegments(1).setDepthSegments(1).setHeightSegments(1);
    bbox = new HE_Mesh(creator);
    //validate the HE_mesh object
    HET_Diagnosis.validate(bbox);

    //data initialisation
    initialise_terrain(csv_path, x_header, y_header, z_header);

    //initialise A_star parameters
    nmap = new int[x_ext][y_ext];
    openSet = new ArrayList();
    closedSet = new ArrayList();
    nodes = new ArrayList();
    path = new ArrayList();
    generateMap(sea);
  }

  void initialise_terrain(String csv_path, String x_header, String y_header, String z_header) {
    Table t;
    t = loadTable(csv_path, "header");
    t_len = t.getRowCount();
    //column indices for taking x,y
    List<String> headersList = Arrays.asList(t.getColumnTitles());
    //check up of headers included in csv
    if (!(headersList.contains(x_header) && headersList.contains(y_header) && headersList.contains((z_header)))) {
      throw new RuntimeException("The headers specified here are not the headers for X,Y,Z coordinates of your points. Check your csv and type the correct headers");
    }
    //take the index of the column by giving an header
    int x_col_i = t.checkColumnIndex(x_header);
    int y_col_i = t.checkColumnIndex(y_header);
    //calc the unique values in the x,y cols to take the extend of the terrain
    x_ext = t.getUnique(x_col_i).length;
    y_ext = t.getUnique(y_col_i).length;

    //geometric containers
    points = new PVector[t_len];
    float[][] vertices = new float[t_len][3];
    int[][] faces = new int[(x_ext-1) * (y_ext-1) ] [];

    //topographical layers
    landuse = new String[t_len];
    river = new int[t_len];
    sea = new float[t_len];

    int k = 0;
    for (TableRow row : t.rows()) {
      float x = row.getFloat(x_header);
      float y = row.getFloat(y_header);
      float z = row.getFloat(z_header);
      //take x,y,z and convertto processing coordindates
      PVector rw_tmp = new PVector(x, y, z);
      PVector tr_tmp = PVector.sub(rw_tmp, td.rw_trans );
      PVector fl_tmp = new PVector( tr_tmp.x, td.delta_y-tr_tmp.y, tr_tmp.z);
      fl_tmp.mult(td.scale);
      //add to points as PVector[]
      points[k] = fl_tmp.copy();
      //add vertices to my list
      vertices[k][0] = fl_tmp.x;
      vertices[k][1] = fl_tmp.y;
      vertices[k][2] = fl_tmp.z;
      //add topo layers
      landuse[k] = row.getString("LandUse") ;
      river[k] = row.getInt("CRiver100m");
      sea[k] = row.getFloat("Land");

      //increment the counter
      k++;
    }

    int index = 0;
    for (int j = 0; j <y_ext-1; j++) {
      for (int i = 0; i<x_ext-1; i++) {
        //construct face indices container
        faces[index] = new int[4];
        //assign the vertices indices acconrdingly
        faces[index][0] = i + x_ext*j;
        faces[index][1] = i + x_ext*(j+1);
        faces[index][2] = i+1 + x_ext*(j+1);
        faces[index][3] = i+1 + x_ext*j;
        index++;
      }
    }

    HEC_FromFacelist facelist = new HEC_FromFacelist().setVertices(vertices).setFaces(faces).setDuplicate(false);
    mesh = new HE_Mesh(facelist);
    mesh.validate();
    //    
    HES_CatmullClark sub = new HES_CatmullClark();
    sub.setKeepBoundary(true);
    sub.setKeepEdges(true);
    mesh.subdivide(sub, 1);
    mesh_topology_tree = mesh.getVertexTree();
  }

  //////////////////////////////////////METHODS
  void visualise_bb() {
    pushStyle();
    strokeWeight(.8);
    stroke(255);
    render.drawEdges(bbox);
    popStyle();
  }

  void visualise() {
    visualise_bb();
    pushStyle();
    //stroke(255);
    //strokeWeight(.5);
    //render.drawEdges(mesh);
    noStroke();
    //fill(200);
    render.drawFacesVC(mesh);
    popStyle();
    //draw A* path
    pushStyle();
    noFill();
    stroke(230);
    strokeWeight(2.5);
    this.drawPathOnTerrain();
    popStyle();
  }

  int getIndex(HE_Vertex v) {
    //retrieve the closest point index which carries information of the landuse (paired to the PVector array)
    return Util.closestPoint( new PVector(v.xf(), v.yf(), v.zf()), points, 100 );
  }

  String getLandUse(HE_Vertex v) {
    //retrieve the closest point index which carries information of the landuse (paired to the PVector array)
    int i = this.getIndex(v);
    if (i >= 0) {
      return landuse[i];
    } else {
      return "";
    }
  }


  void colourByValues(int[] topo_layer, color from, color to) {

    //take ends in values (min,max)
    int delta = max(topo_layer) - min(topo_layer);
    //initialise a list of colours
    color[] colours = new color[delta+1];

    for (int i = 0; i<delta+1; i++) {
      colours[i] = lerpColor(from, to, (float)i/(delta-1));
    }
    println("max", max(topo_layer));
    println("min", min(topo_layer));
    println(colours);
    //colour the mesh by assigning a colour to the vertices
    HE_VertexIterator v_itr = mesh.vItr();
    //
    while (v_itr.hasNext()) {
      HE_Vertex v = v_itr.next();
      //retrieve the closest point index which carries information of the landuse (paired to the PVector array)
      int i = Util.closestPoint( new PVector(v.xf(), v.yf(), v.zf()), points, 100 );
      //get the index of the colour associated to set of land uses
      int c = topo_layer[i] - min(topo_layer);
      println(c);
      //colour the vertex
      v.setColor(colours[c]);
    }
  }

  void colourByFloats(float[] topo_layer, color from, color to) {

    //take ends in values (min,max)
    int delta = (int)max(topo_layer) - (int)min(topo_layer);
    //initialise a list of colours
    color[] colours = new color[delta+1];

    for (int i = 0; i<delta+1; i++) {
      colours[i] = lerpColor(from, to, (float)i/(delta-1));
    }

    //colour the mesh by assigning a colour to the vertices
    HE_VertexIterator v_itr = mesh.vItr();
    //
    while (v_itr.hasNext()) {
      HE_Vertex v = v_itr.next();
      //retrieve the closest point index which carries information of the landuse (paired to the PVector array)
      int i = Util.closestPoint( new PVector(v.xf(), v.yf(), v.zf()), points, 100 );
      //get the index of the colour associated to set of land uses
      int c = (int)topo_layer[i] - (int)min(topo_layer);
      //colour the vertex
      v.setColor(colours[c]);
    }
  }


  void colourByString(String[] topo_layer, color from, color to) {
    //create a string SET to store unique values
    Set<String> stringset = new HashSet<String>(Arrays.asList(topo_layer));
    int l = stringset.size();
    //initialise an array of colours to be applied to the mesh faces
    color[] colours = new color[l];
    for (int i = 0; i < colours.length; i++) {
      colours[i] = lerpColor(from, to, (float)i/(l-1) );
    }
    //colour the mesh by assigning a colour to the vertices
    HE_VertexIterator v_itr = mesh.vItr();
    //
    while (v_itr.hasNext()) {
      HE_Vertex v = v_itr.next();
      //retrieve the closest point index which carries information of the landuse (paired to the PVector array)
      int i = Util.closestPoint( new PVector(v.xf(), v.yf(), v.zf()), points, 100 );
      //get the index of the colour associated to set of land uses
      int c = Util.getIndex(stringset, topo_layer[i]);
      //colour the vertex
      v.setColor(colours[c]);
    }
  }

  //INDICES CONVETER
  int[] getIJ(int index) {
    int[] res = {ceil(index/x_ext), index%x_ext};
    return res;
  }
  int getIndex(int i, int j) {
    return i + (j * x_ext);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////A star function
  /*
  * A* code is derived and re-interpreted from another repo - unfortunately I cannot find it anymore.
   * If anyone notices any similarity, please report.
   */
  void generateMap(float[] topo_layer) {
    int q;
    Node n2;
    for ( int ix = 0; ix < x_ext; ix++ ) {
      for ( int iy = 0; iy < y_ext; iy++) {
        //position in flattened list
        int id = getIndex(ix, iy);
        PVector s = points[id]; //retrieve point
        nmap[ix][iy] = -1; //set a 0 index in nmap. will become positive if the nmap[i] points to a node (the node exists)

        if (topo_layer[id] >0) { //add only points with positive value (use negative values to avoid points from network)

          nodes.add(new Node(s.x, s.y));
          nmap[ix][iy] = nodes.size()-1; //add node index to nmap
          //avoid x boundary (ix==0)
          if (ix>0) {
            if (nmap[ix-1][iy]!=-1) {
              n2 = (Node)nodes.get(nodes.size()-1);
              int n2_pt_index = Util.closestPoint(s, points, 50);
              float cost = topo_layer[n2_pt_index];
              n2.addNbor((Node)nodes.get(nmap[ix-1][iy]), cost);
              ((Node)nodes.get(nmap[ix-1][iy])).addNbor(n2, cost);
            }
          }
          //avoid y boundary (iy==0)
          if (iy>0) {
            if (nmap[ix][iy-1]!=-1) {
              n2 = (Node)nodes.get(nodes.size()-1);
              int n2_pt_index = Util.closestPoint(s, points, 50);
              float cost = topo_layer[n2_pt_index];
              n2.addNbor((Node)nodes.get(nmap[ix][iy-1]), cost); 
              ((Node)nodes.get(nmap[ix][iy-1])).addNbor(n2, cost);
            }
          }
          //avoid corner (ix,iy==0)
          if (ix>0 && iy>0) {
            if (nmap[ix-1][iy-1]!=-1) {
              n2 = (Node)nodes.get(nodes.size()-1);
              int n2_pt_index = Util.closestPoint(s, points, 50);
              float cost = topo_layer[n2_pt_index];
              n2.addNbor((Node)nodes.get(nmap[ix-1][iy-1]), cost);
              ((Node)nodes.get(nmap[ix-1][iy-1])).addNbor(n2, cost);
            }
          }
        }
      }
    }
  }

  boolean aStar(int iStart, int iEnd) {
    start = iStart;
    end = iEnd;
    //A* Pathfinding Algorithm
    //Finds short path from node[iStart] to node[iEnd]
    //Works strictly off nodes, so not grid depended at all
    float endX, endY;
    endX = ((Node)nodes.get(iEnd)).x;
    endY = ((Node)nodes.get(iEnd)).y;

    openSet.clear();
    closedSet.clear();
    path.clear();

    //add initial node to openSet
    openSet.add( ((Node)nodes.get(iStart)) );
    ((Node)openSet.get(0)).p = -1;
    ((Node)openSet.get(0)).g = 0;
    ((Node)openSet.get(0)).h = Util.distance( ((Node)openSet.get(0)).x, ((Node)openSet.get(0)).y, endX, endY );

    Node current;
    float tentativeGScore;
    boolean tentativeIsBetter;
    float lowest = 999999999;
    int lowId = -1;

    while ( openSet.size()>0 ) {
      //find the node in openSet with the lowest f (g+h scores) and put its index in lowId
      lowest = 999999999;
      for ( int a = 0; a < openSet.size(); a++ ) {
        if ( ( ((Node)openSet.get(a)).g+((Node)openSet.get(a)).h ) <= lowest ) {
          lowest = ( ((Node)openSet.get(a)).g+((Node)openSet.get(a)).h );
          lowId = a;
        }
      }
      current = (Node)openSet.get(lowId);
      if ( (current.x == endX) && (current.y == endY) ) { //path found
        //follow parents backward from goal
        Node d = (Node)openSet.get(lowId);
        while ( d.p != -1 ) {
          path.add( d );
          d = (Node)nodes.get(d.p);
        }
        return true;
      }
      closedSet.add( (Node)openSet.get(lowId) );
      openSet.remove( lowId );
      for ( int n = 0; n < current.nbors.size(); n++ ) {
        if ( closedSet.contains( (Node)current.nbors.get(n) ) ) {
          continue;
        }
        tentativeGScore = current.g + Util.distance( current.x, current.y, ((Node)current.nbors.get(n)).x, ((Node)current.nbors.get(n)).y )*((Float)current.nCost.get(n));
        if ( !openSet.contains( (Node)current.nbors.get(n) ) ) {
          openSet.add( (Node)current.nbors.get(n) );
          tentativeIsBetter = true;
        } else if ( tentativeGScore < ((Node)current.nbors.get(n)).g ) {
          tentativeIsBetter = true;
        } else {
          tentativeIsBetter = false;
        }

        if ( tentativeIsBetter ) {
          ((Node)current.nbors.get(n)).p = nodes.indexOf( (Node)closedSet.get(closedSet.size()-1) ); //!!!!
          ((Node)current.nbors.get(n)).g = tentativeGScore;
          ((Node)current.nbors.get(n)).h = Util.distance( ((Node)current.nbors.get(n)).x, ((Node)current.nbors.get(n)).y, endX, endY );
        }
      }
    }
    //no path found
    return false;
  }

  void drawPathOnXY() {
    Node t1, t2;
    float ends_dim = 4;
    float pts_dim = ends_dim*.2;

    for ( int i = 0; i < nodes.size(); i++ ) {
      t1 = (Node)nodes.get(i);
      pushStyle();
      pushMatrix();
      translate(t1.x, t1.y, 1);
      if (i==start) { //start pt
        noStroke();
        fill(200, 100, 255);
        ellipse(0, 0, ends_dim, ends_dim);
      } else if (i==end) { //end pt
        noStroke();
        fill(255, 100, 200);
        ellipse(0, 0, ends_dim, ends_dim);
      } else {
        if (path.contains(t1)) { //all other pt
          stroke(255);
          fill(255);
          ellipse(0, 0, pts_dim, pts_dim);
        }
      }
      popStyle();
      popMatrix();
    }
  }

  void drawPathOnTerrain() {
    Node t1, t2;
    float ends_dim = 4;
    float pts_dim = ends_dim*.2;

    for ( int i = 0; i < nodes.size(); i++ ) {
      t1 = (Node)nodes.get(i);
      int p_i = Util.closestPoint(new PVector(t1.x, t1.y, 0), this.points, 500);
      pushStyle();
      pushMatrix();
      translate(points[p_i].x, points[p_i].y, points[p_i].z+2);
      if (i==start) { //start pt
        noStroke();
        fill(200, 100, 255);
        ellipse(0, 0, ends_dim, ends_dim);
      } else if (i==end) { //end pt
        noStroke();
        fill(255, 100, 200);
        ellipse(0, 0, ends_dim, ends_dim);
      } else {
        if (path.contains(t1)) { //all other pt
          stroke(255);
          fill(255);
          ellipse(0, 0, pts_dim, pts_dim);
        }
      }
      popStyle();
      popMatrix();
    }
  }
}


class TerrainDomain {
  //real world cooridnates
  float rw_min_x, rw_max_x, rw_min_y, rw_max_y, rw_min_z, rw_max_z;
  //translation from origin
  PVector rw_trans;
  //delta rw
  float delta_x, delta_y, delta_z;
  //scale factor
  float scale;
  PVector centre;

  TerrainDomain(float _x_min, float _x_max, float _y_min, float _y_max, float _z_min, float _z_max, float _scale) {
    rw_min_x = _x_min;
    rw_max_x = _x_max;
    rw_min_y = _y_min;
    rw_max_y = _y_max;
    rw_min_z = _z_min;
    rw_max_z = _z_max;

    //real world tranlsation vector (x,y,z)minimum => (0,0,0)
    rw_trans = new PVector( _x_min, _y_min, _z_min);

    //real world deltas (width, length, height) of Terrain Domain (bounding box)
    delta_x = _x_max - _x_min;
    delta_y = _y_max - _y_min;
    delta_z = _z_max - _z_min;

    scale = _scale;
    centre = new PVector(delta_x*.5*scale, delta_y*.5*scale, delta_z*.5*scale);
  }
}
