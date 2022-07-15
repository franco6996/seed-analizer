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
import grafica.*;
//import java.util.Random;
//import java.util.ArrayList;
import java.util.*;
import java.lang.Math;

// Grafica objects
GPlot plot1, plot2;

// An Array of dataFiles (.csv) to be loaded with seeds data each one
DataFile[] dataFiles;
final int dataFilesMax = 4;  // This means 4 as max files to be loaded at the same time
public int dataFileCount;  // Counts the files alredy loaded

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 680;
final int plotToY = 680;

// Define the version SW
final String swVersion = "v0.4b";

void setup() {
  size(1600, 800);
  frameRate(24);
  background(255);
  randomSeed(2);
  
  // Set title bar and icon for Windows app
  PImage titlebaricon = loadImage("icon.png"); 
  if (titlebaricon != null){
    surface.setIcon(titlebaricon);
  }
  surface.setTitle("Seed Analizer (" + swVersion + ")" ); 
  
  dataFiles = new DataFile[dataFilesMax];
  dataFileCount = 0;
  
  plot1SetConfig();
  noLoop();
  File start1 = new File(sketchPath("")+"/*.csv"); 
  selectInput("Select a .csv file to analize", "loadData", start1);

}

void draw() {
  background(255);  // clear the previus draw
  
  // Draw the Plot
    plot1.defaultDraw();
    /*plot2.beginDraw();
    plot2.drawBackground();
    plot2.drawBox();
    plot2.drawYAxis();
    plot2.drawTitle();
    plot2.drawHistograms();
    plot2.endDraw();*/
  // Show information text arround the window
  showInfoText();
}

void showInfoText() {
  
  // Name of file selected
  textAlign(RIGHT);
  fill(0);
  //text(fileName, width-10, height-10);  // Shows the selected file in screen
  
  // Name and version of SW
  textAlign(LEFT);
  fill(0);
  text("Seed Analizer  " + swVersion , 10, height-10);
  
  /*
    // Average and Standard Deviation
    textAlign(RIGHT);
    fill(0);
    text("Mean = " + nf((float)avgMinValue,0,2) , width-80 , plotFromY+60);
    text("SDeviation = " + nf((float)sDeviation,0,2) , width-80 , plotFromY+80);
  */
}
/*
void plot2SetConfig(){    // Histogram
  ArrayList<Integer> minValueVector = new ArrayList<Integer>();
  
  // Get an array of all the min values of each valid seed
  for (Seed s : seeds) {
    int minValue = s.getValueMin();
    if (minValue>0)
      minValueVector.add(minValue);
  }
  
  // Get the average to show later in screen
  for (int x = 0 ; x < minValueVector.size() ; x++){
    avgMinValue += minValueVector.get(x);
  }
  avgMinValue /= minValueVector.size();
  
  // Get standard deviation to show in screen
  for(int x = 0 ; x < minValueVector.size() ; x++) {
    sDeviation += Math.pow( minValueVector.get(x) - avgMinValue, 2);
  }
  sDeviation = sDeviation / minValueVector.size() - 1;
  sDeviation = Math.sqrt(sDeviation);
  
  Collections.sort(minValueVector);  // Sort values of array from min to max
  int hMinValue = minValueVector.get(0);  // Get min
  int hMaxValue = minValueVector.get(minValueVector.size()-1);  // Get max
  int hClasses = (int) Math.sqrt( (double)minValueVector.size() ); // Define the quantity of classes (divisions/bins of the histogram)
  hClasses = (hClasses>20) ? 20 : hClasses; // Classes should not be greater than 20 or smaller than 3
  hClasses = (hClasses<4) ? 4 : hClasses;
  int hClassesWidth = ( hMaxValue - hMinValue ) / hClasses;  // Get the width of each bin
  int hLimitSup = hMinValue + hClassesWidth;  //  Calculate the superior limit of the first class
  
  // Prepare the points for the third plot
  float[] gaussianStack = new float[hClasses];  // This vector will store the quantity of points in each class
  int gaussianCounter = 0;  // Point counter
  
  //  Divide and add each data point to its class
  int j = 0, i = 0;
  while ( j< (hClasses-1) ){
     if ( minValueVector.get(i) > hLimitSup){
       gaussianStack[j] = i - gaussianCounter;
       gaussianCounter = i;
       j++;
       hLimitSup += hClassesWidth;
     }
     i++;
  }
  gaussianStack[j] = minValueVector.size() - gaussianCounter;
  gaussianCounter = minValueVector.size();
  
  //  Forward code represents the data in the gaussianStack vector
  GPointsArray points2 = new GPointsArray(gaussianStack.length);

  for (int l = 0; l < gaussianStack.length; l++) {
    points2.add(l + 0.5 - gaussianStack.length/2.0, gaussianStack[l]/gaussianCounter, hMinValue+l*hClassesWidth + "-" + (hMinValue+(l+1)*hClassesWidth) );
  }

  // Setup for the histogram plot 
  plot2 = new GPlot(this);
  plot2.setPos(plotFromX+plotToX+100, plotFromY);
  plot2.setDim(plotToX-plotFromX, plotToY-plotFromY);
  plot2.getTitle().setText("Seeds min values Gaussian distribution (" + str(gaussianCounter) + " points)");
  plot2.getTitle().setTextAlignment(LEFT);
  plot2.getTitle().setRelativePos(0);
  plot2.getYAxis().getAxisLabel().setText("Relative probability");
  plot2.getYAxis().getAxisLabel().setTextAlignment(RIGHT);
  plot2.getYAxis().getAxisLabel().setRelativePos(1);
  plot2.setPoints(points2);
  plot2.startHistograms(GPlot.VERTICAL);
  plot2.getHistogram().setDrawLabels(true);
  plot2.getHistogram().setRotateLabels(true);
  plot2.getHistogram().setBgColors(new color[] {
    color(0, 0, 255, 50), color(0, 0, 255, 100), 
    color(0, 0, 255, 150), color(0, 0, 255, 200)
  }
  );
  plot2.activateCentering(LEFT, GPlot.CTRLMOD);
}

void plot2AddLayers(){
  // Add layers corresponding to each dataFile that contains each valid Seed data set with each points to plot
  for (DataFile f : dataFiles) {
    f.addLayers();
  }
}*/

