import 'package:shakti/models/User.dart';

class  Pageable<T> {
    final List<T> data;
    final int pageNo;
    final int totalItems;

    Pageable({required this.data, required this.pageNo, required this.totalItems});
}