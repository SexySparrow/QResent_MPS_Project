class CourseModel {
  List<dynamic>? intervals;
  String assignedProfessor;
  String uid;

  CourseModel(
      {this.intervals, required this.assignedProfessor, required this.uid});

  factory CourseModel.fromMap(map) {
    return CourseModel(
      uid: map["UID"],
      assignedProfessor: map["AssignedProfessor"],
      intervals: map["Intervals"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "UID": uid,
      "AssignedProfessor": assignedProfessor,
      "Intervals": intervals,
    };
  }
}
