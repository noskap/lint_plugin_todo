library lint_plugin_todo;

import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => _TodoLinter();

final RegExp todoSelector = RegExp(r'TODO');

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _TodoLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const RequireTodoComment(),
        const RequireTodoTicketNumber(),
      ];
}

class RequireTodoComment extends DartLintRule {
  const RequireTodoComment() : super(code: _code);

  static const _code = LintCode(
    name: 'require_todo_comment',
    problemMessage: 'TODO comments should have a comment',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addComment((Comment node) {
      Token? commentToken = node.beginToken.precedingComments;
      while (commentToken != null) {
        if (todoSelector.hasMatch(commentToken.lexeme)) {
          final RegExp pattern = RegExp(r'TODO\s?.{6,}');
          if (pattern.hasMatch(commentToken.lexeme)) {
            // match found, do nothing
          } else {
            reporter.reportErrorForToken(code, commentToken);
          }
          commentToken = commentToken.next;
        }
      }
    });
  }
}

class RequireTodoTicketNumber extends DartLintRule {
  const RequireTodoTicketNumber() : super(code: _code);

  /// Metadata about the warning that will show-up in the IDE.
  /// This is used for `// ignore: code` and enabling/disabling the lint
  static const _code = LintCode(
    name: 'require_todo_ticket_number',
    problemMessage: 'TODO comments should have a ticket number',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleIdentifier((SimpleIdentifier node) {
      Token? commentToken = node.beginToken.precedingComments;
      final RegExp pattern = RegExp(r'TODO \w+-\d+');
      while (commentToken != null) {
        if (pattern.hasMatch(commentToken.lexeme)) {
          reporter.reportErrorForToken(code, commentToken);
        }
        commentToken = commentToken.next;
      }
    });
  }
}
