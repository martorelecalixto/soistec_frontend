class ReciboReceber {
  final int? idrecibo;
  final DateTime? dataemissao;
  final String? descricao;
  final double? valor;
  final int? identidade;
  final int? idmoeda;
  final int? idfilial;
  final String? chave;
  final String? empresa;
  final int? id;
  final String? tipo;
  final String? entidade;

  ReciboReceber({
    this.idrecibo,
    this.dataemissao,
    this.descricao,
    this.valor,
    this.identidade,
    this.idmoeda,
    this.idfilial,
    this.chave,
    this.empresa,
    this.id,
    this.tipo,
    this.entidade,
  });

  factory ReciboReceber.fromJson(Map<String, dynamic> json) {
    return ReciboReceber(
      idrecibo: json['idrecibo'] as int?,
      dataemissao: json['dataemissao'] is String ? DateTime.parse(json['dataemissao']) : json['dataemissao'], 
      descricao: json['descricao'] as String?,
      valor: (json['valor'] as num?)?.toDouble(),
      identidade: json['identidade'] as int?,
      idmoeda: json['idmoeda'] as int?,
      idfilial: json['idfilial'] as int?,
      chave: json['chave'] as String?,
      empresa: json['empresa'] as String?,
      id: json['id'] as int?,
      tipo: json['tipo'] as String?,
      entidade: json['entidade'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idrecibo': idrecibo,
      'dataemissao': dataemissao?.toIso8601String(),
      'descricao': descricao,
      'valor': valor,
      'identidade': identidade,
      'idmoeda': idmoeda,
      'idfilial': idfilial,
      'chave': chave,
      'empresa': empresa,
      'id': id,
      'tipo': tipo,
      'entidade': entidade,
    };
  }
}
