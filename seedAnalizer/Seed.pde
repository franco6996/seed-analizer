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
  
  // Display the Seed
  void display(int xPixelFrom, int yPixelFrom, int xPixelTo, int yPixelTo) {
    int plotWidth = xPixelTo - xPixelFrom;
    int plotHeight = yPixelTo - yPixelFrom;
    stroke(0);
    strokeWeight(2); //<>//
    noFill();
    for (int i = 0; i<=100; i++){
      value[i] = (value[i] > 4096) ? 0 : value[i];
      if (validSeed)
        stroke(0);
      else
        stroke(50);
      circle( xPixelFrom + (plotWidth/100) * i , map(value[i], 0, 4096, yPixelFrom+plotHeight, yPixelFrom),5);
    }
  }
}
