import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_store.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = AuthStore.instance.token;
    if (token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final u = await Api.adminUsers(token);
      if (mounted) setState(() => _users = u);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users (${_users.length})')),
      body: _loading || _error != null
          ? StateView(loading: _loading, error: _error, onRetry: _load)
          : RefreshIndicator(
              color: kBlue,
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (_, i) => _row(_users[i]),
              ),
            ),
    );
  }

  Widget _row(AppUser u) {
    final initial = (u.username.isNotEmpty ? u.username[0] : '?').toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: kBlue,
          backgroundImage:
              (u.imageUrl != null && u.imageUrl!.isNotEmpty) ? NetworkImage(u.imageUrl!) : null,
          child: (u.imageUrl == null || u.imageUrl!.isEmpty)
              ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.username, style: poppins(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(u.email,
                style: const TextStyle(color: kMuted, fontSize: 12.5),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        if (u.isAdmin)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0x140078D8), borderRadius: BorderRadius.circular(20)),
            child: const Text('Admin',
                style: TextStyle(color: kBlueDark, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}
