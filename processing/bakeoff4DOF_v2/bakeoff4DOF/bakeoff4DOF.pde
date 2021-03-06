import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0;
int trialCount = 4; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean drag_phase = false;
boolean start_game = false;
boolean flag3 = true;
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


  background(60); //background is dark grey
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

  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  Target t = targets.get(trialIndex);
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));
  fill(204, 255, 255); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  popMatrix();
boolean closeDist = dist(t.x,t.y,screenTransX-width/2,screenTransY-height/2)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  if(start_game == false){
    translate(width/2, height/2);
    screenTransX = 0;
    screenTransY = 0;
    
  }
  
  if(flag3 && drag_phase == false && mousePressed && dist(lastX, lastY, mouseX, mouseY)<inchesToPixels(0.5f)){
    drag_phase = true;
    start_game= true;
    flag4=false;
    println("asdasdhiahfsfmiosd");
  }
  
  if(flag3 && drag_phase){
    screenTransY = mouseY;
    screenTransX = mouseX;
  }
  
  if (flag3 && drag_phase == true && mousePressed){
    lastY = mouseY;
    lastX = mouseX;
    screenTransY = lastY;
    screenTransX = lastX;
    println("drag done");
    drag_phase = false;
  }

  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  fill(255,255,255,50);
  int op = 0;
  if(closeDist == true){
    op += 50;
  }
  if(closeRotation == true){
    op += 20;
  }
  if(closeZ == true){
    op += 25;
  }
  fill(0,255,0,op);
  if(checkForSuccess()==true){
    fill(0, 255, 0);
  }
  strokeWeight(3f);
  stroke(160);
  rect(0,0, screenZ, screenZ);
  popMatrix();
  //line(t.x+300, t.y+300, lastX, lastY);
  drawArrow(lastX, lastY, t.x+300, t.y+300);

  
  
  noFill();
  ellipse(t.x+300, t.y+300, inchesToPixels(.05f),inchesToPixels(.05f));
  

  
    //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  print(flag3);
  print(drag_phase);
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
    if(flag3 == false){
    float rotX = screenTransX;
    float rotY = screenTransY;
  
    if(dist(rotX, rotY, mouseX, mouseY)<inchesToPixels(3f)){
      line(rotX, rotY, mouseX, mouseY);
      drawArrow(rotX, rotY, mouseX, mouseY);
      screenZ = dist(rotX, rotY, mouseX, mouseY);
        
      screenRotation = getAngle(rotX, rotY, mouseX, mouseY);
    }
  }
  


  
  
  
  
  ////upper left corner, rotate counterclockwise
  //text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  //if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenRotation--;

  ////upper right corner, rotate clockwise
  //text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  //if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenRotation++;

  ////lower left corner, decrease Z
  //text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  //if (mousePressed && dist(0, height, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenZ-=inchesToPixels(.02f);

  ////lower right corner, increase Z
  //text("+", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  //if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenZ+=inchesToPixels(.02f);

  ////left middle, move left
  //text("left", inchesToPixels(.2f), height/2);
  //if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransX-=inchesToPixels(.02f);

  //text("right", width-inchesToPixels(.2f), height/2);
  //if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransX+=inchesToPixels(.02f);
  
  //text("up", width/2, inchesToPixels(.2f));
  //if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransY-=inchesToPixels(.02f);
  
  //text("down", width/2, height-inchesToPixels(.2f));
  //if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchesToPixels(.5f))
  //  +=inchesToPixels(.02f);
}


void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
   if (flag3 == false){
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
    flag3 = true;
    drag_phase = false;
  }
}

void mouseReleased()
{
  if(drag_phase==false && flag4==false){
    flag3 = false;
  }
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