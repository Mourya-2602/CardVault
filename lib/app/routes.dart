abstract final class AppRoutes {
  static const login = '/login';
  static const cards = '/cards';
  static const card = '/cards/:id';
  static const limits = '/cards/:id/limits';
  static const reveal = '/cards/:id/reveal';
  static const credit = '/cards/:id/credit';
  static const statements = '/cards/:id/statements';
  static const statement = '/cards/:id/statements/:month';
  static const pay = '/cards/:id/pay';
  static const block = '/cards/:id/block';
}
