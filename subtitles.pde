import java.io.File;
 
PGraphics graph;
int curr_frame = 0;
boolean GREEN_SCREEN = false;
boolean SAVE_IMAGES = false;
String SAVE_FRAME_PATH = "frames/";
PFont font; 
String FONTNAME = "ROCK.TTF";
Subtitles subtitles;
String SUB_DEFAULT_PATH = "input/subtitles.lrc";
int FPS = 24;
float TEXT_WIDTH;
float TEXT_HEGIHT;
float fraction= 0.1;

void setup() {
  size(1080, 720);
  graph = createGraphics(width, height);
  font = createFont(FONTNAME, 60);
  subtitles = new Subtitles(SUB_DEFAULT_PATH);
  deleteOldData();
}

void deleteOldData(){
  String framesPath = sketchPath(SAVE_FRAME_PATH);
  File fileName = new File(framesPath);
  File[] fileList = fileName.listFiles();
  println("Deleting old frames.");
  for (File file: fileList) {   
       file.delete();
  }
}

void draw(){
  TEXT_WIDTH = width - fraction*width;
  TEXT_HEGIHT = height;
  drawGraphics();
  //graph.save("aa.png");
  if (GREEN_SCREEN){
      background(0,255,0);
      image(graph, 0,0);
      if (SAVE_IMAGES)
        saveFrame(SAVE_FRAME_PATH + "######.png");
  }
  else{
    String filename = String.format("%06d.png", curr_frame);
    if (SAVE_IMAGES)
      graph.save(SAVE_FRAME_PATH+ filename);
  }
  curr_frame++;
  graph.clear();
  subtitles.advance(1.0/FPS*1000);
  if (subtitles.hasEnded())
    exit();
}


void drawGraphics(){
  graph.beginDraw();
  graph.fill(255,0,0);
  graph.rect(81+curr_frame, 81+curr_frame, 63, 63);
  graph.ellipse(width/2, height/2, 20,20);
  graph.fill(255,255,255);
  graph.textAlign(CENTER, CENTER);
  graph.rectMode(CENTER);
  graph.textFont(font);
  println(subtitles.getSubtitle());
  graph.text(subtitles.getSubtitle(), width/2, height/2,TEXT_WIDTH, TEXT_HEGIHT);
  graph.endDraw();
}

class Subtitles{
  private float curr_time;
  private int curr_index;
  private ArrayList<Float> times; // inderstand which datatipe is time
  private ArrayList<String> subs;
  
  BufferedReader reader;
  String ti;
  String ar;
  String al;
  String by;
  String la;
  String re;
  String ve;
  
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
    return curr_frame >= times.size();
  }
  
  public int numberOfFrames(int fps){
    float lastTime = times.get(times.size()-1);
    return int(lastTime/1000*fps);
  }
  
 
  
}
