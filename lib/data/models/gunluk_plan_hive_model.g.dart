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
      id: fields[0] as String,
      tarih: fields[1] as DateTime,
      kahvaltiJson: fields[2] as String?,
      araOgun1Json: fields[3] as String?,
      ogleYemegiJson: fields[4] as String?,
      araOgun2Json: fields[5] as String?,
      aksamYemegiJson: fields[6] as String?,
      geceAtistirmaJson: fields[7] as String?,
      makroHedefleriJson: fields[8] as String,
      fitnessSkoru: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GunlukPlanHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tarih)
      ..writeByte(2)
      ..write(obj.kahvaltiJson)
      ..writeByte(3)
      ..write(obj.araOgun1Json)
      ..writeByte(4)
      ..write(obj.ogleYemegiJson)
      ..writeByte(5)
      ..write(obj.araOgun2Json)
      ..writeByte(6)
      ..write(obj.aksamYemegiJson)
      ..writeByte(7)
      ..write(obj.geceAtistirmaJson)
      ..writeByte(8)
      ..write(obj.makroHedefleriJson)
      ..writeByte(9)
      ..write(obj.fitnessSkoru);
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
