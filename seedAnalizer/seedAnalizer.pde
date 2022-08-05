/**
 * Loading Tabular Data
 *
 * Here is what the CSV looks like:
 *
   #,timeStamp,0,1,2,3,...,100
   0,103,2000,2300,2200,2100,...,2050
   1,137,1500,1600,1700,1650,...,1680
   2,235,1800,1830,1790,2000,...,3500
   3,179,50,150,200,400,...,350
 */

// Libraries
import processing.javafx.*;
import grafica.*;
//import java.util.Random;
//import java.util.ArrayList;
import java.util.*;
import java.lang.Math;

// Grafica objects
GPlot plot1, plot2, plot3;

// An Array of dataFiles (.csv) to be loaded with seeds data each one
DataFile[] dataFiles;
final int dataFilesMax = 6;  // This means 4 as max files to be loaded at the same time
public int dataFileCount;  // Counts the files alredy loaded
String[] column_compare = { "#", "timeStamp", "0"}; // format of .csv file to compare and validated added files.
public int seedCounter = 0;
public float hMaxProbValue = 0;
public boolean hNoData = false;

// Predefined Plot Colors= {  R,   G,   B,Yell,Cyan,Mage,}
int[] predefinedColorR = {  255,   0,   0, 255,   0, 255,};
int[] predefinedColorG = {    0, 200,   0, 210, 255,   0,};
int[] predefinedColorB = {    0,   0, 255,   0, 255, 255,};

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 680;
final int plotToY = 680;

// Define the version SW
final String swVersion = "0.8";
boolean debug = true;

void settings() {
  size(1600, 800, PConstants.FX2D );
  //smooth(4);
}

void setup() {
  
  frameRate(30);
  background(255);
  randomSeed(99);
  
  // Set title bar and icon for Windows app
  PImage titlebaricon = loadImage("icon.png"); 
  if (titlebaricon != null){
    surface.setIcon(titlebaricon);
  }
  surface.setTitle("Seed Analizer (v" + swVersion + ")" ); 
  
  // Check for new Updates
  checkUpdates();
  
  dataFiles = new DataFile[dataFilesMax];
  dataFileCount = 0;
  
  plot1SetConfig();
  plot2SetConfig();
  plot3SetConfig();
  
  noLoop();
  File start1 = new File(sketchPath("")+"/*.csv"); 
  selectInput("Select a .csv file to analize", "loadData", start1);
  
  PFont font = createFont("Consolas", 12);
  textFont(font);
}

public int plotMode = 0;
void draw() {
  background(255);  // clear the previus draw
  
  // Draw the Plots
  switch (plotMode) {
    
    case 1:   // Timeline view
      plot3.beginDraw();
      plot3.drawBackground();
      plot3.drawBox();
      plot3.drawYAxis();
      plot3.drawXAxis();
      plot3.drawTitle();
      plot3.drawPoints();
      plot3.drawLines();
      plot3.drawLabels();
      plot3.endDraw();
    break;
    
    default:  // Default view
      //plot1.defaultDraw();
      plot1.beginDraw();
      plot1.drawBackground();
      plot1.drawBox();
      plot1.drawYAxis();
      plot1.drawXAxis();
      plot1.drawTitle();
      plot1.drawPoints();
      plot1.drawLines();
      plot1.drawLabels();
      plot1.endDraw();
      // Histogram plot
      plot2.beginDraw();
      plot2.drawBackground();
      plot2.drawBox();
      plot2.drawYAxis();
      plot2.drawGridLines(GPlot.HORIZONTAL);
      plot2.setGridLineWidth(0.5);
      plot2.drawTitle();
      plot2.drawHistograms();
      plot2.endDraw();
      // Draw probabilistic info to the right
      drawMath();
    break;
  }
  // Show information text arround the window
  showInfoText();
}

