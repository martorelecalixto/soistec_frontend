class Emissor {
  final int? idemissor;
  final double? percomisnac;
  final double? percomisint;
  final int? entidadeid;
  final double? percomissernac;
  final double? percomisserint;

  Emissor({
    this.idemissor,
    this.percomisnac,
    this.percomisint,
    this.entidadeid,
    this.percomissernac,
    this.percomisserint,
  });

  factory Emissor.fromJson(Map<String, dynamic> json) {
    return Emissor(
      idemissor: json['idemissor'] as int?,
      percomisnac: (json['percomisnac'] as num?)?.toDouble(),
      percomisint: (json['percomisint'] as num?)?.toDouble(),
      entidadeid: json['entidadeid'] as int?,
      percomissernac: (json['percomissernac'] as num?)?.toDouble(),
      percomisserint: (json['percomisserint'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idemissor': idemissor,
      'percomisnac': percomisnac,
      'percomisint': percomisint,
      'entidadeid': entidadeid,
      'percomissernac': percomissernac,
      'percomisserint': percomisserint,
    };
  }
}
