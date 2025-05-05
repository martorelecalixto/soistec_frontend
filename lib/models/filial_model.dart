class Filial {
  final int? idfilial;
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
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? empresa;

  Filial({
    this.idfilial,
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
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.empresa,
  });

  factory Filial.fromJson(Map<String, dynamic> json) {
    return Filial(
      idfilial: json['IdFilial'] as int?,
      nome: json['Nome'] as String?,
      razaosocial: json['RazaoSocial'] as String?,
      cnpjcpf: json['cnpjcpf'] as String?,
      celular1: json['Celular1'] as String?,
      celular2: json['Celular2'] as String?,
      telefone1: json['Telefone1'] as String?,
      telefone2: json['Telefone2'] as String?,
      redessociais: json['RedesSociais'] as String?,
      home: json['Home'] as String?,
      email: json['Email'] as String?,
      cep: json['CEP'] as String?,
      logradouro: json['Logradouro'] as String?,
      numero: json['Numero'] as String?,
      complemento: json['Complemento'] as String?,
      bairro: json['Bairro'] as String?,
      cidade: json['Cidade'] as String?,
      estado: json['Estado'] as String?,
      empresa: json['empresa'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idfilial': idfilial,
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
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'empresa': empresa,
    };
  }
}
