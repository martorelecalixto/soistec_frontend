class CentroCusto {
  final int? id;
  final String? nome;
  final int? idpai;
  final String? tipo;
  final String? empresa;
  final int? idpaigeral;
  final String? chave;

  CentroCusto({
    this.id,
    this.nome,
    this.idpai,
    this.tipo,
    this.empresa,
    this.idpaigeral,
    this.chave,
  });

  factory CentroCusto.fromJson(Map<String, dynamic> json) {
    return CentroCusto(
      id: json['id'] as int?,
      nome: json['nome'] as String?,
      idpai: json['idpai'] as int?,
      tipo: json['tipo'] as String?,
      empresa: json['empresa'] as String?,
      idpaigeral: json['idpaigeral'] as int?,
      chave: json['chave'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'idpai': idpai,
      'tipo': tipo,
      'empresa': empresa,
      'idpaigeral': idpaigeral,
      'chave': chave,
    };
  }
}
