//
// Copyright (c) 2014, ISR/IST (Instituto de Sistemas e Robótica / Instituto Superior Técnico)
// All rights reserved.
// 
// Author:
//    Ricardo Ribeiro <ribeiro@isr.ist.utl.pt>
//
//
// Distribution allowed only inside the context of the Seagull project:
//     Contract reference QREN/ADI-20131034063
//
// Contact:
//    Alexandre Bernardino <alex@isr.ist.utl.pt>
//
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "iostream"
#include <sstream>
#include <string>
#include <list>
#include <opencv2/core/core.hpp>
#include <fstream>
#include <ctime>
#include <cstdio> // for remove("filename")
#include <getopt.h>

using namespace std;


template <typename T>
std::string to_string(T value)
{
  std::ostringstream os ;
  os << value ;
  return os.str() ;
}


struct points {
  int x1, x2, y1, y2 ;
};

struct detection{
  bool valid ;
  bool estimated ;
  //int id;
  points pts;
  detection():valid(false),estimated(false){
    pts.x1 = 50;
    pts.x2 = 60;
    pts.y1 = 50;
    pts.y2 = 60;
  } ;
};

void copy_detection(detection & src, detection & dest){
  dest.valid = src.valid ;
  dest.estimated = src.estimated ;
  dest.pts.x1 = src.pts.x1 ;
  dest.pts.y1 = src.pts.y1 ;
  dest.pts.x2 = src.pts.x2 ;
  dest.pts.y2 = src.pts.y2 ;
};


struct frame_detections{
  std::vector<detection> dl;
};

class detections {
public:
  detections( int number_of_frames = 1, int number_of_ids = 5 ){
    fl.resize(number_of_frames);
    for (int f = 0; f<fl.size(); f++)
      fl[f].dl.resize(number_of_ids);
    Nids = number_of_ids;
  };
  void set_detection(int f, int id, int x1, int y1, int x2, int y2, bool estimated = false){
    if ( (f >= fl.size()) || (id >= fl[f].dl.size()) ) return ;
    detection* d = &(fl[f].dl[id]);
    d->pts.x1 = x1;
    d->pts.x2 = x2;
    d->pts.y1 = y1;
    d->pts.y2 = y2;
    d->estimated = estimated;
    d->valid = true;
  };
  void set_detection( int f, int id, points pts, bool estimated = false ){
    set_detection( f, id, pts.x1, pts.y1, pts.x2, pts.y2, estimated ) ;
  };
  void set_estimated( int f, int id, bool tf = true ){
    if ( (f >= fl.size()) || (id >= fl[f].dl.size()) ) return ;
    fl[f].dl[id].estimated = tf;
  };
  detection get_detection(int f, int id){
    detection d ;
    if ( f  >= fl.size()    ) return d ;
    if ( id >= fl[f].dl.size() ) return d ;
    if ( fl[f].dl[id].valid ) {
      copy_detection( fl[f].dl[id] , d ) ;
    }
    return d ;
  };
  bool is_valid(int f, int id){
    detection d = get_detection(f,id) ;
    return d.valid;
  }
  points get_points(int f, int id){
    detection d = get_detection(f,id);
    return d.pts ;
  };
  void delete_detection(int f, int id){
    if ( f  >= fl.size()    ) return ;
    if ( id >= fl[f].dl.size() ) return ;
    fl[f].dl[id].valid = false ;
  };
  void read_from_file(std::string filename){
    string line;
    ifstream file ( filename.c_str() ) ;
    if ( file.is_open() ) {
      while ( getline (file,line) ) {
	//cout << "original " << line << '\n';
	stringstream ss(line) ;
	int f, x1, y1, width, height, id ;
	bool estimated;
	ss >> f ; f -= 1 ;
	ss >> x1 ; x1 -= 1 ;
	ss >> y1 ; y1 -= 1 ;
	ss >> width ;
	ss >> height ;
	ss >> id ;
	ss >> estimated ;
	//cout << "decoded  " << f << " " << x1 << " " << y1 << " " << width << " " << height << " " << id << endl ;
	if ( f < fl.size() ) {
	  if ( id < fl[f].dl.size() ) {
	    fl[f].dl[id].pts.x1 = x1 ;
	    fl[f].dl[id].pts.y1 = y1 ;
	    fl[f].dl[id].pts.x2 = x1 + width - 1 ;
	    fl[f].dl[id].pts.y2 = y1 + height - 1 ;
	    fl[f].dl[id].valid = true ;
	    fl[f].dl[id].estimated = estimated ;
	  }
	}
      }
      file.close();
    } else {
      std::cout << "Unable to open detection file." << std::endl ; 
    }

  };
  void write_to_file(std::string filename){
    std::ofstream file;
    file.open (filename.c_str());
    for (int f = 0; f < fl.size(); f++ ){
      for (int i = 0; i < fl[f].dl.size(); i++){
	//if ( fl[f].dl[i].valid && !fl[f].dl[i].estimated ) {
	if ( fl[f].dl[i].valid ) {
	  file << f + 1 ;                                       file << " " ;
	  file << fl[f].dl[i].pts.x1 + 1 ;                      file << " " ;
	  file << fl[f].dl[i].pts.y1 + 1 ;                      file << " " ;
	  file << fl[f].dl[i].pts.x2 - fl[f].dl[i].pts.x1 + 1;  file << " " ;
	  file << fl[f].dl[i].pts.y2 - fl[f].dl[i].pts.y1 + 1;  file << " " ;
	  file << i;                                            file << " " ;
	  file << fl[f].dl[i].estimated;                        file << std::endl ;
	}
      }
    }
    file.close();
  };
  int find_frame_of_previous_detection(int current_frame, int id, bool estimated = false){
    int f = current_frame;
    detection d;
    do {
      f--;
      d = get_detection(f,id);
    } while ( ( !d.valid || d.estimated != estimated ) && f > 0 );
    if ( !d.valid )
      return -1;
    else
      return f;
  };
  int find_frame_of_next_detection(int current_frame, int id, bool estimated = false){
    int f = current_frame;
    detection d;
    do {
      f++;
      d = get_detection(f,id);
    } while ( ( !d.valid || d.estimated != estimated ) && f < fl.size()-1 );
    if ( !d.valid )
      return -1;
    else
      return f;
  };
  int get_number_of_ids(){ return Nids ; } ;
private:
  int Nids; // just a default number to initialize the length of the vector of detections for each frame.
  std::vector <frame_detections> fl;
};


