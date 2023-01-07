import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Riverpod',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

enum City {
  stockholm,
  paris,
  tokyo,
}

typedef WeatherEmoji = String;
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.stockholm: '❅',
      City.paris: '🌧️',
      City.tokyo: '💨',
    }[city]!,
  );
}

/*========== UI Writes to this and reads from this ==========*/
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
const unknownWeatherEmoji = '🤷‍♂️';

/*========== UI Reads This ==========*/
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) async {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return unknownWeatherEmoji;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Weather App'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          currentWeather.when(
            data: (data) => Text(
              data,
              style: const TextStyle(
                fontSize: 40,
              ),
            ),
            error: (error, stackTrace) => Text('🤖Error : === $error ==='),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                color: Colors.pink,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () => ref
                      .read(
                        currentCityProvider.notifier,
                      )
                      .state = city,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
