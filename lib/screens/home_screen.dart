import 'package:flutter/material.dart'; 
import 'package:sqflite/sqflite.dart'; 

import '../models/banda.dart'; 
import '../models/evento.dart';
import '../models/reserva.dart'; 
import '../models/user.dart'; 
import '../services/database_helper.dart'; 
import '../services/reserva_repo.dart'; 
import '../services/session_manager.dart';
import '../utils/app_theme.dart'; 
import '../widgets/banda_card.dart';
import '../widgets/evento_card.dart'; 
import '../widgets/user_card.dart'; 
import '../widgets/user_form_dialog.dart'; 
import 'detalhe_banda_screen.dart'; 
import 'login_screen.dart';
import 'reserva_screen.dart'; 
import 'status_reservas_screen.dart';
import 'users_management_screen.dart';

class HomeScreen extends StatefulWidget {
  
  const HomeScreen(
      {super.key}); 

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState(); 
}

class _HomeScreenState extends State<HomeScreen> {
  
  int _aba = 0; 

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
   
      bottomNavigationBar: NavigationBar(
    
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() =>
            _aba = i),
        backgroundColor:
            AppTheme.vermelho,
        indicatorColor: AppTheme.dourado, 
        destinations: const [
         
          NavigationDestination(
            icon: Icon(Icons.celebration_outlined,
                color: Colors.white70),
            selectedIcon: Icon(Icons.celebration,
                color: AppTheme.vermelho), 
            label: 'Eventos', 
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined,
                color: Colors
                    .white70), 
            selectedIcon: Icon(Icons.music_note,
                color: AppTheme
                    .vermelho), 
            label: 'Bandas', // Texto do destino.
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined,
                color: Colors
                    .white70), // Ícone do destino "Reservas" (não selecionado).
            selectedIcon: Icon(Icons.table_restaurant,
                color: AppTheme
                    .vermelho), // Ícone do destino "Reservas" (selecionado).
            label: 'Reservas', // Texto do destino.
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline,
                color: Colors
                    .white70), // Ícone do destino "Conta" (não selecionado).
            selectedIcon: Icon(Icons.person,
                color: AppTheme
                    .vermelho), // Ícone do destino "Conta" (selecionado).
            label: 'Conta', // Texto do destino.
          ),
        ],
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              // Define estilo do label conforme o estado do widget.
              color: s.contains(WidgetState.selected)
                  ? AppTheme.dourado
                  : Colors.white60, // Cor diferente quando selecionado.
              fontSize: 12, // Tamanho do texto do label.
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.bold
                  : FontWeight.normal, // Negrito só no selecionado.
            )),
      ),
      body: IndexedStack(
        // IndexedStack troca a "aba" pelo índice, mas mantém estado das abas ativas.
        index: _aba, // Índice atual que determina qual child aparece.
        children: [
          // Lista de telas (widgets) para cada aba.
          _AbaEventos(
              onReservar: () => setState(
                  () {})), // Aba 0: Eventos. Chama setState ao voltar de uma reserva.
          const _AbaBandas(), // Aba 1: Bandas.
          _AbaReservas(
              onCancelar: () => setState(
                  () {})), // Aba 2: Reservas. Atualiza quando cancelar.
          const _AbaConta(), // Aba 3: Conta. Dados do usuário logado + CRUD de usuários + logout.
        ],
      ),
      floatingActionButton: _aba == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StatusReservasScreen()),
                );
              },
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Status'),
              backgroundColor: AppTheme.dourado,
              foregroundColor: AppTheme.marrom,
            )
          : null,
    );
  }
}

class _AbaEventos extends StatefulWidget {
  // StatefulWidget: precisa guardar a ocupação de mesas (consulta async ao SQLite).
  final VoidCallback
      onReservar; // Callback chamado após o usuário completar ou voltar da tela de reserva.
  const _AbaEventos(
      {required this.onReservar}); // Construtor: onReservar é obrigatório.

  @override
  State<_AbaEventos> createState() => _AbaEventosState();
}

