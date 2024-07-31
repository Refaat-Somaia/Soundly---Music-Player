import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'global.dart';

List<Widget> listOfSongs = [];
String uriOfAvtiveSong = "";
String nameOfPlayingSong = "";
int count = 1;
bool changedTheme=false;
bool endOfList = false;
bool shuffle=false;
bool autoPlayNext=true;
bool repeat=false;
Random random = Random();
int shuffleAnimteDuration=700;
int repeatAnimteDuration=700;
final TextEditingController searchBar = TextEditingController();
final TextEditingController listTitle = TextEditingController();
PageController pageController = PageController(initialPage: 0, keepPage: false);
String songs = '';
String text = "Currently playing";
int index = 0;
int duration = 0;
List<String> titlesOfPages=["Currently playing","Playlists","Tracks"];
int indexOfCurrentSong = 0;
double progress = 0;
double barPosition = 0;
late Duration duration1;
List<SongModel> audios = [];
List<SongModel> audiosOfList = [];
String nameOfPlayingAlbum = "Unknown";
bool playBarAnimation = false;
List<bool> activeDots = [false, false, false];
bool playingSong = false;
late bool playAnimations;
String titleOfOpenedList="";
Map<String, Color> themes = {
  "Main": const Color(0xFF7E30E1),
  "Green": const Color(0xFF0EB29A),
  "Blue": const Color(0xFF0881A3),
  "Orange": const Color(0xFFFE7A36),
  "Red": const Color(0xFFE43F5A),
  "Pink": const Color(0xFFF875AA),
  "Cyan": const Color(0xFF51C4D3),
  "yellow":  Colors.yellow,
};
final assetsAudioPlayer = AssetsAudioPlayer();
late bool shadowsOn = true;
bool openPlayList = false;
Map<String,Widget> listOfPlayLists = {};
Map<int,int> playlistSongsIndex={};
bool playingFromList=false;





dynamic alert(BuildContext context)async {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(
                child: Text(
              'Settings',
              style: setFontStyle(12.sp, FontWeight.bold, fontColor),
            )),
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(
                  height: 60.h,
                  width: 100.w,
                  child: Column(
                    children: [
                      Text(
                        "Buttons shadow",
                        style: setFontStyle(10.sp, FontWeight.bold, fontColor),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            bottom: BorderSide(width: 4, color: mainColor),
                          ),
                        ),
                        child: ToggleSwitch(
                          minWidth: 30.w,
                          minHeight: 5.h,
                          initialLabelIndex: shadowsOn ? 0 : 1,
                          inactiveBgColor: secondColor,
                          inactiveFgColor: fontColor,
                          totalSwitches: 2,
                          labels: const ['On', 'Off'],
                          customTextStyles: [
                            setFontStyle(8.sp, FontWeight.w600, mainColor)
                          ],
                          activeBgColors: [
                            [mainColor.withOpacity(0.5)],
                            [mainColor.withOpacity(0.5)]
                          ],
                          animationDuration: 200,
                          animate: true,
                          onToggle: (index) async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            if (index == 0) {
                              prefs.setBool('shadowsOn', true);
                              shadowsOn=true;
                            } else {
                              prefs.setBool('shadowsOn', false);
                              shadowsOn=false;

                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        "Start-up animations",
                        style: setFontStyle(10.sp, FontWeight.bold, fontColor),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            bottom: BorderSide(width: 4, color: mainColor),
                          ),
                        ),
                        child: ToggleSwitch(
                          minWidth: 30.w,
                          minHeight: 5.h,
                          initialLabelIndex:  playAnimations ? 0 : 1,
                          inactiveBgColor: secondColor,
                          inactiveFgColor: fontColor,
                          totalSwitches: 2,
                          labels: const ['On', 'Off'],
                          customTextStyles: [
                            setFontStyle(8.sp, FontWeight.w600, mainColor)
                          ],
                          activeBgColors: [
                            [mainColor.withOpacity(0.5)],
                            [mainColor.withOpacity(0.5)]
                          ],
                          animationDuration: 200,
                          animate: true,
                          onToggle: (index) async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            if (index == 0) {
                              prefs.setBool('playAnimations', true);
                              playAnimations=true;
                            } else {
                              prefs.setBool('playAnimations', false);
                              playAnimations=false;

                            }
                          },
                        ),
                      ),
                        SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        "Auto play next song",
                        style: setFontStyle(10.sp, FontWeight.bold, fontColor),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            bottom: BorderSide(width: 4, color: mainColor),
                          ),
                        ),
                        child: ToggleSwitch(
                          minWidth: 30.w,
                          minHeight: 5.h,
                          initialLabelIndex:  autoPlayNext ? 0 : 1,
                          inactiveBgColor: secondColor,
                          inactiveFgColor: fontColor,
                          totalSwitches: 2,
                          labels: const ['On', 'Off'],
                          customTextStyles: [
                            setFontStyle(8.sp, FontWeight.w600, mainColor)
                          ],
                          activeBgColors: [
                            [mainColor.withOpacity(0.5)],
                            [mainColor.withOpacity(0.5)]
                          ],
                          animationDuration: 200,
                          animate: true,
                          onToggle: (index) async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            if (index == 0) {
                              prefs.setBool('autoPlayNext', true);
                              autoPlayNext=true;
                            } else {
                              prefs.setBool('autoPlayNext', false);
                              autoPlayNext=false;

                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ],
          );
        },
      );
    },
  );
}