struct highlight {
  int id ;
  bool top, bottom, left, right ;
};

struct private_data {
  points *pts ;
  highlight *hl ;
  int* zoom;
  int* zoom_factor;
  int* zoom_x0;
  int* zoom_y0;
  bool* update_det;
  float* window_resize_factor;
};

int abs( int val ){
  if ( val >= 0 ) return val; else return -val ;
}

void set_highlited(int x, int y, points pts, highlight& hl){
  int range = 3 ;
  hl.top    = abs( y - pts.y1 ) <= range ;
  hl.bottom = abs( y - pts.y2 ) <= range ;
  hl.left   = abs( x - pts.x1 ) <= range ;
  hl.right  = abs( x - pts.x2 ) <= range ;
}


void onMouse( int event, int x, int y, int flags, void* data ) {

  private_data* pd = (private_data*) data;  
  points* pts = pd->pts ;
  highlight* hl = pd->hl ;

  x = x / *(pd->window_resize_factor) ;
  y = y / *(pd->window_resize_factor) ;


  if ( *(pd->zoom) != 0 ) {
    //cout << "before: (x,y)=("<< x << "," << y <<")"<< endl ;
    x = (float)x / *(pd->zoom_factor) + *(pd->zoom_x0) ;
    y = (float)y / *(pd->zoom_factor) + *(pd->zoom_y0) ;
    //cout << "after: (x,y)=("<< x << "," << y <<")"<< endl ;
  }

  static bool bt_pressed = false ;
  static int dx1,dy1,dx2,dy2 ;

  switch ( event ) {
  case cv::EVENT_LBUTTONDOWN :
    cout << "but down" << endl;
    bt_pressed = true ;
    dx1 = x - pts->x1 ;
    dx2 = x - pts->x2 ;
    dy1 = y - pts->y1 ;
    dy2 = y - pts->y2 ;
    break;
  case cv::EVENT_LBUTTONUP :
    cout << "but up" << endl;
    bt_pressed = false ;
    break;
  default :
    if ( bt_pressed ){
      if ( hl->top )    pts->y1 = y ;
      if ( hl->bottom ) pts->y2 = y ;
      if ( hl->left )   pts->x1 = x ;
      if ( hl->right )  pts->x2 = x ;
      if ( !(hl->top || hl->bottom || hl->left || hl->right ) ) {
	pts->y1 = y - dy1 ;
	pts->y2 = y - dy2 ;
	pts->x1 = x - dx1 ;
	pts->x2 = x - dx2 ;
      }
      *(pd->update_det) = true ;
    }
    if ( !bt_pressed ) {
      set_highlited( x, y, *pts, *hl ) ;
    }
  }

}


