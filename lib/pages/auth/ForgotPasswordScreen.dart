// import 'package:shakti/singletons/NotificationService.dart';
// import 'package:shakti/state/HttpStates.dart';
// import 'package:shakti/widgets/CustomElevatedButton.dart';
// import 'package:shakti/widgets/CustomInputField.dart';
// import 'package:shakti/widgets/CustomTextButton.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../routes.dart';
// import '../../state/auth/Auth_bloc.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final CancelToken cancelToken = CancelToken();
//   final formKey = GlobalKey<FormState>(debugLabel: 'loginForm');
//   final TextEditingController usernameEmailController = TextEditingController(text: '');
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthBloc, AuthState>(
//       listenWhen: (previous, current) => previous != current,
//       listener: (ctx, state) {
//         if (state.isError(forr: HttpStates.FORGOT_PASSWORD)) {
//           NotificationService.showSnackbar(text: state.getError(forr: HttpStates.FORGOT_PASSWORD)!.message, color: Colors.red);
//         }
//         if (state.success) {
//           NotificationService.showSnackbar(text: state.message!, color: Colors.green);
//           GoRouter.of(context).pushReplacementNamed(AppRoutes.otp.name, pathParameters: {'usernameEmail': usernameEmailController.text});
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Forgot Password', style: TextStyle(color: Colors.white, fontFamily: "Kalam", fontSize: 32, fontWeight: FontWeight.bold)),
//             centerTitle: true,
//             backgroundColor: Theme.of(context).primaryColor,
//             elevation: 10,
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(15),
//             child: Center(
//               child: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     CustomInputField(
//                         controller: usernameEmailController,
//                         labelText: 'Username/Email',
//                         hintText: 'xyz/xyz@gmail.com',
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please enter username/email";
//                           }
//                           return null;
//                         }),
//                     const SizedBox(height: 12),
//                     CustomElevatedButton(
//                         onPressed: state.isLoading(forr: HttpStates.FORGOT_PASSWORD)
//                             ? null
//                             : () {
//                           if (!formKey.currentState!.validate()) return;
//                           BlocProvider.of<AuthBloc>(context).add(
//                             ForgotPasswordEvent(
//                               usernameEmail: usernameEmailController.text,
//                               cancelToken: cancelToken,
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Forgot-password',
//                           style: const TextStyle(color: Colors.white, fontSize: 18),
//                         )),
//                     const SizedBox(height: 12),
//                     CustomTextButton(onPressed: state.isLoading(forr: HttpStates.FORGOT_PASSWORD) ? null : () => context.goNamed(AppRoutes.login.name), child: const Text('Sign-in instead'))
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     cancelToken.cancel("login cancelled");
//     super.dispose();
//   }
// }
