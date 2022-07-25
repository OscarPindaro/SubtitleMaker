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
  size(720, 480);
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

TextInput fps_input= new TextInput("FPS");
TextInput width_input= new TextInput("Width");
TextInput height_input= new TextInput("Height");


void draw(){
  int tol = 5;
  background(c_dark);
  beginCard( "VIDEO OPTION", 10, 10, s_big*2, s_big*2);
  // RESOLUTION
  textAlign(TOP, TOP);
  fill(c_text_color);
  textSize(22);
  text("Resolution", 20,60);
  String width_text = width_input.draw(150, 60, 2*s_small, s_height);
  textAlign(TOP, TOP);
  fill(c_text_color);
  textSize(20);
  text("X", 20 + 150 + 2*s_small, 63);
  String height_text = height_input.draw(20 + 150 + 2*s_small+20, 60, 2*s_small, s_height);
  textAlign(TOP, TOP);
  // FPS
  fill(c_text_color);
  textSize(22);
  text("FPS", 20, 60 + s_height+tol);
  String fps_text = fps_input.draw(150, 60 + s_height + tol, 2*s_small, s_height);
  endCard();
 
}

void createMovie(){
  TEXT_WIDTH = width - fraction*width;
  TEXT_HEGIHT = height;
  drawGraphics();
  videoExport.saveFrame();
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