void drawMath() {
  textAlign(RIGHT);
  int positionX = width-20;
  int positionY = 40;
  int wideForm = 160;
  int heightForm = 70;
  
  for (int x = 0; x < dataFileCount ; x++ ) {
    //Drawing one rectangle
    noFill();
    stroke(200);
    rect(positionX, positionY, -wideForm, heightForm);
    line(positionX, positionY+20, positionX-wideForm, positionY+20);
    fill(0);
    textAlign(CENTER);
    // Getting the corresponding color
    if ( dataFileCount > 1 )
      fill( predefinedColorR[ x ], predefinedColorG[ x ], predefinedColorB[ x ]);
    // Get Name of file
    String fn = dataFiles[x].getFileName();
    // Cut name if too long and take away the '.csv'
    fn = fn.substring(0,fn.length()-4 );
    if ( fn.length() > 21){
      fn = fn.substring(0,19);
      fn += "...";      
    }
    text( fn, positionX - wideForm/2, positionY+15);
    // Write the math
    fill(0);
    float avg = dataFiles[x].getAvgDeltaValue();
    float sDeviation = dataFiles[x].getSDeviation();
    textAlign(RIGHT);
    if ( avg == -1)
      text( "Average Delta: --" ,positionX-5, positionY+40);
    else
      text( "Average Delta: " + nf(avg,0,2),positionX-5, positionY+40);
    if (sDeviation == -1 )
      text( "SD: --" , positionX-5, positionY+60);
    else
      text( "SD: " +nf(sDeviation,0,2), positionX-5, positionY+60);
    
    // For the next loop
    positionY += heightForm + 20;
  }
}

int helpNumber = 0;
int time = 0;
void showInfoText() {

  if ( millis() - time > 5000) {
    helpNumber ++;
    if ( helpNumber > 3 )
      helpNumber = 0;
    time = millis();
  }
  textAlign(LEFT);
  fill(0);
  switch ( helpNumber ) {
    case 1:
      text("Press 'LEFT MOUSE' to highlight a Point in the plot", 10, height-10);
    break;
    case 2:
      text("Press 'RIGHT MOUSE' to set a Point as invalid", 10, height-10);
    break;
    case 3:
      text("Press 'r' to center the view", 10, height-10);
    break;
    default:
      text("Press 'n' to add a new file to compare", 10, height-10);
    break;
  }
  
  // Show FPS Counter if i'm in debug
  textAlign(LEFT);
  fill(150);
  if ( debug )
    text("FPS: " + nf(frameRate, 0, 2) , 10 , 10);
  
  // Update title seeds number
  if( dataFileCount > 0 )
    plot1.setTitleText("Overlaping " + str( seedCounter) + " Seeds");
  
  // Number of files selected
  textAlign(RIGHT);
  fill(0);
  text( dataFileCount +" file/s loaded.", width-10 , height-10);
  
  // No histogram data
   if ( hNoData ) { 
    textAlign(CENTER);
    textSize(16);
    fill(0);
    float[] pos = new float[2];
    pos = plot2.getPos();
    float[] dim = new float[2];
    dim = plot2.getDim();
    float x = pos[0] + (dim[0] / 2), y = pos[1] + (dim[1] / 2);
    text("Not enough data to plot.", x + 60, y);
    textSize(12);
   }
}

void loadingText() {
  fill(0);
  rect(width/2-100, height/2-40, 195, 60);
  
  textAlign(CENTER);
  fill(255);
  textSize(32);
  text("Loading...", width/2 , height/2);
  textSize(12);
}

void plot2SetConfig(){    // Histogram
  // Setup for the histogram plot 
  plot2 = new GPlot(this);
  plot2.setPos(plotToX+75, plotFromY);
  plot2.setDim( (plotToX-plotFromX) * 0.85 , plotToY-plotFromY);
  plot2.getTitle().setText("Seeds delta values Gaussian distribution");
  plot2.getTitle().setTextAlignment(LEFT);
  plot2.getTitle().setRelativePos(0);
  plot2.getYAxis().getAxisLabel().setText("Relative probability");
  plot2.getYAxis().getAxisLabel().setTextAlignment(RIGHT);
  plot2.getYAxis().getAxisLabel().setRelativePos(1);
  plot2.getYAxis().setLim(new float[] { 0, 1});
  plot2.setVerticalAxesNTicks( 6);
  plot2.activateCentering(LEFT, GPlot.CTRLMOD);
  plot2.activatePointLabels( LEFT, GPlot.NONE);
  
}

