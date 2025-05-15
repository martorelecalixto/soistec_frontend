class FormaPagamento {
  final int? idformapagamento;
  final String? nome;
  final String? tipo;
  final bool? debito;
  final bool? credito;
  final bool? gerartitulofatura;
  final bool? gerartitulovenda;
  final bool? baixaautomatica;
  final bool? vendaparcelada;
  final String? empresa;
  final bool? gerarfatura;
  final bool? addtaxanovalor;
  final bool? addassentonovalor;
  final bool? addravnovalor;
  final bool? addcomissaonovalor;
  final bool? gerartituloservicofor;
  final bool? gerartituloservicocomis;
  final int? idplanocontaaereo;
  final int? idplanocontaforaereo;
  final int? idplanocontaservico;
  final int? idplanocontaforservico;
  final int? idplanocontacomisservico;
  final int? idplanocontapacote;

  FormaPagamento({
    this.idformapagamento,
    this.nome,
    this.tipo,
    this.debito,
    this.credito,
    this.gerartitulofatura,
    this.gerartitulovenda,
    this.baixaautomatica,
    this.vendaparcelada,
    this.empresa,
    this.gerarfatura,
    this.addtaxanovalor,
    this.addassentonovalor,
    this.addravnovalor,
    this.addcomissaonovalor,
    this.gerartituloservicofor,
    this.gerartituloservicocomis,
    this.idplanocontaaereo,
    this.idplanocontaforaereo,
    this.idplanocontaservico,
    this.idplanocontaforservico,
    this.idplanocontacomisservico,
    this.idplanocontapacote,
  });

  factory FormaPagamento.fromJson(Map<String, dynamic> json) {
    return FormaPagamento(
      idformapagamento: json['idformapagamento'] as int?,
      nome: json['nome'] as String?,
      tipo: json['tipo'] as String?,
      debito: json['debito'] as bool?,
      credito: json['credito'] as bool?,
      gerartitulofatura: json['gerartitulofatura'] as bool?,
      gerartitulovenda: json['gerartitulovenda'] as bool?,
      baixaautomatica: json['baixaautomatica'] as bool?,
      vendaparcelada: json['vendaparcelada'] as bool?,
      empresa: json['empresa'] as String?,
      gerarfatura: json['gerarfatura'] as bool?,
      addtaxanovalor: json['addtaxanovalor'] as bool?,
      addassentonovalor: json['addassentonovalor'] as bool?,
      addravnovalor: json['addravnovalor'] as bool?,
      addcomissaonovalor: json['addcomissaonovalor'] as bool?,
      gerartituloservicofor: json['gerartituloservicofor'] as bool?,
      gerartituloservicocomis: json['gerartituloservicocomis'] as bool?,
      idplanocontaaereo: json['idplanocontaaereo'] as int?,
      idplanocontaforaereo: json['idplanocontaforaereo'] as int?,
      idplanocontaservico: json['idplanocontaservico'] as int?,
      idplanocontaforservico: json['idplanocontaforservico'] as int?,
      idplanocontacomisservico: json['idplanocontacomisservico'] as int?,
      idplanocontapacote: json['idplanocontapacote'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idformapagamento': idformapagamento,
      'nome': nome,
      'tipo': tipo,
      'debito': debito,
      'credito': credito,
      'gerartitulofatura': gerartitulofatura,
      'gerartitulovenda': gerartitulovenda,
      'baixaautomatica': baixaautomatica,
      'vendaparcelada': vendaparcelada,
      'empresa': empresa,
      'gerarfatura': gerarfatura,
      'addtaxanovalor': addtaxanovalor,
      'addassentonovalor': addassentonovalor,
      'addravnovalor': addravnovalor,
      'addcomissaonovalor': addcomissaonovalor,
      'gerartituloservicofor': gerartituloservicofor,
      'gerartituloservicocomis': gerartituloservicocomis,
      'idplanocontaaereo': idplanocontaaereo,
      'idplanocontaforaereo': idplanocontaforaereo,
      'idplanocontaservico': idplanocontaservico,
      'idplanocontaforservico': idplanocontaforservico,
      'idplanocontacomisservico': idplanocontacomisservico,
      'idplanocontapacote': idplanocontapacote,
    };
  }
}
