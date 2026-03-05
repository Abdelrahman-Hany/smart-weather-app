import '../../domain/entities/app_user_entity.dart';

class AppUserModel extends AppUserEntity {
  const AppUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    required super.isAnonymous,
  });

  factory AppUserModel.fromFirebaseUser(dynamic firebaseUser) {
    return AppUserModel(
      uid: firebaseUser.uid as String,
      email: firebaseUser.email as String?,
      displayName: firebaseUser.displayName as String?,
      photoUrl: firebaseUser.photoURL as String?,
      isAnonymous: firebaseUser.isAnonymous as bool,
    );
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
    };
  }
}
