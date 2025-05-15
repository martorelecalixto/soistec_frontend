class Grupo {
  final int? id;
  final String? nome;
  final String? empresa;

  Grupo({
    this.id,
    this.nome,
    this.empresa,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
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
