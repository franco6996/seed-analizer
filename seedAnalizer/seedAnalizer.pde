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

// An Array of Bubble objects
Seed[] seeds;

// A Table object
Table table;
public boolean plotDataLoaded;
public String fileNamePath = "", fileName = "";
public double avgMinValue, sDeviation;

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 680;
final int plotToY = 680;

// Define the version SW
final String swVersion = "v0.2b";

void setup() {
  size(1600, 800);
  frameRate(24);
  background(255);
  randomSeed(2);
  
  // Set title bar and icon for Windows app
  PImage titlebaricon = loadImage("icon.png"); 
  if (titlebaricon != null){
    //javax.swing.JOptionPane.showMessageDialog(null, "I'm over here with this error: ", "Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
    surface.setIcon(titlebaricon);
  }
  surface.setTitle("Seed Analizer (" + swVersion + ")" ); 
  
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
  text("Seed Analizer  " + swVersion , 10, height-10);
  
  if (plotDataLoaded == true) {
    // Average and Standard Deviation
    textAlign(RIGHT);
    fill(0);
    text("Mean = " + nf((float)avgMinValue,0,2) , width-80 , plotFromY+60);
    text("SDeviation = " + nf((float)sDeviation,0,2) , width-80 , plotFromY+80);
  }
}

void loadPlot2Data(){    // Histogram
  ArrayList<Integer> minValueVector = new ArrayList<Integer>();
  
  // Obtengo array the todos los valores minimos de Seeds
  for (Seed s : seeds) {
    int minValue = s.getValueMin();
    if (minValue>0)
      minValueVector.add(minValue);
  }
  
  // Obtengo promedio para mostrar en pantalla
  for (int x = 0 ; x < minValueVector.size() ; x++){
    avgMinValue += minValueVector.get(x);
  }
  avgMinValue /= minValueVector.size(); //<>//
  
  // Obtengo desviación estandar de una muestra
  for(int x = 0 ; x < minValueVector.size() ; x++) { //<>//
    sDeviation += Math.pow( minValueVector.get(x) - avgMinValue, 2);
  }
  sDeviation = sDeviation / minValueVector.size() - 1;
  sDeviation = Math.sqrt(sDeviation);
  
  Collections.sort(minValueVector);  // Ordeno vector de min a max
  int hMinValue = minValueVector.get(0);  // Obtengo min
  int hMaxValue = minValueVector.get(minValueVector.size()-1);  // Obtengo max
  int hClasses = (int) Math.sqrt( (double)minValueVector.size() ); // Defino cantidad de clases (divisiones de histograma)
  hClasses = (hClasses>20) ? 20 : hClasses; // Por regla no se recomienda mayor a 20 clases ni menor a 3
  int hClassesWidth = ( hMaxValue - hMinValue ) / hClasses;  // Ancho de cada clase
  int hLimitSup = hMinValue + hClassesWidth;  //  Limite superior de la primera clase - variable que va creciendo al pasar de clase
  
  // Prepare the points for the third plot
  float[] gaussianStack = new float[hClasses];  // Vector que guarda la frecuencia de puntos en cada clase //<>//
  int gaussianCounter = 0;  // Contador de puntos totales de datos
  
  //  Contador de puntos correspondientes a cada clase
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
  
  //  A partir de aquí el código realiza la representación gráfica de las clases del histograma
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

void loadPlot1Data() {
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX-plotFromX, plotToY-plotFromY);
  // Set the plot title and the axis labels
  plot1.setTitleText("Overlaping Seeds from '" + fileName + "'");
  plot1.getXAxis().setAxisLabelText("Time [ms * 10]");
  plot1.getYAxis().setAxisLabelText("ADC raw value");
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
  if (selection == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "No file selected", "Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
    System.exit(0);
  }
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
