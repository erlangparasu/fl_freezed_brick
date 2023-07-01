import 'package:mason/mason.dart';

void run(HookContext context) {
  // Read vars.
  final filename = context.vars['input_filaname'];

  // Use the `Logger` instance.
  context.logger.info('Generating file: $filename');

  // Update vars.
  context.vars['current_year'] = DateTime.now().year;
}
