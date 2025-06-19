class Entidade {
  final int? identidade;
  final String? nome;
  final String? fantasia;
  final String? cnpjcpf;
  final String? celular1;
  final String? celular2;
  final String? telefone1;
  final String? telefone2;
  final DateTime? datacadastro;
  final DateTime? datanascimento;
  final String? email;
  final bool? ativo;
  final bool? for_;
  final bool? cli;
  final bool? vend;
  final bool? emis;
  final bool? mot;
  final bool? gui;
  final bool? cia;
  final bool? ope;
  final bool? hot;
  final String? sigla;
  final String? cartaosigla1;
  final String? cartaonumero1;
  final int? cartaomesvencimento1;
  final int? cartaoanovencimento1;
  final int? cartaodiafechamento1;
  final String? cartaotitular1;
  final String? cartaosigla2;
  final String? cartaonumero2;
  final int? cartaomesvencimento2;
  final int? cartaoanovencimento2;
  final int? cartaodiafechamento2;
  final String? cartaotitular2;
  final String? chave;
  final int? atividadeid;
  final String? empresa;
  final bool? seg;
  final bool? ter;
  final bool? loc;
  final bool? sexo;
  final bool? pes;
  final String? documento;
  final String? tipodocumento;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;

  Entidade({
    this.identidade,
    this.nome,
    this.fantasia,
    this.cnpjcpf,
    this.celular1,
    this.celular2,
    this.telefone1,
    this.telefone2,
    this.datacadastro,
    this.datanascimento,
    this.email,
    this.ativo,
    this.for_,
    this.cli,
    this.vend,
    this.emis,
    this.mot,
    this.gui,
    this.cia,
    this.ope,
    this.hot,
    this.sigla,
    this.cartaosigla1,
    this.cartaonumero1,
    this.cartaomesvencimento1,
    this.cartaoanovencimento1,
    this.cartaodiafechamento1,
    this.cartaotitular1,
    this.cartaosigla2,
    this.cartaonumero2,
    this.cartaomesvencimento2,
    this.cartaoanovencimento2,
    this.cartaodiafechamento2,
    this.cartaotitular2,
    this.chave,
    this.atividadeid,
    this.empresa,
    this.seg,
    this.ter,
    this.loc,
    this.sexo,
    this.pes,
    this.documento,
    this.tipodocumento,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,

  });

  factory Entidade.fromJson(Map<String, dynamic> json) {
    return Entidade(
      identidade: json['identidade'] as int?,
      nome: json['nome'] as String?,
      fantasia: json['fantasia'] as String?,
      cnpjcpf: json['cnpjcpf'] as String?,
      celular1: json['celular1'] as String?,
      celular2: json['celular2'] as String?,
      telefone1: json['telefone1'] as String?,
      telefone2: json['telefone2'] as String?,
      datacadastro: json['datacadastro'] is String ? DateTime.parse(json['datacadastro']) : json['datacadastro'],
      datanascimento: json['datanascimento'] is String ? DateTime.parse(json['datanascimento']) : json['datanascimento'],//json['datanascimento'] != null ? DateTime.parse(json['datanascimento']) : null,
      email: json['email'] as String?,
      ativo: json['ativo'] as bool?,
      for_: json['for'] as bool?,
      cli: json['cli'] as bool?,
      vend: json['vend'] as bool?,
      emis: json['emis'] as bool?,
      mot: json['mot'] as bool?,
      gui: json['gui'] as bool?,
      cia: json['cia'] as bool?,
      ope: json['ope'] as bool?,
      hot: json['hot'] as bool?,
      sigla: json['sigla'] as String?,
      cartaosigla1: json['cartao_sigla_1'] as String?,
      cartaonumero1: json['cartao_numero_1'] as String?,
      cartaomesvencimento1: json['cartao_mesvencimento_1'] as int?,
      cartaoanovencimento1: json['cartao_anovencimento_1'] as int?,
      cartaodiafechamento1: json['cartao_diafechamento_1'] as int?,
      cartaotitular1: json['cartao_titular_1'] as String?,
      cartaosigla2: json['cartao_sigla_2'] as String?,
      cartaonumero2: json['cartao_numero_2'] as String?,
      cartaomesvencimento2: json['cartao_mesvencimento_2'] as int?,
      cartaoanovencimento2: json['cartao_anovencimento_2'] as int?,
      cartaodiafechamento2: json['cartao_diafechamento_2'] as int?,
      cartaotitular2: json['cartao_titular_2'] as String?,
      chave: json['chave'] as String?,
      atividadeid: json['atividadeid'] as int?,
      empresa: json['empresa'] as String?,
      seg: json['seg'] as bool?,
      ter: json['ter'] as bool?,
      loc: json['loc'] as bool?,
      sexo: json['sexo'] as bool?,
      pes: json['pes'] as bool?,
      documento: json['documento'] as String?,
      tipodocumento: json['tipodocumento'] as String?,
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identidade': identidade,
      'nome': nome,
      'fantasia': fantasia,
      'cnpjcpf': cnpjcpf,
      'Celular1': celular1,
      'Celular2': celular2,
      'Telefone1': telefone1,
      'Telefone2': telefone2,
      'datacadastro': datacadastro?.toIso8601String(),
      'datanascimento': datanascimento?.toIso8601String(),
      'email': email,
      'ativo': ativo,
      'for': for_,
      'cli': cli,
      'vend': vend,
      'emis': emis,
      'mot': mot,
      'gui': gui,
      'cia': cia,
      'ope': ope,
      'hot': hot,
      'Sigla': sigla,
      'cartao_sigla_1': cartaosigla1,
      'cartao_numero_1': cartaonumero1,
      'cartao_mesvencimento_1': cartaomesvencimento1,
      'cartao_anovencimento_1': cartaoanovencimento1,
      'cartao_diafechamento_1': cartaodiafechamento1,
      'cartao_titular_1': cartaotitular1,
      'cartao_sigla_2': cartaosigla2,
      'cartao_numero_2': cartaonumero2,
      'cartao_mesvencimento_2': cartaomesvencimento2,
      'cartao_anovencimento_2': cartaoanovencimento2,
      'cartao_diafechamento_2': cartaodiafechamento2,
      'cartao_titular_2': cartaotitular2,
      'chave': chave,
      'atividadeid': atividadeid,
      'empresa': empresa,
      'seg': seg,
      'ter': ter,
      'loc': loc,
      'sexo': sexo,
      'pes': pes,
      'documento': documento,
      'tipodocumento': tipodocumento,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }
}
