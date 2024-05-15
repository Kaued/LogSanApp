import 'package:cloud_firestore/cloud_firestore.dart';

class WorkRoute {
  WorkRoute({
    required this.uid,
    required this.toDate,
    this.deleted = false,
    this.finish = false,
    this.finishAt,
  });

  WorkRoute.fromJson(Map<String, Object?> json)
      : this(
          uid: json["uid"]! as String,
          toDate: json["to_date"]! as Timestamp,
          finish: json["finish"]! as bool,
          finishAt: json["finish_at"]! as Timestamp?,
          deleted: json["deleted"]! as bool,
        );

  bool deleted;
  String uid;
  Timestamp? finishAt;
  bool finish;
  Timestamp toDate;

  Map<String, Object?> toJson() {
    return {  
      "uid": uid,
      "to_date": toDate,
      "finish_at": finishAt,
      "finish": finish,
      "deleted": deleted,
    };
  }
}
