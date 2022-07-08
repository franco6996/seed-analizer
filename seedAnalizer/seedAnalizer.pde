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
import java.util.Random;
import java.util.ArrayList;

// Grafica objects
GPlot plot1, plot2;

// An Array of Bubble objects
Seed[] seeds;

// A Table object
Table table;
public boolean plotDataLoaded;
public String fileNamePath = "", fileName = "";

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 680;
final int plotToY = 680;

void setup() {
  size(1600, 800);
  background(255);
  randomSeed(2);
  
  plotDataLoaded = false;
  selectInput("Select a .csv file to analize", "loadData");
  
}

void draw() {
  background(255);  // clear the previus draw
  
  // Draw the Plot
  if (plotDataLoaded == true) {
    plot1.defaultDraw();
    plot2.beginDraw();
    plot2.drawBackground();
    plot2.drawBox();
    plot2.drawYAxis();
    plot2.drawTitle();
    plot2.drawHistograms();
    plot2.endDraw();
  }
  // Show information text arround the window
  showInfoText();
}

void showInfoText() {
  
  // Name of file selected
  textAlign(RIGHT);
  fill(0);
  text(fileName, width-10, height-10);  // Shows the selected file in screen
  
  // Name and version of SW
  textAlign(LEFT);
  fill(0);
  text("Seed Analizer v0.1b", 10, height-10);
}

void loadPlot2Data(){    // Histogram
  ArrayList<Integer> minValueVector = new ArrayList<Integer>();
  
  // Obtengo array the todos los valores minimos de Seeds
  for (Seed s : seeds) {
    int minValue = s.getValueMin();
    if (minValue>0)
      minValueVector.add(minValue);
  }
  
  // Prepare the points for the third plot
  float[] gaussianStack = new float[40];  // Divisions of the Histogram //<>//
  int gaussianCounter = 0;  // Points counter
  int index = 0;
  
  for (int j = 100; j < 4000; j+=100) {
    for (int i = 0; i < minValueVector.size(); i++) {
      if (minValueVector.get(i) < j && minValueVector.get(i) > (j-100) ) {
        gaussianStack[index]++;
        gaussianCounter++;
      }
    }
    index++;
  }
  
  GPointsArray points2 = new GPointsArray(gaussianStack.length); //<>//

  for (int i = 0; i < gaussianStack.length; i++) {
    points2.add(i + 0.5 - gaussianStack.length/2.0, gaussianStack[i]/gaussianCounter, i*100 + "-" + (i+1)*100);
  }

  // Setup for the third plot 
  plot2 = new GPlot(this);
  plot2.setPos(plotFromX+plotToX+100, plotFromY);
  plot2.setDim(plotToX-plotFromX, plotToY-plotFromY);
  //plot2.setYLim(-0.02, 0.45);
  //plot2.setXLim(-5, 5);
  plot2.getTitle().setText("Gaussian distribution (" + str(gaussianCounter) + " points)");
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

void loadPlot1Data() {
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX-plotFromX, plotToY-plotFromY);
  // Set the plot title and the axis labels
  plot1.setTitleText("Analizing Seeds from '" + fileName + "'");
  plot1.getXAxis().setAxisLabelText("time");
  plot1.getYAxis().setAxisLabelText("cuentas");
  // Add one layer for every seed
  for (Seed s : seeds) {
    s.displayLayer();
  }
  // Set plot1 configs
  plot1.activatePointLabels();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
  
  
}

void loadData(File selection) {
  // Get the name of the selected file
  fileNamePath = selection.getAbsolutePath();
  fileName = selection.getName();
  
  // Load CSV file into a Table object
  // "header" option indicates the file has a header row
  table = loadTable(fileNamePath, "header");
  
  // The size of the array of Bubble objects is determined by the total number of rows in the CSV
  seeds = new Seed[table.getRowCount()]; 

  // You can access iterate over all the rows in a table
  int rowCount = 0;
  for (TableRow row : table.rows()) {
    // You can access the fields via their column name (or index)
    int seedNumber = row.getInt("#");               //get the item number
    int seedTimeStamp = row.getInt("timeStamp");    //get the timeStamp
    
    int[] seedValueArray = new int[101];
    for(int i = 0; i<101; i++){
      seedValueArray[i] = row.getInt(str(i));           //get an array of the 100 values
    }
    
    // Make a Seed object out of the data read
    seeds[rowCount] = new Seed(seedNumber, seedTimeStamp, seedValueArray);
    rowCount++;
  }
  
  // Load the new data to the plot
  loadPlot1Data();
  loadPlot2Data();
  
  // Set the flag that mark if its ready to plot
  plotDataLoaded = true;
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
