class CourseModel {
  List<dynamic>? intervals;
  String uid;

  CourseModel({this.intervals, required this.uid});

  factory CourseModel.fromMap(map) {
    return CourseModel(
      uid: map['UID'],
      intervals: map['Intervals'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UID': uid,
      'Intervals': intervals,
    };
  }
}
