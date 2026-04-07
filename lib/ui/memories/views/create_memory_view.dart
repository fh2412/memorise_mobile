import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/memories/view_models/create_memory_view_model.dart';
import 'package:provider/provider.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  @override
  Widget build(BuildContext context) {
    // Assuming ViewModel is provided higher up the tree
    final vm = context.watch<MemoryCreationViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("New Memory"), centerTitle: true),
      body: Theme(
        // Overriding the Stepper theme locally to ensure M3 consistency
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: theme.colorScheme.primary,
          ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          elevation: 0, // Keeps it flat and clean for M3
          currentStep: vm.currentStep,
          onStepContinue: () => vm.nextStep(3),
          onStepCancel: vm.previousStep,
          // Customizing controls to use M3 buttons
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: details.onStepContinue,
                      child: Text(vm.currentStep == 2 ? 'Create' : 'Next'),
                    ),
                  ),
                  if (vm.currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              state: vm.currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              isActive: vm.currentStep >= 0,
              title: const Text("Details"),
              content: MetadataStep(),
            ),
            Step(
              state: vm.currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              isActive: vm.currentStep >= 1,
              title: const Text("Friends"),
              content: const Card(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Center(child: Text("Friends List")),
                ),
              ),
            ),
            Step(
              isActive: vm.currentStep >= 2,
              title: const Text("Photos"),
              content: const Card(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Center(child: Text("Photo Grid")),
                ),
              ),
            ),
          ],
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
