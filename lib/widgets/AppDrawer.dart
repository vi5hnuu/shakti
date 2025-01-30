import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/models/User.dart';
import 'package:shakti/routes.dart';

import '../state/auth/Auth_bloc.dart';
import 'UserAvatar.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final md=MediaQuery.of(context);
  late final theme=Theme.of(context);
  late final authBloc=BlocProvider.of<AuthBloc>(context);
  late final router=GoRouter.of(context);


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc,AuthState>(
      buildWhen: (previous, current) => previous!=current,
      builder: (context, state) {
        final userInfo=state.userInfo;
        return Drawer(
          shape: BeveledRectangleBorder(),
          child: Flex(direction: Axis.vertical,children: [
            Container(
              height: md.size.height*0.25,
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserAvatar(radius: md.size.height*0.08, imageUrl: userInfo?.profileUrl),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                      child: Text(overflow: TextOverflow.ellipsis,userInfo!=null ? '${userInfo.firstName} ${userInfo.lastName??''}' : '',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  ListTile(tileColor: Colors.lightGreenAccent.withValues(alpha: 0.5),onTap: () => router.pushNamed(AppRoutes.shaktiReels.name),title: Text("Watch Bhakti Reels",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),),leading: SvgPicture.asset("assets/icons/reel.svg",colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)),)
                ],
              ),
            ),
            SizedBox(width: double.infinity,
              child: FilledButton(style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(),
                backgroundColor: Colors.red
              ), onPressed: _handleLogout,child: ListTile(leading: Icon(Icons.logout,color: Colors.white,size: 32),title: Text('Log out',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),)),
            )
          ],),
        );
      },
    );
  }

  _handleLogout(){
    authBloc.add(LogoutEvent());
  }
}


