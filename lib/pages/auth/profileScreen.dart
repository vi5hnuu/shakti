import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:shakti/models/enums/AccountType.dart';
import 'package:shakti/routes.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/state/HttpStates.dart';
import 'package:shakti/widgets/CustomInputField.dart';
import 'package:shakti/widgets/CustomTextButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth/Auth_bloc.dart';
import '../../widgets/UserAvatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CancelToken deleteMeToken = CancelToken();
  final formKey = GlobalKey<FormState>(debugLabel: 'profile-form');
  DateTime? _lastBackPressedAt;
  late final md=MediaQuery.of(context);
  late final theme = Theme.of(context);
  late final mediaQuery = MediaQuery.of(context);
  late final router=GoRouter.of(context);
  late final bloc=BlocProvider.of<AuthBloc>(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => shouldUpdate(previous,current),
        listener: (context, state) {
          if(!mounted) return;
          if(!state.isExpired(forr: HttpStates.UPDATE_PASSWORD_INIT)){
            bloc.add(ExpireHttpState(forr: HttpStates.UPDATE_PASSWORD_INIT));
            final updatePassInitState=state.httpStates[HttpStates.UPDATE_PASSWORD_INIT]!;
            if(updatePassInitState.done==true){
              NotificationService.showSnackbar(text: updatePassInitState.value ?? 'Otp sent successfully', color: Colors.green);
              router.pushNamed(AppRoutes.updatePassword.name);
              return;
            }else if(updatePassInitState.error!=null){
              NotificationService.showSnackbar(text: updatePassInitState.error!, color: Colors.red);
            }
          }else if(!state.isExpired(forr: HttpStates.DELETE_ME)){
            bloc.add(ExpireHttpState(forr: HttpStates.DELETE_ME));
            if (state.isError(forr: HttpStates.DELETE_ME)) {
              NotificationService.showSnackbar(text: state.httpStates[HttpStates.DELETE_ME]!.error!, color: Colors.red);
            }else if (state.isSuccess(forr: HttpStates.DELETE_ME)) {
              router.goNamed(AppRoutes.login.name);
            }
          }

        },
        buildWhen: (previous, current) => shouldUpdate(previous,current),
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if(!mounted) return;
              final canNavigateBack = router.canPop() &&
                  (_lastBackPressedAt != null &&
                      DateTime.now().difference(_lastBackPressedAt!) <= const Duration(seconds: 2)) ||
                  !state.anyLoading(forr: [HttpStates.UPDATE_PASSWORD_INIT, HttpStates.DELETE_ME]);

              if (canNavigateBack) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted && router.canPop()) router.pop();
                });
                return;
              }
              setState(() =>_lastBackPressedAt = DateTime.now());
              NotificationService.showSnackbar(text: "Changes may be lost, Press again to exit");
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "oxanium",
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                elevation: 10,
                backgroundColor: theme.primaryColor,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.5),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.5),
                          padding: const EdgeInsets.all(5.5).copyWith(bottom: 32),
                          child: Center(child: Column(
                            children: [
                              UserAvatar(radius: md.size.height*0.08, imageUrl: state.userInfo?.profileUrl),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                child: Text('${state.userInfo?.firstName ?? ''} ${state.userInfo?.lastName??''}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),),
                        ),
                        CustomInputField(labelText: "Active Since", initialValue: DateFormat("dd MMM yyyy").format(state.userInfo!.createdAt), enabled: false),
                        const SizedBox(height: 9),
                        CustomInputField(
                            labelText: "Username",
                            initialValue: state.userInfo!.username,
                            enabled: false),
                        const SizedBox(height: 9),
                        CustomInputField(
                            labelText: "Email",
                            initialValue: state.userInfo!.email,
                            enabled: false),
                        const SizedBox(height: 9),
                        CustomInputField(
                            labelText: "Password Updated At",
                            initialValue:  DateFormat("dd MMM yyyy").format(state.userInfo!.passwordUpdatedAt ?? state.userInfo!.createdAt),
                            enabled: false),
                        const SizedBox(height: 9),
                        CustomTextButton(
                            isLoading: state.isLoading(forr: HttpStates.UPDATE_PASSWORD_INIT),
                            isDisabled: state.userInfo?.accountType==AccountType.GOOGLE || state.isLoading(forr: HttpStates.DELETE_ME),
                            onPressed: () => bloc.add(UpdatePasswordInitEvent(usernameEmail: state.userInfo!.email)),
                            child: const Text('Update Password')),
                        if(state.userInfo?.accountType==AccountType.GOOGLE) Text("** You cannot update password as you logged in via google",style: TextStyle(color: Colors.red,fontSize: 12)),
                        const SizedBox(height: 9),
                        CustomTextButton(backgroundColor: Colors.red,
                            isDisabled: state.isLoading(forr: HttpStates.UPDATE_PASSWORD_INIT),
                            isLoading: state.isLoading(forr: HttpStates.DELETE_ME),
                            onPressed: deleteAccountInit,
                            child: const Text('Delete Account',style: TextStyle(color: Colors.white),))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  shouldUpdate(AuthState previous,AuthState current){
    if(ModalRoute.of(context)?.isCurrent != true) return false;//is screen alive
    return previous!=current && current.userInfo!=null;
  }
  saveChanges() async {
    // if (this.profileImage == null && this.coverImage == null) throw Error();
    // BlocProvider.of<AuthBloc>(context).add(UpdateProfileMeta(
    //     profileImage: profileImage != null
    //         ? await MultipartFile.fromFile(profileImage!.path)
    //         : null,
    //     posterImage: coverImage != null
    //         ? await MultipartFile.fromFile(coverImage!.path)
    //         : null,
    //     cancelToken: profileMetaToken));
  }

  deleteAccountInit() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        backgroundColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.warning, color: Colors.red, size: 48),
                const Text('The action is irreversible', textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 3,
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),
                const Text('Are you sure you want to delete your account ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(DeleteMeEvent(cancelToken: deleteMeToken));
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    deleteMeToken.cancel("cancelled");
    super.dispose();
  }
}
