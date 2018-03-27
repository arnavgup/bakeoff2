import java.util.ArrayList;
import java.util.Collections;
import java.lang.System;

//these are variables you should probably leave alone
int index = 0;
int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean rot_phase = false;
boolean start_game = false;
boolean rot_finish = true;
float lx = 0;
float ly = 0;
boolean flag4 = false;
int lastX = 300;
int lastY = 300;
final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(600,600); 
  //fullScreen();
  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);
frameRate(100);
  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}



void draw() {
  //Target t = targets.get(trialIndex);


  background(90); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }

  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  Target t = targets.get(trialIndex);
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));
  fill(204, 255, 255); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  //ellipse(t.x + t.z - 300, t.y + t.z/2 - 300, 10, 10);
  popMatrix();
  
  boolean closeDist = dist(t.x,t.y,screenTransX-width/2,screenTransY-height/2)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  
  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  if(rot_phase == false && rot_finish == true)
  {
  screenTransY = mouseY;
  screenTransX = mouseX;
  
  if (dist(mouseX, mouseY, t.x, t.y) > dist(mouseX, mouseY, lx, ly)){
  t.z += 1;
  }
  lx = t.x;
  ly = t.y;
  fill(255,255,255);
  
  drawArrow(mouseX, mouseY, t.x+300, t.y+300);
  }
  

  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  fill(255,255,255,50);
  int op = 0;
  int f = 255;
  if(closeDist == true){
    op += 70;
    f = 255;
  }
  if(closeRotation == true){
    op += 20;
  }
  if(closeZ == true){
    op += 25;
  }
  fill(0,255,f,op);
  if(checkForSuccess()==true){
    fill(0, 255, 0);
  }
  strokeWeight(3f);
  stroke(160);
  rect(0,0, screenZ, screenZ);
  popMatrix();
  //line(t.x+300, t.y+300, lastX, lastY);

  if(rot_phase == false){
  line(mouseX, mouseY, t.x+300, t.y+300);}

  noFill();
  ellipse(t.x+300, t.y+300, inchesToPixels(.05f),inchesToPixels(.05f));
  

  
    //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.3f));
  textSize(25);
  if(closeRotation){
    fill(0, 255, 0);
   }
   else{
     fill(220,20,60);
   }
  text("Rotation", width/4, 50);
   
   
   if(closeDist){
    fill(0, 255, 0);
    
    
   }
   else{
     fill(220,20,60);
   }
  text("Distance", 2*width/4, 50);
  
  
  if(closeZ){
    fill(0, 255, 0);
   }
   else{
     fill(220,20,60);
   }
  text("Size", 3*width/4, 50);
  textSize(15);
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
    if(rot_phase == true){
    float rotX = screenTransX;
    float rotY = screenTransY;
  
    if(dist(rotX, rotY, mouseX, mouseY)<inchesToPixels(6f)){
      //line(rotX, rotY, mouseX, mouseY);
      //drawArrow(rotX, rotY, mouseX, mouseY);
      screenZ = (dist(rotX, rotY, mouseX, mouseY)/1.41421356237)*2;
        
      screenRotation = getAngle(rotX, rotY, mouseX, mouseY)-45;
    }
  }
  

}


void mousePressed()
{
  if (rot_phase == true){
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;
    flag4 = true;
    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
    rot_phase = false;
  }
  else{
    lastY = mouseY;
    lastX = mouseX;
    screenTransY = lastY;
    screenTransX = lastX;
    rot_phase = true;}
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
    
      
   
}

void mouseReleased()
{

}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,screenTransX-width/2,screenTransY-height/2)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	
  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
 	println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
	
	return closeDist && closeRotation && closeZ;	
}

//utility function I include
double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }
 

float getAngle(float pX1,float pY1, float pX2,float pY2){
  return atan2(pY2 - pY1, pX2 - pX1)* 180/ PI;
}

void drawArrow(float x1, float y1, float x2, float y2) {
  float a = dist(x1, y1, x2, y2) / 50;
  pushMatrix();
  translate(x2, y2);
  rotate(atan2(y2 - y1, x2 - x1));
  triangle(- a * 2 , - a, 0, 0, - a * 2, a);
  popMatrix();
  line(x1, y1, x2, y2);  
}