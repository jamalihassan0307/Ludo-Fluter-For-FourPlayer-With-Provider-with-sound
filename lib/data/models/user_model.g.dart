part of 'user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 2;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.read(),
      name: reader.read(),
      email: reader.read(),
      photoUrl: reader.read(),
      gamesPlayed: reader.read(),
      gamesWon: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.photoUrl);
    writer.write(obj.gamesPlayed);
    writer.write(obj.gamesWon);
  }
}
