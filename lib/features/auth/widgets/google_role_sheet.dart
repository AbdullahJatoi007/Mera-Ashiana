import 'package:flutter/material.dart';

/// Returns ('user'|'agency', phone) or null if dismissed.
Future<(String, String)?> showGoogleRoleSheet(
    BuildContext context, {
      String? email,
      String? name,
    }) {
  return showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _GoogleRoleSheet(email: email, name: name),
  );
}

class _GoogleRoleSheet extends StatefulWidget {
  final String? email;
  final String? name;
  const _GoogleRoleSheet({this.email, this.name});
  @override
  State<_GoogleRoleSheet> createState() => _GoogleRoleSheetState();
}

class _GoogleRoleSheetState extends State<_GoogleRoleSheet> {
  String _role = 'user';
  final _phone = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final p = _phone.text.trim();
    if (!RegExp(r'^\+?[\d\s\-]{6,20}$').hasMatch(p)) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }
    Navigator.pop(context, (_role, p));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finish setting up your account',
              style: Theme.of(context).textTheme.titleMedium),
          if (widget.email != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(widget.email!,
                  style: const TextStyle(color: Colors.grey)),
            ),
          const SizedBox(height: 16),
          const Text('I am a'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'user', label: Text('User')),
              ButtonSegment(value: 'agency', label: Text('Agency')),
            ],
            selected: {_role},
            onSelectionChanged: (s) => setState(() => _role = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone number',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}