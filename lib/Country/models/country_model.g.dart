// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryAdapter extends TypeAdapter<Country> {
  @override
  final int typeId = 0;

  @override
  Country read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Country(
      name: fields[0] as CountryName,
      capital: (fields[1] as List).cast<String>(),
      population: fields[2] as int,
      region: fields[3] as String,
      subregion: fields[4] as String,
      area: fields[5] as double?,
      borders: (fields[6] as List).cast<String>(),
      languages: (fields[7] as Map).cast<String, String>(),
      currencies: (fields[8] as Map).cast<String, Currency>(),
      timezones: (fields[9] as List).cast<String>(),
      flags: fields[10] as CountryFlags,
      latlng: (fields[11] as List?)?.cast<double>(),
      independent: fields[12] as bool,
      unMember: fields[13] as bool,
      fifa: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Country obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.capital)
      ..writeByte(2)
      ..write(obj.population)
      ..writeByte(3)
      ..write(obj.region)
      ..writeByte(4)
      ..write(obj.subregion)
      ..writeByte(5)
      ..write(obj.area)
      ..writeByte(6)
      ..write(obj.borders)
      ..writeByte(7)
      ..write(obj.languages)
      ..writeByte(8)
      ..write(obj.currencies)
      ..writeByte(9)
      ..write(obj.timezones)
      ..writeByte(10)
      ..write(obj.flags)
      ..writeByte(11)
      ..write(obj.latlng)
      ..writeByte(12)
      ..write(obj.independent)
      ..writeByte(13)
      ..write(obj.unMember)
      ..writeByte(14)
      ..write(obj.fifa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CountryNameAdapter extends TypeAdapter<CountryName> {
  @override
  final int typeId = 1;

  @override
  CountryName read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryName(
      common: fields[0] as String,
      official: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CountryName obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.common)
      ..writeByte(1)
      ..write(obj.official);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryNameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 2;

  @override
  Currency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Currency(
      name: fields[0] as String,
      symbol: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.symbol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CountryFlagsAdapter extends TypeAdapter<CountryFlags> {
  @override
  final int typeId = 3;

  @override
  CountryFlags read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryFlags(
      png: fields[0] as String,
      svg: fields[1] as String,
      alt: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CountryFlags obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.png)
      ..writeByte(1)
      ..write(obj.svg)
      ..writeByte(2)
      ..write(obj.alt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryFlagsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
