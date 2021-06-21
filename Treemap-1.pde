// CS5764 HW5 Treemap sample code.
// Make a tree structure out of a categorical csv data table.
import java.util.Arrays;
import java.util.Collections;

TreeNode root;
int winWidth;
int winHeight;

void setup(){
  //setup drawing window
  size(1500, 1000);
  winWidth = 1500;
  winHeight = 1000;
  
  //setup tree
  root = new TreeNode("treemap-stocks.csv", 3, 5, 6, 4);
  //root = new TreeNode("treemap-counties.csv", 3, 4);
  println(root.size, root.children[0].size, root.children[0].children[0].size, 
    root.children[0].children[0].children[0].size, root.children[0].children[0].children[0].data.getRowCount(), 
    root.children[0].children[0].children[0].name, root.children[0].children[0].children[0].leafFullName,
    red(root.children[0].children[0].children[0].leafColor), green(root.children[0].children[0].children[0].leafColor));
  root = createTreeMap(root);
  println(root.children.length);
  pushMatrix();
  scale(0.98);
  translate(5, 5); 
  
}
void draw() {
  //pushMatrix();
  //scale(0.98);
  //translate(5, 5); 
  drawTree(root);
  drawTreeBorders(root);
  drawTreePath(root);
  drawTreeLabels(root);
  
  //popMatrix();
}


int numLevels=0, sizeColIdx=0, colorColIdx=0, leafFullNameIdx=0;// Data file parameters
float maxColValue=0; float minColValue=0;

public class TreeNode implements Comparable<TreeNode> {
  public int level;          // my level in the tree, 0=root
  public String name;        // my name
  public Table data;         // table of data for all my leaf descendents
  public float size;         // my total size, computed from size data column
  public boolean isLeaf;     // am i a leaf?
  public color leafColor;    //color to be assigned to a leaf node
  public String leafFullName;   //abbreviation for leaf node name
  public TreeNode[] children;// my list of children nodes
  public int cornerX;
  public int cornerY;
  public int nodeWidth;
  public int nodeHeight;

  // Create a tree from csv file, 
  // with lvls number of categoral levels starting at column index 1
  // and using column index sz for the leaf node size data.
  // Uses recursion to build the tree.
  TreeNode(String file, int lvls, int sz, int col, int fullname) {  // other params needed ...?
    numLevels = lvls;
    sizeColIdx = sz;
    colorColIdx = col;
    leafFullNameIdx = fullname;
    data = loadTable(file, "header");
    maxColValue = data.getFloatList(col).max();
    minColValue = data.getFloatList(col).min();
    println(data.getRowCount(), data.getColumnCount()); 
    init(0, "Root", data);
  }
  TreeNode(int lev, String nm, Table d) {
    init(lev, nm, d);
  }
  public int compareTo(TreeNode n) {  //Comparable, useful for Arrays.sort(children)
    if(size < n.size){
      return -1;
    }
    else if(size == n.size){
      return 0;
    }
    return 1;
  }

  private void init(int lev, String nm, Table d) {
    level = lev;
    name = nm; 
    data = d;
    size = getSize();
    isLeaf = (level >= numLevels);  
    children = getChildrenList();
  }
  private float getSize() {  // compute size of this node from leaf data
    float sum=0.0;
    for (float e : data.getFloatColumn(sizeColIdx))
      sum += e;
    return(sum);
  }
  private String[] getChildrenNames() {  // find names of children of this node from next level column of data
    return(data.getUnique(level+1));
  }
  private Table getChildData(String childname) {  // filter data for a given child
    return(new Table(data.findRows(childname, level+1)));
  }
  private TreeNode[] getChildrenList() {  // setup a list of children
    if (isLeaf){
      float colorVal = data.getFloat(0,colorColIdx); 
      if (colorVal>=0){
        leafColor = color(0, map(colorVal, 0, maxColValue, 20, 255), 0);
      }
      else{
        leafColor = color(map(colorVal, 0, minColValue, 20, 255),0, 0);
      }
      leafFullName = data.getString(0,leafFullNameIdx);
      return null;
    }
    String[] childNames = getChildrenNames();
    TreeNode[] childs = new TreeNode[childNames.length];
    for (int i=0; i<childNames.length; i++) {
      childs[i] = new TreeNode(level+1, childNames[i], getChildData(childNames[i]));  // Recursion happens here.
    }
    Arrays.sort(childs, Collections.reverseOrder());
    return childs;
  }
}

