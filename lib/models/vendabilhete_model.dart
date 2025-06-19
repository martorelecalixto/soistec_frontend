class VendaBilhete {
  final int? idvenda;
  final DateTime? datavenda;
  final DateTime? datavencimento;
  final String? documento;
  final double? valortotal;
  final double? descontototal;
  final String? cartaoSigla;
  final String? cartaoNumero;
  final int? cartaoMesvencimento;
  final int? cartaoAnovencimento;
  final String? observacao;
  final String? solicitante;
  final int? identidade;
  final int? idvendedor;
  final int? idemissor;
  final int? idmoeda;
  final int? idformapagamento;
  final int? idfilial;
  final int? idfatura;
  final int? idreciboreceber;
  final String? chave;
  final bool? excluido;
  final String? empresa;
  final int? idcentrocusto;
  final int? idgrupo;
  final int? id;
  final double? valorentrada;
  final String? entidade;
  final String? pagamento;
  final String? vendedor;
  final String? emissor;
  final int? recibo;
  final int? fatura;
  final double? valorpago;
  
  VendaBilhete({
    this.idvenda,
    this.datavenda,
    this.datavencimento,
    this.documento,
    this.valortotal,
    this.descontototal,
    this.cartaoSigla,
    this.cartaoNumero,
    this.cartaoMesvencimento,
    this.cartaoAnovencimento,
    this.observacao,
    this.solicitante,
    this.identidade,
    this.idvendedor,
    this.idemissor,
    this.idmoeda,
    this.idformapagamento,
    this.idfilial,
    this.idfatura,
    this.idreciboreceber,
    this.chave,
    this.excluido,
    this.empresa,
    this.idcentrocusto,
    this.idgrupo,
    this.id,
    this.valorentrada,
    this.entidade,
    this.pagamento,
    this.vendedor,
    this.emissor,
    this.recibo,
    this.fatura,
    this.valorpago,
  });

  factory VendaBilhete.fromJson(Map<String, dynamic> json) {
    return VendaBilhete(
      idvenda: json['idvenda'] as int?,
      datavenda: json['datavenda'] is String ? DateTime.parse(json['datavenda']) : json['datavenda'], 
      datavencimento: json['datavencimento'] is String ? DateTime.tryParse(json['datavencimento']) : json['datavencimento'],      
      documento: json['documento'] as String?,
      valortotal: (json['valortotal'] as num?)?.toDouble(),
      descontototal: (json['descontototal'] as num?)?.toDouble(),
      cartaoSigla: json['cartao_sigla'] as String?,
      cartaoNumero: json['cartao_numero'] as String?,
      cartaoMesvencimento: json['cartao_mesvencimento'] as int?,
      cartaoAnovencimento: json['cartao_anovencimento'] as int?,
      observacao: json['observacao'] as String?,
      solicitante: json['solicitante'] as String?,
      identidade: json['identidade'] as int?,
      idvendedor: json['idvendedor'] as int?,
      idemissor: json['idemissor'] as int?,
      idmoeda: json['idmoeda'] as int?,
      idformapagamento: json['idformapagamento'] as int?,
      idfilial: json['idfilial'] as int?,
      idfatura: json['idfatura'] as int?,
      idreciboreceber: json['idreciboreceber'] as int?,
      chave: json['chave'] as String?,
      excluido: json['excluido'] as bool?,
      empresa: json['empresa'] as String?,
      idcentrocusto: json['idcentrocusto'] as int?,
      idgrupo: json['idgrupo'] as int?,
      id: json['id'] as int?,
      valorentrada: (json['valorentrada'] as num?)?.toDouble(),
      entidade: json['entidade'] as String?,
      pagamento: json['pagamento'] as String?,
      vendedor: json['vendedor'] as String?,
      emissor: json['emissor'] as String?,
      recibo: json['recibo'] as int?,
      fatura: json['fatura'] as int?,
      valorpago: json['valorpago'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idvenda': idvenda,
      'datavenda': datavenda?.toIso8601String(),
      'datavencimento': datavencimento?.toIso8601String(),
      'documento': documento,
      'valortotal': valortotal,
      'descontototal': descontototal,
      'cartao_sigla': cartaoSigla,
      'cartao_numero': cartaoNumero,
      'cartao_mesvencimento': cartaoMesvencimento,
      'cartao_anovencimento': cartaoAnovencimento,
      'observacao': observacao,
      'solicitante': solicitante,
      'identidade': identidade,
      'idvendedor': idvendedor,
      'idemissor': idemissor,
      'idmoeda': idmoeda,
      'idformapagamento': idformapagamento,
      'idfilial': idfilial,
      'idfatura': idfatura,
      'idreciboreceber': idreciboreceber,
      'chave': chave,
      'excluido': excluido,
      'empresa': empresa,
      'idcentrocusto': idcentrocusto,
      'idgrupo': idgrupo,
      'id': id,
      'valorentrada': valorentrada,
      'entidade': entidade,
      'pagamento': pagamento,
      'vendedor': vendedor,
      'emissor': emissor,
      'recibo': recibo,
      'fatura': fatura,
      'valorpago': valorpago,
    };
  }
}
