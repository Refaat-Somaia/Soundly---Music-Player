import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';


var bodyColor =  const Color(0xFF1B1B2F);
var mainColor = const Color(0xFF7E30E1);
var fontColor =const Color(0xFFE7E7E7);
var secondColor=const Color(0xFF132043);
bool openDrawer=false;



TextStyle setFontStyle(double size,FontWeight fontWeight,Color color){
  return TextStyle(fontFamily:'inter',fontSize: size,fontWeight: fontWeight,color:color );
} 







  Widget drawerButton(Color color,String text,void Function()? func,IconData icon,int i){
    return   Container(
        margin: EdgeInsets.only(bottom: 2.h),
                        width: 50.w,
                        child: TextButton(
                          style: ButtonStyle(
      overlayColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          return Colors.transparent;
        },
      ),
      splashFactory: NoSplash.splashFactory,
    ),
                          onPressed: func,
                          
                          child: Row(
                            children: [
                            Container(width: 14.w,height: 7.h,
                            decoration: BoxDecoration(color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16)),
                            child:  Icon(icon,color: color,),),
                            
                            SizedBox(
                          width: 3.w,),
                            Text(text,style: setFontStyle(10.sp, FontWeight.w600, fontColor,))
                          ],),
                        ),
                      );
  }