public void drawTree(TreeNode root){
  
  
  for(int i = 0; i < root.children.length;i++){
    noStroke();
    //println(root.children[i].cornerX, root.children[i].cornerY, root.children[i].nodeWidth, root.children[i].nodeHeight);
    if(!root.children[0].isLeaf){
      drawTree(root.children[i]);
    }
    if(root.children[i].isLeaf){
      fill(root.children[i].leafColor);
    }
    else{
      noFill();
    }
    rect(root.children[i].cornerX, root.children[i].cornerY, root.children[i].nodeWidth, root.children[i].nodeHeight); 
    
  }
}

public void drawTreeBorders(TreeNode root){
  for(int i = 0; i < root.children.length;i++){
    noFill();
    //println(root.children[i].cornerX, root.children[i].cornerY, root.children[i].nodeWidth, root.children[i].nodeHeight);
    if(!root.children[0].isLeaf){
      drawTreeBorders(root.children[i]);
    }
    stroke(0, 0, 0);
    strokeWeight(map(numLevels - root.children[i].level, 0, numLevels, 1, 7));
    rect(root.children[i].cornerX, root.children[i].cornerY, root.children[i].nodeWidth, root.children[i].nodeHeight); 
    
  }
}

public void drawTreeLabels(TreeNode node){
  for(int i = 0; i < node.children.length;i++){
    fill(255, 255, 255, map(node.children[i].level, 0, numLevels, 40, 255));
    //println(node.children[i].cornerX, node.children[i].cornerY, node.children[i].nodeWidth, node.children[i].nodeHeight);
    
    //stroke(255, 255, 255);
    //trokeWeight(map(numLevels - node.children[i].level, 0, numLevels, 1, 7));
    
    //textSize(map(numLevels - node.children[i].level, 0, numLevels, 6, 32));
    textSize(map(node.children[i].size/root.size,0, 1, 8, 128));
    if(mouseX > node.children[i].cornerX && mouseX < node.children[i].cornerX + node.children[i].nodeWidth &&
       mouseY > node.children[i].cornerY && mouseY < node.children[i].cornerY + node.children[i].nodeHeight){
         if(node.children[i].isLeaf){  
          textAlign(CENTER,CENTER);
          text(node.children[i].leafFullName, node.children[i].cornerX + node.children[i].nodeWidth/2, 
               node.children[i].cornerY + node.children[i].nodeHeight/2);      
         }
         else if(node.children[i].level > 1){
           textAlign(CENTER,TOP);
           text(node.children[i].name, node.children[i].cornerX + node.children[i].nodeWidth/2, 
                node.children[i].cornerY);
         }
         else{
           textAlign(CENTER,CENTER);
           text(node.children[i].name, node.children[i].cornerX + node.children[i].nodeWidth/2, 
                node.children[i].cornerY + node.children[i].nodeHeight/2);
         }
    }
    else if(node.children[i].level == 1 || node.children[i].level == numLevels){
      textAlign(CENTER,CENTER);
      text(node.children[i].name, node.children[i].cornerX + node.children[i].nodeWidth/2, 
      node.children[i].cornerY + node.children[i].nodeHeight/2);
    }
    if(!node.children[0].isLeaf){
      drawTreeLabels(node.children[i]);
    }
    
  }
}

public void drawTreePath(TreeNode root){
  noFill();
  stroke(255, 255, 0);
  strokeWeight(3);
  for(int i = 0; i < root.children.length;i++){
    if(!root.children[0].isLeaf){
      drawTreePath(root.children[i]);
    }
    if(mouseX > root.children[i].cornerX && mouseX < root.children[i].cornerX + root.children[i].nodeWidth &&
       mouseY > root.children[i].cornerY && mouseY < root.children[i].cornerY + root.children[i].nodeHeight){
      rect(root.children[i].cornerX, root.children[i].cornerY, root.children[i].nodeWidth, root.children[i].nodeHeight);
    }
  }
}
public TreeNode createTreeMap(TreeNode root){
  root.nodeWidth = winWidth;
  root.nodeHeight = winHeight;
  root = addSquare(0, 0, winWidth, winHeight, root);
  return root;
    //makeSquares(0, 0, winWidth, windHeight, 
}

