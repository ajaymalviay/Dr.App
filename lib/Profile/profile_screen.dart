import 'dart:convert';
import 'dart:io';

import 'package:doctorapp/api/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/Appbar.dart';
import '../Helper/Color.dart';
import 'package:http/http.dart' as http;
import '../New_model/Check_plan_model.dart';
import '../New_model/getUserProfileModel.dart';
import 'EditeProfile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool isLoder =true;
  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<bool> showExitPopup() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text('Select Image'),
          content: Row(
            // crossAxisAlignment: CrossAxisAlignment.s,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // _getFromCamera();
                },

                child: Text('Camera'),
              ),
              const SizedBox(
                width: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  // _getFromGallery();
                  // Navigator.pop(context,true);
                  // Navigator.pop(context,true);
                },
                //return true when click on "Yes"
                child: Text('Gallery'),
              ),
            ],
          )),
    ) ??
        false; //if showDialouge had returned null, then return false
  }

  // _getFromGallery() async {
  //   final XFile? pickedFile =
  //   await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
  //   /* PickedFile? pickedFile = await ImagePicker().getImage(
  //     source: ImageSource.gallery,
  //   );*/
  //   if (pickedFile != null) {
  //     setState(() {
  //       imageFile = File(pickedFile.path);
  //     });
  //     Navigator.pop(context);
  //   }
  // }

  // _getFromCamera() async {
  //   final XFile? pickedFile =
  //   await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
  //   /*  PickedFile? pickedFile = await ImagePicker().getImage(
  //     source: ImageSource.camera,
  //   );*/
  //   if (pickedFile != null) {
  //     setState(() {
  //       imageFile = File(pickedFile.path);
  //     });
  //     Navigator.pop(context);
  //   }
  // }

  GetUserProfileModel? getprofile;
  getuserProfile() async {
    setState(() {
      isLoder == true ? const Center(child: CircularProgressIndicator()):SizedBox();
    });
    print("This Is User profilel============>");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('userId');
    print('this is getProfile==========Data----------->${userId} ');
    var headers = {
      'Cookie': 'ci_session=9aba5e78ffa799cbe054723c796d2bd8f2f7d120'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiService.getUserProfile}'));
    request.fields.addAll({'user_id': "${userId}"});
    print("ths is userId=========>i11111qqqq${request.fields}");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      print('__________${finalResult}_____________');
      final jsonResponse = GetUserProfileModel.fromJson(json.decode(finalResult));
      print("this is userIddd=========>${jsonResponse}");
      setState(() {
        getprofile = jsonResponse;

      });
    } else {
      print(response.reasonPhrase);
    }
  }
  CheckPlanModel? checkPlanModel;
  checkSubscriptionApi() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('userId');
    var headers = {
      'Cookie': 'ci_session=64caa747045713fca2e42eb930c7387e303fd583'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${ApiService.getCheckSubscriptionApi}'));
    request.fields.addAll({
      'user_id': "$userId"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var  result = await response.stream.bytesToString();
      var finalResult = CheckPlanModel.fromJson(jsonDecode(result));
      print('____Bew Api______${finalResult}_________');
      setState(() {
        checkPlanModel =  finalResult ;
      });
    }
    else {
      print(response.reasonPhrase);
    }

  }

  // userProfile() async {
  //
  //   var headers = {
  //     'Cookie': 'ci_session=bacf39f3998692bb37277bfd0e78e137fbd49a22'
  //   };
  //   var request = http.MultipartRequest('POST', Uri.parse('https://developmentalphawizz.com/dr_booking/app/v1/api/user_profile'));
  //   request.fields.addAll({
  //     'user_id': '49'
  //   });
  //
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //
  //     print(await response.stream.bytesToString());
  //   }
  //   else {
  //   print(response.reasonPhrase);
  //   }
  //
  // }
  void initState() {
    super.initState();
    checkSubscriptionApi();
    Future.delayed(Duration(milliseconds:300), () {
      return getuserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("My Profile pic is here U can ------${getprofile?.user?.profilePic}");
    return Scaffold(
      bottomSheet:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
             color:colors.secondary,
            borderRadius: BorderRadius.circular(10)
          ),
          height: 50,
          child: InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditeProfile(getUserProfileModel: getprofile ?? GetUserProfileModel(),
                  ),
                ),
              ).then((value) => getuserProfile());
            },
            child: Center(child: Text("Edit Profile",style: TextStyle(color: colors.whiteTemp),))
          ),
        ),
      ),
      appBar: customAppBar(text: "Profile", isTrue: true, context: context),
      body: SingleChildScrollView(
        child: getprofile == null || getprofile == null
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : Padding(
          padding: const EdgeInsets.only(left: 10,right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Stack(children: [
                /*Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          // color: whiteColor
                        ),
                        child: imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(
                                  imageFile!,
                                  fit: BoxFit.cover,
                                ))
                            : Image.asset('assets/images/tablets.png'),
                      ),*/
                Card(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)
                  ),
                  elevation: 3,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: getprofile?.user?.profilePic == null ||
                        getprofile?.user?.profilePic == ""
                        ? Image.asset('assets/images/tablets.png')
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        "${getprofile?.user?.profilePic}",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(
                height: 10,
              ),
              // Text('${getprofile?.user?.username}',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${getprofile?.user?.userData?[0].title}",style: TextStyle(color: colors.blackTemp,fontWeight: FontWeight.bold),),
                  Text("${getprofile?.user?.username}"),
                ],
              ),

              const SizedBox(
                height: 40,
              ),
            Card(
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Email id',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          // padding: EdgeInsets.only(left: 30),
                            child: Text(
                              "${getprofile?.user?.userData?.first.email}",
                            ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mobile Number',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text("${getprofile?.user?.userData?.first.mobile}"),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Experience',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text("${getprofile?.user?.userData?.first.experience}"),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Company Name',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child:getprofile?.user?.userData?.first.companyName == null || getprofile?.user?.userData?.first.companyName == ""? Text("No Name"):Text("${getprofile?.user?.userData?.first.companyName}"),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dr.Degree',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child:getprofile?.user?.userData?.first.docDigree == null || getprofile?.user?.userData?.first.docDigree == ""? Text("No Name"):Text("${getprofile?.user?.userData?.first.docDigree}"),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gender',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text("${getprofile?.user?.userData?.first.gender}"),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('City Name',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text("${getprofile?.user?.userData?.first.cityName}"),
                        )
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       const Text('Place Name',
                  //           style: TextStyle(
                  //               fontSize: 15, fontWeight: FontWeight.w700)),
                  //       const SizedBox(
                  //         width: 50,
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.only(left: 0.0),
                  //         child: Text("${getprofile?.user?.userData?.first.placeName}"),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  Container(
                    height:MediaQuery.of(context).size.height/1.3,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: getprofile?.user?.userData?.first.clinics?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 5,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text("Clinic/Hospital Name",style: TextStyle(color: colors.blackTemp,fontWeight: FontWeight.bold),),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("${getprofile?.user?.userData?.first.clinics?[index].clinicName}",style: TextStyle(color: colors.blackTemp,),),
                                    )
                                  ],),
                                )
                               ,
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      const Text(
                                        'Available Days',
                                        style: TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        // padding: EdgeInsets.only(left: 30),
                                          child: Container(
                                            child: Text(
                                              "${getprofile?.user?.userData?.first.clinics?[index].day}",
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Morning Shift',
                                          style: TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w700)),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0.0),
                                        child: Text("${getprofile?.user?.userData?.first.clinics?[index].morningShift}"),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Evening Shift',
                                          style: TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w700)),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0.0),
                                        child: Text("${getprofile?.user?.userData?.first.clinics?[index].eveningShift}"),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Address',
                                          style: TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w700)),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Container(
                                        width: 140,
                                          child: Text("${getprofile?.user?.userData?.first.clinics?[index].addresses}",overflow: TextOverflow.ellipsis,maxLines: 2,))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Appoint Number',
                                          style: TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w700)),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0.0),
                                        child: Text("${getprofile?.user?.userData?.first.clinics?[index].appointNumber}"),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Place Name',
                                          style: TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w700)),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0.0),
                                        child: Text("${getprofile?.user?.userData?.first.placeName}"),
                                      )
                                    ],
                                  ),
                                ),
                                // SizedBox(height: 10,)


                              ],
                            ),
                          );
                        }),
                  ),


                ],
              ),
            ),

              checkPlanModel == null || checkPlanModel == "" ? SizedBox.shrink():  Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                    child: Text("My Subscription Plan",style: TextStyle(color: colors.secondary,fontWeight: FontWeight.bold,fontSize: 20),)),
              ),
              checkPlanModel == null || checkPlanModel == "" ? SizedBox.shrink():  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: .0, vertical: 2.0),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      height: 200,
                      child: ListView.builder(
                          itemCount: checkPlanModel!.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return  Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 5,
                              child: ListTile(
                                title: Text(
                                  "${checkPlanModel!.data![index].name}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text( "${checkPlanModel!.data![index].description}"),
                                    SizedBox(height: 8),
                                    Text( "${checkPlanModel!.data![index].time}"),
                                    SizedBox(height: 8),

                                    Text("₹ ${checkPlanModel!.data![index].amount}"),
                                    SizedBox(height: 8),

                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${checkPlanModel!.data![index].purchaseDate}"),
                                    SizedBox(height: 8),
                                    Text("${checkPlanModel!.data![index].expiryDate}"),
                                    SizedBox(height: 8),
                                  ],
                                ),
                                // trailing: getPlan!.data![index].isPurchased == true ? Container(
                                //   height: 30,
                                //   width: 90,
                                //   decoration: BoxDecoration(
                                //       color: colors.secondary,
                                //       borderRadius: BorderRadius.circular(10)
                                //   ),
                                //   child: Center(child: Text("Purchased",style: TextStyle(color: colors.whiteTemp,fontWeight: FontWeight.bold),)),
                                // ):SizedBox.shrink()
                              ),
                            );
                          }),
                    ),


                  )
              )


            ],
          ),
        ),
      ),
    );
  }
}
