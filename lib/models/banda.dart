
// COMMIT [FUTURO]: adicionar campo 'fotoUrl' para exibir imagem real da banda
// final String fotoUrl;

//  COMMIT [FUTURO]: adicionar campo 'redesSociais' (Map<String,String>)
//  para exibir links de Instagram, YouTube etc.

enum GeneroBanda { vanerao, xote, milonga, nativismo, chamame }

extension GeneroBandaExt on GeneroBanda {
  String get label => switch (this) {
    GeneroBanda.vanerao   => 'Vanerão',
    GeneroBanda.xote      => 'Xote',
    GeneroBanda.milonga   => 'Milonga',
    GeneroBanda.nativismo => 'Nativismo',
    GeneroBanda.chamame   => 'Chamamé',
  };
}

class Banda {
  final String id;
  final String nome;
  final String origem;
  final String bio;
  final List<GeneroBanda> generos;
  final int anoFundacao;

  // COMMIT [FUTURO]: adicionar fotoUrl e redesSociais no construtor aqui

  const Banda({
    required this.id,
    required this.nome,
    required this.origem,
    required this.bio,
    required this.generos,
    required this.anoFundacao,
  });

  int    get anosCarreira  => DateTime.now().year - anoFundacao;
  String get generosLabel  => generos.map((g) => g.label).join(' · ');
}

class BandasMock {
  // COMMIT [FUTURO]: substituir esta lista por chamada a uma API REST
  // Future<List<Banda>> fetchBandas() async { ... }
  static const lista = [
    Banda(
      id: 'b1', nome: 'Querência Gaúcha',
      origem: 'Passo Fundo - RS',
      bio: 'Referência no vanerão moderno desde 2003, misturando raiz e inovação.',
      generos: [GeneroBanda.vanerao, GeneroBanda.xote],
      anoFundacao: 2003,
    ),
    Banda(
      id: 'b2', nome: 'Duo Pampa & Viola',
      origem: 'Uruguaiana - RS',
      bio: 'Especialistas em milonga e chamamé fronteiriço. Irmãos Gilberto e José Carlos.',
      generos: [GeneroBanda.milonga, GeneroBanda.chamame],
      anoFundacao: 2010,
    ),
    Banda(
      id: 'b3', nome: 'Galpão Crioulo',
      origem: 'Porto Alegre - RS',
      bio: 'Mais de 20 anos preservando o nativismo gaúcho nos palcos do Sul.',
      generos: [GeneroBanda.nativismo, GeneroBanda.xote],
      anoFundacao: 2000,
    ),
    Banda(
      id: 'b4', nome: 'Tchê Baile',
      origem: 'Caxias do Sul - RS',
      bio: 'Vanerão jovem com energia e tradição, conquistando o sul do Brasil.',
      generos: [GeneroBanda.vanerao, GeneroBanda.nativismo],
      anoFundacao: 2015,
    ),
  ];

  static Banda? porId(String id) {
    try { return lista.firstWhere((b) => b.id == id); }
    catch (_) { return null; }
  }
}