public TreeNode addSquare(int cornerx, int cornery, int boundwidth, int boundheight, TreeNode parent){
  //int parentArea = parent.nodeWidth*parent.nodeHeight;
  boolean usingHeight = boundheight < boundwidth;
  ArrayList<Float> nodeAreas = new ArrayList<Float>();
  int boundingDim = 0;
  if(usingHeight){
    boundingDim = boundheight;
  }
  else{
    boundingDim = boundwidth;
  }
    
  float currentAspect = 0;
  float totalArea = 0;
  for(int i = 0; i < parent.children.length; i++){
    float screenArea = 0;
    //if(i == parent.children.length - 1){
    //  screenArea = max(parentArea,(parent.children[i].size/parent.size)*parent.nodeWidth*parent.nodeHeight) ;
    //}
    //else{
      screenArea = (parent.children[i].size/parent.size)*parent.nodeWidth*parent.nodeHeight;
     // parentArea = parentArea - (int)(screenArea);
    //}
    
    totalArea = totalArea + screenArea;
    int tempDim1 = (int)(totalArea/boundingDim);
    int tempDim2 = (int)(screenArea/tempDim1);
    float tempaspect = (float)(min(tempDim1, tempDim2))/(float)(max(tempDim1, tempDim2));
    //println(screenArea, tempDim1, tempDim2);
    if(tempaspect >=currentAspect && i != parent.children.length - 1){      
      nodeAreas.add(screenArea);
      //println(i, tempaspect);
      currentAspect = tempaspect;
    }
    else{
      if(i == parent.children.length - 1){
        nodeAreas.add(screenArea);        
        totalArea = totalArea + screenArea;
        i = i+1;
      }
      totalArea = totalArea - screenArea;
      int curdimCount = 0;
      for(int j = 0 ; j < nodeAreas.size();j++){
        
        if(usingHeight){          
          int curboxwidth = (int)(totalArea/boundheight);
          int curboxheight = (int)(nodeAreas.get(j)/curboxwidth);
          parent.children[i - nodeAreas.size() + j].cornerY = cornery + curdimCount;//cornery + boundheight - curboxheight - curdimCount;          
          parent.children[i - nodeAreas.size() + j].cornerX = cornerx;
          if(i == parent.children.length){
            parent.children[i - nodeAreas.size() + j].nodeWidth = parent.cornerX + parent.nodeWidth - parent.children[i - nodeAreas.size() + j].cornerX;
          }
          else{
            parent.children[i - nodeAreas.size() + j].nodeWidth = curboxwidth;
          }

          parent.children[i - nodeAreas.size() + j].nodeHeight = curboxheight;
          curdimCount = curdimCount + curboxheight;
        }
        if(!usingHeight){          
          int curboxheight = (int)(totalArea/boundwidth);
          int curboxwidth = (int)(nodeAreas.get(j)/curboxheight);
          if(i == parent.children.length){
            parent.children[i - nodeAreas.size() + j].cornerY = parent.cornerY;
          }
          else{
            parent.children[i - nodeAreas.size() + j].cornerY = cornery + boundheight - curboxheight;
          }
          parent.children[i - nodeAreas.size() + j].cornerX = cornerx + curdimCount;
          parent.children[i - nodeAreas.size() + j].nodeWidth = curboxwidth;
          if(i == parent.children.length){
            parent.children[i - nodeAreas.size() + j].nodeHeight = boundheight;
          }
          else{  
            parent.children[i - nodeAreas.size() + j].nodeHeight = curboxheight;
          }
          curdimCount = curdimCount + curboxwidth;
        }
      }
      
      if(usingHeight){
        cornerx = cornerx + (int)(totalArea/boundheight);
        boundwidth = boundwidth - (int)(totalArea/boundheight);
      }
      if(!usingHeight){
        boundheight = boundheight - (int)(totalArea/boundwidth);
      }
      currentAspect = 0;
      totalArea = 0;
      i = i - 1;
      nodeAreas.clear();
      usingHeight = boundheight < boundwidth;
      if(usingHeight){
        boundingDim = boundheight;
      }
      else{
        boundingDim = boundwidth;
      }
    }
    
  }
  if (!parent.children[0].isLeaf){
    for(int i = 0;i < parent.children.length;i++){
      parent.children[i] = addSquare(parent.children[i].cornerX, parent.children[i].cornerY, 
                                     parent.children[i].nodeWidth, parent.children[i].nodeHeight, parent.children[i]);
    }
  }
  return parent;
}
  
public void makeSquares(int cornerx, int cornery, int boundwidth, int boundheight, TreeNode node){

}