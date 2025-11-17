// ignore_for_file: unused_local_variable

/// Example usage of LogSymptomsScreen
///
/// This file demonstrates how to integrate the Log Symptoms feature
/// into your pregnancy dashboard app. Copy these snippets to your screens.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pregnancy_dashboard/models/symptom_entry.dart';
import 'package:pregnancy_dashboard/providers/symptoms_provider.dart';

/// ============================================================================
/// EXAMPLE 1: Navigate to Log Symptoms from Dashboard
/// ============================================================================

class DashboardExample extends StatelessWidget {
  const DashboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple button to log symptoms
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to log symptoms screen
                final result = await Navigator.pushNamed(
                  context,
                  '/log-symptoms',
                );

                // Handle result (optional)
                if (result != null && result is SymptomEntry) {
                  debugPrint('User logged symptoms: ${result.symptomsSummary}');

                  // Show confirmation
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logged: ${result.symptomsSummary}'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.medical_information),
              label: const Text('Log Symptoms'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// EXAMPLE 2: Display Recent Symptom Entries
/// ============================================================================

class RecentSymptomsWidget extends StatelessWidget {
  const RecentSymptomsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.entries.isEmpty) {
          return const Center(
            child: Text('No symptoms logged yet'),
          );
        }

        // Get last 3 entries
        final recentEntries = provider.entries.take(3).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentEntries.length,
          itemBuilder: (context, index) {
            final entry = recentEntries[index];

            return ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: Text(entry.symptomsSummary),
              subtitle: Text(
                _formatDate(entry.timestamp),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to details or edit
                _showEntryDetails(context, entry);
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }

  void _showEntryDetails(BuildContext context, SymptomEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Symptom Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(entry.timestamp)}'),
            const SizedBox(height: 12),
            const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...entry.symptoms.map((s) => Text('• $s')),
            if (entry.notes != null) ...[
              const SizedBox(height: 12),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(entry.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// EXAMPLE 3: Symptom Statistics Dashboard
/// ============================================================================

class SymptomStatsWidget extends StatelessWidget {
  const SymptomStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomsProvider>(
      builder: (context, provider, child) {
        final frequency = provider.getSymptomFrequency();

        if (frequency.isEmpty) {
          return const Text('No symptom data yet');
        }

        // Sort by frequency
        final sortedSymptoms = frequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Common Symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sortedSymptoms.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

/// ============================================================================
/// EXAMPLE 4: Quick Log Symptom Button (stays on same screen)
/// ============================================================================

class QuickLogSymptomButton extends StatelessWidget {
  const QuickLogSymptomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        // Navigate and don't pop back automatically
        await Navigator.pushNamed(context, '/log-symptoms');

        // Refresh symptoms provider after logging
        if (context.mounted) {
          await context.read<SymptomsProvider>().fetchEntries();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Log Symptoms'),
    );
  }
}

/// ============================================================================
/// EXAMPLE 5: Edit Existing Symptom Entry
/// ============================================================================

class EditSymptomExample extends StatelessWidget {
  final SymptomEntry entryToEdit;

  const EditSymptomExample({
    super.key,
    required this.entryToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Navigate with initial entry for editing
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Placeholder(), // LogSymptomsScreen(
              // initialEntry: entryToEdit,
              // navigateBackOnSave: true,
            // ),
          ),
        );

        if (result != null && result is SymptomEntry && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Symptom entry updated')),
          );
        }
      },
      child: const Text('Edit Entry'),
    );
  }
}

/// ============================================================================
/// EXAMPLE 6: Add Custom Symptoms Programmatically
/// ============================================================================

class CustomSymptomExample extends StatelessWidget {
  const CustomSymptomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final provider = context.read<SymptomsProvider>();

        // Add custom symptoms to the available list
        provider.updateAvailableSymptoms([
          'Headache',
          'Nausea',
          'Swelling',
          'Blurred Vision',
          'Dizziness',
          'Fatigue',
          // Custom symptoms
          'Back Pain',
          'Leg Cramps',
          'Heartburn',
          'Shortness of Breath',
        ]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom symptoms added')),
        );
      },
      child: const Text('Add Custom Symptoms'),
    );
  }
}

/// ============================================================================
/// EXAMPLE 7: Symptom Calendar View (grouped by date)
/// ============================================================================

class SymptomCalendarWidget extends StatelessWidget {
  const SymptomCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomsProvider>(
      builder: (context, provider, child) {
        final grouped = provider.getEntriesGroupedByDate();

        if (grouped.isEmpty) {
          return const Center(child: Text('No entries yet'));
        }

        return ListView.builder(
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final date = grouped.keys.elementAt(index);
            final entries = grouped[date]!;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  _formatDateFull(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${entries.length} ${entries.length == 1 ? "entry" : "entries"}'),
                children: entries.map((entry) {
                  return ListTile(
                    dense: true,
                    title: Text(entry.symptomsSummary),
                    subtitle: entry.notes != null
                        ? Text(
                            entry.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateFull(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// ============================================================================
/// EXAMPLE 8: Bottom Sheet Quick Log (Alternative UI)
/// ============================================================================

void showQuickLogBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Log Symptoms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/log-symptoms');
              },
              child: const Text('Open Full Form'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// ============================================================================
/// EXAMPLE 9: Symptom Alert Banner (if critical symptoms detected)
/// ============================================================================

class SymptomAlertBanner extends StatelessWidget {
  const SymptomAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomsProvider>(
      builder: (context, provider, child) {
        final latestEntry = provider.latestEntry;

        if (latestEntry == null) return const SizedBox.shrink();

        // Check for critical symptoms
        final criticalSymptoms = [
          'Blurred Vision',
          'Severe Headache',
          'Chest Pain'
        ];

        final hasCritical = latestEntry.symptoms.any(
          (s) => criticalSymptoms.contains(s),
        );

        if (!hasCritical) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Critical Symptoms Detected',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please contact your healthcare provider immediately',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================================================================
/// USAGE IN MAIN DASHBOARD
/// ============================================================================

/*
class PregnancyDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pregnancy Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Alert banner if critical symptoms
            SymptomAlertBanner(),

            // Recent symptoms
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RecentSymptomsWidget(),
              ),
            ),

            // Statistics
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SymptomStatsWidget(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: QuickLogSymptomButton(),
    );
  }
}
*/
