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
  void addLayer( String fileName_ , int dataFileIndex_) {
    String layerName = fileName_ + "." + str(dataFileIndex_) + ">" + str(item); //Conform the plot layer name as 'csvFileName.#>itemNumber'
    int nPoints = value.length;                       // number of value points in cvs file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      if (value[i] > 0)
      points.add(i, value[i]);
    }
    plot1.addLayer(layerName, points);     // add points to the layer
    // Set layer Color
    int randomColorR = int(random(10,255));
    int randomColorG = int(random(10,255));
    int randomColorB = int(random(10,255));
    plot1.getLayer(layerName).setLineColor(color(randomColorR, randomColorG, randomColorB));
    plot1.getLayer(layerName).setPointColor(color(randomColorR, randomColorG, randomColorB));
  // Remove one leyer (one seed) from the plot
  void removeLayer ( String fileName_ , int dataFileIndex_) {
    String layerName = fileName_ + "." + str(dataFileIndex_) + ">" + str(item); //Conform the plot layer name as 'csvFileName.#>itemNumber'
    plot1.removeLayer( layerName );
  }
  
  int getValueMin() {
    if (validSeed)
      return value[50];
    else
      return -1;
  }
}
