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
  double getAvgDeltaValue () {
    int delta, counter = 0;
    double avg = 0;
    
    for (Seed s : seeds) {
      delta = s.getDeltaV();
      if (delta >=0 ){
        avg += delta; 
        counter++;
      }
    }
    avg /= counter;
    avgDeltaValue = avg;
    
    return avgDeltaValue;
  }
  
  // Get an array of all the delta values of each valid see
  private ArrayList<Integer> getDeltaValueVector () {
    // Get an array of all the delta values of each valid see
    ArrayList<Integer> deltaVector = new ArrayList<Integer>();
    for (Seed s : seeds) {
      int delta = s.getDeltaV();
      if (delta>=0)
        deltaVector.add(delta);
    }
    return deltaVector;
  }
  
  // Returns the standard deviation of the  minimun value for each row of table.
  double getSDeviation () {
    
    // Get an array of all the delta values of each valid see
    ArrayList<Integer> deltaValueVector = new ArrayList<Integer>();
    deltaValueVector = getDeltaValueVector();
    
    // Get de deviation
    if (avgDeltaValue == 0)
      getAvgDeltaValue();
    for(int x = 0 ; x < deltaValueVector.size() ; x++) {
      sDeviation += Math.pow( deltaValueVector.get(x) - avgDeltaValue, 2);
    }
    sDeviation = sDeviation / deltaValueVector.size() - 1;
    sDeviation = Math.sqrt(sDeviation);
    
    return sDeviation;
  }
  
  // returns a vector containing = { numberOfDeltaValues , minDeltaValue, maxDeltaValue}
  int[] getDeltaValuesInfo (){
    int[] rtrn = {0 ,0 , 0};
    
    // Get an array of all the delta values of each valid see
    ArrayList<Integer> deltaValueVector = new ArrayList<Integer>();
    deltaValueVector = getDeltaValueVector();
    Collections.sort(deltaValueVector);
    
    rtrn[0] = deltaValueVector.size();
    rtrn[1] = deltaValueVector.get(0);
    rtrn[2] = deltaValueVector.get( deltaValueVector.size() - 1 );
    
    return rtrn;
  }
  
  boolean isPlotDataLoaded (){
     return plotDataLoaded;
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
  
}