import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/res/components/custom_widgets.dart';
import 'package:trackerapp/utils/constant_colors.dart';
import 'package:trackerapp/utils/constant_styles.dart';

class NewVehicleListDashBoard extends StatefulWidget {
  const NewVehicleListDashBoard({super.key});

  @override
  State<NewVehicleListDashBoard> createState() => _NewVehicleListDashBoardState();
}

class _NewVehicleListDashBoardState extends State<NewVehicleListDashBoard>
    with SingleTickerProviderStateMixin {
  bool _isFilterOpen = false;

  final List<Map<String, dynamic>> statuses = [
    {"title": "Offline", "count": 104, "color": Colors.blue},
    {"title": "Running", "count": 80, "color": Colors.green},
    {"title": "Stopped", "count": 20, "color": Colors.red},
    {"title": "Idle", "count": 5, "color": Colors.orange},
    {"title": "No Data", "count": 200, "color": Colors.grey},
    {"title": "Expired", "count": 150, "color": Colors.purple},
  ];
  final List<Map<String,dynamic>>vehicles=[
    {
      "titles":"AAT-829","Speed":"0","Update":"11:10:2023 09:23:45 PM","Address":"گلشنِ اقبال، بلاک 7، نزد سفاری پارک، کراچی","image":"https://cdn.pixabay.com/photo/2013/07/13/11/50/car-158795_1280.png","status":"Running"
    },
    {
      "titles":"ABT-859","Speed":"0","Update":"11:10:2023 09:23:45 PM","Address":"گلشنِ اقبال، بلاک 7، نزد سفاری پارک، کراچی","image":"https://cdn.pixabay.com/photo/2017/04/06/16/57/car-2208807_1280.png","status":"Stopped"
    },
    {
      "titles":"ABT-859","Speed":"0","Update":"11:10:2023 09:23:45 PM","Address":"گلشنِ اقبال بلاک 13، مین یونیورسٹی روڈ، نزدیک بیت المکرم مسجد، کراچی، پاکستان","image":"https://cdn.pixabay.com/photo/2013/07/13/11/48/bmw-158703_1280.png","status":"Idle"
    },
    {
      "titles":"ABT-859","Speed":"0","Update":"11:10:2023 09:23:45 PM","Address":"نارتھ ناظم آباد بلاک H، مدینہ مارکیٹ کے قریب، شاہراہِ نورجہاں، کراچی، سندھ، پاکستان","image":"https://cdn.pixabay.com/photo/2012/04/13/21/05/car-33633_1280.png","status":"Offline"

    },
    {
      "titles":"ABT-859","Speed":"0","Update":"11:10:2023 09:23:45 PM","Address":"نارتھ ناظم آباد بلاک H، مدینہ مارکیٹ کے قریب، شاہراہِ نورجہاں، کراچی، سندھ، پاکستان","image":"https://cdn.pixabay.com/photo/2013/07/13/11/48/bmw-158703_1280.png","status":"NoData"

    },
    {
      "titles":"ABT-859","Speed":"0","Update":"11:10:2023 09:23:45 PM","Address":"نارتھ ناظم آباد بلاک H، مدینہ مارکیٹ کے قریب، شاہراہِ نورجہاں، کراچی، سندھ، پاکستان","image":"https://cdn.pixabay.com/photo/2023/09/26/19/51/bmw-8278129_1280.png","status":"Running"


    },
  ];

  double boxWidth = 15.5.w;
  double boxHeight = 4.5.h;
  double baseCircleSize = 3.2.h;

// Add this for multi-selection
  final Set<String> _selectedGroups = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          verticalSpace(height: 4.h),
          // Horizontal Status Boxes
          SizedBox(
            height: (boxHeight + baseCircleSize / 2) + 2.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                String countStr = status["count"].toString();
                int digits = countStr.length;
                double circleSize = baseCircleSize +
                    (digits > 3 ? (digits - 3) * 0.4.h : 0);
                double fontSize = digits > 4 ? 10.sp : 12.sp;
                return Padding(
                  padding: EdgeInsets.only(right: 1.w),
                  child: SizedBox(
                    width: boxWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: circleSize / 2,
                          child: Container(
                            width: boxWidth,
                            height: boxHeight,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              status["title"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: (boxWidth - circleSize) / 2,
                          child: Container(
                            width: circleSize,
                            height: circleSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: status["color"],
                                width: 2,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                countStr,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          verticalSpace(height: 1.h),
// Search + Filter Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: ConstantColors.blueCyan,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: ConstantColors.borderColor),
                            borderRadius: BorderRadius.circular(30)),
                        isCollapsed: true,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ConstantColors.blueCyan),
                            borderRadius: BorderRadius.circular(30)),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Icon(Icons.search_outlined),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          maxHeight: 3.h,
                        )),
                  ),
                ),
                horizontalSpace(width: 3.w),

