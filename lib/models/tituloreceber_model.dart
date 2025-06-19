class TituloReceber {
  final int? idtitulo;
  final DateTime? dataemissao;
  final DateTime? datavencimento;
  final DateTime? datacompetencia;
  final String? descricao;
  final String? documento;
  final double? valor;
  final double? valorpago;
  final double? descontopago;
  final double? juropago;
  final int? parcela;
  final int? idvendabilhete;
  final int? idvendahotel;
  final int? idvendapacote;
  final int? idfatura;
  final int? identidade;
  final int? idmoeda;
  final int? idformapagamento;
  final int? idplanoconta;
  final int? idcentrocusto;
  final int? idfilial;
  final String? chave;
  final String? empresa;
  final bool? comissao;
  final int? idnotacredito;
  final int? idnotadebito;
  final int? idreembolso;
  final int? id;
  final int? idnf;
  final String? numeronf;
  final bool? titulovalorentrada;
  final String? entidade;
  final String? pagamento;
  final String? planoconta;

  TituloReceber({
    this.idtitulo,
    this.dataemissao,
    this.datavencimento,
    this.datacompetencia,
    this.descricao,
    this.documento,
    this.valor,
    this.valorpago,
    this.descontopago,
    this.juropago,
    this.parcela,
    this.idvendabilhete,
    this.idvendahotel,
    this.idvendapacote,
    this.idfatura,
    this.identidade,
    this.idmoeda,
    this.idformapagamento,
    this.idplanoconta,
    this.idcentrocusto,
    this.idfilial,
    this.chave,
    this.empresa,
    this.comissao,
    this.idnotacredito,
    this.idnotadebito,
    this.idreembolso,
    this.id,
    this.idnf,
    this.numeronf,
    this.titulovalorentrada,
    this.entidade,
    this.pagamento,
    this.planoconta,
  });

  factory TituloReceber.fromJson(Map<String, dynamic> json) {
    return TituloReceber(
      idtitulo: json['idtitulo'] as int?,
      dataemissao: json['dataemissao'] != null ? DateTime.parse(json['dataemissao']) : null,
      datavencimento: json['datavencimento'] != null ? DateTime.parse(json['datavencimento']) : null,
      datacompetencia: json['datacompetencia'] != null ? DateTime.parse(json['datacompetencia']) : null,
      descricao: json['descricao'] as String?,
      documento: json['documento'] as String?,
      valor: (json['valor'] as num?)?.toDouble(),
      valorpago: (json['valorpago'] as num?)?.toDouble(),
      descontopago: (json['descontopago'] as num?)?.toDouble(),
      juropago: (json['juropago'] as num?)?.toDouble(),
      parcela: json['parcela'] as int?,
      idvendabilhete: json['idvendabilhete'] as int?,
      idvendahotel: json['idvendahotel'] as int?,
      idvendapacote: json['idvendapacote'] as int?,
      idfatura: json['idfatura'] as int?,
      identidade: json['identidade'] as int?,
      idmoeda: json['idmoeda'] as int?,
      idformapagamento: json['idformapagamento'] as int?,
      idplanoconta: json['idplanoconta'] as int?,
      idcentrocusto: json['idcentrocusto'] as int?,
      idfilial: json['idfilial'] as int?,
      chave: json['chave'] as String?,
      empresa: json['empresa'] as String?,
      comissao: json['comissao'] as bool?,
      idnotacredito: json['idnotacredito'] as int?,
      idnotadebito: json['idnotadebito'] as int?,
      idreembolso: json['idreembolso'] as int?,
      id: json['id'] as int?,
      idnf: json['idnf'] as int?,
      numeronf: json['numeronf'] as String?,
      titulovalorentrada: json['titulovalorentrada'] as bool?,
      entidade: json['entidade'] as String?,
      pagamento: json['pagamento'] as String?,
      planoconta: json['planoconta'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idtitulo': idtitulo,
      'dataemissao': dataemissao?.toIso8601String(),
      'datavencimento': datavencimento?.toIso8601String(),
      'datacompetencia': datacompetencia?.toIso8601String(),
      'descricao': descricao,
      'documento': documento,
      'valor': valor,
      'valorpago': valorpago,
      'descontopago': descontopago,
      'juropago': juropago,
      'parcela': parcela,
      'idvendabilhete': idvendabilhete,
      'idvendahotel': idvendahotel,
      'idvendapacote': idvendapacote,
      'idfatura': idfatura,
      'identidade': identidade,
      'idmoeda': idmoeda,
      'idformapagamento': idformapagamento,
      'idplanoconta': idplanoconta,
      'idcentrocusto': idcentrocusto,
      'idfilial': idfilial,
      'chave': chave,
      'empresa': empresa,
      'comissao': comissao,
      'idnotacredito': idnotacredito,
      'idnotadebito': idnotadebito,
      'idreembolso': idreembolso,
      'id': id,
      'idnf': idnf,
      'numeronf': numeronf,
      'titulovalorentrada': titulovalorentrada,
      'entidade': entidade,
      'pagamento': pagamento,
      'planoconta': planoconta,
    };
  }
}
