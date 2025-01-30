// import 'dart:io';
//
// import 'package:shakti/singletons/NotificationService.dart';
// import 'package:shakti/state/auth/auth_bloc.dart';
// import 'package:shakti/state/httpStates.dart';
// import 'package:shakti/widgets/CustomElevatedButton.dart';
// import 'package:shakti/widgets/CustomTextButton.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../widgets/CustomInputField.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final formKey = GlobalKey<FormState>(debugLabel: 'registerForm');
//   final ImagePicker imagePicker = ImagePicker();
//   XFile? profileImage = null;
//   XFile? coverImage = null;
//
//   final _defaultCoverImagePath = "assets/images/ram_poster_sm.jpg";
//   final _defaultProfileImagePath = "assets/images/ram_dp_sm.jpg";
//   late final ImageProvider defaultCoverImage;
//   late final ImageProvider defaultProfileImage;
//   final TextEditingController firstNameCntrl = TextEditingController(text: '');
//   final TextEditingController lastNameCntrl = TextEditingController(text: '');
//   final TextEditingController usernameControllerCntrl = TextEditingController(text: '');
//   final TextEditingController emailCntrl = TextEditingController(text: '');
//   final TextEditingController passwordCntrl = TextEditingController(text: '');
//   final CancelToken cancelToken = CancelToken();
//
//   @override
//   void initState() {
//     defaultCoverImage = AssetImage(_defaultCoverImagePath);
//     defaultProfileImage = AssetImage(_defaultProfileImagePath);
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthBloc, AuthState>(
//         listener: (ctx, state) {
//           if (state.success) {
//             NotificationService.showSnackbar(text: state.message ?? "registered successfully");
//             GoRouter.of(context).goNamed(Routing.login.name);
//           }
//         },
//         builder: (context, state) => Scaffold(
//               appBar: AppBar(
//                 title: const Text(
//                   'Registration',
//                   style: TextStyle(color: Colors.white, fontFamily: "Kalam", fontSize: 32, fontWeight: FontWeight.bold),
//                 ),
//                 centerTitle: true,
//                 elevation: 10,
//                 backgroundColor: Theme.of(context).primaryColor,
//               ),
//               body: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(18.5),
//                   child: Form(
//                     key: formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Stack(
//                           alignment: Alignment.bottomCenter,
//                           clipBehavior: Clip.none,
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 4.5),
//                               padding: const EdgeInsets.all(5.5),
//                               constraints: const BoxConstraints(maxHeight: 150, minHeight: 150, minWidth: double.infinity),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5),
//                                   image: DecorationImage(
//                                     image: (coverImage != null ? FileImage(File(coverImage!.path)) : defaultCoverImage) as ImageProvider,
//                                     fit: BoxFit.fitWidth,
//                                     alignment: Alignment.topCenter,
//                                     repeat: ImageRepeat.noRepeat,
//                                   )),
//                               child: Align(
//                                 alignment: Alignment.topRight,
//                                 child: CameraIconButton(onPressed: () async {
//                                   var posterImage = await imagePicker.pickImage(source: ImageSource.gallery);
//                                   setState(() {
//                                     if (!mounted) return;
//                                     coverImage = posterImage;
//                                   });
//                                 }),
//                               ),
//                             ),
//                             Positioned(
//                                 top: 98.5,
//                                 child: Card(
//                                   shape: const CircleBorder(side: BorderSide(color: Colors.black26)),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: CircleAvatar(
//                                       radius: 45.6,
//                                       backgroundImage: profileImage != null ? FileImage(File(profileImage!.path)) : defaultProfileImage as ImageProvider,
//                                       child: Align(
//                                         alignment: Alignment.center,
//                                         child: CameraIconButton(onPressed: () async {
//                                           var profileImage = await imagePicker.pickImage(source: ImageSource.gallery);
//                                           setState(() {
//                                             if (!mounted) return;
//                                             this.profileImage = profileImage;
//                                           });
//                                         }),
//                                       ),
//                                     ),
//                                   ),
//                                 ))
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 65,
//                         ),
//                         CustomInputField(
//                             controller: firstNameCntrl,
//                             hintText: "vishnu",
//                             labelText: "First Name",
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter first name';
//                               }
//                               return null;
//                             }),
//                         const SizedBox(
//                           height: 7,
//                         ),
//                         CustomInputField(
//                             controller: lastNameCntrl,
//                             hintText: "kumar",
//                             labelText: "Last Name",
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter last name';
//                               }
//                               return null;
//                             }),
//                         const SizedBox(
//                           height: 7,
//                         ),
//                         CustomInputField(
//                             controller: usernameControllerCntrl,
//                             hintText: "vi5hnu",
//                             labelText: "Username",
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter username';
//                               }
//                               return null;
//                             }),
//                         const SizedBox(
//                           height: 7,
//                         ),
//                         CustomInputField(
//                             controller: emailCntrl,
//                             hintText: "xyz@gmail.com",
//                             labelText: "Email",
//                             suffixIcon: const Icon(Icons.email_outlined),
//                             validator: (value) {
//                               if (value == null || !value.contains("@gmail.com")) {
//                                 return 'Please enter valid email id';
//                               }
//                               return null;
//                             }),
//                         const SizedBox(
//                           height: 7,
//                         ),
//                         CustomInputField(
//                             controller: passwordCntrl,
//                             obscureText: true,
//                             hintText: "as4c45a65s",
//                             labelText: "password",
//                             suffixIcon: const Icon(Icons.password),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter valid password';
//                               }
//                               return null;
//                             }),
//                         const SizedBox(
//                           height: 18,
//                         ),
//                         CustomElevatedButton(
//                             onPressed: state.isLoading(forr: Httpstates.REGISTER)
//                                 ? null
//                                 : () async {
//                                     if (formKey.currentState?.validate() == false) {
//                                       return;
//                                     }
//
//                                     BlocProvider.of<AuthBloc>(context).add(RegisterEvent(
//                                         profilePic: (this.profileImage != null
//                                             ? await MultipartFile.fromFile(this.profileImage!.path)
//                                             : await _getDefaultProfileImage(assetPath: _defaultProfileImagePath)) as MultipartFile,
//                                         posterPic: (this.coverImage != null ? await MultipartFile.fromFile(this.coverImage!.path) : await _getDefaultCoverImage(assetPath: _defaultCoverImagePath))
//                                             as MultipartFile,
//                                         firstName: firstNameCntrl.text,
//                                         lastName: lastNameCntrl.text,
//                                         username: usernameControllerCntrl.text,
//                                         email: emailCntrl.text,
//                                         password: passwordCntrl.text,
//                                         cancelToken: cancelToken));
//                                   },
//                             child: const Text(
//                               'Register',
//                               style: TextStyle(color: Colors.white, fontSize: 18),
//                             )),
//                         if (state.isError(forr: Httpstates.REGISTER))
//                           Text(
//                             state.getError(forr: Httpstates.REGISTER)!.message,
//                             textAlign: TextAlign.center,
//                           ),
//                         const SizedBox(height: 12),
//                         CustomTextButton(
//                             onPressed: state.isLoading(forr: Httpstates.REGISTER)
//                                 ? null
//                                 : () {
//                                     GoRouter.of(context).goNamed(Routing.login.name);
//                                   },
//                             child: const Text('Sign-in instead')),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ));
//   }
//
//   Future<MultipartFile> _getDefaultCoverImage({required String assetPath}) async {
//     final bytes = await rootBundle.load(assetPath);
//     return MultipartFile.fromBytes(bytes.buffer.asUint8List(), filename: 'cover.png');
//   }
//
//   Future<MultipartFile> _getDefaultProfileImage({required String assetPath}) async {
//     final bytes = await rootBundle.load(assetPath);
//     return MultipartFile.fromBytes(bytes.buffer.asUint8List(), filename: 'profile.png');
//   }
//
//   @override
//   void dispose() {
//     cancelToken.cancel("register cancelled");
//     super.dispose();
//   }
// }
