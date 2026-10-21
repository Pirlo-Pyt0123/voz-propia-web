import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_user.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_icon_button.dart';
import '../widgets/brutal_text_field.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  AdminStatsModel? _stats;
  List<AdminUserModel> _users = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _query = '';

  ApiClient get _api => context.read<AuthController>().api;

  List<AdminUserModel> get _filteredUsers {
    if (_query.isEmpty) return _users;
    final q = _query.toLowerCase();
    return _users
        .where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final statsJson = await _api.getAdminStats();
      final usersJson = await _api.listAdminUsers();
      _stats = AdminStatsModel.fromJson(statsJson);
      _users = usersJson.map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDeleteUser(AdminUserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: BrutalColors.ink.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: brutalDecoration(
              fill: BrutalColors.cream,
              radius: 20,
              borderWidth: 3,
              shadowOffset: const Offset(7, 7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Borrar a ${user.name}?',
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se van a borrar sus ${user.voiceProfileCount} perfiles de voz y todo lo asociado. '
                  'No se puede deshacer.',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar', style: TextStyle(color: BrutalColors.ink, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Borrar', style: TextStyle(color: BrutalColors.red, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _api.deleteAdminUser(user.id);
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return Scaffold(
      body: BrutalBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: BrutalColors.ink,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    BrutalIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Administración',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vista general del sistema y gestión de usuarios.',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  BrutalCard(
                    fill: BrutalColors.red,
                    child: Text(_error!, style: const TextStyle(color: BrutalColors.cream, fontWeight: FontWeight.w700)),
                  ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: BrutalColors.ink)),
                  )
                else if (stats != null) ...[
                  const Text(
                    'Evaluación agregada (MOS)',
                    style: TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  BrutalCard(
                    fill: BrutalColors.purple,
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatBlock(
                            label: 'Promedio MOS',
                            value: stats.averageMos != null ? stats.averageMos!.toStringAsFixed(2) : '—',
                            color: BrutalColors.cream,
                          ),
                        ),
                        Expanded(
                          child: _StatBlock(
                            label: 'Calificaciones',
                            value: '${stats.totalRatings}',
                            color: BrutalColors.cream,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sistema',
                    style: TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: BrutalCard(
                          fill: BrutalColors.green,
                          child: _StatBlock(label: 'Usuarios', value: '${stats.totalUsers}', color: BrutalColors.ink),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BrutalCard(
                          fill: BrutalColors.yellow,
                          child: _StatBlock(label: 'Perfiles de voz', value: '${stats.totalVoiceProfiles}', color: BrutalColors.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: BrutalCard(
                          child: _StatBlock(label: 'Grabaciones', value: '${stats.totalRecordings}', color: BrutalColors.ink),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BrutalCard(
                          child: _StatBlock(label: 'Frases sintetizadas', value: '${stats.totalSynthesizedPhrases}', color: BrutalColors.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BrutalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perfiles por estado',
                          style: TextStyle(color: BrutalColors.ink, fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        ...stats.profilesByStatus.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(e.key, style: const TextStyle(color: BrutalColors.ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text('${e.value}', style: const TextStyle(color: BrutalColors.ink, fontSize: 12.5, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Usuarios',
                        style: TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredUsers.length} de ${_users.length}',
                        style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.55), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BrutalTextField(
                    controller: _searchController,
                    hintText: 'Buscar por nombre o email...',
                    icon: Icons.search_rounded,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 10),
                  BrutalCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(BrutalColors.ink),
                          headingTextStyle: const TextStyle(
                            color: BrutalColors.cream,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                          dataTextStyle: const TextStyle(color: BrutalColors.ink, fontSize: 12.5),
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Rol')),
                            DataColumn(label: Text('Perfiles'), numeric: true),
                            DataColumn(label: Text('')),
                          ],
                          rows: _filteredUsers
                              .map(
                                (u) => DataRow(
                                  cells: [
                                    DataCell(Text(u.name)),
                                    DataCell(Text(u.email)),
                                    DataCell(Text(u.roleName)),
                                    DataCell(Text('${u.voiceProfileCount}')),
                                    DataCell(
                                      u.roleName == 'administrator'
                                          ? const SizedBox.shrink()
                                          : GestureDetector(
                                              onTap: () => _confirmDeleteUser(u),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: BrutalColors.red,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBlock({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

