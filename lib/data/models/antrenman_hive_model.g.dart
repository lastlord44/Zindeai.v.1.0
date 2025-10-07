// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'antrenman_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TamamlananAntrenmanHiveModelAdapter
    extends TypeAdapter<TamamlananAntrenmanHiveModel> {
  @override
  final int typeId = 2;

  @override
  TamamlananAntrenmanHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TamamlananAntrenmanHiveModel(
      id: fields[0] as String,
      antrenmanId: fields[1] as String,
      tamamlanmaTarihi: fields[2] as DateTime,
      tamamlananSure: fields[3] as int,
      yakilanKalori: fields[4] as int,
      tamamlananEgzersizler: (fields[5] as List).cast<String>(),
      kullaniciNotlari: fields[6] as double?,
      yorum: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TamamlananAntrenmanHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.antrenmanId)
      ..writeByte(2)
      ..write(obj.tamamlanmaTarihi)
      ..writeByte(3)
      ..write(obj.tamamlananSure)
      ..writeByte(4)
      ..write(obj.yakilanKalori)
      ..writeByte(5)
      ..write(obj.tamamlananEgzersizler)
      ..writeByte(6)
      ..write(obj.kullaniciNotlari)
      ..writeByte(7)
      ..write(obj.yorum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TamamlananAntrenmanHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
