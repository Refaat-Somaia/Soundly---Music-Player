import 'dart:async';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundly/custom_icons_icons.dart';
import 'package:soundly/global.dart';
import 'package:soundly/alertsAndVars.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> with TickerProviderStateMixin {
  late AnimationController controllerOfDrawer = AnimationController(
    duration: 400.ms,
    vsync: this,
  );
  late AnimationController controllerOfList = AnimationController(
    duration: 400.ms,
    vsync: this,
  );

  late SharedPreferences pref;

  @override
  void initState() {
    getSharedPrefs();

    getAudios(count);
    super.initState();
    getLists();
    activeDots[0] = true;
  }

  getSharedPrefs() async {
    pref = await SharedPreferences.getInstance();
  }

  void getLists() async {
    listOfPlayLists.clear();

    listOfPlayLists["Recently played"] = createPlayList("Recently played", () {
      // pref.setString('lastOpenedList',"Recently played");

      setState(() {
        titleOfOpenedList = "Recently played";
        openPlayList = true;
        text = "Recently played";
      });
      getSongsOfList();
    }, () {});

    for (int i = 1; i < 10; i++) {
      if (pref.getString("list,$i") != null) {
        listOfPlayLists[pref.getString("list,$i")!] =
            createPlayList(pref.getString("list,$i")!, () {
          setState(() {
            titleOfOpenedList = pref.getString("list,$i")!;
            openPlayList = true;
            text = pref.getString("list,$i")!;
          });
          getSongsOfList();
        }, () {
          alertDeletePlayList(context, pref.getString("list,$i")!, () async {
            for (int i = 0; i < 150; i++) {
              if (pref.getInt("${pref.getString("list,$i")},$i") != null) {
                pref.remove("${pref.getString("list,$i")},$i");
              }
            }

            for (int i = 1; i < 10; i++) {
              if (pref.getString("list,$i") == pref.getString("list,$i")!) {
                setState(() {
                  listOfPlayLists.remove(pref.getString("list,$i")!);
                  pref.remove("list,$i");
                });
                Navigator.pop(context);
              }
            }
          });
        });
      }
    }
  }

  Future getAudios(int c) async {
    listOfSongs.clear();
    audios.clear();

    final OnAudioQuery _audioQuery = OnAudioQuery();
    audios = await _audioQuery.querySongs();

    for (int i = 0; i < audios.length; i++) {
      listOfSongs.add(createSong(i));
    }
    setState(() {});

    if (pref.getInt("index") != null) {
      if (pref.getString("lastOpenedList") != null) {
        titleOfOpenedList = pref.getString("lastOpenedList")!;
        await getSongsOfList();
        print("name of list ${pref.getString("lastOpenedList")}");

        selectSong(pref.getInt("index")!.toInt(), true, audiosOfList);
      } else {
        selectSong(pref.getInt("index")!.toInt(), true, audios);
      }
    }
  }

  void playSong() async {
    if (!playingSong) {
      await {
        assetsAudioPlayer.play(),
        setState(() {
          playingSong = true;
        }),
      };
    } else {
      await {
        assetsAudioPlayer.pause(),
        setState(() {
          playingSong = false;
        }),
      };
    }
    // updateDuration();
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  void anim(int i) {
    setState(() {
      duration = i;
    });
  }

  void updateDuration() async {
    if (assetsAudioPlayer.current.hasValue) {
      duration1 = assetsAudioPlayer.current.value!.audio.duration;
      pref.setString('duration1', duration1.toString());
      setState(() {
        playBarAnimation = true;
      });
    }

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (playingSong && assetsAudioPlayer.currentPosition.hasValue) {
        setState(() {
          progress = assetsAudioPlayer.currentPosition.value.inSeconds /
              duration1.inSeconds;
          barPosition = progress * 85.w;
        });

        pref.setDouble("progress", progress);
        pref.setDouble("barPosition", barPosition);
        if (assetsAudioPlayer.current.valueOrNull == null && autoPlayNext) {
          if (playingFromList) {
            if (repeat) {
              selectSong(indexOfCurrentSong, false, audiosOfList);
            } else if (shuffle) {
              int randomNumber = random.nextInt(audiosOfList.length);
              selectSong(randomNumber, false, audiosOfList);
            } else {
              selectSong(indexOfCurrentSong + 1, false, audiosOfList);
            }
          } else {
            if (repeat) {
              selectSong(indexOfCurrentSong, false, audios);
            } else if (shuffle) {
              int randomNumber = random.nextInt(audios.length);
              selectSong(randomNumber, false, audios);
            } else {
              selectSong(indexOfCurrentSong + 1, false, audios);
            }
          }
        }
        // Timer(const Duration(seconds: 2),(){
        // if(progress==0){

        // }
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      child: Scaffold(
        backgroundColor: bodyColor,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),

                      // top bar -------------------------------------------------------

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: 13.5.w,
                              height: 6.25.h,
                              decoration: BoxDecoration(
                                color: bodyColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0.01.h,
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      openDrawer = true;
                                    });
                                  },
                                  icon: Icon(
                                    CustomIcons.menu,
                                    color: mainColor.withOpacity(0.7),
                                  ))),
                          SizedBox(
                            width: 23.w,
                          ),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeDots[0]
                                    ? mainColor.withOpacity(0.8)
                                    : secondColor),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeDots[1]
                                    ? mainColor.withOpacity(0.8)
                                    : secondColor),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeDots[2]
                                    ? mainColor.withOpacity(0.8)
                                    : secondColor),
                          ),
                          SizedBox(
                            width: 23.w,
                          ),
                          Container(
                              width: 13.5.w,
                              height: 6.25.h,
                              decoration: BoxDecoration(
                                color: bodyColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0.01.h,
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: IconButton(
                                  onPressed: () async {
                                    if (index != 2) {
                                      pageController.animateToPage(2,
                                          duration: 300.ms,
                                          curve: Curves.easeInOut);
                                    } else {
                                      if (searchBar.text.isEmpty) {
                                        listOfSongs.clear();
                                        getAudios(count);
                                        setState(() {});
                                      }
                                      // playSong();
                                      else {
                                        setState(() {
                                          listOfSongs.clear();
                                        });
                                        String search = searchBar.text;
                                        RegExp regex = RegExp(
                                            '${searchBar.text}',
                                            caseSensitive: false);

                                        final OnAudioQuery _audioQuery =
                                            OnAudioQuery();
                                        audios = await _audioQuery.querySongs();

                                        for (int i = 0;
                                            i < audios.length;
                                            i++) {
                                          if (regex.hasMatch(audios[i].title)) {
                                            listOfSongs.add(createSong(i));
                                          }
                                        }
                                        setState(() {});
                                      }
// Timer(Duration(milliseconds: 400),(){
//   assetsAudioPlayer.seek(Duration(seconds:((duration1.inSeconds)*(prog)).toInt()));
//   assetsAudioPlayer.play();
// setState(() {
//   playingSong=true;

// });
//   });
                                    }
                                  },
                                  icon: Icon(
                                    CustomIcons.search,
                                    color: mainColor.withOpacity(0.7),
                                  ))),
                        ],
                      ),
                    ),
                    Animate(
                        child: Text(
                      text,
                      style: setFontStyle(12.sp, FontWeight.bold, fontColor),
                    )).fade(
                        duration: index == 0
                            ? 801.ms
                            : index == 1
                                ? 802.ms
                                : 800.ms),
                    openPlayList
                        ? Animate(
                            child: Text(
                            "${audiosOfList.length} tracks",
                            style: setFontStyle(10.sp, FontWeight.bold,
                                fontColor.withOpacity(0.7)),
                          )).fadeIn(duration: 500.ms, curve: Curves.easeInOut)
                        : Text(
                            "",
                            style: TextStyle(fontSize: 10.sp),
                          ),
                    SizedBox(
                      width: double.infinity,
                      height: 80.h,
                      child: PageView(
                        controller: pageController,
                        // controller: pageController,
                        children: [
                          nowPlaying(),
                          playLists(),
                          audioList(),
                        ],

                        onPageChanged: (value) {
                          value == 1 ? getLists() : {};

                          setState(() {
                            text = titlesOfPages[value];
                            playAnimations = false;
                            index = value;
                            for (int i = 0; i < 3; i++) {
                              activeDots[i] = false;
                            }
                            activeDots[value] = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (openDrawer)
                  Animate(
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      color: Colors.black.withOpacity(0.3),
                      child: TextButton(
                        style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent)),
                        onPressed: () {
                          controllerOfDrawer.reverse();

                          Timer(const Duration(milliseconds: 400), () {
                            setState(() {
                              openDrawer = false;
                            });
                          });
                        },
                        child: const Text(''),
                      ),
                    ),
                  ).animate(controller: controllerOfDrawer).fadeIn(
                        duration: 400.ms,
                        // curve: Curves.easeInOut,
                      ),
                if (openDrawer)
                  Positioned(
                      left: 0,
                      child: Animate(
                        child: Container(
                          width: 60.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                              color: bodyColor,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(32),
                                  bottomRight: Radius.circular(32))),
                          child: Animate(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10.h,
                                ),
                                drawerButton(const Color(0xFF51C4D3), "Theme",
                                    () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          backgroundColor: bodyColor,
                                          surfaceTintColor: bodyColor,
                                          actions: <Widget>[
                                            SizedBox(
                                              width: 90.w,
                                              height: 4.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Themes',
                                                  style: setFontStyle(
                                                      10.sp,
                                                      FontWeight.bold,
                                                      fontColor),
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Icon(
                                                  CustomIcons.brush,
                                                  size: 4.h,
                                                  color:
                                                      const Color(0xFF51C4D3),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3.h,
                                            ),
                                            SizedBox(
                                              height: 45.h,
                                              child: Center(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height: 3.h,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          themeButton(
                                                              "Main",
                                                              const Color(
                                                                  0xFF7E30E1)),
                                                          themeButton(
                                                              "Green",
                                                              const Color(
                                                                  0xFF0EB29A)),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 2.h,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          themeButton(
                                                              "Blue",
                                                              const Color(
                                                                  0xFF0881A3)),
                                                          themeButton(
                                                              "Orange",
                                                              const Color(
                                                                  0xFFFE7A36)),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 2.h,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          themeButton(
                                                              "Red",
                                                              const Color(
                                                                  0xFFE43F5A)),
                                                          themeButton(
                                                              "Pink",
                                                              const Color(
                                                                  0xFFF875AA)),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 2.h,
                                                      ),
                                                      Row(
                                                        children: [
                                                          themeButton(
                                                              "Cyan",
                                                              const Color(
                                                                  0xFF51C4D3)),
                                                          themeButton("yellow",
                                                              Colors.yellow),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3.h,
                                            )
                                          ],
                                        );
                                      });
                                    },
                                  );
                                }, CustomIcons.brush, 0),
                                drawerButton(
                                    const Color(0xFFFE7A36),
                                    bodyColor != const Color(0xFF1B1B2F)
                                        ? "Dark mode"
                                        : "Light mode", () async {
                                  if (bodyColor == const Color(0xFFE7E7E7)) {
                                    pref.setBool('darkMode', true);
                                    anim(200);
                                    setState(() {
                                      bodyColor = const Color(0xFF1B1B2F);
                                      secondColor = const Color(0xFF132043);
                                      fontColor = const Color(0xFFE7E7E7);
                                    });
                                  } else {
                                    pref.setBool('darkMode', false);
                                    setState(() {
                                      anim(201);

                                      bodyColor = const Color(0xFFE7E7E7);
                                      secondColor = const Color(0xFFE1E1E1);
                                      fontColor = const Color(0xFF2D2D2D);
                                    });
                                  }
                                  //   await assetsAudioPlayer.pause();
                                  //  await getAudios(count);
                                  //    assetsAudioPlayer.play();
                                  getLists();
                                },
                                    bodyColor != const Color(0xFF1B1B2F)
                                        ? CustomIcons.noun_dark_mode_6724412
                                        : Icons.sunny,
                                    100),
                                drawerButton(
                                    const Color(0xFF0EB29A), "Create List", () {
                                  alertAddPlayList(context, () async {
                                    String t = listTitle.text;

                                    if (listTitle.text.isNotEmpty) {
                                      setState(() {
                                        listOfPlayLists[listTitle.text] =
                                            createPlayList(listTitle.text, () {
                                          setState(() {
                                            titleOfOpenedList = listTitle.text;
                                            openPlayList = true;
                                            text = t;
                                          });
                                          getSongsOfList();
                                        }, () {
                                          alertDeletePlayList(context, t,
                                              () async {
                                            for (int i = 0; i < 150; i++) {
                                              if (pref.getInt(
                                                      "${pref.getString("list,$i")},$i") !=
                                                  null) {
                                                pref.remove(
                                                    "${pref.getString("list,$i")},$i");
                                              }
                                            }

                                            for (int i = 1; i < 10; i++) {
                                              if (pref.getString("list,$i") ==
                                                  t) {
                                                setState(() {
                                                  listOfPlayLists.remove(t);
                                                  pref.remove("list,$i");
                                                });
                                                // Navigator.pop(context);
                                              }
                                            }
                                          });
                                        });
                                      });

                                      Navigator.pop(context);

                                      for (int i = 1; i < 10; i++) {
                                        if (pref.getString("list,$i") == null) {
                                          pref.setString(
                                              "list,$i", listTitle.text);
                                          break;
                                        }
                                      }
                                      listTitle.clear();
                                      setState(() {
                                        openDrawer = false;
                                      });
                                      pageController.animateToPage(1,
                                          duration: 400.ms,
                                          curve: Curves.easeInOut);
                                    }
                                  });
                                }, Icons.create, 200),
                                drawerButton(
                                    const Color(0xFFF56D91), "Settings", () {
                                  alert(context);
                                }, Icons.settings, 200),
                                drawerButton(const Color(0xFFFFD369), "About",
                                    () {}, Icons.info, 200),
                                drawerButton(
                                    const Color(0xFF674188), "Reset data",
                                    () async {
                                  alertResetWarning(context, () async {
                                    setState(() {
                                      listOfPlayLists.clear();
                                    });
                                    pref.clear();
                                    Navigator.pop(context);
                                    Timer(const Duration(milliseconds: 500),
                                        () {
                                      alertReset(context);
                                    });
                                  });
                                }, Icons.restore, 200),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ),
                      )
                          .animate(controller: controllerOfDrawer)
                          .slideX(
                            begin: -1,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeInOut,
                          )
                          .fadeIn(
                            duration: 300.ms,
                            curve: Curves.easeInOut,
                          )),
              ],
            ),
          ),
        ),
      ),
    ).fadeIn(duration: duration.ms, curve: Curves.easeInOut);
  }

  Widget nowPlaying() {
    return Container(
      color: Colors.transparent,
      width: 100.w,
      child: Column(
        children: [
          SizedBox(
            height: 4.h,
          ),
          Animate(
            child: Container(
              width: 55.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: secondColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.01.h,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                CustomIcons.logo,
                color: mainColor,
                size: 9.h,
              ),
            ),
          ).animate().fadeIn(duration: playAnimations ? 1000.ms : 0.ms).shimmer(
              duration: playAnimations ? 1000.ms : 0.ms,
              curve: Curves.easeInOut),

          SizedBox(
            height: 2.h,
          ),

          // track details -----------------------------------------

          SizedBox(
              width: 80.w,
              child: Column(
                children: [
                  SizedBox(
                    height: 4.h,
                    child: Animate(
                      child: Text(
                          nameOfPlayingSong.isEmpty
                              ? 'Unkown'
                              : nameOfPlayingSong,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:
                              setFontStyle(13.sp, FontWeight.bold, fontColor)),
                    ).animate().fade(delay: playAnimations ? 1500.ms : 0.ms),
                  ),
                  SizedBox(
                    height: 3.h,
                    child: Animate(
                      child: Text(
                        nameOfPlayingAlbum,
                        style: setFontStyle(
                            8.sp, FontWeight.bold, fontColor.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ).animate().fade(delay: playAnimations ? 1800.ms : 0.ms),
                  ),
                ],
              )),
          SizedBox(
            height: 4.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Animate(
                child: Container(
                    width: 15.w,
                    height: 7.5.h,
                    decoration: BoxDecoration(
                      color: secondColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(shadowsOn ? 0.2 : 0),
                          spreadRadius: 0.01.h,
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            repeat = false;
                          });
                          if (playingFromList) {
                            if (shuffle) {
                              int randomNumber =
                                  random.nextInt(audiosOfList.length);
                              selectSong(randomNumber, false, audiosOfList);
                            } else {
                              selectSong(
                                  indexOfCurrentSong - 1, false, audiosOfList);
                            }
                          } else {
                            if (shuffle) {
                              int randomNumber = random.nextInt(audios.length);
                              selectSong(randomNumber, false, audios);
                            } else {
                              selectSong(indexOfCurrentSong - 1, false, audios);
                            }
                          }
                        },
                        icon: RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              CustomIcons.next,
                              color: mainColor,
                            )))),
              )
                  .animate()
                  .slideY(
                      begin: 1,
                      end: 0,
                      curve: Curves.easeInOut,
                      duration: playAnimations ? 700.ms : 0.ms)
                  .fadeIn(
                      curve: Curves.easeInOut,
                      duration: playAnimations ? 700.ms : 0.ms,
                      delay: playAnimations ? 400.ms : 0.ms),
              Animate(
                child: myButton(() {
                  playSong();
                },
                    9.h,
                    19.w,
                    mainColor.withOpacity(0.2),
                    Icon(
                      playingSong ? Icons.pause_rounded : CustomIcons.play,
                      color: mainColor,
                      size: playingSong ? 6.h : 4.h,
                    )),
              )
                  .animate()
                  .slideY(
                      begin: 3,
                      end: 0,
                      curve: Curves.easeInOut,
                      duration: playAnimations ? 1200.ms : 0.ms)
                  .fadeIn(
                      curve: Curves.easeInOut,
                      duration: playAnimations ? 1200.ms : 0.ms,
                      delay: playAnimations ? 500.ms : 0.ms),
              Animate(
                child: myButton(() {
                  setState(() {
                    repeat = false;
                  });
                  if (playingFromList) {
                    if (shuffle) {
                      int randomNumber = random.nextInt(audiosOfList.length);
                      selectSong(randomNumber, false, audiosOfList);
                    } else {
                      selectSong(indexOfCurrentSong + 1, false, audiosOfList);
                    }
                  } else {
                    if (shuffle) {
                      int randomNumber = random.nextInt(audios.length);
                      selectSong(randomNumber, false, audios);
                    } else {
                      selectSong(indexOfCurrentSong + 1, false, audios);
                    }
                  }
                },
                    7.5.h,
                    15.w,
                    mainColor.withOpacity(0.2),
                    Icon(
                      CustomIcons.next,
                      color: mainColor,
                    )),
              )
                  .animate()
                  .slideY(
                      begin: 1,
                      end: 0,
                      curve: Curves.easeInOut,
                      duration: playAnimations ? 700.ms : 0.ms)
                  .fadeIn(
                      curve: Curves.easeInOut,
                      duration: playAnimations ? 700.ms : 0.ms,
                      delay: playAnimations ? 500.ms : 0.ms),
            ],
          ),
          SizedBox(
            height: 3.h,
          ),

          // progress bar -------------------------------------------------

          Stack(
            children: [
              // Container(
              //   width: 85.w,
              //   height: 1.5.h,
              //   decoration: BoxDecoration(
              //       color: const Color(0xFFC6C6C6),
              //       borderRadius: BorderRadius.circular(16)),
              // ),
              // Animate(
              //   child: Container(
              //     width: (progress*85).w,
              //     height: 1.5.h,
              //     decoration: BoxDecoration(
              //         color: mainColor, borderRadius: BorderRadius.circular(16)),
              //   ),
              // ).animate().fadeIn(curve: Curves.easeInOut)

              Animate(
                child: SfSlider(
                  min: 0.0,
                  activeColor: mainColor,
                  max: 85.w,
                  value: barPosition,
                  inactiveColor: secondColor,

                  //  interval: 20,
                  //  showTicks: true,
                  //  showLabels: true,
                  //  enableTooltip: true,
                  minorTicksPerInterval: 1,
                  onChanged: (dynamic value) {
                    setState(() {
                      progress = value;
                      barPosition = value + 1;
                    });
                    assetsAudioPlayer.seek(Duration(
                        seconds: ((duration1.inSeconds) * (progress / 85.w))
                            .toInt()));
                  },
                ),
              ).animate().shimmer(duration: (2000).ms),
            ],
          ),

          Container(
            width: 100.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (assetsAudioPlayer.currentPosition.hasValue)
                  Text(
                    "${assetsAudioPlayer.currentPosition.value.toString().split(":")[1]}:${assetsAudioPlayer.currentPosition.value.toString().split(":")[2].substring(0, 2)}",
                    style: setFontStyle(8.sp, FontWeight.bold, fontColor),
                  ),
                SizedBox(
                  width: 50.w,
                ),
                if (assetsAudioPlayer.current.hasValue)
                  Text(
                    "${assetsAudioPlayer.current.value?.audio.duration.toString().split(":")[1]}:${assetsAudioPlayer.current.valueOrNull?.audio.duration.toString().split(":")[2].substring(0, 2)}",
                    style: setFontStyle(8.sp, FontWeight.bold, fontColor),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          shuffleAnimteDuration == 700
                              ? shuffleAnimteDuration = 701
                              : shuffleAnimteDuration = 700;
                          shuffle = !shuffle;
                        });
                      },
                      icon: Icon(
                        CustomIcons.shuffle,
                        size: 4.h,
                        color: shuffle ? mainColor : mainColor.withOpacity(0.5),
                      )),
                  Animate(
                    child: Text(
                      shuffle ? "Shuffle on" : "Shuffle off",
                      style: setFontStyle(
                          8.sp, FontWeight.bold, fontColor.withOpacity(0.8)),
                    ),
                  ).fadeOut(
                      curve: Curves.easeInOut,
                      duration: shuffleAnimteDuration.ms)
                ],
              ),
              Column(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          repeatAnimteDuration == 700
                              ? repeatAnimteDuration = 701
                              : repeatAnimteDuration = 700;
                          repeat = !repeat;
                        });
                      },
                      icon: Icon(
                        CustomIcons.repeat,
                        size: 4.h,
                        color: repeat ? mainColor : mainColor.withOpacity(0.5),
                      )),
                  Animate(
                    child: Text(
                      repeat ? "Loop on" : "Loop off",
                      style: setFontStyle(
                          8.sp, FontWeight.bold, fontColor.withOpacity(0.8)),
                    ),
                  ).fadeOut(
                      curve: Curves.easeInOut,
                      duration: repeatAnimteDuration.ms)
                ],
              ),
              // IconButton(onPressed: (){}, icon: Icon(CustomIcons.,size: 4.h,)),
            ],
          ),
        ],
      ),
    );
  }

  void selectSong(int index, bool firstTime, List<SongModel> audioList) async {
    if (index == audioList.length) {
      index = 0;
    }
    if (index == -1) {
      index = audioList.length - 1;
    }
    SongModel audio = audioList[index];

    uriOfAvtiveSong = audio.uri.toString();

    if (playingFromList) {
      pref.setString("lastOpenedList", titleOfOpenedList);
    } else {
      pref.remove("lastOpenedList");
    }

    pref.setInt("index", index);

    if (listOfPlayLists["Recently played"] == null) {
      listOfPlayLists["Recently played"] =
          createPlayList("Recently played", () {
        setState(() {
          titleOfOpenedList = "Recently played";
          openPlayList = true;
          text = "Recently played";
        });
        getSongsOfList();
      }, () {});
    }
    if (!alreadyInRecently(index)) {
      for (int i = 0; i < 150; i++) {
        if (pref.getInt("Recently played,$i") == null) {
          pref.setInt("Recently played,$i", index);

          break;
        }
      }
    } else {
      for (int i = 0; i < 150; i++) {
        if (pref.getInt("Recently played,$i") == null) {
          break;
        } else {
          pref.setInt(
              "Recently played,${i + 1}", pref.getInt("Recently played,$i")!);
        }
      }
      pref.setInt("Recently played,${0}", index);
    }

    try {
      await assetsAudioPlayer.open(
          Audio.file(uriOfAvtiveSong,
              metas: Metas(
                  title: audio.title,
                  artist: audio.artist,
                  album: audio.album,
                  image: assetsAudioPlayer.getCurrentAudioImage != null
                      ? MetasImage.asset(
                          assetsAudioPlayer.getCurrentAudioImage!.path)
                      : const MetasImage.asset(
                          "assets/images/logo.png"))), //can be MetasImage.network

          showNotification: true);
      setState(() {
        indexOfCurrentSong = index;
        nameOfPlayingSong = audio.title;
        barPosition = 0;
        progress = 0;
        nameOfPlayingAlbum = audio.album!;
        playingSong = true;
      });

      if (firstTime) {
        setState(() {
          progress = pref.getDouble("progress")!;
          playingSong = false;
          barPosition = pref.getDouble("barPosition")!;
        });
        duration1 = assetsAudioPlayer.current.value!.audio.duration;
        assetsAudioPlayer.seek(
            Duration(seconds: ((duration1.inSeconds) * (progress)).toInt()));
        assetsAudioPlayer.pause();
      }
      updateDuration();
    } catch (t) {
      //stream unreachable
    }
  }

  bool alreadyInRecently(int index) {
    for (int i = 0; i < 150; i++) {
      if (pref.getInt("Recently played,$i") == index) {
        return true;
      }
    }
    return false;
  }

  Widget themeButton(String title, Color color) {
    return TextButton(
      style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent)),
      onPressed: () async {
        pref.setString('theme', title);

        // getAudios(count);

        setState(() {
          mainColor = color;
          openDrawer = false;
          getLists();
          Navigator.pop(context);
        });
      },
      child: Container(
        width: 28.w,
        height: 13.h,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(
          title,
          style: setFontStyle(12.sp, FontWeight.bold, Colors.white),
        )),
      ),
    );
  }

  Widget createSong(int index) {
    var date = DateTime.fromMillisecondsSinceEpoch(audios[index].duration!);

    return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        width: 92.w,
        height: 12.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: secondColor,
          boxShadow: [
            BoxShadow(
              color: secondColor.withOpacity(0.2),
              spreadRadius: 0.01.h,
              blurRadius: 5,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextButton(
          style: ButtonStyle(
              overlayColor:
                  MaterialStateProperty.all(mainColor.withOpacity(0.3))),
          onPressed: () {
            setState(() {
              playingFromList = false;
            });
            selectSong(index, false, audios);
          },
          onLongPress: () {
            alertShowPlayLists(context, index);
          },
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 73.w,
                      height: 4.h,
                      child: Text(
                        audios[index].title,
                        style: setFontStyle(10.sp, FontWeight.bold, fontColor),
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(
                      width: 73.w,
                      height: 3.h,
                      child: Text(
                        audios[index].album ?? "Unkown",
                        style: setFontStyle(
                            8.sp, FontWeight.w500, fontColor.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(
                      width: 73.w,
                      height: 3.h,
                      child: Text(
                        "${date.minute}:${date.second}",
                        style: setFontStyle(9.sp, FontWeight.bold, fontColor),
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                      onPressed: () {
                        alertTrackDetails(
                            context,
                            audios[index].title,
                            audios[index].album,
                            audios[index].size,
                            audios[index].uri,
                            audios[index].dateAdded,
                            date,
                            audios[index].fileExtension);
                      },
                      icon: Icon(
                        Icons.info_outline_rounded,
                        size: 3.5.h,
                        color: fontColor.withOpacity(0.5),
                      )))
            ],
          ),
        ));
  }

  Widget createSongOfList(int index) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(audiosOfList[index].duration!);

    return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        width: 92.w,
        height: 12.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: secondColor,
          boxShadow: [
            BoxShadow(
              color: secondColor.withOpacity(0.2),
              spreadRadius: 0.01.h,
              blurRadius: 5,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextButton(
          style: ButtonStyle(
              overlayColor:
                  MaterialStateProperty.all(mainColor.withOpacity(0.3))),
          onPressed: () async {
            setState(() {
              playingFromList = true;
            });
            selectSong(index, false, audiosOfList);
          },
          onLongPress: () {
            alertShowPlayLists(context, index);
          },
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 73.w,
                      height: 4.h,
                      child: Text(
                        audiosOfList[index].title,
                        style: setFontStyle(10.sp, FontWeight.bold, fontColor),
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(
                      width: 73.w,
                      height: 3.h,
                      child: Text(
                        audiosOfList[index].album ?? "Unkown",
                        style: setFontStyle(
                            8.sp, FontWeight.w500, fontColor.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(
                      width: 73.w,
                      height: 3.h,
                      child: Text(
                        "${date.minute}:${date.second}",
                        style: setFontStyle(9.sp, FontWeight.bold, fontColor),
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                      onPressed: () {
                        alertTrackDetails(
                            context,
                            audiosOfList[index].title,
                            audiosOfList[index].album,
                            audiosOfList[index].size,
                            audiosOfList[index].uri,
                            audiosOfList[index].dateAdded,
                            date,
                            audiosOfList[index].fileExtension);
                      },
                      icon: Icon(
                        Icons.info_outline_rounded,
                        size: 3.5.h,
                        color: fontColor.withOpacity(0.5),
                      )))
            ],
          ),
        ));
  }

  Widget playLists() {
    return Container(
      color: Colors.transparent,
      width: 100.w,
      child: Stack(
        children: [
          Column(children: [
            SizedBox(
              height: 5.h,
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
              child: listOfPlayLists.isNotEmpty
                  ? ListView(itemExtent: 130, children: [
                      for (int i = 0; i < listOfPlayLists.length; i++)
                        listOfPlayLists.values.elementAt(i),
                    ])
                  : Column(
                      children: [
                        SizedBox(height: 25.h),
                        Animate(
                          child: Text(
                            "You have no playlists...",
                            style: setFontStyle(12.sp, FontWeight.bold,
                                fontColor.withOpacity(0.5)),
                          ),
                        ),
                      ],
                    ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
          ]),
          if (openPlayList)
            Animate(
              child: Container(
                  height: 80.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                      color: bodyColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32))),
                  padding: EdgeInsets.only(top: 10.h),
                  child: ListView(
                      itemExtent: 15.h,
                      children: songsOfList.isNotEmpty
                          ? songsOfList
                          : [Text("data")])),
            ).animate(controller: controllerOfList).slideY(
                end: 0,
                begin: 1,
                duration: openPlayList ? 300.ms : 0.ms,
                curve: Curves.easeInOut),
          if (openPlayList)
            Positioned(
              right: 0,
              child: Animate(
                child: Container(
                    margin: EdgeInsets.only(right: 1.h, top: 1.h),
                    width: 13.5.w,
                    height: 6.25.h,
                    decoration: BoxDecoration(
                      color: bodyColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0.01.h,
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: IconButton(
                        onPressed: () {
                          controllerOfList.reverse();
                          Timer(const Duration(seconds: 1), () {
                            setState(() {
                              openPlayList = false;
                              text = titlesOfPages[1];
                            });
                          });
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          size: 4.h,
                          color: mainColor.withOpacity(0.7),
                        ))),
              ).animate(controller: controllerOfList).fadeIn(
                  duration: 400.ms, curve: Curves.easeInOut, delay: 400.ms),
            ),
        ],
      ),
      //     Container(width: 100.w,height: 100.h,
      // color: Colors.black.withOpacity(0.5),),
    );
  }

  Future getSongsOfList() async {
    songsOfList.clear();
    playlistSongsIndex.clear();
    audiosOfList.clear();
    int count = 0;

    for (int i = 0; i < 150; i++) {
      if (pref.getInt("$titleOfOpenedList,$i") == null) {
        break;
      } else {
        setState(() {
          audiosOfList.add(audios[pref.getInt("$titleOfOpenedList,$i")!]);
          songsOfList.add(createSongOfList(count));
          count++;
        });
      }
    }
  }
}