// Filter Button with Toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFilterOpen = !_isFilterOpen;
                    });
                  },
                  child: Container(
                    height: 5.h,
                    width: 5.h,
                    decoration: BoxDecoration(
                      color: ConstantColors.borderColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 800),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: _isFilterOpen
                          ? Icon(Icons.close, key: ValueKey('close'))
                          : Image.asset("assets/images/filter.png",
                          key: ValueKey('filter')),
                    ),
                  ),
                ),
              ],
            ),
          ),

// Animated Filter Group Panel
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: _isFilterOpen ? 40.h : 0,
            width: double.infinity,
            margin: EdgeInsets.only(
                right: 5.w,
                left: 25.w,
                top: 1.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: ConstantColors.borderColor.withOpacity(0.4), blurRadius: 6, offset: Offset(0, 0),spreadRadius: 0)
              ],
            ),
            child: _isFilterOpen
                ? ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildGroupItem("Group A"),
                _buildGroupItem("Group B"),
                _buildGroupItem("Group C"),
                _buildGroupItem("Group D"),
              ],
            )
                : null,
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                itemCount: vehicles.length,
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    padding: EdgeInsets.all(1.h),
                    decoration: BoxDecoration(
                      color: ConstantColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                              // top: BorderSide(
// color:vehicles[index]["status"]=="Running"?ConstantColors.green:vehicles[index]["status"]=="Stopped"?ConstantColors.red:
// vehicles[index]["status"]=="Idle"?ConstantColors.yellow:vehicles[index]["status"]=="Offline"?ConstantColors.blueCyan:
// ConstantColors.purple,
// width: .5.w
// ),
// bottom: BorderSide(
// color:vehicles[index]["status"]=="Running"?ConstantColors.green:vehicles[index]["status"]=="Stopped"?ConstantColors.red:
// vehicles[index]["status"]=="Idle"?ConstantColors.yellow:vehicles[index]["status"]=="Offline"?ConstantColors.blueCyan:
// ConstantColors.purple,
// width: .5.w
// ),
// right: BorderSide(
// color:vehicles[index]["status"]=="Running"?ConstantColors.green:vehicles[index]["status"]=="Stopped"?ConstantColors.red:
// vehicles[index]["status"]=="Idle"?ConstantColors.yellow:vehicles[index]["status"]=="Offline"?ConstantColors.blueCyan:
// ConstantColors.purple,
// width: .5.w
// ),
                          left: BorderSide(
                              color:vehicles[index]["status"]=="Running"?ConstantColors.green:vehicles[index]["status"]=="Stopped"?ConstantColors.red:
                              vehicles[index]["status"]=="Idle"?ConstantColors.yellow:vehicles[index]["status"]=="Offline"?ConstantColors.blueCyan:
                              ConstantColors.purple,
                              width: .5.w
                          )
                      ),

                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        horizontalSpace(width: 1.w),
                        SizedBox(
                            width: 30.w,
                            height: 12.h,
                            child: Image.network(vehicles[index]['image'])),
                        horizontalSpace(width: 6.w),
                        Flexible(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/caricon.png",
                                    height: 2.4.h,),
                                  horizontalSpace(width: 2.w),
                                  Text(vehicles[index]["titles"],style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 15.sp),),


                                ],),
                              verticalSpace(height: 1.h),
                              RichText(text: TextSpan(children: [
                                TextSpan(text: 'Speed : ',style: ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontSize: 15.sp)),
                                TextSpan(text: vehicles[index]["Speed"],style: ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.black,fontSize: 14.sp)),
                                TextSpan(text: " km/h",style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 13.sp)),
                              ])),
                              verticalSpace(height: 1.h),
                              RichText(text: TextSpan(children: [
                                TextSpan(text: 'Status : ',style: ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontSize: 15.sp)),
                                TextSpan(text: vehicles[index]["status"],style: ConstantTextStyles.regularTextStyle.copyWith(
                                    color:vehicles[index]["status"]=="Running"?ConstantColors.green:vehicles[index]["status"]=="Stopped"?ConstantColors.red:
                                    vehicles[index]["status"]=="Idle"?ConstantColors.yellow:vehicles[index]["status"]=="Offline"?ConstantColors.blueCyan:
                                    ConstantColors.purple,fontSize: 14.sp)),
                                TextSpan(text: " 5h 34min 12s",style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 11.sp,color: ConstantColors.grey)),
                              ])),
                              verticalSpace(height: 1.h),
                              RichText(text: TextSpan(children: [
                                TextSpan(text: 'Update : ',style: ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.textBlack,fontSize: 15.sp)),
                                TextSpan(text: vehicles[index]['Update'],style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 13.sp,color: ConstantColors.textBlack)),
                              ])),
                              verticalSpace(height: 1.h),
                              Padding(
                                padding: EdgeInsets.only(right: 3.w),
                                child: Text(vehicles[index]["Address"],style: ConstantTextStyles.lightTextStyle.copyWith(fontSize: 13.sp),textAlign: TextAlign.end,),
                              ),
                              verticalSpace(height: 1.h),
                              Row(children: [
                                Container(alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 1.w),
                                  padding: EdgeInsets.symmetric(horizontal: 2.w,vertical: .5.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: ConstantColors.green
                                      )
                                  ),
                                  child: Text("Live Tracking",style: ConstantTextStyles.lightTextStyle.copyWith(
                                      fontSize: 12.sp
                                  ),),
                                ),
                                Container(alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 1.w),
                                  padding: EdgeInsets.symmetric(horizontal: 2.w,vertical: .5.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),

                                      border: Border.all(
                                          color: ConstantColors.green
                                      )
                                  ),
                                  child: Text("Playback",style: ConstantTextStyles.lightTextStyle.copyWith(
                                      fontSize: 12.sp
                                  ),),
                                ),
                                Container(alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 1.w),
                                  padding: EdgeInsets.symmetric(horizontal: 2.w,vertical: .5.h),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),

                                      border: Border.all(
                                          color: ConstantColors.green
                                      )
                                  ),
                                  child: Text("Reports",style: ConstantTextStyles.lightTextStyle.copyWith(
                                      fontSize: 12.sp
                                  ),),
                                ),
                              ],)

                            ],
                          ),
                        )
                      ],),
                  );
                }),
          )
        ],
      ),
    );
  }

