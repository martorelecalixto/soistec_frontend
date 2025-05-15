class PlanoConta {
  final int? idplanoconta;
  final String? nome;
  final String? estrutura;
  final String? tipo;
  final String? natureza;
  final int? idplanocontapai;
  final String? empresa;
  final int? idpaigeral;
  final String? chave;
  final bool? naoresultado;

  PlanoConta({
    this.idplanoconta,
    this.nome,
    this.estrutura,
    this.tipo,
    this.natureza,
    this.idplanocontapai,
    this.empresa,
    this.idpaigeral,
    this.chave,
    this.naoresultado,
  });

  factory PlanoConta.fromJson(Map<String, dynamic> json) {
    return PlanoConta(
      idplanoconta: json['idplanoconta'] as int?,
      nome: json['nome'] as String?,
      estrutura: json['estrutura'] as String?,
      tipo: json['tipo'] as String?,
      natureza: json['natureza'] as String?,
      idplanocontapai: json['idplanocontapai'] as int?,
      empresa: json['empresa'] as String?,
      idpaigeral: json['idpaigeral'] as int?,
      chave: json['chave'] as String?,
      naoresultado: json['naoresultado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idplanoconta': idplanoconta,
      'nome': nome,
      'estrutura': estrutura,
      'tipo': tipo,
      'natureza': natureza,
      'idplanocontapai': idplanocontapai,
      'empresa': empresa,
      'idpaigeral': idpaigeral,
      'chave': chave,
      'naoresultado': naoresultado,
    };
  }
}
