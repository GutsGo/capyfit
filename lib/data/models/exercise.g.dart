// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 3;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as ExerciseCategory,
      difficulty: fields[3] as Difficulty,
      targetMuscles: (fields[4] as List).cast<String>(),
      met: fields[13] as double,
      sets: fields[5] as int?,
      reps: fields[6] as String?,
      duration: fields[7] as String?,
      description: fields[8] as String?,
      tips: (fields[9] as List?)?.cast<String>(),
      steps: (fields[10] as List?)?.cast<String>(),
      image: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.targetMuscles)
      ..writeByte(5)
      ..write(obj.sets)
      ..writeByte(6)
      ..write(obj.reps)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.tips)
      ..writeByte(10)
      ..write(obj.steps)
      ..writeByte(12)
      ..write(obj.image)
      ..writeByte(13)
      ..write(obj.met);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseCategoryAdapter extends TypeAdapter<ExerciseCategory> {
  @override
  final int typeId = 4;

  @override
  ExerciseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseCategory.chest;
      case 1:
        return ExerciseCategory.back;
      case 2:
        return ExerciseCategory.legs;
      case 3:
        return ExerciseCategory.shoulders;
      case 4:
        return ExerciseCategory.arms;
      case 5:
        return ExerciseCategory.core;
      case 6:
        return ExerciseCategory.cardio;
      case 7:
        return ExerciseCategory.yoga;
      case 8:
        return ExerciseCategory.other;
      default:
        return ExerciseCategory.chest;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseCategory obj) {
    switch (obj) {
      case ExerciseCategory.chest:
        writer.writeByte(0);
        break;
      case ExerciseCategory.back:
        writer.writeByte(1);
        break;
      case ExerciseCategory.legs:
        writer.writeByte(2);
        break;
      case ExerciseCategory.shoulders:
        writer.writeByte(3);
        break;
      case ExerciseCategory.arms:
        writer.writeByte(4);
        break;
      case ExerciseCategory.core:
        writer.writeByte(5);
        break;
      case ExerciseCategory.cardio:
        writer.writeByte(6);
        break;
      case ExerciseCategory.yoga:
        writer.writeByte(7);
        break;
      case ExerciseCategory.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final int typeId = 5;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.beginner;
      case 1:
        return Difficulty.intermediate;
      case 2:
        return Difficulty.advanced;
      default:
        return Difficulty.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.beginner:
        writer.writeByte(0);
        break;
      case Difficulty.intermediate:
        writer.writeByte(1);
        break;
      case Difficulty.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
