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

// An Array of Bubble objects
Seed[] seeds;

// A Table object
Table table;

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 800;
final int plotToY = 800;

void setup() {
  size(800, 800);
  background(255);
  loadData();
  // Create a new plot and set its position on the screen
  GPlot plot = new GPlot(this);
  plot.setPos(25, 25);
  // Set the plot title and the axis labels
  plot.setTitleText("Analizing Seeds from 'data.csv'");
  plot.getXAxis().setAxisLabelText("time");
  plot.getYAxis().setAxisLabelText("cuentas");
  // Display all seeds
  for (Seed s : seeds) {
    int[] seedValues = s.valArray();
    // Prepare the points for the plot
    int nPoints = seedValues.length;  //number of value points in cvs file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      points.add(i, seedValues[i]);
    }
    plot.setPoints(points);
  }
    
  // Draw it
  plot.defaultDraw();
}

void draw() {
  
  textAlign(LEFT);
  fill(0);
  text("Seed Analizer v0.1b", 10, height-10);
  while(true);
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
