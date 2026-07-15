## 0.9.2
- Throw StateError on circular dependency cycles instead of logging a warning.
- Add compile-time validation for missing dependency providers to fail the build runner step early with a descriptive error message.
- Refactor `SummaryReader` API to return nullable summaries instead of throwing `FileSystemException`, avoiding control-flow exceptions.

## 0.9.1
- Add example/example.md file

## 0.9.0

- Initial version.
