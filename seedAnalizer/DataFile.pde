class DataFile {
  // An array of Seed objects
  Seed[] seeds;
  
  Table table; // Table thats contains the file info
  boolean plotDataLoaded;  // Flag set when the dat in table is already loaded to the plot
  String fileNamePath , fileName;
  double avgDeltaValue, sDeviation;  // Average value and deviation of the  minimun value for each row of table.
  int priority;  // priority to wich file display into the plot first 
  int fileIndex; // indicate the order in wich the file was added
  
  // For data validation
  String[] column_titles;
  
  // Initialize the file
  DataFile (String file, String filePath) {
    plotDataLoaded = false; // this will be true when all seed data cointaned the file are loaded to the plot layers
    priority = dataFileCount;  // priority to wich file display into the plot first
    fileIndex = dataFileCount;
    // Get the name of the selected file
    fileNamePath = filePath;
    fileName = file;
    // Load CSV file into a Table object
    // "header" option indicates the file has a header row
    table = loadTable(fileNamePath, "header");
    // Data file validation
    try {
      java.lang.reflect.Field f = table.getClass().getDeclaredField("columnTitles");
      f.setAccessible(true);
      column_titles = (String[]) f.get(table);
      for (int i = 0; i<column_compare.length; i++ ) {
        if ( ! column_titles[i].equals(column_compare[i]) ) {
          javax.swing.JOptionPane.showMessageDialog(null, "It seems that the .csv file format is incorrect.", 
                                                    "File Input Error", javax.swing.JOptionPane.ERROR_MESSAGE);
          System.exit(0);
        }
      }
    } 
    catch (Exception exc) {
      exc.printStackTrace();
    }
    
    // At this point i supouse that the file loaded is valir and not corrupt
    
    // The size of the array of Seed objects is determined by the total number of rows in the CSV
    seeds = new Seed[table.getRowCount()]; 
    
    // You can access iterate over all the rows in a table
    int rowCount = 0;
    for (TableRow row : table.rows()) {
      // You can access the fields via their column name (or index)
      int seedNumber = row.getInt("#");               //get the item number
      int seedTimeStamp = row.getInt("timeStamp");    //get the timeStamp
      
      int[] seedValueArray = new int[101];
      for(int i = 0; i<101; i++){
        seedValueArray[i] = row.getInt(str(i));           //get an array of the 101 values, the 50th its supoused to be the min value of each row
      }
      // Make a Seed object out of the data read
      seeds[rowCount] = new Seed(seedNumber, seedTimeStamp, seedValueArray);
      rowCount++;
    }
    
  }
  
  // Returns the name of the original file loaded to this dataFile object
  String getFileName () {
    return fileName;
  }
  
  // Returns the average of all the delta values in file.
  double calcAvgDeltaValue () {
    int delta, counter = 0;
    double avg = 0;
    
    for (Seed s : seeds) {
      delta = s.getDeltaV();
      if (delta >=0 ){
        avg += delta; 
        counter++;
      }
    }
    if ( counter == 0 )
      avgDeltaValue = -1;
    else {
      avg /= counter;
      avgDeltaValue = avg;
    }
    return avgDeltaValue;
  }
  
  float getAvgDeltaValue () {
   return (float)avgDeltaValue;
  }
  
  // Get an array of all the delta values of each valid seed
  private ArrayList<Integer> getDeltaValueVector () {
    ArrayList<Integer> deltaVector = new ArrayList<Integer>();
    for (Seed s : seeds) {
      int delta = s.getDeltaV();
      if (delta>=0)
        deltaVector.add(delta);
    }
    return deltaVector;
  }
  
  // Returns the standard deviation of the  minimun value for each row of table.
  double calcSDeviation () {
    
    // Get an array of all the delta values of each valid see
    ArrayList<Integer> deltaValueVector = new ArrayList<Integer>();
    deltaValueVector = getDeltaValueVector();
    
    // Need for the avg value for next calcs
    calcAvgDeltaValue();
    
    // Return if i have less of 2 values
    if ( avgDeltaValue == -1 || deltaValueVector.size() == 1) {
      sDeviation = -1;
      return sDeviation;
    }
    
    // Get de deviation
    for(int x = 0 ; x < deltaValueVector.size() ; x++) {
      sDeviation += Math.pow( deltaValueVector.get(x) - avgDeltaValue, 2);
    }
    sDeviation = sDeviation / deltaValueVector.size() - 1;
    sDeviation = Math.sqrt(sDeviation);
    
    return sDeviation;
  }
  
  float getSDeviation () {
    return (float)sDeviation;
  }
  
  // returns a vector containing = { numberOfDeltaValues , minDeltaValue, maxDeltaValue}
  int[] getDeltaValuesInfo (){
    int[] rtrn = {0 ,0 , 0};
    
    // Get an array of all the delta values of each valid see
    ArrayList<Integer> deltaValueVector = new ArrayList<Integer>();
    deltaValueVector = getDeltaValueVector();
    Collections.sort(deltaValueVector);
    
    if ( deltaValueVector.size() > 0) {
      rtrn[0] = deltaValueVector.size();
      rtrn[1] = deltaValueVector.get(0);
      rtrn[2] = deltaValueVector.get( deltaValueVector.size() - 1 );
    }
    return rtrn;
  }
  
  boolean isPlotDataLoaded (){
     return plotDataLoaded;
  }
  
  void addHistogramLayers ( int hClasses_, int hClassesWidth_, int hLimitSup_, int hMaxValue_, int hMinValue_) {
    
    // Get an array of all the delta values of each valid see
    ArrayList<Integer> deltaValueVector = new ArrayList<Integer>();
    deltaValueVector = getDeltaValueVector();
    Collections.sort(deltaValueVector);  // Sort values of array from min to max
    
    // Delimit de total clases of histogram to local clases
    int[] hClassesLocalLimits = { 1, hClasses_};
    int maxLimit = hMinValue_ + hClassesWidth_ * ( hClasses_ -1 );
    while ( deltaValueVector.get( deltaValueVector.size()-1 ) < maxLimit) { // Search the class where to start depending on my min local value.
       hClassesLocalLimits[1]--;
       maxLimit -= hClassesWidth_;
    }
    
    while ( deltaValueVector.get(0) > hLimitSup_) { // Search the class where to start depending on my min local value.
       hClassesLocalLimits[0]++;
       hLimitSup_ += hClassesWidth_;
    }
    
    int hLocalClasses = hClassesLocalLimits[1] - hClassesLocalLimits[0] + 1;
    
    // Prepare the points for the histogtram plot
    float[] gaussianStack = new float[hLocalClasses];  // This vector will store the quantity of points in each class
    int gaussianCounter = 0;  // Point counter
    
    // Asign the values to each class minus the last
    int hLimitInf = hMinValue_ + hClassesWidth_ * ( hClassesLocalLimits[0] -1 );
    int hLimitSup = hMinValue_ + hClassesWidth_ * hClassesLocalLimits[0];
    
    for ( int classesIndex = 0; classesIndex < (hLocalClasses - 1) ; classesIndex++ ) {
      for ( int vectorIndex = 0; vectorIndex < deltaValueVector.size() ; vectorIndex++ ) {
        if ( deltaValueVector.get(vectorIndex) >= hLimitInf && deltaValueVector.get(vectorIndex) < hLimitSup) {
          gaussianStack[classesIndex]++;
          gaussianCounter++;
        }
      }
      hLimitInf = hLimitSup;
      hLimitSup += hClassesWidth_;
    }
    // The next is for assign the values for the last local class
    for ( int vectorIndex = 0; vectorIndex < deltaValueVector.size() ; vectorIndex++ ) {
        if ( deltaValueVector.get(vectorIndex) >= hLimitInf && deltaValueVector.get(vectorIndex) <= hLimitSup) {
          gaussianStack[ (hLocalClasses - 1) ]++;
          gaussianCounter++;
        }
    }
    
    //  Forward code represents the data in the gaussianStack vector
    GPointsArray points = new GPointsArray(gaussianStack.length);
    
    int m = 0;
    for (int l = hClassesLocalLimits[0] ; l <= hClassesLocalLimits[1]; l++, m++) {
      points.add( l, gaussianStack[m]/gaussianCounter );
      if ( hMaxProbValue < (gaussianStack[m]/gaussianCounter) ){
        hMaxProbValue = (gaussianStack[m]/gaussianCounter);
      }
    }
    
    String layerName = fileName + "." + str(fileIndex) ;
    plot2.addLayer(layerName, points);
    
  }
  
  void removeHistogramLayers() {
    String layerName = fileName + "." + str(fileIndex) ;
    plot2.removeLayer ( layerName );
  }
  
  void setHistogramColors () {
    // Set layer Color
    int colorR, colorG, colorB;
    colorR = predefinedColorR[ fileIndex ];
    colorG = predefinedColorG[ fileIndex ];
    colorB = predefinedColorB[ fileIndex ];
    
    String layerName = fileName + "." + str(fileIndex) ;
    
    plot2.getHistogram(layerName).setBgColors(new color[] {
    color(colorR, colorG, colorB, 150), color(colorR, colorG, colorB, 150), 
    color(colorR, colorG, colorB, 150), color(colorR, colorG, colorB, 150) 
    }
    );
  }
  
  void addLayers () {
    // Add one layer for every seed saved in file
    for (Seed s : seeds) {
      s.addLayer( fileName, fileIndex);
    }
    plotDataLoaded = true;
  }
  
  void removeLayers (){
    // Remove one layer for every seed saved in file
    for (Seed s : seeds) {
      s.removeLayer( fileName, fileIndex);
    }
  }
  
  // Count all the valid seeds in file
  int getValidSeeds (){
    int validSeedsCounter = 0;
    // Remove one layer for every seed saved in file
    for (Seed s : seeds) {
      if( s.getValidSeed() == true ) {
       validSeedsCounter++;
      }
    }
    return validSeedsCounter;
  }
  
  ArrayList<String> getNearLayerPointAt(float mouseX_, float mouseY_) {
    ArrayList<String> layerNames = new ArrayList<String>();
    for (Seed s : seeds) {
      String ln = s.getNearPointAt ( fileName,  fileIndex, mouseX_, mouseY_);
      if (ln != null)
        layerNames.add(ln);
    }
    if ( layerNames.size() > 0)
      return layerNames;
    else
      return null;
  }
  
  void setSeedAsInvalid(int item_) {
    for (Seed s : seeds) {
      int i = s.getItem();
      if ( i == item_ ) {
        s.setInvalid();
        return;
      }
    }
  }
  
  void addFileToTimeline() {
    int zeroTime = seeds[0].getTimeStamp();
    String ln = fileName + "." + fileIndex;
    
    GPointsArray points = new GPointsArray(0);
    plot3.addLayer(ln, points);
    
    for (Seed s : seeds) {
      s.addPointsToLayer( ln, zeroTime);
    }
    
    int colorR = predefinedColorR[ fileIndex ];
    int colorG = predefinedColorG[ fileIndex ];
    int colorB = predefinedColorB[ fileIndex ];
    int colorA = 220;
    plot3.getLayer(ln).setLineColor(color(colorR, colorG, colorB, colorA));
    plot3.getLayer(ln).setPointColor(color(colorR, colorG, colorB, colorA));
    
    
  }
  
  int getFileIndex() {
    return fileIndex;
  }
  
  void setFileIndex( int fi ) {
    fileIndex = fi;
  }
  
  String exportToFile( int format ){
    String fileSavedIn = "";
    
    switch (format) {
      case 0:  /*  Export in .csv format  */
        /*  Init new table where to export  */
        Table tableExport;
        tableExport = new Table();
        
        /*  Add colums  */
        tableExport.addColumn("#");
        tableExport.addColumn("timeStamp");
        for ( int i=0 ; i < 101 ; i++ ){
          tableExport.addColumn( str(i) );
        }
        
        /*  Add Rows  */
        for (Seed s : seeds) { //<>//
          s.addSeedToTable( tableExport );
        }
        
        /*  Save table  */
        fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exported.csv";
        saveTable( tableExport, fileSavedIn );
        
        break;
      case 1:  /* Export in .txt format   */
        String matrixVector[] = {"","",""};
        
        /*  Add the text of all the seeds data  */
        int numberOfSeeds = 0;
        for (Seed s : seeds) {
          String newSeed = s.getDataOnString();
          if ( newSeed != null ) {
            numberOfSeeds++;
            matrixVector[1] += newSeed + ",\n";
          }
        }
        
        /*  Add the end of the matrix vector  */
        matrixVector[1] = matrixVector[1].substring(0,matrixVector[1].length()-2 ) + "\n";
        matrixVector[1] += "};";
        
        /*  Add the start of the matrix vector  */
        matrixVector[0] = "#define NUMBER_OF_SEEDS " + numberOfSeeds + "\nuint16_t seedsData[NUMBER_OF_SEEDS][101] = {";
        
        /*  Add the timeStamps  */
        matrixVector[2] = "uint32_t seedsTimeStamp[NUMBER_OF_SEEDS] = {";
        for (Seed s : seeds) {
          int newTimeStamp = s.getTimeStamp();
          if ( newTimeStamp != -1 ) {
            matrixVector[2] += newTimeStamp + ",";
          }
        }
        matrixVector[2] = matrixVector[2].substring(0,matrixVector[2].length()-1 ) + "};";
        
        /*  Save text file  */
        fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exported.h";
        saveStrings( fileSavedIn, matrixVector );
        break;
    }
    return fileSavedIn;
  }
  
}
