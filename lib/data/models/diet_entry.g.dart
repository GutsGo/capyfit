// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DietEntryAdapter extends TypeAdapter<DietEntry> {
  @override
  final int typeId = 7;

  @override
  DietEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DietEntry(
      id: fields[0] as String,
      meal: fields[1] as MealType,
      name: fields[2] as String,
      calories: fields[3] as int,
      protein: fields[4] as double,
      carbs: fields[5] as double,
      fat: fields[6] as double,
      time: fields[7] as String,
      date: fields[8] as String,
      foodId: fields[9] as String?,
      isCustom: fields[10] as bool? ?? false,
      emoji: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DietEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.meal)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.carbs)
      ..writeByte(6)
      ..write(obj.fat)
      ..writeByte(7)
      ..write(obj.time)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.foodId)
      ..writeByte(10)
      ..write(obj.isCustom)
      ..writeByte(11)
      ..write(obj.emoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 8;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      case 3:
        return MealType.snack;
      default:
        return MealType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast:
        writer.writeByte(0);
        break;
      case MealType.lunch:
        writer.writeByte(1);
        break;
      case MealType.dinner:
        writer.writeByte(2);
        break;
      case MealType.snack:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
