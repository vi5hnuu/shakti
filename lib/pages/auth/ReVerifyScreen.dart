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
// class ReVerifyScreen extends StatefulWidget {
//   ReVerifyScreen({super.key});
//
//   @override
//   State<ReVerifyScreen> createState() => _ReVerifyScreenState();
// }
//
// class _ReVerifyScreenState extends State<ReVerifyScreen> {
//   final CancelToken cancelToken = CancelToken();
//   final formKey = GlobalKey<FormState>(debugLabel: 'loginForm');
//   final TextEditingController emailCntrl = TextEditingController(text: '');
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthBloc, AuthState>(
//       listenWhen: (previous, current) => previous != current,
//       listener: (ctx, state) {
//         if (state.success) {
//           NotificationService.showSnackbar(text: state.message ?? "verified successfully", color: Colors.green);
//           context.goNamed(AppRoutes.login.name);
//         }
//         if (state.isError(forr: HttpStates.REVERIFY)) {
//           NotificationService.showSnackbar(text: state.message ?? "verification failed", color: Colors.red);
//         }
//       },
//       builder: (context, state) => Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'verify',
//             style: TextStyle(color: Colors.white, fontFamily: "Kalam", fontSize: 32, fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//           backgroundColor: Theme.of(context).primaryColor,
//           elevation: 10,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Center(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   CustomInputField(
//                     controller: emailCntrl,
//                     labelText: 'Email',
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Please enter email";
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),
//                   CustomElevatedButton(
//                       onPressed: state.isLoading(forr: HttpStates.REVERIFY) ? null : () => BlocProvider.of<AuthBloc>(context).add(ReVerifyEvent(email: this.emailCntrl.value.text, cancelToken: cancelToken)),
//                       child: const Text(
//                         "send verification email",
//                         style: TextStyle(color: Colors.white),
//                       )),
//                   const SizedBox(height: 12),
//                   CustomTextButton(onPressed: state.isLoading(forr: HttpStates.REVERIFY) ? null : () => context.goNamed(AppRoutes.login.name), child: const Text('login instead')),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     cancelToken.cancel("login cancelled");
//     super.dispose();
//   }
// }
