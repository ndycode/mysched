import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection_monitor.dart';
import 'telemetry_service.dart';
import 'data_sync.dart';

/// Queues failed mutations for later retry when connectivity is restored.
class OfflineQueue {
  OfflineQueue._();

  static OfflineQueue? _instance;
  static OfflineQueue get instance {
    _instance ??= OfflineQueue._();
    return _instance!;
  }

  static const _queueKey = 'offline_mutation_queue_v1';
  static const _maxQueueSize = 100;
  static const _maxRetries = 5;

  SharedPreferences? _prefs;
  final ValueNotifier<int> pendingCount = ValueNotifier(0);
  final ValueNotifier<bool> isSyncing = ValueNotifier(false);

  VoidCallback? _connectionListener;
  bool _initialized = false;

  /// Initialize the queue and start listening for connectivity changes.
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _loadPendingCount();

    // Listen for connectivity changes
    _connectionListener = () {
      if (ConnectionMonitor.instance.isOnline && pendingCount.value > 0) {
        processQueue();
      }
    };
    ConnectionMonitor.instance.state.addListener(_connectionListener!);

    // If we're online and have pending items, process them
    if (ConnectionMonitor.instance.isOnline && pendingCount.value > 0) {
      unawaited(processQueue());
    }

    _initialized = true;
  }

  /// Enqueue a mutation for later processing.
  Future<void> enqueue(QueuedMutation mutation) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final queue = await _loadQueue(prefs);

    // Prevent queue from growing too large
    if (queue.length >= _maxQueueSize) {
      // Remove oldest items
      queue.removeRange(0, queue.length - _maxQueueSize + 1);
    }

    queue.add(mutation);
    await _saveQueue(prefs, queue);
    await _loadPendingCount();

    TelemetryService.instance.recordEvent(
      'offline_queue_enqueued',
      data: {'type': mutation.type, 'pending': pendingCount.value},
    );
  }

  /// Process all queued mutations.
  Future<void> processQueue() async {
    if (isSyncing.value) return;
    if (!ConnectionMonitor.instance.isOnline) return;

    isSyncing.value = true;
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    try {
      final queue = await _loadQueue(prefs);
      if (queue.isEmpty) {
        isSyncing.value = false;
        return;
      }

      final processed = <String>[];
      final failed = <QueuedMutation>[];

      for (final mutation in queue) {
        try {
          await _executeMutation(mutation);
          processed.add(mutation.id);
        } catch (e) {
          final updated = mutation.copyWith(
            retryCount: mutation.retryCount + 1,
            lastError: e.toString(),
          );

          if (updated.retryCount < _maxRetries) {
            failed.add(updated);
          } else {
            TelemetryService.instance.recordEvent(
              'offline_queue_dropped',
              data: {
                'type': mutation.type,
                'id': mutation.id,
                'error': e.toString(),
              },
            );
          }
        }
      }

      // Save remaining failed items
      await _saveQueue(prefs, failed);
      await _loadPendingCount();

      if (processed.isNotEmpty) {
        TelemetryService.instance.recordEvent(
          'offline_queue_processed',
          data: {'processed': processed.length, 'remaining': failed.length},
        );
        DataSync.instance.notifyRemindersChanged();
      }
    } finally {
      isSyncing.value = false;
    }
  }

  /// Clear all queued mutations.
  Future<void> clear() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    pendingCount.value = 0;
  }

  /// Get all pending mutations (for display purposes).
  Future<List<QueuedMutation>> getPending() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return _loadQueue(prefs);
  }

  Future<void> _loadPendingCount() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final queue = await _loadQueue(prefs);
    pendingCount.value = queue.length;
  }

  Future<List<QueuedMutation>> _loadQueue(SharedPreferences prefs) async {
    final raw = prefs.getString(_queueKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => QueuedMutation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveQueue(
    SharedPreferences prefs,
    List<QueuedMutation> queue,
  ) async {
    if (queue.isEmpty) {
      await prefs.remove(_queueKey);
      return;
    }
    final encoded = jsonEncode(queue.map((m) => m.toJson()).toList());
    await prefs.setString(_queueKey, encoded);
  }

  Future<void> _executeMutation(QueuedMutation mutation) async {
    // Execute based on mutation type
    // This is a dispatcher - actual execution depends on the mutation type
    final handler = _handlers[mutation.type];
    if (handler == null) {
      throw Exception('Unknown mutation type: ${mutation.type}');
    }
    await handler(mutation.payload);
  }

  // Registry of mutation handlers
  static final Map<String, Future<void> Function(Map<String, dynamic>)>
      _handlers = {};

  /// Register a handler for a mutation type.
  static void registerHandler(
    String type,
    Future<void> Function(Map<String, dynamic>) handler,
  ) {
    _handlers[type] = handler;
  }

  /// Remove a handler for a mutation type.
  static void unregisterHandler(String type) {
    _handlers.remove(type);
  }

  void dispose() {
    if (_connectionListener != null) {
      ConnectionMonitor.instance.state.removeListener(_connectionListener!);
      _connectionListener = null;
    }
  }

  @visibleForTesting
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
    _handlers.clear();
  }
}

/// Represents a queued mutation operation.
class QueuedMutation {
  const QueuedMutation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  QueuedMutation copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
  }) {
    return QueuedMutation(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  factory QueuedMutation.fromJson(Map<String, dynamic> json) {
    return QueuedMutation(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  /// Create a new mutation with a unique ID.
  factory QueuedMutation.create({
    required String type,
    required Map<String, dynamic> payload,
  }) {
    return QueuedMutation(
      id: '${DateTime.now().millisecondsSinceEpoch}_${type.hashCode}',
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );
  }
}
