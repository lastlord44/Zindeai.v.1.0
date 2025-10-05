// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gunluk_plan_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GunlukPlanHiveModelAdapter extends TypeAdapter<GunlukPlanHiveModel> {
  @override
  final int typeId = 1;

  @override
  GunlukPlanHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GunlukPlanHiveModel(
      id: fields[0] as String?,
      tarih: fields[1] as DateTime?,
      kahvalti: (fields[2] as Map?)?.cast<String, dynamic>(),
      ogleYemegi: (fields[3] as Map?)?.cast<String, dynamic>(),
      aksamYemegi: (fields[4] as Map?)?.cast<String, dynamic>(),
      araOgun: (fields[5] as Map?)?.cast<String, dynamic>(),
      fitnessSkoru: fields[6] as double?,
      makroHedefleri: (fields[7] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, GunlukPlanHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tarih)
      ..writeByte(2)
      ..write(obj.kahvalti)
      ..writeByte(3)
      ..write(obj.ogleYemegi)
      ..writeByte(4)
      ..write(obj.aksamYemegi)
      ..writeByte(5)
      ..write(obj.araOgun)
      ..writeByte(6)
      ..write(obj.fitnessSkoru)
      ..writeByte(7)
      ..write(obj.makroHedefleri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GunlukPlanHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
