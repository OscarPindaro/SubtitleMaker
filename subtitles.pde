import com.hamoid.*;

import java.io.File;
 
PGraphics graph;
int curr_frame = 0;
boolean GREEN_SCREEN = true;
boolean SAVE_IMAGES = false;
String SAVE_FRAME_PATH = "frames/";
String SAVE_MOVIE_PATH = "output/";
PFont font; 
String FONTNAME = "ROCK.TTF";
Subtitles subtitles;
String SUB_DEFAULT_PATH = "input/subtitles.lrc";
int FPS = 24;
float TEXT_WIDTH;
float TEXT_HEGIHT;
float fraction= 0.1;
VideoExport videoExport;

void setup() {
  size(1080, 720);
  graph = createGraphics(width, height);
  font = createFont(FONTNAME, 60);
  subtitles = new Subtitles(SUB_DEFAULT_PATH);
  //deleteOldData(); 
  videoExport = new VideoExport(this, SAVE_MOVIE_PATH + subtitles.getTitle() +".mov", graph);
  videoExport.setFrameRate(FPS);
  videoExport.startMovie();
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
  videoExport.saveFrame();
  //graph.save("aa.png");
  if (GREEN_SCREEN){
      background(0,255,0);
      image(graph, 0,0);
      if (SAVE_IMAGES)
        saveFrame(SAVE_FRAME_PATH + "######.png");
  }
  /*
  else{
    String filename = String.format("%06d.png", curr_frame);
    if (SAVE_IMAGES)
      graph.save(SAVE_FRAME_PATH+ filename);
  }*/
  curr_frame++;
  graph.clear();
  subtitles.advance(1.0/FPS*1000);
  if (subtitles.hasEnded()){
    videoExport.endMovie();
    exit();
  }
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