Widget myButton(
  void Function()? func,
  double height,
  double width,
  Color shadowColor,
  Icon icon,
) {
  return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: secondColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowsOn ? shadowColor : Colors.transparent,
            spreadRadius: 0.01.h,
            blurRadius: 5,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: IconButton(onPressed: func, icon: icon));
}

Widget audioList() {
  return Container(
      color: Colors.transparent,
      width: 100.w,
      child: Stack(
        children: [
          Column(children: [
            SizedBox(
              height: 10.h,
            ),
            Container(
                width: 100.w,
                height: 70.h,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                // child: SingleChildScrollView(
                //   child: Column(
                //     children: listOfSongs.isNotEmpty
                //         ? listOfSongs
                //         : [Container()],
                //   ),
                // ),
                child: ListView(
                  itemExtent: 15.h,
                  children:
                      listOfSongs.isNotEmpty ? listOfSongs : [Container()],
                )),
          ]),
          //     Container(width: 100.w,height: 100.h,
          // color: Colors.black.withOpacity(0.5),),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: secondColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: SingleChildScrollView(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search...",
                      hintStyle: setFontStyle(
                          10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                    ),
                    controller: searchBar,
                    style: setFontStyle(12.sp, FontWeight.bold, fontColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ));
}


Widget createPlayList(String title,void Function()? func,void Function()? func2) {
  return Animate(
    child: TextButton(
      onPressed:  func,
      onLongPress: func2,
      child: Container(
        decoration: BoxDecoration(
            color: secondColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0.01.h,
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(1.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 6.h,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: setFontStyle(12.sp, FontWeight.bold, mainColor),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ).animate().shimmer(duration: 200.ms);
}

dynamic alertAddPlayList(BuildContext context, void Function()? func) {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(
                child: Text(
              'Add Playlist',
              style: setFontStyle(14.sp, FontWeight.bold, fontColor),
            )),
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(
                  height: 30.h,
                  width: 100.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Playlist title",
                        style: setFontStyle(10.sp, FontWeight.bold, fontColor),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        width: 90.w,
                        height: 7.h,
                        decoration: BoxDecoration(
                          color: secondColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: SingleChildScrollView(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Title...",
                              hintStyle: setFontStyle(10.sp, FontWeight.bold,
                                  fontColor.withOpacity(0.7)),
                            ),
                            controller: listTitle,
                            style:
                                setFontStyle(10.sp, FontWeight.bold, fontColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      TextButton(onPressed: func, child: Text("Add",
                      style: setFontStyle(10.sp, FontWeight.bold, mainColor),))
                    ],
                  )),
            ],
          );
        },
      );
    },
  );
}



Widget createAddToPlaylist(BuildContext context,String title,int index){
  return Container(
    width: 40.w,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: secondColor
    ),
    margin:EdgeInsets.only(bottom: 2.h),
    child: 
    TextButton(onPressed: ()async{
          SharedPreferences pref=await SharedPreferences.getInstance();
          for(int i=0;i<150;i++){
            if(pref.getInt("$title,$i")==null){
              pref.setInt("$title,$i", index);
              break;
            }
          }
          Navigator.pop(context);

    }, child: Text(title,style: setFontStyle(10.sp, FontWeight.bold, mainColor),)));
}

dynamic alertShowPlayLists(BuildContext context,int index) {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(height: 5.h,),
                 Center(
                child: Text(
              'Select playlist to add to',
              style: setFontStyle(12.sp, FontWeight.bold, fontColor),
            )),
              SizedBox(height: 3.h,),

              SizedBox(
                  height: 40.h,
                  width: 100.w,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      
                        for(int i=0;i<listOfPlayLists.length;i++)
                        createAddToPlaylist(context,listOfPlayLists.keys.elementAt(i), index)
                        
                      ],
                    ),
                  )),
            ],
          );
        },
      );
    },
  );
}


