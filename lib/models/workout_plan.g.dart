// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutPlanAdapter extends TypeAdapter<WorkoutPlan> {
  @override
  final int typeId = 9;

  @override
  WorkoutPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutPlan(
      id: fields[0] as String,
      name: fields[1] as String,
      date: fields[2] as String,
      time: fields[3] as String,
      duration: fields[4] as int,
      calories: fields[5] as int,
      type: fields[6] as WorkoutType,
      intensity: fields[7] as Intensity,
      completed: fields[8] as bool,
      exercises: (fields[9] as List?)?.cast<String>(),
      mode: fields[10] as PlanMode,
      completedDates: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutPlan obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.intensity)
      ..writeByte(8)
      ..write(obj.completed)
      ..writeByte(9)
      ..write(obj.exercises)
      ..writeByte(10)
      ..write(obj.mode)
      ..writeByte(11)
      ..write(obj.completedDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutTypeAdapter extends TypeAdapter<WorkoutType> {
  @override
  final int typeId = 10;

  @override
  WorkoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutType.strength;
      case 1:
        return WorkoutType.cardio;
      case 2:
        return WorkoutType.yoga;
      case 3:
        return WorkoutType.other;
      default:
        return WorkoutType.strength;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutType obj) {
    switch (obj) {
      case WorkoutType.strength:
        writer.writeByte(0);
        break;
      case WorkoutType.cardio:
        writer.writeByte(1);
        break;
      case WorkoutType.yoga:
        writer.writeByte(2);
        break;
      case WorkoutType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IntensityAdapter extends TypeAdapter<Intensity> {
  @override
  final int typeId = 11;

  @override
  Intensity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Intensity.low;
      case 1:
        return Intensity.medium;
      case 2:
        return Intensity.high;
      default:
        return Intensity.low;
    }
  }

  @override
  void write(BinaryWriter writer, Intensity obj) {
    switch (obj) {
      case Intensity.low:
        writer.writeByte(0);
        break;
      case Intensity.medium:
        writer.writeByte(1);
        break;
      case Intensity.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntensityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlanModeAdapter extends TypeAdapter<PlanMode> {
  @override
  final int typeId = 12;

  @override
  PlanMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlanMode.longTerm;
      case 2:
        return PlanMode.oneTime;
      default:
        return PlanMode.longTerm;
    }
  }

  @override
  void write(BinaryWriter writer, PlanMode obj) {
    switch (obj) {
      case PlanMode.longTerm:
        writer.writeByte(0);
        break;
      case PlanMode.oneTime:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
