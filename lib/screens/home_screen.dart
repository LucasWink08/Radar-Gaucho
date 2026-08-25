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
            label: 'Bandas',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined,
                color: Colors
                    .white70),
            selectedIcon: Icon(Icons.table_restaurant,
                color: AppTheme
                        .vermelho),
                      label: 'Reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline,
                color: Colors
                    .white70),
            selectedIcon: Icon(Icons.person,
                color: AppTheme
                        .vermelho),
                      label: 'Conta',
          ),
        ],
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              color: s.contains(WidgetState.selected)
                  ? AppTheme.dourado
                  : Colors.white60,
                fontSize: 12,
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.bold
                  : FontWeight.normal,
            )),
      ),
      body: IndexedStack(
        index: _aba,
        children: [
          _AbaEventos(
              onReservar: () => setState(
              () {})),
            const _AbaBandas(),
          _AbaReservas(
              onCancelar: () => setState(
              () {})),
            const _AbaConta(),
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
  final VoidCallback
      onReservar;
  const _AbaEventos(
      {required this.onReservar});

  @override
  State<_AbaEventos> createState() => _AbaEventosState();
}

class _AbaEventosState extends State<_AbaEventos> {
  Map<String, int> _ocupacao = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarOcupacao();
  }

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
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.vermelho),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star,
                color: AppTheme.dourado,
                size: 16),
            SizedBox(width: 8),
            Text('Radar Gaúcho'),
            SizedBox(width: 8),
            Icon(Icons.star,
                color: AppTheme.dourado,
                size: 16),
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.verdeEscuro,
                  AppTheme.marrom
                ],
                begin: Alignment
                    .topLeft,
                end: Alignment
                    .bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximos bailes',
                  style: TextStyle(
                      color: AppTheme
                          .dourado),
                ),
                SizedBox(
                    height: 8),
                Text(
                  'Reserve sua mesa antes que acabe!',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(
              height: 4),
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
                                _carregarOcupacao();
                                widget.onReservar();
                              })
                          : null,
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(
              height: 20),
        ],
      ),
    );
  }
}

class _AbaBandas extends StatefulWidget {
  const _AbaBandas();

  @override
  State<_AbaBandas> createState() =>
      _AbabandasState();
}

class _AbabandasState extends State<_AbaBandas> {
  GeneroBanda?
      _filtro;

  List<Banda>
      get _lista =>
          _filtro == null
              ? BandasMock.lista
              : BandasMock.lista
                  .where((b) => b.generos.contains(_filtro))
                  .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Bandas & Conjuntos')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection:
                  Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8), 
                  child: FilterChip(
                    label: const Text(
                        'Todos'), 
                    selected: _filtro ==
                        null, 
                    onSelected: (_) => setState(() =>
                        _filtro = null), 
                    selectedColor:
                        AppTheme.vermelho, 
                    labelStyle: TextStyle(
                      color: _filtro == null
                          ? Colors.white
                          : AppTheme
                              .marrom, 
                      fontWeight: _filtro == null
                          ? FontWeight.bold
                          : FontWeight.normal, 
                    ),
                    checkmarkColor:
                        Colors.white, 
                  ),
                ),
                ...GeneroBanda.values.map((g) {
                
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: 8), 
                    child: FilterChip(
                      label: Text(g
                          .label), 
                      selected: _filtro ==
                          g, 
                      onSelected: (_) => setState(() => _filtro = _filtro == g
                          ? null
                          : g), 
                      selectedColor:
                          AppTheme.vermelho, 
                      labelStyle: TextStyle(
                        color: _filtro == g
                            ? Colors.white
                            : AppTheme
                                .marrom, 
                        fontWeight:
                            _filtro == g ? FontWeight.bold : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: _lista
                  .isEmpty
                ? const Center(
                    child: Text('Nenhuma banda encontrada.',
                        style: TextStyle(color: AppTheme.marrom)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 20),
                    itemCount: _lista.length,
                    itemBuilder: (ctx, i) => BandaCard(
                      banda: _lista[
                          i],
                      onVerDetalhes: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => DetalheBandaScreen(
                              banda: _lista[
                                  i]),
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
  final VoidCallback
      onCancelar;
  const _AbaReservas(
      {required this.onCancelar});

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

    await ReservaRepo.cancelar(r.id!);
    if (!mounted) return;
    await _carregar();
    widget.onCancelar();
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

    await ReservaRepo.excluir(r.id!);
    if (!mounted) return;
    await _carregar();
    widget.onCancelar();
  }

  String _fmt(DateTime d) {
    final dd = d.day
      .toString()
      .padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min =
      d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final reservas = _reservas;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Minhas Reservas')),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.vermelho))
          : reservas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center,
                children: [
                  Icon(Icons.table_restaurant_outlined,
                      size: 72,
                        color: AppTheme.dourado),
                      SizedBox(height: 12),
                  Text('Nenhuma reserva ainda.',
                      style: TextStyle(
                          color: AppTheme.marrom,
                            fontSize: 16)),
                          SizedBox(height: 4),
                  Text('Explore os eventos e reserve uma mesa!',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                  top: 8, bottom: 24),
                itemCount: reservas.length,
              itemBuilder: (ctx, i) {
                final r = reservas[i];
                final cancelada = r.status ==
                    StatusReserva
                        .cancelada;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: cancelada
                          ? Colors.grey
                          : AppTheme
                              .vermelho,
                      child: Text(
                        '${r.numeroMesa}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      r.nomeEvento,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: AppTheme.marrom),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${r.nomeResponsavel} · ${r.numeroPessoas} pessoa(s)'),
                        Text(
                          _fmt(r
                              .criadaEm),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing:
                        cancelada
                            ? Row(
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
                                icon: const Icon(Icons.cancel_outlined,
                                    color: Colors
                                        .red),
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
  const _AbaConta();

  @override
  State<_AbaConta> createState() => _AbaContaState();
}

class _AbaContaState extends State<_AbaConta> {
  int? _meuId;
  User?
        _meuUsuario;
      List<User> _usuarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _editarUsuario(User usuario) async {
    final atualizado = await showUserFormDialog(context, user: usuario);
    if (atualizado == null) return;

    try {
      await DatabaseHelper.instance.updateUser(atualizado);

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
