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
      idfilial: json['idfilial'] as int?,
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
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
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
