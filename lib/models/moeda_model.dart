class Moeda {
  final int? idmoeda;
  final String? nome;
  final String? sigla;
  final String? codiso;
  final String? intplural;
  final String? intsingular;
  final String? decplural;
  final String? decsingular;
  final String? empresa;

  Moeda({
    this.idmoeda,
    this.nome,
    this.sigla,
    this.codiso,
    this.intplural,
    this.intsingular,
    this.decplural,
    this.decsingular,
    this.empresa,
  });

  factory Moeda.fromJson(Map<String, dynamic> json) {
    return Moeda(
      idmoeda: json['idmoeda'] as int?,
      nome: json['nome'] as String?,
      sigla: json['sigla'] as String?,
      codiso: json['codiso'] as String?,
      intplural: json['intplural'] as String?,
      intsingular: json['intsingular'] as String?,
      decplural: json['decplural'] as String?,
      decsingular: json['decsingular'] as String?,
      empresa: json['empresa'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idmoeda': idmoeda,
      'nome': nome,
      'sigla': sigla,
      'codiso': codiso,
      'intplural': intplural,
      'intsingular': intsingular,
      'decplural': decplural,
      'decsingular': decsingular,
      'empresa': empresa,
    };
  }
}