void plot2Draw() {  
  // Get info of all the files necesaries to configure the plot histogram
  int[] pointsInfo = new int[3];
  int hMinValue = 0xFFFFFF, hMaxValue = 0, hPoints = 0;
  for (int x = 0 ; x < dataFileCount ; x++) {
    pointsInfo = dataFiles[x].getDeltaValuesInfo();  // get { numberOfDeltaValues , minDeltaValue, maxDeltaValue}
    hPoints += pointsInfo[0];
    if ( pointsInfo[1] < hMinValue && pointsInfo[0] > 0)
      hMinValue = pointsInfo[1];
    if ( pointsInfo[2] > hMaxValue && pointsInfo[0] > 0)
      hMaxValue = pointsInfo[2];
  }
  
  // If too little data
  if ( hPoints < 3 )  {
    hNoData = true;
    return;
  }
  hNoData = false;
  
  // Calculate histogram bin count and more
  int hClasses = (int) Math.sqrt( (double)hPoints ); // Define the quantity of classes (divisions/bins of the histogram)
  hClasses = (hClasses>20) ? 20 : hClasses; // Classes should not be greater than 20 or smaller than 3
  hClasses = (hClasses<4) ? 4 : hClasses;
  int hClassesWidth = ceil( (float)(  (float)( hMaxValue - hMinValue ) / hClasses) );  // Get the width of each bin
  int hLimitSup = hMinValue + hClassesWidth;  //  Calculate the superior limit of the first class
  
  // Add layers of each file
  for (int x = 0 ; x < dataFileCount ; x++) {
    dataFiles[x].addHistogramLayers (hClasses, hClassesWidth, hLimitSup, hMaxValue, hMinValue);
  }
  
  //Set Axis Labels
   GPointsArray points = new GPointsArray(hClasses+1);
  for (int l = 0; l <= hClasses; l++) {
    points.add(l+0.5 , 0, str(hMinValue+l*hClassesWidth) );
  }
  plot2.setPoints(points);
  
  // Plot
  plot2.startHistograms(GPlot.VERTICAL);
  plot2.getHistogram().setDrawLabels(true);
  plot2.getHistogram().setRotateLabels(false);
  
  // Set layers colors
  for (int x = 0 ; x < dataFileCount ; x++) {
    dataFiles[x].setHistogramColors ();
  }
  
  float max = 0.1;
  while (hMaxProbValue > max) {
    max += 0.05;
  }
  int divisions = 5;
  if (max > 0.5)
    divisions = 10;
  float[] ticks = new float[divisions+1];
  ticks[0] = 0;
  for ( int i = 1; i <= divisions ; i++){
    float aux = (max / divisions) * i;
    aux = round( aux * 100);
    aux /= 100;
    ticks [i] = aux;
  }
  plot2.setVerticalAxesTicks( ticks );
  
  // Get an array of all the min values of each valid seed
  
  // Get the average to show later in screen
  
  // Get standard deviation to show in screen
}

void plot1SetConfig() {
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX-plotFromX, plotToY-plotFromY);
  
  // Set the plot title and the axis labels
  plot1.setTitleText("Overlaping all the Seeds");
  plot1.getXAxis().setAxisLabelText("Time [ms * 10]");
  plot1.getYAxis().setAxisLabelText("ADC raw value");
  
  plot1.getYAxis().setLim(new float[] { 0, 4100});
  plot1.getYAxis().setNTicks( 10);
  plot1.getXAxis().setLim(new float[] { 0, 100});
  plot1.getXAxis().setNTicks( 10);
  
  // Set plot1 configs
  plot1.activatePointLabels();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
}

