import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/life_provider.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '📝 Journal',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showNewEntrySheet(context),
          ),
        ],
      ),
      body: Consumer<LifeProvider>(
        builder: (context, provider, child) {
          final entries = provider.journalEntries;
          final todayEntry = provider.getTodayJournal();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's prompt
                  _buildTodayCard(todayEntry, context, provider)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 24),

                  // Mood tracker
                  _buildMoodTracker(entries)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 24),

                  // Past entries
                  if (entries.isNotEmpty) ...[
                    const Text(
                      'Past Reflections',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...entries.reversed.take(10).toList().asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildEntryCard(entry.value)
                            .animate(delay: Duration(milliseconds: 300 + entry.key * 100))
                            .fadeIn()
                            .slideX(begin: 0.1, end: 0),
                      );
                    }),
                  ] else
                    _buildEmptyState()
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard(JournalEntry? todayEntry, BuildContext context, LifeProvider provider) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF8B5CF6).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              if (todayEntry != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(todayEntry.moodEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF22C55E),
                        size: 20,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (todayEntry == null)
            GestureDetector(
              onTap: () => _showNewEntrySheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Write Today\'s Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todayEntry.reflection != null && todayEntry.reflection!.isNotEmpty)
                  Text(
                    todayEntry.reflection!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (todayEntry.gratitude.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: todayEntry.gratitude.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🙏 $g',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker(List<JournalEntry> entries) {
    final last7Days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dateStr = date.toIso8601String().split('T')[0];
      try {
        return entries.firstWhere(
          (e) => e.date.toIso8601String().split('T')[0] == dateStr,
        );
      } catch (e) {
        return null;
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Mood This Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: last7Days.asMap().entries.map((entry) {
              final journalEntry = entry.value;
              final date = DateTime.now().subtract(Duration(days: 6 - entry.key));
              final dayName = DateFormat('E').format(date).substring(0, 1);

              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: journalEntry != null
                          ? _getMoodColor(journalEntry.mood).withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        journalEntry?.moodEmoji ?? '·',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.amazing:
        return const Color(0xFF22C55E);
      case Mood.good:
        return const Color(0xFF3B82F6);
      case Mood.okay:
        return const Color(0xFFF59E0B);
      case Mood.bad:
        return const Color(0xFFEF4444);
      case Mood.terrible:
        return const Color(0xFF8B5CF6);
    }
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final dateStr = DateFormat('MMM d, yyyy').format(entry.date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getMoodColor(entry.mood).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(entry.moodEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (entry.reflection != null && entry.reflection!.isNotEmpty)
                  Text(
                    entry.reflection!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            entry.moodText,
            style: TextStyle(
              fontSize: 12,
              color: _getMoodColor(entry.mood),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('📝', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Start Your Journal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reflect on your day and track your mood',
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showNewEntrySheet(BuildContext context) {
    Mood selectedMood = Mood.okay;
    final reflectionController = TextEditingController();
    final gratitudeController = TextEditingController();
    List<String> gratitudeList = [];
    int energyLevel = 3;
    int productivityLevel = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a2e),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How are you feeling?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mood selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: Mood.values.map((mood) {
                          final isSelected = mood == selectedMood;
                          String emoji;
                          switch (mood) {
                            case Mood.amazing:
                              emoji = '🤩';
                              break;
                            case Mood.good:
                              emoji = '😊';
                              break;
                            case Mood.okay:
                              emoji = '😐';
                              break;
                            case Mood.bad:
                              emoji = '😔';
                              break;
                            case Mood.terrible:
                              emoji = '😢';
                              break;
                          }
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedMood = mood);
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getMoodColor(mood).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(color: _getMoodColor(mood), width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // Reflection
                      const Text(
                        '💭 What\'s on your mind?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reflectionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Gratitude
                      const Text(
                        '🙏 What are you grateful for?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: gratitudeController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Add something...',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              if (gratitudeController.text.isNotEmpty) {
                                setState(() {
                                  gratitudeList.add(gratitudeController.text);
                                  gratitudeController.clear();
                                });
                              }
                            },
                            icon: const Icon(Icons.add_circle, color: Color(0xFFF59E0B)),
                          ),
                        ],
                      ),
                      if (gratitudeList.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: gratitudeList.map((g) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    g,
                                    style: const TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => setState(() => gratitudeList.remove(g)),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Energy level
                      _buildSlider(
                        '⚡ Energy Level',
                        energyLevel,
                        (v) => setState(() => energyLevel = v),
                      ),
                      const SizedBox(height: 16),
                      // Productivity level
                      _buildSlider(
                        '📊 Productivity',
                        productivityLevel,
                        (v) => setState(() => productivityLevel = v),
                      ),
                      const SizedBox(height: 32),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final provider = Provider.of<LifeProvider>(
                              context,
                              listen: false,
                            );
                            provider.addJournalEntry(JournalEntry(
                              id: 'journal_${DateTime.now().millisecondsSinceEpoch}',
                              date: DateTime.now(),
                              mood: selectedMood,
                              reflection: reflectionController.text.isEmpty
                                  ? null
                                  : reflectionController.text,
                              gratitude: gratitudeList,
                              energyLevel: energyLevel,
                              productivityLevel: productivityLevel,
                            ));
                            Navigator.pop(context);
                            HapticFeedback.heavyImpact();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save Entry',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value/5',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (i) {
            final level = i + 1;
            final isSelected = level <= value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(level),
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
