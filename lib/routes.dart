class AppRoute{
  final String name;
  final String path;//relative
  final String fullPath;//relative
  AppRoute({required this.name,required this.path,required this.fullPath});
}

class AppRoutes{
  static AppRoute splashRoute=AppRoute(name: 'splash', path: '/splash',fullPath: '/splash');
  static AppRoute errorRoute=AppRoute(name: 'error', path: '/error',fullPath: '/error');
  static AppRoute home=AppRoute(name: 'home', path: '/home',fullPath: '/home');
  static AppRoute settings=AppRoute(name: 'settings', path: '/settings',fullPath: '/settings');
  static AppRoute player=AppRoute(name: 'player', path: '/player',fullPath: '/player');
  static AppRoute shaktiReels=AppRoute(name: 'shakti reels', path: '/shakti-reels',fullPath: '/shakti-reels');

  static AppRoute auth=AppRoute(name: 'auth', path: '/auth',fullPath: '/auth');
  static AppRoute login=AppRoute(name: 'login', path: 'login',fullPath: '/auth/login');
  static AppRoute profile=AppRoute(name: 'profile', path: 'profile',fullPath: '/auth/profile');
  static AppRoute updatePassword=AppRoute(name: 'update password', path: 'update-password',fullPath: '/auth/update-password');
  static AppRoute resetPasswordInit=AppRoute(name: 'forgot password init', path: 'forgot-password-init',fullPath: '/auth/forgot-password-init');
  static AppRoute resetPasswordComplete=AppRoute(name: 'forgot password complete', path: 'forgot-password-complete',fullPath: '/auth/forgot-password-complete');
  static AppRoute registerUser=AppRoute(name: 'register', path: 'register',fullPath: '/auth/register');
  static AppRoute reverifyAccount=AppRoute(name: 're-verify account', path: 're-verify-account',fullPath: '/auth/re-verify-account');
}