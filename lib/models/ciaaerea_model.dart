class CiaAerea {
  final int? idciaaerea;
  final double? percomisnac;
  final double? percomisint;
  final double? overnac;
  final double? overint;
  final bool? liqaddtarifanaciv;
  final bool? liqaddtaxanaciv;
  final bool? liqadddunaciv;
  final bool? liqaddcomissaonaciv;
  final bool? liqaddovernaciv;
  final bool? liqaddtarifanaccc;
  final bool? liqaddtaxanaccc;
  final bool? liqadddunaccc;
  final bool? liqaddcomissaonaccc;
  final bool? liqaddovernaccc;
  final bool? liqaddtarifaintiv;
  final bool? liqaddtaxaintiv;
  final bool? liqaddduintiv;
  final bool? liqaddcomissaointiv;
  final bool? liqaddoverintiv;
  final bool? liqaddtarifaintcc;
  final bool? liqaddtaxaintcc;
  final bool? liqaddduintcc;
  final bool? liqaddcomissaointcc;
  final bool? liqaddoverintcc;
  final bool? liqdedtarifanaciv;
  final bool? liqdedtaxanaciv;
  final bool? liqdeddunaciv;
  final bool? liqdedcomissaonaciv;
  final bool? liqdedovernaciv;
  final bool? liqdedtarifanaccc;
  final bool? liqdedtaxanaccc;
  final bool? liqdeddunaccc;
  final bool? liqdedcomissaonaccc;
  final bool? liqdedovernaccc;
  final bool? liqdedtarifaintiv;
  final bool? liqdedtaxaintiv;
  final bool? liqdedduintiv;
  final bool? liqdedcomissaointiv;
  final bool? liqdedoverintiv;
  final bool? liqdedtarifaintcc;
  final bool? liqdedtaxaintcc;
  final bool? liqdedduintcc;
  final bool? liqdedcomissaointcc;
  final bool? liqdedoverintcc;
  final double? valorininac1;
  final double? valorfinnac1;
  final double? valornac1;
  final double? percnac1;
  final double? valorininac2;
  final double? valorfinnac2;
  final double? valornac2;
  final double? percnac2;
  final double? valoriniint1;
  final double? valorfinint1;
  final double? valorint1;
  final double? percint1;
  final double? valoriniint2;
  final double? valorfinint2;
  final double? valorint2;
  final double? percint2;
  final int? entidadeid;

  CiaAerea({
    this.idciaaerea,
    this.percomisnac,
    this.percomisint,
    this.overnac,
    this.overint,
    this.liqaddtarifanaciv,
    this.liqaddtaxanaciv,
    this.liqadddunaciv,
    this.liqaddcomissaonaciv,
    this.liqaddovernaciv,
    this.liqaddtarifanaccc,
    this.liqaddtaxanaccc,
    this.liqadddunaccc,
    this.liqaddcomissaonaccc,
    this.liqaddovernaccc,
    this.liqaddtarifaintiv,
    this.liqaddtaxaintiv,
    this.liqaddduintiv,
    this.liqaddcomissaointiv,
    this.liqaddoverintiv,
    this.liqaddtarifaintcc,
    this.liqaddtaxaintcc,
    this.liqaddduintcc,
    this.liqaddcomissaointcc,
    this.liqaddoverintcc,
    this.liqdedtarifanaciv,
    this.liqdedtaxanaciv,
    this.liqdeddunaciv,
    this.liqdedcomissaonaciv,
    this.liqdedovernaciv,
    this.liqdedtarifanaccc,
    this.liqdedtaxanaccc,
    this.liqdeddunaccc,
    this.liqdedcomissaonaccc,
    this.liqdedovernaccc,
    this.liqdedtarifaintiv,
    this.liqdedtaxaintiv,
    this.liqdedduintiv,
    this.liqdedcomissaointiv,
    this.liqdedoverintiv,
    this.liqdedtarifaintcc,
    this.liqdedtaxaintcc,
    this.liqdedduintcc,
    this.liqdedcomissaointcc,
    this.liqdedoverintcc,
    this.valorininac1,
    this.valorfinnac1,
    this.valornac1,
    this.percnac1,
    this.valorininac2,
    this.valorfinnac2,
    this.valornac2,
    this.percnac2,
    this.valoriniint1,
    this.valorfinint1,
    this.valorint1,
    this.percint1,
    this.valoriniint2,
    this.valorfinint2,
    this.valorint2,
    this.percint2,
    this.entidadeid,
  });

  factory CiaAerea.fromJson(Map<String, dynamic> json) {
    return CiaAerea(
      idciaaerea: json['idciaaerea'] as int?,
      percomisnac: (json['percomisnac'] as num?)?.toDouble(),
      percomisint: (json['percomisint'] as num?)?.toDouble(),
      overnac: (json['overnac'] as num?)?.toDouble(),
      overint: (json['overint'] as num?)?.toDouble(),
      liqaddtarifanaciv: json['liqaddtarifanaciv'] as bool?,
      liqaddtaxanaciv: json['liqaddtaxanaciv'] as bool?,
      liqadddunaciv: json['liqadddunaciv'] as bool?,
      liqaddcomissaonaciv: json['liqaddcomissaonaciv'] as bool?,
      liqaddovernaciv: json['liqaddovernaciv'] as bool?,
      liqaddtarifanaccc: json['liqaddtarifanaccc'] as bool?,
      liqaddtaxanaccc: json['liqaddtaxanaccc'] as bool?,
      liqadddunaccc: json['liqadddunaccc'] as bool?,
      liqaddcomissaonaccc: json['liqaddcomissaonaccc'] as bool?,
      liqaddovernaccc: json['liqaddovernaccc'] as bool?,
      liqaddtarifaintiv: json['liqaddtarifaintiv'] as bool?,
      liqaddtaxaintiv: json['liqaddtaxaintiv'] as bool?,
      liqaddduintiv: json['liqaddduintiv'] as bool?,
      liqaddcomissaointiv: json['liqaddcomissaointiv'] as bool?,
      liqaddoverintiv: json['liqaddoverintiv'] as bool?,
      liqaddtarifaintcc: json['liqaddtarifaintcc'] as bool?,
      liqaddtaxaintcc: json['liqaddtaxaintcc'] as bool?,
      liqaddduintcc: json['liqaddduintcc'] as bool?,
      liqaddcomissaointcc: json['liqaddcomissaointcc'] as bool?,
      liqaddoverintcc: json['liqaddoverintcc'] as bool?,
      liqdedtarifanaciv: json['liqdedtarifanaciv'] as bool?,
      liqdedtaxanaciv: json['liqdedtaxanaciv'] as bool?,
      liqdeddunaciv: json['liqdeddunaciv'] as bool?,
      liqdedcomissaonaciv: json['liqdedcomissaonaciv'] as bool?,
      liqdedovernaciv: json['liqdedovernaciv'] as bool?,
      liqdedtarifanaccc: json['liqdedtarifanaccc'] as bool?,
      liqdedtaxanaccc: json['liqdedtaxanaccc'] as bool?,
      liqdeddunaccc: json['liqdeddunaccc'] as bool?,
      liqdedcomissaonaccc: json['liqdedcomissaonaccc'] as bool?,
      liqdedovernaccc: json['liqdedovernaccc'] as bool?,
      liqdedtarifaintiv: json['liqdedtarifaintiv'] as bool?,
      liqdedtaxaintiv: json['liqdedtaxaintiv'] as bool?,
      liqdedduintiv: json['liqdedduintiv'] as bool?,
      liqdedcomissaointiv: json['liqdedcomissaointiv'] as bool?,
      liqdedoverintiv: json['liqdedoverintiv'] as bool?,
      liqdedtarifaintcc: json['liqdedtarifaintcc'] as bool?,
      liqdedtaxaintcc: json['liqdedtaxaintcc'] as bool?,
      liqdedduintcc: json['liqdedduintcc'] as bool?,
      liqdedcomissaointcc: json['liqdedcomissaointcc'] as bool?,
      liqdedoverintcc: json['liqdedoverintcc'] as bool?,
      valorininac1: (json['valorininac1'] as num?)?.toDouble(),
      valorfinnac1: (json['valorfinnac1'] as num?)?.toDouble(),
      valornac1: (json['valornac1'] as num?)?.toDouble(),
      percnac1: (json['percnac1'] as num?)?.toDouble(),
      valorininac2: (json['valorininac2'] as num?)?.toDouble(),
      valorfinnac2: (json['valorfinnac2'] as num?)?.toDouble(),
      valornac2: (json['valornac2'] as num?)?.toDouble(),
      percnac2: (json['percnac2'] as num?)?.toDouble(),
      valoriniint1: (json['valoriniint1'] as num?)?.toDouble(),
      valorfinint1: (json['valorfinint1'] as num?)?.toDouble(),
      valorint1: (json['valorint1'] as num?)?.toDouble(),
      percint1: (json['percint1'] as num?)?.toDouble(),
      valoriniint2: (json['valoriniint2'] as num?)?.toDouble(),
      valorfinint2: (json['valorfinint2'] as num?)?.toDouble(),
      valorint2: (json['valorint2'] as num?)?.toDouble(),
      percint2: (json['percint2'] as num?)?.toDouble(),
      entidadeid: json['entidadeid'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idciaaerea': idciaaerea,
      'percomisnac': percomisnac,
      'percomisint': percomisint,
      'overnac': overnac,
      'overint': overint,
      'liqaddtarifanaciv': liqaddtarifanaciv,
      'liqaddtaxanaciv': liqaddtaxanaciv,
      'liqadddunaciv': liqadddunaciv,
      'liqaddcomissaonaciv': liqaddcomissaonaciv,
      'liqaddovernaciv': liqaddovernaciv,
      'liqaddtarifanaccc': liqaddtarifanaccc,
      'liqaddtaxanaccc': liqaddtaxanaccc,
      'liqadddunaccc': liqadddunaccc,
      'liqaddcomissaonaccc': liqaddcomissaonaccc,
      'liqaddovernaccc': liqaddovernaccc,
      'liqaddtarifaintiv': liqaddtarifaintiv,
      'liqaddtaxaintiv': liqaddtaxaintiv,
      'liqaddduintiv': liqaddduintiv,
      'liqaddcomissaointiv': liqaddcomissaointiv,
      'liqaddoverintiv': liqaddoverintiv,
      'liqaddtarifaintcc': liqaddtarifaintcc,
      'liqaddtaxaintcc': liqaddtaxaintcc,
      'liqaddduintcc': liqaddduintcc,
      'liqaddcomissaointcc': liqaddcomissaointcc,
      'liqaddoverintcc': liqaddoverintcc,
      'liqdedtarifanaciv': liqdedtarifanaciv,
      'liqdedtaxanaciv': liqdedtaxanaciv,
      'liqdeddunaciv': liqdeddunaciv,
      'liqdedcomissaonaciv': liqdedcomissaonaciv,
      'liqdedovernaciv': liqdedovernaciv,
      'liqdedtarifanaccc': liqdedtarifanaccc,
      'liqdedtaxanaccc': liqdedtaxanaccc,
      'liqdeddunaccc': liqdeddunaccc,
      'liqdedcomissaonaccc': liqdedcomissaonaccc,
      'liqdedovernaccc': liqdedovernaccc,
      'liqdedtarifaintiv': liqdedtarifaintiv,
      'liqdedtaxaintiv': liqdedtaxaintiv,
      'liqdedduintiv': liqdedduintiv,
      'liqdedcomissaointiv': liqdedcomissaointiv,
      'liqdedoverintiv': liqdedoverintiv,
      'liqdedtarifaintcc': liqdedtarifaintcc,
      'liqdedtaxaintcc': liqdedtaxaintcc,
      'liqdedduintcc': liqdedduintcc,
      'liqdedcomissaointcc': liqdedcomissaointcc,
      'liqdedoverintcc': liqdedoverintcc,
      'valorininac1': valorininac1,
      'valorfinnac1': valorfinnac1,
      'valornac1': valornac1,
      'percnac1': percnac1,
      'valorininac2': valorininac2,
      'valorfinnac2': valorfinnac2,
      'valornac2': valornac2,
      'percnac2': percnac2,
      'valoriniint1': valoriniint1,
      'valorfinint1': valorfinint1,
      'valorint1': valorint1,
      'percint1': percint1,
      'valoriniint2': valoriniint2,
      'valorfinint2': valorfinint2,
      'valorint2': valorint2,
      'percint2': percint2,
      'entidadeid': entidadeid,
    };
  }
}