void plot3SetConfig() {
  // Create a new plot and set its position on the screen
  plot3 = new GPlot(this);
  plot3.setPos(plotFromX, plotFromY);
  plot3.setDim( plotToX*2-plotFromX+100, plotToY-plotFromY);
  
  // Set the plot title and the axis labels
  plot3.setTitleText("Seeds Timeline Representation");
  plot3.getXAxis().setAxisLabelText("Time [ms * 10]");
  plot3.getYAxis().setAxisLabelText("ADC raw value");
  
  plot3.getYAxis().setLim(new float[] { 0, 4100});
  plot3.getYAxis().setNTicks( 10);
  plot3.getXAxis().setNTicks( 10);
  
  // Set plot1 configs
  plot3.activatePointLabels();
  plot3.activateZooming(1.2, CENTER, CENTER);
  plot3.activatePanning();
}

void plot3Draw() {

}

void loadData(File selection) {
  if (selection == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "No file selected.", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
    return;
  }
  String fileName = selection.getName(), fileNamePath = selection.getAbsolutePath();
  loadingText();
  // Initialize the new file
  dataFiles[dataFileCount] = new DataFile( fileName, fileNamePath );
  
  // Add Layers of the new file selected
  if ( dataFileCount == 1) {        // if enter the multiple file mode, redraw the first plot
    dataFiles[0].removeLayers();    //  so the color indicates different files
    dataFiles[0].addLayers();
  }
  dataFiles[dataFileCount].addLayers();
  
  // Remove all histogram layers to redraw it
  for (int x = 0 ; x < dataFileCount ; x++) {
    dataFiles[x].removeHistogramLayers ();
  }
  
  // Prepare for the next file
  dataFileCount++;
  
  // Draw histogram for all files
  plot2Draw();
  
  // To update title seeds number and calculate probabilistic math
  seedCounter = 0;
  for (int x = 0 ; x < dataFileCount ; x++) {
    seedCounter += dataFiles[x].getValidSeeds ();
    dataFiles[x].calcSDeviation();
  }
  
  loop();
}

void rightMouseFunction() {
  // Get an array of the near layers to mouse
  ArrayList<String> layerNames = new ArrayList<String>();
  
  for (int x = 0 ; x < dataFileCount ; x++) {
    ArrayList<String> lns = dataFiles[x].getNearLayerPointAt ( mouseX, mouseY);
    if ( lns != null )
      layerNames.addAll(lns);
  }
  
  // Break if no point or too many are close.
  if ( layerNames.size() == 0 )
    return;
  if ( layerNames.size() > 3 )
    return;
  // set the seeds of the selected layers as invalid and remove it from the plot
  for ( int x = 0 ; x < layerNames.size() ; x++ ) {
    // Trims the layerName array into the file to access and the item to put as invalid.
    String ln = layerNames.get(x);
    int indexOf = ln.indexOf(">");
    String fi = ln.substring( indexOf-1 , indexOf );  // file index 
    String sn = ln.substring( indexOf + 1 );  // seed item
    int fiN = Integer.valueOf(fi);
    int snN = Integer.valueOf(sn);
    // Set seed as invalid
    dataFiles[ fiN ].setSeedAsInvalid( snN );
    plot1.removeLayer(ln);
    
    // If the highlighted seed was the wanted to put as invalid
    if ( ln.equals(lastHighlightedLayer) )
      lastHighlightedLayer = null;
  }
  
  // Remove all histogram layers to redraw it
  for (int x = 0 ; x < dataFileCount ; x++) {
    dataFiles[x].removeHistogramLayers ();
  }
  
  // Draw histogram for all files
  plot2Draw();
  
  // To update title seeds number and calculate probabilistic math
  seedCounter = 0;
  for (int x = 0 ; x < dataFileCount ; x++) {
    seedCounter += dataFiles[x].getValidSeeds ();
    dataFiles[x].calcSDeviation();
  }
}

