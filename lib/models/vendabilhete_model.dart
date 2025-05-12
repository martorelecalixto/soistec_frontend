/*
class VendaBilhete {
  final int? idvenda;
  final DateTime? datavenda;
  final DateTime? datavencimento;
  final String? documento;
  final double? valortotal;
  final double? descontototal;
  final String? cartao_sigla;
  final String? cartao_numero;
  final int? cartao_mesvencimento;
  final int? cartao_anovencimento;
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

  // Campos adicionais da consulta
  final String? entidade;      // entidades.nome
  final String? pagamento;     // formapagamento.nome

  VendaBilhete({
    this.idvenda,
    this.datavenda,
    this.datavencimento,
    this.documento,
    this.valortotal,
    this.descontototal,
    this.cartao_sigla,
    this.cartao_numero,
    this.cartao_mesvencimento,
    this.cartao_anovencimento,
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
  });

  factory VendaBilhete.fromJson(Map<String, dynamic> json) {
    return VendaBilhete(
      idvenda: json['idvenda'] as int?,
      datavenda: json['datavenda'] != null ? DateTime.tryParse(json['datavenda']) : null,
      datavencimento: json['datavencimento'] != null ? DateTime.tryParse(json['datavencimento']) : null,
      documento: json['documento'] as String?,
      valortotal: (json['valortotal'] as num?)?.toDouble(),
      descontototal: (json['descontototal'] as num?)?.toDouble(),
      cartao_sigla: json['cartao_sigla'] as String?,
      cartao_numero: json['cartao_numero'] as String?,
      cartao_mesvencimento: json['cartao_mesvencimento'] as int?,
      cartao_anovencimento: json['cartao_anovencimento'] as int?,
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
      entidade: json['entidade'] as String?,   // Nome da entidade
      pagamento: json['pagamento'] as String?, // Nome da forma de pagamento
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
      'cartao_sigla': cartao_sigla,
      'cartao_numero': cartao_numero,
      'cartao_mesvencimento': cartao_mesvencimento,
      'cartao_anovencimento': cartao_anovencimento,
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
    };
  }
}

*/









class VendaBilhete {
  final int? idvenda;
  final DateTime? datavenda;
  final DateTime? datavencimento;
  final String? documento;
  final double? valortotal;
  final double? descontototal;
  final String? cartao_sigla;
  final String? cartao_numero;
  final int? cartao_mesvencimento;
  final int? cartao_anovencimento;
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

  VendaBilhete({
    this.idvenda,
    this.datavenda,
    this.datavencimento,
    this.documento,
    this.valortotal,
    this.descontototal,
    this.cartao_sigla,
    this.cartao_numero,
    this.cartao_mesvencimento,
    this.cartao_anovencimento,
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
  });

  factory VendaBilhete.fromJson(Map<String, dynamic> json) {
    return VendaBilhete(
      idvenda: json['idvenda'] as int?,
      datavenda: json['datavenda'] != null ? DateTime.parse(json['datavenda']) : null, //json['datavenda'] as DateTime?,
      datavencimento: json['datavencimento'] != null ? DateTime.parse(json['datavencimento']) : null, //json['datavencimento'] as DateTime?,
      documento: json['documento'] as String?,
      valortotal: json['valortotal'] as double?,
      descontototal: json['descontototal'] as double?,
      cartao_sigla: json['cartao_sigla'] as String?,
      cartao_numero: json['cartao_numero'] as String?,
      cartao_mesvencimento: json['cartao_mesvencimento'] as int?,
      cartao_anovencimento: json['cartao_anovencimento'] as int?,
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
      valorentrada: json['valorentrada'] as double?,
      entidade: json['entidade'] as String?,
      pagamento: json['pagamento'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idvenda': idvenda,
      'datavenda': datavenda,
      'datavencimento': datavencimento,
      'documento': documento,
      'valortotal': valortotal,
      'descontototal': descontototal,
      'cartao_sigla': cartao_sigla,
      'cartao_numero': cartao_numero,
      'cartao_mesvencimento': cartao_mesvencimento,
      'cartao_anovencimento': cartao_anovencimento,
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
    };
  }
}
