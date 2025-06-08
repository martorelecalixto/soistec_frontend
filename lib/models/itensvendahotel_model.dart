class ItensVendaHotel {
  final int? id;
  final int? quantidade;
  final String? pax;
  final String? observacao;
  final String? descricao;
  final DateTime? periodoini;
  final DateTime? periodofin;
  final DateTime? datavencimento;
  final DateTime? datavencimentofor;
  final double? valorhotel;
  final double? valortaxa;
  final double? valortaxaservico;
  final double? valordu;
  final double? valordesconto;
  final double? valoroutros;
  final double? valorcomissao;
  final double? valorfornecedor;
  final int? idvenda;
  final int? idfornecedor;
  final int? idoperadora;
  final int? tiposervicohotelid;
  final double? valorcomisvendedor;
  final int? idacomodacao;
  final String? chave;
  final double? valorcomisemissor;
  final double? valorextras;
  final String? tiposervico;
  final String? fornecedor;
  final String? operadora;
  final String? acomodacao;
  final String? tiposervicohotel;

  ItensVendaHotel({
    this.id,
    this.quantidade,
    this.pax,
    this.observacao,
    this.descricao,
    this.periodoini,
    this.periodofin,
    this.datavencimento,
    this.datavencimentofor,
    this.valorhotel,
    this.valortaxa,
    this.valortaxaservico,
    this.valordu,
    this.valordesconto,
    this.valoroutros,
    this.valorcomissao,
    this.valorfornecedor,
    this.idvenda,
    this.idfornecedor,
    this.idoperadora,
    this.tiposervicohotelid,
    this.valorcomisvendedor,
    this.idacomodacao,
    this.chave,
    this.valorcomisemissor,
    this.valorextras,
    this.tiposervico,
    this.fornecedor,
    this.operadora,
    this.acomodacao,
    this.tiposervicohotel,
  });

  factory ItensVendaHotel.fromJson(Map<String, dynamic> json) {
    return ItensVendaHotel(
      id: json['id'] as int?,
      quantidade: json['quantidade'] as int?,
      pax: json['pax'] as String?,
      observacao: json['observacao'] as String?,
      descricao: json['descricao'] as String?,
      periodoini: json['periodoini'] != null ? DateTime.parse(json['periodoini']) : null,
      periodofin: json['periodofin'] != null ? DateTime.parse(json['periodofin']) : null,
      datavencimento: json['datavencimento'] != null ? DateTime.parse(json['datavencimento']) : null,
      datavencimentofor: json['datavencimentofor'] != null ? DateTime.parse(json['datavencimentofor']) : null,
      valorhotel: (json['valorhotel'] as num?)?.toDouble(),
      valortaxa: (json['valortaxa'] as num?)?.toDouble(),
      valortaxaservico: (json['valortaxaservico'] as num?)?.toDouble(),
      valordu: (json['valordu'] as num?)?.toDouble(),
      valordesconto: (json['valordesconto'] as num?)?.toDouble(),
      valoroutros: (json['valoroutros'] as num?)?.toDouble(),
      valorcomissao: (json['valorcomissao'] as num?)?.toDouble(),
      valorfornecedor: (json['valorfornecedor'] as num?)?.toDouble(),
      idvenda: json['idvenda'] as int?,
      idfornecedor: json['idfornecedor'] as int?,
      idoperadora: json['idoperadora'] as int?,
      tiposervicohotelid: json['tiposervicohotelid'] as int?,
      valorcomisvendedor: (json['valorcomisvendedor'] as num?)?.toDouble(),
      idacomodacao: json['idacomodacao'] as int?,
      chave: json['chave'] as String?,
      valorcomisemissor: (json['valorcomisemissor'] as num?)?.toDouble(),
      valorextras: (json['valorextras'] as num?)?.toDouble(),
      tiposervico: json['tiposervico'] as String?,
      fornecedor: json['fornecedor'] as String?,
      operadora: json['operadora'] as String?,
      acomodacao: json['acomodacao'] as String?,
      tiposervicohotel: json['tiposervicohotel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantidade': quantidade,
      'pax': pax,
      'observacao': observacao,
      'descricao': descricao,
      'periodoini': periodoini?.toIso8601String(),
      'periodofin': periodofin?.toIso8601String(),
      'datavencimento': datavencimento?.toIso8601String(),
      'datavencimentofor': datavencimentofor?.toIso8601String(),
      'valorhotel': valorhotel,
      'valortaxa': valortaxa,
      'valortaxaservico': valortaxaservico,
      'valordu': valordu,
      'valordesconto': valordesconto,
      'valoroutros': valoroutros,
      'valorcomissao': valorcomissao,
      'valorfornecedor': valorfornecedor,
      'idvenda': idvenda,
      'idfornecedor': idfornecedor,
      'idoperadora': idoperadora,
      'tiposervicohotelid': tiposervicohotelid,
      'valorcomisvendedor': valorcomisvendedor,
      'idacomodacao': idacomodacao,
      'chave': chave,
      'valorcomisemissor': valorcomisemissor,
      'valorextras': valorextras,
      'tiposervico': tiposervico,
      'fornecedor': fornecedor,
      'operadora': operadora,
      'acomodacao': acomodacao,
      'tiposervicohotel': tiposervicohotel,
    };
  }
}
