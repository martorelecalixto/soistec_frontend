class Vendedor {
  final int? id;
  final double? percomisnac;
  final double? percomisint;
  final int? entidadeid;
  final double? percomissernac;
  final double? percomisserint;

  Vendedor({
    this.id,
    this.percomisnac,
    this.percomisint,
    this.entidadeid,
    this.percomissernac,
    this.percomisserint,
  });

  factory Vendedor.fromJson(Map<String, dynamic> json) {
    return Vendedor(
      id: json['id'] as int?,
      percomisnac: (json['percomisnac'] as num?)?.toDouble(),
      percomisint: (json['percomisint'] as num?)?.toDouble(),
      entidadeid: json['entidadeid'] as int?,
      percomissernac: (json['percomissernac'] as num?)?.toDouble(),
      percomisserint: (json['percomisserint'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'percomisnac': percomisnac,
      'percomisint': percomisint,
      'entidadeid': entidadeid,
      'percomissernac': percomissernac,
      'percomisserint': percomisserint,
    };
  }
}
