class Subtitles{
  private float curr_time;
  private int curr_index;
  private ArrayList<Float> times; // inderstand which datatipe is time
  private ArrayList<String> subs;
  
  private BufferedReader reader;
  private String ti;
  private String ar;
  private String al;
  private String by;
  private String la;
  private String re;
  private String ve;
  
  Subtitles(String path){
    curr_time = 0;
    curr_index = 0;
    times = new ArrayList<Float>();
    subs = new ArrayList<String>();
    reader = createReader(path);
    parseSubtitles();
  }
  
  private void parseSubtitles(){
    String line;
    ArrayList<String> lines = new ArrayList<String>();
    try {
      while ((line = reader.readLine()) != null) {
        lines.add(line);
      }
      reader.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    //println(lines.get(0));
    ti = match(lines.get(0), "\\[ti:(.*?)\\]")[1];
    ar = match(lines.get(1), "\\[ar:(.*?)\\]")[1];
    al = match(lines.get(2), "\\[al:(.*?)\\]")[1];
    by = match(lines.get(3), "\\[by:(.*?)\\]")[1];
    la = match(lines.get(4), "\\[la:(.*?)\\]")[1];
    re = match(lines.get(5), "\\[re:(.*?)\\]")[1];
    ve = match(lines.get(6), "\\[ve:(.*?)\\]")[1];
    
    //add an empity string for the start
    times.add(0.0);
    subs.add("");
    
    // starts from 8 siince there is an empty line at index 7
    for(int i=8; i < lines.size(); i++){
      String[] x = match(lines.get(i), "\\[(\\d*):(\\d*)\\.(\\d*)\\](.*)");
      //ginore whitespacest
      if (x != null){
        float min = float(x[1]);
        float sec = float(x[2]);
        float cents = float(x[3]);
        String text = x[4];
        
        float time_key = cents*10 + sec*1000 + min*60*1000;
        times.add(time_key);
        subs.add(text);
      }

    }  
    printArray(subs);
    printArray(times);
  }
  
  public void advance(float deltaMillis){
    curr_time += deltaMillis;
    if (curr_time > times.get(curr_index)){
      curr_index++;
    }
  }
  
  public String getSubtitle(){
    return subs.get(curr_index);
  }  
  
  public boolean hasEnded(){
    return curr_index >= times.size();
  }
  
  public int numberOfFrames(int fps){
    float lastTime = times.get(times.size()-1);
    return int(lastTime/1000*fps);
  }
  
  public String getTitle(){
    return ti;
  }
  
  public float getPercProgress(){
    return curr_time / times.get(times.size()-1);
  }
  
 
  
}

class ProgressBar{
  
  private float x;
  private float y;
  private float w;
  private float h;
  private float perc = 0.0;
  
  ProgressBar(float x, float y, float w, float h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void setPerc(float perc){
    if (perc < 0 || perc > 1) return;
    this.perc = perc;
  }
  
  void draw(color bg, color fg){
    rectMode(CORNER);
    fill(bg);
    rect(x,y, w, h);
    fill(fg);
    rect(x,y,perc*w, h);
    
  }
  
  

}
