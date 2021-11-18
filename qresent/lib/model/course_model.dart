class CourseModel {
  List<dynamic>? intervals;
  String assignedProfessor;
  String uid;
  String? information;

  CourseModel(
      {this.intervals,
      required this.assignedProfessor,
      required this.uid,
      this.information});

  factory CourseModel.fromMap(map) {
    return CourseModel(
      uid: map["UID"],
      assignedProfessor: map["AssignedProfessor"],
      intervals: map["Intervals"],
      information: map["Information"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "UID": uid,
      "AssignedProfessor": assignedProfessor,
      "Intervals": intervals,
      "Information": information,
    };
  }
}
