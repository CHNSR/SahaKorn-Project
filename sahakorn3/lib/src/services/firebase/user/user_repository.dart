import 'fire_user_read_service.dart';
import 'fire_user_write_service.dart';
import 'package:sahakorn3/src/models/user.dart';

class UserRepository {
  final FireUserReadService readService;
  final FireUserWriteService writeService;

  UserRepository({
    FireUserReadService? readService,
    FireUserWriteService? writeService,
  })  : readService = readService ?? FireUserReadService(),
        writeService = writeService ?? FireUserWriteService();

  // Read
  Future<AppUser?> getById(String uid) => readService.fetchUserById(uid);
  Stream<AppUser?> watchById(String uid) => readService.watchUserById(uid);
  Future<List<AppUser>> listAll({int limit = 50}) => readService.fetchAllUsers(limit: limit);

  // Write
  Future<String?> createOrReplace(String uid, Map<String, dynamic> data) =>
      writeService.createOrReplaceUser(uid: uid, data: data);

  Future<String?> update(String uid, Map<String, dynamic> data) =>
      writeService.updateUser(uid: uid, data: data);

  Future<String?> delete(String uid) => writeService.deleteUser(uid);
}