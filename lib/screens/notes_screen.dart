import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/upgrade_pro_modal.dart';
import '../theme/app_theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Map<String, String>> _journalEntries = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<AppProvider>(context);
    final isPremium = provider.user.isPremium;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Journal',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'journal_fab',
        backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.pastelGrowthIcon,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          if (!isPremium) {
            showUpgradeProModal(
              context,
              featureTitle: 'Journal & Reflection Logs',
              limitExplanation: 'Free plan includes read-only access to browse past reflections. Upgrade to Pro for ₹49/month to write and encrypt unlimited journal entries.',
            );
          } else {
            _showAddJournalDialog(context);
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          // Read-Only Banner for Free Mode
          if (!isPremium) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF0D5CE5)).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF0D5CE5)).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    color: isDark ? const Color(0xFF818CF8) : const Color(0xFF0D5CE5),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free Mode: Read-Only Access',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Browsing journal in read-only mode. Upgrade to Pro (₹49) to write encrypted journal entries.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF0D5CE5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showUpgradeProModal(
                        context,
                        featureTitle: 'Pro Journal',
                        limitExplanation: 'Upgrade to Pro for ₹49/month to record, format, and encrypt unlimited personal reflections and journals.',
                      );
                    },
                    child: const Text('Upgrade', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
          if (_journalEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  'No journal entries written yet.\nTap + or click below to record your first entry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
              ),
            )
          else
            ..._journalEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildJournalCard(context, item, index);
            }).toList(),

          // Dashed Quick Journal Entry Container
          GestureDetector(
            onTap: () {
              if (!isPremium) {
                showUpgradeProModal(
                  context,
                  featureTitle: 'Write Journal Entry',
                  limitExplanation: 'Free plan includes read-only access. Upgrade to Pro for ₹49/month to write, format, and encrypt personal reflections.',
                );
              } else {
                _showAddJournalDialog(context);
              }
            },
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardBg : AppTheme.pastelGrowth,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppTheme.darkCardBorder : const Color(0xFFB4DEBF),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: isDark ? AppTheme.darkIconGlow : AppTheme.pastelGrowthIcon,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to write a quick journal entry',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildJournalCard(
      BuildContext context, Map<String, String> item, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: AppTheme.darkCardBorder, width: 1) : null,
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['title']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  size: 20,
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditJournalDialog(context, index);
                  } else if (val == 'delete') {
                    setState(() {
                      _journalEntries.removeAt(index);
                    });
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: isDark ? AppTheme.darkPrimary : AppTheme.pastelGrowthIcon,
                        ),
                        const SizedBox(width: 8),
                        const Text('Edit Entry'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete Entry',
                            style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['body']!,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item['date']!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddJournalDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Journal Entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Journal Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts, goals, or reflections...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5CE5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _journalEntries.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': titleCtrl.text.trim(),
                        'body': bodyCtrl.text.trim(),
                        'date': 'Today',
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'Save Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditJournalDialog(BuildContext context, int index) {
    final titleCtrl = TextEditingController(text: _journalEntries[index]['title']);
    final bodyCtrl = TextEditingController(text: _journalEntries[index]['body']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Journal Entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Journal Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Journal Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5CE5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _journalEntries[index]['title'] = titleCtrl.text.trim();
                      _journalEntries[index]['body'] = bodyCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
