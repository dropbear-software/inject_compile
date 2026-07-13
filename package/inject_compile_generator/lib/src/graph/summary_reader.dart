// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:build/build.dart';
import '../models/summary.dart';

/// A reader that retrieves and caches [LibrarySummary] instances.
abstract class SummaryReader {
  /// The [LibrarySummary] read from [assetId].
  Future<LibrarySummary> read(AssetId assetId);
}

/// An implementation of [SummaryReader] that uses an [AssetReader] to load summaries.
class AssetSummaryReader implements SummaryReader {
  final AssetReader _reader;
  final Map<AssetId, LibrarySummary> _cache = {};

  AssetSummaryReader(this._reader);

  @override
  Future<LibrarySummary> read(AssetId assetId) async {
    if (_cache.containsKey(assetId)) {
      return _cache[assetId]!;
    }

    // The assetId passed here should be the .dart file,
    // but the summary is at .inject.summary.
    final summaryId = assetId.changeExtension('.inject.summary');

    if (!await _reader.canRead(summaryId)) {
      throw FileSystemException(
        summaryId.uri.toString(),
        'Could not read summary file',
      );
    }

    final json = await _reader.readAsString(summaryId);
    final summary = LibrarySummary.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    _cache[assetId] = summary;
    return summary;
  }
}
