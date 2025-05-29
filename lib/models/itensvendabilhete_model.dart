class ItensVendaBilhete {
  final int? id;
  final int? quantidade;
  final String? pax;
  final String? observacao;
  final String? bilhete;
  final String? trecho;
  final String? tipovoo;
  final double? valorbilhete;
  final double? valortaxabilhete;
  final double? valortaxaservico;
  final double? valordesconto;
  final double? valortotal;
  final int? idvenda;
  final int? idciaaerea;
  final int? idoperadora;
  final String? voo;
  final String? tipobilhete;
  final bool? cancelado;
  final double? valorcomisagente;
  final double? valorcomisvendedor;
  final double? valorassento;
  final double? valorcomisemissor;
  final double? valorfornecedor;
  final double? valornet;
  final String? localembarque;
  final DateTime? dataembarque;
  final DateTime? horaembarque;
  final String? localdesembarque;
  final DateTime? datadesembarque;
  final DateTime? horadesembarque;
  final String? chave;
  final String? cia;
  final String? operadora;

  ItensVendaBilhete({
    this.id,
    this.quantidade,
    this.pax,
    this.observacao,
    this.bilhete,
    this.trecho,
    this.tipovoo,
    this.valorbilhete,
    this.valortaxabilhete,
    this.valortaxaservico,
    this.valordesconto,
    this.valortotal,
    this.idvenda,
    this.idciaaerea,
    this.idoperadora,
    this.voo,
    this.tipobilhete,
    this.cancelado,
    this.valorcomisagente,
    this.valorcomisvendedor,
    this.valorassento,
    this.valorcomisemissor,
    this.valorfornecedor,
    this.valornet,
    this.localembarque,
    this.dataembarque,
    this.horaembarque,
    this.localdesembarque,
    this.datadesembarque,
    this.horadesembarque,
    this.chave,
    this.cia,
    this.operadora,
  });

  factory ItensVendaBilhete.fromJson(Map<String, dynamic> json) {
    return ItensVendaBilhete(
      id: json['id'] as int?,
      quantidade: json['quantidade'] as int?,
      pax: json['pax'] as String?,
      observacao: json['observacao'] as String?,
      bilhete: json['bilhete'] as String?,
      trecho: json['trecho'] as String?,
      tipovoo: json['tipovoo'] as String?,
      valorbilhete: (json['valorbilhete'] as num?)?.toDouble(),
      valortaxabilhete: (json['valortaxabilhete'] as num?)?.toDouble(),
      valortaxaservico: (json['valortaxaservico'] as num?)?.toDouble(),
      valordesconto: (json['valordesconto'] as num?)?.toDouble(),
      valortotal: (json['valortotal'] as num?)?.toDouble(),
      idvenda: json['idvenda'] as int?,
      idciaaerea: json['idciaaerea'] as int?,
      idoperadora: json['idoperadora'] as int?,
      voo: json['voo'] as String?,
      tipobilhete: json['tipobilhete'] as String?,
      cancelado: json['cancelado'] as bool?,
      valorcomisagente: (json['valorcomisagente'] as num?)?.toDouble(),
      valorcomisvendedor: (json['valorcomisvendedor'] as num?)?.toDouble(),
      valorassento: (json['valorassento'] as num?)?.toDouble(),
      valorcomisemissor: (json['valorcomisemissor'] as num?)?.toDouble(),
      valorfornecedor: (json['valorfornecedor'] as num?)?.toDouble(),
      valornet: (json['valornet'] as num?)?.toDouble(),
      localembarque: json['localembarque'] as String?,
      dataembarque: json['dataembarque'] is String ? DateTime.parse(json['dataembarque']) : json['dataembarque'], 
      horaembarque: json['horaembarque'] is String ? DateTime.parse(json['horaembarque']) : json['horaembarque'], 
      //dataembarque: json['dataembarque'] != null ? DateTime.parse(json['dataembarque']) : null,
      //horaembarque: json['horaembarque'] != null ? DateTime.parse(json['horaembarque']) : null,
      localdesembarque: json['localdesembarque'] as String?,
      //datadesembarque: json['datadesembarque'] != null ? DateTime.parse(json['datadesembarque']) : null,
      //horadesembarque: json['horadesembarque'] != null ? DateTime.parse(json['horadesembarque']) : null,
      datadesembarque: json['datadesembarque'] is String ? DateTime.parse(json['datadesembarque']) : json['datadesembarque'], 
      horadesembarque: json['horadesembarque'] is String ? DateTime.parse(json['horadesembarque']) : json['horadesembarque'], 

      chave: json['chave'] as String?,
      cia: json['cia'] as String?,
      operadora: json['operadora'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantidade': quantidade,
      'pax': pax,
      'observacao': observacao,
      'bilhete': bilhete,
      'trecho': trecho,
      'tipovoo': tipovoo,
      'valorbilhete': valorbilhete,
      'valortaxabilhete': valortaxabilhete,
      'valortaxaservico': valortaxaservico,
      'valordesconto': valordesconto,
      'valortotal': valortotal,
      'idvenda': idvenda,
      'idciaaerea': idciaaerea,
      'idoperadora': idoperadora,
      'voo': voo,
      'tipobilhete': tipobilhete,
      'cancelado': cancelado,
      'valorcomisagente': valorcomisagente,
      'valorcomisvendedor': valorcomisvendedor,
      'valorassento': valorassento,
      'valorcomisemissor': valorcomisemissor,
      'valorfornecedor': valorfornecedor,
      'valornet': valornet,
      'localembarque': localembarque,
      'dataembarque': dataembarque?.toIso8601String(),
      'horaembarque': horaembarque?.toIso8601String(),
      'localdesembarque': localdesembarque,
      'datadesembarque': datadesembarque?.toIso8601String(),
      'horadesembarque': horadesembarque?.toIso8601String(),
      'chave': chave,
      'cia': cia,
      'operadora': operadora,
    };
  }
}
