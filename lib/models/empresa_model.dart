class Empresa {
  final int? idempresa;
  final String? nome;
  final String? razaosocial;
  final String? cnpjcpf;
  final String? celular1;
  final String? celular2;
  final String? telefone1;
  final String? telefone2;
  final String? redessociais;
  final String? home;
  final String? email;
  final String? linkimagem;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? codigoempresa;
  final String? referencia;
  final String? licenca;
  final DateTime? datalimitecons;
  final int? machine;
  final bool? machinefree;
  final bool? emissivo;
  final bool? receptivo;
  final bool? financeiro;
  final bool? advocaticio;
  final DateTime? databloqueio;
  final bool? bloqueado;

  Empresa({
    this.idempresa,
    this.nome,
    this.razaosocial,
    this.cnpjcpf,
    this.celular1,
    this.celular2,
    this.telefone1,
    this.telefone2,
    this.redessociais,
    this.home,
    this.email,
    this.linkimagem,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.codigoempresa,
    this.referencia,
    this.licenca,
    this.datalimitecons,
    this.machine,
    this.machinefree,
    this.emissivo,
    this.receptivo,
    this.financeiro,
    this.advocaticio,
    this.databloqueio,
    this.bloqueado,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      idempresa: json['idempresa'] as int?,
      nome: json['nome'] as String?,
      razaosocial: json['razaosocial'] as String?,
      cnpjcpf: json['cnpjcpf'] as String?,
      celular1: json['celular1'] as String?,
      celular2: json['celular2'] as String?,
      telefone1: json['telefone1'] as String?,
      telefone2: json['telefone2'] as String?,
      redessociais: json['redessociais'] as String?,
      home: json['home'] as String?,
      email: json['email'] as String?,
      linkimagem: json['linkimagem'] as String?,
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      codigoempresa: json['codigoempresa'] as String?,
      referencia: json['referencia'] as String?,
      licenca: json['licenca'] as String?,
      datalimitecons: json['datalimitecons'] is String ? DateTime.parse(json['datalimitecons']) : json['datalimitecons'], 
      machine: json['machine'] as int?,
      machinefree: json['machinefree'] as bool?,
      emissivo: json['emissivo'] as bool?,
      receptivo: json['receptivo'] as bool?,
      financeiro: json['financeiro'] as bool?,
      advocaticio: json['advocaticio'] as bool?,
      databloqueio: json['databloqueio'] is String ? DateTime.parse(json['databloqueio']) : json['databloqueio'], 
      bloqueado: json['bloqueado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idempresa': idempresa,
      'nome': nome,
      'razaosocial': razaosocial,
      'cnpjcpf': cnpjcpf,
      'celular1': celular1,
      'celular2': celular2,
      'telefone1': telefone1,
      'telefone2': telefone2,
      'redessociais': redessociais,
      'home': home,
      'email': email,
      'linkimagem': linkimagem,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'codigoempresa': codigoempresa,
      'referencia': referencia,
      'licenca': licenca,
      'datalimitecons': datalimitecons?.toIso8601String(),
      'machine': machine,
      'machinefree': machinefree,
      'emissivo': emissivo,
      'receptivo': receptivo,
      'financeiro': financeiro,
      'advocaticio': advocaticio,
      'databloqueio': databloqueio?.toIso8601String(),
      'bloqueado': bloqueado,
    };
  }
}
