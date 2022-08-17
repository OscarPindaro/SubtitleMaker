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
float fraction= 0.01;
VideoExport videoExport;
String DEFAULT_WIDTH = "1080";
String DEFAULT_HEIGHT = "720";
String DEFAULT_FPS = "24";

enum Options{
  DEFAULT,
  APPLE_PRO_RES
}

TextInput fps_input;
TextInput width_input;
TextInput height_input;
ProgressBar pbar;

void setup() {
  size(420, 300);
  font = createFont(FONTNAME, 40);
  subtitles = new Subtitles(SUB_DEFAULT_PATH);
  //deleteOldData(); 
  fps_input= new TextInput("FPS");
  width_input= new TextInput("Width");
  height_input= new TextInput("Height");
  width_input.text= DEFAULT_WIDTH;
  height_input.text = DEFAULT_HEIGHT;
  fps_input.text = DEFAULT_FPS;
  //progress bar
  pbar = new ProgressBar(10, 200, s_big*2, s_small);
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



boolean render_video = false;
boolean created_object = false;
int pg_w = 1080;
int pg_h = 720;
int pg_fps = 24;
void draw(){

  int tol = 5;

  if (!render_video){
    background(c_dark);
    beginCard( "VIDEO OPTION", 10, 10, s_big*2, s_big);
    // RESOLUTION
    textAlign(TOP, TOP);
    fill(c_text_color);
    textSize(22);
    text("Resolution", 20,60);
    String width_text = width_input.draw(150, 60, 2*s_small, s_height);
    textAlign(TOP, TOP);
    fill(c_text_color);
    textSize(20);
    text("X", 20 + 150 + 2*s_small-5, 63);
    String height_text = height_input.draw(20 + 150 + 2*s_small+20, 60, 2*s_small, s_height);
    textAlign(TOP, TOP);
    // FPS
    fill(c_text_color);
    textSize(22);
    text("FPS", 20, 60 + s_height+tol);
    String fps_text = fps_input.draw(150, 60 + s_height + tol, 2*s_small, s_height);
    endCard();
    if(Button("OK", 160,  60 + s_height + tol+s_height+ 20)){
       try{
         pg_w = Integer.valueOf(width_text);
         pg_h = Integer.valueOf(height_text);
         pg_fps = Integer.valueOf(fps_text);
         render_video = true;
       } catch (Exception e){
         println("errore");
       }
     }
     
  }
  // render video is true
  else{
    if (!created_object){
      println("Starting rendering");
      createRenderObjects(pg_w, pg_h, subtitles.getTitle(),pg_fps );
      created_object = true;
    }
    createMovie(pg_w, pg_h, pg_fps);
    pbar.setPerc(subtitles.getPercProgress());
    pbar.draw(c_dark,c_light);
  }

 
}

void createRenderObjects(int pg_width, int pg_height, String title, int fps){
    graph = createGraphics(pg_width, pg_height);
    //graph.smooth(8);
    videoExport = new VideoExport(this, SAVE_MOVIE_PATH + title +".mov", graph);
    setFfmpegOptions(Options.APPLE_PRO_RES);
    videoExport.setFrameRate(fps);
    videoExport.startMovie();
}

void createMovie(int pg_width, int pg_height, int fps){
  drawGraphics(pg_width, pg_height);
  videoExport.saveFrame();
  graph.save(String.format("frames/%6d.png", curr_frame));
  curr_frame+=1;
  graph.clear();
  subtitles.advance(1.0/fps*1000);
  if (subtitles.hasEnded()){
    videoExport.endMovie();
    exit();
  }
}

void drawGraphics(int pg_width, int pg_height){
  TEXT_WIDTH = pg_width - fraction*pg_width;
  TEXT_HEGIHT = pg_height;
  graph.beginDraw();
  graph.fill(255,255,255);
  graph.textAlign(CENTER, CENTER);
  graph.rectMode(CENTER);
  graph.textFont(font);
  graph.text(subtitles.getSubtitle(), pg_width/2, pg_height/2,TEXT_WIDTH, TEXT_HEGIHT);
  graph.endDraw();
}

void setFfmpegOptions(Options options_type){
    if (options_type == Options.DEFAULT)
      return;
    else if (options_type == Options.APPLE_PRO_RES){
      videoExport.setFfmpegVideoSettings(
      new String[]{
      "[ffmpeg]",
      "-y",
      "-f", "rawvideo",
      "-vcodec", "rawvideo",
      "-s", "[width]x[height]",
      "-pix_fmt", "rgba",
      "-r", "[fps]",
      "-i", "-",
      
      "-an",
      "-c:v", "prores_ks",
      "-profile:v", "4444",
      "-vendor", "apl0",
      "-bits_per_mb", "8000",
      "-pix_fmt", "yuva444p10le",
      "-metadata",
      "comment=[comment]",
      "[output]"});
    }
  

  
  
}
