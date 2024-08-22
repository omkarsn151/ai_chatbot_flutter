import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';
import '../repository/chat_repository.dart';

final chatProvider = Provider(
      (ref) => ChatRepository(),
);

final authProvider = Provider(
      (ref) => AuthRepository(),
);