// ✅ Updated method for selectable items without background
  Widget _buildGroupItem(String title) {
    bool isSelected = _selectedGroups.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGroups.remove(title);
          } else {
            _selectedGroups.add(title);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.fromLTRB( 4.w, 1.h, 4.w, 1.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: ConstantTextStyles.regularTextStyle.copyWith(color: ConstantColors.black)),
            isSelected?
            Icon(Icons.check_box_outlined, color: ConstantColors.blueCyan, size: 22): Icon(Icons.check_box_outline_blank, color: ConstantColors.borderColor, size: 22),
          ],
        ),
      ),
    );
  }
}

// class FuelIndicator extends StatelessWidget {
// final int filledBars; // How many bars are filled (0-5)
// final int totalBars; // Total number of bars
// final double barWidth;
// final double barHeight;
//
// const FuelIndicator({
// super.key,
// required this.filledBars,
// this.totalBars = 5,
// this.barWidth = 15,
// this.barHeight = 8,
// });
//
// @override
// Widget build(BuildContext context) {
// return Row(
// mainAxisSize: MainAxisSize.min,
// children: [
// Icon(Icons.local_gas_station, color: Colors.black, size: 24),
// SizedBox(width: 6),
// Row(
// children: List.generate(totalBars, (index) {
// bool isFilled = index < filledBars;
// return Container(
// margin: EdgeInsets.symmetric(horizontal: 2),
// width: barWidth,
// height: barHeight,
// decoration: BoxDecoration(
// color: isFilled ? Colors.green : Colors.grey.shade300,
// borderRadius: BorderRadius.circular(1),
// ),
// );
// }),
// ),
// ],
// );
// }
// }