void print_online_help ( cv::Mat img2 ) {
  int nlskip = 15;
  int x = 3;
  int y = 20;
  cv::Scalar color(255,255,255) ;
  //cv::Scalar color(0,25,25) ;
  int font = cv::FONT_HERSHEY_SIMPLEX ;
  float font_size = 0.4;
  putText( img2, string("h - show/hide this help") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("v - show/hide frame number and current id info") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("x - show/hide box id's") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("1 - maximizes dynamic range of the image shown.") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("ESC - quits the program and saves detections to file") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  y+=nlskip ; 
  putText( img2, string("moving box borders (normal - move by 1 pixel; with shift - move by 10 pixels):") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("  3/e - top border up/down") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("  a/s - left border left/right") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("  f/g - right border left/right") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("  d/c - bottom border up/down") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  y+=nlskip ; 
  putText( img2, string(",/. - previous/next frame") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("m/- - previous/next 10th frame") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string(";/: - previous/next 100th frame") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("M/_ - first/last frame") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("k/l - previous/next final box") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("K/L - previous/next estimated box") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("Space - start/stop play") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  y+=nlskip ; 
  putText( img2, string("5/6 - decrement/increment current id") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("+ - create a new box (at <10,10,100,100>)") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("* - delete current box") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("t - set current box as temporary") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ;
  putText( img2, string("T - set current box as final") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("enter - set current box as final and advance to next frame") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  y+=nlskip ; 
  putText( img2, string("p - copy the box of previous frame an sets as temporary box (previous box needs to be final.)") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("o - search for the image within the previous frame box (needs to be final) in the current image and sets new temp box") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("i - interpolates between the previous final box and current box") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("u - adjust the temporary boxes between current and last final box using image search (both boxes, at start and at end, need to be final) ") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  y+=nlskip ; 
  putText( img2, string("7/8/9 - resize window to half/full/double size") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("0 - enter/exit full screem mode") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
  putText( img2, string("Note: Final boxes of current id are green and temporary boxes are yellow. Boxes with other id's are grey.") , cvPoint(x,y),font, font_size, color ) ; y+=nlskip ; 
}

void print_info ( cv::Mat img, string str ) {
  int x = img.cols - 100  ;
  int y = 20;
  cv::Scalar color(255,255,255) ;
  //cv::Scalar color(0,25,25) ;
  int font = cv::FONT_HERSHEY_SIMPLEX ;
  //string str;
  //str.append( "frame_number/total" ) ;

  int baseline=0;
  cv::Size textSize = cv::getTextSize(str, font, .5 , 1, &baseline);
  cv::Point textOrg( (img.cols-textSize.width), textSize.height );

  cv::rectangle( img, textOrg+cv::Point(0,baseline), textOrg+cv::Point(textSize.width,-textSize.height), cv::Scalar(0,0,0) , CV_FILLED );

  putText( img, str , textOrg ,font, .5, color , 1 ) ; 
}

void do_linear_interpolation_prediction( cv::Mat img, detections & det, int current_frame, int current_id ) {

  if ( current_frame < 1 ) return;

  // search for previous labeled frame
  int previous_frame = current_frame;
  detection d ;  
  do {
    previous_frame-- ;
    d = det.get_detection( previous_frame ,current_id ) ;  
  } while ( previous_frame > 0 && ( !d.valid || d.estimated ) );

  // interpolate
  if ( d.valid && !d.estimated ) {
    points curr_pts = det.get_points( current_frame ,current_id ) ;
    points prev_pts = det.get_points( previous_frame ,current_id ) ;
    int N = current_frame - previous_frame;

    float dx1 = (float)(curr_pts.x1 - prev_pts.x1) / N ;
    float dx2 = (float)(curr_pts.x2 - prev_pts.x2) / N ;
    float dy1 = (float)(curr_pts.y1 - prev_pts.y1) / N ;
    float dy2 = (float)(curr_pts.y2 - prev_pts.y2) / N ;

    points pts ;
    float x1, x2, y1, y2 ;

    x1 = prev_pts.x1 + dx1 ;
    x2 = prev_pts.x2 + dx2 ;
    y1 = prev_pts.y1 + dy1 ;
    y2 = prev_pts.y2 + dy2 ;

    for (int f = previous_frame +1; f < current_frame; f++) {
      pts.x1 = x1 ;
      pts.x2 = x2 ;
      pts.y1 = y1 ;
      pts.y2 = y2 ;
      det.set_detection( f, current_id, pts, true ) ;
      x1 += dx1 ;
      x2 += dx2 ;
      y1 += dy1 ;
      y2 += dy2 ;
    }

  }

}


void do_search_prediction_in_range( detections & det, int start_frame, int end_frame, int id , cv::VideoCapture cap ) {
    double saved_frame_number = cap.get( CV_CAP_PROP_POS_FRAMES );

    detection detA = det.get_detection(start_frame,id);
    detection detB = det.get_detection(end_frame,id);
    if ( !detA.valid || detA.estimated ) return;
    if ( !detB.valid || detB.estimated ) return;

    cv::Mat imgA, imgB;
    cap.set( CV_CAP_PROP_POS_FRAMES, end_frame );
    if ( !cap.read(imgB) )  cout<<"Error reading frame!"<<endl ;
    cap.set( CV_CAP_PROP_POS_FRAMES, start_frame );
    if ( !cap.read(imgA) )  cout<<"Error reading frame!"<<endl ;


    float dAhlx =  ( detA.pts.x2 - detA.pts.x1 +1 ) / 2.0 ; // detection A/B half length in x/y
    float dAhly =  ( detA.pts.y2 - detA.pts.y1 +1 ) / 2.0 ;
    float dBhlx =  ( detB.pts.x2 - detB.pts.x1 +1 ) / 2.0 ;
    float dBhly =  ( detB.pts.y2 - detB.pts.y1 +1 ) / 2.0 ;

    cv::Mat start_template = imgA( cv::Range(detA.pts.y1,detA.pts.y2), cv::Range(detA.pts.x1,detA.pts.x2) ) ;
    cv::Mat end_template   = imgB( cv::Range(detB.pts.y1,detB.pts.y2), cv::Range(detB.pts.x1,detB.pts.x2) ) ;

    int search_range = 50 ;

    cv::Mat img;
    cv::Mat img_cutA;
    cv::Mat img_cutB;
    cv::Mat resultA( 2*search_range+1, 2*search_range+1,CV_32FC1 );
    cv::Mat resultB( 2*search_range+1, 2*search_range+1,CV_32FC1 );
    cv::Mat result ( 2*search_range+1, 2*search_range+1,CV_32FC1 );
    cv::Point minLocA, minLocB, minLoc ;
    double minValA, minValB, minVal ;
    double maxValA, maxValB ;

    //cv::imshow( "tA", start_template );
    //cv::imshow( "tB", end_template );

    
    int N = end_frame - start_frame - 1 ;

    //cap.set( CV_CAP_PROP_POS_FRAMES, start_frame + 1 );
    for (int f = start_frame +1 ; f < end_frame ; f ++) {
      //cout << f << endl ;
      if ( !cap.read(img) )  cout<<"Error reading frame!"<<endl ;

      detection d = det.get_detection(f,id);
      if ( !detA.valid ) return;
      float dcx = ( d.pts.x1 + d.pts.x2 ) / 2.0 ;
      float dcy = ( d.pts.y1 + d.pts.y2 ) / 2.0 ;

      //cout << "dcx,dcy -> " << dcx << " " << dcy << endl ;
      //cout << "dAhlx/y -> " << dAhlx << " " << dAhly << endl ;
      //cout << "dBhlx/y -> " <<dBhlx << " " << dBhly << endl ;

      cv::Range RAx( dcx - dAhlx - search_range, dcx + dAhlx + search_range ) ;
      cv::Range RAy( dcy - dAhly - search_range, dcy + dAhly + search_range ) ;
      cv::Range RBx( dcx - dBhlx - search_range, dcx + dBhlx + search_range ) ;
      cv::Range RBy( dcy - dBhly - search_range, dcy + dBhly + search_range ) ;

      //cout << "RBx,RBy -> " << RBx.start << " " << RBx.end << " " << RBy.start << " " << RBy.end << endl ;

      int x_pos_A = search_range;
      int y_pos_A = search_range;
      int x_pos_B = search_range;
      int y_pos_B = search_range;

      
      // verify ranges
      int delta;
      if (RAx.start < 0) { delta = -RAx.start ; RAx.start = 0; x_pos_A -= delta ; }
      if (RAy.start < 0) { delta = -RAy.start ; RAy.start = 0; y_pos_A -= delta ; }
      if (RBx.start < 0) { delta = -RBx.start ; RBx.start = 0; x_pos_B -= delta ; }
      if (RBy.start < 0) { delta = -RBy.start ; RBy.start = 0; y_pos_B -= delta ; }
      if ( RAx.end > img.cols-1 ) RAx.end = img.cols-1 ;
      if ( RAy.end > img.rows-1 ) RAy.end = img.rows-1 ;
      if ( RBx.end > img.cols-1 ) RBx.end = img.cols-1 ;
      if ( RBy.end > img.rows-1 ) RBy.end = img.rows-1 ;
      
      //cout << "RBx,RBy -> " << RBx.start << " " << RBx.end << " " << RBy.start << " " << RBy.end << endl ;

      //cout << 11111 << endl;
      img_cutA = img( RAy, RAx ) ;
      //cout << 22222 << endl;
      img_cutB = img( RBy, RBx ) ;
      //cout << 33333 << endl;

      //cv::imshow( "icA", img_cutA );
      //cv::imshow( "icB", img_cutB );

      //cout << 33333 << endl;
      cv::matchTemplate( img_cutA, start_template, resultA, CV_TM_SQDIFF );
      //cout << 33333 << endl;
      cv::matchTemplate( img_cutB, end_template  , resultB, CV_TM_SQDIFF );
      //cout << 33333 << endl;

      cv::minMaxLoc(resultA, &minValA, &maxValA, &minLocA, NULL) ;
      //cout << 33333 << endl;
      cv::minMaxLoc(resultB, &minValB, &maxValB, &minLocB, NULL) ;
      //cout << 33333 << endl;

      //cout << "minValA/B = " << minValA << " " << minValB << endl ;

      //cv::imshow( "errorA", resultA * (1/maxValA) );
      //cv::imshow( "errorB", resultB * (1/maxValB) );

      // weight errors and choose the lowest error estimatition
      double weightA = (double)( f - start_frame ) / N ;
      double weightB = (double)( end_frame - f ) / N ;
      minValA *= weightA ;
      minValB *= weightB ;

      //cout << "weightA/B = " << weightA << " " << weightB << endl ;
      //cout << "minValA/B (weighted) = " << minValA << " " << minValB << endl ;

      if ( minValA < minValB ) {
	//cout << "A" << endl ;
	minLoc = minLocA ;
	minLoc.x -= x_pos_A ;
	minLoc.y -= y_pos_A ;
      } else {
	//cout << "B" << endl ;
	minLoc = minLocB ;
	minLoc.x -= x_pos_B ;
	minLoc.y -= y_pos_B ;
      }

      //cout << minLoc << endl ;

      d.pts.x1 += minLoc.x ;
      d.pts.x2 += minLoc.x ;
      d.pts.y1 += minLoc.y ;
      d.pts.y2 += minLoc.y ;
      det.set_detection(f,id,d.pts,true);


      //cv::Mat tmp;
      //cv::Mat tmp2 = imgA( Range(), Range() );      
      //cv::Mat tmp = img( cv::Range(detA.pts.y1,detA.pts.y2), cv::Range(detA.pts.x1,detA.pts.x2) ) ;
      
      //if (f==20) cv::waitKey();
      //if (f==25) cv::waitKey();
      //if (f==30) cv::waitKey();
      //if (f==35) cv::waitKey();
      
    }
    
    cap.set( CV_CAP_PROP_POS_FRAMES, saved_frame_number );
}


void do_search_prediction( cv::Mat img, detections & det, int current_frame, int current_id , cv::VideoCapture cap ) {
  cout << "search prediction" << endl ;
  if ( current_frame < 1 ) return;
  detection d = det.get_detection( current_frame - 1 ,current_id ) ;
  if ( d.valid && !d.estimated ) {
    cout << "doing it" << endl ;
    // TODO: search on the image
    int search_range = 4 ;
    cout << img.rows << " " << img.cols << endl ;
    cout << " " << d.pts.x1 << " " << d.pts.x2 << " " << d.pts.y1 << " " << d.pts.y2 << endl;
    cv::Mat img_template = img( cv::Range(d.pts.y1,d.pts.y2), cv::Range(d.pts.x1,d.pts.x2) ) ;
    int xx1 = d.pts.x1 - search_range ;
    int xx2 = d.pts.x2 + search_range ;
    int yy1 = d.pts.y1 - search_range ;
    int yy2 = d.pts.y2 + search_range ;
    cout << " " << xx1 << " " << xx2 << " " << yy1 << " " << yy2 << endl;

    if (xx1<0) xx1 = 0 ;
    if (yy1<0) yy1 = 0 ;
    if (xx2>=img.cols) xx2 = img.cols - 1 ;
    if (yy2>=img.rows) yy2 = img.rows - 1 ;

    cout << " " << xx1 << " " << xx2 << " " << yy1 << " " << yy2 << endl;

    int x_delta1 = d.pts.x1 - xx1 ;
    //int x_delta2 = xx2 - d.pts.x2 ;
    int y_delta1 = d.pts.y1 - yy1 ;
    //int y_delta2 = yy2 - d.pts.y2 ;

    cout << "deltas" << endl;
    //cout << " " << x_delta1 << " " << x_delta2 << " " << y_delta1 << " " << y_delta2 << endl;
    cout << " " << x_delta1 << " " << " " << y_delta1 << endl;


    double saved_frame_number = cap.get( CV_CAP_PROP_POS_FRAMES );
    cap.set( CV_CAP_PROP_POS_FRAMES, current_frame-1 );
    cv::Mat img2;
    if ( !cap.read(img2) )
      cout<<"Already at last frame!"<<endl ;
    cap.set( CV_CAP_PROP_POS_FRAMES, saved_frame_number );

    //cv::Mat image = img2( cv::Range(d.pts.y1-search_range,d.pts.y2+search_range), cv::Range(d.pts.x1-search_range,d.pts.x2+search_range) ) ;
    cv::Mat image = img2( cv::Range(yy1,yy2), cv::Range(xx1,xx2) ) ;

    cv::Mat result( 2*search_range+1, 2*search_range+1,CV_32FC1 );

    //cv::imshow( "tmpl", img_template );
    //cv::imshow( "imag", image );
    
    cv::matchTemplate( image, img_template, result, CV_TM_SQDIFF );

    cv::Point maxLoc, minLoc;
    cv::minMaxLoc(result, NULL, NULL, &minLoc, &maxLoc) ;
    cout << minLoc << " " << maxLoc <<endl ;
    //minLoc.x -= search_range ;
    //minLoc.y -= search_range ;
    //maxLoc.x -= search_range ; 
    //maxLoc.y -= search_range ;
    minLoc.x -= x_delta1 ;
    minLoc.y -= y_delta1 ;
    maxLoc.x -= x_delta1 ; 
    maxLoc.y -= y_delta1 ;
    cout << minLoc << " " << maxLoc <<endl ;

    int dx = - minLoc.x;
    int dy = - minLoc.y;
    cout << "dx,dy = " << dx << "," << dy << endl;

    points pts;
    pts.x1 = dx + d.pts.x1 ;
    pts.x2 = dx + d.pts.x2 ;
    pts.y1 = dy + d.pts.y1 ;
    pts.y2 = dy + d.pts.y2 ;

    std::cout << "points" << std::endl;
    cout << " " << pts.x1 << " " << pts.x2 << " " << pts.y1 << " " << pts.y2 << endl;

    if (pts.x1<0) pts.x1 = 0 ;
    if (pts.y1<0) pts.y1 = 0 ;
    if (pts.x2>=img.cols) pts.x2 = img.cols - 1 ;
    if (pts.y2>=img.rows) pts.y2 = img.rows - 1 ;

    std::cout << "setting new label" << std::endl;
    cout << " " << pts.x1 << " " << pts.x2 << " " << pts.y1 << " " << pts.y2 << endl;
    det.set_detection( current_frame, current_id, pts, true ) ;
  }
}


void do_copy_last_prediction( cv::Mat img, detections & det, int current_frame, int current_id ) {
  if ( current_frame < 1 ) return;
  cout << 1111 << endl ;
  // search for previous labeled frame
  int previous_frame = current_frame;
  detection d ;  
  do {
    previous_frame-- ;
    d = det.get_detection( previous_frame ,current_id ) ;
    cout << " " << previous_frame << " " << d.valid << " " << d.estimated << endl ;
  } while ( previous_frame > 0 && ( !d.valid || d.estimated ) );
  cout << 2222 << " previous_frame=" << previous_frame << endl ;
  //use last frame detection version
  //detection* d = det.get_detection( current_frame - 1 ,current_id ) ;

  if ( d.valid && !d.estimated ) {
    det.set_detection( current_frame, current_id, d.pts, true ) ;
    cout << 3333 << endl ;
  }
}


void do_prediction( cv::Mat img, detections &det, int current_frame, int current_id ) {
  do_copy_last_prediction( img, det, current_frame, current_id ) ;
  //do_search_prediction( img, det, current_frame, current_id ) ;
  //do_linear_interpolation_prediction( img, det, current_frame, current_id ) ;
}



void version(){
  std::cout << "version 0.1.2" << endl ;
}

void help_cmdl(char** argv){


  std::cout<< "Usage:" << std::endl;
  std::cout<< argv[0]<<" [options] <video_file>"<<std::endl;
  version();
  std::cout << "(using OpenCV version " << CV_MAJOR_VERSION << "." << CV_MINOR_VERSION << ")" <<std::endl;

  std::cout<< "options:        " << std::endl;
  std::cout<< "    -d <detections_file>   - defines the file where to read and to save the detections." << std::endl;
  std::cout<< "                             If unspecified, the software uses the video filename with" << std::endl;
  std::cout<< "                             the extension replaced by 'gt.txt'." << std::endl;
  std::cout<< "                             (example: video.avi -> video.gt.txt) " << std::endl;
  std::cout<< "    -h                     - show this help." << std::endl;
  std::cout<< "    -v                     - show software version." << std::endl;
  std::cout<< "    " << std::endl;
  std::cout<< "While using the program press the 'h' key for more help." << std::endl;
  std::cout<< "    " << std::endl;
  std::cout<< "output file format:" << std::endl;
  std::cout<< "    - text file." << std::endl;
  std::cout<< "    - one line per detection." << std::endl;
  std::cout<< "    - each line has the following format:" << std::endl;
  std::cout<< "        <frame number> <top left x> <top left y> <width> <height> <object id> <1(temporary)/0(final)>" << std::endl;
  std::cout<< "    " << std::endl;
  std::cout<< "The software autosaves the detections to a file every 30 seconds. The filename is the same but with '.autosave' added" << std::endl;
  std::cout<< "in the end (example: video.gt.txt.autosave). Normal exiting the program automatically removes the autosave file." << std::endl;
  std::cout<< "    " << std::endl;
}


int main( int argc, char*argv[] ) {


  std::string video_filename;
  std::string detection_filename;

  int opt;
  while ( (opt=getopt(argc,argv,"hvd:")) != -1 ) {
    switch (opt) {
    case 'd' :
      detection_filename.assign(optarg);
      break;
    case 'h' :
      help_cmdl(argv);
      return 0;
      break;
    case 'v' :
      version();
      return 0;
      break;
    default :
      help_cmdl(argv);
      return -1;
    }
  }
  if (argc < optind + 1) {
    help_cmdl(argv);
    return -1;
  }

  video_filename.assign( argv[optind] );

  if ( detection_filename.empty() ) {
    std::cout << "Guessing the detections file name...";
    //cout << video_filename << endl;
    size_t idx = video_filename.find('%');
    //cout << idx << " / "<< std::string::npos << endl;
    if ( idx != std::string::npos ) {
      std::string tmp_basename_2 = video_filename.substr(0, idx) ;
      if ( tmp_basename_2.length() > 0 && tmp_basename_2.at( tmp_basename_2.length()-1 ) != '/' && tmp_basename_2.length() > 0 )
	tmp_basename_2 += '.' ;
      detection_filename = tmp_basename_2 + std::string("gt.txt") ;
    } else {
      int index = video_filename.find_last_of('.') ;
      std::string tmp_basename = video_filename.substr(0, index) ;
      // detection_filename.assign("aaa.txt") ;
      detection_filename = tmp_basename + std::string(".gt.txt") ;
    } ;
    std::cout << "  -> using " << detection_filename << std::endl;
  }


  std::string autosave_filename( detection_filename + std::string(".autosave") );
  time_t autosave_time_of_last = time(0);

  //IplImage *src=cvCreateImage(cvSize(640,480), 8, 3);
  //CvCapture* capture =cvCaptureFromCAM(CV_CAP_ANY);

  bool help_screen = false ;
  bool info  = false ;
  int zoom = false ;
  int zoom_factor = 1 ;
  int zoom_x_start = 0 ;
  int zoom_y_start = 0 ;


  float window_resize_factor = 0.5; 

  bool labels = false ;
  bool play = false ;
  bool update_det = false ;

  int current_id = 0 ;
  int num_ids = 100 ;


  cv::Mat img, img2;
  //img = cv::imread("00001234.png", CV_LOAD_IMAGE_COLOR) ;
  //if(! img.data )
  //  img = cv::Mat::zeros(200, 300, CV_32FC3);
  //img2 = img.clone();


  //cv::VideoCapture cap("lanchaArgos_clip1.avi");
  cv::VideoCapture cap( video_filename.c_str() );
  if(!cap.isOpened()) {
    std::cout<<"Error oppening video_file"<<std::endl;
    return -1;
  }
  if ( !cap.read(img) ) {
    cout<<"Error reading frame!"<<endl ;
    return -1;
  }


  double fps = cap.get( CV_CAP_PROP_FPS ) ;
  if ( !isnormal(fps) ) {
    fps = 25;
    cout << "WARNING: could not get the video frame rate. Using 25 fps instead." << endl;
  };
  int delay = 1.0/fps * 1000.0; // in miliseconds
  if ( delay == 0 ) delay = 10 ;

  detections det( cap.get(CV_CAP_PROP_FRAME_COUNT), num_ids ) ;
  //det.read_from_file( std::string("aaa.txt") ) ;
  det.read_from_file( detection_filename ) ;

  //points pts = { 10, 100, 10, 100 } ;
  //det.set_detection( 0,0,1608,308,1638,324,true) ;
  //det.set_detection(50,0,1556,310,1587,329,true) ;
  points pts = det.get_points(0,0) ;
  //cout << pts.x1 << pts.x2 << pts.y1 << pts.y2 << endl ;


  highlight hl = { 1, false, false, false, false };
  private_data pd = { &pts, &hl, &zoom, &zoom_factor, &zoom_x_start, &zoom_y_start, &update_det, &window_resize_factor } ;

  //cv::namedWindow( "out", CV_WINDOW_AUTOSIZE ) ;
  cv::namedWindow( "out", CV_WINDOW_NORMAL ) ;
  cv::setMouseCallback( "out", onMouse, &pd ) ;
  //cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)   , cap.get(CV_CAP_PROP_FRAME_HEIGHT)   ) ;
  cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)/2 , cap.get(CV_CAP_PROP_FRAME_HEIGHT)/2 ) ;
  cv::moveWindow( "out", 0, 0 ) ;

  int small_inc = 1 ;
  int large_inc = 10;

  int detection_selected = 1;

  int total_frames =  cap.get(CV_CAP_PROP_FRAME_COUNT) ;
  int current_frame = 0 ;

  bool max_dynamic_range = false ;

  while(1){
    //update_det = false ;

    pts = det.get_points( cap.get(CV_CAP_PROP_POS_FRAMES) - 1 ,current_id ) ;
    //cout << cap.get(CV_CAP_PROP_POS_FRAMES) <<pts.x1 << pts.x2 << pts.y1 << pts.y2 << endl ;

    current_frame =  cap.get(CV_CAP_PROP_POS_FRAMES) - 1 ;

    //src = cvRetrieveFrame( capture );
    img2=img.clone();

    if (max_dynamic_range){
      static double alpha = 1.0;
      static double beta = 0.0;

      cv::Mat img_gray;
      cv::cvtColor(img2, img_gray, CV_BGR2GRAY);
      double min, max ;
      minMaxLoc( img_gray, &min, &max );
      float new_alpha = 256.0/(max-min) ;
      float new_beta = - min * new_alpha ;

      // time filter the gain parameters ( N=0 disables time filtering )
      int N = 0; //10;
      alpha = (new_alpha + N*alpha)/(N+1)  ;
      beta = (new_beta + N*beta)/(N+1) ;
      //std::cout << "alfa , beta = " << alpha << " , " << beta << std::endl ;
      
      img2.convertTo(img2,-1,alpha,beta);

    }

    detection d ;
    cv::Scalar color ;
    color = cv::Scalar(127,127,127) ;
    for (int i = 0 ; i < num_ids; i++) {
      d = det.get_detection(current_frame,i) ;
      if ( d.valid ) {
	if ( i != current_id ) {
	  rectangle( img2, cv::Rect(cvPoint(d.pts.x1,d.pts.y1),cvPoint(d.pts.x2+1,d.pts.y2+1)), color );
	  if ( labels )
	    putText( img2, to_string(i) , cvPoint(d.pts.x1+1,d.pts.y1+8), cv::FONT_HERSHEY_SIMPLEX, 0.3, color ) ;
	}
      }
    }
    d = det.get_detection(current_frame,current_id) ;
    if ( d.valid ) {
      if ( d.estimated )
	color = cv::Scalar(0,255,255) ;
      else 
	color = cv::Scalar(0,255,0) ;

      rectangle( img2, cv::Rect(cvPoint(d.pts.x1,d.pts.y1),cvPoint(d.pts.x2+1,d.pts.y2+1)), color );
      // highlight
      if ( hl.top )    line( img2, cvPoint(d.pts.x1,d.pts.y1), cvPoint(d.pts.x2,d.pts.y1), cv::Scalar(0,0,255) ) ;
      if ( hl.bottom ) line( img2, cvPoint(d.pts.x1,d.pts.y2), cvPoint(d.pts.x2,d.pts.y2), cv::Scalar(0,0,255) ) ;
      if ( hl.left )   line( img2, cvPoint(d.pts.x1,d.pts.y1), cvPoint(d.pts.x1,d.pts.y2), cv::Scalar(0,0,255) ) ;
      if ( hl.right )  line( img2, cvPoint(d.pts.x2,d.pts.y1), cvPoint(d.pts.x2,d.pts.y2), cv::Scalar(0,0,255) ) ;
      
      // text label
      if ( labels ) {
	putText( img2, to_string(current_id) , cvPoint(d.pts.x1+1,d.pts.y1+8), cv::FONT_HERSHEY_SIMPLEX, 0.3, color ) ;
      }
    }

    // zoom
    if ( zoom != 0 ){
      int factor;
      switch ( zoom ) {
        case 1: factor = 2; break;
        case 2: factor = 4; break;
      }
      //cout << pts.x1 <<"..."<< pts.x2 <<"..."<< pts.y1 <<"..."<< pts.y2 <<"..."<< endl ;
      int x_center = (pts.x2 + pts.x1) / 2 ;
      int y_center = (pts.y2 + pts.y1) / 2 ;
      //cout << x_center << " - " <<  y_center << endl ;
      int x_start = x_center - img2.cols/2/factor ;
      int y_start = y_center - img2.rows/2/factor ;
      int x_end = x_center + img2.cols/2/factor ;
      int y_end = y_center + img2.rows/2/factor ;

      //cout << x_start <<", "<< x_end <<", "<< y_start <<", "<< y_end << endl;

      if ( x_start < 0 ) { x_start = 0 ; x_end = img2.cols/factor ; }
      if ( y_start < 0 ) { y_start = 0 ; y_end = img2.rows/factor ; }
      if ( x_end > img2.cols ) { x_start = img.cols - img2.cols/factor ; x_end = img2.cols ; }
      if ( y_end > img2.rows ) { y_start = img.rows - img2.rows/factor ; y_end = img2.rows ; }

      //cout << x_start <<", "<< x_end <<", "<< y_start <<", "<< y_end << endl;

      //cv::Mat aux = img2.colRange(x_start,x_end).rowRange(y_start,y_end) ;
      //cv::Mat aux = img2.colRange(1,4).rowRange(1,4) ; //.colRange(x_start,x_end).rowRange(y_start,y_end) ;
      //cv::Mat aux = img2(cv::Rect(x_start, y_start, img2.cols/factor, img2.rows/factor));
      cv::Mat aux = img2.clone() ;
      zoom_x_start = x_start ;
      zoom_y_start = y_start ;
      zoom_factor = factor ;
      //cv::resize( img2(cv::Rect(x_start, y_start, img2.cols/factor, img2.rows/factor)), img2, img2.size(), 0, 0, cv::INTER_NEAREST ) ;
      //cv::resize( aux, img2, img2.size(), 0, 0, cv::INTER_NEAREST ) ;
      cv::resize( aux.colRange(x_start,x_end).rowRange(y_start,y_end), img2, img2.size(), 0, 0, cv::INTER_NEAREST ) ;

      //img2 = aux;

    }


    //cv::Mat img_resized( (float)img2.rows*window_resize_factor, (float)img2.cols*window_resize_factor, CV_8UC3 );
    cv::Mat img_resized;
    cv::resize( img2, img_resized, cv::Size(), window_resize_factor, window_resize_factor ) ;
    //cv::resize( img2, img_resized, cv::Size(img2.cols*window_resize_factor,img2.rows*window_resize_factor) ,0,0);
    //cv::resize( img2, img_resized, img_resized.size(), 0, 0, cv::INTER_NEAREST ) ;

    // help
    if ( help_screen ){
      //img2.convertTo(img2, -1, 0.3, 0.0);
      //print_online_help( img2 ) ;
      img_resized.convertTo(img_resized, -1, 0.3, 0.0);
      print_online_help( img_resized ) ;
    } ;

    // info
    if ( info ){
      ostringstream temp;
      temp << cap.get(CV_CAP_PROP_POS_FRAMES);
      temp << "/";
      temp << cap.get(CV_CAP_PROP_FRAME_COUNT);
      temp << " (id=" << current_id << ")";
      //print_info( img2 , temp.str() ) ;
      print_info( img_resized , temp.str() ) ;
    }

    
    //cv::imshow( "out", img2 );
    cv::imshow( "out", img_resized );


    //int key;
    int f ;
    cv::Mat new_img ;

    int key_int ;
    char key;

    key_int = cv::waitKey(delay);
    key = key_int;
    char key_char = key ;
    if ( key == 27 ) break; //if 'esc' is pressed (note: the key code can change.)

    if ( key != -1 ) {
      cout<<key<<" -- "<<hex<<key<<dec<<endl;
      cout << key_int << " " << hex << key_int << dec << " " << key_char << endl ;
      switch (key_char) {

      case 'a':	pts.x1 -= small_inc; update_det=true; break;
      case 's':	pts.x1 += small_inc; update_det=true; break;
      case 'A':	pts.x1 -= large_inc; update_det=true; break;
      case 'S':	pts.x1 += large_inc; update_det=true; break;

      case '3':	pts.y1 -= small_inc; update_det=true; break;
      case 'e':	pts.y1 += small_inc; update_det=true; break;
      case '#': pts.y1 -= large_inc; update_det=true; break;
      case 'E':	pts.y1 += large_inc; update_det=true; break;

      case 'd':	pts.y2 -= small_inc; update_det=true; break;
      case 'c':	pts.y2 += small_inc; update_det=true; break;
      case 'D':	pts.y2 -= large_inc; update_det=true; break;
      case 'C':	pts.y2 += large_inc; update_det=true; break;

      case 'f':	pts.x2 -= small_inc; update_det=true; break;
      case 'g':	pts.x2 += small_inc; update_det=true; break;
      case 'F':	pts.x2 -= large_inc; update_det=true; break;
      case 'G':	pts.x2 += large_inc; update_det=true; break;

      case 'h': help_screen = !help_screen; break;
      case 'v':	info = !info; break;
      case 'x':	labels = !labels; break;
      case 'z': zoom++; if (zoom>2) zoom = 0; break;

      case ' ': play = !play; break;

      case '1': max_dynamic_range = !max_dynamic_range; break;

      case '5': if (current_id > 0 ) { current_id-- ; }; break ;
      case '6': if (current_id < num_ids - 1 ) { current_id++ ; }; break ;

	//case '7':	cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)/2 , cap.get(CV_CAP_PROP_FRAME_HEIGHT)/2 ) ; break ;
	//case '8':	cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)   , cap.get(CV_CAP_PROP_FRAME_HEIGHT)   ) ; break ;
	//case '9': cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)*2 , cap.get(CV_CAP_PROP_FRAME_HEIGHT)*2 ) ; break ;
      case '7':
	window_resize_factor = 0.5 ;
	cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)*window_resize_factor , cap.get(CV_CAP_PROP_FRAME_HEIGHT)*window_resize_factor );
	//cv::moveWindow( "out", 0, 0 ) ;
	break;
      case '8':
	window_resize_factor = 1.0 ; 
	cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)*window_resize_factor , cap.get(CV_CAP_PROP_FRAME_HEIGHT)*window_resize_factor );
	//cv::moveWindow( "out", 0, 0 ) ;
	break;
      case '9':
	window_resize_factor = 2.0 ;
	cv::resizeWindow( "out", cap.get(CV_CAP_PROP_FRAME_WIDTH)*window_resize_factor , cap.get(CV_CAP_PROP_FRAME_HEIGHT)*window_resize_factor );
	//cv::moveWindow( "out", 0, 0 ) ;
	break;
      case '0':
	if ( cv::getWindowProperty("out",CV_WND_PROP_FULLSCREEN) == CV_WINDOW_NORMAL ) {
	  cout << "to fullscreen mode."<<endl;
	  cv::setWindowProperty("out",CV_WND_PROP_AUTOSIZE, CV_WINDOW_NORMAL );
	  cv::setWindowProperty("out",CV_WND_PROP_FULLSCREEN, CV_WINDOW_FULLSCREEN );
	} else {
	  cout << "out of fullscreen mode."<<endl;
	  cv::setWindowProperty("out",CV_WND_PROP_AUTOSIZE, CV_WINDOW_AUTOSIZE );
	  cv::setWindowProperty("out",CV_WND_PROP_FULLSCREEN, CV_WINDOW_NORMAL );
	}
	break;

      case '.':
	if ( current_frame < total_frames - 1 ) 
	  if ( cap.read(new_img) )  img = new_img ;
	break;
      case ',':
	cap.set( CV_CAP_PROP_POS_FRAMES,  current_frame - 1 ) ;
	if ( cap.read(new_img) )  img = new_img ;
	break;
      case '-':
	if ( current_frame < total_frames - 10 ) {
	  cap.set( CV_CAP_PROP_POS_FRAMES, current_frame + 10 ) ;
	  if ( cap.read(new_img) )  img = new_img ;
	}
	break;
      case 'm':
	cap.set( CV_CAP_PROP_POS_FRAMES, current_frame - 10 ) ;
	if ( cap.read(new_img) )  img = new_img ;
	break;

      case ':':
	if ( current_frame < total_frames - 10 ) {
	  cap.set( CV_CAP_PROP_POS_FRAMES, current_frame + 100 ) ;
	  if ( cap.read(new_img) )  img = new_img ;
	}
	break;
      case ';':
	cap.set( CV_CAP_PROP_POS_FRAMES, current_frame - 100 ) ;
	if ( cap.read(new_img) )  img = new_img ;
	break;

      case 'M':
	cap.set( CV_CAP_PROP_POS_FRAMES, 0 ) ;
	if ( cap.read(new_img) )  img = new_img ;
	break;
      case '_':
	cap.set( CV_CAP_PROP_POS_FRAMES, total_frames - 1 ) ;
	if ( cap.read(new_img) )  img = new_img ;
	break;


      case 'l':
	f = det.find_frame_of_next_detection(current_frame,current_id) ;
	if ( f >= 0 ) 
	  if ( f < total_frames - 1 ) {
	    cap.set( CV_CAP_PROP_POS_FRAMES, f ) ;
	    if ( cap.read(new_img) )  img = new_img ;
	  }
	break;
      case 'k':
	f = det.find_frame_of_previous_detection(current_frame,current_id) ;
	if ( f >= 0 ) {
	  cap.set( CV_CAP_PROP_POS_FRAMES, f ) ;
	  if ( cap.read(new_img) )  img = new_img ;
	}
	break;
      case 'L':
	f = det.find_frame_of_next_detection(current_frame,current_id,true) ;
	if ( f >= 0 ) 
	  if ( f < total_frames - 1 ) {
	    cap.set( CV_CAP_PROP_POS_FRAMES, f ) ;
	    if ( cap.read(new_img) )  img = new_img ;
	  }
	break;
      case 'K':
	f = det.find_frame_of_previous_detection(current_frame,current_id,true) ;
	if ( f >= 0 ) {
	  cap.set( CV_CAP_PROP_POS_FRAMES, f ) ;
	  if ( cap.read(new_img) )  img = new_img ;
	}
	break;



      case '+': // new detection
	det.set_detection( current_frame, current_id, 10,10,100,100,true) ;
	break;
      case '*': // delete detection
	det.delete_detection( current_frame, current_id ) ; 
	break;
      case 'p': // predict box
	do_copy_last_prediction( img, det, current_frame, current_id );
	break;
      case 'o': // linear prediction
	do_search_prediction( img, det, current_frame, current_id, cap );
	break;
      case 'i': // linear prediction
	do_linear_interpolation_prediction( img, det, current_frame, current_id );
	break;
      case 'u': // linear prediction
	f = det.find_frame_of_previous_detection(current_frame,current_id) ;
	//cout << f << endl ;
	//do_search_prediction_in_range( det, det.find_frame_of_previous_detection(current_frame,current_id), current_frame, current_id , cap );
	do_search_prediction_in_range( det, f, current_frame, current_id , cap );
	break;
      case 't': // set as estimated
	det.set_estimated( current_frame, current_id, true) ;
	break;
      case 'T': // set as real
	det.set_estimated( current_frame, current_id, false) ;
	break;


      //case '\n': // enter key
      case 0x0D: // enter key
      case 0x0A: // enter key
	det.set_estimated( current_frame, current_id, false ) ;
	if ( current_frame < total_frames - 1 ) 
	  if ( cap.read(new_img) )  img = new_img ;
	break;

      default:	break;	// do nothing
      }

    }

    if (play) {
      if ( current_frame < total_frames - 1 ) {
	  if ( cap.read(new_img) )  img = new_img ;
      } else {
	play = false ;
      }
    }

    //cvGrabFrame( capture );

    if (update_det) {
      if ( det.is_valid( current_frame, current_id ) ) {
	if ( pts.x1 < 0 ) pts.x1 = 0 ;
	if ( pts.y1 < 0 ) pts.y1 = 0 ;
	if ( pts.x2 > img.cols-1 ) pts.x2 = img.cols-1 ;
	if ( pts.y2 > img.rows-1 ) pts.y2 = img.rows-1 ;
	det.set_detection( current_frame, current_id, pts ) ;
      }
      update_det = false ;
    }

    time_t now = time(0) ;
    if ( difftime(now,autosave_time_of_last) > 30 ) {
      cout << "Autosaving to file " << autosave_filename << " ......... " << endl ;
      det.write_to_file( autosave_filename ) ;
      cout << "Autosaving done." << endl ;
      autosave_time_of_last = now;
    }
    
  }


  // check if detection file already exists and make backup copy of it
  std::ifstream infile(detection_filename.c_str());
  if ( infile ) {
    std::string detection_filename_backup = detection_filename + std::string("~") ;
    std::ofstream outfile( detection_filename_backup.c_str() );
    outfile << infile.rdbuf();
    outfile.close();
    infile.close();
    std::cout << "Old detections file backup: "<< detection_filename_backup << std::endl ;
  }

  //det.write_to_file(std::string("aaa.txt")) ;
  det.write_to_file( std::string(detection_filename) ) ;
  std::cout << "Detections saved to file:   "<< detection_filename << std::endl ;

  // Data is already saved. Delete the autosave file.
  remove(autosave_filename.c_str());

  cvDestroyAllWindows();
  //cvReleaseCapture( &capture );
  return 0;
}


