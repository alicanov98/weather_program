import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_program/models/weather_model.dart';

class WeatherService {
  Future<String> getLocation() async {
    // Konum servisi açıqmı kontrol edirik.
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Konum servisi bağlıdırsa xeta veririk.
      throw Exception('Konumunuz bağlıdır!');
    }

    // İstifadəçinin konum icazəsi varmı kontrol edirik.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // İstifadəçi konum icazəsi verməyibsə icazə istəyirik.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // İstifadəçi yenə icazə verməzsə xeta veririk.
        throw Exception('Konum icazəsi verməlisiniz!');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // İstifadəçi konum icazəsini qalıcı olaraq rədd edibsə xeta veririk.
      throw Exception('Konum icazəsi qalıcı olaraq rədd edildi!');
    }

    // İstifadəçinin konumunu alırıq.
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // İstifadəçinin konumundan yerləşdiyi yeri tapırıq.
    final List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // Şəhəri dəyişkənə yazırıq.

    final String? city = placemark[0].locality;

    if (city == null) {
      // Şəhər tapılmadıqda xeta veririk.
      throw Exception("Bir xəta baş verdi!");
    }

    return city;
  }

  Future<List<WeatherModel>> getWeatherData() async {
    final String city = await getLocation();
    final String url =
        'https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$city';
    const Map<String, dynamic> headers = {
      'authorization': 'apikey 4I8DBYg8ETDeJrEZwwa0Pl:3Ht4IwjahVH2H75O2ecEDa',
      'content-type': 'application/json'
    };

    final dio = Dio();

    final response = await dio.get(url, options: Options(headers: headers));
    if (response.statusCode != 200) {
      return Future.error('Bir Xeta Bas Verdi!');
    }
    final List list = response.data['result'];
    final List<WeatherModel> weatherList =
        list.map((e) => WeatherModel.fromJson(e)).toList();
    return weatherList;
  }
}