class _AbaEventosState extends State<_AbaEventos> {
  // Mapa eventoId -> quantidade de reservas confirmadas (consultado no SQLite).
  Map<String, int> _ocupacao = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarOcupacao();
  }

  // Recarrega, para cada evento mockado, quantas reservas confirmadas
  // ele já tem — chamado na inicialização e após voltar de uma reserva.
  Future<void> _carregarOcupacao() async {
    final mapa = <String, int>{};
    for (final e in EventosMock.lista) {
      mapa[e.id] = await ReservaRepo.qtdReservasConfirmadas(e.id);
    }
    if (!mounted) return;
    setState(() {
      _ocupacao = mapa;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // build: monta a UI da aba Eventos.
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.vermelho),
        ),
      );
    }
    return Scaffold(
      // Scaffold individual da aba, com AppBar própria.
      appBar: AppBar(
        title: const Row(
          // Título da AppBar composto por ícones e texto centralizados.
          mainAxisSize: MainAxisSize
              .min, // Row ocupa só o espaço necessário (não estica até a borda).
          children: [
            Icon(Icons.star,
                color: AppTheme.dourado,
                size: 16), // Estrela decorativa à esquerda do título.
            SizedBox(width: 8), // Espaçamento entre estrela e texto.
            Text('Radar Gaúcho'), // Texto principal da AppBar.
            SizedBox(width: 8), // Espaçamento entre texto e estrela.
            Icon(Icons.star,
                color: AppTheme.dourado,
                size: 16), // Estrela decorativa à direita do título.
          ],
        ),
      ),
      body: ListView(
        // Lista rolável que contém o banner e os cards de eventos.
        children: [
          Container(
            // Banner decorativo no topo da lista com gradiente.
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18), // Espaçamento interno do banner.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // Gradiente de fundo do banner.
                colors: [
                  AppTheme.verdeEscuro,
                  AppTheme.marrom
                ], // Cores do degradê: verde escuro → marrom.
                begin: Alignment
                    .topLeft, // O gradiente começa no canto superior esquerdo.
                end: Alignment
                    .bottomRight, // E termina no canto inferior direito.
              ),
            ),
            child: const Column(
              // Coluna com dois textos dentro do banner.
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinha os textos à esquerda.
              children: [
                Text(
                  'Próximos bailes',
                  style: TextStyle(
                      color: AppTheme
                          .dourado), // Texto do título do banner na cor dourada.
                ),
                SizedBox(
                    height: 8), // Espaçamento vertical entre os dois textos.
                Text(
                  'Reserve sua mesa antes que acabe!',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13), // Subtítulo em branco semitransparente.
                ),
              ],
            ),
          ),
          const SizedBox(
              height: 4), // Pequeno espaçamento entre o banner e os cards.
          ...EventosMock.lista.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;

            final mesasOcupadas = _ocupacao[e.id] ?? 0;
            final mesasDisponiveisAtuais =
                (e.totalMesas - mesasOcupadas).clamp(0, e.totalMesas);

            final eventoAtual = Evento(
              id: e.id,
              nome: e.nome,
              descricao: e.descricao,
              data: e.data,
              local: e.local,
              cidade: e.cidade,
              preco: e.preco,
              totalMesas: e.totalMesas,
              mesasDisponiveis: mesasDisponiveisAtuais,
              bandasIds: e.bandasIds,
            );

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 450 + (i * 90)),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 16),
                    child: EventoCard(
                      evento: eventoAtual,
                      onTap: () {},
                      onReservar: eventoAtual.temMesa
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReservaScreen(evento: eventoAtual),
                                ),
                              ).then((_) {
                                _carregarOcupacao(); // atualiza mesas ocupadas desta aba
                                widget.onReservar(); // notifica a tela pai (comportamento existente)
                              })
                          : null,
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(
              height:
                  20), // Espaçamento no final da lista para não colar no fim da tela.
        ],
      ),
    );
  }
}

class _AbaBandas extends StatefulWidget {
  // StatefulWidget: guarda o filtro de gênero selecionado.
  const _AbaBandas();

  @override
  State<_AbaBandas> createState() =>
      _AbabandasState(); // Cria o State correspondente.
}

class _AbabandasState extends State<_AbaBandas> {
  // State da aba Bandas: controla o filtro ativo.
  GeneroBanda?
      _filtro; // Gênero selecionado para filtrar as bandas; null = exibir todas.

  List<Banda>
      get _lista => // Getter: retorna a lista filtrada ou completa conforme _filtro.
          _filtro == null
              ? BandasMock.lista
              : BandasMock.lista
                  .where((b) => b.generos.contains(_filtro))
                  .toList();
  // Se _filtro for null, retorna todas. Senão, filtra as bandas que contêm o gênero selecionado.

