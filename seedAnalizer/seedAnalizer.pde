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
final int dataFilesMax = 6;  // This means 4 as max files to be loaded at the same time
public int dataFileCount;  // Counts the files alredy loaded
String[] column_compare = { "#", "timeStamp", "0"}; // format of .csv file to compare and validated added files.

// Predefined Plot Colors= {  R,   G,   B,Yell,Cyan,Mage,}
int[] predefinedColorR = {  255,   0,   0, 255,   0, 255,};
int[] predefinedColorG = {    0, 255,   0, 255, 255,   0,};
int[] predefinedColorB = {    0,   0, 255,   0, 255, 255,};

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 680;
final int plotToY = 680;

// Define the version SW
final String swVersion = "v0.4b";

void setup() {
  size(1600, 800);
  frameRate(30);
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
  plot2SetConfig();
  
  noLoop();
  File start1 = new File(sketchPath("")+"/*.csv"); 
  selectInput("Select a .csv file to analize", "loadData", start1);

}

void draw() {
  background(255);  // clear the previus draw
  
  // Draw the Plot
    plot1.defaultDraw();
    plot2.beginDraw();
    plot2.drawBackground();
    plot2.drawBox();
    plot2.drawYAxis();
    plot2.drawTitle();
    plot2.drawHistograms();
    plot2.endDraw();
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

void plot2SetConfig(){    // Histogram
  // Setup for the histogram plot 
  plot2 = new GPlot(this);
  plot2.setPos(plotFromX+plotToX+100, plotFromY);
  plot2.setDim(plotToX-plotFromX, plotToY-plotFromY);
  plot2.getTitle().setText("Seeds delta values Gaussian distribution");
  plot2.getTitle().setTextAlignment(LEFT);
  plot2.getTitle().setRelativePos(0);
  plot2.getYAxis().getAxisLabel().setText("Relative probability");
  plot2.getYAxis().getAxisLabel().setTextAlignment(RIGHT);
  plot2.getYAxis().getAxisLabel().setRelativePos(1);
  //plot2.setPoints(points2);
  
  plot2.activateCentering(LEFT, GPlot.CTRLMOD);
  
}

void plot2Draw() {
  // Remove all layers to redraw all the histograms
  for (int x = 0 ; x < dataFileCount ; x++) {
    dataFiles[x].removeHistogramLayers ();
  }
  
  // Get info of all the files necesaries to configure the plot histogram
  int[] pointsInfo = new int[3];
  int hMinValue = 0xFFFFFF, hMaxValue = 0, hPoints = 0;
  for (int x = 0 ; x <= dataFileCount ; x++) {
    pointsInfo = dataFiles[x].getDeltaValuesInfo();  // get { numberOfDeltaValues , minDeltaValue, maxDeltaValue}
    hPoints += pointsInfo[0];
    if ( pointsInfo[1] < hMinValue)
      hMinValue = pointsInfo[1];
    if ( pointsInfo[2] > hMaxValue)
      hMaxValue = pointsInfo[2];
  }
  
  // Calculate histogram bin count and more
  int hClasses = (int) Math.sqrt( (double)hPoints ); // Define the quantity of classes (divisions/bins of the histogram)
  hClasses = (hClasses>20) ? 20 : hClasses; // Classes should not be greater than 20 or smaller than 3
  hClasses = (hClasses<4) ? 4 : hClasses;
  int hClassesWidth = (int)( (float)( (float)( (float)( hMaxValue - hMinValue ) / hClasses) +0.5) );  // Get the width of each bin
  int hLimitSup = hMinValue + hClassesWidth;  //  Calculate the superior limit of the first class
  
  // Add layers of each file
  for (int x = 0 ; x <= dataFileCount ; x++) {
    dataFiles[x].addHistogramLayers (hClasses, hClassesWidth, hLimitSup, hMaxValue, hMinValue); //<>//
  }
  
  plot2.startHistograms(GPlot.VERTICAL);
  plot2.getHistogram().setDrawLabels(true);
  plot2.getHistogram().setRotateLabels(true);
  plot2.getHistogram().setBgColors(new color[] {
    color(0, 0, 255, 50), color(0, 0, 255, 100), 
    color(0, 0, 255, 150), color(0, 0, 255, 200)
  }
  );
  
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
  
  // Set plot1 configs
  plot1.activatePointLabels();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
}

void loadData(File selection) {
  if (selection == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "No file selected.", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
    return;
  }
  String fileName = selection.getName(), fileNamePath = selection.getAbsolutePath();
  
  // Initialize the new file
  dataFiles[dataFileCount] = new DataFile( fileName, fileNamePath );
  
  // Add Layers of the new file selected
  if ( dataFileCount == 1) {        // if enter the multiple file mode, redraw the first plot
    dataFiles[0].removeLayers();    //  so the color indicates different files
    dataFiles[0].addLayers();
  }
  dataFiles[dataFileCount].addLayers();
  
  
  plot2Draw();
  // Prepare for the next file
  dataFileCount++;
  
  
  
  loop();
}

// Pressing 'n' will bring the window to select a new file to add to the plot
void keyPressed() {
  if (key == 'n') {
    if ( dataFileCount >= dataFilesMax ) {
      javax.swing.JOptionPane.showMessageDialog(null, "Max number of files reached.", "File Input Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
    } else {
      noLoop();
      File start1 = new File(sketchPath("")+"/*.csv");
      selectInput("Select a .csv file to analize", "loadData", start1);
    }
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
