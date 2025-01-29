class AppRoute{
  final String name;
  final String path;//relative
  final String fullPath;//relative
  AppRoute({required this.name,required this.path,required this.fullPath});
}

class AppRoutes{
  static AppRoute splashRoute=AppRoute(name: 'splash', path: '/splash',fullPath: '/splash');
  static AppRoute errorRoute=AppRoute(name: 'error', path: '/error',fullPath: '/error');
  static AppRoute login=AppRoute(name: 'login', path: '/login',fullPath: '/login');
  static AppRoute home=AppRoute(name: 'home', path: '/home',fullPath: '/home');
  static AppRoute settings=AppRoute(name: 'settings', path: '/settings',fullPath: '/settings');
  static AppRoute player=AppRoute(name: 'player', path: '/player',fullPath: '/player');
  static AppRoute shaktiReels=AppRoute(name: 'shakti reels', path: '/shakti-reels',fullPath: '/shakti-reels');
}