  @override
  Widget build(BuildContext context) {
    // build: monta a UI da aba Bandas.
    return Scaffold(
      appBar: AppBar(
          title: const Text('Bandas & Conjuntos')), // AppBar com título fixo.
      body: Column(
        // Layout em coluna: chips de filtro no topo + lista abaixo.
        children: [
          SizedBox(
            height: 52, // Altura fixa para a linha de filtros.
            child: ListView(
              // Lista horizontal dos FilterChips de gênero.
              scrollDirection:
                  Axis.horizontal, // Rolagem horizontal para os chips.
              padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8), // Margens internas da lista de chips.
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8), // Espaço à direita do chip "Todos".
                  child: FilterChip(
                    label: const Text(
                        'Todos'), // Label do chip que limpa o filtro.
                    selected: _filtro ==
                        null, // Chip "Todos" aparece selecionado quando não há filtro ativo.
                    onSelected: (_) => setState(() =>
                        _filtro = null), // Selecionar "Todos" limpa o filtro.
                    selectedColor:
                        AppTheme.vermelho, // Cor de fundo quando selecionado.
                    labelStyle: TextStyle(
                      color: _filtro == null
                          ? Colors.white
                          : AppTheme
                              .marrom, // Texto branco quando selecionado, marrom quando não.
                      fontWeight: _filtro == null
                          ? FontWeight.bold
                          : FontWeight.normal, // Negrito só quando ativo.
                    ),
                    checkmarkColor:
                        Colors.white, // Cor do ícone de check dentro do chip.
                  ),
                ),
                ...GeneroBanda.values.map((g) {
                  // Gera um FilterChip para cada valor do enum GeneroBanda.
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: 8), // Espaço entre chips.
                    child: FilterChip(
                      label: Text(g
                          .label), // Exibe o nome amigável do gênero (propriedade label do enum).
                      selected: _filtro ==
                          g, // Chip aparece selecionado se for o gênero ativo.
                      onSelected: (_) => setState(() => _filtro = _filtro == g
                          ? null
                          : g), // Toggle: seleciona ou deseleciona o gênero.
                      selectedColor:
                          AppTheme.vermelho, // Cor de fundo quando selecionado.
                      labelStyle: TextStyle(
                        color: _filtro == g
                            ? Colors.white
                            : AppTheme
                                .marrom, // Estilo dinâmico conforme seleção.
                        fontWeight:
                            _filtro == g ? FontWeight.bold : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.white, // Cor do check mark.
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            // Expanded: ocupa todo o espaço vertical restante abaixo dos chips.
            child: _lista
                    .isEmpty // Se a lista filtrada estiver vazia, exibe mensagem.
                ? const Center(
                    child: Text('Nenhuma banda encontrada.',
                        style: TextStyle(color: AppTheme.marrom)),
                  )
                : ListView.builder(
                    // ListView.builder: cria os cards sob demanda (mais eficiente para listas longas).
                    padding: const EdgeInsets.only(
                        bottom: 20), // Espaço no fim da lista.
                    itemCount: _lista.length, // Número de itens a renderizar.
                    itemBuilder: (ctx, i) => BandaCard(
                      // Função que constrói cada item da lista.
                      banda: _lista[
                          i], // Passa a banda correspondente ao índice i.
                      onVerDetalhes: () => Navigator.push(
                        // Navega para a tela de detalhe ao tocar no card.
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => DetalheBandaScreen(
                              banda: _lista[
                                  i]), // Passa a banda para a tela de detalhes.
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AbaReservas extends StatefulWidget {
  // StatefulWidget: precisa carregar de forma assíncrona as reservas
  // do usuário logado a partir do SQLite.
  final VoidCallback
      onCancelar; // Callback chamado após cancelar uma reserva, para forçar rebuild na tela pai.
  const _AbaReservas(
      {required this.onCancelar}); // Construtor: onCancelar é obrigatório.

  @override
  State<_AbaReservas> createState() => _AbaReservasState();
}

class _AbaReservasState extends State<_AbaReservas> {
  List<Reserva> _reservas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Recarrega apenas as reservas do usuário logado (SessionManager) —
  // chamado na inicialização e após cancelar/excluir uma reserva.
  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final userId = await SessionManager.getUserId();
    final reservas =
        userId == null ? <Reserva>[] : await ReservaRepo.doUsuario(userId);
    if (!mounted) return;
    setState(() {
      _reservas = reservas;
      _carregando = false;
    });
  }

  Future<void> _cancelar(Reserva r) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar reserva?'),
        content: Text(
            'Mesa ${r.numeroMesa} — ${r.nomeEvento}\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await ReservaRepo.cancelar(r.id!); // UPDATE de status (não apaga o registro)
    if (!mounted) return;
    await _carregar(); // atualiza a lista local
    widget.onCancelar(); // notifica a tela pai (comportamento existente)
  }

  Future<void> _excluir(Reserva r) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir reserva?'),
        content: Text(
            'Mesa ${r.numeroMesa} — ${r.nomeEvento}\nO registro será removido permanentemente do banco de dados.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await ReservaRepo.excluir(r.id!); // DELETE definitivo
    if (!mounted) return;
    await _carregar();
    widget.onCancelar();
  }

  String _fmt(DateTime d) {
    // Método auxiliar: formata um DateTime como "dd/mm/yyyy hh:mm".
    final dd = d.day
        .toString()
        .padLeft(2, '0'); // Dia com zero à esquerda se necessário.
    final mm = d.month.toString().padLeft(2, '0'); // Mês com zero à esquerda.
    final yyyy = d.year.toString().padLeft(4, '0'); // Ano com 4 dígitos.
    final hh = d.hour.toString().padLeft(2, '0'); // Hora com zero à esquerda.
    final min =
        d.minute.toString().padLeft(2, '0'); // Minuto com zero à esquerda.
    return '$dd/$mm/$yyyy $hh:$min'; // Retorna a string formatada.
  }

  @override
  Widget build(BuildContext context) {
    // build: monta a UI da aba Reservas.
    final reservas = _reservas; // Reservas do usuário logado, já carregadas.

    return Scaffold(
      appBar: AppBar(
          title: const Text('Minhas Reservas')), // AppBar com título fixo.
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.vermelho))
          : reservas.isEmpty // Se não há reservas, exibe estado vazio.
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centraliza o conteúdo verticalmente.
                children: [
                  Icon(Icons.table_restaurant_outlined,
                      size: 72,
                      color: AppTheme.dourado), // Ícone grande decorativo.
                  SizedBox(height: 12), // Espaço entre ícone e texto.
                  Text('Nenhuma reserva ainda.',
                      style: TextStyle(
                          color: AppTheme.marrom,
                          fontSize: 16)), // Mensagem principal.
                  SizedBox(height: 4), // Espaço entre os dois textos.
                  Text('Explore os eventos e reserve uma mesa!',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13)), // Mensagem secundária.
                ],
              ),
            )
          : ListView.builder(
              // Lista as reservas existentes.
              padding: const EdgeInsets.only(
                  top: 8, bottom: 24), // Espaçamento interno da lista.
              itemCount: reservas.length, // Número de reservas a exibir.
              itemBuilder: (ctx, i) {
                // Constrói cada item da lista.
                final r = reservas[i]; // Reserva atual.
                final cancelada = r.status ==
                    StatusReserva
                        .cancelada; // Verifica se a reserva está cancelada.

                return Card(
                  // Card visual para cada reserva.
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6), // Margem horizontal e vertical do card.
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8), // Espaçamento interno do ListTile.
                    leading: CircleAvatar(
                      // Avatar circular com o número da mesa.
                      backgroundColor: cancelada
                          ? Colors.grey
                          : AppTheme
                              .vermelho, // Cinza se cancelada, vermelho se ativa.
                      child: Text(
                        '${r.numeroMesa}', // Exibe o número da mesa dentro do avatar.
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      r.nomeEvento, // Nome do evento como título do ListTile.
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: AppTheme.marrom),
                    ),
                    subtitle: Column(
                      // Subtítulo com nome, número de pessoas e data.
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Alinha à esquerda.
                      children: [
                        Text(
                            '${r.nomeResponsavel} · ${r.numeroPessoas} pessoa(s)'), // Nome e quantidade de pessoas.
                        Text(
                          _fmt(r
                              .criadaEm), // Data formatada de criação da reserva.
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey), // Texto menor e em cinza.
                        ),
                      ],
                    ),
                    trailing:
                        cancelada // Lado direito do ListTile: chip "Cancelada" + excluir, ou botão de cancelar.
                            ? Row(
                                // Se já cancelada: chip informativo + opção de excluir de vez (DELETE real).
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Chip(
                                    label: Text('Cancelada',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11)),
                                    backgroundColor: Colors.grey,
                                    padding: EdgeInsets.zero,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    tooltip: 'Excluir definitivamente',
                                    onPressed: () => _excluir(r),
                                  ),
                                ],
                              )
                            : IconButton(
                                // Se ativa, exibe botão de cancelamento.
                                icon: const Icon(Icons.cancel_outlined,
                                    color: Colors
                                        .red), // Ícone de cancelar em vermelho.
                                onPressed: () => _cancelar(r),
                              ),
                  ),
                );
              },
            ),
    );
  }
}

