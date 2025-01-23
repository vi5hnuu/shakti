class AppRoute{
  final String name;
  final String path;//relative
  AppRoute({required this.name,required this.path});
}

class AppRoutes{
  static AppRoute splashRoute=AppRoute(name: 'splash', path: '/splash');
  static AppRoute errorRoute=AppRoute(name: 'error', path: '/error');
  static AppRoute login=AppRoute(name: 'login', path: '/login');
  static AppRoute home=AppRoute(name: 'home', path: '/home');
  static AppRoute settings=AppRoute(name: 'settings', path: '/settings');
  static AppRoute player=AppRoute(name: 'player', path: '/player');
}