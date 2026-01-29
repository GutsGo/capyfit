// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      height: fields[0] as double,
      weight: fields[1] as double,
      gender: fields[2] as Gender,
      age: fields[3] as int,
      goal: fields[4] as UserGoal,
      isSmartCalculation: fields[5] as bool,
      customCalorieGoal: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.goal)
      ..writeByte(5)
      ..write(obj.isSmartCalculation)
      ..writeByte(6)
      ..write(obj.customCalorieGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserGoalAdapter extends TypeAdapter<UserGoal> {
  @override
  final int typeId = 1;

  @override
  UserGoal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserGoal.muscleGain;
      case 1:
        return UserGoal.weightLoss;
      case 2:
        return UserGoal.maintain;
      default:
        return UserGoal.muscleGain;
    }
  }

  @override
  void write(BinaryWriter writer, UserGoal obj) {
    switch (obj) {
      case UserGoal.muscleGain:
        writer.writeByte(0);
        break;
      case UserGoal.weightLoss:
        writer.writeByte(1);
        break;
      case UserGoal.maintain:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 2;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
