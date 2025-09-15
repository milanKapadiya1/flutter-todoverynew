// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:todo_verynew/model/user_details.dart';

// // class SteamEx extends StatefulWidget {
// //   const SteamEx({super.key});

// //   @override
// //   State<SteamEx> createState() => _SteamExState();
// // }

// // class _SteamExState extends State<SteamEx> {
// //   final firbaseFireStore = FirebaseFirestore.instance;
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: StreamBuilder(
// //         stream: firbaseFireStore
// //         .collection('/user')
// //          .doc('CXetyLwzR3TGCVg1l2dd')
// //          .snapshots(),

// //         builder: (context, data){
// //          if(data.hasData){
// //           if(data.requireData.data()==null){
// //             return Text("No data");
// //           }
// //           final userDetails = UserDetails.fromJson(data.requireData.data()!);
// //           return Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //                Text(userDetails.uid.toString()),
// //                Text(userDetails.email.toString()),
// //                Text(userDetails.password.toString()),
// //                Text(userDetails.firstname.toString()),
// //                Text(userDetails.lastname.toString()),

// //             ],
// //           ),
// //           );
// //          }
// //          return Text('no data found');
// //         }
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:todo_verynew/model/user_details.dart';

// class SteamEx extends StatefulWidget {
//   const SteamEx({super.key});

//   @override
//   State<SteamEx> createState() => _SteamExState();
// }

// class _SteamExState extends State<SteamEx> {
//   final _firebaseFirestore = FirebaseFirestore.instance;
//   // final _authUser = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       body: StreamBuilder(
//           stream: _firebaseFirestore
//               .collection('/user')
//               .doc('a3NO4D6lBtvFbHT9f0Hx')
//               .snapshots(),
//           builder: (context, data) {
//             if (data.hasError) {
//               return const Center(
//                 child: Text('something wrong'),
//               );
//             }
//             if (data.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//             if (!data.hasData || data.data == null) {
//               return const Center(
//                 child: Text('no user'),
//               );
//             }
//             final userDetails = UserDetails.fromJson(data.requireData.data()!);

//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(userDetails.uid.toString()),
//                   Text(userDetails.email.toString()),
//                   Text(userDetails.firstname.toString()),
//                   Text(userDetails.lastname.toString()),
//                 ],
//               ),
//             );
//           }),
//     ));
//   }
// }
