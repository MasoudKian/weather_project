class CurrentCityDataModel {
  final String _cityName;
  final _lon;
  final _lat;
  final String _main;
  final String _description;
  final _temp;
  final _tempMin;
  final _tempMax;
  final _pressure;
  final _humidity;
  final _windSpeed;
  final _dataTime;
  final String _country;
  final _sunRise;
  final _sunSet;

  CurrentCityDataModel(
    this._cityName,
    this._lon,
    this._lat,
    this._main,
    this._description,
    this._temp,
    this._tempMin,
    this._tempMax,
    this._pressure,
    this._humidity,
    this._windSpeed,
    this._dataTime,
    this._country,
    this._sunRise,
    this._sunSet,
  );

  get sunSet => _sunSet;

  get sunRise => _sunRise;

  get country => _country;

  get dataTime => _dataTime;

  get windSpeed => _windSpeed;

  get humidity => _humidity;

  get pressure => _pressure;

  get tempMax => _tempMax;

  get tempMin => _tempMin;

  get temp => _temp;

  String get description => _description;

  String get main => _main;

  get lat => _lat;

  get lon => _lon;

  String get cityName => _cityName;
}
