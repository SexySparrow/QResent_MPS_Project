class AttendanceModel {
  Map<String, dynamic> dates;
  int total;

  AttendanceModel({
    required this.dates,
    required this.total,
  });

  factory AttendanceModel.fromMap(map) {
    return AttendanceModel(
      total: map["total"],
      dates: map["Dates"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "total": total,
      "Dates": dates,
    };
  }
}
