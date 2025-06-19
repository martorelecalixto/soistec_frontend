class TipoServico {
  final int? id;
  final String? nome;
  final String? empresa;

  TipoServico({
    this.id,
    this.nome,
    this.empresa,
  });

  factory TipoServico.fromJson(Map<String, dynamic> json) {
    return TipoServico(
      id: json['id'] as int?,
      nome: json['nome'] as String?,
      empresa: json['empresa'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'empresa': empresa,
    };
  }
}
