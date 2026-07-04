import 'package:hive/hive.dart';

// ─── Type IDs ────────────────────────────────────────────────────────────────

/// Hive type adapter IDs.  Must be unique across the entire app.
/// Keep this list up to date when adding new Hive types.
const int _todoModelTypeId = 0;
const int _pendingChangeModelTypeId = 1;
const int _locationModelTypeId = 2;

// ─── Sync Status Enum ────────────────────────────────────────────────────────

/// Represents the synchronisation state of a locally stored todo item.
enum SyncStatus {
  /// Item is in sync with the server.
  synced,

  /// Item has pending local changes not yet sent to the server.
  pending,

  /// Last sync attempt failed; will be retried.
  failed,
}

// ─── Pending Change Status Enum ──────────────────────────────────────────────

/// Lifecycle state of a pending-change record stored locally.
enum PendingChangeStatus {
  /// Waiting to be sent to the server.
  pending,

  /// Currently being transmitted.
  sending,

  /// Successfully delivered.
  sent,

  /// Delivery failed; retry eligible.
  failed,
}

// ─── Hive Models ─────────────────────────────────────────────────────────────

/// Hive model for a cached Todo item.
///
/// Stores the full todo payload so the app can display todos while offline
/// and tracks [syncStatus] to know whether local changes need uploading.
class TodoHiveModel extends HiveObject {
  String id;
  String title;
  String? description;
  bool isCompleted;
  String? dueAt;

  /// ISO-8601 timestamp of the last local modification.
  String updatedAt;

  /// Tracks whether this item still needs to be pushed to the server.
  /// Stores [SyncStatus.name] for Hive compatibility (plain String field).
  String syncStatus;

  TodoHiveModel({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  /// Convenience getter for the typed enum value.
  SyncStatus get syncStatusEnum => SyncStatus.values.firstWhere(
        (e) => e.name == syncStatus,
        orElse: () => SyncStatus.synced,
      );
}

/// Hive TypeAdapter for [TodoHiveModel].
class TodoHiveModelAdapter extends TypeAdapter<TodoHiveModel> {
  @override
  final int typeId = _todoModelTypeId;

  @override
  TodoHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      dueAt: fields[4] as String?,
      updatedAt: fields[5] as String,
      syncStatus: fields[6] as String? ?? 'synced',
    );
  }

  @override
  void write(BinaryWriter writer, TodoHiveModel obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.isCompleted);
    writer.writeByte(4);
    writer.write(obj.dueAt);
    writer.writeByte(5);
    writer.write(obj.updatedAt);
    writer.writeByte(6);
    writer.write(obj.syncStatus);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoHiveModelAdapter && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// ─── PendingChangeHiveModel ───────────────────────────────────────────────────

/// Hive model for a queued todo change that has not been synced to the server.
///
/// Created whenever the user toggles a todo while offline.  The sync service
/// reads these records and sends them via `POST /api/v1/todos/sync`.
class PendingChangeHiveModel extends HiveObject {
  String todoId;
  bool isCompleted;

  /// ISO-8601 timestamp of when the local change was made.
  String updatedAt;

  /// Number of failed upload attempts; used for back-off / give-up logic.
  int retryCount;

  /// Lifecycle status of this pending change (stores [PendingChangeStatus.name]).
  String status;

  PendingChangeHiveModel({
    required this.todoId,
    required this.isCompleted,
    required this.updatedAt,
    this.retryCount = 0,
    this.status = 'pending',
  });

  /// Convenience getter for the typed enum value.
  PendingChangeStatus get statusEnum => PendingChangeStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => PendingChangeStatus.pending,
      );
}

/// Hive TypeAdapter for [PendingChangeHiveModel].
class PendingChangeHiveModelAdapter extends TypeAdapter<PendingChangeHiveModel> {
  @override
  final int typeId = _pendingChangeModelTypeId;

  @override
  PendingChangeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingChangeHiveModel(
      todoId: fields[0] as String,
      isCompleted: fields[1] as bool,
      updatedAt: fields[2] as String,
      retryCount: fields[3] as int? ?? 0,
      status: fields[4] as String? ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, PendingChangeHiveModel obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.todoId);
    writer.writeByte(1);
    writer.write(obj.isCompleted);
    writer.writeByte(2);
    writer.write(obj.updatedAt);
    writer.writeByte(3);
    writer.write(obj.retryCount);
    writer.writeByte(4);
    writer.write(obj.status);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingChangeHiveModelAdapter && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// ─── LocationHiveModel ────────────────────────────────────────────────────────

/// Hive model for a cached geofence Location.
///
/// Written when locations are fetched from the server so that the background
/// isolate (WorkManager) can check geofences without a network call.
class LocationHiveModel extends HiveObject {
  String id;
  String locationName;
  double latitude;
  double longitude;
  double radiusM;
  bool isActive;

  LocationHiveModel({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusM,
    this.isActive = true,
  });
}

/// Hive TypeAdapter for [LocationHiveModel].
class LocationHiveModelAdapter extends TypeAdapter<LocationHiveModel> {
  @override
  final int typeId = _locationModelTypeId;

  @override
  LocationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationHiveModel(
      id: fields[0] as String,
      locationName: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      radiusM: fields[4] as double,
      isActive: fields[5] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, LocationHiveModel obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.locationName);
    writer.writeByte(2);
    writer.write(obj.latitude);
    writer.writeByte(3);
    writer.write(obj.longitude);
    writer.writeByte(4);
    writer.write(obj.radiusM);
    writer.writeByte(5);
    writer.write(obj.isActive);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationHiveModelAdapter && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}