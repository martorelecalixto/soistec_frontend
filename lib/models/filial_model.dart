class Filial {
  final int? idfilial;
  final String nome;
  final String razaosocial;
  final String cnpjcpf;
  final String celular1;
  final String celular2;
  final String telefone1;
  final String telefone2;
  final String redessociais;
  final String home;
  final String email;
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;

  Filial({
    this.idfilial,
    required this.nome,
    required this.razaosocial,
    required this.cnpjcpf,
    required this.celular1,
    required this.celular2,
    required this.telefone1,
    required this.telefone2,
    required this.redessociais,
    required this.home,
    required this.email,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  factory Filial.fromJson(Map<String, dynamic> json) {
    return Filial(
      idfilial: json['idfilial'],
      nome: json['nome'],
      razaosocial: json['razaosocial'],
      cnpjcpf: json['cnpjcpf'],
      celular1: json['celular1'],
      celular2: json['celular2'],
      telefone1: json['telefone1'],
      telefone2: json['telefone2'],
      redessociais: json['redessociais'],
      home: json['home'],
      email: json['email'],
      cep: json['cep'],
      logradouro: json['logradouro'],
      numero: json['numero'],
      complemento: json['complemento'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
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
    };
  }
}
