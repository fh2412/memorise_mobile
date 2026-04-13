import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/memories/view_models/create_memory_view_model.dart';
import 'package:memorise_mobile/ui/memories/views/photo_selection.dart';
import 'package:memorise_mobile/ui/user/views/friends_selection_view.dart';
import 'package:provider/provider.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  void _handleFinish(MemoryCreationViewModel vm) async {
    // 1. Show the Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false, // User can't click away
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Creating your memory..."),
          ],
        ),
      ),
    );

    // 2. Trigger the logic
    bool success = await vm.finalizeCreation();

    // 3. Close the Loading Dialog
    if (mounted) Navigator.of(context).pop();

    // 4. If successful, go back to the Home/Feed screen
    if (success && mounted) {
      // Use pushNamedAndRemoveUntil or pop depending on your route logic
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemoryCreationViewModel>();
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _showDiscardDialog(context);
        if (shouldDiscard && context.mounted) {
          vm.handleBackAction();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("New Memory"), centerTitle: true),
        // --- THE TRICK ---
        // We use the bottomNavigationBar to keep buttons pinned at the bottom
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (vm.currentStep > 0) ...[
                  TextButton(
                    onPressed: vm.previousStep,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (vm.currentStep == 2) {
                        _handleFinish(vm);
                      } else {
                        vm.nextStep();
                      }
                    },
                    child: Text(vm.currentStep == 2 ? 'Create' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: Stepper(
            type: StepperType.horizontal,
            elevation: 0,
            currentStep: vm.currentStep,
            // 1. Hide the default controls entirely
            controlsBuilder: (context, details) => const SizedBox.shrink(),
            steps: [
              Step(
                state: vm.currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                isActive: vm.currentStep >= 0,
                title: const Text("Details"),
                content: const MetadataStep(),
              ),
              Step(
                state: vm.currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                isActive: vm.currentStep >= 1,
                title: const Text("Friends"),
                content: SizedBox(
                  // Remove hardcoded height or use constrained box for better responsiveness
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: FriendsSelectionStep(memoryId: vm.memoryId.toString()),
                ),
              ),
              Step(
                isActive: vm.currentStep >= 2,
                title: const Text("Photos"),
                content: vm.memoryId == null
                    ? const Center(
                        child: Text("Please complete the first step first."),
                      )
                    : PhotoSelection(memoryId: vm.memoryId!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetadataStep extends StatelessWidget {
  const MetadataStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemoryCreationViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE
        TextField(
          controller: vm.titleController,
          decoration: const InputDecoration(
            labelText: "Memory Title",
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 24),

        // DESCRIPTION
        TextField(
          controller: vm.descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Description",
            prefixIcon: Icon(Icons.description_outlined),
          ),
        ),
        const SizedBox(height: 24),

        // IS ACTIVE (Styled as an InputDecorator to match)
        InputDecorator(
          decoration: const InputDecoration(
            labelText: "Visibility",
            prefixIcon: Icon(Icons.visibility_outlined),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Memory is active"),
              Switch(value: vm.isActive, onChanged: vm.updateIsActive),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // DATES ROW
        Row(
          children: [
            Expanded(
              child: _DatePickerField(
                label: "Start Date",
                value: vm.startDate,
                onTap: () async {
                  final picked = await _showPicker(context, vm.startDate);
                  if (picked != null) vm.updateStartDate(picked);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePickerField(
                label: "End Date",
                value: vm.endDate,
                onTap: () async {
                  final picked = await _showPicker(context, vm.endDate);
                  if (picked != null) vm.updateEndDate(picked);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // LOCATION SECTION
        InputDecorator(
          decoration: const InputDecoration(
            labelText: "Location",
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          child: Text(
            vm.selectedLocationName ?? "No location selected",
            style: TextStyle(
              color: vm.selectedLocationName == null
                  ? colorScheme.outline
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: vm.fetchCurrentLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text("Current"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open Choose Location Widget
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("Choose"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<DateTime?> _showPicker(BuildContext context, DateTime? initial) async {
    return await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }
}

/// Helper for Styled Date Fields
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        ),
        child: Text(
          value == null ? "Select" : "${value!.toLocal()}".split(' ')[0],
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

Future<bool> _showDiscardDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Discard Memory?"),
          content: const Text(
            "Are you sure you want to cancel? All your current progress will be lost.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay here
              child: const Text("Continue Editing"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Exit
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text("Discard"),
            ),
          ],
        ),
      ) ??
      false; // Default to false if they click outside the dialog
}
