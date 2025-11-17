import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/symptom_entry.dart';
import '../providers/symptoms_provider.dart';
import '../widgets/symptom_checkbox_tile.dart';
import '../widgets/rounded_text_area.dart';

/// Screen for logging pregnancy symptoms with notes
///
/// Features:
/// - Select multiple symptoms from predefined list
/// - Add optional notes
/// - View past symptom entries
/// - Save entries to local database
/// - Pixel-faithful UI matching design specs
/// - Full accessibility support
class LogSymptomsScreen extends StatefulWidget {
  /// Optional existing entry to edit
  final SymptomEntry? initialEntry;

  /// Whether to navigate back after saving
  final bool navigateBackOnSave;

  const LogSymptomsScreen({
    super.key,
    this.initialEntry,
    this.navigateBackOnSave = true,
  });

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  // Controllers and state
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  final Set<String> _selectedSymptoms = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Load initial entry if editing
    if (widget.initialEntry != null) {
      _selectedSymptoms.addAll(widget.initialEntry!.symptoms);
      _notesController.text = widget.initialEntry!.notes ?? '';
    }

    // Load symptom entries on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SymptomsProvider>().fetchEntries();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  /// Check if form is valid (has at least one symptom or notes)
  bool get _isFormValid {
    return _selectedSymptoms.isNotEmpty ||
        _notesController.text.trim().isNotEmpty;
  }

  /// Toggle symptom selection
  void _toggleSymptom(String symptom, bool selected) {
    setState(() {
      if (selected) {
        _selectedSymptoms.add(symptom);
      } else {
        _selectedSymptoms.remove(symptom);
      }
    });
  }

  /// Save symptom entry
  Future<void> _saveEntry() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom or add notes'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<SymptomsProvider>();

      // Create entry
      final entry = SymptomEntry(
        id: widget.initialEntry?.id,
        timestamp: widget.initialEntry?.timestamp ?? DateTime.now(),
        symptoms: _selectedSymptoms.toList()..sort(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Save or update
      SymptomEntry? savedEntry;
      if (widget.initialEntry != null) {
        final success = await provider.updateEntry(entry);
        if (success) savedEntry = entry;
      } else {
        savedEntry = await provider.addEntry(entry);
      }

      if (savedEntry != null && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Entry saved'),
              ],
            ),
            backgroundColor: const Color(0xFF38A169),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back if requested
        if (widget.navigateBackOnSave) {
          Navigator.pop(context, savedEntry);
        } else {
          // Clear form for new entry
          setState(() {
            _selectedSymptoms.clear();
            _notesController.clear();
          });
        }
      } else if (mounted) {
        // Show error
        final error = provider.error ?? 'Failed to save entry';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Select Symptoms section
                      _buildSymptomsSection(),

                      const SizedBox(height: 24),

                      // Notes section
                      _buildNotesSection(),

                      const SizedBox(height: 24),

                      // Save button
                      _buildSaveButton(),

                      const SizedBox(height: 32),

                      // Past Entries section
                      _buildPastEntriesSection(),

                      const SizedBox(height: 24),
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

  /// Build header with back button and title
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E9EE), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Semantics(
            button: true,
            label: 'Go back',
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1A2332),
                  size: 24,
                ),
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'Log Symptoms',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2332),
              ),
            ),
          ),

          // Spacer to balance back button
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// Build symptoms selection section
  Widget _buildSymptomsSection() {
    return Consumer<SymptomsProvider>(
      builder: (context, provider, child) {
        final availableSymptoms = provider.availableSymptoms;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Select Symptoms',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 16),

            // Symptoms list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableSymptoms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final symptom = availableSymptoms[index];
                final isSelected = _selectedSymptoms.contains(symptom);
                final emoji = SymptomOptions.getSymptomIcon(symptom);

                return SymptomCheckboxTileWithEmoji(
                  symptom: symptom,
                  emoji: emoji,
                  isSelected: isSelected,
                  onChanged: (selected) => _toggleSymptom(symptom, selected),
                  semanticsLabel: SymptomOptions.getSymptomSemanticLabel(symptom),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Build notes input section
  Widget _buildNotesSection() {
    return RoundedTextArea(
      controller: _notesController,
      focusNode: _notesFocusNode,
      label: 'Notes',
      placeholder: 'Add any notes...',
      minHeight: 140,
      maxLength: 500,
      onChanged: (_) => setState(() {}), // Rebuild to update button state
      semanticsLabel: 'Add notes about your symptoms',
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isSaving ? _saveEntry : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D79FF),
          disabledBackgroundColor: const Color(0xFF0D79FF).withOpacity(0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  /// Build past entries section
  Widget _buildPastEntriesSection() {
    return Consumer<SymptomsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final entries = provider.entries;

        if (entries.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Past Entries',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A2332),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: const Color(0xFF718096).withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No entries yet',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Past Entries',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 16),

            // Entries list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length > 5 ? 5 : entries.length, // Show max 5
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildEntryTile(entry);
              },
            ),

            // Show more button if there are more entries
            if (entries.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to full entries list screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('View all entries screen coming soon'),
                        ),
                      );
                    },
                    child: Text(
                      'View all entries (${entries.length})',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0D79FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build a single entry tile
  Widget _buildEntryTile(SymptomEntry entry) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final dateStr = dateFormat.format(entry.timestamp);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _showEntryDetails(entry),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              // Date and symptoms
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2332),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.symptomsSummary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Chevron icon
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF718096),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show entry details dialog
  void _showEntryDetails(SymptomEntry entry) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy • h:mm a');
    final dateStr = dateFormat.format(entry.timestamp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Symptom Entry',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 16),

              // Symptoms
              Text(
                'Symptoms:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...entry.symptoms.map((symptom) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          SymptomOptions.getSymptomIcon(symptom),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          symptom,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  )),

              // Notes
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Notes:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.notes!,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: const Color(0xFF0D79FF)),
            ),
          ),
        ],
      ),
    );
  }
}
