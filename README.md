# CityPulse

Приложение для просмотра городских событий на карте. Позволяет находить, создавать, редактировать и удалять события, а также добавлять их в избранное.

## Возможности

- Карта с маркерами событий (требуется Google Maps API ключ)
- Создание и редактирование событий с выбором типа, даты и места
- Система избранного
- Фильтрация и поиск по событиям
- Светлая и тёмная тема
- Локализация на русский язык
- Оффлайн-хранилище (Hive)

## Архитектура

Clean Architecture с разделением на слои:

```
lib/
├── core/           -- общие компоненты (DI, ошибки, тема, утилиты)
├── features/
│   └── map/        -- фича "Карта событий"
│       ├── data/       -- datasources, models, repositories (реализации)
│       ├── domain/     -- entities, repositories (интерфейсы), usecases
│       └── presentation/ -- bloc, cubit, pages, widgets
```

## Стек

| Пакет | Назначение |
|-------|-----------|
| flutter_bloc | State management |
| get_it | Dependency injection |
| hive / hive_flutter | Локальная БД |
| google_maps_flutter | Карта |
| geolocator | Геолокация |
| dartz | Функциональный стиль (Either) |
| equatable | Сравнение объектов |
| intl | Локализация дат |

## Запуск

```bash
# Установка зависимостей
flutter pub get

# Запуск
flutter run
```

### Google Maps API ключ

Для работы карты добавьте ключ:

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_KEY")
```

## Тесты

```bash
flutter test
```

| Модуль | Тестов |
|--------|--------|
| SeedService | 7 |
| EventLocalDatasource | 11 |
| FavoriteLocalDatasource | 10 |
| EventModel | 9 |
| EventRepositoryImpl | 9 |
| GetEvents / GetEventById / SaveEvent | 9 |
| MapBloc | 6 |
| CreateEventCubit | 5 |
| FavoriteCubit | 10 |
| **Итого** | **76** |

## Сборка

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```
