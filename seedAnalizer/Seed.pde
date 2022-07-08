// A Seed class

class Seed {
  int item, timeStamp;
  int[] value = new int[101];
  boolean validSeed;
  
  // Create  the Seed
  Seed(int item_, int timeStamp_, int[] value_) {
    item = item_;            // # of seed
    timeStamp = timeStamp_;  // time stamp of min value of signal
    value = value_;          /* array of 101 elements, wich contains the value of ADC every 100us.
                                value[50] corresponds to the min of the signal */
    validSeed = true;
  }
  
  // Prepare to Display the values from one Seed
  void displayLayer() {
    int nPoints = value.length;                       // number of value points in cvs file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      if (value[i] > 0)
      points.add(i, value[i]);
    }
    plot1.addLayer(str(item), points);     // add points to the layer
    // Set layer Color
    int randomColorR = int(random(10,255));
    int randomColorG = int(random(10,255));
    int randomColorB = int(random(10,255));
    plot1.getLayer(str(item)).setLineColor(color(randomColorR, randomColorG, randomColorB));
    plot1.getLayer(str(item)).setPointColor(color(randomColorR, randomColorG, randomColorB));
  }
  
  int getValueMin() {
    if (validSeed)
      return value[50];
    else
      return -1;
  }
}
