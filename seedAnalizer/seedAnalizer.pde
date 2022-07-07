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
// Grafica objects
GPlot plot1;

// An Array of Bubble objects
Seed[] seeds;

// A Table object
Table table;

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 700;
final int plotToY = 700;

void setup() {
  size(800, 800);
  background(255);
  randomSeed(2);
  // Load the seed data from .csv file
  loadData();
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX-plotFromX, plotToY-plotFromY);
  // Set the plot title and the axis labels
  plot1.setTitleText("Analizing Seeds from 'data.csv'");
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
  plot1.moveHorizontalAxesLim(100);
  
}

void draw() {
  // Draw it
  plot1.defaultDraw();
  
  textAlign(LEFT);
  fill(0);
  text("Seed Analizer v0.1b", 10, height-10);
  //while(true);
}

void loadData() {
  // Load CSV file into a Table object
  // "header" option indicates the file has a header row
  table = loadTable("data.csv", "header");

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