String lastHighlightedLayer;
int[] lastHighlightedColor = new int[4];

void leftMouseFunction() {
  // Get an array of the near layers to mouse
  ArrayList<String> layerNames = new ArrayList<String>();
  
  for (int x = 0 ; x < dataFileCount ; x++) {
    ArrayList<String> lns = dataFiles[x].getNearLayerPointAt ( mouseX, mouseY);
    if ( lns != null )
      layerNames.addAll(lns);
  }
  
  // Break if no point or too many are close.
  if ( layerNames.size() == 0 )
    return;
  if ( layerNames.size() > 1 )
    return;
    
  if ( lastHighlightedLayer != null) {
    plot1.getLayer(lastHighlightedLayer).setLineColor(lastHighlightedColor[0]);
    plot1.getLayer(lastHighlightedLayer).setPointColor(lastHighlightedColor[0]);
    plot1.getLayer(lastHighlightedLayer).setLineWidth(1.0);
    plot1.getLayer(lastHighlightedLayer).setPointSize(7.0);
  }
    
  // set the seeds of the selected layers as invalid and remove it from the plot
  for ( int x = 0 ; x < layerNames.size() ; x++ ) {
    // Trims the layerName array into the file to access and the item to put as invalid.
    String ln = layerNames.get(x);
    
    int nPoints = plot1.getLayer(ln).getPoints().getNPoints();
    GPointsArray points = new GPointsArray(nPoints);  // points of layer
    points = plot1.getLayer(ln).getPoints();
    lastHighlightedColor = plot1.getLayer(ln).getPointColors();
    
    plot1.removeLayer(ln);
    
    plot1.addLayer(ln, points);
    plot1.getLayer(ln).setLineColor(color(0, 0, 0, 255));
    plot1.getLayer(ln).setPointColor(color(0, 0, 0, 255));
    plot1.getLayer(ln).setLineWidth(2.0);
    plot1.getLayer(ln).setPointSize(8.0);
    
    lastHighlightedLayer = ln;
  }
}

void resetView() {
    
    if ( lastHighlightedLayer != null ) {
      plot1.getLayer(lastHighlightedLayer).setLineColor(lastHighlightedColor[0]);
      plot1.getLayer(lastHighlightedLayer).setPointColor(lastHighlightedColor[0]);
      plot1.getLayer(lastHighlightedLayer).setLineWidth(1.0);
      plot1.getLayer(lastHighlightedLayer).setPointSize(7.0);
    }
    
    lastHighlightedLayer = null;
    
    float[] center = new float[2];
    center = plot1.getScreenPosAtValue(50, 2000);
    plot1.center (center[0],center[1]);
}


void mouseClicked() {
  
  if ( mouseButton == RIGHT) {
    rightMouseFunction();
  }
  
  if ( mouseButton == LEFT) {
    leftMouseFunction();
  }
  
}

// Pressing 'n' will bring the window to select a new file to add to the plot
void keyReleased() {
  switch (key) {
    case 'N':
      if ( dataFileCount >= dataFilesMax ) {
        javax.swing.JOptionPane.showMessageDialog(null, "Max number of files reached.", "File Input Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
      } else {
        noLoop();
        File start1 = new File(sketchPath("")+"/*.csv");
        selectInput("Select a .csv file to analize", "loadData", start1);
      }
    break;
    case 'R':
      resetView();
    break;
    case 'T':
      if (plotMode == 0) {
        plot3Draw();
        plotMode = 1;
        println(plotMode);
      }
      else {
        plotMode = 0;
      }
    break;
  }
}

// This function calls the main sketch code but with a uiScale parameter to work well on scaled displays in exported apps.
public static void main(String[] args) {
  
    System.setProperty("sun.java2d.uiScale", "1.0");
    System.setProperty("prism.allowhidpi","false");
    String[] mainSketch = concat(new String[] { seedAnalizer.class.getCanonicalName() }, args);
    PApplet.main(mainSketch);
    
}
