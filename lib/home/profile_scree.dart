
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_verynew/model/user_details.dart';
import 'package:todo_verynew/presentation/authentication/login_screen.dart';
import 'package:todo_verynew/util/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserDetails? currentUserDetails;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  final currentUser = FirebaseAuth.instance.currentUser; //get current user from offline data saved.
  bool isLoading = true;

  @override
  void initState(){
    fatchUserProfile();
    super.initState();
  }

 Future<void> fatchUserProfile() async {
  setState(() {
    isLoading = true;
  });

  if (currentUser == null) {
    await _logout();
    return;
  }

  try {
    final userProfile = await FirebaseFirestore.instance
        .collection('/user')
        .doc(currentUser!.uid) 
        .get();

    if (!userProfile.exists || userProfile.data() == null) {
    
      firstNameController = TextEditingController(text: '');
      lastNameController = TextEditingController(text: '');
    } else {
   
      currentUserDetails = UserDetails.fromJson(userProfile.data()!);
      firstNameController =
          TextEditingController(text: currentUserDetails?.firstname ?? '');
      lastNameController =
          TextEditingController(text: currentUserDetails?.lastname ?? '');
    }
  } catch (e) {
  
    debugPrint("Error fetching user profile: $e");
    firstNameController = TextEditingController(text: '');
    lastNameController = TextEditingController(text: '');
  }

  setState(() {
    isLoading = false;
  });
}

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });
    final firestor = FirebaseFirestore.instance;
    currentUserDetails?.firstname = firstNameController.text;
    currentUserDetails?.lastname = lastNameController.text;
    if (currentUserDetails == null) {
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      await firestor
          .collection('/user')
          .doc(currentUser?.uid)
          .update(currentUserDetails!.profileNameToJson());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false);
    } catch (e) {
      if (!mounted) return;
      AppConstans.showSnackBar(
        isSuccess: false,
        context,
        message: 'Error logging out',
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
         ? const Center(
             child: CircularProgressIndicator(),
           )
        //  : currentUserDetails == null
        //      ? const Center(
        //          child: Text('No details found'),
        //        )
             :Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           const SizedBox(height: 40),
                  
           // User Avatar
           CircleAvatar(
             radius: 50,
             backgroundColor: Colors.deepPurple.shade100,
             child: Icon(
               Icons.person,
               size: 50,
               color: Colors.deepPurple.shade400,
             ),
           ),
                  
           const SizedBox(height: 20),
                  
           // User Email
           Text(
             user?.email ?? 'No email',
             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                   fontWeight: FontWeight.bold,
                 ),
             textAlign: TextAlign.center,
           ),
                  
           const SizedBox(height: 8),
                  
           Text(
             'Welcome to TodoEasy',
             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                   color: Colors.grey[600],
                 ),
             textAlign: TextAlign.center,
           ),
           SizedBox(
             height: 24,
           ),
           Form(
               key: _formKey,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   TextFormField(
                     controller: firstNameController,
                     decoration: InputDecoration(
                       hintText: 'first name',
                       filled: true,
                       fillColor: const Color.fromARGB(255, 243, 251, 255),
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: const Color.fromARGB(255, 238, 208, 205),
                           width: 1.2,
                         ),
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: Color.fromARGB(255, 7, 65, 26),
                           width: 1.5,
                         ),
                       ),
                     ),
                   ),
                   SizedBox(
                     height: 20,
                   ),
                   TextFormField(
                     controller: lastNameController,
                     autovalidateMode: AutovalidateMode.onUserInteraction,
                     decoration: InputDecoration(
                       hintText: 'last name',
                       filled: true,
                       fillColor: const Color.fromARGB(255, 243, 251, 255),
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: const Color.fromARGB(
                               255, 238, 208, 205), // light red
                           width: 1.2,
                         ),
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: Color.fromARGB(255, 7, 65, 26),
                           width: 1.5,
                         ),
                       ),
                     ),
                   )
                 ],
               )),
           SizedBox(height: 24,),
           ElevatedButton(onPressed: (){
             _saveProfile();
             
           },
            style: ElevatedButton.styleFrom(
               backgroundColor: const Color.fromARGB(255, 128, 244, 142),
               foregroundColor: const Color.fromARGB(255, 35, 35, 35),
               padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
               minimumSize: const Size(double.infinity, 50),
             ),
             child: const Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.save),
                 SizedBox(width: 8),
                 Text(
                   'Save',
                   style: TextStyle(fontSize: 16),
                 ),
               ],
             )
           ),
           // Logout Button\
           SizedBox(height: 12,),
           ElevatedButton(
             onPressed: () {
              _logout();
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.red,
               foregroundColor: Colors.white,
               padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
               minimumSize: const Size(double.infinity, 50),
             ),
             child: const Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.logout),
                 SizedBox(width: 8),
                 Text(
                   'Logout',
                   style: TextStyle(fontSize: 16),
                 ),
               ],
             ),
           ),
                  
           const SizedBox(height: 20),
         ],
                  ),
      ),
    );
  }
}
