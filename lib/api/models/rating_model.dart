class Rating {
  String? id;
  double? rating;
  String? comment;
  String? userId1;
  String? userId2;

  Rating({
    this.id,
    this.rating,
    this.comment,
    this.userId1,
    this.userId2
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      userId1: json['userId1'] ?? '',
      userId2: json['userId2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'userId1': userId1,
      'userId2': userId2
    };
  }


}