class _AbaConta extends StatefulWidget {
  // StatefulWidget: carrega usuário logado + lista de usuários do SQLite.
  const _AbaConta();

  @override
  State<_AbaConta> createState() => _AbaContaState();
}

class _AbaContaState extends State<_AbaConta> {
  int? _meuId; // id do usuário logado, obtido do SessionManager.
  User?
      _meuUsuario; // dados completos do usuário logado, obtidos do DatabaseHelper.
  List<User> _usuarios = []; // lista de todos os usuários cadastrados.
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Recarrega o usuário logado e a lista completa de usuários — chamado
  // na inicialização e após qualquer inserção/edição/exclusão.
  Future<void> _carregar() async {
    setState(() => _carregando = true);

    final id = await SessionManager.getUserId();
    final usuarios = await DatabaseHelper.instance.getUsers();
    final meuUsuario =
        id == null ? null : await DatabaseHelper.instance.getUserById(id);

    if (!mounted) return;
    setState(() {
      _meuId = id;
      _meuUsuario = meuUsuario;
      _usuarios = usuarios;
      _carregando = false;
    });
  }

  Future<void> _confirmarLogout() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta?'),
        content:
            const Text('Você precisará entrar novamente para acessar o app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vermelho),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await SessionManager.logout();
    if (!mounted) return;

    // pushAndRemoveUntil: limpa toda a pilha, impedindo voltar para a Home sem sessão.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _editarUsuario(User usuario) async {
    final atualizado = await showUserFormDialog(context, user: usuario);
    if (atualizado == null) return; // usuário cancelou o dialog

    try {
      await DatabaseHelper.instance.updateUser(atualizado);

      // Se o usuário editado é o usuário logado, atualiza o e-mail
      // salvo na sessão para manter tudo consistente.
      if (atualizado.id == _meuId) {
        await SessionManager.updateSessionEmail(atualizado.email);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Usuário atualizado.'),
        backgroundColor: AppTheme.verdeEscuro,
      ));
      _carregar();
    } on DatabaseException catch (e) {
      final mensagem = e.isUniqueConstraintError()
          ? 'Este e-mail já está em uso por outro usuário.'
          : 'Não foi possível salvar as alterações.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(mensagem), backgroundColor: AppTheme.vermelho));
    }
  }

  Future<void> _excluirUsuario(User usuario) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir usuário?'),
        content: Text(
            '${usuario.name} (${usuario.email})\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await DatabaseHelper.instance.deleteUser(usuario.id!);
    if (!mounted) return;

    // Se o usuário excluiu a própria conta, a sessão fica inválida:
    // encerra a sessão e volta para o Login em vez de recarregar a aba.
    if (usuario.id == _meuId) {
      await SessionManager.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Usuário excluído.'),
      backgroundColor: AppTheme.verdeEscuro,
    ));
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Gerenciar Usuários',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UsersManagementScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _confirmarLogout,
          ),
        ],
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.vermelho))
          : RefreshIndicator(
              onRefresh: _carregar,
              color: AppTheme.vermelho,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // ── Card do usuário logado ─────────────────────────
                  if (_meuUsuario != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.verdeEscuro, AppTheme.marrom],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.dourado,
                            child: Text(
                              _meuUsuario!.name.isNotEmpty
                                  ? _meuUsuario!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppTheme.marrom,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _meuUsuario!.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(_meuUsuario!.email,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Cabeçalho da lista de usuários ─────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text('Usuários cadastrados',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),

                  if (_usuarios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('Nenhum usuário cadastrado.',
                            style: TextStyle(color: AppTheme.marrom)),
                      ),
                    )
                  else
                    for (final usuario in _usuarios)
                      UserCard(
                        user: usuario,
                        isCurrentUser: usuario.id == _meuId,
                        onEdit: () => _editarUsuario(usuario),
                        onDelete: () => _excluirUsuario(usuario),
                      ),
                ],
              ),
            ),
    );
  }
}