void plot1SetConfig() {
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX-plotFromX, plotToY-plotFromY);
  
  // Set the plot title and the axis labels
  plot1.setTitleText("Overlaping all the Seeds");
  plot1.getXAxis().setAxisLabelText("Time [ms * 10]");
  plot1.getYAxis().setAxisLabelText("ADC raw value");
  
  // Set plot1 configs
  plot1.activatePointLabels();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
} //<>//

void loadData(File selection) {
  if (selection == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "No file selected.", "Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
    System.exit(0);
  }
  String fileName = selection.getName(), fileNamePath = selection.getAbsolutePath();
  
  // Initialize the new file
  dataFiles[dataFileCount] = new DataFile( fileName, fileNamePath );
  // Add Layers of the new file selected
  dataFiles[dataFileCount].addLayers();
  // Prepare for the next file
  dataFileCount++;
  
  
  
  loop();
}

// Pressing 'n' will bring the window to select a new file to add to the plot
void keyPressed() {
  if (key == 'n') {
    noLoop();
    File start1 = new File(sketchPath("")+"/*.csv");
    selectInput("Select a .csv file to analize", "loadData", start1);
  }
}

/*
void mousePressed() {
  // Create a new row
  TableRow row = table.addRow();
  // Set the values of that row
  row.setFloat("x", mouseX);
  row.setFloat("y", mouseY);
  row.setFloat("diameter", random(40, 80));
  row.setString("name", "Blah");

  // If the table has more than 10 rows
  if (table.getRowCount() > 10) {
    // Delete the oldest row
    table.removeRow(0);
  }

  // Writing the CSV back to the same file
  saveTable(table, "data/data.csv");
  // And reloading it
  loadData();
}*/
