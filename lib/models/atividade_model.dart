class Atividade {
  final int? id;
  final String? nome;
  final String? empresa;

  Atividade({
    this.id,
    this.nome,
    this.empresa,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
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
