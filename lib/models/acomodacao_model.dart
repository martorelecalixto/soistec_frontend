class Acomodacao {
  final int? id;
  final String? nome;
  final String? empresa;

  Acomodacao({
    this.id,
    this.nome,
    this.empresa,
  });

  factory Acomodacao.fromJson(Map<String, dynamic> json) {
    return Acomodacao(
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