dynamic alertDeletePlayList(BuildContext context, String title,void Function()? func) {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
           
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(
                  width: 100.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                         SizedBox(
                        height: 3.h,
                      ),
                          Icon(Icons.delete_outline_rounded,color: Colors.red.withOpacity(0.7),size: 7.h,),
                   
                           SizedBox(
                        height: 2.h,
                      ),
                    Center(
                child: Text(
              'Delete $title?',
              style: setFontStyle(12.sp, FontWeight.bold, fontColor),
            )),
               SizedBox(
                        height: 2.h,
                      ),
        
                     
                      TextButton(onPressed: func, child: Text("Delete",
                      style: setFontStyle(10.sp, FontWeight.bold, mainColor),))
                    ],
                  )),
            ],
          );
        },
      );
    },
  );
}
 String getFileSizeString({required int? bytes, int decimals = 0}) {
      const suffixes = ["b", "kb", "mb", "gb", "tb"];
      if (bytes == 0||bytes==null) return '0${suffixes[0]}';
      var i = (log(bytes!) / log(1024)).floor();
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
    }


dynamic alertResetWarning(BuildContext context,void Function()? func) {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
           
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(
                  width: 100.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                         SizedBox(
                        height: 3.h,
                      ),
                          Icon(Icons.info,color: const Color.fromARGB(255, 220, 203, 51),size: 7.h,),
                   
                           SizedBox(
                        height: 2.h,
                      ),
                    Center(
                child: Text(
              'This option is used for clearing the app local storage and reseting it to the default state. Your playlists will be deleted.',
              style: setFontStyle(9.sp, FontWeight.bold, fontColor),textAlign: TextAlign.center,
            )),
               SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Container(
                          
    width: 30.w,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: secondColor
    ),
    margin:EdgeInsets.only(right: 5.w),
    child: 
    TextButton(onPressed: func,child:Text("Confirm",style: setFontStyle(9.sp, FontWeight.bold, 
    Colors.green),) ,)),

    Container(
    width: 30.w,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: secondColor
    ),
    child: 
    TextButton(onPressed: (){
      Navigator.pop(context);
    },child:Text("Cancel",style: setFontStyle(9.sp, FontWeight.bold, 
    Colors.red.withOpacity(0.7)),) ,)),
                      ],)
                    ],
                  )),
            ],
          );
        },
      );
    },
  );
}


dynamic alertReset(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
           
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(
                  width: 100.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                         SizedBox(
                        height: 3.h,
                      ),
                          Icon(Icons.restore,color: Colors.green.withOpacity(0.7),size: 7.h,),
                   
                           SizedBox(
                        height: 2.h,
                      ),
                    Center(
                child: Text(
              'Local storage have been reset',
              style: setFontStyle(12.sp, FontWeight.bold, fontColor),textAlign: TextAlign.center,
            )),
               SizedBox(
                        height: 2.h,
                      ),
                    ],
                  )),
            ],
          );
        },
      );
    },
  );
}


dynamic alertTrackDetails(BuildContext context, String title,String? album,int? size,String? uri,
int? dateCreated,DateTime duration,String? extn) {
  var date1 = DateTime.fromMillisecondsSinceEpoch(dateCreated! * 1000);
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
           title: Center(
                child: Text(
              title,
              style: setFontStyle(12.sp, FontWeight.bold, fontColor),
            )),
            backgroundColor: bodyColor,
            surfaceTintColor: bodyColor,
            actions: <Widget>[
              SizedBox(
                  width: 100.w,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                           SizedBox(
                          height: 3.h,
                        ),
                     
                    SizedBox(width: 100.w,
                      child: Text(
                                    'Album: $album',
                                    style: setFontStyle(10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                                 textAlign: TextAlign.start ),
                    ),
                    SizedBox(
                            height: 3.h,
                                   ),
                              SizedBox(
                                width: 100.w,
                                child: Text(
                                    'Size: ${getFileSizeString(bytes: size)}',
                                    style: setFontStyle(10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                                  textAlign: TextAlign.start,),
                              ),
                                     SizedBox(
                          height: 3.h,
                        ),
                            SizedBox(
                                width: 100.w,
                                child: Text(
                                    'Duration: $duration',
                                    style: setFontStyle(10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                                  textAlign: TextAlign.start,),
                              ),
                                     SizedBox(
                          height: 3.h,
                        ),
                               SizedBox(
                                width: 100.w,
                                 child: Text(
                                    'Path: $uri',
                                    style: setFontStyle(10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                                  textAlign: TextAlign.start),
                               ),
                                  SizedBox(
                          height: 3.h,
                        ),
                    
                                 SizedBox(
                                width: 100.w,
                                 child: Text(
                                    'Date added: $date1',
                                    style: setFontStyle(10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                                  textAlign: TextAlign.start),
                               ),
                                        SizedBox(
                          height: 3.h,
                        ),
                    
                                 SizedBox(
                                width: 100.w,
                                 child: Text(
                                    'Format: $extn',
                                    style: setFontStyle(10.sp, FontWeight.bold, fontColor.withOpacity(0.7)),
                                  textAlign: TextAlign.start),
                               ),
                       
                    
                      ],
                    ),
                  )),
            ],
          );
        },
      );
    },
  );
}

List<Widget> songsOfList=[];
