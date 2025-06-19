class Hotel {
  final int? idhotel;
  final double? percomis;
  final double? percomisint;
  final int? entidadeid;
  final int? prazofaturamento;

  Hotel({
    this.idhotel,
    this.percomis,
    this.percomisint,
    this.entidadeid,
    this.prazofaturamento,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      idhotel: json['idhotel'] as int?,
      percomis: (json['percomis'] as num?)?.toDouble(),
      percomisint: (json['percomisint'] as num?)?.toDouble(),
      entidadeid: json['entidadeid'] as int?,
      prazofaturamento: json['prazofaturamento'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idhotel': idhotel,
      'percomis': percomis,
      'percomisint': percomisint,
      'entidadeid': entidadeid,
      'prazofaturamento': prazofaturamento,
    };
  }
}
