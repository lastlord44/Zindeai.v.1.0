// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yemek_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YemekHiveModelAdapter extends TypeAdapter<YemekHiveModel> {
  @override
  final int typeId = 3;

  @override
  YemekHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YemekHiveModel(
      mealId: fields[0] as String?,
      category: fields[1] as String?,
      mealName: fields[2] as String?,
      calorie: fields[3] as double?,
      proteinG: fields[4] as double?,
      carbG: fields[5] as double?,
      fatG: fields[6] as double?,
      fiberG: fields[7] as double?,
      goalTag: fields[8] as String?,
      difficulty: fields[9] as String?,
      prepTimeMin: fields[10] as int?,
      ingredients: (fields[11] as List?)?.cast<String>(),
      recipe: fields[12] as String?,
      imageUrl: fields[13] as String?,
      tags: (fields[14] as List?)?.cast<String>(),
      alternatives: (fields[15] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, YemekHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.mealId)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.mealName)
      ..writeByte(3)
      ..write(obj.calorie)
      ..writeByte(4)
      ..write(obj.proteinG)
      ..writeByte(5)
      ..write(obj.carbG)
      ..writeByte(6)
      ..write(obj.fatG)
      ..writeByte(7)
      ..write(obj.fiberG)
      ..writeByte(8)
      ..write(obj.goalTag)
      ..writeByte(9)
      ..write(obj.difficulty)
      ..writeByte(10)
      ..write(obj.prepTimeMin)
      ..writeByte(11)
      ..write(obj.ingredients)
      ..writeByte(12)
      ..write(obj.recipe)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.tags)
      ..writeByte(15)
      ..write(obj.alternatives);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YemekHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
